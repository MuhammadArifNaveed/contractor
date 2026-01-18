# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview
TheContractor is an iOS application (iOS 15+) built with UIKit and SwiftUI that connects users with contractors and freelancers. The app uses a hybrid architecture combining storyboard-based UIKit screens with modern SwiftUI views for newer features.

## Common Commands

### Building and Running
```bash
# Install dependencies (must be run first)
pod install

# Open the workspace (not the .xcodeproj)
open TheContractor.xcworkspace

# Build from command line
xcodebuild -workspace TheContractor.xcworkspace -scheme TheContractor -configuration Debug

# Clean build folder
xcodebuild clean -workspace TheContractor.xcworkspace -scheme TheContractor
```

### Testing
```bash
# Run tests (if test target exists)
xcodebuild test -workspace TheContractor.xcworkspace -scheme TheContractor -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Dependencies Management
```bash
# Update pods
pod update

# Install specific pod version
pod install --repo-update
```

## Project Architecture

### Navigation Structure
The app uses a custom container-based navigation system:

- **KYDrawerController**: Root drawer controller that manages side menu navigation
- **MainContainerViewController**: Central navigation hub that manages:
  - Top bar with back button and search
  - Bottom tab bar with 5 main sections (Home, Workshop, Search, Estimation, Profile)
  - Container view that hosts different navigation controllers
  - Dynamic show/hide of top/bottom bars based on current screen

### Key Navigation Methods
- `showHomeController()` - Displays home with categories and companies
- `showWorkshopController()` - Shows workshop listings
- `showSearchController()` - Company search functionality
- `showEsstimationController()` - Budget estimation tool
- `showProfileController()` - User profile management
- `showFreelancersController()` - SwiftUI freelancer list (hides top bar)
- `showFreelanceDashboardController()` - SwiftUI freelance dashboard (hides both bars)
- `showWebController(title:link:)` - In-app web browser for static pages

### View Controller Hierarchy
```
KYDrawerController (Root)
├── UINavigationController
│   ├── MainContainerViewController (Container)
│   │   └── BaseNavigationController (Dynamic Content)
│   │       └── Various ViewControllers
│   └── SideMenuViewController (Drawer Menu)
```

### Base Classes
All view controllers inherit from `BaseViewController` which provides:
- Activity indicators (`startActivity()`, `stopActivity()`)
- Alert dialogs (`showAlertView()`)
- Image picker functionality (`fetchProfileImage()`)
- Keyboard management (`addTapGesture()`, `hideKeyboard()`)
- Internet connectivity checking (`checkInternetConnection()`)
- Image loading with SDWebImage (`setImageWithUrl()`)

### Networking Layer

#### Service Architecture
- **BaseService**: Parent class for all API services with:
  - Session management and cookie handling
  - Automatic header injection (session cookies)
  - Request logging and debugging
  - Multipart form data support
  - Response parsing via `ResponseHandler`

- **LoginService**: Singleton service handling authentication and main API calls
  - User login with session cookie extraction
  - Home data fetching (categories, companies)
  - Search and estimation data
  - Company search with filters

- **FreelancingService**: Singleton service for freelancing features
  - Dashboard metrics
  - Hired freelancers summary
  - Freelancing orders
  - Wallet management

#### API Endpoints
Base URL: `https://contractor.bidcont.com/rest/`

Main endpoints:
- `Account/user_login` - User authentication
- `Home/categories` - Home screen data
- `Home/get_estimation_categories` - Estimation categories
- `Home/get_search` - Search filters (cities, categories)
- `Home/find_companies` - Search results
- `freelancing/*` - Freelancing features

#### Session Management
- Sessions use CodeIgniter's `ci_session` cookie
- Cookie extracted during login and stored in `UserDefaultsManager.shared.token`
- Automatically added to all subsequent requests via `BaseService.getHeaders()`

### Data Layer

#### Global Singleton
`Global.shared` maintains app-wide state:
- `user: UserViewModel` - Current user info
- `isLogedIn: Bool` - Login status
- `fcmToken: String` - Push notification token
- Device information (model, OS version)

#### UserDefaults Wrapper
`UserDefaultsManager.shared` persists:
- `isUserLoggedIn` - Login state
- `userInfo` - User object (NSKeyedArchiver)
- `token` - Session cookie
- `currentLocale` - App language

#### View Models
All view models use SwiftyJSON for parsing:
- **HomeViewModel**: Categories, companies, titanium companies
- **SearchViewModel**: Cities with areas, categories with subcategories
- **CategoryViewModel**: Category with subcategories
- **CompanyViewModel**: Company details with ratings
- **UserViewModel**: User profile data
- **FreelancerViewModel**: Freelancer profile and availability

### SwiftUI Integration

The app integrates SwiftUI screens via `UIHostingController`:

#### Hosting Controllers
- `FreelancersHostingController` - Wraps `FreelancersView`
- `FreelanceDashboardHostingController` - Wraps `FreelanceDashboardView` with back callback

#### SwiftUI Theme System
`AppTheme` provides:
- **Colors**: Primary (F9B11F yellow), dark blue, gray, text colors
- **Fonts**: System fonts with semantic naming (title, headline, body, caption)
- **Spacing**: Consistent spacing scale (xxSmall to xxLarge)
- **CornerRadius**: Small (8), medium (12), large (20)
- **View Modifiers**: `.cardStyle()`, `.outlinedTextField()`

### Side Menu Structure
Defined in `SideMenu.MENULIST` with hidden items:
- Home
- Freelancers (visible) - Shows SwiftUI freelancer list
- Freelance Dashboard (visible) - Requires login, shows SwiftUI dashboard
- Workshop (visible)
- About Us, Advertisement, Become a Vendor (web views)
- Documentation, Privacy Policy, Terms & Conditions (web views)
- Guide, Contact Us (web views)

### UI Components

#### Reusable Views
- **BaseView**: Custom view parent class
- **BaseTableViewCell / BaseCollectionViewCell**: Cell parent classes
- **CategoryCollectionViewCell**: Category tiles with selection state
- **CompanyDetailsTableViewCell**: Company list items with ratings
- **MenuCollectionViewCell**: Horizontal menu items with underline indicator

#### Third-Party Libraries
- **Alamofire**: Networking
- **SwiftyJSON**: JSON parsing
- **SDWebImage**: Image loading and caching
- **IQKeyboardManagerSwift**: Automatic keyboard management
- **Cosmos**: Star rating display
- **iOSDropDown**: Dropdown selections
- **MBProgressHUD**: Activity indicators

### Storyboards
- **Main.storyboard**: Registration and login flows
- **Home.storyboard**: Main app screens (home, search, estimation, profile, workshop)
- **Drawer.storyboard**: Drawer controller and side menu
- **Registration.storyboard**: Login/signup screens

### GCD Helper
Custom `GCD` helper for threading:
```swift
GCD.async(.Background) {
    // Background work
    GCD.async(.Main) {
        // Update UI
    }
}
```

## Important Implementation Notes

### Login Flow
1. User enters phone (+971 prefix) and password
2. `LoginService.getUserLogin()` sends POST request
3. Session cookie extracted from `Set-Cookie` header
4. Cookie stored in `UserDefaultsManager.shared.token`
5. Navigate to drawer controller with `MainContainerViewController`

### Adding New API Calls
1. Add endpoint to `EndPoints` struct in `AppConstants.swift`
2. Add method in `LoginService` or create new service extending `BaseService`
3. Use `makeGetAPICall()` or `makePostAPICall()` with params
4. Parse response using SwiftyJSON and view models
5. Call API from view controller using GCD pattern

### Adding New Screens

#### UIKit Screens
1. Create view controller inheriting from `BaseViewController`
2. Add to appropriate storyboard
3. Add navigation in `MainContainerViewController` if needed
4. Set top/bottom bar visibility: `self.topBarView.isHidden`, `self.bottomBarView.isHidden`

#### SwiftUI Screens
1. Create SwiftUI view in `SwiftUI/Views/`
2. Create hosting controller inheriting from `UIHostingController`
3. Add show method in `MainContainerViewController`
4. Use `AppTheme` for consistent styling
5. For back navigation, pass callback to SwiftUI view or call `dismiss()`

### Session Issues
If API calls fail with authentication errors:
1. Check `UserDefaultsManager.shared.token` has valid session
2. Verify cookie being sent in `BaseService.getHeaders()`
3. Look for "UnAuthorizedAccess" notifications triggering logout
4. Use multipart endpoints with explicit headers if needed

### Freelance Dashboard State
The dashboard stores previous controller state to properly restore when dismissed:
- `freelanceDashboardPreviousController` - Previous navigation stack
- `freelanceDashboardPreviousTopBarHidden` - Top bar state
- `freelanceDashboardPreviousBottomBarHidden` - Bottom bar state
Use `dismissFreelanceDashboardController()` to properly restore state.

## Code Style Notes

### Naming Conventions
- View controllers: `{Feature}ViewController` (e.g., `HomeViewController`)
- View models: `{Entity}ViewModel` (e.g., `HomeViewModel`)
- Storyboard IDs: Match class names or use abbreviations (e.g., "HomeVC")
- Services: `{Feature}Service` with `shared()` singleton accessor

### File Organization
```
TheContractor/
├── Controllers/          # View controllers
├── View Models/          # Data models
├── Global/              # Utilities, constants, protocols
├── Base Classes/        # Reusable base components
├── StoryBoard/          # Storyboard files
├── MainContainer/       # Main navigation container
├── Library/
│   ├── Service/         # Network layer
│   └── Response Handler/
├── SwiftUI/
│   ├── Views/           # SwiftUI screens
│   ├── ViewModels/      # SwiftUI view models
│   └── Theme/           # Theme system
└── Third Party Vendors/ # Custom vendored dependencies
```

### Common Patterns
- Use `Global.shared` for app state
- Use `UserDefaultsManager.shared` for persistence
- Network calls: Background thread → Main thread for UI updates
- Loading states: `startActivity()` before, `stopActivity()` after
- Errors: Show alert with `showAlertView(message:)`
- Check connectivity: `checkInternetConnection()` before API calls
