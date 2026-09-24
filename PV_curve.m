%% SAS PV Curves
clear
close all
clc

idx = 1;
jdx = 1;
deltaP = 500;
for G = 705:5:715
    temp = readmatrix(strcat('data/ExportIVCurve_',num2str(G)));
    irr(idx,:,:) = temp(:,1:4);
    v(idx,:) = irr(idx,:,2);
    p(idx,:) = irr(idx,:,4);
    xq(idx,:) = linspace(0,max(v(idx,:)),2000);
    vq(idx,:) = interp1(v(idx,:),p(idx,:),xq(idx,:));
    figure(1)
    plot(xq(idx,:),vq(idx,:),DisplayName=strcat(num2str(G),' W/m2'))
    hold on
    [m,i] = max(vq(idx,:));
    plot(xq(idx,i),vq(idx,i),'x','Color','black','HandleVisibility','off');
    Pmax(idx) = m;
    Vmax(idx) = xq(idx,i);
    if m > deltaP
        respow = m - deltaP;
        [b,d] = min(abs(vq(idx,i:end) - respow));
        Pres(jdx) = vq(idx,d+i-1);
        Vres(jdx) = xq(idx,d+i-1);
        plot(Vres(jdx),Pres(jdx),'o','Color','red');
        jdx = jdx+1;
    end
    idx = idx+1;
end
p = polyfit(Vres,Pres,2);
% fitv = linspace(286,325,500);
fitv = linspace(300,320,1000);
f = polyval(p,Vmax);
[r2 rmse] = rsquare(Pmax,f);
plot(fitv,polyval(p,fitv),'DisplayName','Fit Curve')
xlim([310 312])
xlabel('Voltage (V)')
ylabel('Power (W)')
title('PV Emulator Curves w/ Local RPP Fit')
legend('705 W/m2','','710 W/m2','','715 W/m2','RPPs','Fit Curve')
% legend('location','Northwest')
%% Single Diode PV Curves
clear
clc
close all

deltaP = 500;
Isc = 7.84;
Voc = 36.3;
Kv = -.36099;
Ki = 0.102;
Rp = 313.3991;
Rs = 0.39383;
a = 0.98117;
Ns = 60;
Tn = 25+273.15;
Gn = 1000;
kq = 1.38e-23 / 1.6e-19;
ser = 10;
par = 1;

% L = 30.31e-6; % assignment 1
% Rc = 0.95e-3; %


T = Tn;
function y = pvsys(x,Ipv,Io,Rs,Rp,Vt,a)
%x(1) is voltage, x(2) current, T is temp
y(1) = -x(2) + Ipv - Io*(exp((x(1)+Rs*x(2))/(Vt*a))-1) - (x(1)+Rs*x(2))/Rp;
y(2) = -x(1)*45+690*x(2)*0.3; %magic numbers for series, parallel, load
end

function y = ivcurve(x,V,Iph,Io,Rs,Rp,Vt,a)
%take array of voltages, x is currents
n = length(V);
y(1:n) = -x(1:n) + Iph - Io.*( exp( (V(1:n)+Rs.*x(1:n))./(Vt*a) ) -1) - (V(1:n)+Rs.*x(1:n))./Rp;
end

idx = 1;
Vt = T*kq*Ns;
test = zeros(1,2);
for G = 1000

Vocfxn = Voc(1+Kv*(T-Tn)) + Vt*a*log(G/Gn);
Iph = Isc*(G/Gn)*(1+Ki*(T-Tn));

Io = (Iph) / ( exp((Vocfxn)/(Vt*a))-1);

% Ipv = @(T)(((Isc*(Rp+Rs)/Rp))+Ki*(T-Tn))*(G/Gn); %with Rs
%Ipv = @(T) Isc %step 1, without the resistances
%Id = @(T) Io(T)*exp((V+Rs*I)/(Vt*a)) - 1; %__


% f = @(x)pvsys(x,Ipv(T),Io(T),Rs,Rp,Vt,a);
% xsolve = fsolve(f,[0 0]);
% 
% Ipanel = xsolve(2)
% Vpanel = xsolve(1)
% Ia = xsolve(2)*par
% Va = xsolve(1)*ser
% Pa = Ia*Va


%now find PV / Load curves

% Vrange = linspace(0,Vocfxn,1531); %1531
Vrange = 0:0.01:Voc;

q = @(x)ivcurve(x,Vrange,Iph,Io,Rs,Rp,Vt,a);
isolve = fsolve(q,zeros(1,length(Vrange)));
% plot([Vrange Voc],[isolve 0],'.') %iv
% hold on
% plot(Vpanel,Ipanel,'x') %op
% hold off

lastIdx = find(isolve >= 0, 1, 'last');
voc_int = interp1(isolve,Vrange,0);
Iplot = par*[isolve(1:lastIdx) 0];
Vplot = ser*[Vrange(1:lastIdx) voc_int];
Pplot = Vplot.*Iplot;

figure(1)
plot(Vplot,Pplot,'DisplayName','Power') %pv
hold on
[m,i] = max(Pplot);
Pmax(idx) = m;
Vmax(idx) = Vplot(i);
% plot(Vplot(i),m,'x','Color','black','HandleVisibility','off')
if m > deltaP
    respow = m - deltaP;
    [b,d] = min(abs(Pplot(i:end) - respow));
    Pres(idx) = Pplot(d+i-1);
    Vres(idx) = Vplot(d+i-1);
    test(idx) = d+i-1;
    % if(idx == 3)
    %     Pres(3) =Pres(3) - 0.15*-29.118905047047743;
    %     Vres(3) = Vres(3) - 0.15;
    % end
    plot(Vres(idx),Pres(idx),'o','Color','red');%,'HandleVisibility','off');
    % [b,d] = min(abs(Pplot(1:i) - respow));
    % plot(Vplot(d),Pplot(d),'o','Color','red','DisplayName','RPPs')
    idx = idx+1;
end
slope = zeros(1,length(Vplot));
for j=1:1:(length(Vplot)-1)
    slope(j) = (Iplot(j) - Iplot(j+1))/(Vplot(j) - Vplot(j+1));
end
end

figure(1)
plot(Vplot(test(1)),Pplot(test(1)),'x','Color','black')
xlabel('Voltage (V)')
ylabel('Power (W)')
% p = polyfit(Vres,Pres,2);
fitv = linspace(318,339.8,1000);
f = polyval(p,Vres);
[r2 rmse] = rsquare(Pres,f);
plot(fitv,polyval(p,fitv),'DisplayName','Fit Curve')
xlim([332 334])
title('Local Reserve Power Point Curve w/ Expanded View')
% legend('','','','RPPs','','','','','','','','','','','','','','','Fit Curve')
legend('700 W/m2','','705 W/m2','','715 W/m2','RPPs','Fit Curve')