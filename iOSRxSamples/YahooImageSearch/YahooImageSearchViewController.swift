//
//  YahooImageSarchViewController.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/20.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD
import SKPhotoBrowser

class YahooImageSearchViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel = YahooImageSearchViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        self.bind()
    }

    func bind() {
        // 入力欄の値を検索キーワードにbind
        self.textField.rx.text.orEmpty
            .bind(to: self.viewModel.inputs.searchWord)
            .disposed(by: self.disposeBag)

        // キーボードを下げる
        self.textField.rx.controlEvent(.editingDidEndOnExit).asDriver()
            .drive(onNext: { [weak self] _ in
                self?.textField.resignFirstResponder()
            })
            .disposed(by: self.disposeBag)

        // 検索ボタン押下時に検索トリガを起動
        self.searchButton.rx.tap.asDriver()
            .drive(self.viewModel.searchTrigger)
            .disposed(by: self.disposeBag)

        // 検索可能な場合は検索ボタンを押下可能に
        self.viewModel.outputs.isSearchButtonEnabled
            .asObservable()
            .bind(to: self.searchButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        // 検索結果をコレクションで表示
        self.viewModel.outputs.items.asObservable()
            .bind(to: self.collectionView.rx.items(cellIdentifier: "ImageItemCell", cellType: ImageItemCell.self)) {
            (index, element, cell) in
                cell.configure(URL(string: element.src)!)
            }.disposed(by: self.disposeBag)

        self.collectionView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)

        // 検索中はMBProgressHUDを表示
        self.viewModel.outputs.isLoading.asDriver(onErrorJustReturn: false)
            .drive(MBProgressHUD.rx.isAnimating(view: self.view))
            .disposed(by: disposeBag)

        // エラー表示
        self.viewModel.outputs.error
            .subscribe(onNext: { [unowned self] error in
                self.showAlert(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

}

// 画像ビューワーで検索結果の画像をスライド表示
extension YahooImageSearchViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Observableで行いたい
        let photos: [SKPhoto] = self.viewModel.outputs.values.value
            .compactMap { return SKPhoto.photoWithImageURL($0.src) }
        
         let browser = SKPhotoBrowser(photos: photos)
         browser.initializePageIndex(indexPath.row)
         self.present(browser, animated: true, completion: {})
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.width * 0.9 / 3)
            return CGSize(width: width, height: width)
    }
}

