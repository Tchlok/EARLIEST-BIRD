class_name Hitstop
extends Node2D

func _ready():
    Score.hitstop=self
    
func trigger():
    get_tree().create_timer(0.02,true,false).timeout.connect(onTimerExpired)
    get_tree().paused=true
func onTimerExpired():
    get_tree().paused=false
