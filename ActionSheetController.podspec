Pod::Spec.new do |s|
  s.name = 'ActionSheetController'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'A short description of ActionSheetController.'
  s.homepage = 'https://github.com/cuzv/ActionSheetController'
#  s.social_media_url = 'https://twitter.com/moxhxiao'
  s.author = { "Moch Xiao" => "cuzval@gmail.com" }
  s.source = { :git => 'https://github.com/cuzv/ActionSheetController.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.source_files = 'ActionSheetController/Sources/*.swift'
  s.requires_arc = true
end
