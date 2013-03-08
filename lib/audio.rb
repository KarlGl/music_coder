# All disc operations. 
class App

  def App.open_w_audiofile file
    raise "no file name to open for writting. " if file.nil? || App.fileoptions.nil?
#    puts "#{file} #{App.fileoptions}"
    Sndfile::File.open(file, App.fileoptions)
  end
  def self.m_from_array data
    write_matrix = GSLng::Matrix.from_array(data)
    write_matrix.transpose
  end

  def App.write_to_audiofile fout, array
    fout.write App.m_from_array array
    GC.start
  end

  def App.open_write(filen)
    File.open(filen, 'w')
  end

  def App.close_write(fi)
    fi.close
  end

  def App.split_array(array, size)
    upto=0
    ammont=array.count
    jump=size
    out = []
    while upto < ammont do 
      # puts "upto #{upto} amount #{ammont}"
      jump = ammont - upto if upto+jump >= ammont
      # puts "array range #{upto} to #{upto+jump-1}"
      out << array[upto..upto+jump-1]
      upto+=jump
    end
    out
  end
  def App.read_chunk_of(array, start=0, chunk_size)
    array[start..start+chunk_size-1]
  end


end

require 'sndfile'
