extends PhysicsMover3D

class_name Player

export var move_acceleration = 390.0
export var air_acceleration = 120.0
export var jump_total_acceleration = 7200.0
export var jump_total_number_of_frames = 3
export var gravity = -25.0

export var ground_dampening = 0.7


enum State {
	DEFAULT
}

var state = State.DEFAULT

onready var model = $PlayerModel

var jump_frame_count := -1
func handle_input(delta):
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# make move direction relative to camera instead of relative to player by rotating
#	move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	
	# TODO check if move_direction is truly non zero if no key pressed
	if is_on_floor():
		add_acceleration(move_acceleration * move_direction)
	else:
		# get ourselves some nice air strafing
		add_acceleration(air_acceleration * move_direction)
	
	var start_jumping  = is_on_floor() and Input.is_action_just_pressed("jump")
	if start_jumping:
		jump_frame_count = 0
		# set snap vector in super class
		snap_vector = Vector3.ZERO 
		
	if not jump_frame_count == -1: # since -1 means not jumping right now
		if jump_frame_count < jump_total_number_of_frames:
			# spread acceleration evenly (we can try unevenly later)
			add_acceleration(jump_total_acceleration / jump_total_number_of_frames * Vector3.UP)
			jump_frame_count += 1
		else:
			# done with jump acceleration
			jump_frame_count = -1

	var look_direction := -Vector3(acceleration)
	var look_vec2 := Vector2(acceleration.x, acceleration.z)
#	var own_vec2 := Vector2(self.translation.x, self.translation.z)
	
	var angular_velocity := 30.0
	if look_vec2 != Vector2.ZERO and not start_jumping:
		rotation.y = lerp_angle(rotation.y, atan2(-look_direction.x, -look_direction.z), angular_velocity * delta)

func state_default(delta):
	handle_input(delta)
	execute_movement(delta)
	

func match_state(delta):
	match state:
		State.DEFAULT:
			state_default(delta)
	

func _physics_process(delta: float) -> void:
	match_state(delta)
