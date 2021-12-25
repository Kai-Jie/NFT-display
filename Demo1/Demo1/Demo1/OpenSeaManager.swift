//
//  OpenSeaManager.swift
//  Demo1
//
//  Created by Neo Hsu on 2021/12/24.
//

import Foundation

private let serverURL = "https://api.opensea.io/api/"
private let assetsAPI = "v1/assets"

enum OpenSeaNotifyName:String {
  case Assets = "Assets"
}

class OpenSeaManager:NSObject
{
    
    struct AssetsResponse: Decodable {
        let assets: [Asset]
    }
    
    struct Asset: Decodable {
        let token_id: String
        let image_url: String
        let name: String
        let collection: Collection
        let description: String
        let permalink: String
        
    }
    
    struct Collection: Decodable {
        let name: String
    }
    
    func getAssets(owner:String,offset:Int,limit:Int)
    {
        let url = URL(string: serverURL+assetsAPI+"?format=json&owner=\(owner)&offset=\(offset)&limit=\(limit)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil
            {
                let userInfo = ["error":error!] as [String : Error]
                NotificationCenter.default.post(name: Notification.Name(OpenSeaNotifyName.Assets.rawValue), object: self,userInfo: userInfo)
                return
            }
            
            let response = response as! HTTPURLResponse
            let statusCode = response.statusCode
            
            if let data = data {
                do {
                    if response.statusCode  == HTTPStatusCode.Success.rawValue
                    {
                        let decoder = JSONDecoder()
                        let assetsResponse = try decoder.decode(AssetsResponse.self, from: data)
                        
                        let userInfo = ["statusCode":statusCode,"response":assetsResponse] as [String : Any]
                        NotificationCenter.default.post(name: Notification.Name(OpenSeaNotifyName.Assets.rawValue), object: self,userInfo: userInfo)
                    }else
                    {
                        let userInfo = ["statusCode":statusCode] as [String : Any]
                        NotificationCenter.default.post(name: Notification.Name(OpenSeaNotifyName.Assets.rawValue), object: self,userInfo: userInfo)
                    }
                } catch  {
                    print(error)
                }
            }
            
        }.resume()
    }

}
