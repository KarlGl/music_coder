class AudioOutput
  # add all other fls to this
  attr_accessor :filelist
  #this didn't need to be an array, but maybe use it for track mixing?
  attr_accessor :snddists
  attr_accessor :outfile
  # of file write
  attr_accessor :percent_complete

  def initialize()
      @snddists = []
      @outfile = nil
      @filelist= FileList.new
      @percent_complete = 0
  end
  def render
    log "phase 1 of 2: render sounds", 2
    App.done=0
    App.total=0
    snddists.each {|snddist| App.total+=snddist.tally_frames}
#    puts "App.total #{App.total}" # Only for progress bar
    snddists.each {|snddist| self.filelist.addlist snddist.render }
    log "phase 1 complete.", 2
  end
  def make_audio_file
    log "phase 2 of 2: merging all tmp files into #{App::EXT} file. secs:#{App.time_since}", 2
    frames_index = 0
    len = 0 
    # get max len
    snddists.each { |sn| len = sn.len if sn.len > len }
    len = len.round
    fout = App.open_w_audiofile outfile
    App.checks = 0 # for performance testing
    last_jump=0
    while frames_index < len
      
      if frames_index + App::CHUNK_SIZE >= len
        # set jump to finish it off since it's under chunk size
        rest = len - frames_index #1 min, chunk_size max.
        jump = rest
        log "capping chunk size at #{jump}", 4
      else
        jump=App::CHUNK_SIZE
      end

      values_for_write = []
#      while values_for_write.count < jump
      # if frames_index-last_jump >= jump
      #   puts "frames index was #{frames_index} jump was #{jump}"
      #   puts "jump neeeds to be > #{frames_index-last_jump}"
      #   jump = App::CHUNK_SIZE
      # end

      # jump=frames_index+10000

      while frames_index-last_jump < jump
        # minimize if too big
        if frames_index-last_jump+jump > len
          jump = len-frames_index-last_jump
          log "minimizing this chunk to #{jump}", 4          
        end
        log "CHUNK_@#{frames_index} asked for #{jump}.  total: #{len}", 4
        values = filelist.root_get_value(frames_index,jump)#, jump)+
        
        # if values.count==0
        #   puts "VALUES RETURNED 0"
        #   frames_index = len # end this shit
        # end
        # puts "CHUNK recieved #{values.count} "
#        puts "--> read #{values.join(', ')}"
        values_for_write+= values
#        puts "____#{found_vals}"
#        values.add_e found_vals
        # raise " couldn't find a value... fuck." if found_val.nil?
        # print percent
        frames_index += values.count
        App.logger.print_loading_bar(frames_index, len, percent_complete, 50)
        self.percent_complete = ((frames_index.to_f/len)*100)
        # values=nil
        # GC.start
      end
      last_jump=frames_index
      # puts "--> to write: #{values_for_write.count} #{frames_index} #{len}"
      App.write_to_audiofile fout, values_for_write if values_for_write.count>0
      # values_for_write=nil
      # GC.start
    end
    App.close_write fout
    log "performed #{App.checks} lookup checks.", 4
    print_tail_info len
  end
  def write_text_files file=nil
    file = App.outpath + "save.rb" if file.nil?
    log "state save to file #{file}", 2
    File.open(file, 'w') do |file|  
      # snddists.each do |snddist|
      #   file.puts YAML::dump(snddist)
      # end
        file.puts YAML::dump(self)
    end
  end
  def print_tail_info total_frames
    time_taken = App.time_since
    log 'wrote file: ' + outfile, 2
    log 'seconds: ' + (total_frames.to_f / Composer.samplerate).round(2).to_s +
     " (frames: #{(total_frames/1000).round},000)", 2
    log 'time taken: ' + time_taken.round(2).to_s + 
     " seconds (fps: #{(total_frames/time_taken/1000).round()},000)", 2
    #end the very last line 
    puts ""
  end

end#class
