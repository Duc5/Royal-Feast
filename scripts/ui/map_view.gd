extends Control
## Shared exploration raster; frames, legend and titles are native HUD controls.

func _process(_delta: float) -> void:
	if is_visible_in_tree():
		queue_redraw()

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO,size)
	draw_rect(rect,Color("111e2c"))
	var discovery: Dictionary = State.discovered.get(State.region_id,{})
	var scale_x: float = rect.size.x/60.0
	var scale_y: float = rect.size.y/48.0
	var colors: Dictionary = {"village":Color("708259"),"forest":Color("4b775d"),"mountains":Color("b1c9d2"),"volcano":Color("685251"),"kitchen":Color("a38e71")}
	for key: String in discovery:
		var parts: PackedStringArray = key.split(",")
		var x: int = int(parts[0])
		var y: int = int(parts[1])
		var color: Color = colors[State.region_id]
		if State.region_id == "forest" and y >= 19 and y < 25: color = Color("477e94")
		if State.region_id == "mountains" and y >=13 and y <29: color = Color("34475d")
		draw_rect(Rect2(rect.position+Vector2(x*scale_x,y*scale_y),Vector2(scale_x+0.1,scale_y+0.1)),color)
	var actor: ChefPlayer = get_tree().get_first_node_in_group("player")
	var region: Node = actor.get_parent().get("region") if actor != null else null
	if region != null:
		for object: Node in region.get_children():
			if object is FeastInteractable and object.visible:
				var cell := Vector2i(object.position/16)
				if discovery.has(str(cell.x)+","+str(cell.y)) and object.kind in ["gate","ingredient","npc"]:
					var p: Vector2 = rect.position+object.position/Vector2(960,768)*rect.size
					draw_rect(Rect2(p-Vector2(1,1),Vector2(3,3)),Color("efc66d") if object.kind != "npc" else Color("dbd6b5"))
	var p: Vector2 = rect.position+State.chef_position/Vector2(960,768)*rect.size
	draw_rect(Rect2(p-Vector2(1,1),Vector2(3,3)),Color.WHITE)
	draw_rect(rect,Color("aa9066"),false,1)
