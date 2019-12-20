# Uncomment the next line to define a global platform for your project
platform :ios, '13.2'

target 'GMapsTest' do
  # Comment the next line if you don't want to use dynamic frameworks
  #use_frameworks!

  pod 'Alamofire', '~> 5.0.0-rc.3'
  pod 'GoogleMaps'
  pod 'Google-Maps-iOS-Utils'

  target 'GMapsTestTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

plugin 'cocoapods-keys', {
  :project => "GMapsTest",
  :keys => [
    "GMapsTestKey"
  ]}
  