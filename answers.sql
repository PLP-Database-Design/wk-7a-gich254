
SELECT 
  pd.OrderID,
  pd.CustomerName,
  jt.Product
FROM ProductDetail AS pd
-- turn the comma‑list into a JSON array, then explode it:
JOIN JSON_TABLE(
       CONCAT('["', REPLACE(pd.Products, ', ', '","'), '"]'),
       '$[*]' COLUMNS(Product VARCHAR(100) PATH '$')
     ) AS jt
  ON TRUE
ORDER BY pd.OrderID;


-- 1) Create the new parent “Orders” table
CREATE TABLE Orders (
  OrderID       INT PRIMARY KEY,
  CustomerName  VARCHAR(100) NOT NULL
);

-- Populate it with each OrderID exactly once
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- 2) Create the child “OrderLineItems” table
CREATE TABLE OrderLineItems (
  OrderID    INT       NOT NULL,
  Product    VARCHAR(100) NOT NULL,
  Quantity   INT       NOT NULL,
  PRIMARY KEY (OrderID, Product),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Populate it with the remaining columns
INSERT INTO OrderLineItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;
