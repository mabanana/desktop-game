class_name Character

var char_name: String
var team: int
var move_speed: float = 200.0
var power: float = 20
var range: float = 4
var key_words = []

enum KeyWord {
	GOBLIN,
	HALFLING,
	LIZARD,
	RANGED,
	MELEE,
	MAGIC,
	SUPPORT,
}

func _init(char_name, team):
	self.char_name = char_name
	self.team = team
	match char_name:
		"goblin_archer":
			power += 20
			range += 10
			key_words.append(KeyWord.GOBLIN)
			key_words.append(KeyWord.RANGED)
		"goblin_fanatic":
			power += 25  # Likely a berserker-type unit
			key_words.append(KeyWord.GOBLIN)
			key_words.append(KeyWord.MELEE)
		"goblin_fighter":
			power += 22  # Standard melee combatant
			key_words.append(KeyWord.GOBLIN)
			key_words.append(KeyWord.MELEE)
		"goblin_occultist":
			power += 28  # Magic users tend to be strong but fragile
			range += 6
			key_words.append(KeyWord.GOBLIN)
			key_words.append(KeyWord.RANGED)
			key_words.append(KeyWord.MAGIC)
			key_words.append(KeyWord.SUPPORT)
		"goblin_wolf_rider":
			power += 30  # Mounted units usually have extra mobility and attack
			range += 2
			key_words.append(KeyWord.GOBLIN)
			key_words.append(KeyWord.MELEE)
		"halfling_assassin":
			power += 27  # Assassins deal high burst damage
			key_words.append(KeyWord.MELEE)
		"halfling_bard":
			power += 18  # Support role, likely buffs allies
			range += 4
			key_words.append(KeyWord.MELEE)
			key_words.append(KeyWord.MAGIC)
			key_words.append(KeyWord.SUPPORT)
		"halfling_ranger":
			power += 24  # Ranged but more versatile than an archer
			range += 14
			key_words.append(KeyWord.RANGED)
			key_words.append(KeyWord.MELEE)
		"halfling_rogue":
			power += 26  # Sneaky, high-damage melee
			key_words.append(KeyWord.MELEE)
		"halfling_slinger":
			power += 19  # Ranged but weaker than a ranger
			range += 8
			key_words.append(KeyWord.RANGED)
		"lizard_archer":
			power += 23  # Likely stronger than goblins due to physiology
			range += 8
			key_words.append(KeyWord.RANGED)
		"lizard_beast":
			power += 35  # Likely a brute force tank
			key_words.append(KeyWord.MELEE)
		"lizard_gladiator":
			power += 32  # Skilled melee fighter
			key_words.append(KeyWord.MELEE)
		"lizard_scout":
			power += 21  # Agile but lower power
			range += 6
			key_words.append(KeyWord.MELEE)
			key_words.append(KeyWord.RANGED)
			key_words.append(KeyWord.SUPPORT)
		_:
			power = 10  # Default case for unknown characters
