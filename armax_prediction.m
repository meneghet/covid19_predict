clearvars
close all
clc

T = readtable('saved_data.csv');

% 'terapia_intensiva'
% 'totale_positivi'
% 'dimessi_guariti'
% 'deceduti'
% 'totale_casi'
% 'nuovi_positivi'

target = 'nuovi_positivi';
PH = 45; % days

%% prepare data
y = round(T.(target));
% y = [0; diff(y)];
my_data = iddata(y,[],1);

%% prepare time data
t = T.data;
my_t = {};
for k = 1:length(t)
    t_ = t{k};
    foo = datetime(t_(1:10)); % strip hours
    my_t = [my_t; foo];
end
t = my_t;

%% select validation days

validation_n = 2; % days

% validation_pct = 0.2;
% validation_n = round(length(my_data.y) * validation_pct);

%% try different orders for the armax model on a validation subset

% select validation portion
my_data_tr = my_data(1:end-validation_n);

orders_N = 3:15;

val_mse = nan*ones(max(orders_N),1);
for N = orders_N
    try 
        my_model = armax(my_data_tr, [N 0]);
    catch
        continue
    end
    [yhat,x0,sysf,yf_sd,x,x_sd] = forecast(my_model,my_data_tr,validation_n+1);
    
    yhat_val = round(yhat.y(2:end));
    val_mse(N) = mean(abs(yhat_val - my_data.y(end-validation_n+1:end)));
end

% plot rmse with different orders
figure('Color','w')
plot(val_mse)
xlabel('order')
ylabel('MSE')

% select best order
[~,  N] = min(val_mse);
fprintf('Best order: %i\n', N)

%% predict

% identify and predict
my_data_tr = my_data(1:end-validation_n);
my_model = armax(my_data_tr, [N 0]);
PH = PH + validation_n;
[yhat,x0,sysf,yf_sd,x,x_sd] = forecast(my_model,my_data_tr,PH);
yhat = yhat.y;
yhat = round(yhat);
yhat = [my_data_tr.y(end); yhat];
yf_sd = [0; yf_sd];

% prediction time
t_tr = t(1:end-validation_n);
t_new = [t_tr(end)];
for n = 1:PH
    t_new = [t_new; t_new(end)+days(1)];
end

% plot
figure('Color','w')
hold on
plot(t_new, yhat, 'or')
plot(t, my_data.y, 'ob')
% plot(t_new, yhat+yf_sd, '-.k')
% plot(t_new, yhat-yf_sd, '-.k')
grid on
ylim([0 max(yhat)*1.5])
title(sprintf('%s',target),'Interpreter','none')

%% print prediction for today
today = datetime(floor(now),'convertfrom','datenum');
disp(target)
today_pred = round(yhat(2+validation_n));
today_sd = round(yf_sd(2+validation_n));
fprintf('Predizione per %s: \n %i +- %i \n', datestr(today), today_pred, today_sd)






