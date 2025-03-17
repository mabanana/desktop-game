extends Node
class_name GameController

var main: Main

var character_scene: PackedScene
var char_name_list = ["goblin_archer", "goblin_fanatic", "goblin_fighter", "goblin_occultist", "goblin_wolf_rider", "halfling_assassin", "halfling_bard", "halfling_ranger", "halfling_rogue", "halfling_slinger", "lizard_archer", "lizard_beast", "lizard_gladiator", "lizard_scout"]

func _init(main):
	self.main = main
	character_scene = preload("res://character_body.tscn")

func _on_body_leave_screen(body: Node2D):
	if body is CharacterBody2D:
		var x = 0 if body.team == 0 else  main.window_width
		body.position = Vector2i(x,  main.window_height)

func spawn_character(char):
	var node: CharacterBody = character_scene.instantiate()
	node.character = char
	if char.team != 0:
		node.position.x = main.window_width
	main.add_child(node)

func get_next_spawn():
	var char_name = char_name_list[randi_range(0, len(char_name_list) - 1)]
	var team = randi_range(0, 1)
	var char = Character.new(char_name, team)
	return char

func _on_spawn_cd_timeout():
	spawn_character(get_next_spawn())
