extends Control

@onready var grid_container = $VBoxContainer/GridContainer

var choice = null
func _ready():
	for b in grid_container.get_children():
		if b is Button:
			b.pressed.connect(_on_hero_button_clicked.bind(b))
	$VBoxContainer/HBoxContainer/Random.pressed.connect(_on_random_clicked)
	$VBoxContainer/HBoxContainer/Confirm.pressed.connect(_on_confirm_clicked)
	
func _on_hero_button_clicked(button: Button):
	for b in grid_container.get_children():
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
	Network.pick_hero.rpc_id(1, choice)
