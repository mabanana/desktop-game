extends Node
class_name GameController

var main: Main

var character_scene: PackedScene
var char_name_list = ["goblin_archer", "goblin_fanatic", "goblin_fighter", "goblin_occultist", "goblin_wolf_rider", "halfling_assassin", "halfling_bard", "halfling_ranger", "halfling_rogue", "halfling_slinger", "lizard_archer", "lizard_beast", "lizard_gladiator", "lizard_scout"]

var player_units = {
	"goblin_wolf_rider" : 15,
	"goblin_fanatic": 10,
}
var advantage: int = 4
var score = 0

func _init(main):
	self.main = main
	character_scene = preload("res://character_body.tscn")

func _on_body_leave_screen(body: Node2D):
	if body is CharacterBody2D:
		if body.team == 0 and body.position.x > 20:
			score += body.power
			print("score: %s" % [score])
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
	team = 0 if randi_range(0, 10) < advantage else team
	if team == 0:
		char_name = get_player_unit()
	var char = Character.new(char_name, team)
	return char

func _on_spawn_cd_timeout():
	var spawn = get_next_spawn()
	if not spawn.char_name:
		return
	spawn_character(spawn)

func get_player_unit():
	var unit_list = player_units.keys()
	var char_name
	if unit_list:
		char_name = unit_list[randi_range(0, len(unit_list) - 1)]
		player_units[char_name] -= 1
		if player_units[char_name] <= 0:
			player_units.erase(char_name)
	else:
		char_name = ""
		print("Player ran out of units")
	return char_name

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
