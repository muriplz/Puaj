extends GridMap

func _ready():
	# Assuming the ID of your white plane tile in the MeshLibrary is 0
	var tile_id = 0
	
	# Define the range for x, y, and z coordinates. Adjust these values based on your GridMap size
	var x_range = 10 # Number of tiles in x direction
	var z_range = 10 # Number of tiles in z direction
	var y_level = 0 # Y level where the tiles will be placed

	# Loop through each coordinate within the specified range and set the cell
	for x in range(x_range):
		for z in range(z_range):
			# Use Vector3 to specify the coordinates
			var position = Vector3(x, y_level, z)
			# Adjusted call to set_cell_item
			set_cell_item(position, tile_id, false)
