//
//  YahooImageSarchViewModel.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/20.
//  Copyright © 2020 cano. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import RxOptional
import Kanna

protocol YahooImageSearchViewModelInputs {
    // 検索キーワード
    var searchWord: BehaviorRelay<String?> { get }
    // 検索トリガ
    var searchTrigger: PublishSubject<Void> { get }
}

protocol YahooImageSearchViewModelOutputs {
    // 検索結果
    var items: Observable<[Img]> { get }
    var values: BehaviorRelay<[Img]> { get }
    // 検索ボタンの押下可否
    var isSearchButtonEnabled: Observable<Bool> { get }
    // 検索中か
    var isLoading: Observable<Bool> { get }
    // エラー
    var error: Observable<ActionError> { get }
}

protocol YahooImageSearchViewModelType {
    var inputs: YahooImageSearchViewModelInputs { get }
    var outputs: YahooImageSearchViewModelOutputs { get }
}


class YahooImageSearchViewModel: YahooImageSearchViewModelType, YahooImageSearchViewModelInputs, YahooImageSearchViewModelOutputs {
    
    // MARK: - Properties
    var inputs: YahooImageSearchViewModelInputs { return self }
    var outputs: YahooImageSearchViewModelOutputs { return self }

    // Input Sources
    let searchWord = BehaviorRelay<String?>(value: nil)     // 検索キーワード
    let searchTrigger = PublishSubject<Void>()  // 検索トリガ

    // Output Sources
    let items: Observable<[Img]>                    // 検索結果
    let values: BehaviorRelay<[Img]>
    let isSearchButtonEnabled: Observable<Bool>     // 検索ボタンの押下可否
    let isLoading: Observable<Bool>                 // 検索中か
    let error: Observable<ActionError>              // エラー

    private let action: Action<String, [Img]>       // 動作実態部分定義
    private let disposeBag = DisposeBag()

    init() {
        self.values = BehaviorRelay<[Img]>(value: [])
        self.items = self.values.asObservable()

        // 検索キーワード3文字以上で検索可能に
        self.isSearchButtonEnabled = self.searchWord.asObservable()
            .filterNil()
            .map { $0.count >= 3 }

        // アクション定義
        self.action = Action { keyword in
            // Yahoo画像検索
            let urlStr =  "https://search.yahoo.co.jp/image/search?n=60&p=\(keyword)"
            let url = URL(string:urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!

            // User-Agentに自分のメールアドレスをセットしておく
            var request = URLRequest(url: url)
            request.addValue("xxx@gmail.com", forHTTPHeaderField: "User-Agent")

            // 検索結果のHTMLをパースしてimgタグのsrcを配列で返す
            return URLSession.shared.rx.response(request: request)
                .filter{ $0.response.statusCode == 200 }
                .map{ $0.data }
                .map{ try! HTML(html: $0 as Data, encoding: .utf8) }
                .map{ $0.css("img").compactMap { $0["src"] }.filter { $0.hasPrefix("https://msp.c.yimg.jp") } }
                .map{ $0.compactMap{ Img(src:$0) } }
                .asObservable()
        }

        // 検索トリガ：検索可能な場合に検索キーワードをActionのinputsに渡す
        self.searchTrigger.withLatestFrom(self.searchWord.asObservable())
            .filterNil()
            .bind(to:self.action.inputs)
            .disposed(by: disposeBag)

        // Actionのoutputsを検索結果に渡す
        self.action.elements
            .bind(to: self.values)
            .disposed(by: disposeBag)

        // 検索中
        self.isLoading = action.executing.startWith(false)

        // エラー
        self.error = action.errors
    }
}
