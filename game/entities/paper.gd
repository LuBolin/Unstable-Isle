@tool
extends Node3D

func set_texture(texture: Texture):
	$Render/Sprite.set_texture(texture)
	pass
