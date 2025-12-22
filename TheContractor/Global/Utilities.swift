import Foundation
import UIKit
private var maxLengths = [UITextField: Int]()

class Utilities {
    
   static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

 static func readJson(fileName:String) -> Any {
        do {
            if let file = Bundle.main.url(forResource: fileName, withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                   
                    print(object)
                    return object
                } else if let object = json as? [Any] {
                   print(object)
                    return object
                } else {
                    print("JSON is invalid")
                    return ""
                }
            } else {
                print("no file")
                return ""
            }
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
    static func unArchiveObject(key: String) -> AnyObject? {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as AnyObject
    }

   static func txtfeildSpacing(textfield:UITextField){
        textfield.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
    }
    static func txtfieldPlaceholderWhite(textfield:UITextField){
        textfield .setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")
    }

    static func isValidEmail(_ testStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
  
    static   func textAttachmentWithImage(flag:intmax_t,title: NSString,image: NSString,fontName:UIFont) -> NSMutableAttributedString {
        
        let textAttachment = NSTextAttachment()
        
        
        textAttachment.image = UIImage(named: image as String)
        
        let mid = fontName.descender + fontName.capHeight
        
        if (flag == 0)
        {
            textAttachment.bounds = CGRect(x: 0, y: fontName.descender - textAttachment.image!.size.height / 2 + mid + 2, width: textAttachment.image!.size.width, height: textAttachment.image!.size.height).integral
        }
        else
        {
            textAttachment.bounds = CGRect(x: 0, y: fontName.descender - textAttachment.image!.size.height / 2 + mid + 2 , width: textAttachment.image!.size.width, height: textAttachment.image!.size.height).integral
        }
        
        let attachmentString = NSAttributedString(attachment: textAttachment)
        let newString = NSMutableAttributedString()
        let myString = NSMutableAttributedString(string:title as String)
        
        if (flag == 2)
        {
            newString.append(myString)
            newString.append(attachmentString)
            
        }
        else
        {
            newString.append(attachmentString)
            newString.append(myString)
        }
        
        return newString
    }
    static func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        
        label.text = text
        label.sizeToFit()
        return label.frame.height
        
    }
    
    static func getFormattedDateString(dateStr : String) -> String{
        if(dateStr.trimmingCharacters(in: .whitespaces).isEmpty){
            return ""
        }
        var date = Date()
        let formate = DateFormatter()
        formate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        date = formate.date(from: dateStr)!
        formate.dateFormat = "dd MMM yyyy hh:mm a"
        let dateString = formate.string(from: date)
        return dateString
    }
    
    static func getUTCDateFromTimeSpanString(dateStr : String) -> Date{
        var date = Date()
        let formate = DateFormatter()
        formate.locale = Locale(identifier: "en_US_POSIX")
        formate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formate.timeZone = TimeZone(identifier: "UTC")
        
        date = formate.date(from: dateStr)!
        
        return date
    }
    
    static func isDateGreater(serverDate: Date, appDate: Date)-> Bool {
        
        let compare = appDate.compare(serverDate)
        
        if compare == .orderedAscending {
            return true
        }else{
            return false
        }
    }
    static func getYearList() -> [String] {
        var yearList = [String]()
        let date = Date()
        let formatter  = DateFormatter()
        formatter.dateFormat = "YYYY"
        let year = formatter.string(from: date)
        for i in 0..<200{
            let currentYear = Int(year) ?? 2018
            yearList.append("\(currentYear - i)")
        }
        return yearList
    }
    static func getDayOfWeek(_ today:String) -> String {
        let formatter  = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        formatter.timeZone = TimeZone.current
        let todayDate = formatter.date(from: today) ?? Date()
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        switch weekDay {
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THU"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return ""
        }
    }
    static func getStringFromDate(date:Date) -> String{
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd MMM YYYY"
        let dateString = formatter.string(from: date)
        
        return dateString
    }
    static func getStringWithFormateFromDate(date:Date) -> String{
        let formatter = DateFormatter()
        
        formatter.dateFormat = "YYYY-MM-dd"
        let dateString = formatter.string(from: date)
        
        return dateString
    }
    static func  getDateFromString(string:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
      //  dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: string) ?? Date()
       // dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let finalDate = dateFormatter.date(from: dateString) ?? Date()
        return finalDate
    }
    
    static func getTimeStringFromDate(date:Date) -> String{
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "h:mm a"
        let timeStemp = formatter.string(from: date)
        
        return timeStemp
        
    }
    
    static func getCurrentDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let timeStemp = formatter.string(from: date)
        
        return timeStemp
        
    }
    
    static func getCurrentDate() -> Date{
        return Date()
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MM-yyyy HH:mm a"
//        formatter.timeZone = TimeZone(abbreviation: "UTC")
//        let temp = formatter.string(from: date)
//        return formatter.date(from: temp) ?? Date()
        
//        return timeStemp
        
    }
    static func getCurrentDateString() -> String{
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"//"dd MMM YYYY"
        let timeStemp = formatter.string(from: date)
        
        return timeStemp
        
    }
    static func getChatCurrentDateString() -> String{
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd MMM yyyy hh:mm a"
        let timeStemp = formatter.string(from: date)
        
        return timeStemp
        
    }
    static func getNextDateString(date:Date,value:Int? = 1) -> String{
        let today = date
        let tomorrow = Calendar.current.date(byAdding: .day, value: value!, to: today)
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd MMM YYYY"
        let timeStemp = formatter.string(from: tomorrow!)
        
        return timeStemp
    }
    static func getNextDateStringForDay(date:Date,value:Int? = 1) -> String{
        let today = date
        let tomorrow = Calendar.current.date(byAdding: .day, value: value!, to: today)
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dddd"
        let timeStemp = formatter.string(from: tomorrow!)
        
        return timeStemp
    }
    
    static func getFlipTransition() -> CATransition{
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "flip")
        transition.subtype = CATransitionSubtype.fromLeft
        return transition
    }
    static func isCurrentDate(strDate:String) -> Bool{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let temp = formatter.date(from: strDate)
        let currentString = formatter.string(from: Date())
        let currentDate = formatter.date(from: currentString)
        if(currentDate == temp){
            return true
        }
        return false
    }
    static func getDateTimeFormatteForChat(strDate:String) -> String{
        
        if(strDate.trimmingCharacters(in: .whitespaces).isEmpty){
            return ""
        }
        if(self.isCurrentDate(strDate: strDate)){
            return "Today"
        }
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MM-yyyy HH:mm a"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let temp = formatter.date(from: strDate)
        
        formatter.dateFormat = "dd MMM yyyy"
        formatter.timeZone = TimeZone.current
        let timeStemp = formatter.string(from: temp!)
       // let newDate = formatter.date(from: timeStemp)
        print(timeStemp)
        
        return timeStemp
    }
    static func getDayFromDateString(strDate:String) -> String{
        
        if(strDate.trimmingCharacters(in: .whitespaces).isEmpty){
            return ""
        }
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let temp = formatter.date(from: strDate)
        
        formatter.dateFormat = "dd"
        formatter.timeZone = TimeZone.current
        let timeStemp = formatter.string(from: temp!)
        // let newDate = formatter.date(from: timeStemp)
        print(timeStemp)
        
        return timeStemp
    }
    static func getMonthFromDateString(strDate:String) -> String{
        
        if(strDate.trimmingCharacters(in: .whitespaces).isEmpty){
            return ""
        }
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let temp = formatter.date(from: strDate)
        
        formatter.dateFormat = "MMM"
        formatter.timeZone = TimeZone.current
        let timeStemp = formatter.string(from: temp!)
        // let newDate = formatter.date(from: timeStemp)
        print(timeStemp)
        
        return timeStemp
    }
    static func getDatefromDateString(strDate:String) -> String{
        
        if(strDate.trimmingCharacters(in: .whitespaces).isEmpty){
            return ""
        }
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: strDate) ?? Date()
        
        formatter.dateFormat = "dd/MM/yy"
        let strdate = formatter.string(from: date)
        // let newDate = formatter.date(from: timeStemp)
        print(strdate)
        
        return strdate
    }
    static func getTimeFromDateString(strDate:String) -> String{
        
        if(strDate.trimmingCharacters(in: .whitespaces).isEmpty){
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: strDate) ?? Date()
        
        formatter.dateFormat = "HH:mm"
        let timeStemp = formatter.string(from: date)
        print(timeStemp)
        
        return timeStemp
    }
   
    static func getTimeFromDate(date:Date) -> String{
        
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "hh:mm a"
        formatter.timeZone = TimeZone.current
        let timeStemp = formatter.string(from: date)
        print("Local \(timeStemp)")
        return timeStemp
    }
    static func getDateStringFromDate(date:Date) -> String{
        
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "dd MMM YYYY hh:mm a"
        formatter.timeZone = TimeZone.current
        
        let dateString = formatter.string(from: date)
        print("Local \(dateString)")
        return dateString
    }
    static func getPatientId() -> String{
        
        
         let date = Date()
        let components = date.get(.day, .hour, .minute, .second)
        let number = Int.random(in: 0..<1000)
       return "\(components.day ?? 0)\(components.hour ?? 0)\(components.minute ?? 0)\(components.second ?? 0)\(number)"
    }
}


extension UserDefaults {
    
    func set<T: Encodable>(codable: T, forKey key: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(codable)
            let jsonString = String(data: data, encoding: .utf8)!
            print("Saving \"\(key)\": \(jsonString)")
            self.set(jsonString, forKey: key)
        } catch {
            print("Saving \"\(key)\" failed: \(error)")
        }
    }
    
    func codable<T: Decodable>(_ codable: T.Type, forKey key: String) -> T? {
        guard let jsonString = self.string(forKey: key) else { return nil }
        guard let data = jsonString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        print("Loading \"\(key)\": \(jsonString)")
        return try? decoder.decode(codable, from: data)
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
