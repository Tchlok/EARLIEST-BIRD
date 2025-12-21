extends Node2D

@export var label : RichTextLabel
@export var squash : SquashAnchor

@export var countingDuration : float
@export var wormPacked : PackedScene
@export var wormColors : Array[Color]
@export var wormTextures : Array[Texture]
@export var timeToStart : float = 1
@export var wormSpawnRadius : float

var curHoldDuration : float
var holding : bool
@export var holdDuration : float
var holdP : float

func _ready():
	for i in range(Score.score):
		var cur : GameOverWorm = wormPacked.instantiate()
		var activateCd : float = timeToStart + (float(i)/float(Score.score))*countingDuration
		cur.setup(activateCd,wormColors.pick_random(),wormTextures.pick_random(),i)
		cur.position=Vector2.ZERO+MathS.RandDir2()*(float(i)/float(Score.score))*wormSpawnRadius
		call_deferred("add_child",cur)


var t : float

func _process(delta: float):
	if max(t-timeToStart,0) < countingDuration:
		t+=delta
		squash.rotation_degrees=sin(t*6)*2
		var countingP = MathS.Clamp01(max(t-timeToStart,0)/countingDuration)
		label.text="[center]YOU CAUGHT " + str(int(countingP*Score.score)) + " WORMS!"
		if t>=timeToStart+countingDuration:
			squash.TriggerSquash(SquashAnchor.Medium)
			squash.rotation_degrees=0
	else:
		if Input.is_action_just_pressed("action"):
			holding=true
		if Input.is_action_just_released("action"):
			holding=false
			if not TransitionManager.IsTransitioning() and curHoldDuration<=0.4:
				TransitionManager.TransitionScene("res://game.tscn")

		if holding:
			curHoldDuration+=delta
			if curHoldDuration>=holdDuration and not TransitionManager.IsTransitioning():
				TransitionManager.TransitionScene("res://Scenes/startScreen.tscn")
		else:
			curHoldDuration=false
		holdP=MathS.Clamp01(curHoldDuration/holdDuration)
