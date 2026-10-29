extends Node2D
## Visual attachments only. The player controller owns movement and combat timing.
@onready var actor: ChefPlayer = get_parent() as ChefPlayer
@onready var spatula: Node2D = $SpatulaPivot
@onready var slash: Sprite2D = $SpatulaPivot/Slash

func _process(_delta: float) -> void:
 var bob: float = 0.0 if actor.velocity.length() < 5 else roundf(sin(actor.anim_clock*15.0))
 spatula.position = Vector2(0,-6-actor.height+bob)
 var angle: float = actor.aim.angle()
 if actor.attack_time > 0:
  angle += (0.13-actor.attack_time)*10.0-0.6
 spatula.rotation = angle
 slash.visible = actor.attack_time > 0
 slash.frame = clampi(int((1.0-actor.attack_time/0.18)*6),0,5)
 $DodgeRing.visible = actor.dodge_time > 0
 $DodgeRing.position.y = -actor.height+bob
 $HeldRock.visible = State.has_rock
 $HeldRock.position.y = -36-actor.height
 # Put the tool behind the body when aiming away from the camera.
 spatula.z_index = -1 if actor.aim.y < -0.25 else 1
