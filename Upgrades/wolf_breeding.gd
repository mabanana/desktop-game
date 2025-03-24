extends Upgrade
class_name WolfBreedingUpgrade

func _ready():
	name = "Wolf Breeding"
	description = "Goblin Wolf Riders have increased movement speed (10 * tier) and power (5 * tier)"

func apply_upgrades(char: Character):
	if char.char_name == "goblin_wolf_rider":
		char.move_speed += 10 * tier
		char.power += 5 * tier
