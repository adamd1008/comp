function ret = mag2db(mag)
%
   if (isvector(mag))
      len = length(mag);
      ret = zeros(len, 1);
      
      for i = 1:len
         ret(i) = actual_mag2db(mag(i));
      end
   elseif (isscalar(mag))
      ret = actual_mag2db(mag);
   else
      error("mag2db: Invalid argument type");
   end
%
end

function dB = actual_mag2db(mag)
%
   dB = 20 * log10(abs(mag));
%
end
