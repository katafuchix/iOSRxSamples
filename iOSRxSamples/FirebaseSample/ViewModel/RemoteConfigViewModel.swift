//
//  RemoteConfigViewModel.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/21.
//  Copyright © 2020 cano. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import Action
import Firebase
import RxFirebaseRemoteConfig
import RxOptional
import SwiftyJSON

protocol RemoteConfigViewModelInputs {
    var fetchTrigger: PublishSubject<Void> { get }
}

protocol RemoteConfigViewModelOutputs {
    var items: Observable<[Item]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<ActionError> { get }
}

protocol RemoteConfigViewModelType {
    var inputs: RemoteConfigViewModelInputs { get }
    var outputs: RemoteConfigViewModelOutputs { get }
}


class RemoteConfigViewModel: RemoteConfigViewModelInputs, RemoteConfigViewModelOutputs, RemoteConfigViewModelType {

    var inputs: RemoteConfigViewModelInputs { return self }
    var outputs: RemoteConfigViewModelOutputs { return self }

    // MARK: - Inputs
    let fetchTrigger = PublishSubject<Void>()

    // MARK: - Outputs
    let items: Observable<[Item]>
    let isLoading: Observable<Bool>
    let error: Observable<ActionError>

    // 内部変数
    private let status = BehaviorRelay<RemoteConfigFetchStatus>(value: .noFetchYet)
    private let itemJson = RemoteConfig.remoteConfig().configValue(forKey: "xxx_json")
    private let configAction: Action<(), RemoteConfigFetchStatus>
    private let disposeBag = DisposeBag()

    init() {

        // Actionを定義
        self.configAction = Action { _ in
            return RemoteConfig.remoteConfig().rx
            .fetch(withExpirationDuration: TimeInterval(180), activateFetched: true)
        }

        // 実行結果をbind
        self.configAction.elements
            .bind(to: status)
            .disposed(by: disposeBag)

        // 一時的な変数
        let tmpItems    = BehaviorRelay<[Item]>(value: [])
        // Observableをoutputs変数へ
        self.items      = tmpItems.asObservable()

        self.status
            .filter { $0 == RemoteConfigFetchStatus.success } // 接続成功時のみ
            .withLatestFrom(Observable.of(itemJson.stringValue)) // データ取得
            .filterNil()
            .compactMap { $0.data(using: .utf8) }
            .compactMap { data in
                // Jsonを解析して配列を生成
                do {
                    return try (JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]])?.compactMap { Item(json: JSON($0)) }
                } catch {
                    return []
                }
            }
        .bind(to: tmpItems)
        .disposed(by: disposeBag)

        // ローディング 初期値はfalse
        self.isLoading = self.configAction.executing.startWith(false)

        // エラー
        self.error = self.configAction.errors

        // 開始
        self.fetchTrigger
            .bind(to: self.configAction.inputs)
            .disposed(by: disposeBag)
    }
}

/*
こんなふうにして使う

        self.viewModel = ViewModel()

        // Firebase Remote Config へ接続
        self.viewModel.inputs.fetchTrigger.onNext(())

        // FireBase から データを取得してテーブルに表示
        self.viewModel.outputs.items.asObservable()
            .subscribe(onNext:{ [unowned self] items in
                self.items = items
                self.tableView.reloadData()  // DataSourceもRxにするとさらに楽
            }).disposed(by: rx.disposeBag)

        // ローディング
        self.viewModel.isLoading.asDriver(onErrorJustReturn: false)
            .drive(SVProgressHUD.rx.isAnimating())
            .disposed(by: rx.disposeBag)

        // エラー表示
        self.viewModel.outputs.error
            .subscribe(onNext: { [unowned self] error in
                // アラートとかで表示する
                print(error.localizedDescription)
            }).disposed(by: rx.disposeBag)
*/
