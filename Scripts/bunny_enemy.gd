extends CharacterBody2D

@export var speed = 30.0

enum {
	IDLE,
	RUN,
	JUMP,
	FALL,
	LAND,
	HURT,
	DIE
}

var state = IDLE
var gravity = 200.0
var direction = 1.0

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready() -> void :
	pass

func _physics_process(delta):
	match state:
		IDLE:
			idle_state()
		RUN:
			run_state(delta)
		JUMP:
			pass
		FALL:
			fall_state(delta)
		LAND:
			pass
		HURT:
			pass
		DIE:
			pass

func idle_state():
	animated_sprite_2d.play("Idle")
	velocity = Vector2.ZERO
	move_and_slide()

func run_state(delta):
	animated_sprite_2d.play("Run")
	if not is_on_floor():
		state = FALL

	if is_on_floor():
		if is_on_wall():
			turn_around()

	velocity.x = direction * speed
	animated_sprite_2d.scale.x = direction

	move_and_slide()

func fall_state(delta):
	velocity.y += gravity * delta

func turn_around() -> void:
	direction *= -1.0
