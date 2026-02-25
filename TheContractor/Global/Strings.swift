
import Foundation
import UIKit


typealias ParamsAny             = [String:Any]
typealias ParamsString          = [String:String]

let ALERT_TITLE_APP_NAME        = "The Contractor"
let EMAIL_REGULAR_EXPRESSION    = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"


struct StoryboardNames {
    static let Main = "Main"
}

struct NavigationTitles {
    static let Home                 = "Home"
 
}

struct NotificationName {
    static let UnAuthorizedAccess    = Notification.Name(rawValue: "UnAuthorizedAccess")
}

struct AssetNames {
    static let backArrow            = "Back-arrow"

  
}

struct SideMenu {
    static let MENULIST = [["title":"Home","image":"home"],["title":"Company Finder","image":"company-finder"],["title":"Submit Enquiry","image":"submit-quotation"],["title":"Enquiries","image":"enquiries"],["title":"Submit Quotations","image":"submit-quotation"],["title":"Quotations","image":"quotation"],["title":"Complaints","image":"compaints"],["title":"Estimations","image":"quotation"],["title":"24/7 Companies","image":"24-7"],["title":"Freelancers","image":"become-a-vendor"],["title":"Workshop","image":"become-a-vendor"],["title":"About Us","image":"guide"],["title":"Advertisement","image":"advertisement"],["title":"Become a Vendor","image":"become-a-vendor"],["title":"Documentations","image":"document"],["title":"Privacy Polices","image":"privacy-policy"],["title":"Terms & Conditions","image":"terms-and-conditions"],["title":"Guide","image":"guide"],["title":"Contact Us","image":"contact"],["title":"Rate Us","image":"rate"],["title":"Share","image":"share"]]
}

struct VendorMenu {
    static let MENULIST = [["title":"Home","image":"home"],["title":"Inbox","image":"inbox"],["title":"Vendor Rating","image":"rate"],["title":"Enquiries","image":"enquiries"],["title":"Quotations","image":"quotation"],["title":"Post Workshop","image":"become-a-vendor"],["title":"My Workshops","image":"become-a-vendor"],["title":"All Workshops","image":"become-a-vendor"],["title":"Interested Workshops","image":"become-a-vendor"],["title":"Jobs Portal","image":"become-a-vendor"],["title":"Available Applicant","image":"become-a-vendor"],["title":"Freelancers","image":"become-a-vendor"],["title":"Freelancer Dashboard","image":"become-a-vendor"],["title":"Memberships","image":"become-a-vendor"],["title":"My Membership","image":"become-a-vendor"],["title":"Vendor Logout","image":"logout"]]
}

struct ProfileMenu {
    static let MENULIST = [["title":"Select Language","image":"guide"],["title":"Profile Settings","image":"user"],["title":"Change Password","image":"password"],["title":"About Us","image":"privacy-policy"],["title":"Advertisement","image":"advertisement"],["title":"Become a Vendor","image":"become-a-vendor"],["title":"Documentation","image":"document"],["title":"Privacy Policy","image":"privacy-policy"],["title":"Terms & Conditions","image":"terms-and-conditions"],["title":"Guide","image":"guide"],["title":"Contact Us","image":"contact"],["title":"Logout","image":"logout"]]
}



struct AppLinks {
    private static let baseURL = "https://contractor.bidcont.com/"
    static let AboutUS = "\(baseURL)about-app"
    static let Terms = "\(baseURL)terms-and-conditions-app"
    static let Privacy = "\(baseURL)privacy-policy-app"
    static let Advertisment = "\(baseURL)advertisement-app"
    static let Vendor = "\(baseURL)become-a-vender-app"
    static let Guide = "\(baseURL)guide-app"
    static let Documentation = "\(baseURL)documentations-app"
    static let ContactUS = "\(baseURL)contact"
}



struct ServiceMessage {
    static let LocationTitle       = "Location Service Off"
    static let LocationMessage     = "Turn on Location in Settings > Privacy to allow myLUMS to determine your Location"
    static let Settings            = "Settings"
    static let CameraTitle         = "Permission Denied"
    static let CameraMessage       = "Turn on Camera in Settings"
}

struct ControllerIdentifier {
  
   
}

struct ValidationMessages {
     static let VerifyNumber = "Please Verify Your Number"
    static let EmptyPhonNumber = "Please enter phone number"
     static let SomeThingWrong = "SomeThingWrong"
    static let PhoneNumberVerified = "PhoneNumber Verified Successfully"
     static let WrondPinCode = "Please Enter A Valid VerificationCode"
    static let loginSuccessfully            = "You are logged in"
    static let selectProfileimage           = "Select Profile Image"
    static let emptyName                    = "Please enter your name"
    static let emptyEmail                   = "Please enter your email"
    static let enterValidEmail              = "Please enter valid email"
    static let emptyPassword                = "Password field cannot be empty"
    static let shortPassword                = "Password must be atleast 6 characters"
    static let reTypePassword               = "Please re-type password"
    static let nonMatchingPassword          = "Password is not matching"
    static let invalidPhoneNumber           = "Enter a valid phone number"
    static let configurationUrl             = "Please enter configuration url"
    static let validUrl                     = "Please enter valid url"
    static let emptyPhonNumber              = "Please enter phone number"
    static let emptyPincode                 = "Please enter pincode from email to continue"
    static let emptyCategoryName            = "Please enter category name first"
    static let emptyProductName             = "Please enter product name first"
    static let invalidProductPrice          = "Please enter a valid price for product"
    static let emptyProductInfo             = "Please describe product briefly"
    static let noImageProduct               = "Add at least one image of product"
    static let selectWeightUnit             = "Select product weight unit first"
    static let commentsMissing              = "Comment field cannot empty"
    static let noLocationAdded              = "Location info is must in order to become a supplier"
    static let fillAllFields              = "Please fill all fields"
}
struct CellIdentifier {
  
   
}

struct PopupMessages {
    static let emptySearch = "Please enter something for search"
    static let verification = "Verification Code Sent Again Successfully"
    static let LocationNotFound             = "Location Not found"
    static let cantSendMessage              = "Cant Send Message Now Please Try Agian Later"
    static let warning                      = "Warning"
    static let sureToLogout                 = "Are you sure to logout"
    static let nothingToUpdate              = "Nothing to update"
    static let orderMarkedCompleted         = "Order marked completed successfullly"
    static let unAuthorizedAccessMessage    = "Session expired, please login again"
    static let cameraPermissionNeeded       = "Camera permission needed to scan QR Code. Goto settings to enable camera permission"
    static let SomethingWentWrong           = "Something went wrong, please check your internet connection or try again later!"
}



struct LocalStrings {
    static let success              = "Success"
    static let ok                   = "OK"
    static let Yes                  = "Yes"
    static let No                   = "No"
    static let edit                 = "Edit"
    static let delete               = "Delete"
    static let Cancel               = "Cancel"
    static let Camera               = "Camera"
    static let complete             = "COMPLETE"
    static let prepare              = "PREPARE"
    static let update               = "UPDATE"
    static let NoDataFound          = "No data found"
    static let EnterUsername        = "Enter Username"
    static let EnterEmail           = "Enter Email"
    static let OldPassword          = "Old Password"
    static let EnterOldPassword     = "Enter old password"
    static let ChangePassword       = "CHANGE PASSWORD"
    static let noDescription        = "No description available"
    static let cancellationReason   = "Cancellation Reason"
    static let deleteProduct        = "Please Select Product To Delete"
    static let enableProduct        = "Please Select Product To Enable"
    static let disableProduct       = "Please Select Product To Disable"
    static let EmptySubject        = "Please Enter Subject"
    static let EmptyMessage        = "Please Enter Message"
}


struct AppFonts {
    static func CenturyGolthicBoldWith(size : CGFloat) -> UIFont {
        
        if let font = UIFont(name: "Century Gothic Bold", size: size) {
            return font
        }
        else {
            return UIFont.systemFont(ofSize: size)
        }
    }
    static func CenturyGolthicRegularWith(size : CGFloat) -> UIFont {
        
        if let font = UIFont(name: "Century Gothic Regular", size: size) {
            return font
        }
        else {
            return UIFont.systemFont(ofSize: size)
        }
    }
}
