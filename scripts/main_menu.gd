extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var story_button = $VBoxContainer/StoryButton
@onready var levels_button = $VBoxContainer/LevelsButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var title_label = $TitleLabel
@onready var subtitle_label = $SubtitleLabel

func _ready():
	# Connect buttons
	play_button.pressed.connect(_on_play_pressed)
	story_button.pressed.connect(_on_story_pressed)
	levels_button.pressed.connect(_on_levels_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Add hover effects to all buttons
	_setup_button_hover(play_button)
	_setup_button_hover(story_button)
	_setup_button_hover(levels_button)
	_setup_button_hover(settings_button)
	_setup_button_hover(quit_button)
	
	# Animate title
	_animate_title()
	
	# Animate background if GridPattern exists
	if has_node("GridPattern"):
		_animate_background()
	
	# Play menu music
	AudioManager.play_music(preload("res://Audio/Music/menu_music.mp3"))

func _setup_button_hover(button: Button):
	button.mouse_entered.connect(func(): 
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)
	)
	button.mouse_exited.connect(func(): 
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
	)


func _animate_background():
	# Pulse the grid pattern
	var grid_pattern = get_node("GridPattern")
	if grid_pattern:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(grid_pattern, "modulate:a", 0.3, 2.0)
		tween.tween_property(grid_pattern, "modulate:a", 0.05, 2.0)

func _animate_title():
	title_label.modulate.a = 0
	title_label.position.y -= 50
	subtitle_label.modulate.a = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(title_label, "position:y", title_label.position.y + 50, 1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	var subtitle_tween = create_tween()
	subtitle_tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.5)

func _on_play_pressed():
	# Start from story intro
	SceneTransition.transition_to_scene("res://scenes/ui/story_intro.tscn")

func _on_story_pressed():
	# View story again
	SceneTransition.transition_to_scene("res://scenes/ui/story_intro.tscn")

func _on_levels_pressed():
	# Open level select
	SceneTransition.transition_to_scene("res://scenes/ui/level_select.tscn")

func _on_settings_pressed():
	# Open settings
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
