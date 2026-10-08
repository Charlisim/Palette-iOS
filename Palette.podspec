Pod::Spec.new do |s|
  s.name = "Palette"
  s.version = "2.0.0"
  s.summary = "Choose black or white text for UIKit backgrounds using WCAG contrast."
  s.description = "A main-actor-isolated UIKit library with safe sRGB pixel sampling, dynamic color support, and Swift and Objective-C APIs."
  s.homepage = "https://github.com/Charlisim/Palette-iOS"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Carlos Simon Villas" => "csimonts@gmail.com" }
  s.source = { :git => "https://github.com/Charlisim/Palette-iOS.git", :tag => s.version.to_s }
  s.ios.deployment_target = "15.0"
  s.swift_version = "6.0"
  s.source_files = "Palette/*.{h,swift}"
  s.public_header_files = "Palette/Palette-iOS.h"
  s.frameworks = "UIKit"
end
