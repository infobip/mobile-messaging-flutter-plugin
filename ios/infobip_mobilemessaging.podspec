#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint infobip_mobilemessaging.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'infobip_mobilemessaging'
  s.version          = '0.0.1'
  s.summary          = 'Infobip Mobile Messaging Flutter Plugin.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://infobip.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Infobip Mobile Messaging Team' => 'Team_Mobile_Messaging@infobip.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency "MobileMessaging/Core", "9.2.11"
  s.dependency "MobileMessaging/Geofencing", "9.2.11"
  s.dependency "MobileMessaging/InAppChat", "9.2.11"

  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
