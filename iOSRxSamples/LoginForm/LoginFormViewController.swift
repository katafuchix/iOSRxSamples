//
//  LoginFormViewController.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/20.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class LoginFormViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: LoginButton!
    
    let viewModel = LoginFormViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.bind()
    }
    
    func bind() {
        self.usernameTextField.rx.text.map { $0 ?? "" }
            .bind(to: self.viewModel.usernameText)
            .disposed(by: rx.disposeBag)
        
        self.passwordTextField.rx.text.map { $0 ?? "" }
            .bind(to: self.viewModel.passwordText)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.isValid
            .bind(to: self.loginButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        self.loginButton.rx.tap.asDriver().drive(onNext: { _ in
            print("tap")
        }).disposed(by: rx.disposeBag)
        
        // エラー表示
        self.viewModel.outputs.error.subscribe(onNext: { [unowned self] error in
            self.showAlert(error.localizedDescription)
        }).disposed(by: rx.disposeBag)
    }

}
