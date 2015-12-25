Pod::Spec.new do |s|
  s.name             = "AsyncNetwork"
  s.version          = "1.1.1"
  s.summary          = "Simple Socket Networking"
  s.description      = "iOS / Cocoa Framework for socket networking based on CocoaAsyncSocket"
  s.homepage         = "https://github.com/jdiehl/async-network"
  s.license          = 'MIT'
  s.author           = "Jonathan Diehl"
  s.source           = { :git => "https://github.com/jdiehl/async-network.git", :tag => s.version.to_s }
  s.requires_arc     = true
  s.source_files     = 'AsyncNetwork'
  s.osx.frameworks        = 'CFNetwork', 'Security'
  s.osx.deployment_target = '10.7'
  s.ios.frameworks        = 'CFNetwork', 'Security'
  s.ios.deployment_target = '5.0'
  s.dependency 'CocoaAsyncSocket'
end
