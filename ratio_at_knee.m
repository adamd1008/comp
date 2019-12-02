%{
   ratio_at_knee - Calculate compression ratio at a certain sample value
   
   Mechanics:
   
   _ This does not calculate the actual gain reduction; it is literally just
     calculating the ratio at a certain decibel sample value!
%}
function ans = ratio_at_knee(dB, ratio, knee_start, knee_end, knee)
%
   if (dB <= knee_start)
      ans = 1;
   elseif (dB >= knee_end)
      ans = ratio;
   else
      sample_range = dB - knee_start;
      
      ans = 1 + ((sample_range / knee) * (ratio - 1));
   end
%
end
