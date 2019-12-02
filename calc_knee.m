function [knee_start, knee_end] = calc_knee(thr, knee)
%
   knee_start = thr - (knee / 2);
   knee_end = thr + (knee / 2);
%
end
