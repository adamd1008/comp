function res = rms(samples)
%
   total = 0.0;
   l = length(samples);
   
   for i = 1:l
      sample = samples(i);
      total += sample * sample;
   end
   
   total /= l;
   res = sqrt(total);
%
end
