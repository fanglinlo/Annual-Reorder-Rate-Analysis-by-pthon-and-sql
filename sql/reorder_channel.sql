-- 購買次數
WITH ord_cnt AS
(SELECT Orders.customerid, Orders.TransactionYear, COUNT(orderid) AS 'buy_count'
FROM Orders
GROUP By 1,2)

SELECT Customers.FirstTransactionYear ,Channels.ChannelType,
	COUNT(DISTINCT Customers.CustomerId) AS 'new_cus', 
    COUNT(DISTINCT order_cnt.customerid) AS 'rep_cus'
FROM Customers 
LEFT JOIN (SELECT * FROM ord_cnt WHERE ord_cnt.`buy_count` >= 2) AS 'order_cnt'
ON Customers.CustomerId = order_cnt.customerid
AND Customers.firsttransactionyear = order_cnt.TransactionYear
JOIN Channels
on Customers.FirstChannel = Channels.Channel
GROUP BY 1,2;
