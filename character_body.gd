extends CharacterBody2D
class_name CharacterBody

var character: Character
var team: int
var move_speed = 200.0
var char_name: String
var power: float

@export var sprite: AnimatedSprite2D
@export var hitbox: Area2D

func _ready():
	if not character:
		print("No character resource on CharacterBody, Freeing.")
		queue_free()
	char_name = character.char_name
	team = character.team
	move_speed = character.move_speed
	power = character.power
	sprite.play(character.char_name)
	if team != 0:
		sprite.flip_h = true
	hitbox.body_entered.connect(_on_collide_with_enemy)

func _physics_process(delta):
	var direction = Vector2(1,1) if team == 0 else Vector2(-1, 1)
	if direction:
		velocity = direction * move_speed
	else:
		velocity = velocity.normalized() * move_toward(velocity.length(), 0, move_speed)
	
	move_and_slide()

func _on_collide_with_enemy(body):
	if body.is_queued_for_deletion() or is_queued_for_deletion():
		return
	var winner
	var loser
	if body is CharacterBody and body.team != team:
		if attack() > body.attack():
			winner = self
			loser = body
		else:
			winner = body
			loser = self
		print("%s %s has been killed by %s" % [team, loser.char_name, winner.char_name])
		loser.queue_free()

func attack():
	var roll = randi_range(0, power)
	print("%s attacked for %s" % [char_name, roll])
	return roll
