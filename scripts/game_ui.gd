extends CanvasLayer

@export var max_health = 100
var current_health = 100

@onready var health_bar = $TopBar/VBoxContainer/HBoxContainer/HealthContainer/HealthBar
@onready var health_label = $TopBar/VBoxContainer/HBoxContainer/HealthContainer/HealthBar/HealthLabel
@onready var score_label = $TopBar/VBoxContainer/HBoxContainer/StatsContainer/ScoreLabel
@onready var timer_label = $TopBar/VBoxContainer/HBoxContainer/StatsContainer/TimerLabel
@onready var completion_screen = $CompletionScreen
@onready var completion_time = $CompletionScreen/Panel/VBoxContainer/StatsContainer/TimeLabel
@onready var completion_score = $CompletionScreen/Panel/VBoxContainer/StatsContainer/ScoreLabel
@onready var completion_health = $CompletionScreen/Panel/VBoxContainer/StatsContainer/HealthLabel
@onready var controls_hint = $ControlsHint
@onready var game_over_screen = $GameOverScreen
@onready var game_over_score = $GameOverScreen/Panel/VBoxContainer/FinalScore

var score = 0
var elapsed_time = 0.0
var is_timer_running = true
var level_completed = false
var game_over = false
var current_level_number = 1  # Will be set by game manager

func _ready():
	update_health(current_health)
	update_score(0)
	# Make sure all UI elements exist
	if not health_bar or not health_label or not score_label or not timer_label:
		push_error("UI elements not found! Check node paths.")
	
	# Hide completion screen initially
	if completion_screen:
		completion_screen.visible = false
	
	# Hide game over screen initially
	if game_over_screen:
		game_over_screen.visible = false
	
	# Hide controls hint after 5 seconds
	if controls_hint:
		await get_tree().create_timer(5.0).timeout
		var tween = create_tween()
		tween.tween_property(controls_hint, "modulate:a", 0.0, 1.0)
		tween.tween_callback(func(): controls_hint.visible = false)

func _process(delta):
	if is_timer_running:
		elapsed_time += delta
		update_timer()
	
	# Check for continue input when level is completed
	if level_completed and Input.is_action_just_pressed("ui_accept"):
		continue_to_next_level()
	
	# Check for restart on game over
	if game_over and Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()

func update_health(health: int):
	current_health = health
	if health_bar and health_label:
		health_bar.value = health
		health_label.text = str(health) + "/" + str(max_health)
		
		# Color feedback for health
		if health < max_health * 0.3:
			health_bar.modulate = Color(1, 0.3, 0.3)  # Red when low
		elif health < max_health * 0.6:
			health_bar.modulate = Color(1, 1, 0.3)  # Yellow when medium
		else:
			health_bar.modulate = Color(0.3, 1, 0.3)  # Green when high

func update_score(points: int):
	score += points
	if score_label:
		score_label.text = "SCORE: " + str(score)

func update_timer():
	var minutes = int(elapsed_time / 60.0)
	var seconds = int(elapsed_time) % 60
	if timer_label:
		timer_label.text = "TIME: %02d:%02d" % [minutes, seconds]

func stop_timer():
	is_timer_running = false

func show_completion_screen():
	level_completed = true
	is_timer_running = false
	SFX.play_complete()  # Play completion sound
	
	# Save progress to GameData
	GameData.complete_level(current_level_number, score, elapsed_time)
	
	if completion_screen:
		# Update completion stats
		var minutes = int(elapsed_time / 60.0)
		var seconds = int(elapsed_time) % 60
		completion_time.text = "Time: %02d:%02d" % [minutes, seconds]
		completion_score.text = "Score: " + str(score)
		completion_health.text = "Health Remaining: " + str(current_health)
		
		# Show the screen with animation
		completion_screen.modulate.a = 0.0
		completion_screen.visible = true
		var tween = create_tween()
		tween.tween_property(completion_screen, "modulate:a", 1.0, 0.5)

func continue_to_next_level():
	# Load next level or return to menu
	var next_level_num = current_level_number + 1
	var next_level = "res://scenes/levels/level_%d.tscn" % next_level_num
	if ResourceLoader.exists(next_level):
		SceneTransition.transition_to_scene(next_level)
	else:
		# No next level, return to level select
		SceneTransition.transition_to_scene("res://scenes/ui/level_select.tscn")

func show_game_over():
	game_over = true
	is_timer_running = false
	
	if game_over_screen:
		game_over_score.text = "Final Score: " + str(score)
		
		# Show the screen with animation
		game_over_screen.modulate.a = 0.0
		game_over_screen.visible = true
		var tween = create_tween()
		tween.tween_property(game_over_screen, "modulate:a", 1.0, 0.5)
		print("All levels complete! You won!")
		get_tree().reload_current_scene()
