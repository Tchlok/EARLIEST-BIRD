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
var wormsAlive : int
var worms : Array[Worm]

func reset():
	score=0
	wormsAlive=0
	worms.clear()


func _onWormKilled(worm : Worm,creditPlayer : bool):
	wormsAlive-=1
	worms.erase(worm)
	if creditPlayer:
		score+=1
		display.update(score)
		cam.trigger()
		hitstop.trigger()
func _onWormSpawned(worm : Worm):
	wormsAlive+=1
	worms.append(worm)
