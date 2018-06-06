Pod::Spec.new do |s|

  s.name         = "MGMovableVideoView"
  s.version      = "0.0.1"
  s.summary      = "A short description of MGMovableVideoView."

  s.description  = <<-DESC
                   DESC

  s.homepage     = "http://EXAMPLE/MGMovableVideoView"

  s.license      = "MIT (example)"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "water" => "crazydennies@gmail.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "http://EXAMPLE/MGMovableVideoView.git", :tag => "#{s.version}" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.framework  = "UIKit"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.dependency "JSONKit", "~> 1.4"
  s.dependency 'MGViewsSwift'

end
