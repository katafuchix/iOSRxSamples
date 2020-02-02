//
//  SignUpViewController.swift
//  iOSRxSamples
//
//  Created by cano on 2020/02/02.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import MBProgressHUD

class SignUpViewController: UITableViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    let viewModel: SignUpViewModelType = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.bind()
    }
    

    func bind() {
        // id欄
        self.idTextField.rx.text.asDriver()
            .filterNil()
            .drive(viewModel.inputs.idString)
            .disposed(by: rx.disposeBag)
        
        // メールアドレス欄
        self.mailTextField.rx.text.asDriver()
            .filterNil()
            .drive(viewModel.inputs.mailString)
            .disposed(by: rx.disposeBag)
        
        // パスワード欄
        self.passwordTextField.rx.text.asDriver()
            .filterNil()
            .drive(viewModel.inputs.passwordString)
            .disposed(by: rx.disposeBag)
        
        // 同意ボタン
        self.checkButton.rx.controlEvent(.touchDown).asDriver()
            .withLatestFrom(viewModel.inputs.isAgreementService.asDriver())
            .map { !$0 }
            .drive(viewModel.inputs.isAgreementService)
            .disposed(by: rx.disposeBag)
        
        // ViewModel側からONにする
        self.viewModel.inputs.isAgreementService.asDriver()
            .drive(checkButton.rx.isSelected)
            .disposed(by: rx.disposeBag)
        
        // 新規登録ボタン
        self.viewModel.outputs.isSignUpButtonEnabled
            .drive(signUpButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        // 新規登録ボタン押下でActionのinputにストリームを流す
        self.signUpButton.rx.tap.asDriver()
            //.do(onNext: { [weak self] in self?.view.endEditing(true) })
            .drive(viewModel.inputs.signUpTrigger)
            .disposed(by: rx.disposeBag)
        
        // 読み込みフラグ
        self.viewModel.outputs.isLoading
            .drive(MBProgressHUD.rx.isAnimating(view: navigationController?.view ?? view))
            .disposed(by: rx.disposeBag)
        
        // 新規登録成功
        self.viewModel.outputs.succeedLoginTrigger
            .drive(onNext: { _ in
                print("新規登録成功")
            })
            .disposed(by: rx.disposeBag)
        
        // エラー表示
        self.viewModel.outputs.error
            .drive(onNext: { [unowned self] error in
                self.showAlert(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }

}
