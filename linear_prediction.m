clearvars
close all
clc

T = readtable('saved_data.csv');

days_ahead = 20;
start_from = '1-Oct-2020';

n = floor(days(datetime(now, 'ConvertFrom','datenum') - datetime(start_from)));

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
f1 = figure('Color','w');
hold on
l1 = bar(t, y);
l2 = plot(x_, yhat, 'r', 'DisplayName', sprintf('Linear trend (last %g days)', n));
legend(l2, 'Location', 'northwest')

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
f2 = figure('Color','w');
hold on
l1 = bar(t, y);
l2 = plot(x_, yhat, 'r', 'DisplayName', sprintf('Linear trend (last %g days)', n));
legend(l2, 'Location', 'northwest')


% figure settings
grid on
title('Nuovi contagi totali')

%%
saveas(f1, 'attualmente_positivi.png')
saveas(f2, 'nuovi_contagi.png')




