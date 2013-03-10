#These are the main methods in the API to be called from anywhere.
#Other important API classes to read are:
#* Dist
#* Snd
#* Note
#* HitSq
class Object
# initialize all instance vars from a Hash if they are specified in args.
def init_hash(args)
  instance_variables.each do |p|
    v_name = p[1,p.size]
    arg = args[v_name.to_sym] if not args.nil?
    self.instance_variable_set p, arg if not arg.nil?
  end
end

def deep_copy
  Marshal.load(Marshal.dump(self))
end
#:nodoc: test if attributes are equal
def vars_eql?(other,vars=nil)
  vars ||= instance_variables
  vars.each do |var|
    # puts instance_variable_get(var)
    if instance_variable_get(var).respond_to? 'is_eql'
      # puts 'responds to is_eql'
      return false if !(instance_variable_get(var).is_eql other.instance_variable_get(var))
    else
      # puts "mine: #{instance_variable_get(var)} other: #{other.instance_variable_get(var)}"
      return false if !(instance_variable_get(var) == other.instance_variable_get(var))
    end
  end
  true
end
end

class Array
  # add all elements and fit if i'm too small
  def add_e (array)
    if !array.nil? && array.count > 0
      array.count.times do |i|
        self<<0 if i > self.count-1
        self[i] += array[i]
      end
    end
    self
  end
  # add all elements and fit if i'm too small
  def add_e_no_resize (array)
    self.count.times do |i|
      self[i] += array[i]
    end
    self
  end
end

#require 'debugger'
# The top level of the program. This static class contains static methods and static attributes.
#Gem site: rubygems.org/gems/music_coder
class App
class << self
  #file containing input (without .rb extension)
  attr_accessor :infile
  #Time of the last output computation
  attr_accessor :lastgen
  #write to this to be made
  attr_accessor :out
  attr_accessor :start_t
  attr_accessor :outpath
  attr_accessor :fileoptions
  attr_accessor :mixes_num
  attr_accessor :audio_file_settings
# how many hits are done, how many are todo
  attr_accessor :done, :total
  # perf testing
  attr_accessor :checks
  # Logger
  attr_accessor :logger
end 
require 'yaml'

# Reload all files in case of update.
def self.load_all
  load File.dirname(__FILE__) + '/tone.rb'
  load File.dirname(__FILE__) + '/logger.rb'
  load File.dirname(__FILE__) + '/fader.rb'
  load File.dirname(__FILE__) + '/composer.rb'
  load File.dirname(__FILE__) + '/math_utils.rb'
  load File.dirname(__FILE__) + '/wave.rb'
  load File.dirname(__FILE__) + '/wave_data.rb'
  load File.dirname(__FILE__) + '/mixer.rb'
  load File.dirname(__FILE__) + '/audio_output.rb'
  load File.dirname(__FILE__) + '/tone_part.rb'
  load File.dirname(__FILE__) + '/tone_seq.rb'
  load File.dirname(__FILE__) + '/audio.rb'
  load File.dirname(__FILE__) + '/file_list.rb'
  load File.dirname(__FILE__) + '/snd_dist.rb'
  load File.dirname(__FILE__) + '/api/note.rb'
  load File.dirname(__FILE__) + '/api/api.rb'
  load File.dirname(__FILE__) + '/api/dist.rb'
  load File.dirname(__FILE__) + '/api/hit_sq.rb'
  load File.dirname(__FILE__) + '/api/snd.rb'
end

def self.clear_dir dir_path
  Dir.foreach(dir_path) {|f| fn = File.join(dir_path, f); File.delete(fn) if f != '.' && f != '..'}
end

# clears objects ready to write to file.
def self.clear_ready
  App.clear_dir App::TMP_DIR
  App.out.snddists = []
  App.out.filelist = FileList.new
end

# The top level of program calls this
def self.main_loop
  puts "Running application code"
  self.infile = 'input'
  App.clear_dir App.outpath+"sound/"
  self.out = AudioOutput.new
  # App.clear_ready
  self.out.outfile="#{App.outpath}sound/output.aiff"
  while true do
    if generate_new?
        load_all
        puts infile + ".rb change detected."
      begin
        load '../'+infile+'.rb'
        files = *(1..App.mixes_num)
        files.each {|let| 
          
          self.out.outfile="#{App.outpath}sound/#{let}#{App::EXT}"
          puts "+++BEGIN #{let}#{App::EXT} +++"
          App.start_t = Time.new
          self.generate
          
          }
      rescue Exception => ex
        puts "!!! - Mistake in input file!"
        puts "!!! - " + ex.message
        puts ex.backtrace.join("\n")
      end
      puts "...waiting for input changes..."
    end
  sleep(0.8)
  end
end

def self.time_since
  (Time.new - App.start_t)
end

# Generates audio from input file.
def self.generate
  input
end

# has there been a change in the input file since last generation?
# file:: the name without .rb extnesion or ./ before it
# lastgen:: the time of last generation
def self.generate_new?(file = nil)
  file = infile if file.nil?
  now = File.ctime("../"+file+".rb")
  is_new = (lastgen != now)
  self.lastgen = now
  return is_new ? true : false
end

# To copy ruby classes not pass them by reference
def self.deep_copy(o)
  Marshal.load(Marshal.dump(o))
end

# audio files are read this many frames at a time, reduce to save RAM, but will have longer generating times.
self.load_all # on load
# this is the max elements in an array of data for the write file. higher = less CPU load, more RAM load.
# 46,000 of these per mb roughly.
App::CHUNK_SIZE = 110_000 unless const_defined?(:CHUNK_SIZE)
App::EXT = ".aiff" unless const_defined?(:EXT)
App::TMP_DIR = "tmp/" unless const_defined?(:TMP_DIR)
App.outpath = "output/"
App.start_t = Time.new
self.mixes_num = 1
Composer.samplerate = 44100
Composer.bpm = 128
App.checks = 0
self.out = AudioOutput.new
# make dirs
require 'fileutils'
FileUtils.mkdir_p App.outpath+"sound/"
FileUtils.mkdir_p App::TMP_DIR
#
App.clear_dir App.outpath+"sound/"
self.out.outfile="#{App.outpath}sound/output#{App::EXT}"
self.logger = Logger.new
App.fileoptions={:mode => :WRITE, :format => :AIFF, :encoding => :PCM_16, :channels => 1, :samplerate => Composer.samplerate}
log "Music Coder", 1
end
