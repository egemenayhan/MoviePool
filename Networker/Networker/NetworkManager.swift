//
//  NetworkManager.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 22.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Alamofire
#if DEBUG
import Reqres
#endif

public enum NetworkManagerError: Error {
    case connectionError(Error)
    case corruptedData
    case mappingFailed
}

public class NetworkManager: NSObject {

    public static let shared = NetworkManager()
    private let manager: SessionManager
    
    override init() {
        #if DEBUG
            let configuration = Reqres.defaultSessionConfiguration()
            manager = SessionManager(configuration: configuration)
        #else
            manager = SessionManager()
        #endif
    }
    
    @discardableResult public func execute<T>(_ request: Request,
                                              completion: @escaping (_ response: Result<T>) -> Void) -> URLSessionTask? where T: RawDataMappable {
        let dataRequest = manager.request(request)
        dataRequest.responseJSON { (dataResponse: DataResponse<Any>) in
            let result: Result<T>
            
            // Constructing result
            switch dataResponse.result {
            case .success(let value):
                if let JSON = value as? [String: Any] {
                    do {
                        let object = try T(jsonDict: JSON)
                        result = .success(object)
                    } catch {
                        result = .failure(NetworkManagerError.mappingFailed)
                    }
                } else {
                    result = .failure(NetworkManagerError.corruptedData)
                }
            case .failure(let error):
                result = .failure(NetworkManagerError.connectionError(error))
            }
            
            completion(result)
        }
        
        return dataRequest.task
    }
    
}
