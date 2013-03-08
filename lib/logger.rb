# any output to console runs through this
class Logger
  #higher level means more is logged. 
  #0 means silent. 
  #1 heading and written files.
  #2 condensed stats and updative info from a process (loading bars)
  #3 warnings
  #4 memory updates and debug info
  attr_accessor :level
  def initialize
    self.level = 4
  end
  
  #output something if our level says it's okay
  def log str, lvl
    raise "Don't write anything to log level 0." if lvl < 1
    extra = ""
    (lvl-1).times {extra+="_"}
    puts extra + str + extra if level >= lvl
  end
  
  # a loading bar
  def print_loading_bar(frames_index, len, percent_complete=nil)
    percent = ((frames_index.to_f/len)*100).round(4)
    percent = percent.round if !percent_complete.nil?
    # puts "percent #{percent}"
    # puts "fun percent_complete #{percent_complete}"
    if level > 1 && (percent_complete.nil? || (percent_complete.round < percent))  
      App.logger.print_and_flush("__#{percent}%__")
    end
    percent
  end
  # puts without newline
  def print_and_flush(str)
    print str
    $stdout.flush
  end

end
