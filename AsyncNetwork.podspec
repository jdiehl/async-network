#
# Be sure to run `pod lib lint AsyncNetwork.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AsyncNetwork"
  s.version          = "1.1"
  s.summary          = "Cocoa and iOS Socket Networking Evolved. "
  s.description      = <<-DESC
                       Async Network is a framework for socket networking on Cocoa or Cocoa Touch based on [AsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket).
                       DESC
  s.homepage         = "http://jdiehl.github.com/async-network"
  s.license          = 'MIT'
  s.author           = 'Jonathan Diehl'
  s.source           = { :git => "https://github.com/jdiehl/async-network.git", :tag => s.version.to_s }

  s.osx.platform     = :osx, '10.7'
  s.ios.platform     = :ios, '6.0'
  s.ios.deployment_target = "6.0"
  s.osx.deployment_target = "10.7"
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.ios.frameworks = 'Foundation', 'Security', 'CFNetwork'
  s.osx.frameworks = 'Foundation', 'CFNetwork'
  s.dependency 'CocoaAsyncSocket'
end
