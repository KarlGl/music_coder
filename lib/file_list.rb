
# tree
class FileList
  # ONLY WITH NO CHILDREN
  attr_accessor :files
  attr_accessor :file_content_lens
  attr_accessor :loaded_file_index
  attr_accessor :loaded_file_data

  # N CHILDREN
  attr_accessor :filelists
  # delays of children
  attr_accessor :filelist_delays
  # I want each child in the fileslist to fill len frames from my start
  attr_accessor :child_len, :mark_of_death
  def initialize()
    @files = []
    @loaded_file_index = nil
    @filelists = []
    @filelist_delays = []
    @child_len = 0
    @file_content_lens=[]
    @loaded_file_data = nil
    @mark_of_death = false
  end

  def root_get_value(index,size=1)
    out=get_value(index,size)
    if out.count < 1
      # raise "Error looking up a value at that index. fatal. index #{index}, size #{size}." 
      out=Array.new(size,0)
    end
    out
  end
# return the value, index frames into your files. recursive.
  def get_value(index,size=1)
#    puts "requested #{size}"
    out = []
    
    if files.empty? # has children
       out=lookup_children(index,size)
       # raise "Child filelist failed at index #{index}, size #{size}." if out.count < 1
    else # no children, just files
#      puts "looked something up"
      out = get(index,size)
#      puts "retrieved #{out.count} frames from object files on disk"
#      puts "got #{out.count}"
#      puts "=>> no children, real files found value #{out}"
    end
#    puts "valuse  #{out}"
    out
  end

  def lookup_child(index,size,i)
    out=[]
    fl=filelists[i]
    App.checks+=1
    delay = filelist_delays[i]
    # delay = 0 if delay.nil?
    # puts "deciding if we should go into filelist #{i+1} of #{filelists.count},"+
         # " is #{delay} <= #{index} ? "
#        puts "child len #{@child_len}"
    needed_until_in = delay - index
    if needed_until_in <= 0
#          puts "child #{i}"# #{index-delay}"
      if fl.mark_of_death
#            puts "old count: #{filelists.count}"
        # fl.loaded_file_data=nil
        # GC.start
        self.filelists.delete_at i
        self.filelist_delays.delete_at i
#            puts "#{i} is dead! new count: #{filelists.count}"
      else
        # normal result
        result =fl.get_value(index-delay,size)
#             puts "normal #{result.count}"
        out= result
      end
    else 
       spoof_req_len = size - needed_until_in
       if spoof_req_len > 0
         # Read a smaller chunk in the futre that will be missed if we increment by size.
         index_to_get_in = needed_until_in + index
         delay_on_future_chunk = Array.new(needed_until_in, 0)
         future_chunk = fl.get_value(index_to_get_in-delay, spoof_req_len)
#             puts future_chunk.count
         combo = [] + delay_on_future_chunk + future_chunk
#             puts combo.count
         out= combo # with resizing, but will be chunk len anyway.
       else
         # Will be handled in future chunks.
#          out.add_e Array.new(2,0)
       # puts "not above delay"
#          puts "c #{delay-index}"
       end
    end
    out
  end

  def lookup_children(index,size)
    out = []
    if filelists.count==0
        #no file lists, so fill with 0s to len
        sil_amount = size
        sil_amount = child_len if child_len < sil_amount && child_len != 0  #limit silence to my length
        sil_amount
        out = Array.new(sil_amount-index,0) if sil_amount-index > 0
        ### puts "set mark of death, returning silence #{sil_amount}, my length: #{child_len}"
        self.mark_of_death = true
        return []
    end
    filelists.each_with_index do |fl,i|
      out.add_e lookup_child(index,size,i)
    end
    out
  end

  def get(index, size=1)
#    out=Array.new(1,0)
out=[]
    # not opened yet
    if loaded_file_index.nil?
      # App.logger.print_and_flush "|t|"
      load_from_file(0)
    end

    #still got data to write in THIS file
    if current_index_fits_opended_file?(index)
      out = (read_data_at index, size)
#      puts "fl-no-child: normal read #{out}"

    #need to load next file (index is higher than current)
    else 
      # theres more files to load
      if files.count > loaded_file_index+1 
        load_from_file(loaded_file_index+1)
        out = (read_data_at index, size)
        # puts "fl-no-child: file #{loaded_file_index} is finished. load next. found val #{out}"
      else # no more files, index is past
        self.mark_of_death =true
#        puts "fl-no-child: marking for dead!!!"
      end
    end
    out
  end

  #return:: total len of this TrackSection
  #nil is error
  def get_content_len
    child_len.nil? ? file_content_lens.reduce(:+) : child_len
  end

  def current_index_fits_opended_file?(index) # all that have been opened are tallied
    index < file_content_lens[0..loaded_file_index].reduce(:+)
  end

  # returning array of size
  def read_data_at (index,size=2)
    lookup=loaded_file_index==0 ? index : index-file_content_lens[0..loaded_file_index-1].reduce(:+)
    #index - all other lengths, so we get a relative index.
    rb = loaded_file_data.count-1 # right bound
#    puts "largest possible  #{rb}, lookup #{lookup}"
    jump = lookup+size-1
    jump = rb if jump > rb
    result=loaded_file_data[lookup..jump]
#    puts "#{lookup }  #{jump} #{result}"
#    puts "giving data size #{result.count}"
    result
  end

  #index
  def load_from_file(fi)
    f=File.new(files[fi], "r")
    data=f.gets(nil)
    f.close
    self.loaded_file_index = fi
    parse_loaded data
  end

  def parse_loaded data
    self.loaded_file_data=Marshal.load(data)
  end

  def addlist list, delay=0
    self.filelists.push list
    self.filelist_delays.push delay.to_i
  end

  def write(wave_data,delay=0)
    full=wave_data.dps
    # puts "--> values: #{full.join(', ')}"
    spli=App.split_array(full, App::CHUNK_SIZE)
    spli.each_with_index do |array,i|
      self.files.push "#{App::TMP_DIR}#{object_id}_#{i}"
      self.file_content_lens.push array.count
      File.open(self.files.last, 'w') do |fout|  
        fout.puts Marshal.dump(array)
      end
    end
    # puts "written #{spli.count} tmp files"
  end
end
