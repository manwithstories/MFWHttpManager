Pod::Spec.new do |s|
s.name             = "MFWHttpManager"
s.version          = "1.0"
s.summary          = "MFWHttpManager"
s.source           = { :path => './'}
s.social_media_url = 'http://www.mafengwo.cn'

s.platform     = :ios, '7.0'
s.requires_arc = true

s.xcconfig = { 'ONLY_ACTIVE_ARCH' => 'NO' }

s.public_header_files = ['MFWHttpManager/Engine/*.h','MFWHttpManager/Plugin/Request/*.h','MFWHttpManager/Plugin/Response/*.h','MFWHttpManager/Task/*.h']

s.source_files = ['MFWHttpManager/Engine/*.{h,m}','MFWHttpManager/Engine/Private/*.{h,m}','MFWHttpManager/Plugin/Request/*.{h,m}','MFWHttpManager/Plugin/Response/*.{h,m}','MFWHttpManager/Task/*.{h,m}']

s.frameworks = ['MobileCoreServices', 'CoreGraphics', 'Security', 'SystemConfiguration']

end