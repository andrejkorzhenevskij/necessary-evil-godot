extends Control

func _on_begin_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/intake/IntakeDesk.tscn")
