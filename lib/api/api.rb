#base class for most of the things the user will touch directly
class Api
  def initialize
    @parents=[]
  end
  #Add things to me. This can be applied for many classes. Can handles arrays of excepted types.
  #object Dist can add Dist to children.
  #object Dist can add Snd to list of sounds.
  #object Dist and HitSq can add HitSq to list of hits. 
  #object Dist and HitSq can add Numbers to list of hits. 
  #object Snd can repalce ToneSeq.
  #object Snd can add Snd to repalce its ToneSeq. 
  #object Snd can add TonePart to add it to its ToneSeq. 
  def << toadd
#    puts "type: #{toadd.class}"
    case toadd
    when Array
#      puts "recognised array"
      toadd.each do |ta| 
        r = add_single ta
        raise "This type is not recongnised." if r ==false
      end
    else
      r=add_single toadd
      raise "This type is not recongnised." if r==false
    end
    self
  end
  # Delete things from me
  def >> todel
#    puts "type: #{todel.class}"
    case todel
    when Array
#      puts "deleting array #{todel}"
      todel.each do |ta| 
        r = del_single ta
        raise "This type is not recongnised." if r ==false
      end
    else
      r=del_single todel
      raise "This type is not recongnised." if r==false
    end
    self
  end
  
  def parent index=0
    @parents[index]
  end
  
  protected
  def add_parent obj
    @parents << obj
    self
  end
  
end#class

#load program state from a saved file.
def load_state file=nil
  file=App.outpath + "save.rb" if file.nil?
  f=File.open(file,'r')
  content=f.read
  # puts content
  App.out= YAML.load(content)
  f.close
end

#save program state to a file.
def save_state file=nil
  App.out.write_text_files file
end

#generate the audio data for everything in the queue. see #queue method.
def render
  App.out.render
end

#make an audio file based off generated data.
def make
  App.out.make_audio_file
end

#return the frames in i beats. used for setting lengths when they are needed in frames.
def beat i=1
  z=Composer.beat i
  z.to_i
end
#return the frames in i bars. used for setting lengths when they are needed in frames.
def bar i=1
  z=Composer.beat i*4
  z.to_i
end

# add a Dist to the queue of things to be rendered when you call render. see #render.
def queue dist
  App.out.snddists<<dist.instance_variable_get(:@dist)
end

#clear already rendered files. 
#usually you will want to do this at the start of the program or temp files 
#created from the last use will overlap the current ones when you run #make.
def clear
  App.clear_ready
end

#set the beats per minute of all following audio. now helper methods like #beat will be usefull.
def bpm_set val
  Composer.bpm = val
end
#return the current beats per minute.
def bpm
  Composer.bpm
end
#shortcut for #render #save_state #make
def compute
  render
  save_state
  make
end
#send String str to be logged.
#level:: it won't be logged unless Logger.level is at or above this level.
def log str, level=3
  App.logger.log str, level
end
# set Logger.level. Higher means more logging. 0 is silent.
def log_level set
  App.logger.level = set
end


#outputs the midi notes of the chord in an array
#note:: midi value of root note in chord. range: 0 to 11
#name:: anything from Composer.chords
def chord_notes(note, name = "dim7")
  set=[]
  out=[]
  all=Composer.chords
  # handle all selected
  if name=="all"
    all.keys.each { |val| out.push chord_notes(note, val) }
  else #normal
    set = all[name]
    raise "Unknown scale name" if set.nil?
    out = [note] # always root
    set.each do |val|
      out.push note+val
    end
  end

  out
end

#return array of notes in the scale
#note:: midi value of root note. range: 0 to 11
#name:: anything from Composer.scales
def scale_notes(name = "major", note=0)
  set=[]
  out=[]
  all=Composer.scales
  # handle all selected
  if name=="all"
    all.keys.each { |val| out.push scale_notes(val,note) }
  else #normal
    set = all[name]
    raise "Unknown scale name" if set.nil?
    out = [note] # always root
    set.each do |val|
      out.push note+ val
    end
  end
  out
end

#return an Array of String of chords that could be the i number chord for notes in the given scale.
def scale_chord(i=0, scale = "major")
  notes = Composer.get_notes(Composer.scales[scale])
  Composer.matching_chords(scale, notes[i])
end

#return an Array of chords (each chord is an Array of Integer notes) 
#that fit each note consecutively in the given scale. 
#The chord is randomly sampled from those availiable.
def get_chords(scale = "major")
  out = []
  notes = Composer.get_notes Composer.scales[scale]
  notes.count.times do |i|
    chord = scale_chord(i,"mixolydian").sample #rand
    out << chord_notes(notes[i], chord)
  end
  out
end
