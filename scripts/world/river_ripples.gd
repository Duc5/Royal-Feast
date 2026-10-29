extends Node2D
## Sprite-only overlay. Existing terrain and bridge collision remain in the region.
@export var drift_speed: float = 11.0
var clock: float = 0.0

func _physics_process(delta: float) -> void:
	if State.controls_locked:
		return
	clock += delta
	for i: int in range(get_child_count()):
		var ripple: Sprite2D = get_child(i) as Sprite2D
		ripple.position.x = fmod(i*37+clock*drift_speed,944)+8
		ripple.frame = (int(clock*4)+i) % 4
