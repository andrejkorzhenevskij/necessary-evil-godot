extends Node

const SURGERY_RESULT_BY_ZONE := {
	"scene": {
		"ending_id": "ending_12a",
		"achievement_ids": ["escalation"],
		"leonard_dossier_variant": "leonard_a",
	},
	"victoria": {
		"ending_id": "ending_12b",
		"achievement_ids": ["mercy_question"],
		"leonard_dossier_variant": "leonard_b",
	},
	"desmond": {
		"ending_id": "ending_12c",
		"achievement_ids": ["precision_at_cost"],
		"leonard_dossier_variant": "leonard_c",
	},
}

var dominant_zone: String = ""
var ending_id: String = ""
var achievement_ids: Array[String] = []
var leonard_dossier_variant: String = ""


func reset_run() -> void:
	dominant_zone = ""
	ending_id = ""
	achievement_ids = []
	leonard_dossier_variant = ""


func resolve_surgery_results(zone: String) -> void:
	var result: Dictionary = SURGERY_RESULT_BY_ZONE.get(zone, {})
	if result.is_empty():
		reset_run()
		push_error("GameState.resolve_surgery_results: unknown dominant zone '%s'" % zone)
		return

	dominant_zone = zone
	ending_id = result["ending_id"]
	achievement_ids = (result["achievement_ids"] as Array).duplicate()
	leonard_dossier_variant = result["leonard_dossier_variant"]
