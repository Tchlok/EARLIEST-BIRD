class_name Cam
extends Camera2D

@export var shaker : Shaker
@export var maxOffset : float
@export var offsetPerKill : float
var timeSinceTrigger : float
@export var timeToReset : float
@export var resetSpeed : float = 1


func trigger():
	position.y=min(position.y+offsetPerKill,+maxOffset)
	timeSinceTrigger=0
	shaker.Trigger(2)
func triggerRock():
	shaker.Trigger(4)


func _process(delta):
	timeSinceTrigger+=delta
	if timeSinceTrigger>=timeToReset:
		position.y=max(0,position.y-delta*resetSpeed)

func _ready():
	Score.cam=self
