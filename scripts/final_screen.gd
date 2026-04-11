extends Control

const TITLE_SCENE_PATH := "res://scenes/start/TitleScreen.tscn"
const RESTART_SCENE_PATH := "res://scenes/gameplay/GameplayScreen.tscn"

const ENDING_SUMMARIES := {
	"12A": {
		"title": "12A // Escalation Routed Through Scene",
		"summary": "Scene takes the full load. The rupture stays alive, visible, and useful. The run ends with consequence concentrated instead of dispersed.",
	},
	"12B": {
		"title": "12B // Exit Preserved For Victoria",
		"summary": "Victoria absorbs the carrying line. The breach is contained at the threshold, and the cost is paid in safe passage rather than spectacle.",
	},
	"12C": {
		"title": "12C // Precision Preserved For Desmond",
		"summary": "Desmond inherits the fracture cost. The operation holds its shape, but the ending lands colder and narrower than the others.",
	},
	"12D": {
		"title": "12D // Split Outcome Neutralized",
		"summary": "No single carrier takes the full burden. The run closes on a split line: stable enough to survive, unstable enough to remain unresolved.",
	},
}

const DOSSIER_PAYOFFS := {
	"A": "Archive note A: the file opens on a corridor still vibrating from overuse. Witness language hardens around Scene, as if the run needed a visible wound to stay legible.",
	"B": "Archive note B: the record softens at the edges. Victoria is logged as the point where harm was redirected into passage, not erased, only made survivable.",
	"C": "Archive note C: the annotation narrows into procedural language. Desmond remains intact on paper, but the paper reads like a colder room than before.",
	"D": "Archive note D: the dossier refuses a clean subject line. Too many hands carried the pressure, and the aftermath records itself as compromise rather than verdict.",
}

const BADGE_COPY := {
	"escalation": {
		"title": "ESCALATION",
		"body": "Pressure was made legible by concentrating it in the theater seam.",
	},
	"mercy": {
		"title": "MERCY",
		"body": "The run preserved an exit, even while recording the cost of doing so.",
	},
	"precision_at_cost": {
		"title": "PRECISION AT COST",
		"body": "The shape of the operation survived by narrowing who carried the damage.",
	},
	"neutralized_split": {
		"title": "SPLIT LINE",
		"body": "The consequence was distributed. Nothing broke cleanly enough to count as closure.",
	},
}

@onready var overline: Label = $Margin/RootColumn/HeaderBlock/Overline
@onready var title_label: Label = $Margin/RootColumn/HeaderBlock/Title
@onready var subtitle_label: Label = $Margin/RootColumn/HeaderBlock/Subtitle
@onready var ending_label: Label = $Margin/RootColumn/ContentRow/ResultPanel/Margin/Stack/EndingLabel
@onready var ending_summary: RichTextLabel = $Margin/RootColumn/ContentRow/ResultPanel/Margin/Stack/EndingSummary
@onready var run_meta: Label = $Margin/RootColumn/ContentRow/ResultPanel/Margin/Stack/RunMeta
@onready var dossier_label: Label = $Margin/RootColumn/ContentRow/DossierPanel/Margin/Stack/DossierLabel
@onready var dossier_body: Label = $Margin/RootColumn/ContentRow/DossierPanel/Margin/Stack/DossierBody
@onready var dossier_variant_label: Label = $Margin/RootColumn/ContentRow/DossierPanel/Margin/Stack/DossierVariantLabel
@onready var badges_heading: Label = $Margin/RootColumn/BadgesPanel/Margin/Stack/BadgesHeading
@onready var badge_slot_a_title: Label = $Margin/RootColumn/BadgesPanel/Margin/Stack/BadgeRow/BadgeSlotA/Margin/Stack/BadgeSlotATitle
@onready var badge_slot_a_body: Label = $Margin/RootColumn/BadgesPanel/Margin/Stack/BadgeRow/BadgeSlotA/Margin/Stack/BadgeSlotABody
@onready var badge_slot_b_title: Label = $Margin/RootColumn/BadgesPanel/Margin/Stack/BadgeRow/BadgeSlotB/Margin/Stack/BadgeSlotBTitle
@onready var badge_slot_b_body: Label = $Margin/RootColumn/BadgesPanel/Margin/Stack/BadgeRow/BadgeSlotB/Margin/Stack/BadgeSlotBBody
@onready var badge_slot_c_title: Label = $Margin/RootColumn/BadgesPanel/Margin/Stack/BadgeRow/BadgeSlotC/Margin/Stack/BadgeSlotCTitle
@onready var badge_slot_c_body: Label = $Margin/RootColumn/BadgesPanel/Margin/Stack/BadgeRow/BadgeSlotC/Margin/Stack/BadgeSlotCBody
@onready var footer_note: Label = $Margin/RootColumn/FooterBlock/FooterNote
@onready var restart_button: Button = $Margin/RootColumn/FooterBlock/ButtonRow/RestartButton
@onready var return_button: Button = $Margin/RootColumn/FooterBlock/ButtonRow/ReturnButton


func _ready() -> void:
	_apply_screen_styles()
	_bind_game_state()
	restart_button.pressed.connect(_restart_run)
	return_button.pressed.connect(_back_to_menu)
	restart_button.grab_focus()


func _bind_game_state() -> void:
	var ending := _read_string("ending_id")
	var dominant_zone := _resolve_dominant_zone()
	var dossier_variant := _read_string("dossier_variant")
	var badges := _read_badges()
	var ending_copy: Dictionary = ENDING_SUMMARIES.get(ending, {})
	var allocation_summary := _build_allocation_summary()
	var completed_summary := _build_completed_summary()
	var resolution_label := _read_string("resolution_label")
	var resolution_summary := _read_string("resolution_summary")

	overline.text = "WEYR RECORD // FINAL SCREEN"
	title_label.text = ending_copy.get("title", "OUTCOME UNRESOLVED")
	subtitle_label.text = "Recorded consequence: %s" % _value_or_placeholder(resolution_label)

	ending_label.text = "ENDING SUMMARY"
	ending_summary.text = "[i]%s[/i]\n\n%s\n\nResolver: %s" % [
		ending if not ending.is_empty() else "ENDING ID UNSET",
		ending_copy.get("summary", "No resolved ending is available yet. Launch the scene directly for layout checks, or enter it through the MVP flow to read the recorded result."),
		resolution_summary if not resolution_summary.is_empty() else "Outcome resolver did not record a visible summary.",
	]
	run_meta.text = "Completed freezes: %s\nDominant zone: %s\nAllocation: %s" % [
		completed_summary,
		_value_or_placeholder(dominant_zone).to_upper(),
		allocation_summary,
	]

	dossier_label.text = "DOSSIER PAYOFF"
	dossier_body.text = DOSSIER_PAYOFFS.get(
		dossier_variant,
		"Archive note: the file opens, but the paragraph remains provisional. No dossier variant was recorded for this run."
	)
	dossier_variant_label.text = "Dossier variant: %s" % _value_or_placeholder(dossier_variant)

	badges_heading.text = "MARKERS RECORDED"
	_bind_badge_slots(badges)

	footer_note.text = "Restart Run starts a new pass from F1. Back to Menu returns to the title screen. Both clear the current run state."


func _bind_badge_slots(badges: Array[String]) -> void:
	var titles := [badge_slot_a_title, badge_slot_b_title, badge_slot_c_title]
	var bodies := [badge_slot_a_body, badge_slot_b_body, badge_slot_c_body]

	for index: int in range(3):
		if index < badges.size():
			var badge_id := badges[index]
			var badge_copy: Dictionary = BADGE_COPY.get(badge_id, {})
			titles[index].text = badge_copy.get("title", badge_id.to_upper())
			bodies[index].text = badge_copy.get("body", "Recorded badge id: %s" % badge_id)
		else:
			titles[index].text = "EMPTY SLOT"
			bodies[index].text = "No badge recorded for this marker slot."


func _resolve_dominant_zone() -> String:
	var dominant_zone := _read_string("dominant_zone")
	if not dominant_zone.is_empty():
		return dominant_zone

	var allocation: Dictionary = _read_allocation()
	var scene_points := int(allocation.get("scene", 0))
	var victoria_points := int(allocation.get("victoria", 0))
	var desmond_points := int(allocation.get("desmond", 0))
	var highest_points := maxi(scene_points, maxi(victoria_points, desmond_points))
	var highest_count := 0

	for points: int in [scene_points, victoria_points, desmond_points]:
		if points == highest_points:
			highest_count += 1

	if highest_points == 0:
		return ""
	if highest_count > 1:
		return "mixed"
	if scene_points == highest_points:
		return "scene"
	if victoria_points == highest_points:
		return "victoria"
	return "desmond"


func _build_allocation_summary() -> String:
	var allocation := _read_allocation()
	return "Scene %d / Victoria %d / Desmond %d" % [
		int(allocation.get("scene", 0)),
		int(allocation.get("victoria", 0)),
		int(allocation.get("desmond", 0)),
	]


func _read_allocation() -> Dictionary:
	if has_node("/root/GameState"):
		return GameState.surgery_allocation
	return {"scene": 0, "victoria": 0, "desmond": 0}


func _read_badges() -> Array[String]:
	if has_node("/root/GameState"):
		return GameState.badge_ids
	return []


func _build_completed_summary() -> String:
	if has_node("/root/GameState") and not GameState.completed_phases.is_empty():
		return ", ".join(GameState.completed_phases)
	return "none"


func _read_string(field_name: String) -> String:
	if not has_node("/root/GameState"):
		return ""
	return str(GameState.get(field_name))


func _value_or_placeholder(value: String) -> String:
	return value if not value.is_empty() else "unrecorded"


func _restart_run() -> void:
	if has_node("/root/GameState"):
		GameState.reset_run()
	get_tree().change_scene_to_file(RESTART_SCENE_PATH)


func _back_to_menu() -> void:
	if has_node("/root/GameState"):
		GameState.reset_run()
	get_tree().change_scene_to_file(TITLE_SCENE_PATH)


func _apply_screen_styles() -> void:
	_style_label(overline, 14, Color(0.68, 0.71, 0.8, 0.92))
	_style_label(title_label, 36, Color(0.93, 0.94, 0.98, 1.0))
	_style_label(subtitle_label, 16, Color(0.84, 0.71, 1.0, 0.98))
	_style_label(ending_label, 14, Color(0.84, 0.71, 1.0, 0.98))
	_style_label(run_meta, 14, Color(0.7, 0.73, 0.8, 0.94))
	_style_label(dossier_label, 14, Color(0.84, 0.71, 1.0, 0.98))
	_style_label(dossier_body, 17, Color(0.9, 0.92, 0.97, 0.98))
	_style_label(dossier_variant_label, 14, Color(0.7, 0.73, 0.8, 0.94))
	_style_label(badges_heading, 14, Color(0.84, 0.71, 1.0, 0.98))
	_style_label(footer_note, 14, Color(0.68, 0.71, 0.8, 0.92))

	for title: Label in [badge_slot_a_title, badge_slot_b_title, badge_slot_c_title]:
		_style_label(title, 15, Color(0.95, 0.85, 1.0, 0.98))

	for body: Label in [badge_slot_a_body, badge_slot_b_body, badge_slot_c_body]:
		_style_label(body, 13, Color(0.72, 0.75, 0.83, 0.94))

	ending_summary.add_theme_font_size_override("normal_font_size", 18)
	ending_summary.add_theme_color_override("default_color", Color(0.9, 0.92, 0.97, 0.98))
	ending_summary.add_theme_color_override("font_outline_color", Color(0.01, 0.01, 0.02, 0.9))
	ending_summary.add_theme_constant_override("outline_size", 1)

	var panel_paths := [
		"Margin/RootColumn/ContentRow/ResultPanel",
		"Margin/RootColumn/ContentRow/DossierPanel",
		"Margin/RootColumn/BadgesPanel",
	]
	for panel_path: String in panel_paths:
		var panel := get_node(panel_path) as PanelContainer
		panel.add_theme_stylebox_override("panel", _make_panel_style())

	var badge_slot_paths := [
		"Margin/RootColumn/BadgesPanel/Margin/Stack/BadgeRow/BadgeSlotA",
		"Margin/RootColumn/BadgesPanel/Margin/Stack/BadgeRow/BadgeSlotB",
		"Margin/RootColumn/BadgesPanel/Margin/Stack/BadgeRow/BadgeSlotC",
	]
	for slot_path: String in badge_slot_paths:
		var slot := get_node(slot_path) as PanelContainer
		slot.add_theme_stylebox_override("panel", _make_badge_style())

	_apply_button_style(restart_button, true)
	_apply_button_style(return_button, false)


func _style_label(label: Label, font_size: int, color: Color) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.01, 0.01, 0.02, 0.9))
	label.add_theme_constant_override("outline_size", 1)


func _apply_button_style(button: Button, primary: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.17, 0.1, 0.25, 0.98) if primary else Color(0.1, 0.11, 0.15, 0.95)
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(0.9, 0.72, 1.0, 0.95) if primary else Color(0.36, 0.4, 0.48, 0.9)
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_right = 12
	normal.corner_radius_bottom_left = 12
	normal.shadow_color = Color(0, 0, 0, 0.35)
	normal.shadow_size = 10

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = normal.bg_color.lightened(0.08)

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = normal.bg_color.darkened(0.08)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(0.94, 0.95, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.94, 0.95, 0.98, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.94, 0.95, 0.98, 1.0))


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.075, 0.085, 0.11, 0.96)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.43, 0.29, 0.58, 0.9)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.shadow_color = Color(0.08, 0.02, 0.12, 0.36)
	style.shadow_size = 14
	return style


func _make_badge_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.12, 0.16, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.5, 0.37, 0.65, 0.84)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	return style
