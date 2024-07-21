extends Node3D


func _on_animation_player_animation_finished(_anim_name):
	self.queue_free()
