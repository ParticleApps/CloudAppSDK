Pod::Spec.new do |s|
  s.name             = 'CloudAppSDK'
  s.version          = '0.1.0'
  s.summary          = 'CloudAppSDK is a 3rd party SDK for CloudApp that supports iOS & MacOS.'
  s.description      = 'Supports all API features documented here http://developer.getcloudapp.com. Eventually this description will be copied from the README.'
  s.homepage         = 'https://particleapps.co/' #TODO: Change this to CloudAppSDK Specific URL
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache License, Version 2.0' }
  s.author           = { 'Rocco Del Priore' => 'rocco@particleapps.co' }
  s.source           = { :git => 'https://github.com/Frostbitee08/dotfiles.git', :tag => '0.1.0' } #Change this when it is hosted on the particleapps account
  s.social_media_url = 'https://twitter.com/ParticleAppsCo'
  s.ios.deployment_target = '9.0'
  s.source_files  = "CloudAppSDK", "CloudApp\ SDK/**/*.{h,m}"
end
