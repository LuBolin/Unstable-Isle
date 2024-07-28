extends Control

var gui_controller: GameroomGuiController
var game_room: GameRoom

@export var master_bus_name := "Master"
@onready var master_bus_index: int = AudioServer.get_bus_index(master_bus_name)

@onready var settings_btn: Button = $SettingsButton
@onready var settings_container: MarginContainer = $SettingsContainer

@onready var background_volume_slider = $SettingsContainer/PanelContainer/HBoxContainer/SettingsVBox/BackgroundVolumeSlider

enum SettingsModes {LOBBY, GAME_ROOM}
@export var mode: SettingsModes = SettingsModes.LOBBY

@onready var disconnect_btn = $SettingsContainer/PanelContainer/HBoxContainer/SettingsVBox/Disconnect
@onready var close_room_btn = $SettingsContainer/PanelContainer/HBoxContainer/SettingsVBox/CloseRoom

func _ready():
	settings_btn.pressed.connect(toggle_settings_panel)
	
	background_volume_slider.value_changed.connect(modify_background_volume)
	
	settings_container.visibility_changed.connect(sync_settings)
	
	settings_btn.visibility_changed.connect(
		func(): settings_container.visible = false)
	
	sync_settings()
	
	disconnect_btn.pressed.connect(_on_disconnect)
	close_room_btn.pressed.connect(_on_close_room)
	
	if mode == SettingsModes.GAME_ROOM:
		disconnect_btn.set_visible(true)
		close_room_btn.set_visible(true)
		
		gui_controller = get_parent()
		game_room = gui_controller.game_room

func _input(event):
	if event is InputEventKey \
		and event.keycode == KEY_ESCAPE \
		and event.is_pressed():
		toggle_settings_panel()

func toggle_settings_panel():
	settings_container.visible = \
		not settings_container.visible

func sync_settings():
	background_volume_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(master_bus_index)
	)

func modify_background_volume(value: float):
	AudioServer.set_bus_volume_db(
		master_bus_index,
		linear_to_db(value)
	)

func _on_disconnect():
	if mode != SettingsModes.GAME_ROOM:
		return
	game_room.disconnect_self()

func _on_close_room():
	if mode != SettingsModes.GAME_ROOM:
		return
	game_room.network.request_close_room.rpc_id(1)

func update_player_list():
	if mode != SettingsModes.GAME_ROOM:
		return
	var owner_id = game_room.owner_id
	var is_owner = game_room.multiplayer.get_unique_id() == owner_id
	close_room_btn.set_visible(is_owner)
