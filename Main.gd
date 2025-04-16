extends Node2D
class_name Main

var window_width: int
var window_height: int
var screen_rect: Rect2
var taskbar_height: int
var window_offset: int
var last_passthrough_update: float

@export_category("Screen Parameters")
@export var screen_height: int
@export var x_padding: int
@export var ground_height_offset: int
@export var passthrough_update_rate: float

@export_category("Child Nodes")
@export var tilemap: TileMapLayer
@export var game_controller: GameController
@export var floor_body: StaticBody2D
@export var floor_body_shape: CollisionShape2D
@export var left_bound: Area2D
@export var left_bound_shape: CollisionShape2D
@export var right_bound: Area2D
@export var right_bound_shape: CollisionShape2D


func _ready():
	get_viewport().set_embedding_subwindows(false)
	_initialize_window()
	
	create_new_window(false)


func _initialize_window():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	_update_window_size()

func _update_window_size() -> void:
	screen_rect = DisplayServer.screen_get_usable_rect()
	window_width = screen_rect.size.x - x_padding
	window_height = screen_height
	DisplayServer.window_set_size(Vector2i(window_width, window_height))
	_update_screen_position()
	_update_game_area()
	_update_floor_body()
	_update_floor_tiles()

func _update_game_area():
	left_bound_shape.shape.size.y = window_height
	left_bound.position.x = 0 - left_bound_shape.shape.size.x / 2 + 20
	right_bound.position.x = window_width + right_bound_shape.shape.size.x / 2 - 20
	left_bound.position.y += window_height / 2
	right_bound.position.y += window_height / 2
	right_bound.body_entered.connect(game_controller._on_body_leave_screen)
	left_bound.body_entered.connect(game_controller._on_body_leave_screen)

func _update_floor_body():
	floor_body_shape.shape.set_size(Vector2(window_width * 2, 300))
	var x_offset = window_width
	var y_offset = (floor_body_shape.shape.size.y) / 2
	y_offset -= ground_height_offset
	floor_body.position = Vector2(window_width/2, window_height + y_offset)
	
func _update_screen_position() -> void:
	var screen_y = screen_rect.size.y + screen_rect.position.y - taskbar_height - window_height - window_offset
	DisplayServer.window_set_position(Vector2i(x_padding / 2, screen_y))

func set_window_height_offset(value: float = 0) -> void:
	value = int(value)
	window_offset = value
	_update_screen_position()

func _update_floor_tiles():
	var pos = floor_body.position
	var tile_map_height = 144
	pos.y += tile_map_height - floor_body_shape.shape.get_rect().size.y / 2
	tilemap.position = pos

func create_new_window(hidden = true):
	var window = Window.new()
	window.visible = not hidden
	
	# TODO: Scale size with contents
	window.size = Vector2(300, 100)
	
	window.position = Vector2(window_width, screen_rect.size.y) / 2
	window.position += DisplayServer.screen_get_usable_rect().position
	window.position += window.size / 2 * -1
	
	window.set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	
	window.close_requested.connect(window.hide)
	
	add_child(window)
	
func update_mouse_passthrough():
	screen_rect = DisplayServer.screen_get_usable_rect()
	var polygon_array: Array = []
	var floor_array = get_floor_vec2_array()
	
	for char in game_controller.character_body_hash.values():
		var char_poly = get_polygon(char.sprite)
		polygon_array.append(char_poly)
	
	
	polygon_array.sort_custom(func(a, b):
		return a[0].x <= b[0].x
		)
	polygon_array.slice(1)
	var packed_polygon_array: PackedVector2Array = []
	packed_polygon_array.append_array(floor_array.slice(0,2))
	
	for packed_arr in polygon_array:
		if packed_arr[0].x <= packed_polygon_array[-1].x:
			packed_polygon_array.remove_at(len(packed_polygon_array) - 1)
			var ceiling = min(packed_arr[1].y, packed_polygon_array[-1].y)
			packed_polygon_array[-1].y = ceiling
			packed_polygon_array.append(packed_arr[1])
			packed_polygon_array[-1].y = ceiling
			packed_polygon_array.append(packed_arr[2])
			packed_polygon_array[-1].y = ceiling
			packed_polygon_array.append(packed_arr[3])
		else:
			packed_polygon_array.append_array(packed_arr)
		
	packed_polygon_array.append_array(floor_array.slice(2,4))
	$Polygon2D.polygon = packed_polygon_array
	DisplayServer.window_set_mouse_passthrough(packed_polygon_array)
	
func get_polygon(sprite: AnimatedSprite2D):
	var sprite_texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var sprite_size = Vector2(sprite_texture.get_width(), sprite_texture.get_height()) * sprite_texture.get_size().x / 2
	
	
	var floor_y = floor_body_shape.shape.get_rect().position.y + floor_body.position.y
	var y_max = floor_y - sprite_size.y
	
	var top_left: Vector2 = sprite.global_position - sprite_size / 2
	top_left.y = min(floor_y - sprite_size.y, top_left.y)
	var bottom_right = Vector2(
		top_left.x + sprite_size.x, 
		floor_y
	)
	
	var texture_corners: PackedVector2Array = [
	Vector2(top_left.x, bottom_right.y), # Bottom left
	top_left, # Top left
	Vector2(bottom_right.x, top_left.y) , # Top right
	bottom_right, # Bottom right
	]
	
	return texture_corners

func get_floor_vec2_array():
	var rect = floor_body_shape.shape.get_rect()
	var pos = rect.position + floor_body.position
	var end = rect.end + floor_body.position
	
	return [
		Vector2(pos.x, end.y), # Bottom Left
		pos, # Top Left
		Vector2(end.x, pos.y), # Top Right
		end, # Bottom Right
		]
	
func _process(delta):
	#TODO: update less frequently
	last_passthrough_update += delta
	if last_passthrough_update > 1 / passthrough_update_rate:
		update_mouse_passthrough()
		last_passthrough_update = 0
