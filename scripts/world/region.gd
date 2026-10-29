extends Node2D
const WindRules = preload("res://scripts/puzzles/wind_course.gd")

@export var region_id: String = "village"
var clock: float = 0.0
var spout_clock: float = 1.0
var puzzle_hint_index: int = 0
var bridge_x: float = 480
var pigeon_arrival_active: bool = false

const HINTS: Dictionary = {
	"forest":["Maybe something near the river could help.","The tree by the water might be as tall as the river's width.","Hit the tree trunk 3 times to make a bridge over the river"],
	"mountains":["The valley may contain some hidden gusts ","Throw loose stones into the gap. Some may rise, revealing hidden air currents.","Right click the stones and use it to find the air current, jump between air currents to reach the other side."],
	"volcano":["The dark furnace may react to fire.","Reflect the fireballs to hit the three furnaces to open the vault hiding the pepper."]}

#Initialise all the positions of the puzzles
func _ready() -> void:
	State.changed.connect(sync)
	if region_id == "forest":
#		Random coordinate of the bridge
		bridge_x = [416,480,544][State.seed_value % 3]
		$WeakenedOak.position.x = bridge_x
		$FallenBridge.position.x = bridge_x
		$Mushroom.position.x = bridge_x
		$RiverGap.position.x = bridge_x
		$RiverLeft.position.x = (bridge_x-18)/2
		$RiverLeft/Collision.shape = $RiverLeft/Collision.shape.duplicate()
		$RiverLeft/Collision.shape.size.x = bridge_x-18
		$RiverRight.position.x = (bridge_x+18+960)/2
		$RiverRight/Collision.shape = $RiverRight/Collision.shape.duplicate()
		$RiverRight/Collision.shape.size.x = 960-bridge_x-18
		
	if region_id == "mountains":
		for i: int in range(3):
			get_node("Wind%d"%i).position = WindRules.PATTERNS[State.seed_value%3][i]
			
			
	if region_id == "volcano":
		var patterns: Array = [
#			Hardcoded positions of furnaces
			[Vector2(384,304),Vector2(480,280),Vector2(576,304)],
			[Vector2(368,300),Vector2(480,320),Vector2(592,300)],
			[Vector2(384,328),Vector2(480,280),Vector2(576,328)]
			]
		for i: int in range(3):
			get_node("Switch%d"%i).position = patterns[State.seed_value%3][i]
	sync()

#Update world as player progress
func sync() -> void:

#	Change collision property of river when forest bridge puzzle is solved, so player can cross through
	if region_id == "forest":
		var solved: bool = State.flags.get("forest_bridge",false)
		$RiverGap/Collision.set_deferred("disabled",solved)
		$FallenBridge.visible = solved
	
#	Open only the vault's central gate; its side walls stay solid.
	if region_id == "volcano":
		var solved: bool = State.flags.get("greenhouse_open",false)
		$GreenhouseBarrier/Collision.set_deferred("disabled",solved)
		$GreenhouseBarrier/ForgeDoor.visible = not solved
		$Spout/WarningRing.visible = spout_clock < 0.65
		
#	Allow displaying ingredients on table once they are all collected
	if region_id == "kitchen" and State.flags.get("presented",false) and not has_node("IngredientDisplay"):
		var display := Node2D.new()
		display.name = "IngredientDisplay"
		display.z_index = 6
		add_child(display)
#		Create the Sprite node to display them on table
		for i: int in range(3):
			var icon := Sprite2D.new()
			icon.texture = load("res://assets/custom/"+State.ITEMS[i]+".svg")
			icon.position = Vector2(455+i*24,269)
			display.add_child(icon)
			
	queue_redraw()

func _physics_process(delta: float) -> void:
	if State.controls_locked:
		return
	clock += delta #Gameplay time

	var chef: ChefPlayer = get_tree().get_first_node_in_group("player")
	if chef == null:
		return
		
#	Opening stage, when letter is spawned in the beginning

#	Forest checkpoint
	if region_id == "forest" and chef.position.y > 422 and chef.position.y < 480:
		chef.checkpoint = Vector2(bridge_x,462)
		
#	Mountain checkpoint if player fall down to chasm
	if region_id == "mountains":
		if chef.position.y > WindRules.CHASM_BOTTOM and chef.position.y < 530:
			chef.checkpoint = WindRules.CHECKPOINT
		if chef.position.y < WindRules.CHASM_BOTTOM and chef.position.y > WindRules.CHASM_TOP and chef.height <= 0:
			chef.respawn()
			
	if region_id == "volcano":
		#	Volcano checkpoint if player die by fireball
		if chef.position.y > 420 and chef.position.y < 470:
			chef.checkpoint = Vector2(480,452)
			
		spout_clock -= delta
		if spout_clock <= 0:
			spout_clock = 2.7
#			Generate fireball projectile targeted at player
			var projectile: Node2D = preload("res://scenes/objects/projectile.tscn").instantiate()
			projectile.position = $Spout.position + Vector2(0,-6)
			projectile.direction = (chef.position-projectile.position).normalized()
			add_child(projectile)
		$Spout/WarningRing.visible = spout_clock < 0.65
	
#	Check for hint key pressed near puzzle region
	if Input.is_action_just_pressed("hint") and HINTS.has(region_id):
		if chef.position.y < 520 and chef.position.y > 200:
			State.dialogue_requested.emit("Optional hint %d / 3" % (mini(puzzle_hint_index,2)+1),[HINTS[region_id][mini(puzzle_hint_index,2)]])
			puzzle_hint_index += 1
		else:
			State.notified.emit("Hints are available near the region's main puzzle.")
	queue_redraw()
