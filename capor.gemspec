
Gem::Specification.new do |s|
  s.name        = 'capor'
  s.version     = '0.0.3'
  s.date        = '2017-05-07'
  s.summary     = 'Capor is command line tool for parser iOS .ipa file.'
  s.description = 'Capor is command line tool for parser iOS .ipa file, you cat the ipa package info like cat a file.'
  s.author      = 'Gump Wang'
  s.email       = '1989wg@gmail.com'
  s.license     = 'MIT'
  s.homepage    = 'https://www.github.com/wanggang316/capor'

  s.files       = 'lib/capor.rb'

  s.add_dependency 'commander',       '~> 4.3'
  s.add_dependency 'rubyzip',         '~> 1.0', '>= 1.0.0'
  s.add_dependency 'plist',           '~> 3.3'
  s.add_dependency 'terminal-table',  '~> 1.7', '>= 1.7.3'
  s.add_dependency 'CFPropertyList', '~> 2.3'



  s.bindir = 'bin'
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }



end
