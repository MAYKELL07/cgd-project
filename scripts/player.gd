extends CharacterBody2D

const SPEED = 250.0  # Increased from 200
const JUMP_VELOCITY = -500.0  # Increased from -400 for higher jumps
const COYOTE_TIME = 0.15  # Grace period after leaving platform
const JUMP_BUFFER_TIME = 0.1  # Grace period for early jump input

@export var max_health = 100
@export var current_health = 100
@export var attack_damage = 50

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_invulnerable = false
var attack_area: Area2D
var is_attacking = false
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var was_on_floor = false

signal health_changed(new_health)
signal player_died

func _ready():
	health_changed.emit(current_health)
	setup_attack_area()

func setup_attack_area():
	# Create an attack area as a child
	attack_area = Area2D.new()
	attack_area.name = "AttackArea"
	attack_area.collision_layer = 0
	attack_area.collision_mask = 2  # Hit enemies on layer 2
	add_child(attack_area)
	
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 50
	collision_shape.shape = shape
	attack_area.add_child(collision_shape)
	attack_area.monitoring = false
	
	# Add visual indicator for attack range (optional - can be disabled)
	var attack_indicator = ColorRect.new()
	attack_indicator.name = "AttackIndicator"
	attack_indicator.position = Vector2(-50, -50)
	attack_indicator.size = Vector2(100, 100)
	attack_indicator.color = Color(1, 1, 0, 0.1)  # Subtle yellow tint
	attack_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	attack_indicator.visible = false
	attack_area.add_child(attack_indicator)

func _physics_process(delta):
	# Update coyote time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		was_on_floor = true
	else:
		if was_on_floor:
			coyote_timer -= delta
		was_on_floor = false
	
	# Update jump buffer
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump with coyote time and jump buffer
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
		SFX.play_jump()  # Play jump sound
	
	# Handle attack
	if Input.is_action_just_pressed("ui_select") and not is_attacking:
		perform_attack()

	# Get the input direction and handle the movement/deceleration
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		# Flip sprite based on direction (visual feedback)
		scale.x = sign(direction) if direction != 0 else scale.x
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func perform_attack():
	is_attacking = true
	SFX.play_attack()  # Play attack sound
	
	# Show attack indicator briefly
	if attack_area.has_node("AttackIndicator"):
		attack_area.get_node("AttackIndicator").visible = true
	
	# Visual feedback - flash white and scale up briefly
	var original_modulate = modulate
	modulate = Color(1.5, 1.5, 1.5, 1.0)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "modulate", original_modulate, 0.1)
	tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	if attack_area:
		attack_area.monitoring = true
		# Check for enemies in range
		for body in attack_area.get_overlapping_bodies():
			if body.has_method("die") and body != self:
				body.die()
		# Disable attack area after brief moment
		await get_tree().create_timer(0.15).timeout
		attack_area.monitoring = false
		if attack_area.has_node("AttackIndicator"):
			attack_area.get_node("AttackIndicator").visible = false
	
	await get_tree().create_timer(0.3).timeout  # Attack cooldown
	is_attacking = false

func take_damage(amount: int):
	if is_invulnerable:
		return
	
	current_health -= amount
	current_health = max(0, current_health)
	health_changed.emit(current_health)
	SFX.play_damage()  # Play damage sound
	
	if current_health <= 0:
		die()
	else:
		# Brief invulnerability after taking damage
		is_invulnerable = true
		modulate = Color(1, 0.5, 0.5, 0.7)
		# Blink effect
		var blink_tween = create_tween()
		blink_tween.set_loops(5)
		blink_tween.tween_property(self, "modulate:a", 0.3, 0.1)
		blink_tween.tween_property(self, "modulate:a", 0.7, 0.1)
		
		await get_tree().create_timer(1.0).timeout
		is_invulnerable = false
		modulate = Color(1, 1, 1, 1)

func heal(amount: int):
	current_health += amount
	current_health = min(current_health, max_health)
	health_changed.emit(current_health)
	SFX.play_heal()  # Play heal sound
	
	# Visual feedback for healing
	var heal_tween = create_tween()
	heal_tween.tween_property(self, "modulate", Color(0.5, 1.5, 0.5, 1), 0.2)
	heal_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)

func die():
	player_died.emit()
	SFX.play_game_over()  # Play game over sound
	# Don't reload here - let the game manager handle it
	# to avoid physics callback issues
