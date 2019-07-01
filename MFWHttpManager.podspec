Pod::Spec.new do |s|
s.name             = "MFWHttpManager"
s.version          = "1.0.2"
s.summary          = "MFWHttpManager"
s.source           = { :path => './'}
s.author           = "mafengwo"
s.homepage         = "http://www.mafengwo.cn"
s.social_media_url = 'http://www.mafengwo.cn'
s.platform     = :ios, '7.0'
s.requires_arc = true
s.xcconfig = { 'ONLY_ACTIVE_ARCH' => 'NO', 'ENABLE_BITCODE' => 'NO' }
s.public_header_files = ['MFWHttpManager/**/*.h']
s.source_files = ['MFWHttpManager/**/*.{h,m}']
s.dependency 'AFgzipRequestSerializer', :git => 'https://github.com/manwithstories/AFgzipRequestSerializer', :branch => 'master'
end