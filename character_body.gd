extends CharacterBody2D
class_name CharacterBody

var character: Character
var team: int
var move_speed = 200.0
var char_name: String
var power: float
var is_dead: bool = false
var death_material: ShaderMaterial
var death_time: float = 0.8

@export var sprite: AnimatedSprite2D
@export var body_shape: CollisionShape2D
@export var hitbox: Area2D
@export var hitbox_shape: CollisionShape2D
@export var anim_player: AnimationPlayer

func _ready():
	if not character:
		print("No character resource on CharacterBody, Freeing.")
		queue_free()
	char_name = character.char_name
	team = character.team
	move_speed = character.move_speed
	power = character.power
	death_material = sprite.material
	death_material.setup_local_to_scene()
	sprite.set_material(null)
	sprite.play(character.char_name)
	setup_collisions()
	# note: all sprite frames have consistent sizing between frames

func setup_collisions():
	var sprite_texture = sprite.sprite_frames.get_frame_texture(character.char_name,0)
	var sprite_size = sprite_texture.get_size()
	body_shape.shape = RectangleShape2D.new()
	body_shape.shape.size = sprite_size
	
	hitbox_shape.shape = RectangleShape2D.new()
	var hitbox_size = sprite_size
	hitbox_size.y += 4
	hitbox_size.x += character.range
	hitbox_shape.shape.size = hitbox_size
	if team != 0:
		sprite.flip_h = true
	hitbox.body_entered.connect(_on_collide_with_enemy)

func _physics_process(delta):
	if is_dead:
		return
	
	var direction = Vector2(1,1) if team == 0 else Vector2(-1, 1)
	if direction:
		velocity = direction * move_speed
	else:
		velocity = velocity.normalized() * move_toward(velocity.length(), 0, move_speed)
	move_and_slide()

func _on_collide_with_enemy(body):
	if body is CharacterBody and body.team != team:
		if body.is_dead or is_dead:
			return
		var winner: CharacterBody
		var loser: CharacterBody
		if attack() > body.attack():
			winner = self
			loser = body
		else:
			winner = body
			loser = self
		print("%s %s has been killed by %s" % [team, loser.char_name, winner.char_name])
		loser.die()
		

func attack():
	var roll = randi_range(0, power)
	print("%s attacked for %s" % [char_name, roll])
	return roll

func die():
	# TODO: activate shader only when dead
	is_dead = true
	body_shape.position.y = 10000
	animate_death()
	
func animate_death():
	sprite.set_material(death_material)
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(sprite, "position", Vector2(0, -10), death_time/2)
	tween.chain().tween_property(sprite, "position", Vector2(0, 30), death_time/2)
	tween.play()
	get_tree().create_timer(death_time).timeout.connect(queue_free)
	
