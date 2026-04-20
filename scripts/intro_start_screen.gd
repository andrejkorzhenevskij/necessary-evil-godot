extends Control

const TITLE_SCREEN_PATH := "res://scenes/start/TitleScreen.tscn"
const INTRO_IMAGE_PATHS := [
	"res://art/titlescreen.png",
	"res://art/Titlescreen.png",
	"res://art/back.png",
]
const FADE_DURATION := 1.5

@onready var backdrop: TextureRect = $Backdrop
@onready var prompt: Label = $PromptLayer/Prompt
@onready var fade_overlay: ColorRect = $FadeOverlay

var is_transitioning := false
var prompt_time := 0.0


func _ready() -> void:
	_assign_backdrop_texture()
	if has_node("/root/TitleMusic"):
		TitleMusic.ensure_title_theme()
	fade_overlay.show()
	fade_overlay.color = Color(0, 0, 0, 1)
	set_process(true)
	_fade_in_from_black()


func _process(delta: float) -> void:
	prompt_time += delta
	var pulse := 0.78 + 0.22 * (0.5 + 0.5 * sin(prompt_time * 2.1))
	prompt.modulate = Color(1, 1, 1, pulse)


func _input(event: InputEvent) -> void:
	if is_transitioning:
		return

	if event.is_action_pressed("ui_accept"):
		_begin_transition()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_begin_transition()
			get_viewport().set_input_as_handled()


func _assign_backdrop_texture() -> void:
	for image_path: String in INTRO_IMAGE_PATHS:
		if not ResourceLoader.exists(image_path):
			continue

		var texture := load(image_path) as Texture2D
		if texture != null:
			backdrop.texture = texture
			return


func _fade_in_from_black() -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), FADE_DURATION)
	await tween.finished
	fade_overlay.hide()


func _begin_transition() -> void:
	if is_transitioning:
		return

	is_transitioning = true
	set_process(false)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.show()
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), FADE_DURATION)
	await tween.finished
	get_tree().change_scene_to_file(TITLE_SCREEN_PATH)
