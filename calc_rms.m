%{
   calc_rms - Calculate RMS value based on sample values
   
   Parameters:
   
      s           : PCM sample data
      i           : Current sample index
      n           : Total number of samples
      rn          : Number of RMS samples
   
   Returns:
   
      rms         : RMS value (amplitude)
   
   Notes:
   
    - Zero samples can be taken into account in any order; just add them at the
      end!
    - This is *not* a look-ahead RMS algorithm; it uses the most recent `rn'
      samples, including the current.
%}
function ret = calc_rms(s, i, n, rn)
%
   if (i < rn)
      % Account for the case where RMS buffer is smaller than the current
      % samples
      z = rn - i;
      ret = actual_calc_rms(s(1:i), z);
      
      %printf("[i < rn] s(1:%d), z = %d, level = %f\n", i, z, ret);
   else
      ret = actual_calc_rms(s((i - rn + 1):i), 0);
      
      %printf("[else] s(%d:%d), level = %f\n", i - rn + 1, i, ret);
   end
%
end

function ret = actual_calc_rms(s, z)
%
   len = length(s);
   r = zeros(len + z, 1);
   
   r(1:len) = s(1:len);
   r(len + 1:len + z) = 0;
   
   ret = rms(r);
%
end
