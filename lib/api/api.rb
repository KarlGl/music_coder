#base class for most of the things the user will touch directly
class Api
  def initialize
    @parents=[]
  end
  # Add things to me
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

def load_state
  f=File.open("../output/text/saved.rb",'r')
  content=f.read
  # puts content
  App.out= YAML.load(content)
  f.close
end

def save_state
  App.out.write_text_files
end

def render
  App.out.render
end

def make
  App.out.make_audio_file
end

def beat i=1
  z=Composer.beat i
  z.to_i
end
def bar i=1
  z=Composer.beat i*4
  z.to_i
end

def queue dist
  App.out.snddists<<dist.instance_variable_get(:@dist)
end

# _rendered files
def clear
  App.clear_ready
end

def bpm_set val
  Composer.bpm = val
end
def bpm
  Composer.bpm
end
def compute
  render
  save_state
  make
end
# send str to be logged.
# level:: it won't be logged unless Logger.level is at or above this level.
def log str, level=3
  App.logger.log str, level
end
# set Logger.level. Higher means more logging. 0 is silent.
def log_level set
  App.logger.level = set
end