//  LanguageSelectionView.swift
import SwiftUI
struct LanguageSelectionView: View {
    @StateObject private var viewModel = LanguageSelectionViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        List {
            ForEach(viewModel.languages, id: \.code) { lang in
                Button(action: { viewModel.selectLanguage(lang); presentationMode.wrappedValue.dismiss() }) {
                    HStack {
                        Text(lang.name).font(AppTheme.Fonts.regular(16))
                        Spacer()
                        if viewModel.selectedLanguage == lang.code { Image(systemName: "checkmark").foregroundColor(AppTheme.Colors.primary) }
                    }
                }
            }
        }
        .navigationTitle("Select Language")
    }
}
class LanguageSelectionViewModel: ObservableObject {
    @Published var selectedLanguage = UserDefaultsManager.shared.currentLocale
    let languages = [Language(code: "en", name: "English"), Language(code: "ar", name: "العربية")]
    func selectLanguage(_ lang: Language) {
        UserDefaultsManager.shared.currentLocale = lang.code
        selectedLanguage = lang.code
    }
}
struct Language { let code, name: String }
