extends Control

@onready var grid_container = $ScrollContainer/GridContainer
@onready var back_button = $BackButton

const TOTAL_LEVELS = 3  # Now we have 3 levels!
const LEVEL_NAMES = [
	"WINDOW_1.exe",
	"CORRUPTED_FILE.dll",
	"VIRUS_SOURCE.bin"
]

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	_populate_levels()
	
	# Add hover effect to back button
	_setup_button_hover(back_button)

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

func _populate_levels():
	# Clear existing children
	for child in grid_container.get_children():
		child.queue_free()
	
	# Create level buttons
	for i in range(1, TOTAL_LEVELS + 1):
		var level_button = create_level_button(i)
		grid_container.add_child(level_button)

func create_level_button(level_num: int) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(180, 180)
	
	var is_unlocked = GameData.is_level_unlocked(level_num)
	var level_name = LEVEL_NAMES[level_num - 1] if level_num <= LEVEL_NAMES.size() else "UNKNOWN_FILE"
	
	if is_unlocked:
		button.text = "WINDOW %d\n%s" % [level_num, level_name]
		
		# Show score if completed
		var score = GameData.get_level_score(level_num)
		if score > 0:
			button.text += "\n✓ CLEANED\n⭐ %d" % score
		else:
			button.text += "\n[INFECTED]"
		
		button.pressed.connect(func(): _on_level_selected(level_num))
		
		# Add hover effect to level buttons
		_setup_button_hover(button)
	else:
		button.text = "🔒\nLOCKED\n\n%s" % level_name
		button.disabled = true
	
	return button

func _on_level_selected(level_num: int):
	var level_path = "res://scenes/levels/level_%d.tscn" % level_num
	if ResourceLoader.exists(level_path):
		SceneTransition.transition_to_scene(level_path)
	else:
		push_warning("Level %d doesn't exist yet!" % level_num)

func _on_back_pressed():
	SceneTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")
