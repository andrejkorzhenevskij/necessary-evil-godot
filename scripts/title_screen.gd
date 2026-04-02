extends Control

const NEXT_SCENE_PATH := "res://scenes/intake/IntakeDesk.tscn"
const FALLBACK_SCENE_PATH := "res://scenes/start/StartPlayTransition.tscn"

@onready var begin_button: Button = %BeginButton
@onready var dossier_panel: Control = $CasefilePanel
@onready var dossier_close_button: Button = $CasefilePanel/Margin/Ledger/HeaderRow/CasefileDismissButton
@onready var dossier_case_ref: Label = $CasefilePanel/Margin/Ledger/CaseRef
@onready var dossier_subject_value: Label = $CasefilePanel/Margin/Ledger/SubjectValue
@onready var dossier_subtitle_value: Label = $CasefilePanel/Margin/Ledger/SubtitleValue
@onready var dossier_profile_value: RichTextLabel = $CasefilePanel/Margin/Ledger/ProfileValue
@onready var dossier_observations_value: RichTextLabel = $CasefilePanel/Margin/Ledger/ObservationsValue

const CARD_NODE_PATHS := {
	"OktaviyCard": NodePath("BoardFrame/BoardMargin/BoardContent/CardsArea/OktaviyCard"),
	"CardA": NodePath("BoardFrame/BoardMargin/BoardContent/CardsArea/CardA"),
	"CardB": NodePath("BoardFrame/BoardMargin/BoardContent/CardsArea/CardB"),
	"CardC": NodePath("BoardFrame/BoardMargin/BoardContent/CardsArea/CardC")
}

const DOSSIER_DATA := {
	"OktaviyCard": {
		"name": "OKTAVIY",
		"subtitle": "Unfiled anomaly",
		"case_ref": "Registry 01-A // Corridor Sweep // Internal",
		"profile": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante venenatis dapibus posuere velit aliquet.",
		"observations": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent commodo cursus magna, vel scelerisque nisl consectetur et.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sed odio dui."
	},
	"CardA": {
		"name": "Leonard",
		"subtitle": "Archive witness",
		"case_ref": "Registry 02-C // Annex Review // Internal",
		"profile": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas faucibus mollis interdum. Curabitur blandit tempus porttitor.",
		"observations": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed posuere consectetur est at lobortis.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean lacinia bibendum nulla sed consectetur."
	},
	"CardB": {
		"name": "Victoria",
		"subtitle": "Dormant liaison",
		"case_ref": "Registry 03-B // Desk Intake // Internal",
		"profile": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras mattis consectetur purus sit amet fermentum. Nullam quis risus eget urna mollis ornare vel eu leo.",
		"observations": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante venenatis dapibus."
	},
	"CardC": {
		"name": "Desmond",
		"subtitle": "Flagged observer",
		"case_ref": "Registry 04-D // South Wing // Internal",
		"profile": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam porta sem malesuada magna mollis euismod. Donec ullamcorper nulla non metus auctor fringilla.",
		"observations": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi leo risus, porta ac consectetur ac, vestibulum at eros.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum id ligula porta felis euismod semper."
	}
}

var active_dossier_id := ""

func _ready() -> void:
	begin_button.grab_focus()
	dossier_panel.hide()
	dossier_close_button.pressed.connect(_close_dossier)

	for card_name: String in DOSSIER_DATA.keys():
		var card := get_node(CARD_NODE_PATHS[card_name]) as Control
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.gui_input.connect(_on_card_gui_input.bind(card_name))

func _on_begin_button_pressed() -> void:
	var target_scene_path := NEXT_SCENE_PATH if ResourceLoader.exists(NEXT_SCENE_PATH) else FALLBACK_SCENE_PATH
	get_tree().change_scene_to_file(target_scene_path)

func _on_card_gui_input(event: InputEvent, dossier_id: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_open_dossier(dossier_id)

func _open_dossier(dossier_id: String) -> void:
	var dossier: Dictionary = DOSSIER_DATA[dossier_id]
	active_dossier_id = dossier_id
	dossier_case_ref.text = dossier["case_ref"]
	dossier_subject_value.text = dossier["name"]
	dossier_subtitle_value.text = dossier["subtitle"]
	dossier_profile_value.text = dossier["profile"]
	dossier_observations_value.text = dossier["observations"]
	dossier_panel.show()

func _close_dossier() -> void:
	active_dossier_id = ""
	dossier_panel.hide()
