#
# Be sure to run `pod lib lint MokoLifeX.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MokoLifeX'
  s.version          = '1.0.1'
  s.summary          = 'A short description of MokoLifeX.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/MokoLifeX/MokoLifeX_iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'aadyx2007@163.com' => 'aadyx2007@163.com' }
  s.source           = { :git => 'https://github.com/MokoLifeX/MokoLifeX_iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'MokoLifeX/Classes/**/*'
  
  s.resource_bundles = {
    'MokoLifeX' => ['MokoLifeX/Assets/*.*']
  }
  
  s.subspec 'ApplicationModule' do |ss|
    ss.source_files = 'MokoLifeX/Classes/ApplicationModule/**'
  end
  
  s.subspec 'CTMediator' do |ss|
    ss.source_files = 'MokoLifeX/Classes/CTMediator/**'
      
    ss.dependency 'CTMediator'
    
    ss.dependency 'MokoLifeX/DeviceModel'
  end
  
  s.subspec 'Target' do |ss|
    ss.source_files = 'MokoLifeX/Classes/Target/**'
  end
  
  s.subspec 'SDK' do |ss|
    ss.subspec 'Socket' do |sss|
      sss.source_files = 'MokoLifeX/Classes/SDK/Socket/**'
      
      sss.dependency 'CocoaAsyncSocket'
    end
    
    ss.subspec 'MQTT' do |sss|
      sss.source_files = 'MokoLifeX/Classes/SDK/MQTT/**'
      
      sss.dependency 'MKBaseMQTTModule'
    end
  end
  
  s.subspec 'DeviceModel' do |ss|
    ss.source_files = 'MokoLifeX/Classes/DeviceModel/**'
        
    ss.dependency 'MokoLifeX/SDK/MQTT'
  end
  
  s.subspec 'Expand' do |ss|
    
    ss.subspec 'Cell' do |sss|
      sss.subspec 'PowerOnStatusCell' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Expand/Cell/PowerOnStatusCell/**'
      end
    end
    
    ss.subspec 'DatabaseManager' do |sss|
      sss.source_files = 'MokoLifeX/Classes/Expand/DatabaseManager/**'
      
      sss.dependency 'FMDB'
      
      sss.dependency 'MokoLifeX/DeviceModel'
    end
    
    ss.subspec 'View' do |sss|
        
        sss.subspec 'CountdownPickerView' do |ssss|
          ssss.source_files = 'MokoLifeX/Classes/Expand/View/CountdownPickerView/**'
        end
        
        sss.subspec 'EnergyViews' do |ssss|
          ssss.source_files = 'MokoLifeX/Classes/Expand/View/EnergyViews/**'
        end
        
    end
    
    ss.subspec 'Controller' do |sss|
      
      sss.subspec 'BaseController' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Expand/Controller/BaseController/**'
      end
      
      sss.subspec '1110X' do |ssss|
        
        ssss.subspec 'DeviceInfoPage' do |sssss|
          sssss.subspec 'Controller' do |ssssss|
            ssssss.source_files = 'MokoLifeX/Classes/Expand/Controller/1110X/DeviceInfoPage/Controller/**'
            
            ssssss.dependency 'MokoLifeX/Expand/Controller/BaseController'
            
            ssssss.dependency 'MokoLifeX/Expand/Controller/1110X/DeviceInfoPage/Protocol'
          end
          sssss.subspec 'Protocol' do |ssssss|
            ssssss.source_files = 'MokoLifeX/Classes/Expand/Controller/1110X/DeviceInfoPage/Protocol/**'
          end
        end
        
        ssss.subspec 'PowerOnStatusPage' do |sssss|
          sssss.subspec 'Controller' do |ssssss|
            ssssss.source_files = 'MokoLifeX/Classes/Expand/Controller/1110X/PowerOnStatusPage/Controller/**'
            
            ssssss.dependency 'MokoLifeX/Expand/Cell/PowerOnStatusCell'
            
            ssssss.dependency 'MokoLifeX/Expand/Controller/BaseController'
            
            ssssss.dependency 'MokoLifeX/Expand/Controller/1110X/PowerOnStatusPage/Protocol'
          end
          sssss.subspec 'Protocol' do |ssssss|
            ssssss.source_files = 'MokoLifeX/Classes/Expand/Controller/1110X/PowerOnStatusPage/Protocol/**'
          end
          
        end
        
        ssss.subspec 'ElectricityPage' do |sssss|
          sssss.subspec 'Controller' do |ssssss|
            ssssss.source_files = 'MokoLifeX/Classes/Expand/Controller/1110X/ElectricityPage/Controller/**'
                        
            ssssss.dependency 'MokoLifeX/Expand/Controller/BaseController'
          end
        end
      end
      
      sss.subspec 'Common' do |ssss|
        
        ssss.subspec 'SaveDevice' do |sssss|
          sssss.subspec 'Controller' do |ssssss|
            ssssss.source_files = 'MokoLifeX/Classes/Expand/Controller/Common/SaveDevice/Controller/**'
                        
            ssssss.dependency 'MokoLifeX/Expand/DatabaseManager'
            
            ssssss.dependency 'MokoLifeX/Expand/Controller/BaseController'
          end
        end
        
        ssss.subspec 'UpdatePage' do |sssss|
          sssss.subspec 'Controller' do |ssssss|
            ssssss.source_files = 'MokoLifeX/Classes/Expand/Controller/Common/UpdatePage/Controller/**'
            
            ssssss.dependency 'MokoLifeX/Expand/Controller/BaseController'
            
            ssssss.dependency 'MokoLifeX/Expand/Controller/Common/UpdatePage/Protocol'
            ssssss.dependency 'MokoLifeX/Expand/Controller/Common/UpdatePage/Model'
          end
          sssss.subspec 'Model' do |ssssss|
            ssssss.source_files = 'MokoLifeX/Classes/Expand/Controller/Common/UpdatePage/Model/**'
          end
          sssss.subspec 'Protocol' do |ssssss|
            ssssss.source_files = 'MokoLifeX/Classes/Expand/Controller/Common/UpdatePage/Protocol/**'
          end
        end
        
      end
        
      sss.dependency 'MokoLifeX/DeviceModel'
      
    end
    
  end
  
  s.subspec 'Functions' do |ss|
    
    ss.subspec 'LifeX' do |sss|
      
      sss.subspec 'MQTT' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/MQTT/**'
      end
      
      sss.subspec 'Functions' do |ssss|
        
        ssss.subspec 'AddDevicePage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/Functions/AddDevicePage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/LifeX/Functions/OperationStepsPage/Controller'
              
              ssssss.dependency 'MokoLifeX/Functions/LifeX/Functions/AddDevicePage/View'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/Functions/AddDevicePage/View/**'
            end
        end
        
        ssss.subspec 'DeviceListPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/Functions/DeviceListPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/LifeX/Functions/AddDevicePage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/LifeX/Functions/ServerForAPP/Controller'
              
              ssssss.dependency 'MokoLifeX/Functions/LifeX/Functions/DeviceListPage/View'
              ssssss.dependency 'MokoLifeX/Functions/LifeX/Functions/DeviceListPage/Model'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/Functions/DeviceListPage/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/Functions/DeviceListPage/View/**'
            end
        end
        
        ssss.subspec 'OperationStepsPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/Functions/OperationStepsPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/LifeX/Functions/OperationStepsPage/View'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/Functions/OperationStepsPage/View/**'
            end
        end
        
        ssss.subspec 'ServerForAPP' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/Functions/ServerForAPP/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/LifeX/Functions/ServerForAPP/View'
              ssssss.dependency 'MokoLifeX/Functions/LifeX/Functions/ServerForAPP/Model'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/Functions/ServerForAPP/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/LifeX/Functions/ServerForAPP/View/**'
            end
        end
        
        ssss.dependency 'MokoLifeX/Functions/LifeX/MQTT'
        
      end
      
    end
    
    ss.subspec 'MK10X' do |sss|
      
      sss.subspec 'MQTT' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Functions/MK10X/MQTT/**'
      end
      
      sss.subspec 'Socket' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Functions/MK10X/Socket/**'
      end
      
      sss.subspec 'Target' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Functions/MK10X/Target/**'
        
        ssss.dependency 'MokoLifeX/Functions/MK10X/Functions/ServerForDevice/Controller'
        ssss.dependency 'MokoLifeX/Functions/MK10X/Functions/SwitchStatePage/Controller'
      end
      
      sss.subspec 'Functions' do |ssss|
        
        ssss.subspec 'MorePage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK10X/Functions/MorePage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK10X/Functions/MorePage/Model'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK10X/Functions/MorePage/Model/**'
            end
        end
        
        ssss.subspec 'ServerForDevice' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK10X/Functions/ServerForDevice/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK10X/Functions/ServerForDevice/Model'
              ssssss.dependency 'MokoLifeX/Functions/MK10X/Functions/ServerForDevice/View'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK10X/Functions/ServerForDevice/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK10X/Functions/ServerForDevice/View/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK10X/Functions/ServerForDevice/Model'
            end
        end
        
        ssss.subspec 'SwitchStatePage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK10X/Functions/SwitchStatePage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK10X/Functions/MorePage/Controller'
              
              ssssss.dependency 'MokoLifeX/Functions/MK10X/Functions/SwitchStatePage/View'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK10X/Functions/SwitchStatePage/View/**'
            end
        end
      
        ssss.dependency 'MokoLifeX/Functions/MK10X/MQTT'
        ssss.dependency 'MokoLifeX/Functions/MK10X/Socket'
      end
    
    end
    
    ss.subspec 'MK11X' do |sss|
      
      sss.subspec 'MQTT' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/MQTT/**'
      end
      
      sss.subspec 'Socket' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Socket/**'
      end
      
      sss.subspec 'Target' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Target/**'
        
        ssss.dependency 'MokoLifeX/Functions/MK11X/Functions/ServerForDevice/Controller'
        ssss.dependency 'MokoLifeX/Functions/MK11X/Functions/SwitchStatePage/Controller'
      end
      
      sss.subspec 'Functions' do |ssss|
        
        ssss.subspec 'ColorSettingPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/ColorSettingPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/ColorSettingPage/Model'
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/ColorSettingPage/View'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/ColorSettingPage/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/ColorSettingPage/View/**'
            end
        end
        
        ssss.subspec 'ConfigDataPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/ConfigDataPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/ConfigDataPage/View'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/ConfigDataPage/View/**'
            end
        end
        
        ssss.subspec 'EnergyPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/EnergyPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/EnergyPage/Model'
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/EnergyPage/View'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/EnergyPage/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/EnergyPage/View/**'
            end
        end
        
        ssss.subspec 'MorePage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/MorePage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/MorePage/Model'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/MorePage/Model/**'
            end
        end
        
        ssss.subspec 'ServerForDevice' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/ServerForDevice/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/ServerForDevice/Model'
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/ServerForDevice/View'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/ServerForDevice/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/ServerForDevice/View/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/ServerForDevice/Model'
            end
        end
        
        ssss.subspec 'SettingsPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/SettingsPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/ConfigDataPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/ColorSettingPage/Controller'
              
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/SettingsPage/View'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/SettingsPage/View/**'
            end
        end
        
        ssss.subspec 'SwitchStatePage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/SwitchStatePage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/MorePage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/SettingsPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/EnergyPage/Controller'
              
              ssssss.dependency 'MokoLifeX/Functions/MK11X/Functions/SwitchStatePage/View'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK11X/Functions/SwitchStatePage/View/**'
            end
        end
          
        ssss.dependency 'MokoLifeX/Functions/MK11X/MQTT'
        ssss.dependency 'MokoLifeX/Functions/MK11X/Socket'
      end
    
    end
    
    ss.subspec 'MK117' do |sss|
      
      sss.subspec 'MQTT' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Functions/MK117/MQTT/**'
      end
      
      sss.subspec 'Socket' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Socket/**'
      end
      
      sss.subspec 'Target' do |ssss|
        ssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Target/**'
        
        ssss.dependency 'MokoLifeX/Functions/MK117/Functions/ServerForDevice/Controller'
        ssss.dependency 'MokoLifeX/Functions/MK117/Functions/SwitchStatePage/Controller'
      end
      
      sss.subspec 'Expand' do |ssss|
        
        ssss.subspec 'BaseController' do |sssss|
          sssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Expand/BaseController/**'
          
          sssss.dependency 'MokoLifeX/Functions/MK117/MQTT'
        end
        
      end
      
      sss.subspec 'Functions' do |ssss|
        
        ssss.subspec 'ColorSettingPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/ColorSettingPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/ColorSettingPage/Model'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/ColorSettingPage/View'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/ColorSettingPage/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/ColorSettingPage/View/**'
            end
        end
        
        ssss.subspec 'ConnectionPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/ConnectionPage/Controller/**'
            end
        end
        
        ssss.subspec 'DeviceInfoPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/DeviceInfoPage/Controller/**'
            end
        end
        
        ssss.subspec 'ElectricityPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/ElectricityPage/Controller/**'
            end
        end
        
        ssss.subspec 'EnergyPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/EnergyPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/EnergyPage/Model'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/EnergyPage/View'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/EnergyPage/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/EnergyPage/View/**'
            end
        end
        
        ssss.subspec 'EnergyReportPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/EnergyReportPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/EnergyReportPage/Model'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/EnergyReportPage/View'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/EnergyReportPage/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/EnergyReportPage/View/**'
            end
        end
        
        ssss.subspec 'LEDSettingPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/LEDSettingPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/ColorSettingPage/Controller'
            end
        end
        
        ssss.subspec 'LoadStatusPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/LoadStatusPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/LoadStatusPage/Model'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/LoadStatusPage/Model/**'
            end
        end
        
        ssss.subspec 'MQTTSettingForDevicePage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/MQTTSettingForDevicePage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/MQTTSettingForDevicePage/View'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/MQTTSettingForDevicePage/View/**'
            end
        end
        
        ssss.subspec 'NTPConfigPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/NTPConfigPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/NTPConfigPage/Model'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/NTPConfigPage/Model/**'
            end
        end
        
        ssss.subspec 'OverThresholdPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/OverThresholdPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/OverThresholdPage/Model'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/OverThresholdPage/View'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/OverThresholdPage/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/OverThresholdPage/View/**'
            end
        end
        
        ssss.subspec 'PowerOnStatusPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/PowerOnStatusPage/Controller/**'
            end
        end
        
        ssss.subspec 'PowerReportPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/PowerReportPage/Controller/**'
            end
        end
        
        ssss.subspec 'ProtectionSettingPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/ProtectionSettingPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/OverThresholdPage/Controller'
            end
        end
        
        ssss.subspec 'ServerForDevice' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/ServerForDevice/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/ServerForDevice/Model'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/ServerForDevice/View'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/ServerForDevice/Model/**'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/ServerForDevice/View/**'
            end
        end
        
        ssss.subspec 'SettingsPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/SettingsPage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/PowerOnStatusPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/LEDSettingPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/DeviceInfoPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/StatusReportPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/PowerReportPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/EnergyReportPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/ConnectionPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/LoadStatusPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/ProtectionSettingPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/MQTTSettingForDevicePage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/SystemTimePage/Controller'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/SettingsPage/Model'
            end
            sssss.subspec 'Model' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/SettingsPage/Model/**'
            end
        end
        
        ssss.subspec 'StatusReportPage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/StatusReportPage/Controller/**'
            end
        end
        
        ssss.subspec 'SwitchStatePage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/SwitchStatePage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/ElectricityPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/SettingsPage/Controller'
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/EnergyPage/Controller'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/SwitchStatePage/View'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/SwitchStatePage/View/**'
            end
        end
        
        ssss.subspec 'SystemTimePage' do |sssss|
            sssss.subspec 'Controller' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/SystemTimePage/Controller/**'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/NTPConfigPage/Controller'
              
              ssssss.dependency 'MokoLifeX/Functions/MK117/Functions/SystemTimePage/View'
            end
            sssss.subspec 'View' do |ssssss|
              ssssss.source_files = 'MokoLifeX/Classes/Functions/MK117/Functions/SystemTimePage/View/**'
            end
        end
        
        ssss.dependency 'MokoLifeX/Functions/MK117/Expand'
        ssss.dependency 'MokoLifeX/Functions/MK117/MQTT'
        ssss.dependency 'MokoLifeX/Functions/MK117/Socket'
      end
    
    
    end
    
    
    ss.dependency 'MokoLifeX/DeviceModel'
    ss.dependency 'MokoLifeX/Expand'
    ss.dependency 'MokoLifeX/SDK'
    ss.dependency 'MokoLifeX/CTMediator'
  end

  s.dependency 'MKBaseModuleLibrary'
  s.dependency 'MKCustomUIModule'
  
  s.dependency 'MLInputDodger'
  s.dependency 'FLAnimatedImage'
  
  
end
