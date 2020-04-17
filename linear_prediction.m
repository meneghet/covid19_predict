clearvars
close all
clc

T = readtable('saved_data.csv');

days_ahead = 45;
start_from = '21-Mar-2020';

%% make time
t = T.data;

my_t = {};
for k = 1:length(t)
    t_ = t{k};
    foo = datetime(t_(1:10));
    my_t = [my_t; foo];
end
t = my_t;

%% incremento giornaliero sul totale degli ATTUALMENTE positivi
target = 'totale_positivi';

% select data portion for training
t1 = find(t == datetime(start_from));
y = round(T.(target));
y = [0; diff(y)];
y_ = y(t1:end)';

% estimate linear model
coeff = polyfit(1:length(y_), y_, 1);
q = coeff(2);
m = coeff(1);

% make prediction using linear model coefficients
x = t1:t1+days_ahead;
yhat = m*(1:length(x)) + q;
yhat(yhat<0) = nan;

% datetime array for plotting prediction
x_ = t(t1) + days(0:days_ahead);

% plot
figure('Color','w')
hold on
bar(t, y)
plot(x_, yhat, 'r')

% figure settings
grid on
title('Incremento giornaliero degli attualmente positivi')

%% nuovi positivi sono i casi nuovi TOTALI (senza contare guariti e deceduti)
target = 'nuovi_positivi';

y = T.(target);
y = round(y);

% select data portion for training
t1 = find(t == datetime(start_from));
y_ = y(t1:end)';

% estimate linear model
coeff = polyfit(1:length(y_), y_, 1);
q = coeff(2);
m = coeff(1);

% make prediction using linear model coefficients
x = t1:t1+days_ahead;
yhat = m*(1:length(x)) + q;

% datetime array for plotting prediction
x_ = t(t1) + days(0:days_ahead);

% plot
figure('Color','w')
hold on
bar(t, y)
plot(x_, yhat, 'r')


% figure settings
grid on
title('Nuovi contagi totali')




