//
//  SearchCompaniesView.swift
//  TheContractor
//
//  Search companies screen matching Android Search activity
//

import SwiftUI

struct SearchCompaniesView: View {
    @StateObject private var viewModel = SearchCompaniesViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var keyword = ""
    @State private var showVerifiedOnly = false
    @State private var navigateToResults = false
    @State private var showSpecialtiesPicker = false

    var body: some View {
        ZStack {
            NavigationLink(
                destination: SearchResultsView(
                    categoryId: viewModel.selectedCategoryId,
                    subCategoryIds: Array(viewModel.selectedSubCategoryIds),
                    cityId: viewModel.selectedCityId,
                    specialityIds: Array(viewModel.selectedSpecialityIds),
                    keyword: keyword,
                    verified: showVerifiedOnly
                ),
                isActive: $navigateToResults
            ) { EmptyView() }

        VStack(spacing: 0) {
            // Top Bar
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Keyword Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Keyword")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .underline(color: Color(red: 242/255, green: 190/255, blue: 54/255))
                        TextField("Enter keyword...", text: $keyword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 16)

                    // Specialties Section
                    if !viewModel.specialities.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Specialties")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .underline(color: Color(red: 242/255, green: 190/255, blue: 54/255))

                            Button(action: { showSpecialtiesPicker = true }) {
                                HStack {
                                    Text(viewModel.selectedSpecialityIds.isEmpty
                                         ? "Select Specialties"
                                         : "\(viewModel.selectedSpecialityIds.count) selected")
                                        .foregroundColor(viewModel.selectedSpecialityIds.isEmpty ? .gray : .black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Categories Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Categories")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .underline(color: Color(red: 242/255, green: 190/255, blue: 54/255))
                        
                        // Categories horizontal scroll
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.categories.indices, id: \.self) { index in
                                    let category = viewModel.categories[index]
                                    let isSelected = viewModel.selectedCategoryId == category.id
                                    
                                    Text(category.name)
                                        .font(.system(size: 14))
                                        .foregroundColor(isSelected ? .white : .black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? Color(red: 0/255, green: 150/255, blue: 136/255) : Color.white)
                                        .cornerRadius(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        .onTapGesture {
                                            viewModel.selectCategory(category)
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Sub Categories Section
                    if !viewModel.subCategories.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sub Categories")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .underline(color: Color(red: 242/255, green: 190/255, blue: 54/255))
                            
                            // Sub categories grid
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 10),
                                    GridItem(.flexible(), spacing: 10)
                                ],
                                spacing: 10
                            ) {
                                ForEach(viewModel.subCategories.indices, id: \.self) { index in
                                    let subCategory = viewModel.subCategories[index]
                                    let isSelected = viewModel.selectedSubCategoryIds.contains(subCategory.id)
                                    
                                    Text(subCategory.name)
                                        .font(.system(size: 14))
                                        .foregroundColor(isSelected ? .white : .black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(isSelected ? Color(red: 0/255, green: 150/255, blue: 136/255) : Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        .onTapGesture {
                                            viewModel.toggleSubCategory(subCategory)
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Cities Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cities")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .underline(color: Color(red: 242/255, green: 190/255, blue: 54/255))
                        
                        // Cities horizontal scroll
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.cities.indices, id: \.self) { index in
                                    let city = viewModel.cities[index]
                                    let isSelected = viewModel.selectedCityId == city.id
                                    
                                    Text(city.name)
                                        .font(.system(size: 14))
                                        .foregroundColor(isSelected ? .white : .black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? Color(red: 0/255, green: 150/255, blue: 136/255) : Color.white)
                                        .cornerRadius(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        .onTapGesture {
                                            viewModel.selectCity(city)
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Show Verified Only Checkbox
                    HStack(spacing: 12) {
                        Button(action: { showVerifiedOnly.toggle() }) {
                            Image(systemName: showVerifiedOnly ? "checkmark.square.fill" : "square")
                                .font(.system(size: 24))
                                .foregroundColor(showVerifiedOnly ? Color(red: 242/255, green: 190/255, blue: 54/255) : .gray)
                        }
                        Text("Show Verified listed only")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    // Search Button
                    Button(action: {
                        if viewModel.selectedCategoryId.isEmpty {
                            viewModel.errorMessage = "Please select a category"
                        } else {
                            navigateToResults = true
                        }
                    }) {
                        Text("Search")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 242/255, green: 190/255, blue: 54/255))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)

                    if let err = viewModel.errorMessage {
                        Text(err)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadSearchData()
        }
        .sheet(isPresented: $showSpecialtiesPicker) {
            SpecialtiesPickerSheet(
                specialities: viewModel.specialities,
                selectedIds: $viewModel.selectedSpecialityIds
            )
        }
    }
    
    private var topBar: some View {
        HStack(spacing: 0) {
            Button(action: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)

            Text("Search")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.leading, 8)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(Color(red: 242/255, green: 190/255, blue: 54/255))
    }
}

struct FilterButton: View {
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(value.isEmpty ? title : value)
                    .font(AppTheme.Fonts.regular(13))
                    .foregroundColor(value.isEmpty ? AppTheme.Colors.textSecondary : AppTheme.Colors.primary)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.Colors.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .stroke(value.isEmpty ? Color.clear : AppTheme.Colors.primary, lineWidth: 1)
            )
        }
    }
}

// MARK: - Specialties Picker Sheet
struct SpecialtiesPickerSheet: View {
    let specialities: [SpecialityItem]
    @Binding var selectedIds: Set<String>
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(specialities) { item in
                Button(action: {
                    if selectedIds.contains(item.id) {
                        selectedIds.remove(item.id)
                    } else {
                        selectedIds.insert(item.id)
                    }
                }) {
                    HStack {
                        Text(item.title)
                            .foregroundColor(.black)
                        Spacer()
                        if selectedIds.contains(item.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(red: 242/255, green: 190/255, blue: 54/255))
                        }
                    }
                }
            }
            .navigationTitle("Select Specialties")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Done").font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct SearchCompaniesView_Previews: PreviewProvider {
    static var previews: some View {
        SearchCompaniesView()
    }
}
