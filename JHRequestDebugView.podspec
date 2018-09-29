
Pod::Spec.new do |s|
  s.name         = 'JHRequestDebugView'
  s.summary      = 'A simple request debug view.'
  s.version      = '1.2.0'
  s.license      = { :type => 'MIT'}
  s.authors      = { 'Haocold' => 'xjh093@126.com' }
  s.homepage     = 'https://github.com/xjh093/JHRequestDebugView'

  s.ios.deployment_target = '8.0'

  s.source       = { :git => 'https://github.com/xjh093/JHRequestDebugView.git', :tag => s.version}
  
  s.source_files = 'JHRequestDebugView/*.{h,m}'
  s.requires_arc = true
  s.framework    = 'UIKit'

end