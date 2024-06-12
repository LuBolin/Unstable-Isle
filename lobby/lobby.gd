class_name Lobby
extends Control

@onready var network: LobbyNetwork = $LobbyNetwork
@onready var rooms_container = $"../Rooms"
@onready var controls: LobbyGui = $LobbyGUI

const LOBBY_SERVER_ADDRESS = '127.0.0.1'
const LOBBY_SERVER_PORT = 12000
const GAME_PORT_RANGE = 10
const MAX_CONNECTIONS = 100
var game_ports = range(
	LOBBY_SERVER_PORT + 1, 
	LOBBY_SERVER_PORT + 1 + GAME_PORT_RANGE)

var is_lobby_host: bool = false
var mutiplayer: SceneMultiplayer = SceneMultiplayer.new()

var players = {} # remote id, username
var server_instances = {} # port, reference to object

func _ready():
	network.refresh_lobby_rooms.connect(controls.refresh_lobby_rooms)
	controls.join_room.connect(func(port): network.request_join_room.rpc_id(1, port))

func _enter_tree():
	get_tree().set_multiplayer(mutiplayer, self.get_path())
	is_lobby_host = launch_as_lobby_server()
	if is_lobby_host:
		$RefreshRoomsTimer.timeout.connect(update_clients_about_rooms)
		$LobbyGUI/IsHostLabel.set_visible(true)
	if not is_lobby_host:
		launch_as_lobby_client()

func launch_as_lobby_server():
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	# There will likely be an error here
	var create_lobby_status = peer.create_server(
		LOBBY_SERVER_PORT, MAX_CONNECTIONS)
	# for local testing only, where client and server are on the same machine
	# in deployment, we check if external ip == LOBBY_SERVER_PORT
	# if yes this is host, if not this is client

	var success = create_lobby_status == Error.OK
	if success:
		mutiplayer.multiplayer_peer = peer
	return success

func launch_as_lobby_client():
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(LOBBY_SERVER_ADDRESS, LOBBY_SERVER_PORT)
	mutiplayer.multiplayer_peer = peer


var game_room = preload("res://game/game_room.tscn")
func create_room():
	var new_port = null
	for port in game_ports:
		if not port in server_instances:
			# lambda here because this does not need to
			# be exposed or used anywhere else
			var host_new_room = func(port: int):
				var room: GameRoom = game_room.instantiate()
				rooms_container.add_child(room)
				room.create_room(port)
				server_instances[port] = room
			host_new_room.call(port)
			new_port = port
			break
	if new_port:
		print("Room created on ", new_port)
		update_clients_about_rooms()
		return new_port

func join_room(ip, port):
	var room: GameRoom = game_room.instantiate()
	rooms_container.add_child(room)
	room.join_room(ip, port)
	# only the game, which is node3d, will still be visible
	self.set_visible(false)
	# how should client handle server instance?
	# maybe just a variable, instead of the host's 
	# method of a dictionary?
	# server_instances[port] = room

func request_join_room(client_id: int, port: int):
	print("%s request to join on port  %s" % [client_id, port])
	if not port:
		# if quick_join, find room with space
		# for now, just get first room, ignoring connection limit
		var instances = server_instances.keys()
		if instances:
			port = instances[0]
		else:
			return null
	var result = {}
	result['ip'] = LOBBY_SERVER_ADDRESS
	result['port'] = port
	return result


# Lobby Host Only
func update_clients_about_rooms():
	var s = {}
	for server: GameRoom in rooms_container.get_children():
		var data = server.serialize()
		var port = data['port']
		s[port] = data
	network.refresh_room_list.rpc(s)
