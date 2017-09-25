Pod::Spec.new do |spec|
  spec.name                  = 'CloudAppSDK'
  spec.version               = '1.0'
  spec.summary               = 'CloudAppSDK is a 3rd party SDK for CloudApp that supports iOS & MacOS.'
  spec.description           = 'Supports all API features documented here http://developer.getcloudapp.com.'
  spec.homepage              = 'https://github.com/ParticleApps/CloudAppSDK'
  spec.license               = { :type => 'Apache License, Version 2.0' }
  spec.author                = { 'Rocco Del Priore' => 'rocco@particleapps.co' }
  spec.source                = { :git => 'https://github.com/ParticleApps/CloudAppSDK.git', :tag => "#{spec.version}" }
  spec.social_media_url      = 'https://twitter.com/ParticleAppsCo'
  spec.frameworks            = 'Foundation'
  spec.ios.deployment_target = '9.0'
  spec.osx.deployment_target = '10.8'
  spec.source_files          = "CloudAppSDK", "CloudApp\ SDK/**/*.{h,m}"
end
