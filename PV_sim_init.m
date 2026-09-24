clear
clc
close all

% Perrs = [5000 3000 2000 1000 500 300];
% dVs = [15 6 1.5 0.5 0.25 0.1];
% plot(Perrs, dVs);

year_data = readmatrix('data\2023_NREL_Irradiance.csv');
GHI = year_data(:,7);
%plot(GHI)
sunny_day1 = GHI(1903:2014);
sun_sum = GHI(50250:50433);
ghi_roc = diff(sun_sum);
% max clear is 20 W / 5 min


clouds_midday = GHI(56060:56142);
cloud_slice = clouds_midday(14:24);
slice_2 = GHI(51532:51542);
slice_3 = GHI(63853:63863);
slice_31 = slice_3(7:end);

%oahu june 11,13 2010

%1 second irradiance file
oahu_61310 = readmatrix('data\solardata\20100613.txt');
ghi613 = oahu_61310(:,5);
sec613 = oahu_61310(:,1);
time613 = oahu_61310(:,4);
slice_oahu = ghi613(8000:10000);
slice2_oahu = ghi613(19473:19673); %plunge
slice21_oahu = slice2_oahu(50:175);
slice22_oahu = ghi613(19884:19984); %dip
slice3_oahu = ghi613(12800:13000);
slice31_oahu = ghi613(12897:12917); 
slice4_oahu = ghi613(32000:34000);
slice5_oahu = ghi613(30700:30900);
slice6_oahu = ghi613(27400:27600);
slice7_oahu = ghi613(14000:14200);
t_tot = 200;
time = linspace(0,t_tot,length(slice2_oahu));
irr_sig = [time' slice2_oahu];

% 30 min temperature file, same time
oahu_6temp = readmatrix('data\solardata\201006temp.csv');
temp613 = oahu_6temp(587:617,6);
irr613 = oahu_6temp(587:617,7);
hour613 = oahu_6temp(587:617,4);
min613 = oahu_6temp(587:617,5);
tempsec = (hour613-5).*3600 + min613.*60;
new_secs = linspace(0,54000,54001);
ext_temp = interp1(tempsec,temp613,new_secs);
title_row = ["Index","IrraSlope","Irra","TempSlope","Temp","Sec"];
index = linspace(0,54000,54001);
csvout_temp = zeros(54002,6);
csvout_temp(1,:) = title_row;
csvout_temp(2:end,1) = index;
csvout_temp(2:end,3) = ghi613;
csvout_temp(2:end,6) = new_secs;
csvout_temp(2:end,5) = ext_temp;
irra_slope = zeros(54001,1);
temp_slope = zeros(54001,1);
for i = 1:1:54000
    irra_slope(i) = ghi613(i+1) - ghi613(i);
    temp_slope(i) = ext_temp(i+1) - ext_temp(i);
end
irra_slope(end) = 0;
temp_slope(end) = 0;
csvout_temp(2:end,2) = irra_slope;
csvout_temp(2:end,4) = temp_slope;

%% make SAS files from temp csv
simpleramp_SAS = [title_row;csvout_temp(11000:12000,:)];
simpleramp_SAS(2:end,1)=linspace(1,1001,1001);
simpleramp_SAS(2:end,6)=ones(1001,1);
writematrix(simpleramp_SAS,'data/simpleramp_SAS.csv');
decrease_SAS = [title_row;csvout_temp(38200:39200,:)];
decrease_SAS(2:end,1)=linspace(1,1001,1001);
decrease_SAS(2:end,6)=ones(1001,1);
writematrix(decrease_SAS,'data/decrease_SAS.csv');
plunge_SAS = [title_row;csvout_temp(19000:20000,:)];
plunge_SAS(2:end,1)=linspace(1,1001,1001);
plunge_SAS(2:end,6)=ones(1001,1);
writematrix(plunge_SAS,'data/plunge_SAS.csv');
dip_SAS = [title_row;csvout_temp(12500:13000,:)];
dip_SAS(2:end,1)=linspace(1,501,501);
dip_SAS(2:end,6)=ones(501,1);
writematrix(dip_SAS,'data/dip_SAS.csv');
highramp_SAS = [title_row;csvout_temp(14000:15000,:)];
highramp_SAS(2:end,1)=linspace(1,1001,1001);
highramp_SAS(2:end,6)=ones(1001,1);
writematrix(highramp_SAS,'data/highramp_SAS.csv');

% plot(ghi613)
% hold on
% plot(tempsec,temp613)

%% controller init
ts = 5e-5;
Vdc_sim =400;
kp_vpv = 0.1; %0.85e-1 %0.25
kp_ipv = 0.1; %0.02 %0.2

% ki_vpv = 100;
ti_vpv = 0.065e-1; %0.09e-1 %0.48e-2
ti_ipv = 6e-4; %6e-4

a1_vpv = -kp_vpv;
a0_vpv = kp_vpv*(1 + ts/ti_vpv);

% ki_ipv = 100000;
a1_ipv = -kp_ipv;
a0_ipv = kp_ipv*(1 + ts/ti_ipv);

%% run
out = sim('newPVmethod_1.slx');

%% plotting
close all
t = out.fxn.time;
t2 = out.power.time;
results = reshape(out.fxn.signals.values,[2,length(t)]);
power = out.power.signals.values;
target = power(:,3);
pmax = power(:,2);
ppv = power(:,1);

figure(1)
plot(t,results(1,:))
title('Mode')

% figure(2)
% plot(t,results(2:4,:))
% title('Curve Fit Power Points')

figure(3)
plot(t,results(2,:))
title('Ppva Index')

figure(4)
plot(t2,ppv,'LineWidth',1.5,'DisplayName','Ppv')
hold on
plot(t2,target,'LineWidth',1.5,'DisplayName','Preserve')
plot(t2,pmax,'DisplayName','MPP')
xlabel('Time (s)')
ylabel('Power (W)')
title('Basic PRC Under Irradiance Dips')
legend
grid on

% figure(6)
% plot(t,results(8,:))
% yyaxis right
% plot(t,results(10,:))
% % plot(t,results(8,:)./results(10,:))
% title('dP & dV')

% slope = results(8,:)./results(10,:);
% slope = rmmissing(slope);
% res = out.diag.signals.values;

% f1 = figure('Position',[200 100 550 400]);
% plot(t,i_a,'LineWidth',1.5,'DisplayName','$I_{alpha}$');
% hold on
% plot(t,ref_a,'LineWidth',1.5,'DisplayName','$I_{ref}$');
% xlabel('Time (s)')
% ylabel('Current (A)')
% title('Current vs. Error')
% legend('Interpreter','latex')

%% error
% err_corr = 7.6e4*ones(40,1);
% target_corr = [err_corr; target(41:end)];
error_arr = abs(ppv - target)./target;
error_avg = mean(error_arr)*100

