//
//  AssetsCollectionsViewController.swift
//  Demo1
//
//  Created by Neo Hsu on 2021/12/24.
//

import UIKit
import Kingfisher

class AssetsCollectionsViewController: UICollectionViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    let openSeaManager = OpenSeaManager()
    let ethereumNodesManager = EthereumNodesManager()
    let networkKit = NetworkKit.sharedInstance()
    
    private let reuseIdentifier = "AssetsCollectionsCell"
    private let owner = "0x960DE9907A2e2f5363646d48D7FB675Cd2892e91"
    private var isLoading = false
    private var assetDataSource:[OpenSeaManager.Asset] = []
    private var balance:UInt64 = 0
    {
        didSet
        {
            let headerView = self.collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first

            (headerView as! AssetsCollectionsHeaderView).balanceLabel.text = "\(self.balance) wei"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getETHBalanceResponseHandler), name: Notification.Name(EthereumNodesNotifyName.GetETHBalance.rawValue), object:self.ethereumNodesManager)
        NotificationCenter.default.addObserver(self, selector: #selector(assetsResponseHandler), name: Notification.Name(OpenSeaNotifyName.Assets.rawValue), object:self.openSeaManager)
        
        if networkKit.status != .satisfied
        {
            self.messageLabel.text = "No network"
        }else
        {
            getETHBalance()
        }
    }
    
    @objc func getETHBalanceResponseHandler(_ notification: Notification)
    {
        let response = notification.userInfo?["response"] as? EthereumNodesManager.GetBalanceResponse

        DispatchQueue.main.async { [weak self] in
            if response == nil
            {
                //Fail process
            }else
            {
                //is UInt64 enouth?
                if let wei = UInt64(response!.result.replacingOccurrences(of: "0x", with: ""), radix: 16)
                {
                    self?.balance = wei
                }
            }
            
        }
    }
    
    @objc func assetsResponseHandler(_ notification: Notification)
    {
        let response = notification.userInfo?["response"] as? OpenSeaManager.AssetsResponse
  
        if isLoading == false
        {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if response == nil
            {
                //Fail process
                self?.messageLabel.text = "Request Fail"
            }else
            {
                self?.assetDataSource.append(contentsOf:response!.assets)
                self?.collectionView.performBatchUpdates({
                        
                    //Last item index is (numberOfItems - 1),will insert item index = (last item index + 1) = numberOfItems
                    let insertItemIndex = self!.collectionView.numberOfItems(inSection: 0)
                    
                    for i in 0..<response!.assets.count
                    {
                        self!.collectionView.insertItems(at: [IndexPath(row: insertItemIndex + i, section: 0)])
                    }
                }, completion: nil)
            }
            
            self?.isLoading = false
            self?.activityIndicatorView.stopAnimating()
        }
    }
    
    private func getETHBalance()
    {
        DispatchQueue.global().async {
            let owner = "0x960DE9907A2e2f5363646d48D7FB675Cd2892e91"
            
            self.ethereumNodesManager.getBalance(jsonrpc: "2.0", method: "eth_getBalance", params: [owner,"latest"], id: 1)
        }
    }
    
    private func loadAssets(offset:Int,limit:Int)
    {
        DispatchQueue.global().async {
            let owner = "0x960DE9907A2e2f5363646d48D7FB675Cd2892e91"
            
            self.openSeaManager.getAssets(owner:owner, offset:offset, limit:limit)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.isLoading = false
        self.activityIndicatorView.stopAnimating()
        NotificationCenter.default.removeObserver(self)
    }
    
//MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AssetsCollectionsHeader", for: IndexPath(row: 0, section: 0))
            
            (headerView as! AssetsCollectionsHeaderView).balanceLabel.text = "\(self.balance) wei"
            
            return headerView
        }else
        {
            let reusableView = UICollectionReusableView()
            
            return reusableView
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if let assetDetailViewController = storyboard?.instantiateViewController(withIdentifier: "AssetDetailViewController") as? AssetDetailViewController
        {
            assetDetailViewController.setAssetData(asset: assetDataSource[indexPath.row])
            self.navigationController?.pushViewController(assetDetailViewController, animated: true)
        }
    }
    
//MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
          as! AssetsCollectionsCell
        
        let url = URL(string: assetDataSource[indexPath.row].image_url)
        cell.imageView.kf.setImage(with: url)
        cell.nameLabel.text = assetDataSource[indexPath.row].name
        
        return cell
    }
    
//MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let lastItemIndex = self.collectionView.numberOfItems(inSection: 0)
        let nearContentBottomOffset = scrollView.contentSize.height - scrollView.frame.height - 150
        
        if scrollView.contentOffset.y > nearContentBottomOffset
        {
            if networkKit.status == .satisfied
            {
                self.messageLabel.text = ""
                if isLoading == false
                {
                    
                    isLoading = true
                    activityIndicatorView.startAnimating()
                    loadAssets(offset: lastItemIndex, limit: 20)
                    
                }
            }else
            {
                self.messageLabel.text = "No network"
            }
        }
    }
    
}

