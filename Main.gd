extends Node2D

var window_width: int
var window_height: int
var screen: Rect2
var taskbar_height: int

var character_scene: PackedScene

@export var timer: Timer
@export var spawn_cd: float

var char_name_list = ["goblin_archer", "halfling_assassin"]

func _ready():
	_setup_window()
	$Area2D.body_exited.connect(_on_body_leave_screen)
	character_scene = load("res://character_body.tscn")
	timer.start(spawn_cd)
	timer.timeout.connect(func():
		var spawn = get_next_spawn()
		spawn_character(spawn.char_name, spawn.team)
		)

func  _setup_window():
	_update_screen_size()
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, true)
	
	# TODO: Setup mouse passthrough
	_update_tb_position(0)

func _update_screen_size() -> void:
	# Example: If window size changes (e.g., screen resolution change)
	screen = DisplayServer.screen_get_usable_rect()
	window_width = screen.size.x
	window_height = get_viewport_rect().size.y
	DisplayServer.window_set_size(Vector2i(window_width, window_height))
	_update_screen_position()

func _update_screen_position() -> void:
	var screen_y = screen.size.y + screen.position.y - taskbar_height - window_height
	DisplayServer.window_set_position(Vector2i(0, screen_y))

func _update_tb_position(value: float = 0) -> void:
	value = int(value * 10)
	taskbar_height = value
	_update_screen_position()

func _on_body_leave_screen(body: Node2D):
	if body is CharacterBody2D:
		var x = 0 if body.position.x > 0 else window_width
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
