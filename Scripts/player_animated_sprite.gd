extends AnimatedSprite2D

class_name PlayerAnimatedSprite

var frame_count = 0
func trigger_animation(velocity: Vector2, direction: int, player_mode: Player.PlayerMode):
	var animation_prefix = Player.PlayerMode.keys()[player_mode].to_snake_case()
	
	if not get_parent().is_on_floor():
		play("%s_jump" % animation_prefix)
	
	#handle slide animations
	elif sign(velocity.x) != sign(direction) && velocity.x != 0 && direction != 0:
		if velocity.y == 0:
			play("%s_slide" % animation_prefix)
			scale.x = direction
	else:
	# handle the sprite direction
		if scale.x == 1 && sign(velocity.x) == -1:
			scale.x = -1
		elif scale.x == -1 && sign(velocity.x) == 1:
			scale.x = 1
		
		# handle run and idle animations
		if velocity.x != 0:
			play("%s_move" % animation_prefix)
		else:
			play("%s_idle" % animation_prefix)

func _on_animation_finished():
	if animation == "slime_swallow":
		if get_parent().player_mode == Player.PlayerMode.SWALLOW:
			get_parent().player_mode = Player.PlayerMode.SLIME
			get_parent().set_physics_process(true)
			var velocity = get_parent().velocity
			var direction = sign(velocity.x)
			get_parent().animated_sprite_2d.trigger_animation(velocity, direction, get_parent().player_mode)



