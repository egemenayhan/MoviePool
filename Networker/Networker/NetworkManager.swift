//
//  NetworkManager.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 22.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import UIKit
import Alamofire

public class NetworkManager: NSObject {

    public static let shared = NetworkManager()
    
    public func run() {
        print("Networking test run")
        
        Alamofire.request("https://httpbin.org/get").responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
    }
    
}
