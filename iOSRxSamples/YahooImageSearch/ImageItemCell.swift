//
//  ImageItemCell.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/20.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit
import AlamofireImage

class ImageItemCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    func configure(_ url: URL) {
        self.imageView.af_setImage(withURL: url)
    }
}
