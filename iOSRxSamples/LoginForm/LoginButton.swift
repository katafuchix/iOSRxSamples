//
//  LoginButton.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/20.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit

class LoginButton: UIButton {

    @IBInspectable var enableColor :UIColor?
    @IBInspectable var desableColor :UIColor?
    override open var isEnabled : Bool {
        willSet{
            self.backgroundColor = newValue ? enableColor : desableColor
        }
    }
}
