extends Control

@onready var grid_container = $VBoxContainer/GridContainer
@onready var random_button = $VBoxContainer/HBoxContainer/RandomButton
@onready var confirm_button = $VBoxContainer/HBoxContainer/ConfirmButton

@onready var gui_controller: GameroomGuiController = $".."
var game_room: GameRoom

var choice = null
func _ready():
	game_room = gui_controller.game_room
	for b in grid_container.get_children():
		if b is Button:
			b.pressed.connect(_on_hero_button_clicked.bind(b))
	random_button.pressed.connect(_on_random_clicked)
	confirm_button.pressed.connect(_on_confirm_clicked)
	game_room.round.prep_started.connect(_prep_started)
	
func _on_hero_button_clicked(button: Button):
	for b in grid_container.get_children():
		print(b.modulate, " ", b.self_modulate)
		if b == button:
			b.set_modulate(Color.GREEN)
		else:
			b.set_modulate(Color.BLACK)
	choice = button.get_text()

func _on_random_clicked():
	var rng = RandomNumberGenerator.new()
	var range = len(grid_container.get_children())
	# inclusive
	var rdm = rng.randi_range(0, range-1)
	grid_container.get_child(rdm).pressed.emit()

func _on_confirm_clicked():
	if not choice:
		return
	game_room.network.pick_hero.rpc_id(1, choice)

func _prep_started(_seed):
	choice = null
	for b in grid_container.get_children():
		if b is Button:
			# default
			b.set_modulate(Color.WHITE)
