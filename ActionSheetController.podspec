Pod::Spec.new do |s|
  s.name = "ActionSheetController"
  s.version = "0.2.0"
  s.license = "MIT"
  s.summary = "ActionSheetController is an UIAlertController's APIs like ActionSheet control."
  s.homepage = "https://github.com/cuzv/ActionSheetController"
#  s.social_media_url = "https://twitter.com/mochxiao"
  s.author = { "Moch Xiao" => "cuzval@gmail.com" }
  s.source = { :git => "https://github.com/cuzv/ActionSheetController.git", :tag => s.version }

  s.ios.deployment_target = "8.0"
  s.source_files = "ActionSheetController/Sources/*.swift"
  s.requires_arc = true
end
