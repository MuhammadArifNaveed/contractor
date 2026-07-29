//  VendorProfileView.swift
import SwiftUI
import Alamofire
import SwiftyJSON

struct VendorProfileView: View {
    @StateObject private var viewModel = VendorProfileViewModel()
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color(UIColor(hexFromString: "#F5F5F5"))
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
            } else if viewModel.isDataLoaded {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Company Header
                        VStack(spacing: 12) {
                            AsyncImage(url: URL(string: viewModel.companyLogo)) { image in
                                image.resizable()
                            } placeholder: {
                                Circle()
                                    .fill(Color(red: 242/255, green: 190/255, blue: 54/255))
                                    .overlay(
                                        Image(systemName: "building.2.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                    )
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            
                            Text(viewModel.companyName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            Button(action: {
                                viewModel.toggleOnlineStatus()
                            }) {
                                Text(viewModel.isOnline ? "Online" : "Offline")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                    .background(viewModel.isOnline ? Color.green : Color.red)
                                    .cornerRadius(16)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Company Details
                        VStack(alignment: .leading, spacing: 0) {
                            ProfileDetailRow(label: "Company Name", value: viewModel.companyName)
                            Divider()
                            ProfileDetailRow(label: "Company Phone", value: viewModel.companyPhone)
                            Divider()
                            ProfileDetailRow(label: "Company Email", value: viewModel.companyEmail)
                            Divider()
                            ProfileDetailRow(label: "Address", value: viewModel.address)
                            Divider()
                            ProfileDetailRow(label: "City", value: viewModel.city)
                            Divider()
                            ProfileDetailRow(label: "Area", value: viewModel.area)
                            Divider()
                            ProfileDetailRow(label: "Country", value: viewModel.country)
                            Divider()
                            ProfileDetailRow(label: "Registration Date", value: viewModel.registrationDate)
                            Divider()
                            ProfileDetailRow(label: "Company ID", value: viewModel.companyId)
                            Divider()
                            ProfileDetailRow(label: "Membership No", value: viewModel.membershipNo)
                            Divider()
                            ProfileDetailRow(label: "License Number", value: viewModel.licenseNumber)
                            Divider()
                            ProfileDetailRow(label: "No. of Employees", value: viewModel.noOfEmployees)
                            Divider()
                            ProfileDetailRow(label: "Owner Name", value: viewModel.ownerName)
                            Divider()
                            ProfileDetailRow(label: "Owner Contact", value: viewModel.ownerContact)
                            Divider()
                            ProfileDetailRow(label: "Owner Email", value: viewModel.ownerEmail)
                            Divider()
                            ProfileDetailRow(label: "Available 24/7", value: viewModel.available24x7 ? "Yes" : "No")
                            Divider()
                            ProfileDetailRow(label: "Account Status", value: viewModel.accountStatus)
                            Divider()
                            ProfileDetailRow(label: "Verified Company", value: viewModel.isVerified ? "Yes" : "No")
                            Divider()
                            ProfileDetailRow(label: "Company Approved", value: viewModel.isApproved ? "Yes" : "No")
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding(16)
                }
            } else {
                Text("No data available")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Company Profile")
        .onAppear {
            viewModel.loadVendorProfile()
        }
    }
}

struct ProfileDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(width: 140, alignment: .leading)
            
            Text(value.isEmpty ? "N/A" : value)
                .font(.system(size: 14))
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

class VendorProfileViewModel: ObservableObject {
    @Published var companyName = ""
    @Published var companyPhone = ""
    @Published var companyEmail = ""
    @Published var companyLogo = ""
    @Published var address = ""
    @Published var city = ""
    @Published var area = ""
    @Published var country = ""
    @Published var registrationDate = ""
    @Published var companyId = ""
    @Published var membershipNo = ""
    @Published var licenseNumber = ""
    @Published var noOfEmployees = ""
    @Published var ownerName = ""
    @Published var ownerContact = ""
    @Published var ownerEmail = ""
    @Published var available24x7 = false
    @Published var accountStatus = ""
    @Published var isVerified = false
    @Published var isApproved = false
    @Published var isOnline = false
    @Published var isDataLoaded = false
    
    private var vendorId: String {
        if let vendorData = UserDefaults.standard.data(forKey: "vendor"),
           let vendorDict = try? JSONSerialization.jsonObject(with: vendorData) as? [String: Any] {
            return vendorDict["id"] as? String ?? ""
        }
        return ""
    }
    
    func loadVendorProfile() {
        guard !vendorId.isEmpty else { return }
        
        let completeURL = EndPoints.BASE_URL + "vendor/my_company"
        let params: [String: String] = ["vendor_id": vendorId]
        
        AF.request(completeURL, method: .post, parameters: params)
            .validate()
            .responseJSON { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if json["error"].stringValue == "false" {
                        self.parseVendorData(json["vendor_profile"])
                    }
                case .failure(let error):
                    print("Error loading profile: \(error)")
                }
            }
    }
    
    private func parseVendorData(_ json: JSON) {
        companyName = json["company_name"].stringValue
        companyPhone = json["company_phone"].stringValue
        companyEmail = json["company_email"].stringValue
        companyLogo = json["company_logo"].stringValue
        address = json["address"].stringValue
        city = json["city"].stringValue
        area = json["area"].stringValue
        country = json["country"].stringValue
        registrationDate = json["registration_date"].stringValue
        companyId = json["company_id"].stringValue
        membershipNo = json["membership_no"].stringValue
        licenseNumber = json["license_number"].stringValue
        noOfEmployees = json["no_of_employees"].stringValue
        ownerName = json["owner_name"].stringValue
        ownerContact = json["owner_contact"].stringValue
        ownerEmail = json["owner_email"].stringValue
        available24x7 = json["available_24_7"].boolValue
        accountStatus = json["account_status"].stringValue
        isVerified = json["verified_company"].boolValue
        isApproved = json["company_approved"].boolValue
        isOnline = json["online_status"].boolValue
        isDataLoaded = true
    }
    
    func toggleOnlineStatus() {
        isOnline.toggle()
        // TODO: Call API to update online status
    }
    
    func navigate(_ to: String) {
        print("Navigate to: \(to)")
    }
    
    func logout() {
        Global.shared.user = nil
        Global.shared.isLogedIn = false
        Global.shared.isVendor = false
        Global.shared.loginType = ""
        UserDefaultsManager.shared.clearAllLoginData()
        UserDefaults.standard.removeObject(forKey: "vendor")
        UserDefaults.standard.synchronize()
    }
}
