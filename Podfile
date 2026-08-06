platform :ios, '15.0'

target 'TheContractor' do
  use_frameworks!

  pod 'MBProgressHUD'
  pod 'SwiftyJSON'
  pod 'Alamofire'
  pod 'SDWebImage'
  pod 'IQKeyboardManagerSwift'
  pod 'Cosmos'
  pod 'iOSDropDown'
  pod 'XNLogger'

  # Firebase. Android has auth, messaging, firestore, database and analytics; chat is Firestore
  # (collections `user_connections` and `chat`), the SMS code on sign-up is Auth phone verification, and
  # `firebase_token` on login/register is a Messaging registration token. Realtime Database and
  # Analytics are not pulled in: nothing in the Android chat path uses Database beyond a ServerValue
  # import, and Analytics has no parity requirement.
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Messaging'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
