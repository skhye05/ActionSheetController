Pod::Spec.new do |s|
  s.name = "ActionSheetController"
  s.version = "3.0.1"
  s.license = "MIT"
  s.summary = "ActionSheetController is an UIAlertController's APIs like ActionSheet control."
  s.homepage = "https://github.com/cuzv/ActionSheetController"
#  s.social_media_url = "https://twitter.com/mochxiao"
  s.author = { "Moch Xiao" => "cuzval@gmail.com" }
  s.source = { :git => "https://github.com/cuzv/ActionSheetController.git", :tag => s.version }

  s.ios.deployment_target = "8.0"
  s.source_files = "Sources/*.swift"
  s.requires_arc = true
  s.dependency "PresentAnimatedTransitioningController", "~> 3.0"
end
