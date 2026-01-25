import SwiftUI
import PhotosUI
import UIKit
import UniformTypeIdentifiers
import SwiftyJSON

struct UpdateFreelancerView: View {
    enum Mode {
        case registerCompany
        case generic
    }

    private enum Step: Int, CaseIterable {
        case general = 0
        case bank = 1
        case address = 2

        var title: String {
            switch self {
            case .general: return "GENERAL"
            case .bank: return "BANK\nACCOUNT"
            case .address: return "ADDRESS"
            }
        }

        var header: String {
            switch self {
            case .general: return "Step 1: General Information"
            case .bank: return "Step 2: Bank Account"
            case .address: return "Step 3: Address"
            }
        }
    }

    @Environment(\.presentationMode) private var presentationMode

    let mode: Mode

    @State private var step: Step = .general

    // General information
    @State private var name: String = "Test Freelancer"
    @State private var email: String = "test@example.com"
    @State private var phone: String = "0501234567"
    /// Used as Hourly Rate (AED) field
    @State private var experienceYears: String = "25"
    @State private var selectedSkills: [String] = ["Plumbing", "Electrical"]
    @State private var selectedCategory: String = "Maintenance"
    @State private var selectedCity: String = "Dubai"
    @State private var selectedArea: String = "Deira"

    @State private var availablePerHour: Bool = true
    @State private var startTime: Date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime: Date = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()

    @State private var bankName: String = "Emirates NBD"
    @State private var bankAddress: String = "Dubai Main Branch"
    @State private var accountTitle: String = "Test Account"
    @State private var iban: String = "AE070300000000123456789"

    // Media selection
    @State private var isShowingImagePicker: Bool = false
    @State private var isShowingVideoPicker: Bool = false
    @State private var selectedImagesCount: Int = 0
    @State private var selectedVideoDescription: String = ""
    @State private var selectedImageData: Data?
    @State private var selectedVideoData: Data?

    @State private var addresses: [FreelancerAddress] = [
        FreelancerAddress(title: "this is testing current address", fullAddress: "139 Second Industrial St - Industrial Areas - Industrial Area - Sharjah - United Arab Emirates", isCurrent: true),
        FreelancerAddress(title: "test", fullAddress: "", isCurrent: false),
        FreelancerAddress(title: "sfsdfsdfs", fullAddress: "", isCurrent: false),
        FreelancerAddress(title: "this is address", fullAddress: "139 Second Industrial St - Industrial Areas - Industrial Area - Sharjah - United Arab Emirates", isCurrent: false)
    ]

    @State private var addressPendingDelete: FreelancerAddress?
    @State private var showingDeleteAlert: Bool = false

    @State private var isShowingSkillPicker: Bool = false
    @State private var isSelectingStartTime: Bool = false
    @State private var isSelectingEndTime: Bool = false
    @State private var isShowingAddAddress: Bool = false
    @State private var isSubmitting: Bool = false

    @State private var activeSinglePicker: SinglePickerType?

    @State private var toastMessage: String = ""
    @State private var isShowingToast: Bool = false

    @State private var registrationAlert: RegistrationAlert?

    @State private var generalErrors: GeneralErrors = .init()
    @State private var bankErrors: BankErrors = .init()
    @State private var addressErrors: AddressErrors = .init()

    // Dropdown data loaded from API
    @State private var skills: [String] = []
    @State private var categories: [String] = []
    @State private var cities: [String] = []
    @State private var areas: [String] = []
    @State private var cityToAreas: [String: [String]] = [:]

    @State private var skillIdByTitle: [String: String] = [:]
    @State private var categoryIdByTitle: [String: String] = [:]
    @State private var cityIdByName: [String: String] = [:]
    @State private var areaIdByCityAndTitle: [String: [String: String]] = [:]

    init(mode: Mode = .generic) {
        self.mode = mode
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                stepBar

                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                        Text(step.header)
                            .font(AppTheme.Fonts.semibold(18))
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        if step == .general {
                            generalStep
                        }
                        else if step == .bank {
                            bankStep
                        }
                        else {
                            addressStep
                        }
                    }
                    .padding(AppTheme.Spacing.medium)
                }

                footerButtons
                    .padding(.horizontal, AppTheme.Spacing.medium)
                    .padding(.bottom, AppTheme.Spacing.medium)
            }

            if isShowingToast {
                ToastBanner(message: toastMessage)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
            }

            if let picker = activeSinglePicker {
                SinglePickerOverlay(
                    title: picker.title,
                    options: options(for: picker),
                    onSelect: { option in
                        applySelection(picker: picker, value: option)
                        activeSinglePicker = nil
                    },
                    onDismiss: {
                        activeSinglePicker = nil
                    }
                )
                .zIndex(9)
            }

            if isShowingAddAddress {
                AddAddressOverlay { newAddress in
                    addAddress(newAddress)
                    isShowingAddAddress = false
                } onCancel: {
                    isShowingAddAddress = false
                }
                .zIndex(8)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isShowingSkillPicker) {
            SkillPickerSheet(
                title: "Search Skills",
                options: skills,
                selected: selectedSkills,
                onDone: { updated in
                    selectedSkills = updated
                    isShowingSkillPicker = false
                },
                onCancel: {
                    isShowingSkillPicker = false
                }
            )
        }
        .sheet(isPresented: $isSelectingStartTime) {
            TimePickerSheet(title: "Start Time", date: $startTime) {
                isSelectingStartTime = false
            }
        }
        .sheet(isPresented: $isSelectingEndTime) {
            TimePickerSheet(title: "End Time", date: $endTime) {
                isSelectingEndTime = false
            }
        }
        .alert("Delete Address", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let address = addressPendingDelete {
                    print("🗑️ Alert delete button pressed for: \(address.title)")
                    deleteAddress(address)
                }
                addressPendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                addressPendingDelete = nil
            }
        } message: {
            if let address = addressPendingDelete {
                Text("Are you sure you want to delete \(address.title)?")
            }
        }
        .alert(item: $registrationAlert) { alert in
            Alert(
                title: Text(alert.isSuccess ? "✅ Success" : "❌ Error"),
                message: Text(alert.message),
                dismissButton: .default(Text(alert.isSuccess ? "Great!" : "OK")) {
                    if alert.isSuccess {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePickerSheet { images in
                selectedImagesCount = images.count
                if let first = images.first {
                    selectedImageData = first.jpegData(compressionQuality: 0.8)
                }
                isShowingImagePicker = false
            }
        }
        .sheet(isPresented: $isShowingVideoPicker) {
            VideoPickerSheet { data, description in
                selectedVideoData = data
                selectedVideoDescription = description
                isShowingVideoPicker = false
            }
        }
        .onAppear {
            if skills.isEmpty || categories.isEmpty || cities.isEmpty {
                loadFreelancingSearch()
            }
        }
        .onChange(of: step) { newStep in
            // Fetch addresses only when switching to address step in company mode
            if newStep == .address && mode == .registerCompany {
                fetchFreelancerAddresses()
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 0) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)

            Text("Add Freelancer")
                .font(AppTheme.Fonts.title)
                .foregroundColor(.white)
                .padding(.leading, 8)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(AppTheme.Colors.primary)
    }

    private var stepBar: some View {
        HStack(spacing: 0) {
            ForEach(Step.allCases, id: \.rawValue) { item in
                Button(action: {
                    if item.rawValue <= step.rawValue {
                        step = item
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(item.title)
                            .font(AppTheme.Fonts.medium(13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(item == step ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)

                        Rectangle()
                            .fill(item == step ? AppTheme.Colors.primary : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.white)
    }

    private var generalStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            ValidatedTextField(
                placeholder: "Name",
                text: $name,
                error: generalErrors.name
            )

            ValidatedTextField(
                placeholder: "Email",
                text: $email,
                error: generalErrors.email,
                keyboardType: .emailAddress
            )

            ValidatedTextField(
                placeholder: "Phone",
                text: $phone,
                error: generalErrors.phone,
                keyboardType: .phonePad
            )

            ValidatedTextField(
                placeholder: "Hourly Rate (AED)",
                text: $experienceYears,
                error: generalErrors.experience,
                keyboardType: .decimalPad
            )

            VStack(alignment: .leading, spacing: 6) {
                Button(action: { isShowingSkillPicker = true }) {
                    HStack {
                        Text(selectedSkills.isEmpty ? "Search Skills" : "Search Skills")
                            .font(AppTheme.Fonts.body)
                            .foregroundColor(selectedSkills.isEmpty ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .padding(14)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(generalErrors.skills == nil ? AppTheme.Colors.primary.opacity(0.75) : Color.red, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                if !selectedSkills.isEmpty {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 130), spacing: 10, alignment: .leading)],
                        alignment: .leading,
                        spacing: 10
                    ) {
                        ForEach(selectedSkills, id: \.self) { skill in
                            SkillChip(title: skill) {
                                selectedSkills.removeAll { $0 == skill }
                            }
                        }
                    }
                    .padding(.top, 2)
                }

                if let error = generalErrors.skills {
                    InlineErrorText(error)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                PickerField(
                    title: selectedCategory.isEmpty ? "Select Category" : selectedCategory,
                    hasError: generalErrors.category != nil,
                    onTap: { activeSinglePicker = .category }
                )

                if let error = generalErrors.category {
                    InlineErrorText(error)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                PickerField(
                    title: selectedCity.isEmpty ? "Select City" : selectedCity,
                    hasError: generalErrors.city != nil,
                    onTap: { activeSinglePicker = .city }
                )

                if let error = generalErrors.city {
                    InlineErrorText(error)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                PickerField(
                    title: selectedArea.isEmpty ? "Select Area" : selectedArea,
                    hasError: generalErrors.area != nil,
                    onTap: { activeSinglePicker = .area }
                )

                if let error = generalErrors.area {
                    InlineErrorText(error)
                }
            }

            Button(action: {
                availablePerHour.toggle()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: availablePerHour ? "checkmark.square.fill" : "square")
                        .foregroundColor(AppTheme.Colors.primary)

                    Text("Available Per Hour")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Spacer()
                }
            }
            .buttonStyle(.plain)

            if availablePerHour {
                HStack(spacing: AppTheme.Spacing.medium) {
                    Button(action: { isSelectingStartTime = true }) {
                        HStack {
                            Text(timeString(startTime))
                                .font(AppTheme.Fonts.body)
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Spacer()
                        }
                        .padding(14)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(generalErrors.time == nil ? AppTheme.Colors.primary.opacity(0.75) : Color.red, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: { isSelectingEndTime = true }) {
                        HStack {
                            Text(timeString(endTime))
                                .font(AppTheme.Fonts.body)
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Spacer()
                        }
                        .padding(14)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(generalErrors.time == nil ? AppTheme.Colors.primary.opacity(0.75) : Color.red, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }

                if let error = generalErrors.time {
                    InlineErrorText(error)
                }
            }

            // Media buttons
            Button(action: {
                isShowingImagePicker = true
            }) {
                HStack {
                    Text(selectedImagesCount > 0 ? "Choose Images (\(selectedImagesCount) selected)" : "Choose Images")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Spacer()
                }
                .padding(14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Button(action: {
                isShowingVideoPicker = true
            }) {
                HStack {
                    Text(selectedVideoDescription.isEmpty ? "Choose Video" : selectedVideoDescription)
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Spacer()
                }
                .padding(14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var bankStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            ValidatedTextField(
                placeholder: "Bank Name",
                text: $bankName,
                error: bankErrors.bankName
            )

            ValidatedTextField(
                placeholder: "Bank Address",
                text: $bankAddress,
                error: bankErrors.bankAddress
            )

            ValidatedTextField(
                placeholder: "Account Title",
                text: $accountTitle,
                error: bankErrors.accountTitle
            )

            ValidatedTextField(
                placeholder: "IBAN",
                text: $iban,
                error: bankErrors.iban
            )
        }
    }

    private var addressStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Spacer()

                Button(action: { isShowingAddAddress = true }) {
                    Text("Add Address")
                        .font(AppTheme.Fonts.medium(14))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }

            if let error = addressErrors.addressList {
                InlineErrorText(error)
            }

            LazyVStack(spacing: AppTheme.Spacing.medium) {
                ForEach(addresses) { address in
                    AddressCard(
                        address: address,
                        onSelectCurrent: {
                            addresses = addresses.map {
                                FreelancerAddress(id: $0.id, title: $0.title, fullAddress: $0.fullAddress, isCurrent: $0.id == address.id)
                            }
                        },
                        onDelete: {
                            print("🗑️ onDelete callback triggered for: \(address.title)")
                            addressPendingDelete = address
                            showingDeleteAlert = true
                            print("🗑️ showingDeleteAlert set to true")
                        }
                    )
                }
            }
        }
    }

    private var footerButtons: some View {
        Group {
            if step == .general {
                Button(action: {
                    if validateGeneral() {
                        step = .bank
                    }
                }) {
                    Text("Next Step")
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            else if step == .bank {
                HStack(spacing: AppTheme.Spacing.medium) {
                    Button(action: {
                        step = .general
                    }) {
                        Text("Back")
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        if validateBank() {
                            step = .address
                        }
                    }) {
                        Text("Next")
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.black.opacity(0.7), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            else {
                HStack(spacing: AppTheme.Spacing.medium) {
                    Button(action: {
                        if !isSubmitting { step = .bank }
                    }) {
                        Text("Back")
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        guard !isSubmitting else { return }
                        if validateAddress() {
                            if mode == .registerCompany {
                                submitCompanyRegistration()
                            } else {
                                showToast("Update submitted")
                            }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppTheme.Colors.primary)
                                .frame(height: 52)
                            
                            if isSubmitting {
                                HStack(spacing: 12) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                    Text("Registering...")
                                        .font(AppTheme.Fonts.semibold(16))
                                        .foregroundColor(.white)
                                }
                            } else {
                                Text("Submit")
                                    .font(AppTheme.Fonts.semibold(16))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isSubmitting)
                }
            }
        }
    }

    private func validateGeneral() -> Bool {
        generalErrors = .init()

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            generalErrors.name = "Name is required"
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
            generalErrors.email = "Email is required"
        } else if !isValidEmail(trimmedEmail) {
            generalErrors.email = "Enter a valid email address"
        }

        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPhone.isEmpty {
            generalErrors.phone = "Phone is required"
        }

        let trimmedRate = experienceYears.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedRate.isEmpty {
            generalErrors.experience = "Hourly rate is required"
        }
        else if Double(trimmedRate) == nil {
            generalErrors.experience = "Enter a valid amount"
        }

        if selectedSkills.isEmpty {
            generalErrors.skills = "Please select at least 1 skill"
        }

        if selectedCategory.isEmpty {
            generalErrors.category = "Please select category"
        }

        if selectedCity.isEmpty {
            generalErrors.city = "Please select city"
        }

        if selectedArea.isEmpty {
            generalErrors.area = "Please select area"
        }

        if availablePerHour {
            if endTime <= startTime {
                generalErrors.time = "End time must be after start time"
            }
        }

        if let message = firstGeneralErrorMessage() {
            showToast(message)
            return false
        }

        return true
    }

    private func validateBank() -> Bool {
        bankErrors = .init()

        if bankName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bankErrors.bankName = "Bank name is required"
        }

        if bankAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bankErrors.bankAddress = "Bank address is required"
        }

        if accountTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bankErrors.accountTitle = "Account title is required"
        }

        if iban.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bankErrors.iban = "IBAN is required"
        }

        if let message = firstBankErrorMessage() {
            showToast(message)
            return false
        }

        return true
    }

    private func validateAddress() -> Bool {
        addressErrors = .init()

        if addresses.isEmpty {
            addressErrors.addressList = "Please add at least 1 address"
        }

        if let message = addressErrors.addressList {
            showToast(message)
            return false
        }

        return true
    }

    private func currentAddressForRegistration() -> FreelancerAddress? {
        // First try to find current address with non-empty fullAddress
        if let current = addresses.first(where: { $0.isCurrent && !$0.fullAddress.isEmpty }) {
            return current
        }
        // If current address has empty fullAddress, find any address with non-empty fullAddress
        if let addressWithFullAddress = addresses.first(where: { !$0.fullAddress.isEmpty }) {
            return addressWithFullAddress
        }
        // Fallback to first address (even if empty)
        return addresses.first
    }

    private func submitCompanyRegistration() {
        guard !isSubmitting else { return }
        
        // Show loader immediately
        isSubmitting = true
        
        guard let vendor = Global.shared.companyVendor else {
            isSubmitting = false
            showToast("Company session not found")
            return
        }

        guard let primaryAddress = currentAddressForRegistration() else {
            isSubmitting = false
            showToast("Please add at least 1 address")
            return
        }
        
        // Validate that pick_up_address is not empty
        if primaryAddress.fullAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            isSubmitting = false
            showToast("Please add a complete address with pick-up location details")
            return
        }

        // Identity params for company user
        var params: [String: String] = [:]
        let userId = vendor.userId.isEmpty ? vendor.id : vendor.userId
        params["user_id"] = userId
        params["user_type"] = "companies"
        params["vendor_id"] = vendor.id

        // General
        params["name"] = name.trimmingCharacters(in: .whitespacesAndNewlines)
        params["email"] = email.trimmingCharacters(in: .whitespacesAndNewlines)
        params["phone"] = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        params["rate"] = experienceYears.trimmingCharacters(in: .whitespacesAndNewlines)

        // Skills as JSON string: [{"id":"1"},...]
        let skillIds: [String] = selectedSkills.compactMap { skillIdByTitle[$0] }
        if !skillIds.isEmpty {
            let jsonArray = skillIds.map { ["id": $0] }
            if let data = try? JSONSerialization.data(withJSONObject: jsonArray, options: []),
               let jsonString = String(data: data, encoding: .utf8) {
                params["freelancer_skills"] = jsonString
            }
        }

        if let catId = categoryIdByTitle[selectedCategory] {
            params["job_category"] = catId
        }
        if let cityId = cityIdByName[selectedCity] {
            params["city"] = cityId
        }
        if let areaId = areaIdByCityAndTitle[selectedCity]?[selectedArea] {
            params["area"] = areaId
        }

        params["available_per_hour"] = availablePerHour ? "1" : "0"
        params["from_time"] = timeString(startTime)
        params["to_time"] = timeString(endTime)

        // Bank
        params["bank_name"] = bankName
        params["bank_address"] = bankAddress
        params["account_title"] = accountTitle
        params["iban"] = iban

        // Address
        params["address"] = primaryAddress.title
        params["pick_up_address"] = primaryAddress.fullAddress
        params["pick_up_longitude"] = "0.00000000"
        params["pick_up_latitude"] = "0.00000000"

        FreelancingService.shared.registerCompanyFreelancer(params: params, imageData: selectedImageData, videoData: selectedVideoData) { message, success in
            DispatchQueue.main.async {
                // Always dismiss loader first
                isSubmitting = false
                
                if success {
                    // Show success alert
                    registrationAlert = RegistrationAlert(
                        message: message.isEmpty ? "Freelancer registered successfully!" : message, 
                        isSuccess: true
                    )
                } else {
                    // Show error alert with more descriptive message
                    let errorMessage = message.isEmpty ? "Registration failed. Please try again." : message
                    registrationAlert = RegistrationAlert(
                        message: errorMessage, 
                        isSuccess: false
                    )
                }
            }
        }
    }

    //MARK: - Address Management
    
    private func fetchFreelancerAddresses() {
        print("📍 Fetch addresses called - mode: \(mode), step: \(step)")
        
        guard let vendor = Global.shared.companyVendor else { 
            print("📍 No vendor found")
            return 
        }
        
        let freelancerId = vendor.userId.isEmpty ? vendor.id : vendor.userId
        print("📍 Fetching addresses for freelancer ID: \(freelancerId)")
        
        FreelancingService.shared.fetchFreelancerAddresses(freelancerId: freelancerId) { message, success, json in
            DispatchQueue.main.async {
                print("📍 Fetch API response - success: \(success), message: \(message)")
                if success, let json = json {
                    self.parseAddressesFromAPI(json: json)
                } else {
                    // Keep using hardcoded addresses if API fails
                    print("📍 Failed to fetch addresses: \(message)")
                }
            }
        }
    }
    
    private func parseAddressesFromAPI(json: JSON) {
        addresses.removeAll()
        
        if let addressesArray = json["addresses"].array {
            for addressJson in addressesArray {
                let id = addressJson["id"].stringValue
                let title = addressJson["address"].stringValue
                let pickUpAddress = addressJson["pick_up_address"].stringValue
                let status = addressJson["status"].stringValue == "1"
                
                let freelancerAddress = FreelancerAddress(
                    apiId: id,
                    title: title,
                    fullAddress: pickUpAddress.isEmpty ? title : pickUpAddress,
                    isCurrent: status
                )
                addresses.append(freelancerAddress)
            }
        }
    }
    
    private func deleteAddress(_ address: FreelancerAddress) {
        print("🗑️ Delete address called for: \(address.title)")
        
        guard let apiId = address.apiId else {
            print("🗑️ Local address - removing from array")
            // For local addresses, just remove from array
            addresses.removeAll { $0.id == address.id }
            showToast("Address deleted successfully")
            return
        }
        
        print("🗑️ API address - calling delete API with ID: \(apiId)")
        
        FreelancingService.shared.deleteFreelancerAddress(addressId: apiId) { message, success, json in
            DispatchQueue.main.async {
                print("🗑️ Delete API response - success: \(success), message: \(message)")
                if success {
                    self.addresses.removeAll { $0.id == address.id }
                    self.showToast("Address deleted successfully")
                } else {
                    self.showToast("Failed to delete address: \(message)")
                }
            }
        }
    }
    
    private func addAddress(_ address: FreelancerAddress) {
        guard let vendor = Global.shared.companyVendor else { return }
        
        let freelancerId = vendor.userId.isEmpty ? vendor.id : vendor.userId
        
        FreelancingService.shared.addFreelancerAddress(
            freelancerId: freelancerId,
            address: address.title,
            pickUpAddress: address.fullAddress,
            latitude: "0.00000000", // You might want to get actual coordinates
            longitude: "0.00000000",
            current: address.isCurrent
        ) { message, success, json in
            DispatchQueue.main.async {
                if success {
                    self.showToast("Address added successfully")
                    self.fetchFreelancerAddresses() // Refresh the list
                } else {
                    self.showToast("Failed to add address: \(message)")
                }
            }
        }
    }

    private func firstGeneralErrorMessage() -> String? {
        if let v = generalErrors.name { return v }
        if let v = generalErrors.email { return v }
        if let v = generalErrors.phone { return v }
        if let v = generalErrors.experience { return v }
        if let v = generalErrors.skills { return v }
        if let v = generalErrors.category { return v }
        if let v = generalErrors.city { return v }
        if let v = generalErrors.area { return v }
        if let v = generalErrors.time { return v }
        return nil
    }

    private func firstBankErrorMessage() -> String? {
        if let v = bankErrors.bankName { return v }
        if let v = bankErrors.bankAddress { return v }
        if let v = bankErrors.accountTitle { return v }
        if let v = bankErrors.iban { return v }
        return nil
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func showToast(_ message: String) {
        guard !message.isEmpty else { return }
        toastMessage = message
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowingToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isShowingToast = false
            }
        }
    }

    private func loadFreelancingSearch() {
        FreelancingService.shared.fetchFreelancingSearch { message, success, json in
            DispatchQueue.main.async {
                if success, let json = json {
                    let skillsArray = json["freelancer_skills"].arrayValue
                    skills = skillsArray.map { $0["title"].stringValue }
                    skillIdByTitle = Dictionary(uniqueKeysWithValues: skillsArray.map { ($0["title"].stringValue, $0["id"].stringValue) })

                    let categoriesArray = json["freelancer_categories"].arrayValue
                    categories = categoriesArray.map { $0["title"].stringValue }
                    categoryIdByTitle = Dictionary(uniqueKeysWithValues: categoriesArray.map { ($0["title"].stringValue, $0["id"].stringValue) })

                    let cityArray = json["freelancer_cities"].arrayValue
                    var loadedCities: [String] = []
                    var map: [String: [String]] = [:]
                    var areaIdMap: [String: [String: String]] = [:]
                    var cityIdMap: [String: String] = [:]

                    for city in cityArray {
                        let cityName = city["name"].stringValue
                        let cityId = city["id"].stringValue
                        loadedCities.append(cityName)
                        cityIdMap[cityName] = cityId

                        let areasJson = city["areas"].arrayValue
                        let areaNames = areasJson.map { $0["area_name"].stringValue }
                        map[cityName] = areaNames
                        var singleCityAreaMap: [String: String] = [:]
                        for area in areasJson {
                            singleCityAreaMap[area["area_name"].stringValue] = area["area_id"].stringValue
                        }
                        areaIdMap[cityName] = singleCityAreaMap
                    }
                    cities = loadedCities
                    cityToAreas = map
                    cityIdByName = cityIdMap
                    areaIdByCityAndTitle = areaIdMap

                    if !selectedCity.isEmpty {
                        areas = map[selectedCity] ?? []
                    }
                } else {
                    showToast(message)
                }
            }
        }
    }

    private func options(for picker: SinglePickerType) -> [String] {
        switch picker {
        case .category: return categories
        case .city: return cities
        case .area: return areas
        }
    }

    private func applySelection(picker: SinglePickerType, value: String) {
        switch picker {
        case .category:
            selectedCategory = value
        case .city:
            selectedCity = value
            selectedArea = ""
            areas = cityToAreas[value] ?? []
        case .area:
            selectedArea = value
        }
    }
}

private enum SinglePickerType {
    case category
    case city
    case area

    var title: String {
        switch self {
        case .category: return "Select Category"
        case .city: return "Select City"
        case .area: return "Select Area"
        }
    }
}

private struct PickerField: View {
    let title: String
    let hasError: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: { onTap() }) {
            HStack {
                Text(title)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(title.hasPrefix("Select") ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(14)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(hasError ? Color.red : Color.black.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ValidatedTextField: View {
    let placeholder: String
    @Binding var text: String
    let error: String?
    let keyboardType: UIKeyboardType

    init(placeholder: String, text: Binding<String>, error: String?, keyboardType: UIKeyboardType = .default) {
        self.placeholder = placeholder
        self._text = text
        self.error = error
        self.keyboardType = keyboardType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding(14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(error == nil ? AppTheme.Colors.primary.opacity(0.75) : Color.red, lineWidth: 1)
                )

            if let error {
                InlineErrorText(error)
            }
        }
    }
}

private struct SinglePickerOverlay: View {
    let title: String
    let options: [String]
    let onSelect: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                Text(title)
                    .font(AppTheme.Fonts.semibold(16))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)

                Divider()

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            Button(action: { onSelect(option) }) {
                                HStack {
                                    Text(option)
                                        .font(AppTheme.Fonts.body)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 48)
                            }
                            .buttonStyle(.plain)

                            if option != options.last {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxHeight: 320)
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }
}

private struct SkillChip: View {
    let title: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(AppTheme.Fonts.medium(13))
                .foregroundColor(.black)

            Button(action: { onRemove() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.black)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.primary)
        .cornerRadius(22)
    }
}

private struct InlineErrorText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(AppTheme.Fonts.caption)
            .foregroundColor(.red)
            .padding(.top, 2)
    }
}

private func isValidEmail(_ value: String) -> Bool {
    let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    return value.range(of: pattern, options: .regularExpression) != nil
}

private struct ToastBanner: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()

            Text(message)
                .font(AppTheme.Fonts.medium(14))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.85))
                .cornerRadius(10)
                .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}

private struct SkillPickerSheet: View {
    let title: String
    let options: [String]

    @State private var search: String = ""
    @State private var selected: Set<String>

    let onDone: ([String]) -> Void
    let onCancel: () -> Void

    init(title: String, options: [String], selected: [String], onDone: @escaping ([String]) -> Void, onCancel: @escaping () -> Void) {
        self.title = title
        self.options = options
        self._selected = State(initialValue: Set(selected))
        self.onDone = onDone
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Search", text: $search)
                    .padding(12)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .padding()

                List {
                    ForEach(filteredOptions, id: \.self) { option in
                        Button(action: {
                            if selected.contains(option) {
                                selected.remove(option)
                            }
                            else {
                                selected.insert(option)
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(.black)

                                Spacer()

                                if selected.contains(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.Colors.primary)
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { onCancel() },
                trailing: Button("Done") { onDone(Array(selected).sorted()) }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var filteredOptions: [String] {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return options
        }
        return options.filter { $0.lowercased().contains(trimmed.lowercased()) }
    }
}

private struct ImagePickerSheet: UIViewControllerRepresentable {
    let onComplete: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0 // multiple images
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onComplete: ([UIImage]) -> Void

        init(onComplete: @escaping ([UIImage]) -> Void) {
            self.onComplete = onComplete
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard !results.isEmpty else {
                onComplete([])
                return
            }

            var images: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                        if let image = object as? UIImage {
                            images.append(image)
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.onComplete(images)
            }
        }
    }
}

private struct VideoPickerSheet: UIViewControllerRepresentable {
    let onComplete: (Data?, String) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .videos
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onComplete: (Data?, String) -> Void

        init(onComplete: @escaping (Data?, String) -> Void) {
            self.onComplete = onComplete
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let first = results.first else {
                onComplete(nil, "")
                return
            }

            if first.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                first.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                    var data: Data? = nil
                    if let url {
                        data = try? Data(contentsOf: url)
                    }
                    DispatchQueue.main.async {
                        self.onComplete(data, data == nil ? "" : "Video selected")
                    }
                }
            } else {
                onComplete(nil, "")
            }
        }
    }
}

private struct TimePickerSheet: View {
    let title: String
    @Binding var date: Date
    let onDone: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()

                Spacer()
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { onDone() })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private struct FreelancerAddress: Identifiable {
    let id: UUID // For SwiftUI identification
    let apiId: String? // API address ID (from server)
    let title: String
    let fullAddress: String
    let isCurrent: Bool

    init(id: UUID = UUID(), apiId: String? = nil, title: String, fullAddress: String, isCurrent: Bool) {
        self.id = id
        self.apiId = apiId
        self.title = title
        self.fullAddress = fullAddress
        self.isCurrent = isCurrent
    }
}

private struct AddressCard: View {
    let address: FreelancerAddress
    let onSelectCurrent: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(address.title)
                .font(AppTheme.Fonts.medium(14))
                .foregroundColor(.black)

            if !address.fullAddress.isEmpty {
                Text(address.fullAddress)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            HStack {
                Button(action: { onSelectCurrent() }) {
                    HStack(spacing: 10) {
                        Image(systemName: address.isCurrent ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(AppTheme.Colors.primary)

                        Text("Current Address")
                            .font(AppTheme.Fonts.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)

                        Spacer()
                    }
                }
                .buttonStyle(.plain)

                Button(action: { 
                    print("🗑️ Delete button clicked for: \(address.title)")
                    onDelete() 
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.black)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
    }
}

private struct AddAddressOverlay: View {

    @State private var houseFlatNo: String = ""
    @State private var googleAddress: String = ""
    @State private var isCurrent: Bool = false

    @State private var error: String = ""

    let onSave: (FreelancerAddress) -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            VStack(spacing: 12) {
                VStack(spacing: 12) {
                    TextField("House / Flat No", text: $houseFlatNo)
                        .padding(14)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AppTheme.Colors.primary.opacity(0.75), lineWidth: 1)
                        )

                    TextField("Address from Google Map", text: $googleAddress)
                        .padding(14)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AppTheme.Colors.primary.opacity(0.75), lineWidth: 1)
                        )

                    Button(action: {
                        isCurrent.toggle()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: isCurrent ? "checkmark.square.fill" : "square")
                                .foregroundColor(AppTheme.Colors.primary)

                            Text("Current Address")
                                .font(AppTheme.Fonts.body)
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)

                    if !error.isEmpty {
                        Text(error)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: {
                        let h = houseFlatNo.trimmingCharacters(in: .whitespacesAndNewlines)
                        let g = googleAddress.trimmingCharacters(in: .whitespacesAndNewlines)

                        if h.isEmpty {
                            error = "House / Flat No is required"
                            return
                        }

                        if g.isEmpty {
                            error = "Address is required"
                            return
                        }

                        onSave(
                            FreelancerAddress(
                                title: h,
                                fullAddress: g,
                                isCurrent: isCurrent
                            )
                        )
                    }) {
                        Text("Save Address")
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 24)
            }
            .onTapGesture {
            }
        }
    }
}

private struct RegistrationAlert: Identifiable {
    let id = UUID()
    let message: String
    let isSuccess: Bool
}

private struct GeneralErrors {
    var name: String?
    var email: String?
    var phone: String?
    var experience: String?
    var skills: String?
    var category: String?
    var city: String?
    var area: String?
    var time: String?
}

private struct BankErrors {
    var bankName: String?
    var bankAddress: String?
    var accountTitle: String?
    var iban: String?
}

private struct AddressErrors {
    var addressList: String?
}


