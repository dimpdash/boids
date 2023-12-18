extends CharacterBody2D
class_name Boid

@onready var collision_shape_2d = $View
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var seperation_point_line = $SeperationPoint
@onready var cohesion_point_line = $CohesionPoint
@onready var alignment_point_line = $AlignmentPoint
@onready var body = $Body

@export var SPEED := 80.0
@export var min_speed := 20.0
@export var seperation_factor := 0.002
@export var cohesion_factor := 0.001
@export var matching_factor := 0.001
@export var close_range := 60.0

func _ready():
	velocity = get_direction() * SPEED


var flock = []

func get_direction() -> Vector2:
	var direction = Vector2.RIGHT.rotated(rotation)
	return direction	
	
func _physics_process(delta):
	
	# seperation
	var close_acc_dist := Vector2.ZERO
	
	# alignment
	var birds_avg_alignment := Vector2.ZERO
	
	# cohesion
	var cohesion_point := Vector2.ZERO
	var birds_in_cohesion_point := 0
	
	for boid in flock:
		var displacement : Vector2 = boid.global_position - global_position 
		var distance = displacement.length()
		if 	distance < close_range:
			close_acc_dist -= displacement
		else:
			cohesion_point += displacement
			birds_avg_alignment += boid.velocity.normalized()
			birds_in_cohesion_point += 1
		
	# normalise the accumlated 
	#print(birds_in_cohesion_point)
	if birds_in_cohesion_point > 0:
		cohesion_point = cohesion_point / birds_in_cohesion_point
		birds_avg_alignment = birds_avg_alignment / birds_in_cohesion_point
	
	cohesion_point_line.clear_points()
	cohesion_point_line.points = [
		Vector2.ZERO,
		cohesion_point.rotated(-rotation)
	]
	
	seperation_point_line.points = [
		Vector2.ZERO,
		close_acc_dist.rotated(-rotation)
	]
	alignment_point_line.points = [
		Vector2.ZERO,
		birds_avg_alignment.rotated(-rotation) * 100
	]
	
	
	velocity += cohesion_point * cohesion_factor
	velocity += close_acc_dist * seperation_factor
	#velocity += birds_avg_alignment * matching_factor
	#clamp velocity to max speed
	if velocity.length() > SPEED:
		velocity = velocity.normalized()*SPEED
	elif velocity.length() < min_speed:
		velocity = velocity.normalized()*min_speed
	
	
	global_position = global_position + velocity * delta
	rotation = velocity.angle()
	

func _process(delta):
		animated_sprite_2d.play("fly")
		

func _on_view_body_entered(incoming_body):
	if incoming_body is Boid and incoming_body != self:
		flock.append(incoming_body)


func _on_view_body_exited(body):
	if body in flock:
		flock.erase(body)
