extends PanelContainer

func _ready():
	resize_to_viewport()

func _process(delta):
	resize_to_viewport()

func resize_to_viewport():
	var viewport_size = get_viewport_rect().size
	var aspect_ratio = viewport_size.x / viewport_size.y
	
	# Set a responsive width based on aspect ratio
	var width_percentage = 0.2 if aspect_ratio > 1.0 else 0.6 # 20% for wide screens, 50% for narrow screens
	
	custom_minimum_size.x = viewport_size.x * width_percentage
	custom_minimum_size.y = viewport_size.y  # Full height
	
	# If the menu is meant to pop up, you would animate the `rect_position.x` property
	# from -rect_min_size.x to 0 when you want to show the menu, and back when hiding it.
