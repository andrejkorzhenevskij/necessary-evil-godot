extends Control

const GAMEPLAY_SCENE_PATH := "res://scenes/gameplay/GameplayScreen.tscn"

@onready var overline: Label = $Margin/CenterFrame/FrameMargin/RootColumn/HeaderBlock/Overline
@onready var title_label: Label = $Margin/CenterFrame/FrameMargin/RootColumn/HeaderBlock/Title
@onready var subtitle_label: Label = $Margin/CenterFrame/FrameMargin/RootColumn/HeaderBlock/Subtitle
@onready var footer_note: Label = $Margin/CenterFrame/FrameMargin/RootColumn/FooterBlock/FooterNote
@onready var resume_button: Button = $Margin/CenterFrame/FrameMargin/RootColumn/FooterBlock/ResumeButton
@onready var explanation_bubble_tail: ColorRect = $ExplanationBubbleTail
@onready var explanation_bubble: PanelContainer = $ExplanationBubble
@onready var explanation_bubble_label: Label = $ExplanationBubble/BubbleMargin/ExplanationBubbleLabel

@onready var slot_a_headshot: Label = $Margin/CenterFrame/FrameMargin/RootColumn/SnapshotStrip/PortraitMargin/PortraitRow/DossierSlotA/Margin/Stack/Headshot/HeadshotLabel
@onready var slot_a_title: Label = $Margin/CenterFrame/FrameMargin/RootColumn/SnapshotStrip/PortraitMargin/PortraitRow/DossierSlotA/Margin/Stack/Title
@onready var slot_a_cue: Label = $Margin/CenterFrame/FrameMargin/RootColumn/SnapshotStrip/PortraitMargin/PortraitRow/DossierSlotA/Margin/Stack/Cue
@onready var slot_b_headshot: Label = $Margin/CenterFrame/FrameMargin/RootColumn/SnapshotStrip/PortraitMargin/PortraitRow/DossierSlotB/Margin/Stack/Headshot/HeadshotLabel
@onready var slot_b_title: Label = $Margin/CenterFrame/FrameMargin/RootColumn/SnapshotStrip/PortraitMargin/PortraitRow/DossierSlotB/Margin/Stack/Title
@onready var slot_b_cue: Label = $Margin/CenterFrame/FrameMargin/RootColumn/SnapshotStrip/PortraitMargin/PortraitRow/DossierSlotB/Margin/Stack/Cue
@onready var slot_c_headshot: Label = $Margin/CenterFrame/FrameMargin/RootColumn/SnapshotStrip/PortraitMargin/PortraitRow/DossierSlotC/Margin/Stack/Headshot/HeadshotLabel
@onready var slot_c_title: Label = $Margin/CenterFrame/FrameMargin/RootColumn/SnapshotStrip/PortraitMargin/PortraitRow/DossierSlotC/Margin/Stack/Title
@onready var slot_c_cue: Label = $Margin/CenterFrame/FrameMargin/RootColumn/SnapshotStrip/PortraitMargin/PortraitRow/DossierSlotC/Margin/Stack/Cue


func _ready() -> void:
	resume_button.pressed.connect(_resume_playback)
	resume_button.grab_focus()
	_apply_snapshot_copy()


func _apply_snapshot_copy() -> void:
	var snapshot_context := _get_snapshot_context()
	var source_phase := str(snapshot_context.get("source_phase", "")).strip_edges()
	var next_phase := _resolve_next_phase()
	var phase_label := source_phase if not source_phase.is_empty() else next_phase

	overline.text = "SNAPSHOT MODE // %s" % phase_label
	title_label.text = "Carrier Snapshot"
	subtitle_label.text = "Expanded lower-strip readout after %s. Resume returns to the current authored continuation." % phase_label
	footer_note.text = "This view reuses the gameplay portrait-strip grammar as a focused pause state."
	_apply_explanation_bubble(bool(snapshot_context.get("show_explanatory_overlay", false)))

	if not has_node("/root/GameState"):
		slot_a_headshot.text = "FILM"
		slot_a_title.text = "Depth (unknown)"
		slot_a_cue.text = "Oblivion (unknown)\nPressure (unknown)"
		slot_b_headshot.text = "FLOW"
		slot_b_title.text = "Snapshot after %s" % phase_label
		slot_b_cue.text = "Next %s\nCompleted none" % next_phase
		slot_c_headshot.text = "CAST"
		slot_c_title.text = "Integrity (unknown)"
		slot_c_cue.text = "Trauma (unknown)"
		return

	slot_a_headshot.text = "FILM"
	slot_a_title.text = "Depth %s" % _display_metric(_game_state_value("film_depth"))
	slot_a_cue.text = "Oblivion %s\nPressure %s" % [
		_display_metric_with_risk(_game_state_value("film_oblivion")),
		_display_metric_with_risk(_game_state_value("film_pressure")),
	]

	slot_b_headshot.text = "FLOW"
	slot_b_title.text = "Snapshot after %s" % phase_label
	slot_b_cue.text = "Next %s\nCompleted %s" % [
		next_phase,
		_build_completed_summary(),
	]

	slot_c_headshot.text = "CAST"
	slot_c_title.text = "Integrity %s" % _display_metric(_aggregate_metric([
		"desmond_integrity",
		"victoria_integrity",
		"leonard_integrity",
	]))
	slot_c_cue.text = "Trauma %s" % _display_metric(_aggregate_metric([
		"desmond_trauma",
		"victoria_trauma",
		"leonard_trauma",
	]))


func _apply_explanation_bubble(show_overlay: bool) -> void:
	explanation_bubble.visible = show_overlay
	explanation_bubble_tail.visible = show_overlay
	explanation_bubble_label.text = "Diagnostic layer enabled.\nValues influence decisions and outcome."


func _get_snapshot_context() -> Dictionary:
	if not has_node("/root/GameState"):
		return {
			"source_phase": "",
			"show_explanatory_overlay": false,
		}
	return GameState.get_snapshot_context()


func _resolve_next_phase() -> String:
	if not has_node("/root/GameState"):
		return "(unknown)"
	return _display_metric(_game_state_value("current_phase"))


func _game_state_value(field_name: String) -> Variant:
	if not has_node("/root/GameState"):
		return null
	return GameState.get(field_name)


func _aggregate_metric(field_names: Array[String]) -> Variant:
	var total := 0
	for field_name: String in field_names:
		var value: Variant = _game_state_value(field_name)
		if value == null:
			return null
		total += int(value)
	return total


func _display_metric(value: Variant) -> String:
	if value == null:
		return "(unknown)"
	return str(value)


func _display_metric_with_risk(value: Variant) -> String:
	if value == null:
		return "(unknown)"
	var metric_value := int(value)
	return "%d [%s]" % [metric_value, _risk_tag(metric_value)]


func _risk_tag(value: int) -> String:
	if value <= 2:
		return "LOW"
	if value <= 5:
		return "MED"
	return "HIGH"


func _build_completed_summary() -> String:
	if not has_node("/root/GameState") or GameState.completed_phases.is_empty():
		return "none"
	return ", ".join(GameState.completed_phases)


func _resume_playback() -> void:
	if has_node("/root/GameState"):
		var snapshot_context := GameState.get_snapshot_context()
		var source_phase := str(snapshot_context.get("source_phase", "")).strip_edges()
		if source_phase == "F1":
			var next_phase := str(GameState.current_phase).strip_edges()
			if next_phase.is_empty():
				next_phase = GameState.get_next_phase(source_phase)
			if not next_phase.is_empty():
				GameState.set_gameplay_resume(next_phase, 0)
		GameState.clear_snapshot_context()
	get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH)
