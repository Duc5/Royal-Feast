extends FeastInteractable
## the weakened oak in the forest. three separate spatula hits bring it down
## and it becomes the bridge over the river. it keeps track of its own hits
## and doesn't depend on the quest, so it works whatever order you do things in
signal puzzle_completed(id: String)
var hits: int = 0

func _ready() -> void:
	super._ready()
	add_to_group("damageable")
	# loads hits from State so a half chopped tree stays cracked after a reload
	hits = int(State.flags.get("tree_hits",0))
	sync()

# overrides the base sync. once the bridge exists the standing tree disappears
func sync() -> void:
	if has_node("Sprite"):
		$Sprite.visible = not State.flags.get("forest_bridge",false)
	queue_redraw()

func receive_hit(_direction: Vector2, _reflected: bool) -> void:
	if State.flags.get("forest_bridge",false):
		return
	hits = mini(hits+1,3)
	State.set_flag("tree_hits",hits)
	if hits >= 3:
		State.set_flag("forest_bridge")
		puzzle_completed.emit("forest_bridge")
		Sound.effect("collect")
		State.save_game()
	else:
		# quick wobble so each hit feels like it landed
		var tween := create_tween()
		tween.tween_property($Sprite,"rotation",0.08,0.07)
		tween.tween_property($Sprite,"rotation",-0.06,0.07)
		tween.tween_property($Sprite,"rotation",0.0,0.07)
	queue_redraw()

func interact(_actor: Node2D) -> void:
	State.dialogue_requested.emit("The weakened oak",["The trunk looks old and brittle. A few strong hits might bring it down." if hits < 3 else "The fallen trunk stretches across the river. A way through!"])

# crack line in the trunk after the first hit, gone once it falls
func _draw() -> void:
	super._draw()
	if hits > 0 and hits < 3:
		draw_polyline(PackedVector2Array([Vector2(-3,-20),Vector2(2,-16),Vector2(-1,-10),Vector2(3,-3)]),Color("ffe1a1"),1)
