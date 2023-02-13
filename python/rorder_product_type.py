import pandas as pd
pd.set_option('display.max_columns', None)

customers = pd.read_csv('./綠藤企業案例_題目解析與資料集/table 1. Customers.csv')
orders = pd.read_csv('./綠藤企業案例_題目解析與資料集/table 2. Orders.csv')
orderDetails = pd.read_csv('./綠藤企業案例_題目解析與資料集/table 3. OrderDetails.csv')
products = pd.read_csv('./綠藤企業案例_題目解析與資料集/table 4. Products.csv')

ord_cnt = orders.groupby(["CustomerId", "TransactionYear"])["OrderId"].count().reset_index()
ord_cnt = ord_cnt.rename(columns={"OrderId": "buy_count"})


orders_core = customers.merge(orders, left_on=['CustomerId', 'FirstTransactionDate'],right_on=['CustomerId','TransactionDate'],
                              how='left')\
    .merge(orderDetails, on='OrderId', how='left')\
    .merge(products[products['ProductType'] == '核心產品'], on='ProductId', how='left').dropna(how='any')
orders_core = orders_core[['CustomerId','ProductType']]

orders_road = customers.merge(orders, left_on=['CustomerId', 'FirstTransactionDate'],right_on=['CustomerId','TransactionDate'],
                              how='left')\
    .merge(orderDetails, on='OrderId', how='left')\
    .merge(products[products['ProductType'] == '帶路產品'], on='ProductId', how='left').dropna(how='any')\
    .drop_duplicates(subset=['CustomerId', 'FirstTransactionYear'])
orders_road = orders_road[['CustomerId','ProductType']]

df = customers.merge(ord_cnt,
                     left_on=['CustomerId', 'FirstTransactionYear'],
                     right_on=['CustomerId', 'TransactionYear'],
                     how='left')
df = df.merge(orders_core, on='CustomerId', how='left')
df = df.merge(orders_road, on='CustomerId', how='left', suffixes=('', '_road'))
df = df[['FirstTransactionYear','CustomerId','buy_count','ProductType','ProductType_road']]

# new_ord
new_ord = df.groupby(['FirstTransactionYear']).agg({'CustomerId': 'nunique'})

# rep_ord
rep_ord = df[df['buy_count']>=2]\
    .groupby(['FirstTransactionYear'])\
    .agg({'CustomerId': 'nunique'})\
    .rename(columns={'CustomerId':'rep_ord'})

#只買核心商品
only_core = df[(df['ProductType'].notnull())&(df['ProductType_road'].isnull())]\
    .groupby(['FirstTransactionYear']).agg({'CustomerId': 'nunique'})\
    .rename(columns={'CustomerId': 'only_core'})

#只買帶路商品
only_road = df[(df['ProductType'].isnull())&(df['ProductType_road'].notnull())]\
    .groupby(['FirstTransactionYear']).agg({'CustomerId': 'nunique'})\
    .rename(columns={'CustomerId':'only_road'})

# 都買
both = df[(df['ProductType'].notnull())&(df['ProductType_road'].notnull())]\
    .groupby(['FirstTransactionYear']).agg({'CustomerId': 'nunique'})\
    .rename(columns={'CustomerId':'both'})

# others
others = df[(df['ProductType'].isnull())&(df['ProductType_road'].isnull())]\
    .groupby(['FirstTransactionYear']).agg({'CustomerId': 'nunique'})\
    .rename(columns={'CustomerId':'others'})

result = new_ord.merge(rep_ord,on='FirstTransactionYear').merge(only_core,on='FirstTransactionYear')\
    .merge(only_road,on='FirstTransactionYear').merge(both,on='FirstTransactionYear').merge(others,on='FirstTransactionYear')
print(result)
