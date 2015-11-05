Pod::Spec.new do |s|
  s.name             = "OriginateHTTP"
  s.version          = "0.0.7"
  s.summary          = "A lightweight HTTP networking client backed by NSURLSession."

  s.homepage         = "https://github.com/Originate/OriginateHTTP"
  s.license          = 'MIT'
  s.author           = { "Allen Wu" => "allen.wu@originate.com" }
  s.source           = { :git => "https://github.com/Originate/OriginateHTTP.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
end
