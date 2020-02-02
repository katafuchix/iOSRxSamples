//
//  LoginFormViewModel.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/20.
//  Copyright © 2020 cano. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import Action

// 入力
protocol LoginFormViewModelInputs {
    // ユーザー名
    var usernameText: BehaviorRelay<String> { get }
    // パスワード
    var passwordText: BehaviorRelay<String>{ get }
}

// 出力
protocol LoginFormViewModelOutputs {
    // ボタンの押下可否
    var isValid: Observable<Bool> { get }
    // エラー
    var error: Observable<ActionError> { get }
}

// 管理
protocol LoginFormViewModelType {
    var inputs: LoginFormViewModelInputs { get }
    var outputs: LoginFormViewModelOutputs { get }
}

class LoginFormViewModel: LoginFormViewModelType, LoginFormViewModelInputs, LoginFormViewModelOutputs {

    var inputs: LoginFormViewModelInputs { return self }
    var outputs: LoginFormViewModelOutputs { return self }

    // MARK: - Inputs
    let usernameText = BehaviorRelay<String>(value: "")
    let passwordText = BehaviorRelay<String>(value: "")

    // MARK: - Outputs
    let isValid: Observable<Bool>
    let error: Observable<ActionError>

    // 内部変数
    private let validAction: Action<(String, String), Bool>
    private let disposeBag = DisposeBag()
    
    init() {
        // Action定義
        self.validAction = Action { username, password in
            // ユーザー名、パスワードともに４文字以上であればtrue
            return Observable<Bool>.of(username.description.count >= 4 && password.description.count >= 4)
        }
        
        // ユーザー名とパスワードのストリームをActionのinputにbind
        Observable.combineLatest(self.usernameText.asObservable(), self.passwordText.asObservable())
            .bind(to: self.validAction.inputs)
            .disposed(by: self.disposeBag)
        
        // bind用に内部変数を宣言
        let _isValid = BehaviorRelay<Bool>(value: false)
        // そのObservableを出力用変数へ
        self.isValid = _isValid.asObservable()
        
        // Actionのoutputを内部変数にbind
        self.validAction.elements
            .bind(to: _isValid)
            .disposed(by: self.disposeBag)
        
        // エラー
        self.error = self.validAction.errors
    }
}

