Pod::Spec.new do |s|
  s.name         = "RNFileSystem"
  s.version      = "1.0.0"
  s.summary      = "iOS stub for react-native-file-system"
  s.homepage     = "https://github.com"
  s.license      = "MIT"
  s.author       = { "author" => "author@example.com" }
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com", :tag => "v1.0.0" }
  s.source_files = "**/*.{h,m}"
  s.dependency   "React-Core"
end
