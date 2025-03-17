extends Node2D

var window_width: int
var window_height: int
var screen_rect: Rect2
var taskbar_height: int
var window_offset: int

@export_category("Game Parameters")
@export var screen_height: int
@export var spawn_cd: float
@export var x_padding: int
@export var ground_height_offset: int


@export_category("Child Nodes")
@export var timer: Timer
@export var floor_body: StaticBody2D
@export var floor_body_shape: CollisionShape2D
@export var screen_area: Area2D
@export var screen_area_shape: CollisionShape2D

var character_scene: PackedScene
var char_name_list = ["goblin_archer", "goblin_fanatic", "goblin_fighter", "goblin_occultist", "goblin_wolf_rider", "halfling_assassin", "halfling_bard", "halfling_ranger", "halfling_rogue", "halfling_slinger", "lizard_archer", "lizard_beast", "lizard_gladiator", "lizard_scout"]

func _ready():
	# TODO: Changing height in project settings does not scale game correctly
	_initialize_window()
	screen_area.body_exited.connect(_on_body_leave_screen)
	
	character_scene = load("res://character_body.tscn")
	timer.start(0)
	timer.timeout.connect(func():
		var spawn = get_next_spawn()
		spawn_character(spawn.char_name, spawn.team)
		)
	set_window_height_offset(100)

func  _initialize_window():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	# TODO: Setup mouse passthrough
	_update_window_size()

func _update_window_size() -> void:
	screen_rect = DisplayServer.screen_get_usable_rect()
	window_width = screen_rect.size.x - x_padding
	window_height = screen_height
	DisplayServer.window_set_size(Vector2i(window_width, window_height))
	_update_screen_position()
	_update_game_area()
	_update_floor_body()

func _update_game_area():
	screen_area_shape.shape.set_size(Vector2(window_width, window_height))
	screen_area.position = Vector2(window_width, window_height) / 2

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

func _on_body_leave_screen(body: Node2D):
	if body is CharacterBody2D:
		var x = 0 if body.team == 0 else window_width
		body.position = Vector2i(x, window_height)

func spawn_character(name, team = 0):
	var node: CharacterBody = character_scene.instantiate()
	node.char_name = name
	node.team = team
	if node.team != 0:
		node.position.x = window_width
	add_child(node)

func get_next_spawn():
	var char_name = char_name_list[randi_range(0, len(char_name_list) - 1)]
	var team = randi_range(0, 1)
	return {
		"char_name" : char_name,
		"team" : team,
	}
