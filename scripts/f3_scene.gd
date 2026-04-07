extends Control

const TITLE_SCENE_PATH := "res://scenes/start/TitleScreen.tscn"
const REPLAY_SCENE_PATH := "res://scenes/gameplay/F1.tscn"

@onready var scene_image_label: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/SceneImageArea/SceneImageLabel
@onready var scene_image_note: Label = $Margin/MainRow/SceneFrame/FrameMargin/FrameCanvas/SceneImageArea/SceneImageNote
@onready var overline: Label = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/Overline
@onready var title_label: Label = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/Title
@onready var beat_line: Label = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/BeatLine
@onready var body_copy: RichTextLabel = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/BodyCopy
@onready var cue_card_text: Label = $Margin/MainRow/ScriptColumn/ScriptMargin/ScriptStack/CueCard/CueCardMargin/CueCardText
@onready var scratch_notes: Label = %ScratchNotes
@onready var primary_action_button: Button = %PrimaryActionButton
@onready var secondary_action_button: Button = %SecondaryActionButton
@onready var tertiary_action_button: Button = %TertiaryActionButton


func _ready() -> void:
	var achievement_summary := ", ".join(GameState.achievement_ids)
	if achievement_summary.is_empty():
		achievement_summary = "none"

	scene_image_label.text = "F3 // FINAL OUTCOME"
	scene_image_note.text = "The run resolves here using the exact values stored in GameState."
	overline.text = "FIELD FLOW // F3"
	title_label.text = "Outcome Report"
	beat_line.text = "INT. ARCHIVE CHAMBER - POST-OP"
	body_copy.text = "[i]Run locked.[/i]\n\nDominant zone: %s\nEnding: %s\nLeonard dossier variant: %s\nAchievements: %s" % [
		_value_or_placeholder(GameState.dominant_zone),
		_value_or_placeholder(GameState.ending_id),
		_value_or_placeholder(GameState.leonard_dossier_variant),
		achievement_summary,
	]
	cue_card_text.text = "This is the concrete end of the MVP path."
	scratch_notes.text = "Restart returns to TitleScreen. Replay jumps back to F1."
	primary_action_button.text = "Return to Title"
	secondary_action_button.text = "Replay F1"
	tertiary_action_button.hide()
	primary_action_button.pressed.connect(_return_to_title)
	secondary_action_button.pressed.connect(_replay_flow)
	primary_action_button.grab_focus()


func _return_to_title() -> void:
	get_tree().change_scene_to_file(TITLE_SCENE_PATH)


func _replay_flow() -> void:
	get_tree().change_scene_to_file(REPLAY_SCENE_PATH)


func _value_or_placeholder(value: String) -> String:
	return value if not value.is_empty() else "unset"
