//
//  BaseService.swift
//  OrderAte
//
//  Created by Gulfam Khan on 17/02/2020.
//  Copyright © 2020 Rapidzz. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class BaseService {
    //MARK:- Shared data
    private var dataRequest:DataRequest?
    
    init() {}
    
    fileprivate var sessionManager:Session {
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = 60
        manager.session.configuration.httpMaximumConnectionsPerHost = 10
        return manager
    }
    
    func getHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [:]
        
        // Add session cookie if available
        if let cookie = UserDefaultsManager.shared.token {
            headers["Cookie"] = "ci_session=\(cookie)"
        }
        
        return headers
    }
    
    //MARK:- POST API Call
    func makePostAPICall(with completeURL:String, params:Parameters?,headers:HTTPHeaders? = nil, completion: @escaping (_ error: String, _ success: Bool, _ jsonData:JSON?, _ responseType:ServiceResponseType)->Void){
        
        print("URL: \(completeURL)")
        print("Params: \(params)")
        dataRequest = sessionManager.request(completeURL, method: .post, parameters: params!, encoding: URLEncoding.default, headers: headers)
        
        dataRequest?
            .validate(statusCode: 200...501)
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let parsedResponse = ResponseHandler.handleResponse(json)
                    
                    if parsedResponse.serviceResponseType == .Success {
                        completion(parsedResponse.message,true, parsedResponse.swiftyJsonData, parsedResponse.serviceResponseType)
                    }else if(parsedResponse.serviceResponseType == .Invalid){
                        completion(parsedResponse.message,false,nil, parsedResponse.serviceResponseType)
                    }
                    else {
                        completion(parsedResponse.message,false,nil, parsedResponse.serviceResponseType)
                    }
                    
                case .failure(let error):
                    let errorMessage:String = error.localizedDescription
                    print(errorMessage)
                    completion(PopupMessages.SomethingWentWrong, false,nil, .Failure)
                }
            })
    }
    //MARK:- POST API Call
       func makePostAPiCall(with completeURL:String, params:Parameters?,headers:HTTPHeaders? = nil, completion: @escaping (_ error: String, _ success: Bool, _ jsonData:JSON?, _ responseType:ServiceResponseType)->Void){
        print("URL: \(completeURL)")
        print("Params: \(params)")
        dataRequest = sessionManager.request(completeURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
           
           dataRequest?
               .validate(statusCode: 200...500)
               .responseJSON(completionHandler: { response in
                   switch response.result {
                   case .success(let value):
                       let json = JSON(value)
                       let parsedResponse = ResponseHandler.handleResponse(json)
                       
                       if parsedResponse.serviceResponseType == .Success {
                           completion(parsedResponse.message,true, parsedResponse.swiftyJsonData, parsedResponse.serviceResponseType)
                       }else {
                           completion(parsedResponse.message,false,nil, parsedResponse.serviceResponseType)
                       }
                       
                   case .failure(let error):
                       let errorMessage:String = error.localizedDescription
                       print(errorMessage)
                       completion(PopupMessages.SomethingWentWrong, false,nil, .Failure)
                   }
               })
       }
    func makePostAPICallImage(with completeURL:String, params:Parameters?,headers:HTTPHeaders? = nil, completion: @escaping (_ error: String, _ success: Bool, _ jsonData:Data? , _ responseType : Int?)->Void){
           
           print("URL: \(completeURL)")
           print("Params: \(params)")
           dataRequest = sessionManager.request(completeURL, method: .post, parameters: params!, encoding: URLEncoding.default, headers: headers)
           
           dataRequest?
               .validate(statusCode: 200...500)
               .responseJSON(completionHandler: { response in
                if(response.response?.statusCode == 200){
                    completion("success",true, response.data, response.response?.statusCode)
                }
                else{
                    completion("failure",false, response.data, response.response?.statusCode)
                }
               // let response = response.response?.statusCode
//                   switch response.result {
//                   case .success(let value):
//                       let json = JSON(value)
//                       let parsedResponse = ResponseHandler.handleResponse(json)
//
//                       if parsedResponse.serviceResponseType == .Success {
//                           completion(parsedResponse.message,true, value, parsedResponse.serviceResponseType)
//                       }else {
//                           completion(parsedResponse.message,false,nil, parsedResponse.serviceResponseType)
//                       }
//
//                   case .failure(let error):
//                       let errorMessage:String = error.localizedDescription
//                       print(errorMessage)
//                       completion(PopupMessages.SomethingWentWrong, false,nil, .Failure)
//                   }
               })
       }
    
    //MARK:- Get API Call
    func makeGetAPICall(with completeURL:String, params:Parameters?,headers:HTTPHeaders? = nil,completion: @escaping (_ error: String, _ success: Bool, _ resultList:JSON?, _ responseType:ServiceResponseType)->Void){
        
        dataRequest = sessionManager.request(completeURL, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers)
        dataRequest?
            .validate(statusCode: 200...500)
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let parsedResponse = ResponseHandler.handleResponse(json)
                    
                    if parsedResponse.serviceResponseType == .Success {
                        completion(parsedResponse.message,true, parsedResponse.swiftyJsonData, parsedResponse.serviceResponseType)
                    }else {
                        completion(parsedResponse.message,false,nil,parsedResponse.serviceResponseType)
                    }
                    
                case .failure(let error):
                    let errorMessage:String = error.localizedDescription
                    print(errorMessage)
                    completion(PopupMessages.SomethingWentWrong, false, nil, .Failure)
                }
            })
        
    }
    
    //MARK:- Multipart Post API Call
    func makePostAPICallWithMultipart(with completeURL:String, dict:[String:Data]?, params:[String:String]?, isImageData:Bool, headers: HTTPHeaders? = nil, completion: @escaping (_ error: String, _ success: Bool, _ jsonData:JSON?)->Void) {
        print("\n==================== API REQUEST (MULTIPART) ====================")
        print("URL: \(completeURL)")
        print("Params: \(params ?? [:])")
        let requestHeaders = headers ?? self.getHeaders()
        print("Headers: \(requestHeaders)")
        // Debug: Dump all cookies for the domain
        if let url = URL(string: completeURL),
           let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            print("Cookies for \(url.host ?? "?"):")
            cookies.forEach { print("  \($0.name)=\($0.value)") }
        } else {
            print("No cookies found for URL: \(completeURL)")
        }

        sessionManager.upload(multipartFormData: { multipartFormData in


            for (key, value) in params ?? [:] {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
            let fileName = isImageData ? "image.jpg" : "video.mov"
            let mimeType = isImageData ? "image/jpg" : "video/mov"

            // import image to request
            for (key, value) in dict ?? [:] {
                multipartFormData.append(value, withName: key,fileName: fileName, mimeType: mimeType)
            }

        }, to: completeURL, headers: requestHeaders)
            .responseData { (response) in
                let statusCode = response.response?.statusCode ?? -1
                print("\n-------------------- API RESPONSE (MULTIPART) --------------------")
                print("URL: \(completeURL)")
                print("Status: \(statusCode)")
                if let headers = response.response?.allHeaderFields {
                    print("Response Headers: \(headers)")

                    // Extract and persist ci_session cookie when present so subsequent
                    // requests automatically include it via `getHeaders()`.
                    if let headerDict = headers as? [String: Any],
                       let cookies = headerDict["Set-Cookie"] as? String {
                        let parts = cookies.components(separatedBy: ";")
                        for part in parts {
                            let trimmed = part.trimmingCharacters(in: .whitespaces)
                            if trimmed.hasPrefix("ci_session=") {
                                let value = trimmed.replacingOccurrences(of: "ci_session=", with: "")
                                UserDefaultsManager.shared.token = value
                                break
                            }
                        }
                    }
                }
                print("Raw Response: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "Unable to decode response")")
                print("==================================================================")
                
                let json = JSON(response.data ?? Data())
                let success = statusCode == 200
                
                if success {
                    completion("", true, json)
                } else {
                    let message = json["message"].stringValue.isEmpty ? "Something went wrong" : json["message"].stringValue
                    completion(message, false, json)
                }
        }
    }
    
    //MARK:- Enhanced Multipart Post API Call with proper file handling
    func makePostAPICallWithMultipartWithFiles(with completeURL:String, params:[String:String]?, imageData: Data?, videoData: Data?, headers: HTTPHeaders? = nil, completion: @escaping (_ error: String, _ success: Bool, _ jsonData:JSON?)->Void) {
        print("\n==================== API REQUEST (MULTIPART) ====================")
        print("URL: \(completeURL)")
        print("Params: \(params ?? [:])")
        let requestHeaders = headers ?? self.getHeaders()
        print("Headers: \(requestHeaders)")
        // Debug: Dump all cookies for the domain
        if let url = URL(string: completeURL),
           let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            print("Cookies for \(url.host ?? "?"):")
            cookies.forEach { print("  \($0.name)=\($0.value)") }
        } else {
            print("No cookies found for URL: \(completeURL)")
        }

        sessionManager.upload(multipartFormData: { multipartFormData in
            // Add form parameters
            for (key, value) in params ?? [:] {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
            // Add image file if present
            if let imageData = imageData {
                multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            }
            
            // Add video file if present
            if let videoData = videoData {
                multipartFormData.append(videoData, withName: "video", fileName: "video.mp4", mimeType: "video/mp4")
            }

        }, to: completeURL, headers: requestHeaders)
            .responseData { (response) in
                let statusCode = response.response?.statusCode ?? -1
                print("\n-------------------- API RESPONSE (MULTIPART) --------------------")
                print("URL: \(completeURL)")
                print("Status: \(statusCode)")
                if let headers = response.response?.allHeaderFields {
                    print("Response Headers: \(headers)")

                    // Extract and persist ci_session cookie when present so subsequent
                    // requests automatically include it via `getHeaders()`.
                    if let headerDict = headers as? [String: Any],
                       let cookies = headerDict["Set-Cookie"] as? String {
                        let parts = cookies.components(separatedBy: ";")
                        for part in parts {
                            let trimmed = part.trimmingCharacters(in: .whitespaces)
                            if trimmed.hasPrefix("ci_session=") {
                                let value = trimmed.replacingOccurrences(of: "ci_session=", with: "")
                                UserDefaultsManager.shared.token = value
                                break
                            }
                        }
                    }
                }
                print("Raw Response: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "Unable to decode response")")
                print("==================================================================")
                
                let json = JSON(response.data ?? Data())
                let success = statusCode == 200
                
                if success {
                    completion("", true, json)
                } else {
                    let message = json["message"].stringValue.isEmpty ? "Something went wrong" : json["message"].stringValue
                    completion(message, false, json)
                }
        }
    }
    
}
