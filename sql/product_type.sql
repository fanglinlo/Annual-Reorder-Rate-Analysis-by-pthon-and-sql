WITH Customers_Core AS
(SELECT Customers.CustomerId, Customers.FirstTransactionYear
FROM Customers
LEFT JOIN Orders
on Customers.CustomerId = Orders.customerid
AND Customers.FirstTransactionDate = Orders.TransactionDate -- 首購日期
LEFT join OrderDetails
on Orders.OrderId = OrderDetails.OrderId
left join (SELECT * FROM Products WHERE producttype =='核心產品') AS Product_Core
           on Product_Core.ProductId = OrderDetails.ProductId
WHERE Product_Core.productid is NOT NULL -- 有買核心商品的人 
),

Customer_Road AS
(
SELECT Customers.CustomerId, Customers.FirstTransactionYear
FROM Customers
LEFT JOIN Orders
on Customers.CustomerId = Orders.customerid
AND Customers.FirstTransactionDate = Orders.TransactionDate -- 首購日期
LEFT join OrderDetails
on Orders.OrderId = OrderDetails.OrderId
left join (SELECT * FROM Products WHERE producttype =='帶路產品') AS Product_Road
           on Product_Road.ProductId = OrderDetails.ProductId
WHERE Product_Road.productid is NOT NULL -- 有買帶路商品的人
)

SELECT Customers.FirstTransactionYear,COUNT(DISTINCT Customers.CustomerId)
FROM Customers
LEFT JOIN Customers_Core
On Customers.CustomerId = Customers_Core.customerid
LEFT Join Customer_Road
ON Customers.CustomerId = Customer_Road.customerid
-- !! here to control the product type!!
WHERE (Customers_Core.customerid is   NULL ) -- 有買核心商品的人
AND (Customer_Road.customerid is not  NULL ) -- ”沒“買帶路商品的人
GROUP BY 1;
