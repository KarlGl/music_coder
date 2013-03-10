Gem::Specification.new do |s|  
  s.files       = Dir['lib/**/*.rb']
  s.name        = 'music_coder'
  s.version     = '0.7.1'
  s.summary     = "An application to programmatically create music through code."
  s.require_paths = ["lib"]
  s.add_dependency('sndfile', '>=0.2.0')
  
  # less important
  s.date        = '2012-03-08'
  s.authors     = ["Karl Glaser"]
  s.email       = 'karl.is.god@gmail.com'
  s.homepage    = 'http://musiccoder.com'
  s.test_files = ['lib/tests.rb']
  s.has_rdoc = true
  s.requirements << "libsndfile, library of C routines for reading and writing files containing sampled audio data."
end