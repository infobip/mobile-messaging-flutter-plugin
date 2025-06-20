#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint infobip_mobilemessaging.podspec` to validate before publishing.
#

require 'yaml'

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')
mmVersion = "13.6.1"

Pod::Spec.new do |s|
  s.name             = 'infobip_mobilemessaging'
  s.version          = library_version
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
  s.dependency "MobileMessaging/Core", mmVersion
  s.dependency "MobileMessaging/InAppChat", mmVersion
  s.dependency "MobileMessaging/Inbox", mmVersion
  if defined?($WebRTCUIEnabled)
    s.dependency "MobileMessaging/WebRTCUI", mmVersion
  end
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
