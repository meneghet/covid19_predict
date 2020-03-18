import requests
import pandas as pd

url = 'https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-andamento-nazionale.json'
start_from = '2020-02-20'

response = requests.get(url)
my_data = response.json()
df = pd.DataFrame.from_dict(my_data)
df['data'] = [x.split()[0] for x in df['data']]

# save data
pd.DataFrame.to_csv(df,'saved_data.csv')