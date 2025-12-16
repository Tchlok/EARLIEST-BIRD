class_name Worm
extends RigidBody2D

func kill():
    if is_queued_for_deletion():
        return
    Score.EV_WormKilled.emit(self)
    queue_free()