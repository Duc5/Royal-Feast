extends Control

signal new_game_requested
signal continue_requested
const REGION_NAMES: Dictionary = {"village":"Bramblewick Village","forest":"Riverwood Forest","mountains":"Whispering Peaks","volcano":"Emberfall Forge","kitchen":"The Royal Kitchen"}
var mode: String = "title":
	set(value):
		if mode != "none" and value == "none":
			State.input_grace_frames = 2
		mode = value
		State.controls_locked = value != "none"
		if is_node_ready():
			show_mode()
var dialogue_title: String = ""
var lines: Array = []
var line_index: int = 0
var toast: String = ""
var toast_timer: float = 0
var ending_after_dialogue: bool = false
var ending_clock: float = 0
var autosave_clock: float = 0
var quests: Array[IngredientData] = []

@onready var overlay: Control = $HUDOverlay
@onready var screens: Dictionary = {
	"title": $TitleScreen,
	"dialogue": $DialogueScreen,
	"map": $MapScreen,
	"pause": $PauseScreen,
	"ending": $EndingScreen
}
@onready var full_heart: AtlasTexture = preload("res://assets/game/ui/royal_feast_theme.tres").get_meta("heart_full")
@onready var empty_heart: AtlasTexture = preload("res://assets/game/ui/royal_feast_theme.tres").get_meta("heart_empty")

# Initialise HUD. Preserve the named callbacks used by the current game state.
func _ready() -> void:
	State.dialogue_requested.connect(open_dialogue)
	State.notified.connect(show_notification)
	for id: String in State.ITEMS:
		quests.append(load("res://data/quests/"+id+".tres"))
	for control: Node in find_children("*", "Button", true, false):
		var button := control as Button
		button.pressed.connect(perform.bind(str(button.get_meta("action"))))
	$DialogueScreen.gui_input.connect(dialogue_input)
	show_mode()

func show_notification(message: String) -> void:
	toast = message
	toast_timer = 5.5
	if is_node_ready():
		refresh_content()

#Return player object
func chef() -> ChefPlayer:
	return get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	# notification timer
	toast_timer = maxf(0,toast_timer-delta)
	# ending timer, how long the ending screen is active
	if mode == "ending":
		ending_clock += delta
		$EndingScreen/Content.visible = ending_clock > 1.5
		$EndingScreen/Content/Return.disabled = ending_clock <= 2
	# autosave timer every 12s
	if mode == "none":
		autosave_clock += delta
		if autosave_clock >= 12:
			autosave_clock = 0
			State.save_game()
	refresh_content()

# there are multiple hud modes,none,dialouge,etc.
func set_mode(value: String) -> void:
	mode = value

func show_mode() -> void:
	for id: String in screens:
		(screens[id] as Control).visible = mode == id
	overlay.visible = mode != "ending"
	Input.set_default_cursor_shape(Input.CURSOR_CROSS if mode == "none" else Input.CURSOR_ARROW)
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
	match mode:
		"title":
			$TitleScreen/Panel/Content/Continue.visible = FileAccess.file_exists(State.SAVE_PATH)
			$TitleScreen/Panel/Content/New.grab_focus()
		"map":
			$MapScreen/Panel/Content/Close.grab_focus()
		"pause":
			$PauseScreen/Panel/Content/Resume.grab_focus()
		"ending":
			$EndingScreen/Content.hide()
			$EndingScreen/Content/Return.disabled = true
			$EndingScreen/Fade.play("reveal")
	refresh_content()

#Change mode to dialogue
func open_dialogue(title: String, content: Array) -> void:
	dialogue_title = title
	lines = content.duplicate()
	line_index = 0
	set_mode("dialogue")

#Triggered when Chef presents all 3 ingredients at kitchend counter
func begin_ending() -> void:
	State.set_flag("presented")
	ending_after_dialogue = true
	open_dialogue("A Feast Fit for a King",State.story["ending"])

#Go to next line in dialogue
func advance() -> void:
	line_index += 1
	if line_index >= lines.size():
		if ending_after_dialogue:
			ending_after_dialogue = false
			State.set_flag("completed")
			State.save_game()
			ending_clock = 0
			set_mode("ending")
		else:
			set_mode("none")
	else:
		refresh_content()

func dialogue_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		advance()

func _input(event: InputEvent) -> void:
	# safeguard held down key press
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("pause"):
		if mode == "none": set_mode("pause")
		elif mode in ["pause","map"]:
			set_mode("none")
		elif mode == "dialogue": 
			advance()
		get_viewport().set_input_as_handled()
	elif mode == "dialogue" and (event.is_action_pressed("interact") or event.is_action_pressed("jump") or event.is_action_pressed("ui_accept")):
		advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("map") and mode in ["none","map"]:
		set_mode("none" if mode == "map" else "map")
		get_viewport().set_input_as_handled()
	elif mode == "ending" and event.is_action_pressed("ui_accept"):
		if ending_clock > 2: set_mode("title")
		get_viewport().set_input_as_handled()

#Match action from player input to change in game
func perform(action: String) -> void:
	match action:
		"new": new_game_requested.emit()
		"continue": continue_requested.emit()
		"resume": set_mode("none")
		"title": State.save_game(); set_mode("title")
		"quit": State.save_game(); get_tree().quit()
		"close": set_mode("none")


func refresh_content() -> void:
	var player: ChefPlayer = chef()
	$HUDOverlay/TopBar/Content/Location/Region.text = REGION_NAMES[State.region_id]
	$HUDOverlay/TopBar/Content/Count.text = "INGREDIENTS   %d / 3" % State.inventory.size()
	$MapScreen/Panel/Content/Title.text = REGION_NAMES[State.region_id].to_upper()
	for i: int in range(3):
		if player != null:
			var heart := $HUDOverlay/Hearts.get_child(i) as TextureRect
			heart.texture = full_heart if i < player.health.current else empty_heart
		if i >= quests.size(): continue
		var q: IngredientData = quests[i]
		var icon := $HUDOverlay/TopBar/Content/Ingredients.get_child(i) as TextureRect
		icon.texture = q.icon
		icon.modulate = Color.WHITE if q.stable_id in State.inventory else Color(0.4,0.47,0.45,1)
		($TitleScreen/Panel/Content/Ingredients.get_child(i) as TextureRect).texture = q.icon
	$HUDOverlay/Stone.visible = mode == "none" and State.has_rock
	var target: Node2D = player.interaction.target if player != null else null
	$HUDOverlay/Prompt.visible = mode == "none" and is_instance_valid(target)
	if is_instance_valid(target):
		$HUDOverlay/Prompt/Text.text = target.prompt()
	# Save confirmation stays above pause, clear of its buttons.
	$Toast.visible = mode in ["none","pause"] and toast_timer > 0
	$Toast.position.y = 6 if mode == "pause" else 65
	$Toast/Text.text = toast
	$DialogueScreen/Panel/Content/Speaker.text = dialogue_title.to_upper()
	$DialogueScreen/Panel/Content/Body.text = str(lines[line_index]) if line_index < lines.size() else ""
	$DialogueScreen/Panel/Content/Footer/Progress.text = "%d / %d" % [line_index+1,lines.size()]
