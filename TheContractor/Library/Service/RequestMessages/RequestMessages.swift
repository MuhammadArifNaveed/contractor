import Foundation
import UIKit

class RequestMessage: ServiceRequestMessage{

    var queryItems = [URLQueryItem]()
    var deviceId:String = ""
    var userId:String = ""
    var fcmToken:String = ""
    var type:String = ""
    var email:String = ""
}

