extends Node2D

var window_width: int
var window_height: int
var screen: Rect2
var taskbar_height: int

var character_scene: PackedScene
@export_category("Game Parameters")
@export var screen_height: int
@export var spawn_cd: float
@export var x_padding: int

@export_category("Child Nodes")
@export var timer: Timer
@export var floor_body: StaticBody2D
@export var screen_area: Area2D
@export var screen_area_rect: CollisionShape2D


var char_name_list = ["goblin_archer", "goblin_fanatic", "goblin_fighter", "goblin_occultist", "goblin_wolf_rider", "halfling_assassin", "halfling_bard", "halfling_ranger", "halfling_rogue", "halfling_slinger", "lizard_archer", "lizard_beast", "lizard_gladiator", "lizard_scout"]

func _ready():
	# TODO: Changing height in project settings does not scale game correctly
	_setup_window()
	screen_area.body_exited.connect(_on_body_leave_screen)
	
	character_scene = load("res://character_body.tscn")
	timer.start(spawn_cd)
	timer.timeout.connect(func():
		var spawn = get_next_spawn()
		spawn_character(spawn.char_name, spawn.team)
		)

func  _setup_window():
	_update_screen_size(screen_height)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, true)
	
	# TODO: Setup mouse passthrough
	_update_tb_position(0)

func _update_screen_size(screen_height) -> void:
	# Example: If window size changes (e.g., screen resolution change)
	
	screen = DisplayServer.screen_get_usable_rect()
	window_width = screen.size.x - x_padding
	window_height = screen_height
	print(window_width, ", ", window_height)
	get_window().set_size(Vector2(window_height, window_width))
	screen_area_rect.shape.set_size(Vector2(window_height, window_width))
	DisplayServer.window_set_size(Vector2i(window_width, window_height))
	floor_body.position = Vector2(window_width/2, window_height + 150)
	print(floor_body.position)
	_update_screen_position()

func _update_screen_position() -> void:
	var screen_y = screen.size.y + screen.position.y - taskbar_height - window_height
	DisplayServer.window_set_position(Vector2i(x_padding / 2, screen_y))

func _update_tb_position(value: float = 0) -> void:
	value = int(value * 10)
	taskbar_height = value
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
