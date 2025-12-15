extends Node
signal EV_WormKilled

func _enter_tree():
    EV_WormKilled.connect(_onWormKilled)

var score : int
func _onWormKilled(worm : Worm):
    score+=1
    print(score)