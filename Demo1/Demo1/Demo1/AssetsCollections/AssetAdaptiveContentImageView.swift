//
//  AssetAdaptiveContentImageView.swift
//  Demo1
//
//  Created by Neo Hsu on 2021/12/25.
//

import UIKit

class AssetAdaptiveContentImageView:UIImageView
{
    override var image: UIImage?
    {
        didSet
        {
            guard let image = image else { return }

            let imagAaspectRatio = image.size.height/image.size.width

            if superview != nil {
                self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: imagAaspectRatio).isActive = true
            }
        }
    }
}
