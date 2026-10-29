extends Node2D

#region references which area of the map is loaded into scene
var region: Node2D

@onready var chef: ChefPlayer = $Chef
@onready var hud: Control = $HUD/Canvas

func _ready() -> void:
#	Register event listener, connecting game state to calling its corresponding function 
	State.travel_requested.connect(travel)
	State.ending_requested.connect(hud.begin_ending)
	hud.new_game_requested.connect(new_game)
	hud.continue_requested.connect(continue_game)
	
#	Starting map
	load_region("village",Vector2(280,500))
	
	State.controls_locked = true

#If there is a save, player can choose to restart or continue game
func new_game() -> void:
	State.reset()
	load_region("village",Vector2(280,500))
	chef.health.restore()
	State.controls_locked = false
	hud.mode = "none"
	State.save_game()

func continue_game() -> void:
	if State.load_game():
		load_region(State.region_id,State.chef_position)
		chef.health.restore()
		State.controls_locked = false
		hud.mode = "none"
	else:
		new_game()

#wrapper function for load_region, to change region/scence
func travel(id: String) -> void:
#	Guard clause
	if State.controls_locked:
		return

	var from: String = State.region_id
#	Same spawn position for every region but village
	var spawn := Vector2(480,688) 
	if id == "village":
#		if returning to village, spawn position will be at the different gates
		var spawn_map ={"forest":Vector2(805,380),
				"mountains":Vector2(480,155),
				"volcano":Vector2(780,610),
				"kitchen":Vector2(480,640)}
		spawn = spawn_map.get(from,Vector2(480,400))
	load_region(id,spawn)
	State.save_game()
	State.notified.emit("Arrived · " + hud.REGION_NAMES[id])
	
#load new current region into region slot and change game state
func load_region(id: String, spawn: Vector2) -> void:
	if is_instance_valid(region):
#		detach current region from regionSlot node
		$RegionSlot.remove_child(region)
		region.queue_free()

#	clear projectiles associated with that region rocks/fireballs
	var projectiles := get_tree().get_nodes_in_group("projectile")
	for projectile in projectiles:
		projectile.queue_free()

	State.region_id = id
	region = load("res://scenes/regions/"+id+".tscn").instantiate()
	$RegionSlot.add_child(region)
	
#	clear player interaction with previous region, reset movements and position 
	chef.position = spawn
	chef.checkpoint = spawn
	chef.height = 0
	chef.vertical_speed = 0
	chef.hovering = false
	chef.launch_wind = null
	chef.get_node("Camera2D").position = Vector2.ZERO
	chef.interaction.target = null
	chef.get_node("Camera2D").reset_smoothing()
	State.chef_position = spawn
	State.has_rock = false
	Sound.region(id)
	State.reveal(spawn)
	
#	Signal game state changed
	State.changed.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		State.save_game()

func _exit_tree() -> void:
	Sound.stop_all()
