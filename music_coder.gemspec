Gem::Specification.new do |s|  
  s.files       = Dir['lib/**/*.rb']
  s.name        = 'music_coder'
  s.version     = '0.9.1'
  s.summary     = "write programs that create music. music audio library."
  s.description = "Music Coder is a music programming library. It generates music entirely through code in the chosen programming language (Ruby). 
              There are three main reasons a technically minded person would use Music Coder:
              Producing music: Write scripts that mimic human creativity, and put some randomness in it, giving you a program that can generate aesthetically pleasing music that is completely unique in each file generated.
              Scientific exploration: Use the functions in Music Coder to concisely apply algorithms or math to the structure and properties of sound.
              Making samples: create samples or sections of music that are too complex to be done by hand in graphical audio programs such as Ableton."
  s.require_paths = ["lib"]
  s.add_dependency('sndfile', '>=0.2.0')
  
  # less important
  s.date        = '2012-03-24'
  s.authors     = ["Karl Glaser"]
  s.email       = 'karl.is.god@gmail.com'
  s.homepage    = 'http://musiccoder.com'
  s.test_files = ['lib/tests.rb']
  s.has_rdoc = true
  s.requirements << "libsndfile, library of C routines for reading and writing files containing sampled audio data."
end