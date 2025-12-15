extends Area2D

@export var health_amount = 25

@onready var collection_particles = $CollectionParticles

func _on_body_entered(body):
	if body.has_method("heal"):
		body.heal(health_amount)
		
		# Trigger collection particles
		if collection_particles:
			collection_particles.emitting = true
			collection_particles.reparent(get_tree().current_scene)
			collection_particles.global_position = global_position
		
		# Hide visual elements
		for child in get_children():
			if child is ColorRect:
				child.hide()
		
		# Wait for particles to finish, then delete
		await get_tree().create_timer(1.0).timeout
		call_deferred("queue_free")
