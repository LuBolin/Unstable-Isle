class_name LobbyGui
extends Control

signal join_room(port)

@onready var lobby: Lobby = $".."

@onready var rooms_grid: GridContainer = $MainAndSideHBox/MainVBox/Main/RoomsGrid
@onready var quick_join_button: Button = $MainAndSideHBox/Controls/QuickJoinButton
@onready var create_room_button: Button = $MainAndSideHBox/Controls/CreateRoomButton

func _ready():
	create_room_button.pressed.connect(_on_create_room)
	quick_join_button.pressed.connect(_on_quick_join)

func _on_quick_join():
	lobby.network.request_join_room.rpc_id(1, null)

func _on_create_room():
	lobby.network.request_create_room.rpc_id(1)

func refresh_lobby_rooms(rooms):
	for c in rooms_grid.get_children():
		c.queue_free()
	for port in rooms:
		# var other_var = rooms[port]['other_var']
		var room: LobbyRoom = LobbyRoom.create(port)
		rooms_grid.add_child(room)
		room.join_room.connect(grid_room_pressed)

func grid_room_pressed(port):
	if lobby.network.multiplayer.is_server():
		return
	join_room.emit(port)
