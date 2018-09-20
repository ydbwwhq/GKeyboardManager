Pod::Spec.new do |s|
  s.name         = "GKeyboardManager"
  s.version      = "0.1.0"
  s.summary      = "great keyboardManager"
  s.description  = <<-DESC
                   great tool,you can use it to handle keyboard
                   DESC
  s.homepage     = "https://github.com/ydbwwhq/GKeyboardManager"
  s.license      = "MIT"
  s.author       = { "Hale" => "1334849513@qq.com" }
  s.source       = { :git => "https://github.com/ydbwwhq/GKeyboardManager", :tag => "#{s.version}" }
  s.source_files  = "GKeyboardManager/**/*.{h,m}"
  s.frameworks = 'UIKit','Foundation'
  s.platform = :ios,"8.0"
end
