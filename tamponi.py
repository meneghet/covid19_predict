import requests
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.dates import DateFormatter
import seaborn as sns
import os
import numpy as np
from sklearn import linear_model

url = 'https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-andamento-nazionale.json'
start_from = '2020-02-20'

response = requests.get(url)
my_data = response.json()
df = pd.DataFrame.from_dict(my_data)
df['data'] = [x.split()[0] for x in df['data']]

# save data
pd.DataFrame.to_csv(df,'saved_data.csv')

# start from selected day
d = (df['data'] == start_from).idxmax()
df = df.iloc[d:, :]

tamponi = df.tamponi
# tamponi_per_day = np.diff(tamponi)
tamponi_per_day = np.insert(np.diff(tamponi), 0, 0, axis=0)

nuovi_positivi = df.nuovi_positivi
detection_rate = nuovi_positivi/tamponi_per_day

t = pd.to_datetime(df.data)
# t = t.strftime('%d-%b')

fig, ax = plt.subplots(2,1,figsize=[8,10])
ax[0].bar(t, tamponi_per_day)
ax[0].set_title('tamponi effettuati')
ax[1].bar(t, detection_rate*100)
ax[1].set_title('percentuale tamponi positivi')

for a in ax:
    a.set_xticks(t[0:-1:5]);
    a.xaxis.set_major_formatter(DateFormatter("%d-%m"))
    a.grid(axis='y')
    
plt.show()