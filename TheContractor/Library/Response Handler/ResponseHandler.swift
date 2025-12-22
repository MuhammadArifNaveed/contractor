//
//  ResponseHandler.swift
//  OrderAteDelivery
//
//  Created by Gulfam Khan on 12/09/2019.
//  Copyright © 2019 Rapidzz. All rights reserved.
//

import Foundation
import SwiftyJSON

let KEY_RESULT_CODE = "error"
let KEY_RESPONSE_MESSAGE = "message"
let KEY_RESPONSE_DATA = "result"


class ResponseHandler {
    
    class func handleResponse(_ response:JSON) -> ParsedResponseMessage {
        let parsedResponseMessage = ParsedResponseMessage()
        let resultCode = response[KEY_RESULT_CODE].stringValue
        let resultMessage = response[KEY_RESPONSE_MESSAGE].stringValue
        let swift = ServiceResponseType(rawValue: resultCode)
        var switchValue : ServiceResponseType = .Failure
        if(response["error"].boolValue == true){
            switchValue = .Failure //ServiceResponseType(rawValue: resultCode) ?? .Success
        }
        else{
            switchValue = .Success
        }
       
        print("Response: \(response)")
        parsedResponseMessage.message = resultMessage
        
        switch switchValue {
        case .Success:
            parsedResponseMessage.serviceResponseType = .Success
            parsedResponseMessage.swiftyJsonData = response
        default:
            parsedResponseMessage.data = nil
            parsedResponseMessage.swiftyJsonData = nil
            parsedResponseMessage.serviceResponseType = switchValue
        }
        
        return parsedResponseMessage
    }
    class func handleBookingResponse(_ response:JSON) -> ParsedResponseMessage {
           let parsedResponseMessage = ParsedResponseMessage()
           let resultCode = response[KEY_RESULT_CODE].stringValue
           let resultMessage = response[KEY_RESPONSE_MESSAGE].stringValue
           let switchValue = ServiceResponseType(rawValue: resultCode)!
           print("Response: \(response)")
           parsedResponseMessage.message = resultMessage
           
           switch switchValue {
           case .Success:
               parsedResponseMessage.serviceResponseType = .Success
               parsedResponseMessage.swiftyJsonData = response
           default:
               parsedResponseMessage.data = nil
               parsedResponseMessage.swiftyJsonData = nil
               parsedResponseMessage.serviceResponseType = switchValue
           }
           
           return parsedResponseMessage
       }
}
