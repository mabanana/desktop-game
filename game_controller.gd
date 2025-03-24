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
		var x = 0 if body.team == 0 else main.window_width
		body.position = Vector2i(x,  main.window_height)

func spawn_character(char: Character):
	var node: CharacterBody = character_scene.instantiate()
	node.character = char
	if char.team != 0:
		node.position = Vector2i(main.window_width, main.window_height)
	else:
		node.position.y = main.window_height
		
	main.add_child(node)

func get_next_spawn():
	var char_name = char_name_list[randi_range(0, len(char_name_list) - 1)]
	var team = randi_range(0, 1)
	var char = Character.new(char_name, team)
	return char

func _on_spawn_cd_timeout():
	spawn_character(get_next_spawn())
static func resolve_combat(atker, defer):
	var winner: CharacterBody
	var loser: CharacterBody
	
	var range_adv = max(0, atker.range - defer.range)
	var atk_roll = atker.attack()
	var def_roll = defer.attack()
	if range_adv > def_roll:
		print("%s hit %s with a ranged(%s) attack" % [atker.char_name, defer.char_name, range_adv])
		winner = atker
		loser = defer
	elif atk_roll > def_roll:
		winner = atker
		loser = defer
		# Lose some power on winning melee battle
		var roll_diff = abs(def_roll - atk_roll)
		winner.power = max(winner.power / 2, winner.power - roll_diff)
	else:
		winner = defer
		loser = atker
	print("%s %s(%s) has been killed by %s(%s)" % [winner.team, loser.char_name, min(atk_roll, def_roll), winner.char_name, max(atk_roll, def_roll)])
	loser.die()
