//
//  SignUpViewModel.swift
//  iOSRxSamples
//
//  Created by cano on 2020/02/02.
//  Copyright © 2020 cano. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import Action

protocol SignUpViewModelInputs {
    var idString: BehaviorRelay<String> { get }
    var mailString: BehaviorRelay<String> { get }
    var passwordString: BehaviorRelay<String> { get }
    var isAgreementService: BehaviorRelay<Bool> { get }
    var signUpTrigger: PublishSubject<Void> { get }
}

protocol SignUpViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var error: Driver<ActionError> { get }
    var succeedLoginTrigger: Driver<Void> { get }
    var isSignUpButtonEnabled: Driver<Bool> { get }
}

protocol SignUpViewModelType {
    var inputs: SignUpViewModelInputs { get }
    var outputs: SignUpViewModelOutputs { get }
}

class SignUpViewModel: SignUpViewModelType, SignUpViewModelInputs, SignUpViewModelOutputs {

    // MARK: - Properties
    var inputs: SignUpViewModelInputs { return self }
    var outputs: SignUpViewModelOutputs { return self }

    // Input Sources
    let idString            = BehaviorRelay<String>(value: "")
    let mailString          = BehaviorRelay<String>(value: "")
    let passwordString      = BehaviorRelay<String>(value: "")
    let isAgreementService  = BehaviorRelay<Bool>(value: false)
    let signUpTrigger       = PublishSubject<Void>()
    
    // Output Source
    let isLoading: Driver<Bool>
    let error: Driver<ActionError>
    let succeedLoginTrigger: Driver<Void>
    let isSignUpButtonEnabled: Driver<Bool>
    
    // 内部変数
    private let signUpAction: Action<(), Bool>
    private let disposeBag = DisposeBag()
    
    init () {
        self.isSignUpButtonEnabled = Driver.combineLatest(idString.asDriver(),
                                                          mailString.asDriver(),
                                                          passwordString.asDriver(),
                                                          isAgreementService.asDriver()) { $0.count >= 2 && !$1.isEmpty && $2.count >= 8 && $3}
        // アクション
        self.signUpAction = Action { _ in
            return Observable.just(true)
        }
        
        // 新規登録成功
        self.succeedLoginTrigger = self.signUpAction.elements.asDriver(onErrorDriveWith: .empty())
        .do(onNext: { _ in
            }
        ).map { _ in }
        
        // トリガをinputsにbindしてく 実際の起動はdrive
        self.signUpTrigger
            .bind(to: self.signUpAction.inputs)
            .disposed(by: disposeBag)
        
        // 読み込みフラグ
        self.isLoading = self.signUpAction.executing.asDriver(onErrorDriveWith: .empty())
        
        // エラー
        self.error = self.signUpAction.errors.asDriver(onErrorDriveWith: .empty())
    }
}
