extends Window
class_name GameWindow

var scene: Node
var main: Main
var game_controller: GameController

func _init(main: Main, scene):
	self.main = main
	self.scene = scene.instantiate()
	game_controller = main.game_controller

func _ready():
	# TODO: Have size as a saved setting
	size = Vector2(500, 300)
	set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	close_requested.connect(hide)
	add_child(scene)
