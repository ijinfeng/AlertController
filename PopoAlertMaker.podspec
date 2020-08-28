#
#  Be sure to run `pod spec lint IAAlertMaker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "PopoAlertMaker"
  spec.version      = "1.2.0"
  spec.summary      = "轻量级弹框创建工具"
  spec.description  = "链式alert、sheet以及自定义轻量级弹框创建"
  spec.homepage     = "https://github.com/CranzCapatain/AlertController"
  spec.author    = "JinFeng"
  #spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.platform     = :ios, "7.0"
  spec.source       = { :git => "https://github.com/CranzCapatain/AlertController.git", :tag => "#{spec.version}" }
  spec.source_files  = "PopoAlertController/AlertController/*.{h,m}"
  spec.requires_arc = true

end
