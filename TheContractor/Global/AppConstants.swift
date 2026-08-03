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
    /// Login for companies (vendor portal)
    static let loginCompany = "vendor/login_company"
    static let home = "Home/categories"
    static let getSearch = "Home/get_search"
    static let searchedData = "Home/find_companies"
   
}

struct ImageURLs {
    
    /// Base URL for the application (without /rest/)
    static let BASE_URL = "https://contractor.bidcont.com/"
    
    /// Profile images for users
    static let PROFILE_IMAGE_URL = BASE_URL + "uploads/users/"
    
    /// Profile videos for applicants
    static let PROFILE_VIDEO_URL = BASE_URL + "uploads/applicant_videos/"
    
    /// Category icons
    static let CATEGORIES_IMAGE_URL = BASE_URL + "uploads/icons/"
    
    /// Company logos and images
    static let COMPANIES_IMAGE_URL = BASE_URL + "uploads/companies/"
    
    /// Quotation images
    static let QUOTATION_IMAGE_URL = BASE_URL + "uploads/quotations/"
    
    /// Workshop images
    static let WORKSHOP_IMAGE_URL = BASE_URL + "uploads/workshop/"
    
    /// Downloadable quotation documents
    static let DOWNLOAD_QUOTATIONS_IMAGE_URL = BASE_URL + "uploads/documents/"
    
    /// Helper method to construct full image URL
    /// - Parameters:
    ///   - baseURL: The base URL for the image type
    ///   - imageName: The image file name
    /// - Returns: Complete image URL string, or nil if imageName is empty
    static func imageURL(baseURL: String, imageName: String?) -> String? {
        guard let name = imageName, !name.isEmpty else { return nil }
        return baseURL + name
    }
    
    /// Constructs profile image URL
    static func profileImageURL(_ imageName: String?) -> String? {
        return imageURL(baseURL: PROFILE_IMAGE_URL, imageName: imageName)
    }
    
    /// Constructs company image URL
    static func companyImageURL(_ imageName: String?) -> String? {
        return imageURL(baseURL: COMPANIES_IMAGE_URL, imageName: imageName)
    }
    
    /// Constructs category icon URL
    static func categoryIconURL(_ imageName: String?) -> String? {
        return imageURL(baseURL: CATEGORIES_IMAGE_URL, imageName: imageName)
    }
    
    /// Constructs workshop image URL
    static func workshopImageURL(_ imageName: String?) -> String? {
        return imageURL(baseURL: WORKSHOP_IMAGE_URL, imageName: imageName)
    }
    
    /// Constructs quotation image URL
    static func quotationImageURL(_ imageName: String?) -> String? {
        return imageURL(baseURL: QUOTATION_IMAGE_URL, imageName: imageName)
    }
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



