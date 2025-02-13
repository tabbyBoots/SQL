SELECT Product.ProductNo, Product.ProductName, Product.ProductSpec, Product.PlaceNo, Place.PlaceName
FROM Product 
LEFT OUTER JOIN Place 
ON Product.PlaceNo = Place.PlaceNo