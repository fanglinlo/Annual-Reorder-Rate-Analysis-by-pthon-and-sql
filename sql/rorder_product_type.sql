
-- 先算出客戶購買次數
WITH Orders_Count AS (
SELECT
  customerid
  ,transactionyear
  ,count(distinct orderid) as order_cnt
FROM Orders
GROUP BY 1,2
),

-- 購買核心商品
Orders_Core AS
(SELECT Customers.FirstTransactionYear, Customers.CustomerId
  FROM Customers
LEFT JOIN Orders
  on Customers.CustomerId = Orders.CustomerId
 AND Customers.FirstTransactionDate = Orders.TransactionDate
LEFT join OrderDetails
  on Orders.orderid = OrderDetails.OrderId
LEFT JOIN (SELECT * FROM Products WHERE ProductType == '核心產品') AS Product_core
  on OrderDetails.ProductId = Product_core.productid
WHERE Product_core.productid is NOT NULL),

-- 購買帶路商品
Orders_road AS
(SELECT Customers.FirstTransactionYear, Customers.CustomerId
  FROM Customers
LEFT JOIN Orders
  on Customers.CustomerId = Orders.CustomerId
 AND Customers.FirstTransactionDate = Orders.TransactionDate
LEFT join OrderDetails
  on Orders.orderid = OrderDetails.OrderId
LEFT JOIN (SELECT * FROM Products WHERE ProductType == '帶路產品') AS Product_road
  on OrderDetails.ProductId = Product_road.productid
WHERE Product_road.productid is NOT NULL)

SELECT Customers.FirstTransactionYear, 
	COUNT(DISTINCT Customers.CustomerId) AS 'new_cnt',
	COUNT (DISTINCT rep_order.customerid) as rep_cnt
FROM Customers
left JOIN (SELECT * FROM Orders_Count WHERE order_cnt >= 2) AS rep_order
ON rep_order.customerid = Customers.customerid
AND rep_order.transactionyear = Customers.FirstTransactionYear
LEFT join Orders_Core 
on Orders_Core.customerid = Customers.CustomerId
LEFT JOIN Orders_road
on Orders_road.customerid = Customers.CustomerId
-- !! 控制購買的產品情形！！
WHERE (Orders_Core.customerid is  NULL) AND (Orders_road.customerid is  NULL) 
GROUP BY 1;
