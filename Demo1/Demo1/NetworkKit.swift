//
//  NetworkKit.swift
//  Demo1
//
//  Created by Neo Hsu on 2021/12/24.
//

import Network

class NetworkKit: NSObject
{
    static var sharedNetworkKit:NetworkKit?
    let monitor = NWPathMonitor()
    var status = NWPath.Status.unsatisfied
    
    class func sharedInstance() -> NetworkKit {
        if sharedNetworkKit == nil
        {
            sharedNetworkKit = NetworkKit()
        }
        return sharedNetworkKit!
    }
    
    override init()
    {
        super.init()
        
        monitor.pathUpdateHandler = { path in
            self.status = path.status
        }
        
        monitor.start(queue: DispatchQueue.global())
    }

}
