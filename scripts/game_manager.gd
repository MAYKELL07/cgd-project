extends Node2D

@export var level_number: int = 1

@onready var player = $Player
@onready var game_ui = $GameUI

func _ready():
	# Verify nodes exist
	if not player:
		push_error("Player node not found!")
		return
	if not game_ui:
		push_error("GameUI node not found!")
		return
	
	# Play level music
	AudioManager.play_music(preload("res://Audio/Music/level_music.wav"))
	
	# Connect player signals to UI
	if player.health_changed.connect(_on_player_health_changed) != OK:
		push_error("Failed to connect health_changed signal")
	
	if player.player_died.connect(_on_player_died) != OK:
		push_error("Failed to connect player_died signal")
	
	# Set initial max health in UI
	if game_ui:
		game_ui.max_health = player.max_health
		game_ui.update_health(player.current_health)
		game_ui.current_level_number = level_number
	
	# Connect all enemies to score system
	call_deferred("connect_enemies")

func connect_enemies():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.enemy_killed.connect(_on_enemy_killed) != OK:
			push_warning("Failed to connect enemy signal for: " + enemy.name)

func _on_player_health_changed(new_health):
	if game_ui:
		game_ui.update_health(new_health)

func _on_enemy_killed(score_value):
	if game_ui:
		game_ui.update_score(score_value)

func _on_player_died():
	if game_ui:
		game_ui.show_game_over()
