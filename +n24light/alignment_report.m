function rep = alignment_report(sleep_X, light_cont_h)
%ALIGNMENT_REPORT Sleep vs light span and overlap (hours from reference).

    sleep_span = [sleep_X(1), sleep_X(end)];
    light_span = [min(light_cont_h), max(light_cont_h)];
    o0 = max(sleep_span(1), light_span(1));
    o1 = min(sleep_span(2), light_span(2));

    rep.sleep_span_h = sleep_span;
    rep.light_span_h = light_span;
    rep.overlap_h = [o0, o1];
    rep.has_overlap = o1 > o0;
    rep.overlap_duration_h = max(0, o1 - o0);
end
