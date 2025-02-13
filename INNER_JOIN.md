SELECT Product.ProductNo, Product.ProductSpec, Product.PlaceNo, Place.PlaceName
FROM Product
INNER JOIN Place 
ON Product.PlaceNo = Place.PlaceNo