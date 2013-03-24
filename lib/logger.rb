# any output to console runs through this
class Logger
  #higher level means more is logged. 
  #0 means silent. 
  #1 heading and %.
  #2 condensed stats and written files
  #3 warnings
  #4 memory updates and debug info
  #5 raw data
  attr_accessor :level
  def initialize
    self.level = 5
  end
  
  #output something if our level says it's okay
  def log str, lvl
    raise "Don't write anything to log level 0." if lvl < 1
    extra = ""
    (lvl-1).times {extra+="_"}
    puts extra + str + extra if level >= lvl
  end
  
  # a loading bar
  def print_loading_bar(frames_index, len, percent_complete=nil, skipped_percent= 0, max= 100)
    percent = ((frames_index.to_f/len)*100).round(4)
    percent = percent.round if !percent_complete.nil?
    percent = skipped_percent + (percent.to_f/100.0)*(max-skipped_percent)
    if level > 0 && (percent_complete.nil? || (percent_complete.round < percent))  
      App.logger.print_and_flush(" #{percent.round}% ")
    end
    percent
  end
  # puts without newline
  def print_and_flush(str)
    print str
    $stdout.flush
  end

end
