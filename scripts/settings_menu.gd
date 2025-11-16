extends Control

@onready var music_slider = $VBoxContainer/MusicContainer/MusicSlider
@onready var music_value_label = $VBoxContainer/MusicContainer/ValueLabel
@onready var sfx_slider = $VBoxContainer/SFXContainer/SFXSlider
@onready var sfx_value_label = $VBoxContainer/SFXContainer/ValueLabel
@onready var back_button = $BackButton
@onready var reset_button = $VBoxContainer/ResetProgressButton

func _ready():
	# Setup sliders
	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.step = 1
	music_slider.value = AudioManager.music_volume * 100
	
	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	sfx_slider.step = 1
	sfx_slider.value = AudioManager.sfx_volume * 100
	
	# Connect signals
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	
	# Update labels
	_update_labels()

func _on_music_changed(value: float):
	AudioManager.set_music_volume(value / 100.0)
	_update_labels()

func _on_sfx_changed(value: float):
	AudioManager.set_sfx_volume(value / 100.0)
	_update_labels()

func _update_labels():
	music_value_label.text = str(int(music_slider.value)) + "%"
	sfx_value_label.text = str(int(sfx_slider.value)) + "%"

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_reset_pressed():
	# Show confirmation dialog
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Are you sure you want to reset all progress?\nThis will unlock only Level 1 and clear all scores."
	dialog.title = "Reset Progress"
	dialog.confirmed.connect(func():
		GameData.reset_progress()
		dialog.queue_free()
	)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	add_child(dialog)
	dialog.popup_centered()
