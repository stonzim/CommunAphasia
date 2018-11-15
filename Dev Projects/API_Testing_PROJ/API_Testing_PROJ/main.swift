//
//  main.swift
//  API_Testing_PROJ
//
//  Created by Max Huang on 11/08/18.
//  Copyright © 2018 Max Huang. All rights reserved.
//

import Foundation

import SystemConfiguration

private class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}

private class MyDelegate: NSObject, URLSessionDataDelegate {
    fileprivate var synonyms: [String] = []
    fileprivate func urlSession(_ session: URLSession,
                                dataTask: URLSessionDataTask,
                                didReceive data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = json as? [String: Any],
            let syn = dictionary["synonyms"] {
            self.synonyms = ((syn as! NSArray).componentsJoined(by: ",")).components(separatedBy: ",")
        }
    }
}

func getSynonym(_ word: String) -> [String]? {
    let baseUrl = "https://wordsapiv1.p.mashape.com/words/"
    let type = "synonyms"
    let url = NSURL(string: baseUrl + word + "/" + type)
    let request = NSMutableURLRequest(url: url! as URL)
    request.setValue("yTv8TIqHmimshZvfKLil4h6A2zT2p11GQe5jsnr4XhZtyt69bm", forHTTPHeaderField: "X-Mashape-Key")
    request.setValue("wordsapiv1.p.mashape.com", forHTTPHeaderField: "X-Mashape-Host")
    request.httpMethod = "GET"
    
    let delegateObj = MyDelegate()
    let session = URLSession(configuration: URLSessionConfiguration.default,
                             delegate: delegateObj,
                             delegateQueue: nil)
    let task = session.dataTask(with: request as URLRequest)
    task.resume()
    var timeOut = 0
    while (delegateObj.synonyms.isEmpty) {
        if timeOut >= 3000 {
            print("TIMEOUT")
            return nil
        }
        usleep(20 * 1000)  // sleep for 20 milliseconds
        timeOut += 20
    }
    return delegateObj.synonyms
}

print("> start\n")
if Reachability.isConnectedToNetwork(){
    print("Internet Connection Available!")
    if let s = getSynonym("woman") {
        print(s)
    } else {
        print("ELSE")
    }
}else{
    print("Internet Connection not Available!")
}

print("\n> end")
