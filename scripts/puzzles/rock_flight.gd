extends Node2D
# a thrown stone. flies in a little arc and lands, unless it passes over a
# hidden updraft, in which case the wind catches it, floats it up and
# reveals the updraft. it's how the chef finds safe routes over the chasms
const WindRules = preload("res://scripts/puzzles/wind_course.gd")
var direction: Vector2 = Vector2.UP
var age: float = 0.0
var caught: bool = false
var caught_age: float = 0.0


func _physics_process(delta: float) -> void:
	if State.controls_locked:
		return
	age += delta
	# keeps flying until the wind catches it, then just hangs there floating
	if not caught:
		position += direction*155*delta
	else:
		caught_age += delta
	for wind: Node2D in get_tree().get_nodes_in_group("updraft"):
		if global_position.distance_to(wind.global_position) < WindRules.RADIUS:
			caught = true
			wind.reveal()

	# floats for a bit if caught so you can see where the updraft is,
	# otherwise disappears once it would have hit the ground
	if (caught and caught_age > 1.7) or (not caught and age > 2.3):
		queue_free()
	var lift: float = minf(caught_age*45,28) if caught else sin(minf(age/2.3,1)*PI)*18
	$Sprite.position.y = -lift
