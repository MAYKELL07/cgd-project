extends CharacterBody2D

@export var move_speed = 80.0
@export var move_distance = 150.0
@export var damage = 20
@export var score_value = 10
@export var enemy_type = "walking" # "walking" or "flying"
@export var detect_edges = true  # Only for walking enemies

var start_position: Vector2
var target_position: Vector2
var moving_right = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var damage_cooldown = {}  # Track cooldown per body

signal enemy_killed(score)

func _ready():
	start_position = global_position
	target_position = start_position + Vector2.RIGHT * move_distance

func _physics_process(delta):
	# Apply gravity only for walking enemies
	if enemy_type == "walking" and not is_on_floor():
		velocity.y += gravity * delta
	
	# Edge detection for walking enemies
	if enemy_type == "walking" and detect_edges and is_on_floor():
		if not check_ground_ahead():
			moving_right = !moving_right
	
	# Move back and forth
	var distance_to_target = global_position.x - (target_position.x if moving_right else start_position.x)
	
	if abs(distance_to_target) < 5.0:
		moving_right = !moving_right
	
	velocity.x = move_speed if moving_right else -move_speed
	
	# For flying enemies, keep vertical velocity at 0
	if enemy_type == "flying":
		velocity.y = 0
	
	move_and_slide()

func check_ground_ahead() -> bool:
	# Raycast to check if there's ground ahead
	var space_state = get_world_2d().direct_space_state
	var direction = Vector2.RIGHT if moving_right else Vector2.LEFT
	var start = global_position + direction * 25  # Check ahead
	var end = start + Vector2.DOWN * 30
	
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	return result.size() > 0

func _on_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		# Check cooldown
		if damage_cooldown.has(body):
			if Time.get_ticks_msec() - damage_cooldown[body] < 1000:  # 1 second cooldown
				return
		
		body.take_damage(damage)
		damage_cooldown[body] = Time.get_ticks_msec()

func die():
	enemy_killed.emit(score_value)
	SFX.play_enemy_death()  # Play enemy death sound
	call_deferred("queue_free")
