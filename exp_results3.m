close all
clear 
clc

%% import data
% peview_data1 = readmatrix('data/sig3_newright_thresh50.csv');
peview_data1 = readmatrix('data/plunge_thresh30_intfix.csv');
t1 = peview_data1(2:end,1);
vpv1 = peview_data1(2:end,2);
ipv1 = peview_data1(2:end,3);
dpv1 = peview_data1(2:end,4);
vdc1 = peview_data1(2:end,8);
ppv1 = peview_data1(2:end,11);
ipv_ref1 = peview_data1(2:end,5);
vpv_err1 = peview_data1(2:end,6);
vpv_ref1 = peview_data1(2:end,7);
mode1 = peview_data1(2:end,9);
s_k1 = peview_data1(2:end,10);
% A = peview_data1(2:end,)

% sasdata = readmatrix('data/sig3rampslow_newright_SAS.csv');
sasdata = readmatrix('data/oahu_plunge30_intfix_SAS.csv');
t2 = sasdata(:,2);
pmp2 = sasdata(:,5);
irr2 = sasdata(:,12);

%% plotting
close all
% figure(1)
% plot(t1,ipv1,'DisplayName','Ipv');
% hold on
% plot(t1,ipv_ref1,'DisplayName','Iref');
% % xlim([1.85 4.3])
% xlabel('Time (s)')
% ylabel('Current (A)')
% title('Current & Reference, Left-Side')
% legend('Location','best')
% 
figure(2)
plot(t1,vpv1,'DisplayName','Vpv');
hold on
% plot(t1,vpv_ref1,'DisplayName','Vref');
% xlim([8 16])
xlabel('Time (s)')
ylabel('Voltage (V)')
title('Voltage During Dips')
legend('Location','best')

Pres = 500;

figure(3) % error / realignment should only work for ramp
% nd = length(ppv1);
% t_start = 297; %116
% t_end = 522; %457
offset = 9.98;
tsas = t2 + offset;
plot(tsas,pmp2,'DisplayName','Pmax')
hold on
plot(t1,ppv1,'DisplayName','Ppv')
plot(tsas,pmp2-Pres,'DisplayName','Pres')
% xlim([0 1000])
% ylim([0 2000])
xlabel('Time (s)')
ylabel('Power (W)')
title('Basic PRC Under Irradiance Dip')
legend('Location','best')

% [m1,i1] = min(abs(t1 - offset));
% [m2,i2] = min(abs(t1 - (offset+max(t2))));

% i1 = ((10)/0.02) + 1;
% i2 = ((1010)/0.02) + 1;
% ppv_adj = ppv1(i1:i2);
% t1_adj = t1(i1:i2) - offset;
% target = interp1(t2,pmp2-Pres,t1_adj);
% target(1) = target(2);
% 
% error_arr = abs(ppv_adj - target)./target;
% error_arr(end) = 0;
% error_avg = mean(error_arr)*100

figure(4)
plot(t1,s_k1)
title('Sampling Array Index')
xlabel('Time (s)')
ylabel('# of samples + 1')

figure(6)
Vrange = linspace(280,320,2000);
hold on
% a = -0.96843932658583121;%form(1);
% b = 658.37830326275071;%form(2);
% c = -109786.37576769135;%form(3);
a = -38.03344;%form(1); %890s - 918.4s, first flat part
b = 24165.04;%form(2);
c = -3836746.5;%form(3);
curve = @(v)a*v.^2 + b*v + c;
plot(Vrange,curve(Vrange),'DisplayName','Fit Curve 1');

a = 7.95002651;%form(1); 918.4-921.4, last mode 2 sec
b = -4859.147;%form(2);
c = 743178;%form(3);
curve = @(v)a*v.^2 + b*v + c;
plot(Vrange,curve(Vrange),'DisplayName','Fit Curve 2');

a = -25.27544;%form(1); 923.7, small part at the bottom
b = 15697.457;%form(2);
c = -2435180.75;%form(3);
curve = @(v)a*v.^2 + b*v + c;
plot(Vrange,curve(Vrange),'DisplayName','Fit Curve 3');

% a = -53.5178261;%form(1); one of the oscillations at 975
% b = 33035.4453;%form(2);
% c = -5095987.5;%form(3);
% curve = @(v)a*v.^2 + b*v + c;
% plot(Vrange,curve(Vrange),'DisplayName','Fit Curve 1');
% 
% a = 2.26521468;%form(1); 975-978.4
% b = -1382.50684;%form(2);
% c = 212159.734;%form(3);
% 
% curve = @(v)a*v.^2 + b*v + c;
% plot(Vrange,curve(Vrange),'DisplayName','Fit Curve 2');
% 
% a = 32.7424126;%form(1); 978.4 - end
% b = -20513.5547;%form(2);
% c = 3214302.75;%form(3);
% curve = @(v)a*v.^2 + b*v + c;
% plot(Vrange,curve(Vrange),'DisplayName','Fit Curve 3');



% curve = @(v)a*v.^2 + b*v + c;
% plot(Vrange,curve(Vrange),'DisplayName','Fit Curve');

Varr = [304.137177,304.641327,305.2859];
Parr = [870.8644,905.5584,949.198059];
plot(304.7251,1217.088,'rx','DisplayName','New Sample');
title('Fit Curves During Dips')
xlim([290 320])
ylim([0 2100])
legend
xlabel('Voltage (V)')
ylabel('Power (W)')

% figure(5)
% plot(t1,s_k1)
% title('Ppva Index')

