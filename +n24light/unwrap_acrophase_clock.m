function phase_h = unwrap_acrophase_clock(dt)
%UNWRAP_ACROPHASE_CLOCK Clock hour of each acrophase, unwrapped for drift fits.
%   N24-style delay: later samples may cross midnight; add 24 h when phase
%   steps backward by more than ~6 h relative to the prior collection.

    dt = dt(:);
    phase_h = hour(dt) + minute(dt) / 60 + second(dt) / 3600;
    for i = 2:numel(phase_h)
        while phase_h(i) < phase_h(i - 1) - 6
            phase_h(i) = phase_h(i) + 24;
        end
    end
end
