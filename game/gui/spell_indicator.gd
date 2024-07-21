class_name SpellIndicator
extends Control

const MARGIN = 8
const MIN_SIZE = 64

const CASTPOINT_BORDER_COLOR = Color.YELLOW
const DEFAULT_BORDER_COLOR = Color.WEB_GREEN
const COOLDOWN_BORDER_COLOR = Color.BLACK

@onready var spell_icon = $Aligner/SpellIndicator/SpellIcon
@onready var cooldown_overlay = $Aligner/SpellIndicator/CooldownOverlay
@onready var cooldown_label = $Aligner/SpellIndicator/CooldownLabel
@onready var status_border = $Aligner/SpellIndicator/StatusBorder

@onready var spell_desc_label = $Aligner/SpellDescription/SpellDescLabel

@onready var hover_detect: Panel = $HoverDetect

var spell_desc: String
var my_spell: SpellList.Spell

func _ready():
	hover_detect.mouse_entered.connect(func(): spell_desc_label.show())
	hover_detect.mouse_exited.connect(func(): spell_desc_label.hide())

func reset():
	spell_icon.set_texture(null)
	spell_desc = ""
	cooldown_label.set_text("")

func set_spell(hah: HeroAssetHolder, spell: String):
	var spell_list = hah.spell_list
	var txtr: Texture2D
	var desc: String
	match spell:
		'atk':
			txtr = hah.atk_icon
			desc = hah.atk_description
			my_spell = spell_list.attack
		'fst':
			txtr = hah.fst_icon
			desc = hah.fst_description
			my_spell = spell_list.first_spell
		'scd':
			txtr = hah.scd_icon
			desc = hah.scd_description
			my_spell = spell_list.second_spell
		'ult':
			txtr = hah.ult_icon
			desc = hah.ult_description
			my_spell = spell_list.ulti_spell
	spell_icon.set_texture(txtr)
	spell_desc = desc
	spell_desc_label.set_text(spell_desc)

func process():
	pass

func render(full_cd: float, current_cd: float, spell: SpellList.Spell):
	var icon_shader = spell_icon.get_material()
	icon_shader.set_shader_parameter("cooldown", full_cd)
	icon_shader.set_shader_parameter("current_cooldown", current_cd)

	var overlay_shader = cooldown_overlay.get_material()
	overlay_shader.set_shader_parameter("cooldown", full_cd)
	overlay_shader.set_shader_parameter("current_cooldown", current_cd)

	var cd_to_show = current_cd if current_cd > 0.0 else full_cd
	cd_to_show = "%.2f" % [cd_to_show]
	cooldown_label.set_text(cd_to_show)
	
	if current_cd > 0:
		status_border.border_color = COOLDOWN_BORDER_COLOR
	else:
		if spell == my_spell:
			# casting
			status_border.border_color = CASTPOINT_BORDER_COLOR
		else:
			status_border.border_color = DEFAULT_BORDER_COLOR
