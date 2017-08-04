lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include? lib

Gem::Specification.new do |s|
  s.name          = 'amg'
  s.version       = '1.0.0'
  s.date          = '2017-08-03'
  s.summary       = 'acct manager'
  s.description   = 'account manager tool'
  s.authors       = ['Wenyu Duan']
  s.email         = 'duanwenyu1988@gmail.com'
  s.files         = Dir['lib/**/*']
  s.homepage      = 'https://github.com/duandf35/AcctManagerCLI'
  s.require_paths = ['lib']
  s.executables   = ['amg']
  s.license       = 'MIT'

  s.add_development_dependency 'sqlite3', '1.3.11', '>=1.3.0'
end
