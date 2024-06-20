class_name LobbyRoom
extends Button

signal join_room(port)

const lobby_room = preload("res://lobby/lobby_room.tscn")

@onready var room_id_label = $MarginContainer/VBox/TopRow/RoomID
@onready var player_count_label = $MarginContainer/VBox/TopRow/PlayerCount
@onready var game_status_label = $MarginContainer/VBox/GameStatus

var port: int
var player_count: int
var status: String

static func create(room_info: Dictionary):
	var room = lobby_room.instantiate()
	room.port = room_info['port']
	room.player_count = room_info['player_count']
	room.status = room_info['phase']
	return room

func _ready():
	self.name = str(port)
	room_id_label.set_text(str(port))
	player_count_label.set_text(str(player_count))
	game_status_label.set_text(status)
	self.pressed.connect(_on_room_pressed)

func _on_room_pressed():
	join_room.emit(port)
