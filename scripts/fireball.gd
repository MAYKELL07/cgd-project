extends Area2D

var direction = Vector2.RIGHT
var speed = 200.0
var damage = 25

func _process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	call_deferred("queue_free")

func _on_visible_on_screen_notifier_2d_screen_exited():
	call_deferred("queue_free")
