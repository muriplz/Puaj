class_name Utils

# Constants for conversion calculations
const DEGREES_IN_CIRCLE = 360.0
const RADIANS_IN_CIRCLE = PI * 2
const EARTH_RADIUS_IN_METERS = 6378137.0  # Standard value

static var zoom = 17
static var render_distance = 7
static var tile_size = Vector2(100, 100)  # Size of a tile in game units
static var origin_latlon = Vector2(40.963292, -5.674035)  # Latitude and Longitude of the game world's origin
static var origin_tile = latlon_to_tile(origin_latlon.x, origin_latlon.y)

static var loaded_tiles = {}
static var loaded_meshes = {}

# Helper methods for angle conversions
static func deg_to_rad(deg: float) -> float:
	return deg * PI / 180.0

static func rad_to_deg(rad: float) -> float:
	return rad * 180.0 / PI

# Converts latitude/longitude to tile coordinates at the current zoom level
static func latlon_to_tile(lat: float, lon: float) -> Vector2:
	var n = pow(2.0, zoom)
	var x = int((lon + 180.0) / 360.0 * n)
	var lat_rad = deg_to_rad(lat)
	var y = int((1.0 - log(tan(lat_rad) + 1 / cos(lat_rad)) / PI) / 2.0 * n)
	return Vector2(x, y)

# Converts tile coordinates at the current zoom level to latitude/longitude
static func tile_to_latlon(x: int, y: int) -> Vector2:
	var n = pow(2.0, zoom)
	var lon_deg = x / n * 360.0 - 180.0
	var lat_rad = atan(sinh(PI * (1 - 2 * y / n)))
	var lat_deg = rad_to_deg(lat_rad)
	return Vector2(lat_deg, lon_deg)

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
