SELECT Product.ProductNo, Product.ProductName, Product.ProductSpec, Place.PlaceName, Product.PlaceNo
FROM Product 
FULL OUTER JOIN Place 
ON Product.PlaceNo = Place.PlaceNo
WHERE Product.PlaceNo IS NULL OR Place.PlaceNo IS NULL
ORDER BY Product.ProductNo