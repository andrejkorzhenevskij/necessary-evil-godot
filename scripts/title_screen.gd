extends Control

const NEXT_SCENE_PATH := "res://scenes/gameplay/GameplayScreen.tscn"
const FALLBACK_SCENE_PATH := "res://scenes/start/StartPlayTransition.tscn"
const FADE_DURATION := 1.5

@onready var begin_button: Button = %BeginButton
@onready var debug_f2_button: Button = %DebugF2Button
@onready var debug_f3_burn_button: Button = %DebugF3BurnButton
@onready var debug_f3_oblivion_button: Button = %DebugF3OblivionButton
@onready var debug_f3_clean_button: Button = %DebugF3CleanButton
@onready var dossier_backdrop_dim: ColorRect = $DossierBackdropDim
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var dossier_panel: Control = $CasefilePanel
@onready var dossier_close_button: Button = $CasefilePanel/Margin/Ledger/HeaderRow/CasefileDismissButton
@onready var dossier_case_ref: Label = $CasefilePanel/Margin/Ledger/CaseRef
@onready var dossier_subject_value: Label = $CasefilePanel/Margin/Ledger/SubjectValue
@onready var dossier_subtitle_value: Label = $CasefilePanel/Margin/Ledger/SubtitleValue
@onready var dossier_known_facts_value: RichTextLabel = $CasefilePanel/Margin/Ledger/KnownFactsValue
@onready var dossier_interpretation_value: RichTextLabel = $CasefilePanel/Margin/Ledger/InterpretationValue
@onready var dossier_assessment_stamp: Label = $CasefilePanel/Margin/Ledger/AssessmentStamp

const CARD_NODE_PATHS := {
	"OktaviyCard": NodePath("BoardFrame/BoardMargin/BoardContent/CardsArea/OktaviyCard"),
	"CardA": NodePath("BoardFrame/BoardMargin/BoardContent/CardsArea/CardA"),
	"CardB": NodePath("BoardFrame/BoardMargin/BoardContent/CardsArea/CardB"),
	"CardC": NodePath("BoardFrame/BoardMargin/BoardContent/CardsArea/CardC")
}

const DOSSIER_DATA := {
	"OktaviyCard": {
		"subject": "OKTAVIY",
		"subtitle": "Unfiled anomaly",
		"registry_line": "Registry 01-A // Corridor Sweep // Internal",
		"known_facts": [
			"Observed outside assigned corridor boundaries after curfew.",
			"Record remains unattached to a stable departmental chain.",
			"Witness memory of first contact shifts between statements."
		],
		"interpretation": "Oktaviy reads as an unresolved anomaly rather than a standard intake error. The file suggests persistence without institutional anchoring.",
		"assessment": "UNFILED ANOMALY"
	},
	"CardA": {
		"subject": "Leonard",
		"subtitle": "Archive witness",
		"registry_line": "Registry 02-C // Annex Review // Internal",
		"known_facts": [
			"Present for multiple archive events but absent from official staffing ledgers.",
			"Cross-references place him near sealed material after lock cycle.",
			"Independent accounts describe him as calm, attentive, and difficult to place."
		],
		"interpretation": "Leonard appears less like an intruder than a tolerated witness whose access is never formally acknowledged.",
		"assessment": "ARCHIVE WITNESS"
	},
	"CardB": {
		"subject": "Victoria",
		"subtitle": "Dormant liaison",
		"registry_line": "Registry 03-B // Desk Intake // Internal",
		"known_facts": [
			"Communications history shows long inactive gaps followed by precise contact windows.",
			"Desk routing marks her file as informational rather than operational.",
			"Old liaison credentials remain valid in at least one internal subsystem."
		],
		"interpretation": "Victoria presents as a dormant connector: not currently active, but still capable of re-entering the network with minimal friction.",
		"assessment": "DORMANT LIAISON"
	},
	"CardC": {
		"subject": "Desmond",
		"subtitle": "Flagged observer",
		"registry_line": "Registry 04-D // South Wing // Internal",
		"known_facts": [
			"Repeatedly logged near review sites without initiating direct contact.",
			"Flags were raised by pattern analysis rather than a single incident.",
			"Behavior indicates deliberate observation with minimal physical trace."
		],
		"interpretation": "Desmond is best read as a patient observer whose threat profile comes from repetition and positioning rather than overt action.",
		"assessment": "FLAGGED OBSERVER"
	}
}

var active_dossier_id := ""
var is_transitioning := false

func _ready() -> void:
	if has_node("/root/TitleMusic"):
		TitleMusic.ensure_title_theme()
	begin_button.grab_focus()
	debug_f2_button.show()
	debug_f3_burn_button.show()
	debug_f3_oblivion_button.show()
	debug_f3_clean_button.show()
	_configure_dossier_overlay()
	dossier_backdrop_dim.hide()
	fade_overlay.show()
	fade_overlay.color = Color(0, 0, 0, 1)
	dossier_panel.hide()
	dossier_close_button.pressed.connect(_close_dossier)

	for card_name: String in DOSSIER_DATA.keys():
		var card := get_node(CARD_NODE_PATHS[card_name]) as Control
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.gui_input.connect(_on_card_gui_input.bind(card_name))

	_fade_in_from_black()

func _on_begin_button_pressed() -> void:
	if is_transitioning:
		return

	is_transitioning = true
	_set_debug_buttons_disabled(true)
	begin_button.release_focus()
	_set_board_input_enabled(false)
	GameState.reset_run()
	_transition_to_target_scene()


func _on_debug_f2_button_pressed() -> void:
	if is_transitioning:
		return

	is_transitioning = true
	_set_debug_buttons_disabled(true)
	debug_f2_button.release_focus()
	_set_board_input_enabled(false)
	GameState.apply_debug_preset_f2_desmond()
	_transition_to_target_scene()


func _on_debug_f3_burn_button_pressed() -> void:
	if is_transitioning:
		return

	is_transitioning = true
	_set_debug_buttons_disabled(true)
	debug_f3_burn_button.release_focus()
	_set_board_input_enabled(false)
	GameState.apply_debug_preset_f3_burn()
	_transition_to_target_scene()


func _on_debug_f3_oblivion_button_pressed() -> void:
	if is_transitioning:
		return

	is_transitioning = true
	_set_debug_buttons_disabled(true)
	debug_f3_oblivion_button.release_focus()
	_set_board_input_enabled(false)
	GameState.apply_debug_preset_f3_oblivion()
	_transition_to_target_scene()


func _on_debug_f3_clean_button_pressed() -> void:
	if is_transitioning:
		return

	is_transitioning = true
	_set_debug_buttons_disabled(true)
	debug_f3_clean_button.release_focus()
	_set_board_input_enabled(false)
	GameState.apply_debug_preset_f3_clean()
	_transition_to_target_scene()


func _transition_to_target_scene() -> void:
	var target_scene_path := NEXT_SCENE_PATH if ResourceLoader.exists(NEXT_SCENE_PATH) else FALLBACK_SCENE_PATH
	fade_overlay.show()
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), FADE_DURATION)
	await tween.finished
	get_tree().change_scene_to_file(target_scene_path)


func _fade_in_from_black() -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), FADE_DURATION)
	await tween.finished
	fade_overlay.hide()

func _on_card_gui_input(event: InputEvent, dossier_id: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_open_dossier(dossier_id)

func _open_dossier(dossier_id: String) -> void:
	if not DOSSIER_DATA.has(dossier_id):
		return

	if dossier_panel.visible and active_dossier_id == dossier_id:
		return

	var dossier: Dictionary = DOSSIER_DATA[dossier_id]
	active_dossier_id = dossier_id
	dossier_case_ref.text = dossier["registry_line"]
	dossier_subject_value.text = dossier["subject"]
	dossier_subtitle_value.text = dossier["subtitle"]
	dossier_known_facts_value.text = _format_known_facts(dossier["known_facts"])
	dossier_interpretation_value.text = dossier["interpretation"]
	dossier_assessment_stamp.text = dossier["assessment"]

	if not dossier_backdrop_dim.visible:
		dossier_backdrop_dim.show()
	if not dossier_panel.visible:
		dossier_panel.show()

func _close_dossier() -> void:
	active_dossier_id = ""
	dossier_backdrop_dim.hide()
	dossier_panel.hide()


func _format_known_facts(facts: Array) -> String:
	var entries: PackedStringArray = []
	for fact_variant in facts:
		var fact := str(fact_variant).strip_edges()
		if fact.is_empty():
			continue
		entries.append("• %s" % fact)

	return "\n".join(entries)


func _configure_dossier_overlay() -> void:
	dossier_backdrop_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_overlay_pass_through(dossier_panel)
	dossier_close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP


func _set_overlay_pass_through(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in control.get_children():
		if child is Control:
			_set_overlay_pass_through(child as Control)


func _set_board_input_enabled(enabled: bool) -> void:
	for card_name: String in DOSSIER_DATA.keys():
		var card := get_node(CARD_NODE_PATHS[card_name]) as Control
		card.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	begin_button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	debug_f2_button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	debug_f3_burn_button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	debug_f3_oblivion_button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	debug_f3_clean_button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE


func _set_debug_buttons_disabled(disabled: bool) -> void:
	begin_button.disabled = disabled
	debug_f2_button.disabled = disabled
	debug_f3_burn_button.disabled = disabled
	debug_f3_oblivion_button.disabled = disabled
	debug_f3_clean_button.disabled = disabled
