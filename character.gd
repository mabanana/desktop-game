extends CharacterBody2D

var move_speed = 500.0
@export var sprite: Sprite2D

func _physics_process(delta):
	var direction = Vector2(1,1)
	if direction:
		velocity = direction * move_speed
	else:
		velocity = velocity.normalized() * move_toward(velocity.length(), 0, move_speed)
	
	move_and_slide()
