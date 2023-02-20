Pod::Spec.new do |s|
  s.name = 'AvantisSwapSDK'
  s.version = '1.0.9'
  s.license = 'MIT'
  s.summary = 'Avantis Swap SDK for Swift'
  s.homepage = 'https://github.com/ava-global/avantisswap-sdk-swift'
  s.authors = { 'Peerasak Unsakon' => 'peerasak.u@ava.fund' }
  s.source = { :git => 'https://github.com/ava-global/avantisswap-sdk-swift.git', :tag => s.version.to_s }
  s.module_name = 'AvantisSwapSDK'

  s.swift_version = '5.5'
  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/AvantisSwapSDK/**/*.swift', 'Libraries/**/*.{c,h,swift}'
  s.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS[sdk=iphonesimulator*]' => '$(inherited) $(PODS_TARGET_SRCROOT)/Libraries/**',
    'SWIFT_INCLUDE_PATHS[sdk=iphoneos*]' => '$(inherited) $(PODS_TARGET_SRCROOT)/Libraries/**'
  }
  s.preserve_paths = 'Libraries/**/module.map'
  s.dependency 'BigInt', '~> 5.0.0'
end
