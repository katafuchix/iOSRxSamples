//
//  RandomUserViewModel.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/22.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Action
import RxOptional
import APIKit

protocol RandomUserViewModelInputs {
    var fetchTrigger: PublishSubject<Void> { get }
}

protocol RandomUserViewModelOutputs {
    var user: Observable<ResultListModel?> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<ActionError> { get }
}

protocol RandomUserViewModelType {
    var inputs: RandomUserViewModelInputs { get }
    var outputs: RandomUserViewModelOutputs { get }
}


class RandomUserViewModel: RandomUserViewModelInputs, RandomUserViewModelOutputs, RandomUserViewModelType {

    var inputs: RandomUserViewModelInputs { return self }
    var outputs: RandomUserViewModelOutputs { return self }

    // MARK: - Inputs
    let fetchTrigger = PublishSubject<Void>()

    // MARK: - Outputs
    let user: Observable<ResultListModel?>
    let isLoading: Observable<Bool>
    let error: Observable<ActionError>

    // 内部変数
    private let randomUserAction: Action<(), ResultListModel>
    private let disposeBag = DisposeBag()

    init() {
        // 一時的な変数
        let tmpUser    = BehaviorRelay<ResultListModel?>(value: nil)
        // Observableをoutputs変数へ
        self.user      = tmpUser.asObservable()
        
        // Actionを定義
        self.randomUserAction = Action { _ in
            return Session.rx_sendRequest(FetchRandomUserRequest())
        }
        
        // 実行結果をbind
        self.randomUserAction.elements
            .bind(to: tmpUser)
            .disposed(by: disposeBag)
        
        // ローディング 初期値はfalse
        self.isLoading = self.randomUserAction.executing.startWith(false)
        
        // エラー
        self.error = self.randomUserAction.errors
        
        // 開始
        self.fetchTrigger
            .bind(to: self.randomUserAction.inputs)
            .disposed(by: disposeBag)
        
    }
}
