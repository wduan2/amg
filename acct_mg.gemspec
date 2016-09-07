Gem::Specification.new do |s|
  s.name        = 'am'
  s.version     = '0.0.1'
  s.date        = '2016-08-22'
  s.summary     = 'acct manager'
  s.description = 'account manager tool'
  s.authors     = ['Wenyu Duan']
  s.email       = 'duanwenyu1988@gmail.com'
  s.files       = ['app/']
  s.homepage    = 'https://github.com/duandf35/AcctManagerCLI'

  s.add_development_dependency 'awesome_print', '1.6.1', '>= 1.6.0'
  s.add_development_dependency 'colorize', '0.7.7', '>= 0.7.0'
  s.add_development_dependency 'mysql2', '0.4.2', '>= 0.4.0'
end
