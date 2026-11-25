function dVdt = hilaire_de2(t,V,p,t1,dt,Lext,SWext)

%I = light(t,L);
%I=0;
%I = 100*(mod(t,24)>8);
%t
tn = min(1+floor((t-t1)/dt),length(Lext));
I = Lext(tn);
S = SWext(tn);
%I = interp1(text,Lext,t);
%S = interp1(text,SWext,t);
%S=0;

alpha = p{11}*((I/p{12}).^p{13}).* I./(I+p{14}); % define alpha (retinal activation rate)
B = (1-p{15}*V(2)).*(1-p{15}*V(3))*p{16}*alpha*(1-V(1)); % define B (retinal drive to pacemaker)

Nhat = p{10}*(S+0.333);
NS = Nhat*(1-tanh(V(2)));


%% 
% V(1) means: n
% V(2) means: x
% V(3) means: x_c

dVdt = [...
    60*(alpha*(1-V(1)) - p{9}*V(1)); % = dn/dt
p{1}*(V(3) + B + NS + p{2}*(p{3}*V(2) + p{4}*V(2)^3 + p{5}*V(2)^7)); ... % = dx/dt
p{1}*(B*(p{6}*V(3) - p{7}*V(2)) - V(2)*p{8})]; % = dx_c/dt


end