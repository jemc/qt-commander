
Gem::Specification.new do |s|
  s.name          = 'qt-commander'
  s.version       = '0.6.1'
  s.date          = '2014-05-04'
  s.summary       = 'qt-commander'
  s.description   = "A Ruby utility for building and management of "\
                    "Qt Creator projects."
  s.authors       = ["Joe McIlvain"]
  s.email         = 'joe.eli.mac@gmail.com'
  
  s.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  
  s.require_path  = 'lib'
  s.homepage      = 'https://github.com/jemc/qt-commander/'
  s.licenses      = "MIT"
  
  s.add_dependency 'inifile', '~> 2.0'
  
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-rescue'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fivemat'
  s.add_development_dependency 'yard'
end
