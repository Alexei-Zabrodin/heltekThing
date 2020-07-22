platform :ios, '8.0'
 
inhibit_all_warnings!
use_frameworks!
 
target ‘heltecThing’ do
  #pod 'PromiseKit/Foundation', "~> 4"
  #pod 'SwiftyJSON', "~> 3"
  #pod 'Alamofire', '~> 3'
  #   pod 'Moya', '~> 8.0'
  pod 'RestEssentials', '~> 3'
  pod 'IQKeyboardManagerSwift', '~> 5'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'PromiseKit'
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
    
    if target.name == 'Alamofire'
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
    
    if target.name == 'Moya'
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
    
    if target.name == 'IQKeyboardManagerSwift'
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
    
  end
end
