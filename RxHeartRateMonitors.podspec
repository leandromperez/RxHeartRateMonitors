#
# Be sure to run `pod lib lint RxHeartRateMonitors.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxHeartRateMonitors'
  s.version          = '0.1.0'
  s.summary          = 'RxHeartRateMonitors is a lightweight layer on top of RxBluetoothKit and Core Bluetooth to interact with BTLE Heart Rate Monitors.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
It leverages the power of RxBluetoothKit and Corebluetooth to allow you to communicate with monitors in a seamless way.
* Connect to BTLE heart rate monitors avoiding the complexities of CoreBluetooth.
* No need to parse raw data, it does it for you.
* No need to care about services and characteristics.
* Extensible. If you want to connect to other types of devices, like speedometers, you can create your own central.

                       DESC

  s.homepage         = 'https://github.com/leandromperez/RxHeartRateMonitors'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Leandro Perez' => 'leandromperez@gmail.com' }
  s.source           = { :git => 'https://github.com/leandromperez/RxHeartRateMonitors.git', :tag => s.version.to_s }
  s.social_media_url = 'https://medium.com/@leandromperez'

  s.ios.deployment_target = '10.0'

  s.source_files = 'RxHeartRateMonitors/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RxHeartRateMonitors' => ['RxHeartRateMonitors/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'RxSwift'
    s.dependency 'RxBluetoothKit'
    s.dependency 'SwiftyUserDefaults'
    s.dependency 'RxSwiftExt'
    s.dependency 'RxCocoa'
end
