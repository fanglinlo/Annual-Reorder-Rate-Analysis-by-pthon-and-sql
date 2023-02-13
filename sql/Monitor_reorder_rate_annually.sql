WITH ord_cnt AS
(SELECT Orders.customerid, Orders.TransactionYear, COUNT(orderid) AS 'ord_count'
FROM Orders
GROUP By 1,2)

SELECT Customers.FirstTransactionYear,COUNT ( DISTINCT Customers.CustomerId) AS 'new_ord',COUNT (DISTINCT cus_ord.CustomerId) AS 'rep_ord'
FROM Customers
LEFT JOIN (SELECT * FROM ord_cnt Where ord_cnt.'ord_count' >= 2) AS cus_ord
on cus_ord.customerid = Customers.CustomerId
AND Customers.FirstTransactionYear = cus_ord.transactionyear
GROUP BY 1;
