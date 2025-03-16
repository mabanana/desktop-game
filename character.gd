extends CharacterBody2D
class_name CharacterBody

var team: int
var move_speed = 200.0

@export var char_name: String
@export var sprite: AnimatedSprite2D
@export var hitbox: Area2D

func _ready():
	if not char_name:
		queue_free()
	sprite.play(char_name)
	hitbox.body_entered.connect(_on_collide_with_enemy)
	if team != 0:
		sprite.flip_h = true

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
	if body is CharacterBody and body.team != team:
		if randi_range(0,1):
			queue_free()
		else:
			body.queue_free()
