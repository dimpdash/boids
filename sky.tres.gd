extends Area2D

@onready var region = $CollisionShape2D

func _on_body_exited(body):
	var extent = region.shape.size
	if body.global_position.x > extent.x :
		body.global_position.x = 0
	elif body.global_position.x < 0:
		body.global_position.x = extent.x
		
	if body.global_position.y > extent.y :
		body.global_position.y = 0
	elif body.global_position.y < 0:
		body.global_position.y = extent.y
	

