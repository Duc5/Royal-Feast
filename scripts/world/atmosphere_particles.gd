extends CPUParticles2D
## Freeze existing particles during dialogue/menus without clearing or restarting them.
func _process(_delta: float) -> void:
	speed_scale = 0.0 if State.controls_locked else 1.0
