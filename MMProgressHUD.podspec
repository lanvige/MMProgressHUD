Pod::Spec.new do |s|
  s.name     = 'MMProgressHUD'
  s.version  = '0.3.0'
  s.summary  = 'lightweight hud'
  s.homepage = 'https://github.com/lanvige/MMProgressHUD'
  s.authors  = { 'Lanvige Jiang' => 'lanvige@gmail.com' }
  s.source   = { :git => 'https://github.com/lanvige/MMProgressHUD' }
  s.source_files = 'MMProgressHUD'
  s.resources = 'MMProgressHUD/MMProgressHUD.bundle'

  s.platform = :ios
  s.requires_arc = true
  s.ios.deployment_target = '5.0'
  s.ios.frameworks = 'QuartzCore'
  
  # The readme says that it is needed but it lints without
end