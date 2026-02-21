# TheContractor (المقاول) - iOS Application

## Overview
TheContractor is an iOS application that connects users with construction service providers, freelancers, and companies in the UAE. It serves as a platform for:
- Connecting customers with contractors, service providers, and freelancers
- Enabling companies to hire freelancers
- Helping freelancers find work opportunities
- Managing quotes, enquiries, and service requests

## Architecture

### App Structure
The app follows a hybrid architecture combining:
- UIKit with Storyboard-based UI for main navigation and legacy screens
- SwiftUI for newer features and freelancer-related functionality
- MVVM (Model-View-ViewModel) design pattern

### Key Directories
- **Controllers/**: UIKit view controllers
- **SwiftUI/**: SwiftUI views and view models
- **View Models/**: Data presentation logic
- **Global/**: App constants, utilities, and extensions
- **Library/**: Networking and service classes
- **StoryBoard/**: UIKit interface layouts
- **Third Party Vendors/**: External libraries and components

## Core Features

### User Roles
1. **Regular Users**: Can browse contractors, submit inquiries, and receive quotations
2. **Companies**: Can find and hire freelancers, manage projects
3. **Freelancers**: Can offer services, receive work requests, manage availability

### Key Functionality
- **Company Finder**: Search and browse local contractors
- **Freelancer Marketplace**: List, search, and hire freelancers
- **Freelancer Dashboard**: For freelancers to manage their services and orders
- **Enquiries Management**: Submit and track service requests
- **Quotation System**: Receive and manage service quotes
- **Estimation Tools**: Calculate project estimates
- **24/7 Companies**: Find emergency service providers
- **Workshop Management**: For specialized service providers
- **User Profiles**: Management of personal and company information

### Authentication
- Phone number verification with OTP
- Email/password login
- Separate login flows for regular users and companies

### Networking
- RESTful API integration with base URL: `https://contractor.bidcont.com/rest/`
- API calls handled through custom service classes
- Session management via cookies

## User Interface

### Design Elements
- Custom navigation and tab-based UI
- Card-based listing of contractors and freelancers
- Search functionality with filters
- Star-based rating system
- Modern UI with custom styling
- Arabic language support

### SwiftUI Components
- Freelancer listing and selection views
- Freelancer dashboard
- Checkout flow for hiring freelancers
- Search filters for freelancer discovery
- Company login portal

### Key Screens
1. **Home**: Categories and featured services
2. **Companies List**: Browse available contractors
3. **Company Details**: Service provider information
4. **Freelancers**: Browse available freelancers
5. **Freelancer Dashboard**: Work management for freelancers
6. **Login/Registration**: User authentication
7. **Profile**: User information management
8. **Side Menu**: App navigation

## Technical Details

### iOS Requirements
- iOS 15.0+
- Swift 5.x
- XCode 13+

### Dependencies
- **MBProgressHUD**: Loading indicators
- **SwiftyJSON**: JSON parsing
- **Alamofire**: Networking
- **SDWebImage**: Image loading and caching
- **IQKeyboardManagerSwift**: Keyboard management
- **Cosmos**: Rating control
- **iOSDropDown**: Dropdown UI element

### Data Management
- User defaults for basic data persistence
- API-based data retrieval and submission
- Session management with cookies

### Device Compatibility
- iPhone (iOS 15.0+)
- iPad support with adaptive layouts

## Future Enhancements
To match the Android version, further development should focus on:
- Complete feature parity with Android
- Enhanced offline capabilities
- Push notifications for new orders and messages
- Enhanced localization for Arabic
- Real-time chat functionality

## Development Practices
- Git version control for change management
- Modular architecture for maintainability
- Hybrid UI approach combining UIKit and SwiftUI
- MVVM pattern for separation of concerns
