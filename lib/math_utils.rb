# All generic static math functions needed.
class MathUtils
class << self
end
# golden ratio
self::GR = 1.61803398875 unless const_defined?(:GR)

#outputs 0 to 1 increasing by the factor
#detail:: number of times to apply division. 1 to inf
#factor:: the number to divide by. 
def self.division_fade(detail = 8, factor = nil)
  factor ||= GR
  raise "Detail must be >= 1" if detail < 1
  out = Array.new(detail)
  old = 1
  out.each_with_index do |x,i| 
    out[i] = old / factor.to_f
    out[i] = 1 if i < 1 # first is 1 always
    old = out[i]
  end
  out.reverse
end

#generates data for sin wave in an array (single cycle)
#detail:: number of elements in the wave. 
#default: 2048 very smooth
def self.sinwave(detail = 2048, saturation=0)
  raise "Sinwave frames must be specifed as >= 3." if detail < 3
  val = Array.new(detail)
  val.each_with_index do |foo,i|
    progress=i.to_f/detail
    val[i] = Math.sin(2.0*Math::PI*progress)
    val[i] = (val[i]-saturation.to_f)+rand*saturation.to_f*2.0
  end
  val
end

#generates wave cycle by duplicating data to fillout the other 3 sections of a wave.
#data:: data from 0 to 1 for the first section.
def self.filloutwave(data)
  val = []
  i=0
  while i < data.count
    val.push data[data.count-i-1] if i > 0
    i+=1
  end
  ret = data + val
  val = []
  i=0
  while i < ret.count
    val.push -ret[ret.count-1-i] if i > 0
    i+=1
  end
  ret += val
  ret.pop # remove last 0
  ret
end
require 'matrix'
FIB_MATRIX ||= Matrix[[1,1],[1,0]]
#calculate fibonacci number
def self.fib(n)
  (FIB_MATRIX**(n-1))[0,0]
end
end