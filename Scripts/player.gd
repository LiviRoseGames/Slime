extends CharacterBody2D

var health = 10
const SPEED = 100
const JUMP_VELOCITY = -20.0
var in_air = false
var current_state = States.IDLE
@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_direction = 0

enum States { IDLE, MOVE, JUMP, SWALLOW, DEATH }

func _ready():
	anim_tree.active = true
	
func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		last_direction = direction
	var anim_direction = direction if direction != 0 else last_direction
	anim_tree.set("parameters/Hit/blend_position", anim_direction)
	anim_tree.set("parameters/Die/blend_position", anim_direction)

	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 0:
			anim_tree.set("parameters/Fall/blend_position", anim_direction)
			anim_state.travel("Fall")
			if is_on_floor():
				change_state(States.IDLE)

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		change_state(States.JUMP)
		in_air = true
	elif current_state == States.JUMP and is_on_floor():
		anim_tree.set("parameters/Idle/blend_position", anim_direction)
		change_state(States.IDLE)
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
		change_state(States.MOVE)
	if Input.is_action_pressed("ui_down") and is_on_floor():
		change_state(States.SWALLOW)
		
	move_and_slide()
		
	match current_state:
		States.IDLE:
			if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
				change_state(States.MOVE)
			if Input.is_action_just_pressed("ui_up"):
				change_state(States.JUMP)
			if Input.is_action_pressed("ui_down"):
				change_state(States.SWALLOW)
		States.MOVE:
			handle_move(direction)
		States.JUMP:
			handle_jump(direction)
		States.SWALLOW:
			handle_swallow(direction)
		States.DEATH:
			handle_death()
			
func change_state(new_state):
	current_state = new_state

func handle_jump(direction):
	if direction != 0:
		var last_direction = direction
	var anim_direction = direction if direction != 0 else last_direction
	anim_tree.set("parameters/Jump/blend_position", anim_direction)
	velocity.y = JUMP_VELOCITY
	if(Input.is_action_just_pressed("ui_up")):
		anim_state.travel("Jump")
		if is_on_floor() and direction == 0:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func handle_move(direction):
	if direction != 0:
		var last_direction = direction
	var anim_direction = direction if direction != 0 else last_direction
	anim_tree.set("parameters/Move/blend_position", anim_direction)
	velocity.x = direction * SPEED
	if direction != 0:
		if is_on_floor():
			anim_state.travel("Move")
			if current_state != States.MOVE:
				change_state(States.MOVE)
	else:
		if is_on_floor() and current_state != States.IDLE:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			anim_tree.set("parameters/Idle/blend_position", anim_direction)
			anim_state.travel("Idle")
			change_state(States.IDLE)

func handle_swallow(direction):
	if direction != 0:
		var last_direction = direction
	var anim_direction = direction if direction != 0 else last_direction
	anim_tree.set("parameters/Swallow/blend_position", anim_direction)
	if(Input.is_action_pressed("ui_down")):
		anim_state.travel("Swallow")
	if is_on_floor() and direction == 0:
		velocity.x = move_toward(velocity.x, 0, SPEED)
func handle_death():
	pass


