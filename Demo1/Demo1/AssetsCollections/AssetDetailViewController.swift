//
//  AssetDetailViewController.swift
//  Demo1
//
//  Created by Neo Hsu on 2021/12/25.
//

import UIKit
import Kingfisher

class AssetDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    private var assetData:OpenSeaManager.Asset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        initUI()
    }
    
    func initUI()
    {
        if assetData == nil
        {
            print("No assetData")
            return
        }
            
        self.navigationItem.title = assetData!.collection.name
        
        if let url = URL(string:assetData!.image_url)
        {
            self.imageView.kf.setImage(with: url)
        }
        
        self.nameLabel.text = assetData!.name
        
        self.descriptionTextView.text = assetData!.description
    }
    
    func setAssetData(asset:OpenSeaManager.Asset)
    {
        self.assetData = asset
    }
    
    @IBAction func permalinkButtonTouch(_ sender: Any) {
        
        if assetData == nil
        {
            print("No assetData")
            return
        }
        
        guard let tutorialUrl = URL(string:assetData!.permalink) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(tutorialUrl)
        {
            UIApplication.shared.open(tutorialUrl, options: [:], completionHandler: nil)
        }
    }
    
}
