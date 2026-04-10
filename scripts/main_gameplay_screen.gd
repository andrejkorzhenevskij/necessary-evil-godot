extends Control

const TITLE_SCENE_PATH := "res://scenes/start/TitleScreen.tscn"
const SURGERY_SCENE_PATH := "res://scenes/gameplay/SurgeryLayer.tscn"
const FINAL_SCENE_PATH := "res://scenes/gameplay/FinalScreen.tscn"

@onready var scene_image_label: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/SceneImageArea/SceneImageLabel
@onready var scene_image_note: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/SceneImageArea/SceneImageNote
@onready var inner_voice_label: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/SceneImageArea/OctaviusInnerVoiceLayer/OctaviusInnerVoiceLabel

@onready var dossier_slot_a_headshot_label: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotA/DossierSlotAMargin/DossierSlotAStack/DossierSlotAHeadshot/DossierSlotAHeadshotLabel
@onready var dossier_slot_a_title: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotA/DossierSlotAMargin/DossierSlotAStack/DossierSlotATitle
@onready var dossier_slot_a_cue: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotA/DossierSlotAMargin/DossierSlotAStack/DossierSlotACue
@onready var dossier_slot_b_headshot_label: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotB/DossierSlotBMargin/DossierSlotBStack/DossierSlotBHeadshot/DossierSlotBHeadshotLabel
@onready var dossier_slot_b_title: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotB/DossierSlotBMargin/DossierSlotBStack/DossierSlotBTitle
@onready var dossier_slot_b_cue: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotB/DossierSlotBMargin/DossierSlotBStack/DossierSlotBCue
@onready var dossier_slot_c_headshot_label: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotC/DossierSlotCMargin/DossierSlotCStack/DossierSlotCHeadshot/DossierSlotCHeadshotLabel
@onready var dossier_slot_c_title: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotC/DossierSlotCMargin/DossierSlotCStack/DossierSlotCTitle
@onready var dossier_slot_c_cue: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/PortraitStrip/PortraitMargin/PortraitRow/DossierSlotC/DossierSlotCMargin/DossierSlotCStack/DossierSlotCCue

@onready var overline: Label = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/Overline
@onready var title_label: Label = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/Title
@onready var beat_line: Label = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/BeatLine
@onready var body_copy: RichTextLabel = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/BodyCopy
@onready var cue_card_text: Label = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/CueCard/CueCardMargin/CueCardText
@onready var scratch_notes: Label = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/ScratchNotes
@onready var primary_action_button: Button = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/ActionButtons/PrimaryActionButton
@onready var secondary_action_button: Button = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/ActionButtons/SecondaryActionButton
@onready var tertiary_action_button: Button = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/ActionButtons/TertiaryActionButton


func _ready() -> void:
	_bind_copy()
	_bind_portrait_strip()
	_bind_actions()


func _bind_copy() -> void:
	scene_image_label.text = "FIELD FRAME // CENTRAL GAMEPLAY"
	scene_image_note.text = "This is the playable center of the MVP flow. The left frame holds the atmosphere and the tracked channels; the right column carries the active beat and the next move."
	inner_voice_label.text = "OCTAVIUS INNER VOICE // Hold the fracture where it can still be named."

	overline.text = "FIELD FLOW // MAIN GAME SCREEN"
	title_label.text = "Operating Floor"
	beat_line.text = "INT. PREP BAY - BEFORE THE CUT"
	body_copy.text = "[i]The run is now anchored in one readable screen.[/i]\n\nFrom here the player can read the immediate setup, inspect the three active channels below the frame, and advance into Surgery Layer routing. This pass keeps the MVP narrow: one strong scene, one clear forward move, and one dev-safe way to review the current recorded ending."
	cue_card_text.text = "Primary path: enter Surgery Layer, route the pressure, then review the recorded consequence on Final Screen."
	scratch_notes.text = "Flow: TitleScreen -> GameplayScreen -> SurgeryLayer -> FinalScreen. Secondary action seeds a fallback result only if no ending has been recorded yet."


func _bind_portrait_strip() -> void:
	dossier_slot_a_headshot_label.text = "SCENE"
	dossier_slot_a_title.text = "Scene Channel"
	dossier_slot_a_cue.text = "pressure route: escalation focus"

	dossier_slot_b_headshot_label.text = "VICTORIA"
	dossier_slot_b_title.text = "Exit Channel"
	dossier_slot_b_cue.text = "pressure route: passage and containment"

	dossier_slot_c_headshot_label.text = "DESMOND"
	dossier_slot_c_title.text = "Precision Channel"
	dossier_slot_c_cue.text = "pressure route: control at cost"


func _bind_actions() -> void:
	primary_action_button.text = "Enter Surgery Layer"
	secondary_action_button.text = "Review Final Screen"
	tertiary_action_button.text = "Return to Title"

	primary_action_button.pressed.connect(_go_to_surgery)
	secondary_action_button.pressed.connect(_go_to_final_screen)
	tertiary_action_button.pressed.connect(_return_to_title)
	primary_action_button.grab_focus()


func _go_to_surgery() -> void:
	get_tree().change_scene_to_file(SURGERY_SCENE_PATH)


func _go_to_final_screen() -> void:
	if has_node("/root/GameState") and GameState.ending_id.is_empty():
		GameState.set_surgery_allocation({
			"scene": 1,
			"victoria": 1,
			"desmond": 0,
		})
		GameState.resolve_surgery_allocation()

	get_tree().change_scene_to_file(FINAL_SCENE_PATH)


func _return_to_title() -> void:
	if has_node("/root/GameState"):
		GameState.reset_run()
	get_tree().change_scene_to_file(TITLE_SCENE_PATH)
