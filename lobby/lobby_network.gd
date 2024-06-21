class_name LobbyNetwork
extends Node

signal refresh_lobby_rooms(rooms)

@onready var lobby: Lobby = $".."

func _ready():
	lobby.mutiplayer.peer_connected.connect(_on_client_connected)
	lobby.mutiplayer.peer_disconnected.connect(_on_client_disconnected)
	lobby.mutiplayer.connected_to_server.connect(_on_connected_success)
	lobby.mutiplayer.connection_failed.connect(_on_connected_fail)
	lobby.mutiplayer.server_disconnected.connect(_on_server_disconnected)
	print("MP: ", lobby.multiplayer.get_unique_id())

@rpc("any_peer", "call_remote", "reliable")
func request_create_room():
	var client_id = lobby.multiplayer.get_remote_sender_id()
	var new_port = lobby.create_room()
	if new_port:
		request_join_room(new_port, client_id)
		# client_join_room.rpc_id(client_id, new_port)

#@rpc("any_peer", "call_remote", "reliable")
#func request_quick_join(): pass
# quick_join = join_room(null)
@rpc("any_peer", "call_remote", "reliable")
func request_join_room(port, client_id = null):
	if not client_id:
		client_id = lobby.multiplayer.get_remote_sender_id()
	if client_id == 1:
		return
	var target_room = lobby.request_join_room(client_id, port)
	print(client_id, " request to join room on ", port, ". Target room is ", target_room)
	if not target_room:
		return
	var room_ip = target_room['ip']
	var room_port = target_room['port']
	client_join_room.rpc_id(client_id, room_ip, room_port)

@rpc("authority", 'call_remote', 'reliable')
func client_join_room(ip, port):
	lobby.join_room(ip, port)

@rpc("authority", "call_local", "reliable")
func refresh_room_list(room):
	refresh_lobby_rooms.emit(room)


func _on_client_connected(id):
	print(str(id) + " connected to lobby")

func _on_client_disconnected(id):
	print(str(id) + " disconnect")

func _on_connected_success():
	print("connect success")

func _on_connected_fail():
	print("connect fail")

func _on_server_disconnected():
	print("disconnect")
