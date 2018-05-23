//
//  Response.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 23.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Alamofire

struct Response<Value: Codable>{
    
    var request: URLRequest?
    var response: HTTPURLResponse?
    var data: Data?
    var result: Result<Value>
    
}
