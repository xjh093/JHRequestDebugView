
Pod::Spec.new do |s|
  s.name         = 'JHRequestDebugView'
  s.summary      = 'A simple request debug view.'
  s.version      = '1.0.0'
  s.license      = { :type => 'MIT'}
  s.authors      = { 'Haocold' => 'xjh093@126.com' }
  s.homepage     = 'https://github.com/xjh093/JHRequestDebugView'

  s.platform     = :ios

  s.source       = { :git => 'https://github.com/xjh093/JHRequestDebugView.git', :tag => "1.0.0"}
  
  s.source_files = 'JHRequestDebugView/*.{h,m}'
  s.requires_arc = true
  s.frameworks = 'UIKit'

end