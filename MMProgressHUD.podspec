Pod::Spec.new do |s|
  s.name     = 'MMProgressHUD'
  s.version  = '0.2.0'
  s.summary  = 'The super view with refresh, load more and status view'
  s.homepage = 'https://github.com/lanvige/MMProgressHUD'
  s.authors  = { 'Lanvige Jiang' => 'lanvige@gmail.me' }
  s.source   = { :git => 'https://github.com/lanvige/MMProgressHUD' }
  s.source_files = 'MMProgressHUD'
  s.requires_arc = true

  s.ios.deployment_target = '5.0'
  
  # The readme says that it is needed but it lints without
end