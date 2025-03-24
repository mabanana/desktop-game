extends Upgrade
class_name WolfBreedingUpgrade

func apply_upgrades(char: Character):
	if char.char_name == "goblin_wolf_rider":
		char.move_speed += 10 * tier
		char.power += 5 * tier
