extends CharacterBody2D

const SPEED = 100
const JUMP_VELOCITY = -50.0
var was_on_floor = true
var current_state = States.IDLE

var playerhealth = 10

enum States { IDLE, MOVE, JUMP, FALL, LAND, SWALLOW, DEATH }

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var playanim = get_node("AnimationPlayer")

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	#check for jump input
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		change_state(States.JUMP)
	elif not is_on_floor() and velocity.y > 0 and current_state != States.FALL:
		change_state(States.FALL)
	#check for swallow input
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		change_state(States.SWALLOW)

	#Finite State Machine handling
	match current_state:
		States.IDLE, States.MOVE:
			handle_move(direction)
		States.JUMP:
			handle_jump()
		States.FALL:
			handle_fall(delta)
		States.LAND:
			handle_land()
		States.SWALLOW:
			handle_swallow()
		States.DEATH:
			handle_death()
	
	# Apply movement and gravity outside of state handling
	velocity.y += gravity * delta
	move_and_slide()

func change_state(new_state):
	current_state = new_state
	match new_state:
		States.IDLE:
			playanim.play("Idle")
		States.JUMP:
			velocity.y = JUMP_VELOCITY
			playanim.play("Jump")
		States.FALL:
			playanim.play("Fall")
		States.LAND:
			playanim.play("Land")
		States.SWALLOW:
			playanim.play("Swallow")
		States.DEATH:
			handle_death()
		_:
			pass  # For States.MOVE, animation is handled in handle_move

func handle_move(direction):
	if direction != 0:
		get_node("AnimatedSprite2D").flip_h = direction == -1
		velocity.x = direction * SPEED
		if is_on_floor():
			playanim.play("Move")
			change_state(States.MOVE)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and current_state != States.IDLE:
			playanim.play("Idle")
		change_state(States.IDLE)
		
func handle_swallow():
	playanim.play("Swallow")
	
func handle_jump():
	velocity.y = JUMP_VELOCITY
	playanim.play("Jump")
	if velocity.y > 0:
		change_state(States.FALL)

func handle_fall(delta):
	velocity.y += gravity * delta
	# Fall logic continuation is handled by state transitions
func handle_land():
	playanim.play("Land")
			
func handle_death():
	if playerhealth <= 0:
		change_state(States.DEATH)

func take_damage(amount):
	playerhealth -= amount
	if playerhealth <= 0:
		change_state(States.DEATH)

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "Swallow"):
		change_state(States.IDLE)
	if (anim_name == "Death"):
		self.queue_free()
	if (anim_name == "Jump"):
		change_state(States.FALL)
	if (anim_name == "Fall"):
		change_state(States.LAND)
	if (anim_name == "Land"):
		change_state(States.IDLE)
