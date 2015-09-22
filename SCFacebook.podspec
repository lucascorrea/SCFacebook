#
#  Be sure to run `pod spec lint SCFacebook.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|


  s.name         = "SCFacebook"
  s.version      = "4.0"
  s.summary      = "The SCFacebook is a simpler and cleaner to use the api facebook-ios-sdk Objective-C "

  s.description  = <<-DESC
  The SCFacebook is a simpler and cleaner to use the api facebook-ios-sdk Objective-C (https://github.com/facebook/facebook-ios-sdk) to perform login, get friends list, information about the user and posting on the wall with ^Block for iPhone. 
  http://www.lucascorrea.com
                   DESC

  s.homepage     = "http://www.lucascorrea.com"
   s.license      = { :type => "MIT", :text => "SCFacebook is licensed under the MIT License" }

  s.author             = { "Lucas Correa" => "contato@lucascorrea.com" }
   s.platform     = :ios, "7.0"

  s.ios.deployment_target = "7.0"

  s.source       = { :git => "https://github.com/lucascorrea/SCFacebook.git", :tag => "4.0" }

  s.source_files  = "SCFacebook/**/*SCFacebook.{h,m}"

  s.requires_arc = true

  s.dependency "FBSDKCoreKit"
  s.dependency "FBSDKShareKit"
  s.dependency "FBSDKLoginKit"

end
