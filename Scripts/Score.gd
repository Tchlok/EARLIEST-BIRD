extends Node
signal EV_WormKilled
signal EV_WormSpawned

func _enter_tree():
	EV_WormKilled.connect(_onWormKilled)
	EV_WormSpawned.connect(_onWormSpawned)


var display : ScoreDisplay
var hitstop : Hitstop
var cam : Cam

var score : int
var player : Player
var wormsAlive : int
var worms : Array[Worm]

var pitchStacks : int
const  maxPitchStacks : int = 5
const pitchPerStack : float = 0.2

func reset():
	score=0
	wormsAlive=0
	worms.clear()

func _physics_process(delta: float):
	if not player == null and is_instance_valid(player):
		if player.curState!=Player.PlayerState.Pecking:
			pitchStacks=0

func _onWormKilled(worm : Worm,creditPlayer : bool):
	wormsAlive-=1
	worms.erase(worm)
	if creditPlayer:
		score+=1
		display.update(score)
		cam.trigger()
		hitstop.trigger()
		var sound : AudioStreamPlayer = SoundSpawner.SpawnFromName("Worm",0)
		sound.pitch_scale+=pitchStacks*pitchPerStack
		
		pitchStacks=min(maxPitchStacks,pitchStacks+1)


func _onWormSpawned(worm : Worm):
	wormsAlive+=1
	worms.append(worm)
