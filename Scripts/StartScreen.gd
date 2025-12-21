extends Node2D

@export var alertPerTap : float
var curAlertLevel : float
@export var shaker : Shaker
@export var timeToAlertReset : float
var timeSinceAlertTap : float

@export var textures : Array[Texture]
@export var textureFlying : Texture
@export var hopCurve : Curve
@export var hopEndPos : float

@export var sleepParticle : CPUParticles2D
@export var squash : SquashAnchor
@export var sp : Sprite2D

var wakeUpT : float
@export var wakeUpDuration : float
@export var wakeUpHopStart : float


func _process(delta):
	
	if curAlertLevel >= 1:
		var hopProgOld=MathS.Clamp01(max(wakeUpT-wakeUpHopStart,0)/(wakeUpDuration-wakeUpHopStart))
		wakeUpT+=delta
		var hopProg=MathS.Clamp01(max(wakeUpT-wakeUpHopStart,0)/(wakeUpDuration-wakeUpHopStart))
		if hopProg!=0 and hopProgOld==0:
			squash.TriggerSquash()
			sp.texture=textureFlying
			SoundSpawner.SpawnFromName("Woosh",0.05)
		squash.position.y=lerp(7.0,hopEndPos,hopCurve.sample(hopProg))
		
		if not TransitionManager.IsTransitioning() and wakeUpT>=wakeUpDuration:
			TransitionManager.TransitionScene("res://game.tscn")

	else:
		if Input.is_action_just_pressed("action"):
			curAlertLevel+=alertPerTap
			shaker.Trigger(Shaker.Small)
			var sound : AudioStreamPlayer = SoundSpawner.SpawnFromName("Knock",0)
			sound.pitch_scale+=curAlertLevel*0.4
			timeSinceAlertTap=0
			if curAlertLevel>=1:
				squash.TriggerStretch(SquashAnchor.Medium)
		timeSinceAlertTap+=delta
		if timeSinceAlertTap>=timeToAlertReset:
			curAlertLevel=0
		var texIdx : int = int(curAlertLevel*(textures.size()-1))
		sp.texture=textures[texIdx]
		sleepParticle.emitting=curAlertLevel<=0
