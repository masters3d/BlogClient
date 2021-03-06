//
//  NetworkController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/26/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import Swift

class NetworkOperation: Operation, URLSessionDataDelegate {
    //Error Reporting
    var delegate: ErrorReporting?

    // custom fields
    fileprivate var url: URL?
    fileprivate var keyString: String?
    var request: URLRequest?

    // default
    fileprivate var data = NSMutableData()
    fileprivate var startTime: TimeInterval? = nil
    fileprivate var totalTime: TimeInterval? = nil
    

    // Still need this workaround to overide getter only isFinish
    fileprivate var tempFinished: Bool = false
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            tempFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
        get {
            return tempFinished
        }
    }
    
    //call back function that has data
    private var finishedData: Data?
    private var finishedResponse:HTTPURLResponse?
    fileprivate func getWhenFinished() -> (data:Data?, reponse:HTTPURLResponse?) {
        return (finishedData,finishedResponse)
    }
    
    // Inserts a block to start function
    fileprivate var startingBlock:()->Void = {}

    override func start() {

        startingBlock()

        // clears up any errors in the delegate
        DispatchQueue.main.async(execute: {
            self.delegate?.reportErrorFromOperation(.none)
        })

        if isCancelled {
            isFinished = true
            return
        }

        let config = URLSessionConfiguration.default
        let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: nil)

        // session name for debugging
        session.sessionDescription = keyString

        if let request = request {
            let task = session.dataTask(with: request)
            startTime = Date.timeIntervalSinceReferenceDate
            task.resume()
        }
    }
    
    init(urlRequest:URLRequest, keyForData: String) {
        super.init()
        self.url = urlRequest.url!
        self.keyString = keyForData
        self.request = urlRequest
    
    }

    init(url: URL, keyForData: String) {
        super.init()
        self.url = url
        self.keyString = keyForData
        self.request = URLRequest(url: url)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Unexpected response type")
        }

        finishedResponse = httpResponse

        switch httpResponse.statusCode {
        case 200:
            completionHandler(.allow)
        case 201:
            completionHandler(.allow)
        default:
            let connectionError = NSError(domain: "Check your login information.", code: httpResponse.statusCode, userInfo: nil)
            print(connectionError.localizedDescription)
            DispatchQueue.main.async(execute: {
                self.delegate?.reportErrorFromOperation(connectionError)
            })
            completionHandler(.cancel)
            isFinished = true
        }
        print("return code for server: \(httpResponse.statusCode) for session: \(session.sessionDescription  ?? "no description" )")
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive incomingData: Data) {
        data.append(incomingData)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Failed! \(error)")
            // sending error to delagate UI on the main queue
            DispatchQueue.main.async(execute: {
                self.delegate?.reportErrorFromOperation(error)
            })

            isFinished = true
            return
        }

        //MARk:-ProcessData() and save or use coredata
        //UserDefaults.standard.set(data, forKey: keyString ?? "")
        if data.length > 0 {
            self.finishedData =  data as Data
        }

        totalTime = Date.timeIntervalSinceReferenceDate - startTime! // this should always have a value
        isFinished = true
    }
}

extension NetworkOperation {
    
    internal convenience init(urlRequest:URLRequest ,sessionName:String , errorDelegate: ErrorReporting?,
                              successBlock:@escaping (_ data: Data?, _ reponse: HTTPURLResponse?) -> Void = { _,_  in }
        ) {
        self.init(urlRequest: urlRequest, keyForData: sessionName)
        self.delegate = errorDelegate
        
        self.startingBlock = {
            DispatchQueue.main.async(execute: {
                errorDelegate?.activityIndicatorStart()
            } ) }
        
        self.completionBlock = {
            DispatchQueue.main.async(execute: {
                errorDelegate?.activityIndicatorStop()
            } )
            let (data, response) = self.getWhenFinished()
            successBlock(data, response)
        }
    }
    // make this internal to use this behavior
    fileprivate convenience init(typeOfConnection: ConnectionType, errorDelegate: ErrorReporting?,
                                 successBlock:@escaping (Data?)->Void = { _ in },
                                 showActivityOnUI:Bool = true
        ) {
        self.init(typeOfConnection:typeOfConnection)
        self.delegate = errorDelegate
        
        if showActivityOnUI {
            self.startingBlock = {
                DispatchQueue.main.async(execute: {
                    errorDelegate?.activityIndicatorStart()
                } ) }
            
            self.completionBlock = {
                DispatchQueue.main.async(execute: {
                    errorDelegate?.activityIndicatorStop()
                } )
                successBlock(self.getWhenFinished().data)
            }
        } else {
            self.completionBlock = { successBlock(self.getWhenFinished().data) }
        }
    } // convenience
}

extension NetworkOperation {

    static func escapeForURL(_ input: String) -> String? {
        return input.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
    
   private static func parameterFromDict(_ dict:[String : Any]) -> [URLQueryItem] {
        var result = [URLQueryItem]()
        for each in dict {
            let item = URLQueryItem(name: each.key, value: String(describing: each.value))
            result.append(item)
        }
        return result
    }
    
    static func componentsMaker(baseUrl:String, querryKeyValue:[String : Any] )-> URLComponents? {
        var components = URLComponents.init(string: baseUrl)!
        components.queryItems = parameterFromDict(querryKeyValue)
        return components
    }
}

//MARK: -  CONFIGURATION SAMPLE Make this internal to use

fileprivate enum ConnectionType {
    case sample
    
    var stringValue:String {
        switch self {
        case .sample:
            return "sample"
        }
    }
}

fileprivate extension NetworkOperation {
    convenience init(typeOfConnection: ConnectionType) {
        switch typeOfConnection {
            case .sample:
                let querryDict:[String:Any] = ["extras": "url_s", "safe_search": 1]
                let urlComponents = NetworkOperation.componentsMaker(baseUrl: "https://google.com", querryKeyValue: querryDict)
                let url = urlComponents!.url!
                let urlRequest = URLRequest(url: url)
                self.init(urlRequest: urlRequest, keyForData: typeOfConnection.stringValue)
//            default: fatalError()
        }
    }
}



