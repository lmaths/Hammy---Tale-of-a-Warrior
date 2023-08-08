extends CharacterBody2D

# Constants
const SPEED = 200.0
const JUMP_VELOCITY = -600.0
const UP_DIRECTION = Vector2.UP
const DASH_SPEED = 500.0
const DASH_DURATION = 0.5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Exported Variables
@export var attacking = false
@export var health = 500
@export var coins = 0

# Internal Variables
var attack_duration = 0.5  # Duração do ataque em segundos
var attack_timer = 0.0  # Contador para controlar o tempo de duração do ataque
var idle_time = 0.0
var animation_name = "Idle"
var is_dead := false
var dash_timer = 0.0
var can_dash = true
var is_dashing:= false
var horizontal_direction = 1
var knock_back_vector := Vector2.ZERO

# Nodes
@onready var weapon := $CollisionShape2D/AttackArea as Area2D
@onready var remote_transform := $Remote as RemoteTransform2D

func _process(delta):
	if Input.is_action_just_pressed("Attack") and not attacking and not is_dead and not is_dashing:
		_attack()

	if Input.is_action_just_pressed("Dash") and not attacking and can_dash and not is_dead and not is_dashing:
		_dash()

func _physics_process(delta):
	is_dead = health <= 0
	_handle_animations()

	if not is_dead:
		if not attacking and not can_dash:
			_dash_timer_handler(delta)
		
		if can_dash:
			_handle_movement(delta)

		velocity.y += gravity * delta

		
		_handle_floor_interaction(delta)
		
		if attacking:
			_update_attack(delta)
		knockBackVector()
		move_and_slide()

func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path

func knockBackVector(): 
	if knock_back_vector != Vector2.ZERO:
		velocity = knock_back_vector
		
func pickCoin():
	coins += 1

func takeDamage(damage, knockback_force:= Vector2.ZERO, duration:= 0.25):
	if not is_dashing:
		if knockback_force != Vector2.ZERO:
			knock_back_vector = knockback_force
			var knockback_tween := get_tree().create_tween()
			knockback_tween.parallel().tween_property(self, "knock_back_vector", Vector2.ZERO, duration)
			$CollisionShape2D/AnimatedSprite2D.modulate = Color(1,0,0,1)
			knockback_tween.parallel().tween_property($CollisionShape2D/AnimatedSprite2D, "modulate",Color(1,1,1,1), duration)
		
func _attack():
	weapon.cause_damage()
	attacking = true
	attack_timer = 0.0

func _dash():
	is_dashing = true
	velocity.x = horizontal_direction * DASH_SPEED
	dash_timer = 0.0
	can_dash = false

func _handle_movement(delta):
	horizontal_direction = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	velocity.x = horizontal_direction * SPEED

	var is_jumping := Input.is_action_just_pressed("Jump") and is_on_floor() # Pode pular mesmo quando estiver atacando
	if is_jumping:
		velocity.y = JUMP_VELOCITY

func _update_attack(delta):
	attack_timer += delta
	if attack_timer >= attack_duration:
		print("cabou")

func _handle_floor_interaction(delta):
	if horizontal_direction > 0:
		$CollisionShape2D.scale.x = 1
	elif horizontal_direction < 0:
		$CollisionShape2D.scale.x = -1

	if is_zero_approx(velocity.x):
		idle_time += delta
	else:
		idle_time = 0.0

func _dash_timer_handler(delta):
	dash_timer += delta

	if dash_timer >= DASH_DURATION:
		can_dash = true
		dash_timer = 0.0

	if not can_dash:
		idle_time = 0.0

func _handle_animations():
	var is_jumping = not is_zero_approx(velocity.y) and not is_on_floor() and not is_dead and not is_dashing and not attacking
	var is_running = is_on_floor() and not is_zero_approx(velocity.x) and not is_jumping and not attacking and not is_dead and not is_dashing
	var is_idle = is_on_floor() and is_zero_approx(velocity.x) and not is_jumping and not attacking and not is_dead and not is_dashing
	var is_attacking = attacking and not is_dead and not is_dashing

	if is_idle and idle_time > 1.0:
		animation_name = "Idle"  # Idle por mais tempo
	elif is_idle:
		animation_name = "Idle"
	elif is_running:
		animation_name = "Run"
	elif is_jumping:
		animation_name = "Jump"
	elif is_attacking:
		animation_name = "Attack"
	elif is_dashing:
		animation_name = "Dash"
	elif is_dead:
		animation_name = "Death"

	$CollisionShape2D/AnimatedSprite2D.play(animation_name)


func _on_animated_sprite_2d_animation_finished():
	if $CollisionShape2D/AnimatedSprite2D.animation == "Attack":
		attacking = false
	if $CollisionShape2D/AnimatedSprite2D.animation == "Death":
		queue_free()
	if $CollisionShape2D/AnimatedSprite2D.animation == "Dash":
		is_dashing = false


func _on_virtual_joystick_analogic_chage(move):
	horizontal_direction = move.x


func _on_end_game_body_entered(body):
	health = 0
