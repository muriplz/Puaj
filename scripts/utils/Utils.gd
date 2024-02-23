class_name Utils

static var zoom = 15
static var render_distance = 2
static var tile_size = Vector2(10, 10)  # Size of a tile in game units
static var origin_latlon = Vector2(40.413500, -6.866500)  # Latitude and Longitude of the game world's origin
static var origin_tile = latlon_to_tile(origin_latlon.x, origin_latlon.y)
static var meters_per_unit = 1.0  # How many meters in the real world one game unit represents

# Converts a world position (Vector3) to latitude/longitude (Vector2)
static func world_to_latlon(world_position: Vector3) -> Vector2:
	var tile_coords = world_to_tile(world_position)
	return tile_to_latlon(tile_coords.x, tile_coords.y)

# Converts a world position (Vector3) to tile coordinates (Vector2)
static func world_to_tile(world_position: Vector3) -> Vector2:
	var tile_x = round(origin_tile.x + world_position.x / tile_size.x)
	var tile_y = round(origin_tile.y + world_position.z / tile_size.y)  # Assuming Z-axis is North/South in Godot
	return Vector2(tile_x, tile_y)

# Converts latitude/longitude (Vector2) to a world position (Vector3)
static func latlon_to_world(lat: float, lon: float) -> Vector3:
	var tile_coords = latlon_to_tile(lat, lon)
	var world_x = (tile_coords.x - origin_tile.x) * tile_size.x
	var world_z = (tile_coords.y - origin_tile.y) * tile_size.y  # Assuming Z-axis is North/South in Godot
	return Vector3(world_x, 0, world_z)

# Converts tile coordinates (Vector2) to a world position (Vector3)
static func tile_to_world(x: int, y: int) -> Vector3:
	var world_x = (x - origin_tile.x) * tile_size.x
	var world_z = (y - origin_tile.y) * tile_size.y  # Assuming Z-axis is North/South in Godot
	return Vector3(world_x, 0, world_z)
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

