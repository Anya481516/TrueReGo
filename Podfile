platform :ios, '9.0'

target 'ReGo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ReGo
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Kingfisher'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end
