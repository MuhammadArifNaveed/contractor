//
//  VendorHomeView.swift
//  TheContractor
//
//  Vendor home screen matching Android VendorHome
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct VendorHomeView: View {
    @State private var isLoading = false
    @State private var dashboardStats: [DashboardStat] = []
    @State private var pendingEnquiries: [EnquiryItem] = []
    @State private var acceptedEnquiries: [EnquiryItem] = []
    @State private var todayEnquiries: [EnquiryItem] = []
    
    private var vendorId: String {
        if let vendorData = UserDefaults.standard.data(forKey: "vendor"),
           let vendorDict = try? JSONSerialization.jsonObject(with: vendorData) as? [String: Any] {
            return vendorDict["id"] as? String ?? ""
        }
        return ""
    }
    
    var body: some View {
        ZStack {
            Color(UIColor(hexFromString: "#F5F5F5"))
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        Text("Enquiries Dashboard")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                        
                        // Dashboard Stats Grid
                        if !dashboardStats.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(dashboardStats) { stat in
                                    DashboardStatCard(stat: stat)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Pending Enquiries
                        if !pendingEnquiries.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pending Enquiries")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(pendingEnquiries) { enquiry in
                                            EnquiryCard(enquiry: enquiry)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        // Accepted Enquiries
                        if !acceptedEnquiries.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Accepted Enquiries")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(acceptedEnquiries) { enquiry in
                                            EnquiryCard(enquiry: enquiry)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        // Today Enquiries
                        if !todayEnquiries.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Today Enquiries")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                
                                VStack(spacing: 8) {
                                    ForEach(todayEnquiries) { enquiry in
                                        EnquiryCard(enquiry: enquiry)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        if dashboardStats.isEmpty && pendingEnquiries.isEmpty && acceptedEnquiries.isEmpty && todayEnquiries.isEmpty {
                            Text("No data found")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.top, 100)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .onAppear {
            loadVendorDashboard()
        }
    }
    
    private func loadVendorDashboard() {
        guard !vendorId.isEmpty else { return }
        
        isLoading = true
        
        let completeURL = EndPoints.BASE_URL + "Vendor/dashboard"
        let params: [String: String] = ["vendor_id": vendorId]
        
        AF.request(completeURL, method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                isLoading = false
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if json["error"].stringValue == "false" {
                        parseDashboardData(json)
                    }
                case .failure(let error):
                    print("Error loading dashboard: \(error)")
                }
            }
    }
    
    private func parseDashboardData(_ json: JSON) {
        // Parse dashboard stats
        if let dashboardArray = json["dashboard"].array {
            dashboardStats = dashboardArray.compactMap { statJSON in
                DashboardStat(
                    title: statJSON["title"].stringValue,
                    count: statJSON["count"].stringValue
                )
            }
        }
        
        // Parse pending enquiries
        if let pendingArray = json["pending_enquiries"].array {
            pendingEnquiries = pendingArray.compactMap { enquiryJSON in
                EnquiryItem(
                    id: enquiryJSON["id"].stringValue,
                    name: enquiryJSON["name"].stringValue,
                    description: enquiryJSON["description"].stringValue
                )
            }
        }
        
        // Parse accepted enquiries
        if let acceptedArray = json["accepted_enquiries"].array {
            acceptedEnquiries = acceptedArray.compactMap { enquiryJSON in
                EnquiryItem(
                    id: enquiryJSON["id"].stringValue,
                    name: enquiryJSON["name"].stringValue,
                    description: enquiryJSON["description"].stringValue
                )
            }
        }
        
        // Parse today enquiries
        if let todayArray = json["today_enquiries"].array {
            todayEnquiries = todayArray.compactMap { enquiryJSON in
                EnquiryItem(
                    id: enquiryJSON["id"].stringValue,
                    name: enquiryJSON["name"].stringValue,
                    description: enquiryJSON["description"].stringValue
                )
            }
        }
    }
}

// MARK: - Models
struct DashboardStat: Identifiable {
    let id = UUID()
    let title: String
    let count: String
}

struct EnquiryItem: Identifiable {
    let id: String
    let name: String
    let description: String
}

// MARK: - Dashboard Stat Card
struct DashboardStatCard: View {
    let stat: DashboardStat
    
    var body: some View {
        VStack(spacing: 8) {
            Text(stat.count)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 242/255, green: 190/255, blue: 54/255))
            
            Text(stat.title)
                .font(.system(size: 12))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Enquiry Card
struct EnquiryCard: View {
    let enquiry: EnquiryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(enquiry.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            Text(enquiry.description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .frame(width: 200)
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct VendorHomeView_Previews: PreviewProvider {
    static var previews: some View {
        VendorHomeView()
    }
}
