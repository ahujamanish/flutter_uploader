#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_uploader'
  s.version          = '0.0.1'
  s.summary          = 'A plugin to create and manage background upload tasks'
  s.description      = <<-DESC
A plugin to create and manage background upload tasks
                       DESC
  s.homepage         = 'https://github.com/BlueChilli/flutter_uploader.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'BlueChilli' => 'max@bluechilli.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.dependency 'Flutter'
  s.dependency 'SQLite.swift', '0.12.0'
  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
end

