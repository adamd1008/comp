%{
   calc_gr - Calculate gain reduction target of a sample
   
   Arguments (that need explanation):
   
     s               : Sample value (passed in to determine sign)
     dB              : Sample dB value (passed in for performance, as it's
                       already calculated)
%}
function ret = calc_gr(dB, ratio, knee_start, knee_end, knee)
%
   if (dB > 0)
      error("calc_gr: dB must be <= 0");
   end
   
   if (ratio <= 0)
      error("calc_gr: Ratio must be >= 0");
   end
   
   if (dB <= knee_start)
      ret = 0;
   else
      actual_ratio = ratio_at_knee(dB, ratio, knee_start, knee_end, knee);
      proportion_to_reduce = 1 - (1 / actual_ratio);
      delta = dB - knee_start;
      ret = -(delta * proportion_to_reduce);
   end
%
end












