extends Control

@export var master_bus_name := "Master"
@onready var master_bus_index: int = AudioServer.get_bus_index(master_bus_name)

@onready var settings_button: Button = $SettingsButton
@onready var settings_container: MarginContainer = $SettingsContainer

@onready var background_volume_slider = $SettingsContainer/PanelContainer/HBoxContainer/SettingsVBox/BackgroundVolumeSlider


func _ready():
	settings_button.pressed.connect(toggle_settings_panel)
	
	background_volume_slider.value_changed.connect(modify_background_volume)
	
	settings_container.visibility_changed.connect(sync_settings)
	
	sync_settings()

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
