# Create this as project.godot configuration or in your main scene script

extends Node2D

var window_width: int
var window_height: int
var screen: Rect2
var taskbar_height: int

func _ready():
	_setup_window()
	$Area2D.body_exited.connect(_on_body_leave_screen)

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
		body.position = Vector2i(0, window_height - body.sprite.get_rect().size.y)
