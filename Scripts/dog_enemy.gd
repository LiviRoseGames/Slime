extends CharacterBody2D

@export var speed = 30.0
@export var turns_at_ledge = true

enum {
	IDLE,
	WALK,
	ATTACK,
	HURT,
	DEATH
}

var state = WALK
var gravity = 200.0
var jump = 20.0
var direction = 1.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var run_timer = $RunTimer
@onready var floor_check = $FloorCheck

func _ready() -> void :
	randomize()

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_wall() or (is_at_ledge() and turns_at_ledge):
		turn_around()
	
	match state:
		IDLE:
			idle_state()
		WALK:
			walk_state(delta)
		ATTACK:
			attack_state()
		HURT:
			hurt_state()
		DEATH:
			death_state()

	move_and_slide()

func idle_state():
	animated_sprite_2d.play("Idle")
	velocity = Vector2.ZERO

func walk_state(delta):
	animated_sprite_2d.play("Walk")
	velocity.x = direction * speed
	animated_sprite_2d.scale.x = direction

func attack_state():
	pass

func hurt_state():
	pass

func death_state():
	pass

func turn_around() -> void:
	direction *= -1.0

func is_at_ledge():
	return is_on_floor() and not floor_check.is_colliding()
