platform :ios, '14.0'
use_frameworks!

target 'AzureCalling' do

pod 'AzureCommunicationUICalling', '1.4.0'
pod 'MicrosoftFluentUI/Notification_ios', '0.10.0'
pod 'MicrosoftFluentUI/SegmentedControl_ios', '0.10.0'
pod 'MSAL', '1.2.2'
pod 'SwiftLint', '0.42.0'

end


post_install do |installer|
  xcode_base_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}' | cut -d . -f 1`
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # For xcode 15+ only
      if config.base_configuration_reference && Integer(xcode_base_version) >= 15
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
    end
  end
end
