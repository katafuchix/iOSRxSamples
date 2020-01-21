//
//  UIButton+Extension.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/20.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(_ title: String, _ message: String? = nil, _ buttonTitle: String? = nil, completion: AlertCompletion? = nil) {
        let alert = Alert(title, message)
        _ = alert.addAction(buttonTitle ?? "OK", completion: completion)
        alert.show(self)
    }
    
    func showAlertOKCancel(
            _ title: String, _ message: String? = nil, _ buttonTitle: String? = nil, _ cancelbuttonTitle: String? = nil, completion: AlertCompletion? = nil
        
        ){
        let alert = Alert(title, message)
        _ = alert.addAction(buttonTitle ?? "OK", completion: completion)
        _ = alert.setCancelAction(cancelbuttonTitle ?? "Cancel", completion: nil)
        alert.show(self)
    }
}

public typealias AlertCompletion = ((AlertResult) -> Void)

public enum AlertButtonType {
    case cancel(title: String)
    case other(title: String)
    case textField(text: String, placeholder: String?)
}

public enum AlertResult {
    case cancel
    case other(inputText: [String])
}

private struct AlertInfo {
    
    let type : AlertButtonType
    let completion : AlertCompletion?
    
    init(_ type: AlertButtonType, _ completion: AlertCompletion?) {
        self.type = type
        self.completion = completion
    }
}

public final class Alert {
    
    public let title : String
    public let message : String
    
    private var alertInfo : [AlertInfo] = []
    private var cancelInfo : AlertInfo?
    
    public init(_ title: String, _ message: String? = nil) {
        self.title = title
        self.message = message ?? ""
    }
    
    public func setCancelAction(_ buttonTitle: String = "Cancel", completion: AlertCompletion? = nil) -> Alert {
        self.cancelInfo = AlertInfo(.cancel(title: buttonTitle), completion)
        return self
    }
    
    public func addAction(_ buttonTitle: String, completion: AlertCompletion?) -> Alert {
        let alertInfo = AlertInfo(.other(title: buttonTitle), completion)
        self.alertInfo.append(alertInfo)
        return self
    }
    
    public func addTextField(_ text: String, _ placeholder: String?) -> Alert  {
        let alertInfo = AlertInfo(.textField(text: text, placeholder: placeholder), nil)
        self.alertInfo.append(alertInfo)
        return self
    }
    
    public func show(_ owner: UIViewController?) {
        guard let _owner = owner else { return }
        
        let alertController = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
        
        if let _cancelInfo = self.cancelInfo {
            self.alertInfo.append(_cancelInfo)
            self.cancelInfo = nil
        }
        
        self.alertInfo.forEach() { info in
            switch info.type {
            case .cancel(let buttonTitle):
                let action = UIAlertAction(title: buttonTitle, style: .cancel) { action in
                    info.completion?(.cancel)
                }
                alertController.addAction(action)
            case .other(let buttonTitle):
                let action = UIAlertAction(title: buttonTitle, style: .default) { action in
                    var inputText: [String] = []
                    alertController.textFields?.forEach() {
                        inputText.append($0.text ?? "")
                    }
                    info.completion?(.other(inputText: inputText))
                }
                alertController.addAction(action)
            case .textField(let text, let placeholder):
                alertController.addTextField() { textField in
                    textField.text = text
                    textField.placeholder = placeholder
                }
            }
        }
        
        if self.alertInfo.count == 0 {
            let action = UIAlertAction(title: "OK", style: .default) { _ in }
            alertController.addAction(action)
        }
        
        _owner.present(alertController, animated: true, completion: {
            log.debug("ALERT {\(self.title) + \(self.message)}")
        })
    }
}
