extends CharacterBody2D

@export var move_speed = 80.0
@export var chase_speed = 120.0
@export var move_distance = 150.0
@export var damage = 20
@export var score_value = 10
@export var enemy_type = "walking" # "walking" or "flying"
@export var detect_edges = true  # Only for walking enemies
@export var detection_range = 200.0  # How far enemy can see player
@export var attack_range = 50.0  # Range to stop and attack
@export var jump_force = -300.0  # For jumping over obstacles

var start_position: Vector2
var target_position: Vector2
var moving_right = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var damage_cooldown = {}  # Track cooldown per body

# AI state machine
enum State { PATROL, CHASE, ATTACK, RETURN }
var current_state = State.PATROL
var player: CharacterBody2D = null
var return_timer = 0.0
var attack_cooldown = 0.0
var can_see_player = false
var obstacle_ahead = false

signal enemy_killed(score)

func _ready():
	start_position = global_position
	target_position = start_position + Vector2.RIGHT * move_distance
	
	# Find player reference
	call_deferred("find_player")

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	# Update timers
	if return_timer > 0:
		return_timer -= delta
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	# Apply gravity only for walking enemies
	if enemy_type == "walking" and not is_on_floor():
		velocity.y += gravity * delta
	
	# Update AI state
	update_ai_state()
	
	# Update visual state indicator
	update_visual_state()
	
	# Execute current state behavior
	match current_state:
		State.PATROL:
			patrol_behavior(delta)
		State.CHASE:
			chase_behavior(delta)
		State.ATTACK:
			attack_behavior(delta)
		State.RETURN:
			return_behavior(delta)
	
	move_and_slide()

func update_visual_state():
	# Change color based on state for visual feedback
	var body_node = get_node_or_null("Body")
	if not body_node:
		return
	
	match current_state:
		State.PATROL:
			body_node.color = Color(0.9, 0.1, 0.1, 1)  # Red - normal
		State.CHASE:
			body_node.color = Color(1, 0.5, 0, 1)  # Orange - alert!
		State.ATTACK:
			body_node.color = Color(1, 0, 0, 1)  # Bright red - attacking!
		State.RETURN:
			body_node.color = Color(0.7, 0.3, 0.3, 1)  # Darker red - returning

func update_ai_state():
	if not player:
		current_state = State.PATROL
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	can_see_player = check_line_of_sight_to_player()
	
	match current_state:
		State.PATROL:
			if can_see_player and distance_to_player < detection_range:
				current_state = State.CHASE
		
		State.CHASE:
			if distance_to_player < attack_range:
				current_state = State.ATTACK
			elif not can_see_player or distance_to_player > detection_range * 1.5:
				current_state = State.RETURN
				return_timer = 3.0
		
		State.ATTACK:
			if distance_to_player > attack_range * 1.3:
				current_state = State.CHASE
		
		State.RETURN:
			var distance_to_start = global_position.distance_to(start_position)
			if distance_to_start < 20.0 or return_timer <= 0:
				current_state = State.PATROL
			elif can_see_player and distance_to_player < detection_range * 0.8:
				current_state = State.CHASE

func patrol_behavior(delta):
	# Edge detection for walking enemies
	if enemy_type == "walking" and detect_edges and is_on_floor():
		if not check_ground_ahead():
			moving_right = !moving_right
	
	# Check for walls
	if check_wall_ahead():
		moving_right = !moving_right
	
	# Move back and forth
	var distance_to_target = global_position.x - (target_position.x if moving_right else start_position.x)
	
	if abs(distance_to_target) < 5.0:
		moving_right = !moving_right
	
	velocity.x = move_speed if moving_right else -move_speed
	
	# For flying enemies, keep vertical velocity at 0
	if enemy_type == "flying":
		velocity.y = 0

func chase_behavior(delta):
	if not player:
		return
	
	var direction_to_player = sign(player.global_position.x - global_position.x)
	moving_right = direction_to_player > 0
	
	# Check for obstacles
	obstacle_ahead = check_wall_ahead()
	
	# Jump over obstacles if walking enemy
	if enemy_type == "walking" and obstacle_ahead and is_on_floor():
		velocity.y = jump_force
	
	# Move towards player
	velocity.x = chase_speed * direction_to_player
	
	# Flying enemies move vertically too
	if enemy_type == "flying":
		var vertical_direction = sign(player.global_position.y - global_position.y)
		velocity.y = chase_speed * 0.5 * vertical_direction

func attack_behavior(delta):
	# Stop moving and prepare to attack
	velocity.x = move_toward(velocity.x, 0, move_speed * delta * 5)
	
	if enemy_type == "flying":
		velocity.y = move_toward(velocity.y, 0, move_speed * delta * 5)
	
	# Face the player
	if player:
		moving_right = player.global_position.x > global_position.x
	
	# Perform attack periodically
	if attack_cooldown <= 0:
		perform_attack()
		attack_cooldown = 1.5

func return_behavior(delta):
	var direction_to_start = sign(start_position.x - global_position.x)
	moving_right = direction_to_start > 0
	
	velocity.x = move_speed * direction_to_start
	
	if enemy_type == "flying":
		var vertical_direction = sign(start_position.y - global_position.y)
		velocity.y = move_speed * 0.5 * vertical_direction

func perform_attack():
	# Visual attack indicator
	modulate = Color(1.5, 0.5, 0.5, 1)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
	
	# Check if player is in attack range
	if player and global_position.distance_to(player.global_position) < attack_range:
		if player.has_method("take_damage"):
			# Only damage if not on cooldown
			if not damage_cooldown.has(player) or Time.get_ticks_msec() - damage_cooldown[player] >= 1000:
				player.take_damage(damage)
				damage_cooldown[player] = Time.get_ticks_msec()

func check_line_of_sight_to_player() -> bool:
	if not player:
		return false
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	query.exclude = [self]
	query.collision_mask = 1  # Only check player layer
	var result = space_state.intersect_ray(query)
	
	return result.size() > 0 and result.collider == player

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

func check_wall_ahead() -> bool:
	# Raycast to check if there's a wall ahead
	var space_state = get_world_2d().direct_space_state
	var direction = Vector2.RIGHT if moving_right else Vector2.LEFT
	var start = global_position
	var end = start + direction * 30
	
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.exclude = [self]
	query.collision_mask = 1  # Check walls/platforms
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
	
	# Trigger death particles
	if has_node("DeathParticles"):
		var particles = get_node("DeathParticles")
		particles.emitting = true
		# Hide visual body parts
		for child in get_children():
			if child is ColorRect:
				child.visible = false
		# Wait for particles to finish before removing
		await get_tree().create_timer(1.0).timeout
	
	call_deferred("queue_free")
