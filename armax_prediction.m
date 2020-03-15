clearvars
close all
clc

T = readtable('saved_data.csv');

start_from = 1;

y = T.totale_attualmente_positivi;
t = T.data;

y = y(start_from:end);
t = t(start_from:end);

my_data = iddata(y,[],1);
my_model = armax(my_data, [3 0]);

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
plot(t, y, 'o')
hold on
plot(t_new, yhat, 'o')
plot(t_new, yhat+yf_sd, '-.k')
plot(t_new, yhat-yf_sd, '-.k')

%%
x = 1:length(y);
x = x(:);
p = polyfit(x,log(y),1);

PH = 4;
t_new = t(end);
x_new = x(end);
for n = 1:PH
    t_new = [t_new; t_new(end)+days(1)];
    x_new = [x_new; x_new(end)+1];
end
t_new = t_new(2:end);
x_new = x_new(2:end);
yhat = polyval(p, x_new);

figure('Color','w')
plot(t, exp(log(y)), 'o')
hold on
plot(t_new, exp(polyval(p, x_new)),'o')
grid on


%%
disp(yhat(2))
disp(yhat(end))


