
WITH ord_cnt AS
(SELECT Orders.customerid, Orders.TransactionYear, COUNT(orderid) AS 'buy_count'
FROM Orders
GROUP By 1,2),

order_core AS(
SELECT Customers.FirstTransactionYear, Customers.CustomerId 
FROM Customers
join Orders
on Customers.CustomerId = Orders .customerid
and Orders.TransactionDate = Customers.FirstTransactionDate
join OrderDetails
on Orders.OrderId = OrderDetails.OrderId
left join (SELECT * FROM Products WHERE producttype =='核心產品') AS Product_Core
ON OrderDetails.productid = Product_Core.productid
WHERE Product_Core.productid is not null
),

order_road AS(
SELECT Customers.firsttransactionyear, Customers.CustomerId 
FROM Customers
join Orders
on Customers.CustomerId = Orders .customerid
and Orders.TransactionDate = Customers.FirstTransactionDate
join OrderDetails
on Orders.OrderId = OrderDetails.OrderId
left join (SELECT * FROM Products WHERE producttype =='帶路產品') AS Product_Road
ON OrderDetails.productid = Product_Road.productid
WHERE Product_Road.productid is not null
)

SELECT Customers.FirstTransactionYear ,Channels.ChannelType,
	COUNT(DISTINCT Customers.CustomerId) AS 'new_cus', 
    COUNT(DISTINCT order_cnt.customerid) AS 'rep_cus'
FROM Customers 
LEFT JOIN (SELECT * FROM ord_cnt WHERE ord_cnt.`buy_count` >= 2) AS 'order_cnt'
ON Customers.CustomerId = order_cnt.customerid
AND Customers.firsttransactionyear = order_cnt.TransactionYear
JOIN Channels
on Customers.FirstChannel = Channels.Channel
LEFT JOIN order_core
ON order_core.customerid = Customers.CustomerId
LEFT JOIN order_road
ON order_road.customerid = Customers.CustomerId
WHERE (order_core.customerid is  NULL) AND (order_road.customerid is  NULL)
GROUP BY 1,2;
