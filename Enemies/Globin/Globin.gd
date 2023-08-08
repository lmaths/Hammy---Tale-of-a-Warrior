extends CharacterBody2D



const JUMP_VELOCITY = -400.0
var direction := -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var wall_detector := $GroundDetector as RayCast2D
@onready var texture := $AnimatedSprite2D as AnimatedSprite2D
@onready var player_detector_left := $PlayerDetectorLeft as RayCast2D
@onready var player_detector_right := $PlayerDetectorRight as RayCast2D
@onready var weapon := $Weapon as Area2D
@export var movement_speed := 500
var original_movement_speed := 0
@export var boost_movement:= 3500
@export var health: float = 100
@export var damage:= 100
var can_move:= true
var animation_name = "Walk"

func _ready():
	original_movement_speed = movement_speed
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if not wall_detector.is_colliding() or $AnimatedSprite2D/WorldDetector.is_colliding():
		invert_direction()
	
	if (direction == 1):
		$AnimatedSprite2D/WorldDetector.scale.x = -1
		weapon.scale.x = -1
		texture.flip_h = false
	else:
		$AnimatedSprite2D/WorldDetector.scale.x = 1
		weapon.scale.x = 1
		texture.flip_h = true
	
	if can_move: 
		velocity.x = direction * movement_speed * delta
		move_and_slide()
	texture.play(animation_name)
	detectPlayer()
	_verifyIfIsDie()

func invert_direction():
	direction *= -1
	
func _verifyIfIsDie():
	if health <= 0:
		can_move = false
		animation_name = "Die"
		
func _loseHealth(damage):
	self.velocity.x = 500
	if health > 0:
		print("lose")
		$AudioStreamPlayer2D.play()
		can_move = false
		animation_name = "Hurt"
		health -= damage


func _on_animated_sprite_2d_animation_finished():
	if texture.animation == "Die":
		queue_free()
	if texture.animation == "Hurt":
		can_move = true
		animation_name = "Walk"
	if texture.animation == "Attack":
		can_move = true
		animation_name = "Walk"
	
func detectPlayer():
	if player_detector_left.is_colliding() and wall_detector.is_colliding():
		direction = -1
		movement_speed = boost_movement
	elif player_detector_right.is_colliding() and wall_detector.is_colliding():
		direction = 1
		movement_speed = boost_movement
		
	else:
		movement_speed = original_movement_speed
	
func _on_area_2d_body_entered(body):
	if health > 0:
		can_move = false
		animation_name = "Attack"
		var hit_impulse = Vector2.ZERO
		if $PlayerDetectorLeft.is_colliding():
			hit_impulse = Vector2(-200, -200)
		elif $PlayerDetectorRight.is_colliding():
			hit_impulse = Vector2(200, -200)
		body.takeDamage(damage, hit_impulse)
	
