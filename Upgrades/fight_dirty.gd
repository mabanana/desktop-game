extends Upgrade
class_name FightDirtyUpgrade

func _ready():
	name = "Fight Dirty"
	description = "Goblin units have increased power (1 * tier) and gain extra attack (5 * tier) against ranged and magic units"

func apply_upgrades(char: Character):
	if Character.KeyWord.GOBLIN in char.key_words:
		char.power += 1 * tier

func combat_modifier(char: Character, target: Character) -> float:
	if Character.KeyWord.GOBLIN in char.key_words:
		if (Character.KeyWord.RANGED in target.key_words
		or Character.KeyWord.MAGIC in target.key_words):
			return 5 * tier
	return 0
