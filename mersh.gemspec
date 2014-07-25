Gem::Specification.new do |s|
  s.name              = 'mersh'
  s.rubyforge_project = "mersh"

  s.version           = "0.0.3"
  s.platform          = Gem::Platform::RUBY

  s.summary           = "3D Mesh Manipulation"
  s.description       = "Performs some useful operations on 3D mesh files"
  s.authors           = ["Tony Buser"]
  s.email             = 'tbuser@gmail.com'
  s.homepage          = 'http://github.com/tbuser/mersh'

  s.require_paths     = ["lib"]
  s.files             = Dir["{lib}/**/*.rb", "bin/*", "test/*", "LICENSE", "README.rdoc"]
  s.executables       = ['mersh']
  
  s.add_dependency("json")
end