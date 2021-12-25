//
//  EthereumNodesManager.swift
//  Demo1
//
//  Created by Neo Hsu on 2021/12/26.
//

import Foundation

private let serverURL = "https://cloudflare-eth.com/"

enum EthereumNodesNotifyName:String {
  case GetETHBalance = "GetETHBalance"
}

class EthereumNodesManager:NSObject
{
    
    struct GetBalanceBody: Encodable {
        let jsonrpc: String
        let method: String
        let params: [String]
        let id: Int
    }
    
    struct GetBalanceResponse: Decodable {
        let jsonrpc: String
        let id:Int
        let result:String
    }
    
    
    func getBalance(jsonrpc:String,method:String,params:[String],id:Int)
    {
        let url = URL(string: serverURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let getBalanceBody = GetBalanceBody(jsonrpc: jsonrpc, method: method, params: params, id: id)
        let data = try? encoder.encode(getBalanceBody)
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil
            {
                let userInfo = ["error":error!] as [String : Error]
                NotificationCenter.default.post(name: Notification.Name(EthereumNodesNotifyName.GetETHBalance.rawValue), object: self,userInfo: userInfo)
                return
            }
            
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            
            if let data = data {
                do {
                    if response.statusCode  == HTTPStatusCode.Success.rawValue
                    {
                        let decoder = JSONDecoder()
                        let getBalanceResponse = try decoder.decode(GetBalanceResponse.self, from: data)

                        let userInfo = ["statusCode":status,"response":getBalanceResponse] as [String : Any]
                        NotificationCenter.default.post(name: Notification.Name(EthereumNodesNotifyName.GetETHBalance.rawValue), object: self,userInfo: userInfo)
                    }else
                    {
                        let userInfo = ["statusCode":status] as [String : Any]
                        NotificationCenter.default.post(name: Notification.Name(EthereumNodesNotifyName.GetETHBalance.rawValue), object: self,userInfo: userInfo)
                    }
                } catch  {
                    print(error)
                }
            }
            
        }.resume()
    }
    

}
