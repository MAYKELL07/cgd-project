extends CanvasLayer

signal transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready():
	color_rect.visible = false

func fade_to_black(duration: float = 0.5):
	color_rect.visible = true
	color_rect.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_from_black(duration: float = 0.5):
	color_rect.modulate.a = 1.0
	color_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished
	color_rect.visible = false

func transition_to_scene(scene_path: String, duration: float = 0.5):
	await fade_to_black(duration)
	get_tree().change_scene_to_file(scene_path)
	await fade_from_black(duration)
	transition_finished.emit()
