#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pocketbase_server_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pocketbase_server_flutter'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.prepare_command = './prepare-iOS-SDK.sh'
  s.vendored_frameworks = 'pocketbase_ios/PocketbaseMobile.xcframework'
  s.preserve_paths = 'pocketbase_ios/PocketbaseMobile.xcframework'
end