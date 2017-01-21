#
#  Be sure to run `pod spec lint Cocore.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.name         = "Cocore"
  s.version      = "0.0.25"
  s.summary      = "A short description of Cocore."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  This is a description for Cocore
                   DESC

  s.homepage     = "https://bitbucket.org/shashlov/cocore"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "Dmitry Shashlov" => "shashlov@gmail.com" }
  # Or just: s.author    = "Dmitry Shashlov"
  # s.authors            = { "Dmitry Shashlov" => "shashlov@gmail.com" }
  # s.social_media_url   = "http://twitter.com/Dmitry Shashlov"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "https://shashlov@bitbucket.org/shashlov/cocore.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "Cocore/Source/**/*.{swift}"
  # s.exclude_files = "Cocore/Source/Crashlytics/*.{swift}" # TODO

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  s.resource_bundles = {
    'Cocore' => [ 'Cocore/Resources/**/*.xib', 'Cocore/Resources/Assets.xcassets' ]
  }

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  s.framework  = "UIKit"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

  s.vendored_frameworks = "Cocore/Vendor/Crashlytics.framework", "Cocore/Vendor/Fabric.framework", "Cocore/Vendor/OneSignal.framework", "Cocore/Vendor/UXCam.framework"
  s.preserve_paths = 'Cocore/Vendor/*.framework'
  s.resource = "Cocore/Vendor/Crashlytics.framework", "Cocore/Vendor/Fabric.framework", "Cocore/Vendor/OneSignal.framework", "Cocore/Vendor/UXCam.framework"
  s.xcconfig = { 'LD_RUNPATH_SEARCH_PATHS' => '"$(PODS_ROOT)/Cocore/Cocore/Vendor"', 'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/Cocore/Cocore/Vendor/Crashlytics.framework/Headers", "$(PODS_ROOT)/Cocore/Cocore/Vendor/Fabric.framework/Headers", "$(PODS_ROOT)/Cocore/Cocore/Vendor/OneSignal.framework/Headers", "$(PODS_ROOT)/Cocore/Cocore/Vendor/UXCam.framework/Headers"'}

  # Defaults subspecs
  # s.default_subspecs = 'Core', 'Navigation', 'Logging'
  s.default_subspecs = 'Core', 'Navigation', 'Logging', 'UINotifications', 'HTMLUtils'

  # Default subspecs
  ###################################################################
  
  # Main application core
  #   > Cocore/Core
  s.subspec 'Core' do |ss|
    ss.dependency 'Alamofire', '3.1.4'
    ss.dependency 'RealmSwift', '0.98.6'
    ss.dependency 'ReactiveCocoa', '4.0.4-alpha-4'
    ss.dependency 'ObjectMapper', '1.1.1'
    ss.dependency 'AlamofireObjectMapper', '2.1.0'
    ss.dependency 'Reachability'
    ss.dependency 'DeepLinkKit'
  end
  
  # State machine (own GitHub fork with updates)
  #   > Cocore/Navigation
  s.subspec 'Navigation' do |ss|
    ss.dependency 'SwiftState', '4.1.0-cocore'
  end

  # Logging
  #   > Cocore/Logging
  s.subspec 'Logging' do |ss|
    ss.dependency 'CocoaLumberjack/Swift', '~> 2.2.0'
    ss.dependency 'PaperTrailLumberjack', '2.0.0-cocore'
    ss.dependency 'CocoaAsyncSocket', '7.4.3'
    ss.dependency 'Raven'
  end
  
  # Optional subspecs
  ###################################################################
  
  # Used in TaskService.swift and LocalTaskPerformController.swift
  #   > Cocore/Cloudinary
  s.subspec 'Cloudinary' do |ss|
    ss.dependency 'Cloudinary'
  end
  
  # Modal onscreen progress notifier 
  #   > Cocore/UINotifications
  s.subspec 'UINotifications' do |ss|

    ss.dependency 'ARSLineProgress', '1.2.1-cocore'
    
    # Used in StatusBarNotifier.swift
    ss.dependency 'JDStatusBarNotification', '1.5.4'

  end
  
  # Used in StrintUtils.swift for rendering HTML inside UILabel
  #   > Cocore/HTMLUtils
  s.subspec 'HTMLUtils' do |ss|
    ss.dependency 'TTTAttributedLabel'
  end
  
  # Used for TwitterAuthorization
  #   > Cocore/OAuth
  s.subspec 'OAuth' do |ss|
    ss.dependency 'OAuthSwift-Alamofire', '0.0.2-cocore'
  end
  
  # Used in ViewModels
  #   > Cocore/TimeUtils
  s.subspec 'TimeUtils' do |ss| 

    ss.dependency 'DateTools'
    
    # Used for NSTimer.after(..) calls, mostly for navigation
    ss.dependency 'SwiftyTimer', '1.4.1'

  end

  #   > Cocore/FAQ
  s.subspec 'FAQ' do |ss|
    ss.dependency 'Helpshift', '5.8.0'
  end

end
