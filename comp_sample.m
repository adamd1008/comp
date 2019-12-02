%{
   comp_sample - Actually calculate the compressed sample value
   
   Arguments:
   
      s              : Sample value
      dB             : Sample dB value
      gr             : Gain reduction (dB, negative)
%}
function cs = comp_sample(s, dB, gr)
%
   new_dB = dB + gr;
   
   if (s >= 0)
      cs = db2mag(new_dB);
   else
      cs = -db2mag(new_dB);
   end
%
end
