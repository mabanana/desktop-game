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
@export var left_bound: Area2D
@export var left_bound_shape: CollisionShape2D
@export var right_bound: Area2D
@export var right_bound_shape: CollisionShape2D

var character_scene: PackedScene
var char_name_list = ["goblin_archer", "goblin_fanatic", "goblin_fighter", "goblin_occultist", "goblin_wolf_rider", "halfling_assassin", "halfling_bard", "halfling_ranger", "halfling_rogue", "halfling_slinger", "lizard_archer", "lizard_beast", "lizard_gladiator", "lizard_scout"]

func _ready():
	# TODO: Changing height in project settings does not scale game correctly
	game_controller = GameController.new(self)
	_initialize_window()
	timer.timeout.connect(game_controller._on_spawn_cd_timeout)
	timer.start(0)
	
	#set_window_height_offset(100)

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
