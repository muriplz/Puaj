class_name Utils

static var zoom = 15
static var renderDistance = 3

# Function to convert latitude and longitude to tile coordinates
static func latlon_to_tile(lat: float, lon: float) -> Vector2:
	var n: float = pow(2.0, zoom)
	var x: int = int((lon + 180.0) / 360.0 * n)
	var lat_rad: float = deg_to_rad(lat)
	var y: int = int((1.0 - log(tan(lat_rad) + 1.0 / cos(lat_rad)) / PI) / 2.0 * n)
	return Vector2(x, y)

# Function to convert tile coordinates to latitude and longitude
static func tile_to_latlon(x: int, y: int) -> Vector2:
	var n: float = pow(2.0, zoom)
	var lon_deg: float = x / n * 360.0 - 180.0
	var lat_rad: float = atan(sinh(PI * (1.0 - 2.0 * y / n)))
	var lat_deg: float = deg_to_rad(lat_rad)
	return Vector2(lat_deg, lon_deg)

