extends Node2D
class_name Main

var window_width: int
var window_height: int
var screen_rect: Rect2
var taskbar_height: int
var window_offset: int

var game_controller: GameController

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
	game_controller = GameController.new(self)
	timer.timeout.connect(game_controller._on_spawn_cd_timeout)
	timer.start(0)
	screen_area.body_exited.connect(game_controller._on_body_leave_screen)
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
