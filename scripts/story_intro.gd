extends Control

@onready var story_text = $Panel/VBoxContainer/StoryText
@onready var skip_label = $SkipLabel
@onready var continue_button = $Panel/VBoxContainer/ContinueButton

const STORY = """THE YEAR IS 2035

You never installed antivirus software.
You never cleaned up your files.
You never bothered with updates.

Ten years of neglect.
Ten years of downloaded files.
Ten years of "I'll do it later."

Then you clicked on "FreeGame_TOTALLY_SAFE.exe"

A VIRUS has infected your system.
Your desktop is FROZEN.
Your files are CORRUPTED.
Your apps won't OPEN.

If you restart now, you lose EVERYTHING.

There's only one way out...

You must enter the system yourself.
Fight the BUGS.
Close the infected WINDOWS.
Delete the corrupted FILES.
Find and DESTROY the virus source.

Your digital life depends on it.

Time to clean up your mess.
"""

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)
	_animate_text()

func _animate_text():
	story_text.text = ""
	story_text.visible_ratio = 0
	
	# Type out effect
	var full_text = STORY
	story_text.text = full_text
	
	var char_count = full_text.length()
	var duration = char_count * 0.03  # 0.03s per character
	
	var tween = create_tween()
	tween.tween_property(story_text, "visible_ratio", 1.0, duration)
	await tween.finished
	
	# Show continue button after story
	continue_button.visible = true
	continue_button.modulate = Color(1, 1, 1, 0)
	var button_tween = create_tween()
	button_tween.tween_property(continue_button, "modulate:a", 1.0, 0.5)

func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		if continue_button.visible:
			_on_continue_pressed()
		else:
			# Skip animation
			get_tree().create_tween().kill()
			story_text.visible_ratio = 1.0
			continue_button.visible = true
			continue_button.modulate.a = 1.0

func _on_continue_pressed():
	SceneTransition.transition_to_scene("res://scenes/levels/level_1.tscn")
