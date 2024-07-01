extends CharacterBody3D

var speed = 15
var accel = 10

@onready var target1 = get_node("../NavigationRegion3D/target")
@onready var target2 = get_node("../NavigationRegion3D/target2")
@onready var target3 = get_node("../NavigationRegion3D/target3")
@onready var target4 = get_node("../NavigationRegion3D/target4")
@onready var targets = [target1, target2, target3, target4]
var current_target = 0

@onready var nav: NavigationAgent3D = $NavigationAgent3D

var direction = Vector3()

func _physics_process(delta):
	nav.target_position = targets[current_target].global_position
	
	var new_direction = nav.get_next_path_position() - global_position
	new_direction = new_direction.normalized()
	
	direction = direction.lerp(new_direction, accel * delta)
	
	velocity = direction * speed
	move_and_slide()
	
	if position.distance_to(targets[current_target].global_position) < 5:
		current_target = randi() % targets.size()
	
	look_at(global_transform.origin + direction, Vector3.UP)
