import Foundation
import UIKit
struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}
struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    
    static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X_All = (UIDevice.current.userInterfaceIdiom == .phone && (ScreenSize.SCREEN_MAX_LENGTH == 812 || ScreenSize.SCREEN_MAX_LENGTH == 896))
    static let IS_IPHONE_X = (UIDevice.current.userInterfaceIdiom == .phone && (ScreenSize.SCREEN_MAX_LENGTH == 812))
    static let IS_IPHONE_X_MAX = (UIDevice.current.userInterfaceIdiom == .phone && (ScreenSize.SCREEN_MAX_LENGTH == 896))
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
}

struct AppColors {
    static let yellow           = UIColor(rgbValues: 249, green: 177, blue: 31, alpha: 1)
    static let LightGray        = UIColor.init(hexFromString: "0x969696", alpha: 0.61)
    static let LightBlue        = UIColor.init(hexFromString: "0x093485", alpha: 0.61)
    static let Gray             = UIColor.init(hexFromString: "0x969696")
    static let DarkBlue         = UIColor.init(hexFromString: "0x093485")
}

struct DictKeys {

    
}

struct EndPoints {
   
    static let BASE_URL = "https://contractor.bidcont.com/rest/"
    static let app = "app"
    static let verifyPurchase = "verify-purchase"
    static let login = "Account/user_login"
    static let home = "Home/categories"
    static let homeEsstimation = "Home/get_estimation_categories"
    static let getSearch = "Home/get_search"
    static let searchedData = "Home/find_companies"
   
}

//Default values for data types
let kBlankString = ""
let Plateform = "IOS"
let DeviceToken = "21321312"

let kInt0 = 0
let kIntDefault = -1

let kDouble0 = 0.0
let kDoubleDefault = -1.0

let kFileTypePDF = "pdf"
let kFileTypeJpeg = "jpeg"

let kMimeTypeImage = "image/png"
let kImageFileName = "file.png"

let kMimeTypePDF = "application/pdf"
let kPDFFileName = "document.pdf"



