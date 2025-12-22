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
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
