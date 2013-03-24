# mixes two tracks together or plays one or the other
class Mixer
  
  
# get volumes at a position
def self.get(first, second, reduction)
  reduction2 = reduction > 1 ? 1 : reduction
  reduction1 = reduction * 2
  reduction1 = 0 if reduction1 < 1 
  reduction1 -= 1 if reduction1 >= 1 
  f=first * (1.0 - reduction1)
  s=second * reduction2
  f+s
end

end
