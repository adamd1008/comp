function ret = normalise(vec)
%
   if (!isvector(vec))
      error("normalise: Invalid argument type");
   end
   
   vec_max = max(abs(vec));
   
   if (vec_max > 0)
      ret = vec ./ vec_max;
   else
      ret = vec;
   end
%
end
