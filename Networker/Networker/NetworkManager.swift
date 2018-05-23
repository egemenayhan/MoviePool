//
//  NetworkManager.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 22.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Alamofire

public enum NetworkError: Error {
    case connectionError(Error)
    case corruptedData
}

public class NetworkManager: NSObject {

    public static let shared = NetworkManager()
    private let manager: SessionManager
    
    override init() {
        manager = SessionManager()
    }
    
    @discardableResult public func execute<T: Codable>(_ request: Request,
                                                       handler: @escaping (_ response: Response<T>) -> Void) -> URLSessionTask? {
        let dataRequest = manager.request(request)
        dataRequest.responseData { (dataResponse: DataResponse<Data>) in
            let result: Result<T>
            switch dataResponse.result {
            case .success(let value):
                if let object = T(jsonData: value) {
                    result = .success(object)
                } else {
                    result = .failure(NetworkError.corruptedData)
                }
            case .failure(let error):
                result = .failure(NetworkError.connectionError(error))
            }
            
            handler(Response<T>(request: dataResponse.request,
                                response: dataResponse.response,
                                data: dataResponse.data,
                                result: result))
        }
        
        return dataRequest.task
    }
    
}
