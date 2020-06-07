clearvars
close all
clc

T = readtable('saved_data.csv');

target = 'tamponi';

y = T.(target);
y = round(y);


%%
tamponi = T.tamponi;
tamponi = [0; diff(tamponi)];
nuovi_positivi = T.nuovi_positivi;
detection_rate = nuovi_positivi./tamponi;

t = T.data;

my_t = {};
for k = 1:length(t)
    t_ = t{k};
    foo = datetime(t_(1:10));
    my_t = [my_t; foo];
end
t = my_t;

figure('Color','w')
ax(1) = subplot(2,1,1);
plot(t, tamponi, '-o', 'MarkerFace','w', 'MarkerSize',4)
title('tamponi effettuati')
ax(2) = subplot(2,1,2);
plot(t, detection_rate*100, '-o', 'MarkerFace','w', 'MarkerSize',4)
title('percentuale tamponi positivi')
set(ax, 'XGrid', 'on', 'YGrid', 'on')

%%
y = T.deceduti ./ T.totale_casi *100;

figure('Color','w')
plot(t, y, '-o', 'MarkerFace','w', 'MarkerSize',4)
title('Mortality')
grid on




