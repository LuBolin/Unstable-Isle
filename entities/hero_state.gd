class_name HeroState
extends Node

@export
var animation_name: String
var gravity: int = ProjectSettings.get_setting("physics/3d/default_gravity")


func enter():
	#parent.animations.play(self.name)
	#parent.state_label.set_text(self.name)
	pass

func exit():
	pass

func process_input(event: InputEvent) -> HeroState:
	return null

func process_physics(delta: float) -> HeroState:
	return null

func process_frame(delta: float) -> HeroState:
	return null
