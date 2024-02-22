extends Node

var gridmap: GridMap
var loaded_tiles := {}
var tile_size := Vector2(10, 10)  # Adjust as needed
var render_distance := 2  # Adjust as needed
@onready var tile_getter := $TileGetter as HTTPRequest

func _ready():
	gridmap = get_parent().get_node("GridMap") as GridMap

	tile_getter.image_loaded.connect(Callable(self, "_on_image_loaded"))

	print(gridmap)
	print("TileManager is ready and connected to TileGetter.")

func _on_tile_getter_image_loaded(texture: Texture, tile_coords: Vector2):
	if not is_tile_loaded(tile_coords):
		var mesh_instance := create_mesh_for_tile(tile_coords)
		apply_texture_to_mesh(mesh_instance, texture)
		var tile_key := str(tile_coords)
		loaded_tiles[tile_key] = mesh_instance
		print("Loaded and applied texture for tile: ", tile_coords)

func is_tile_loaded(tile_coords: Vector2) -> bool:
	return str(tile_coords) in loaded_tiles

func request_load_tile(tile_coords: Vector2):
	if not is_tile_loaded(tile_coords):
		if tile_getter != null:
			tile_getter.request_image(tile_coords)
			print("Requested tile at: ", tile_coords)


func create_mesh_for_tile(tile_coords: Vector2) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var position := Vector3(tile_coords.x * tile_size.x, 0, tile_coords.y * tile_size.y)
	mesh_instance.transform.origin = position
	add_child(mesh_instance)
	return mesh_instance

func apply_texture_to_mesh(mesh_instance: MeshInstance3D, texture: Texture):
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	mesh_instance.material_override = material
	print("Applied texture to mesh for tile_coords: ", mesh_instance.translation)

# Add more functions as needed for updating and unloading tiles.
