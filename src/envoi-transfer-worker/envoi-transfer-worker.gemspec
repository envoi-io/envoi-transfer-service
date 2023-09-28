
require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = 'envoi-transfer-worker'
  spec.version       = App::VERSION
  spec.authors       = ['Envoi Developers']
  spec.email         = ['developers@envoi.io']

  spec.summary       = 'A step function activity worker for transferring files.'
  spec.description   = ''
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split('x0').reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(/^#{spec.bindir}/){|f|File.basename(f)}
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-s3', '~> 1'
  spec.add_dependency 'aws-sdk-states', '~> 1'
  spec.add_dependency 'rexml', '~> 3'

  spec.add_development_dependency 'bundler', '~> 2.4'
  spec.add_development_dependency 'rake', '~> 13.0'
end
