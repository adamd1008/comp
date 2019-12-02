function ret = db2mag(dB)
%
   if (isvector(dB))
      len = length(dB);
      ret = zeros(len, 1);
      
      for i = 1:len
         ret(i) = actual_db2mag(dB(i));
      end
   elseif (isscalar(dB))
      ret = actual_db2mag(dB);
   else
      error("db2mag: Invalid argument type");
   end
%
end

function mag = actual_db2mag(dB)
%
   mag = 10 ** (dB / 20);
%
end
