//
//  RandomUserViewController.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/22.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import MBProgressHUD

class RandomUserViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = ""
            nameLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var genderLabel: UILabel! {
        didSet{
            genderLabel.text = ""
            genderLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var locationLabel: UILabel! {
        didSet{
            locationLabel.text = ""
            locationLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var emailLabel: UILabel! {
        didSet {
            emailLabel.text = ""
            emailLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    private let viewModel  = RandomUserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.bind()
    }
    
    func bind() {
        // Random User API call
        self.button.rx.tap.asDriver().drive(self.viewModel.inputs.fetchTrigger).disposed(by: rx.disposeBag)
        //self.viewModel.inputs.fetchTrigger.onNext(())

        // データを取得
        self.viewModel.outputs.user.asObservable().subscribe(onNext: { [weak self] in
            if let resultList = $0 {
                for person in resultList.results {
                    self?.nameLabel.text        = person.name.title
                    self?.genderLabel.text      = person.gender
                    self?.locationLabel.text    = person.location.city
                    self?.emailLabel.text       = person.email
                }
            }
        }).disposed(by: rx.disposeBag)
        
        // ローディング
        self.viewModel.isLoading.asDriver(onErrorJustReturn: false)
            .drive(MBProgressHUD.rx.isAnimating(view: self.view))
            .disposed(by: rx.disposeBag)

        // エラー表示
        self.viewModel.outputs.error
            .subscribe(onNext: { [unowned self] error in
                self.showAlert(error.localizedDescription)
            }).disposed(by: rx.disposeBag)
    }

}
