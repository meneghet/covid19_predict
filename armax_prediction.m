clearvars
close all
clc

T = readtable('saved_data.csv');

target = 'totale_attualmente_positivi';

start_from = 1;

y = T.(target);
t = T.data;

y = y(start_from:end);
t = t(start_from:end);

% x = zeros(size(y));
% x(1) = 1;
% my_data = iddata(y,x,1);

my_data = iddata(y,[],1);

%%

N = 4;
my_model = armax(my_data, [N 0]);

% figure
% impulse(my_model)

%%

PH = 4;
t_new = [t(end)];
for n = 1:PH
    t_new = [t_new; t_new(end)+days(1)];
end

[yhat,x0,sysf,yf_sd,x,x_sd] = forecast(my_model,my_data,PH);
yhat = yhat.y;
yhat = round(yhat);
yhat = [my_data.y(end); yhat];
yf_sd = [0; yf_sd];

figure('Color','w')
hold on
plot(t_new, yhat, 'or')
plot(t, y, 'ob')
plot(t_new, yhat+yf_sd, '-.k')
plot(t_new, yhat-yf_sd, '-.k')

grid on


%%
today = datetime(floor(now),'convertfrom','datenum');
disp(target)
today_pred = round(yhat(2));
today_sd = round(yf_sd(2));
fprintf('Predizione per %s: \n %i +- %i \n', datestr(today), today_pred, today_sd)



