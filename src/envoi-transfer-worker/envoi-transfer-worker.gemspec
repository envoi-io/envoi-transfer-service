
require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = 'envoi-envoi-transfer-worker'
  spec.version       = EnvoiTransferWorker::VERSION
  spec.authors       = ['Envoi Developers']
  spec.email         = ['developers@envoi.io']

  spec.summary       = 'A step function activity worker for transferring files.'
  spec.description   = ''
  spec.homepage      = ''
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(__dir__) do
  #   `git ls-files -z`.split("\x0").reject do |f|
  #     (File.expand_path(f) == __FILE__) ||
  #       f.start_with?(*%w[. bin/ test/ spec/ features/ Gemfile])
  #   end
  # end
  spec.files         = Dir['lib/*.rb', 'lib/**/*.rb']
  spec.bindir        = 'exe'
  # spec.executables   = spec.files.grep(/^#{spec.bindir}/){|f|File.basename(f)}
  spec.executables   = Dir["#{spec.bindir}/*.*"]
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-s3', '~> 1'
  spec.add_dependency 'aws-sdk-ssm', '~> 1'
  spec.add_dependency 'aws-sdk-states', '~> 1'
  spec.add_dependency 'rexml', '~> 3'

  spec.add_development_dependency 'bundler', '~> 2.4'
  spec.add_development_dependency 'rake', '~> 13.0'
end
