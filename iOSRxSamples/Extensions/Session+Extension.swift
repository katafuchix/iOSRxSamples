//
//  Session+Extension.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/22.
//  Copyright © 2020 cano. All rights reserved.
//

import Foundation
import APIKit
import RxSwift
import RxCocoa

// APIKit の Session.sendRequest に Observable を実装する
/**
 * Session for using RxSwift extension
 * - Url: https://qiita.com/natmark/items/5d8cd792d5aae364842f
 */
extension Session {
    
    /**
     * APIKit send action on RxSwift Observable
     * - Parameters:
     *   - request: Request object as APIKit
     */
    public func rx_sendRequest<T: Request>(_ request: T) -> Observable<T.Response> {
        return Observable.create { observer in
            let task = self.send(request) { result in
                switch result {
                case .success(let response):
                    observer.on(.next(response))
                    observer.on(.completed)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                task?.cancel()
            }
        }
    }

    /**
     * APIKit send action on RxSwift Observable
     * - Parameters:
     *   - request: Request object as APIKit
     */
    public class func rx_sendRequest<T: Request>(_ request: T) -> Observable<T.Response> {
        return shared.rx_sendRequest(request)
    }
}

