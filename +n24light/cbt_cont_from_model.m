function out = cbt_cont_from_model(t_dlmo)
%CBT_CONT_FROM_MODEL Continuous CBTmin hours from model DLMO datenum series.

    t_dlmo = t_dlmo(:);
    h0 = (t_dlmo(1) - floor(t_dlmo(1))) * 24;
    dlmo_cont = h0 + (t_dlmo - t_dlmo(1)) * 24;
    out.dlmo_cont = dlmo_cont;
    out.cbt_cont = dlmo_cont + 7;
    out.model_start_dn = t_dlmo(1);
end
