%{
   comp - Dynamic range compressor
   
   Parameters:
   
      s           : PCM sample data
      fs          : Sample rate (needed for att, rel, hold, RMS)
      thr         : Threshold (decibels)
      ratio       : Compression ratio above threshold (decibels)
      knee        : Knee size (decibels)
   
   Returns:
   
      cs          : Processed PCM sample data
      cd          : Per-sample compression (decibels)
   
   Future considerations:
   
      attMs       : Attack duration, per 10 dB (milliseconds)
      holdMs      : Delay before release, per 10 dB (milliseconds)
      relMs       : Release duration, per 10 dB (milliseconds)
      rmsMs       : Root mean square window size (milliseconds)
   
   Mechanics:
   
   Knee
   - The knee of the compressor *in this example* (not necessarily in all
     compressors!) is defined as the total dB range through which the ratio is
     enforced, *centered on the threshold value* (+/- half the knee).
   - In other words: if the threshold is -6 dB and the knee is 4 dB, the ratio
     begins at -8 dB and ends at -4 dB.
   - Decibel reduction is interpolated linearly between the start and end
     values (not a linear amplitude change, of course).
   
   Stage of processing
      
      "open"  : Compressor is not processing sample in any way
      "att"   : Compressor is attacking; beginning to reduce
      "hold"  : Compressor is fully attacked; waiting to release
      "rel"   : Compressor is releasing
      
   att_target     : attack target (reduction to aim for, in decibels)
   att_per_sample : attack per sample
   
   States:
   
   (1) open -> att
   (2) att -> hold
   (3) hold -> rel
   (4) rel -> open
   (5) rel -> hold
   
   State transition (5) is a special case here. If we are releasing from
   -10 dB GR and are currently at -8 dB, but the compressor is meant to be
   compressing down to -6 dB, we *release* to the GR target and go into the
   "hold" state.
   
   NOTE: pre-determine the number of samples required to fully attack/release
   and always use that scale to determine how long a partial attack/release
   should take.
   
   For example: att = 10 samples. If attacking from 0 dB to -10 dB, attack
   should occur at 1 dB GR per sample, of course. If releasing from -10 dB to
   -6 dB GR target, it should take 4 samples to release, i.e. 40% of the
   release time.
   
   This should help us deal with slow-moving targets from low frequencies
   when att/rel is long. If the target changes every sample, go after it at
   this same speed!
   
   This is FEED-FORWARD; we act on the signal on the tick at which something
   changes, not the tick after!
%}
function [cs, cd, stages] = comp(s, fs, thr, ratio, knee, attMs, holdMs, relMs,
                                 rmsMs)
%
   if (!isvector(s))
      error("comp: first argument must be vector");
   end
   
   n = length(s);
   cs = zeros(n, 1);
   cd = zeros(n, 1);
   stages = zeros(n, 1);
   
   attS = attMs / 1000;
   holdS = holdMs / 1000;
   relS = relMs / 1000;
   rmsS = rmsMs / 1000;
   
   stage_open = 0;
   stage_att = 1;
   stage_hold = 2;
   stage_rel = 3;
   stage = stage_open;
   
   dB_per_time = 10; % Decibel change per unit time
   att_dB_per_sample = dB_per_time / (fs * attS);
   rel_dB_per_sample = dB_per_time / (fs * relS);
   
   current_hold_sample = 0;
   hold_samples = 0;
   
   if (holdS > 0)
      hold_samples = round(fs * holdS);
   end
   
   assert(hold_samples >= 0);
   
   % Envelope level (dB), i.e. the current level of gain reduction, in dB
   env_level = 0;
   
   rms_samples = 1;
   
   if (rmsS > 0)
      % Add 1 to account for the sample that represents the *current* sample
      rms_samples = round(fs * rmsS) + 1;
   end
   
   % Gain reduction (dB)
   [knee_start, knee_end] = calc_knee(thr, knee);
   
   printf("Samples         : %d\n", n);
   printf("Sample rate     : %d Hz\n", fs);
   printf("RMS samples     : %d\n", rms_samples);
   printf("Att dB/sample   : %f dB\n", att_dB_per_sample);
   printf("Rel dB/sample   : %f dB\n", rel_dB_per_sample);
   fflush(stdout);
   
   for i = 1:n
      if (mod(i, 10000) == 0)
         printf("Processed %d samples\n", i);
         fflush(stdout);
      end
      
      % dB level of the sample itself, used in GR calculations in comp_sample()
      dB = mag2db(s(i));
      
      % Calculate RMS level
      
      rms = calc_rms(s, i, n, rms_samples);
      rms_dB = mag2db(rms);
      
      % Now do the compress; first, get the current target
      gr = calc_gr(rms_dB, ratio, knee_start, knee_end, knee);
      
      % First, check if the state is valid and correct env_level if necessary
      
      if (stage == stage_open)
         if (gr < 0)
            stage = stage_att;
         end
      elseif (stage == stage_att)
         if (env_level <= gr)
            stage = stage_hold;
            current_hold_sample = 0;
         end
      elseif (stage == stage_hold)
         if (gr < env_level)
            stage = stage_att;
         else
            if (current_hold_sample == hold_samples)
               stage = stage_rel;
            end
         end
      else
         if (gr <= env_level)
            stage = stage_att;
         elseif (env_level >= 0)
            stage = stage_open;
            env_level = 0;
         end
      end
      
      % Now, perform the action required by the current/new state
      
      if (stage == stage_att)
         env_level = env_level - att_dB_per_sample;
      elseif (stage == stage_hold)
         current_hold_sample = current_hold_sample + 1;
      elseif (stage == stage_rel)
         env_level = env_level + rel_dB_per_sample;
      end
      
      cs(i) = comp_sample(s(i), dB, env_level);
      cd(i) = env_level;
      stages(i) = stage;
   end
%
end















