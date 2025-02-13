SELECT Product.ProductNo, Product.ProductName, Product.ProductSpec, Product.PlaceNo, Place.PlaceName
FROM Product 
FULL OUTER JOIN Place 
ON Product.PlaceNo = Place.PlaceNo
ORDER BY Product.ProductNo