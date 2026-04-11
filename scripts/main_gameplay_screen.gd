extends Control

const TITLE_SCENE_PATH := "res://scenes/start/TitleScreen.tscn"
const SURGERY_SCENE_PATH := "res://scenes/gameplay/SurgeryLayer.tscn"
const PHASE_FLOW := ["F1", "F2", "F3"]
const FILM_METRIC_MAX := 9.0
const PHASE_CONTENT := {
	"F1": {
		"scene_image_label": "F1 // OPERATING FLOOR",
		"scene_image_note": "Freeze 1 establishes the field. The first cut hands directly into Surgery Layer before the run can settle.",
		"inner_voice": "OCTAVIUS INNER VOICE // Name the wound before it starts naming you.",
		"overline": "FIELD FLOW // F1",
		"title": "Operating Floor",
		"beat_line": "INT. PREP BAY - FIRST FREEZE",
		"body_copy": "[i]The run opens in a controlled chamber.[/i]\n\nF1 now lives inside the shared runtime shell. Read the setup, inspect the tracked channels, and move into Surgery Layer when the freeze point hits.",
		"cue_card": "Phase carrier: GameplayScreen. Next forced step: Surgery Layer for F1.",
		"scratch_notes": "Runtime path: Title -> Gameplay(F1) -> Surgery -> Gameplay(F2).",
		"primary_action": "Enter Surgery Layer",
		"secondary_action": "Return to Title",
		"slot_a_title": "Scene Channel",
		"slot_a_cue": "first fracture: escalation available",
		"slot_b_title": "Victoria Channel",
		"slot_b_cue": "first fracture: exit pressure tracked",
		"slot_c_title": "Desmond Channel",
		"slot_c_cue": "first fracture: precision pressure tracked",
	},
	"F2": {
		"scene_image_label": "F2 // THEATER HOLD",
		"scene_image_note": "Freeze 2 returns to the same runtime shell with prior allocation already recorded. The second cut compounds what was preserved.",
		"inner_voice": "OCTAVIUS INNER VOICE // The room remembers where you pushed first.",
		"overline": "FIELD FLOW // F2",
		"title": "Second Threshold",
		"beat_line": "INT. SURGERY THEATER - MID-RUN",
		"body_copy": "[i]The shell stays the same, the pressure changes.[/i]\n\nF2 is no longer a separate playable scene. GameplayScreen resumes here, reflects the carried state, and pushes the run into Surgery Layer again.",
		"cue_card": "Freeze 2 stacks onto the recorded totals instead of replacing them.",
		"scratch_notes": "Runtime path: Gameplay(F2) -> Surgery -> Gameplay(F3).",
		"primary_action": "Route Freeze 2",
		"secondary_action": "Return to Title",
		"slot_a_title": "Scene Channel",
		"slot_a_cue": "pressure carried from the first cut",
		"slot_b_title": "Victoria Channel",
		"slot_b_cue": "exit integrity still contested",
		"slot_c_title": "Desmond Channel",
		"slot_c_cue": "control cost now compounding",
	},
	"F3": {
		"scene_image_label": "F3 // RESOLUTION EDGE",
		"scene_image_note": "Freeze 3 is the last playable beat. One final surgery pass resolves the run and hands off to Final Screen.",
		"inner_voice": "OCTAVIUS INNER VOICE // Whatever carries the last weight writes the archive.",
		"overline": "FIELD FLOW // F3",
		"title": "Final Threshold",
		"beat_line": "INT. ARCHIVE EDGE - LAST FREEZE",
		"body_copy": "[i]The same carrier now holds the closing beat.[/i]\n\nF3 remains gameplay inside the shared shell. Enter Surgery Layer one last time, let GameState resolve the accumulated load, and exit cleanly into Final Screen.",
		"cue_card": "Last runtime step: Surgery resolves totals, then Final Screen reads the recorded outcome.",
		"scratch_notes": "Runtime path: Gameplay(F3) -> Surgery -> Final.",
		"primary_action": "Resolve Final Surgery",
		"secondary_action": "Return to Title",
		"slot_a_title": "Scene Channel",
		"slot_a_cue": "final escalation would dominate the record",
		"slot_b_title": "Victoria Channel",
		"slot_b_cue": "final mercy would carry the exit",
		"slot_c_title": "Desmond Channel",
		"slot_c_cue": "final precision would narrow the ending",
	},
}

@onready var scene_image_label: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/SceneImageArea/SceneImageLabel
@onready var scene_image_note: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/SceneImageArea/SceneImageNote
@onready var inner_voice_label: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/SceneImageArea/OctaviusInnerVoiceLayer/OctaviusInnerVoiceLabel

@onready var portrait_strip: PanelContainer = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip
@onready var portrait_bleach_overlay: ColorRect = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitFx/BleachOverlay
@onready var portrait_oblivion_static_a: ColorRect = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitFx/OblivionStaticA
@onready var portrait_oblivion_static_b: ColorRect = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitFx/OblivionStaticB
@onready var portrait_oblivion_grime_left: ColorRect = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitFx/OblivionGrimeLeft
@onready var portrait_oblivion_grime_right: ColorRect = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitFx/OblivionGrimeRight
@onready var portrait_pressure_edge_top: ColorRect = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitFx/PressureEdgeTop
@onready var portrait_pressure_edge_bottom: ColorRect = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitFx/PressureEdgeBottom
@onready var portrait_pressure_fracture_left: ColorRect = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitFx/PressureFractureLeft
@onready var portrait_pressure_fracture_right: ColorRect = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitFx/PressureFractureRight
@onready var dossier_slot_a: PanelContainer = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotA
@onready var dossier_slot_a_headshot_label: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotA/DossierSlotAMargin/DossierSlotAStack/DossierSlotAHeadshot/DossierSlotAHeadshotLabel
@onready var dossier_slot_a_title: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotA/DossierSlotAMargin/DossierSlotAStack/DossierSlotATitle
@onready var dossier_slot_a_cue: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotA/DossierSlotAMargin/DossierSlotAStack/DossierSlotACue
@onready var dossier_slot_b: PanelContainer = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotB
@onready var dossier_slot_b_headshot_label: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotB/DossierSlotBMargin/DossierSlotBStack/DossierSlotBHeadshot/DossierSlotBHeadshotLabel
@onready var dossier_slot_b_title: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotB/DossierSlotBMargin/DossierSlotBStack/DossierSlotBTitle
@onready var dossier_slot_b_cue: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotB/DossierSlotBMargin/DossierSlotBStack/DossierSlotBCue
@onready var dossier_slot_c: PanelContainer = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotC
@onready var dossier_slot_c_headshot_label: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotC/DossierSlotCMargin/DossierSlotCStack/DossierSlotCHeadshot/DossierSlotCHeadshotLabel
@onready var dossier_slot_c_title: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotC/DossierSlotCMargin/DossierSlotCStack/DossierSlotCTitle
@onready var dossier_slot_c_cue: Label = $Margin/RootStack/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotC/DossierSlotCMargin/DossierSlotCStack/DossierSlotCCue

@onready var overline: Label = $Margin/RootStack/MainRow/ScriptColumn/ScriptMargin/ScriptStack/Overline
@onready var title_label: Label = $Margin/RootStack/MainRow/ScriptColumn/ScriptMargin/ScriptStack/Title
@onready var beat_line: Label = $Margin/RootStack/MainRow/ScriptColumn/ScriptMargin/ScriptStack/BeatLine
@onready var body_copy: RichTextLabel = $Margin/RootStack/MainRow/ScriptColumn/ScriptMargin/ScriptStack/BodyCopy
@onready var cue_card_text: Label = $Margin/RootStack/MainRow/ScriptColumn/ScriptMargin/ScriptStack/CueCard/CueCardMargin/CueCardText
@onready var scratch_notes: Label = $Margin/RootStack/MainRow/ScriptColumn/ScriptMargin/ScriptStack/ScratchNotes
@onready var primary_action_button: Button = $Margin/RootStack/MainRow/ScriptColumn/ScriptMargin/ScriptStack/ActionButtons/PrimaryActionButton
@onready var secondary_action_button: Button = $Margin/RootStack/MainRow/ScriptColumn/ScriptMargin/ScriptStack/ActionButtons/SecondaryActionButton
@onready var tertiary_action_button: Button = $Margin/RootStack/MainRow/ScriptColumn/ScriptMargin/ScriptStack/ActionButtons/TertiaryActionButton

var current_phase := "F1"
var metrics_pulse_time := 0.0


func _ready() -> void:
	_resolve_phase()
	_bind_actions()
	_apply_phase_content()
	_refresh_metric_panel()
	set_process(true)


func _process(delta: float) -> void:
	metrics_pulse_time += delta
	_refresh_metric_panel()


func _resolve_phase() -> void:
	if has_node("/root/GameState"):
		GameState.ensure_runtime_phase()
		current_phase = GameState.current_phase
	if not PHASE_FLOW.has(current_phase):
		current_phase = PHASE_FLOW[0]


func _bind_actions() -> void:
	primary_action_button.pressed.connect(_go_to_surgery)
	secondary_action_button.pressed.connect(_return_to_title)
	tertiary_action_button.hide()
	primary_action_button.grab_focus()


func _apply_phase_content() -> void:
	var content: Dictionary = PHASE_CONTENT.get(current_phase, PHASE_CONTENT["F1"])

	scene_image_label.text = content["scene_image_label"]
	scene_image_note.text = "%s\n\nCompleted freezes: %s\nAccumulated routing: %s" % [
		content["scene_image_note"],
		_build_completed_summary(),
		_build_allocation_summary(),
	]
	inner_voice_label.text = content["inner_voice"]

	overline.text = content["overline"]
	title_label.text = content["title"]
	beat_line.text = content["beat_line"]
	body_copy.text = "%s\n\nCurrent runtime phase: %s." % [content["body_copy"], current_phase]
	cue_card_text.text = content["cue_card"]
	scratch_notes.text = "%s\nLegacy scenes F1/F2/F3 remain preserved as reference only." % content["scratch_notes"]

	primary_action_button.text = content["primary_action"]
	secondary_action_button.text = content["secondary_action"]
	_refresh_metric_panel()


func _go_to_surgery() -> void:
	get_tree().change_scene_to_file(SURGERY_SCENE_PATH)


func _return_to_title() -> void:
	if has_node("/root/GameState"):
		GameState.reset_run()
	get_tree().change_scene_to_file(TITLE_SCENE_PATH)


func _build_completed_summary() -> String:
	if not has_node("/root/GameState") or GameState.completed_phases.is_empty():
		return "none"
	return ", ".join(GameState.completed_phases)


func _build_allocation_summary() -> String:
	if not has_node("/root/GameState"):
		return "Scene 0 / Victoria 0 / Desmond 0"
	return "Scene %d / Victoria %d / Desmond %d" % [
		int(GameState.surgery_allocation.get("scene", 0)),
		int(GameState.surgery_allocation.get("victoria", 0)),
		int(GameState.surgery_allocation.get("desmond", 0)),
	]


func _refresh_metric_panel() -> void:
	if has_node("/root/GameState"):
		current_phase = GameState.current_phase if not GameState.current_phase.is_empty() else PHASE_FLOW[PHASE_FLOW.size() - 1]

	if not has_node("/root/GameState"):
		dossier_slot_a_headshot_label.text = "FILM"
		dossier_slot_a_title.text = "Depth 0"
		dossier_slot_a_cue.text = "Oblivion 0 [LOW]\nPressure 0 [LOW]"
		dossier_slot_b_headshot_label.text = "PLAYER"
		dossier_slot_b_title.text = "Control_next 0"
		dossier_slot_b_cue.text = "Phase %s | O LOW\nFreezes none | P LOW" % current_phase
		dossier_slot_c_headshot_label.text = "CAST"
		dossier_slot_c_title.text = "D I/T 0/0"
		dossier_slot_c_cue.text = "V I/T 0/0\nL I/T 0/0"
		_apply_metric_panel_corruption()
		return

	dossier_slot_a_headshot_label.text = "FILM"
	dossier_slot_a_title.text = "Depth %d" % GameState.film_depth
	dossier_slot_a_cue.text = "Oblivion %d [%s]\nPressure %d [%s]" % [
		GameState.film_oblivion,
		_risk_tag(int(GameState.film_oblivion)),
		GameState.film_pressure,
		_risk_tag(int(GameState.film_pressure)),
	]
	dossier_slot_b_headshot_label.text = "PLAYER"
	dossier_slot_b_title.text = "Control_next %d" % GameState.control_next
	dossier_slot_b_cue.text = "Phase %s | O %s\nFreezes %s | P %s" % [
		current_phase,
		_risk_tag(int(GameState.film_oblivion)),
		_build_completed_summary(),
		_risk_tag(int(GameState.film_pressure)),
	]
	dossier_slot_c_headshot_label.text = "CAST"
	dossier_slot_c_title.text = "D I/T %d/%d" % [
		GameState.desmond_integrity,
		GameState.desmond_trauma,
	]
	dossier_slot_c_cue.text = "V I/T %d/%d\nL I/T %d/%d" % [
		GameState.victoria_integrity,
		GameState.victoria_trauma,
		GameState.leonard_integrity,
		GameState.leonard_trauma,
	]
	_apply_metric_panel_corruption()


func _apply_metric_panel_corruption() -> void:
	var oblivion_ratio: float = 0.0
	var pressure_ratio: float = 0.0
	var oblivion_value: int = 0
	var pressure_value: int = 0
	if has_node("/root/GameState"):
		oblivion_value = int(GameState.film_oblivion)
		pressure_value = int(GameState.film_pressure)
		oblivion_ratio = clampf(float(oblivion_value) / FILM_METRIC_MAX, 0.0, 1.0)
		pressure_ratio = clampf(float(pressure_value) / FILM_METRIC_MAX, 0.0, 1.0)

	var oblivion_band: int = _risk_band(oblivion_value)
	var pressure_band: int = _risk_band(pressure_value)
	var global_band: int = maxi(oblivion_band, pressure_band)

	var base_style := StyleBoxFlat.new()
	base_style.bg_color = Color(
		lerpf(0.08, 0.26, oblivion_ratio * 0.50),
		lerpf(0.07, 0.24, oblivion_ratio * 0.54),
		lerpf(0.06, 0.29, max(oblivion_ratio * 0.62, pressure_ratio * 0.16)),
		lerpf(0.94, 0.80, oblivion_ratio)
	)
	base_style.border_width_left = 2
	base_style.border_width_top = 2
	base_style.border_width_right = 2
	base_style.border_width_bottom = 2
	base_style.border_color = Color(
		lerpf(0.39, 0.72, pressure_ratio * 0.90),
		lerpf(0.32, 0.38, oblivion_ratio * 0.55),
		lerpf(0.25, 0.96, pressure_ratio * 0.95),
		lerpf(0.85, 0.98, max(oblivion_ratio * 0.8, pressure_ratio))
	)
	base_style.corner_radius_top_left = 8
	base_style.corner_radius_top_right = 8
	base_style.corner_radius_bottom_right = 12
	base_style.corner_radius_bottom_left = 12
	base_style.shadow_color = Color(0.33, 0.10, 0.55, 0.10 + pressure_ratio * 0.30)
	base_style.shadow_size = 8 + int(round(pressure_ratio * 12.0))
	portrait_strip.add_theme_stylebox_override("panel", base_style)

	var film_card_band: int = maxi(oblivion_band, pressure_band)
	var player_card_band: int = maxi(oblivion_band, pressure_band)
	var cast_card_band: int = max(oblivion_band - 1, pressure_band)
	var card_bands: Array[int] = [film_card_band, player_card_band, cast_card_band]
	var card_index: int = 0
	for card: PanelContainer in [dossier_slot_a, dossier_slot_b, dossier_slot_c]:
		var card_band: int = card_bands[card_index]
		var card_heat: float = [0.0, 0.42, 0.82][card_band]
		var card_fade: float = [0.0, 0.34, 0.68][card_band]
		var card_style := StyleBoxFlat.new()
		card_style.bg_color = Color(
			lerpf(0.18, 0.34, max(oblivion_ratio * 0.30, card_heat * 0.12)),
			lerpf(0.18, 0.24, oblivion_ratio * 0.24),
			lerpf(0.16, 0.33, max(oblivion_ratio * 0.34, pressure_ratio * 0.30)),
			lerpf(1.0, 0.84, max(oblivion_ratio * 0.7, card_fade * 0.5))
		)
		card_style.border_width_left = 1
		card_style.border_width_top = 1
		card_style.border_width_right = 1
		card_style.border_width_bottom = 1
		card_style.border_color = Color(
			lerpf(0.51, 0.86, pressure_ratio * 0.78 + card_heat * 0.12),
			lerpf(0.45, 0.40, oblivion_ratio * 0.55),
			lerpf(0.35, 0.98, pressure_ratio * 0.88 + card_heat * 0.08),
			lerpf(0.80, 0.96, max(pressure_ratio * 0.9, oblivion_ratio * 0.65, float(card_band) * 0.22))
		)
		card_style.corner_radius_top_left = 6
		card_style.corner_radius_top_right = 6
		card_style.corner_radius_bottom_right = 6
		card_style.corner_radius_bottom_left = 6
		card.add_theme_stylebox_override("panel", card_style)
		card_index += 1

	var heading_alpha: float = lerpf(0.92, 0.54, oblivion_ratio)
	var title_alpha: float = lerpf(0.98, 0.70, oblivion_ratio * 0.70)
	var cue_alpha: float = lerpf(0.88, 0.42, oblivion_ratio)
	for heading: Label in [dossier_slot_a_headshot_label, dossier_slot_b_headshot_label, dossier_slot_c_headshot_label]:
		heading.modulate = Color(
			lerpf(0.88, 1.00, pressure_ratio * 0.26),
			lerpf(0.90, 0.84, oblivion_ratio * 0.26),
			lerpf(0.95, 1.00, pressure_ratio * 0.34),
			heading_alpha
		)
	var title_colors: Array[Color] = [
		Color(
			lerpf(0.92, 1.00, pressure_ratio * 0.18),
			lerpf(0.92, 0.82, oblivion_ratio * 0.26),
			lerpf(0.94, 1.00, pressure_ratio * 0.26),
			title_alpha
		),
		Color(
			lerpf(0.92, 0.96, float(global_band) * 0.12),
			lerpf(0.92, 0.85, oblivion_ratio * 0.20),
			lerpf(0.94, 0.99, pressure_ratio * 0.16),
			title_alpha
		),
		Color(
			lerpf(0.92, 0.95, float(global_band) * 0.08),
			lerpf(0.92, 0.84, oblivion_ratio * 0.24),
			lerpf(0.94, 0.97, pressure_ratio * 0.12),
			lerpf(title_alpha, cue_alpha, 0.2)
		),
	]
	var title_index: int = 0
	for title: Label in [dossier_slot_a_title, dossier_slot_b_title, dossier_slot_c_title]:
		title.modulate = title_colors[title_index]
		title_index += 1
	var cue_colors: Array[Color] = [
		Color(
			lerpf(0.84, 0.96, pressure_ratio * 0.24),
			lerpf(0.76, 0.74, pressure_ratio * 0.10),
			lerpf(0.70, 0.98, pressure_ratio * 0.42),
			cue_alpha
		),
		Color(
			lerpf(0.82, 0.90, pressure_ratio * 0.14),
			lerpf(0.74, 0.72, oblivion_ratio * 0.06),
			lerpf(0.68, 0.92, pressure_ratio * 0.24),
			lerpf(cue_alpha, cue_alpha * 0.92, float(global_band) * 0.15)
		),
		Color(
			lerpf(0.80, 0.88, pressure_ratio * 0.10),
			lerpf(0.74, 0.70, oblivion_ratio * 0.10),
			lerpf(0.68, 0.86, pressure_ratio * 0.16),
			lerpf(cue_alpha, cue_alpha * 0.84, oblivion_ratio * 0.24)
		),
	]
	var cue_index: int = 0
	for cue: Label in [dossier_slot_a_cue, dossier_slot_b_cue, dossier_slot_c_cue]:
		cue.modulate = cue_colors[cue_index]
		cue_index += 1

	var oblivion_flicker: float = 0.55 + 0.45 * absf(sin(metrics_pulse_time * (3.1 + oblivion_ratio * 2.8)))
	var pressure_shimmer: float = 0.72 + 0.28 * sin(metrics_pulse_time * (2.0 + pressure_ratio * 2.2))
	var danger_flash: float = 0.55 + 0.45 * absf(sin(metrics_pulse_time * (4.8 + float(global_band) * 0.7)))
	portrait_bleach_overlay.color = Color(0.92, 0.94, 0.95, 0.08 + oblivion_ratio * 0.34)
	portrait_oblivion_static_a.color = Color(0.94, 0.96, 0.98, oblivion_ratio * (0.08 + 0.14 * oblivion_flicker))
	portrait_oblivion_static_b.color = Color(0.80, 0.84, 0.88, oblivion_ratio * (0.06 + 0.12 * (1.0 - oblivion_flicker)))
	portrait_oblivion_grime_left.color = Color(0.60, 0.64, 0.68, oblivion_ratio * (0.10 + 0.14 * oblivion_flicker))
	portrait_oblivion_grime_right.color = Color(0.60, 0.64, 0.68, oblivion_ratio * (0.11 + 0.13 * (1.0 - oblivion_flicker)))

	var edge_alpha: float = pressure_ratio * (0.10 + 0.24 * pressure_shimmer)
	var fracture_alpha: float = pressure_ratio * (0.08 + 0.16 * absf(sin(metrics_pulse_time * 5.8)))
	var burn_flash_alpha: float = pressure_ratio * float(pressure_band) * 0.04 * danger_flash
	portrait_pressure_edge_top.color = Color(0.61, 0.30, 0.92, edge_alpha + burn_flash_alpha)
	portrait_pressure_edge_bottom.color = Color(0.74, 0.36, 1.00, edge_alpha * 1.18 + burn_flash_alpha)
	portrait_pressure_fracture_left.color = Color(0.70, 0.34, 1.00, fracture_alpha)
	portrait_pressure_fracture_right.color = Color(0.78, 0.38, 1.00, fracture_alpha * 1.08)


func _risk_band(value: int) -> int:
	if value >= 7:
		return 2
	if value >= 4:
		return 1
	return 0


func _risk_tag(value: int) -> String:
	match _risk_band(value):
		2:
			return "HIGH"
		1:
			return "MED"
		_:
			return "LOW"


func _risk_word(value: int) -> String:
	if value >= 7:
		return "high"
	if value >= 4:
		return "rising"
	return "low"
