clear
close all
clc
syms q
s = tf('s');

ts = 5e-5;
kp_vpv = 0.1;%0.95e-1; 
kp_ipv = 0.05; %0.02

% ki_vpv = 100;
ti_vpv = 0.65e-2; %0.065e-1
ti_ipv = 6e-4; %6e-4

a1_vpv = -kp_vpv;
a0_vpv = kp_vpv*(1 + ts/ti_vpv);

% ki_ipv = 100000;
a1_ipv = -kp_ipv;
a0_ipv = kp_ipv*(1 + ts/ti_ipv);

piv = kp_vpv*(1+1/(ti_vpv*s));
pii = kp_ipv*(1+1/(ti_ipv*s));

pivq = kp_vpv*(1+1/(ti_vpv*q));
piiq = kp_ipv*(1+1/(ti_ipv*q));

L = 3e-3;
Cpv = 0.75e-3;
% shallow      -3.1895e-04
% MPP          -0.0254
% right-hand   -0.1340
rpvi = 1/0.134; % slope = 1/R
Vdc = 400;

A = [0   1/L;
    -1/Cpv 1/(rpvi*Cpv);];
B = [-Vdc/L;0;];
C = [0 1];
D = [0];

[b,a] = ss2tf(A,B,C,D);
Gvd = tf(b,a);
% figure(1)
% bode(Gvd)

C = [1 0];
[b,a] = ss2tf(A,B,C,D);
Gid = tf(b,a);
% figure(2)
% bode(Gid)

inner = feedback(pii,Gid,-1);
ol = piv*inner*Gvd;
sys = feedback(-ol,1);
newsys = ol/(ol-1);
figure(1)
bode(sys)
figure(2)
margin(sys)
% figure(3)
% bode(newsys)
% figure(4)
% margin(newsys)

%% symbolic
clear
syms kp_vpv kp_ipv ti_vpv ti_vpv L Cpv rpvi Vdc
A = [0   1/L;
    -1/Cpv 1/(rpvi*Cpv);];
B = [-Vdc/L;0;];
C = [0 1];
D = [0];

% Gvd = 

piv = kp_vpv*(1+1/(ti_vpv*s));
pii = kp_ipv*(1+1/(ti_ipv*s));

inner = feedback(pii,Gid,-1);
ol = piv*inner*Gvd;
newsys = ol/(ol-1);