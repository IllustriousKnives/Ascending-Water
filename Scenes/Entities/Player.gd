extends CharacterBody2D
class_name Player 

@export var SPEED: int = 700
@export var GRAVITY: int = 90
@export var JUMP_POWER: int = 2110
@export var DOUBLE_JUMP: int = 0

var DOUBLE_JUMP_LEFT = DOUBLE_JUMP
var is_jumping = false
var possible_coyote = true
var coyote_max_msec_time = 100
@onready var time_start = Time.get_ticks_msec()
var time_elapsed = 0  # miliseconds
@onready var last_time_on_floor = Time.get_ticks_msec()

var in_liquid = false
var lock_position = false
var can_walljump = true
var current_walljump_function_id = 0
var smooth_x_movement = false
var gravity_direction = "down"

signal jump_pressed

var type = "player"
var motion = Vector2()
var modified_motion = Vector2()

func _ready():
	change_gravity(gravity_direction)

func _physics_process(_delta):
	time_elapsed = (time_start - Time.get_ticks_msec())*(-1)
	
	# Signal Emitters
	check_jump_pressed()
	
	# Keys Actions
	key_action_to_rotate_gravity()
	
	if lock_position:
		movement_particles_effect()
		return
	
	if not in_liquid:
		horizontal_move()
		
		if is_on_floor():
			last_time_on_floor = time_elapsed
			motion.y = 0
			reset_double_jump_count__coyote()
			can_jump()
			
		if not is_on_floor():
			double_jump_skill()
			coyote_jump_skill()
			
		apply_gravity()
	
	if in_liquid:
		is_jumping = false
		reset_double_jump_count()
		apply_gravity_in_liquid()
		horizontal_move_in_liquid()
		
		if is_on_floor():
			last_time_on_floor = time_elapsed
			reset_double_jump_count__coyote()
			can_jump()
		
		if not is_on_floor():
			coyote_jump_skill()
	
	movement_particles_effect()
	check_is_not_jumping()
	jump_cut()
	modified_motion = motion
	modify_motion_by_gravity_direction()  # modify 'modified_motion' var
	set_velocity(modified_motion)
	#set_up_direction(Vector2.UP)
	move_and_slide()

func check_jump_pressed():
	if Input.is_action_just_pressed("space"):
		emit_signal("jump_pressed")

func check_is_not_jumping():
	if motion.y >= 0:
		is_jumping = false

func coyote_jump_skill():
	if time_elapsed - last_time_on_floor <= coyote_max_msec_time:
		possible_coyote = true
	else:
		possible_coyote = false
	
	if Input.is_action_just_pressed("space"):
			if possible_coyote == true and not is_jumping:
				print("coyoted")
				possible_coyote = false
				motion.y = -JUMP_POWER
				is_jumping = true

func double_jump_skill():
	if Input.is_action_just_pressed("space"):
		if possible_coyote == false:
			if DOUBLE_JUMP_LEFT >= 1:
				DOUBLE_JUMP_LEFT -= 1
				motion.y = -JUMP_POWER
				is_jumping = true

func reset_double_jump_count__coyote():
	DOUBLE_JUMP_LEFT = DOUBLE_JUMP
	possible_coyote = true

func reset_double_jump_count():
	DOUBLE_JUMP_LEFT = DOUBLE_JUMP

func can_jump():
	if Input.is_action_pressed("space"):
			motion.y = -JUMP_POWER
			is_jumping = true
			print("jumped")

func jump_cut():
	if is_jumping and not Input.is_action_pressed("space"):
		motion.y *= 0.5

func horizontal_move():
	if smooth_x_movement:
		if Input.is_action_pressed("left"):
			motion.x = motion.move_toward(Vector2(-SPEED,motion.y), 27).x
		elif Input.is_action_pressed("right"):
			motion.x = motion.move_toward(Vector2(SPEED,motion.y), 27).x
		else:
			motion.x = motion.move_toward(Vector2(0,motion.y), 27).x
		return
	
	if Input.is_action_pressed("left"):
		motion.x = -SPEED
	elif Input.is_action_pressed("right"):
		motion.x = SPEED
	else:
		motion.x = 0

func horizontal_move_in_liquid():
	var direction = Vector2.ZERO
	if Input.is_action_pressed("left"):
		direction += Vector2(-1, 0)
	if Input.is_action_pressed("right"):
		direction += Vector2(1, 0)
	if Input.is_action_pressed("up") or Input.is_action_pressed("space"):
		direction += Vector2(0, -1)
	if Input.is_action_pressed("down"):
		direction += Vector2(0, 1)
	motion = motion.move_toward(direction * (SPEED + GRAVITY), 50)

func apply_gravity():
	motion.y += GRAVITY

func apply_gravity_in_liquid():
	motion = motion.move_toward(Vector2.ZERO, 30)

func movement_particles_effect():
	if motion.length() > 22 and not lock_position:
		$Particles_by_moving.emitting = true
	else:
		$Particles_by_moving.emitting = false

func on_walljump_left(_body):
	if can_walljump and not in_liquid:
		can_walljump = false
		lock_position = true
		wait_and_do_walljump("right")

func on_walljump_right(_body):
	if can_walljump and not in_liquid:
		can_walljump = false
		lock_position = true
		wait_and_do_walljump("left")

func wait_and_do_walljump(walljump_direction):
	walljump_effect()
	# to do a reset-like function for multiple walljumps case
	var function_id = current_walljump_function_id + 1
	current_walljump_function_id = function_id
	
	await self.jump_pressed
	print("WallJumped")
	smooth_x_movement = true
	is_jumping = true
	
	if walljump_direction == "right":
		motion = Vector2(500, -JUMP_POWER)
	elif walljump_direction == "left":
		motion = Vector2(-500, -JUMP_POWER)
	
	print(motion)
	lock_position = false
	
	await Global.wait(0.04)
	print(motion)
	can_walljump = true
	await Global.wait(0.3)
	if current_walljump_function_id == function_id:
		smooth_x_movement = false

@onready var Particles_by_WallJumped = preload("res://Scenes/Particles_Emitters/particles_by_wall_jumped.tscn")
func walljump_effect():
	$Colors_Effects.play("Wall_Jump Waiting")
	var particles_emitter = Particles_by_WallJumped.instantiate()
	$".".add_child(particles_emitter)
	
	await self.jump_pressed
	
	$Colors_Effects.play("RESET")
	particles_emitter.restart()
	await Global.wait(1)
	particles_emitter.queue_free()

func change_gravity(direction):
	match direction:
		"top":
			motion.y = -motion.y * 0.4
			gravity_direction = "top"
			
			self.rotation_degrees = 180
			set_up_direction(Vector2.DOWN)
		"down":
			motion.y = -motion.y * 0.4
			gravity_direction = "down"
			
			self.rotation_degrees = 0
			set_up_direction(Vector2.UP)
		"left":
			motion.y = -motion.y * 0.4
			gravity_direction = "left"
			
			self.rotation_degrees = 90
			set_up_direction(Vector2.RIGHT)
		"right":
			motion.y = -motion.y * 0.4
			gravity_direction = "right"
			
			self.rotation_degrees = -90
			set_up_direction(Vector2.LEFT)

func modify_motion_by_gravity_direction():
	match gravity_direction:
		"top":
			modified_motion.y = -motion.y
			modified_motion.x = -motion.x
		"down":
			modified_motion = motion
		"left":
			modified_motion.y = motion.x
			modified_motion.x = -motion.y
		"right":
			modified_motion.y = -motion.x
			modified_motion.x = motion.y
		_:
			modified_motion = motion

### V key_actions V ###

func key_action_to_rotate_gravity():
	if Input.is_action_just_pressed("arrow_right"):
		match gravity_direction:
			"down":
				change_gravity("right")
			"right":
				change_gravity("top")
			"top":
				change_gravity("left")
			"left":
				change_gravity("down")
	if Input.is_action_just_pressed("arrow_left"):
		match gravity_direction:
			"top":
				change_gravity("right")
			"left":
				change_gravity("top")
			"down":
				change_gravity("left")
			"right":
				change_gravity("down")
	if Input.is_action_just_pressed("arrow_top"):
		match gravity_direction:
			"top":
				change_gravity("down")
			"left":
				change_gravity("right")
			"down":
				change_gravity("top")
			"right":
				change_gravity("left")

