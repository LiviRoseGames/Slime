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

var state = RUN
var gravity = 200.0
var jump = 20.0
var direction = 1.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var run_timer = $RunTimer

func _ready() -> void :
	randomize()

func _physics_process(delta):
	print(run_timer.time_left)
	match state:
		IDLE:
			idle_state()
		RUN:
			run_state(delta)
		JUMP:
			jump_state(delta)
		FALL:
			fall_state(delta)
		LAND:
			land_state()
		HURT:
			hurt_state()
		DIE:
			die_state()
			
			
	move_and_slide()

func idle_state():
	animated_sprite_2d.play("Idle")
	velocity = Vector2.ZERO

func run_state(delta):
	if run_timer.is_stopped():
		run_timer.start(1)
	animated_sprite_2d.play("Run")
	if not is_on_floor():
		state = FALL

	if is_on_wall():
		turn_around()

	velocity.x = direction * speed
	animated_sprite_2d.scale.x = direction

func jump_state(delta):
	animated_sprite_2d.play("Jump")
	
	if is_on_wall():
		turn_around()
	
	velocity.x = direction * speed
	velocity.y = -jump
	animated_sprite_2d.scale.x = direction

func fall_state(delta):
	animated_sprite_2d.play("Fall")
	velocity.y += gravity * delta
	if is_on_floor():
		state = LAND
	
	if is_on_wall():
		turn_around()

func land_state():
	velocity = Vector2.ZERO
	animated_sprite_2d.play("Land")

func hurt_state():
	pass

func die_state():
	pass

func turn_around() -> void:
	direction *= -1.0

func get_random_state(possible_states : Array):
	possible_states.shuffle()
	return possible_states[1]

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Land":
		state = get_random_state([RUN, JUMP])
	elif animated_sprite_2d.animation == "Jump":
		state = FALL


func _on_run_timer_timeout():
	state = get_random_state([RUN, JUMP])
	
