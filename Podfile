post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end

platform :ios,'9.0'
inhibit_all_warnings!

target 'MokoLifeX' do

pod 'mokoLibrary', :git => 'git@120.27.8.241:mokoBaseLibrary/mokoLibrary.git'
pod 'AFNetworking'
pod 'CocoaAsyncSocket'
pod 'MQTTClient','0.14.0'
pod 'MLInputDodger'
pod 'FLAnimatedImage'
pod 'FMDB'

end
