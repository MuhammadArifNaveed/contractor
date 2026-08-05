//  LanguageSelectionView.swift
import SwiftUI
struct LanguageSelectionView: View {
    @StateObject private var viewModel = LanguageSelectionViewModel()
    @Environment(\.presentationMode) var presentationMode
    /// Opened both as a pushed screen (from the profile menu) and as a drawer item, which has no
    /// navigation bar of its own — hence the explicit bar rather than `navigationTitle`.
    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Select Language", onBack: onBack)
            list
        }
        .navigationBarHidden(true)
    }

    /// Nil when the screen is drawer-rooted: the bar then shows the hamburger.
    var onBack: (() -> Void)? = { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }

    private var list: some View {
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
