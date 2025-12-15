extends CanvasLayer

@onready var pause_panel = $PausePanel
@onready var resume_button = $PausePanel/VBoxContainer/ResumeButton
@onready var restart_button = $PausePanel/VBoxContainer/RestartButton
@onready var menu_button = $PausePanel/VBoxContainer/MenuButton
@onready var quit_button = $PausePanel/VBoxContainer/QuitButton

var is_paused = false

func _ready():
	pause_panel.visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Add hover effects to all buttons
	_setup_button_hover(resume_button)
	_setup_button_hover(restart_button)
	_setup_button_hover(menu_button)
	_setup_button_hover(quit_button)

func _setup_button_hover(button: Button):
	button.mouse_entered.connect(func(): 
		SFX.play_button_hover()
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)
	)
	button.mouse_exited.connect(func(): 
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
	)
	button.pressed.connect(func(): 
		SFX.play_button_click()
	)

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	pause_panel.visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		SFX.play_menu_open()

func _on_resume_pressed():
	toggle_pause()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	SceneTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().quit()
