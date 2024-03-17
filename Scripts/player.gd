extends CharacterBody2D

class_name Player

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum PlayerMode {
	SLIME,
	SWALLOW,
	RABBIT,
	DOG,
	BIRD
}

var player_mode = PlayerMode.SLIME
var is_dead = false

@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_collision_shape = $Area2D/areacollisionshape
@onready var body_collision_shape = $bodycollisionshape
@onready var area_2d = $Area2D

@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 200.0
@export var jump_velocity = -350.0
@export_group("")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y *= 0.5
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = lerpf(velocity.x, speed * direction, run_speed_damping * delta)
	else: 
		direction = int(direction)
		velocity.x = move_toward(velocity.x, 0, speed * delta)
	
	if Input.is_action_just_pressed("ui_down"):
		player_mode = PlayerMode.SWALLOW
		swallow()
	else:
		animated_sprite_2d.trigger_animation(velocity, direction, player_mode)
	move_and_slide()

func swallow():
	animated_sprite_2d.play("slime_swallow")
	set_physics_process(false)

func die():
	is_dead = true
	animated_sprite_2d.play("death")

