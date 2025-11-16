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

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	pause_panel.visible = is_paused
	get_tree().paused = is_paused

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
