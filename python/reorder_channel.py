import pandas as pd
pd.set_option('display.max_columns', None)

customer = pd.read_csv('./綠藤企業案例_題目解析與資料集/table 1. Customers.csv')
orders = pd.read_csv('./綠藤企業案例_題目解析與資料集/table 2. Orders.csv')
channels = pd.read_csv('./綠藤企業案例_題目解析與資料集/table 5. Channels.csv')

# 計算購買次數
ord_cnt = orders.groupby(["CustomerId", "TransactionYear"])["OrderId"].count().reset_index()
ord_cnt = ord_cnt.rename(columns={"OrderId": "buy_count"})

# 合併購買次數跟客戶資料
merged = customer.merge(ord_cnt, left_on=['CustomerId', 'FirstTransactionYear'],
                        right_on=['CustomerId', 'TransactionYear'], how='left')\
    .merge(channels,left_on='FirstChannel',right_on='Channel',how='left')

# 計算新客
grouped = merged.groupby(['FirstTransactionYear','ChannelType']).agg({'CustomerId': 'nunique'})
grouped = grouped.rename(columns={'CustomerId': 'new_ord'})

# 回頭客
rep_grouped = merged[merged['buy_count']>=2].groupby(['FirstTransactionYear','ChannelType']).agg({'CustomerId': 'nunique'})
rep_grouped = rep_grouped.rename(columns={'CustomerId': 'rep_ord'})

# 計算結果
final = grouped.merge(rep_grouped, on=['FirstTransactionYear','ChannelType'], how='left')

# Print the final result
print(final)
