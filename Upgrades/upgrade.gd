class_name Upgrade

var name: String
var description: String
var tier: int

func _init(tier):
	self.tier = tier

func apply_upgrades(char: Character):
	pass

func combat_modifier(char: Character, target: Character) -> float:
	return 0
