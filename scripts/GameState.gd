extends Node

const F2_OUTCOMES: Dictionary[String, Dictionary] = {
	"scene": {
		"ending_id": "12A",
		"badge_id": "escalation",
		"dossier_variant": "A",
	},
	"victoria": {
		"ending_id": "12B",
		"badge_id": "mercy",
		"dossier_variant": "B",
	},
	"desmond": {
		"ending_id": "12C",
		"badge_id": "precision_at_cost",
		"dossier_variant": "C",
	},
	"mixed": {
		"ending_id": "12D",
		"badge_id": "neutralized_split",
		"dossier_variant": "D",
	},
}

var dominant_zone: String = ""
var resolved_outcome: String = ""
var ending_id: String = ""
var badge_ids: Array[String] = []
var dossier_variant: String = ""
var surgery_allocation := {
	"scene": 0,
	"victoria": 0,
	"desmond": 0,
}


func reset_run() -> void:
	dominant_zone = ""
	resolved_outcome = ""
	ending_id = ""
	badge_ids.clear()
	dossier_variant = ""
	surgery_allocation = {
		"scene": 0,
		"victoria": 0,
		"desmond": 0,
	}


func set_dominant_zone(zone_id: String) -> void:
	dominant_zone = zone_id


func set_surgery_allocation(allocation: Dictionary) -> void:
	surgery_allocation = {
		"scene": int(allocation.get("scene", 0)),
		"victoria": int(allocation.get("victoria", 0)),
		"desmond": int(allocation.get("desmond", 0)),
	}


func resolve_f2_outcome() -> void:
	if F2_OUTCOMES.has(dominant_zone):
		set_surgery_allocation({
			"scene": 2 if dominant_zone == "scene" else 0,
			"victoria": 2 if dominant_zone == "victoria" else 0,
			"desmond": 2 if dominant_zone == "desmond" else 0,
		})
		resolved_outcome = dominant_zone
		_apply_f2_outcome(dominant_zone)
		return

	ending_id = ""
	badge_ids.clear()
	dossier_variant = ""
	resolved_outcome = ""
	push_error("GameState.resolve_f2_outcome: unknown dominant zone '%s'" % dominant_zone)


func resolve_surgery_allocation() -> void:
	var scene_points := int(surgery_allocation.get("scene", 0))
	var victoria_points := int(surgery_allocation.get("victoria", 0))
	var desmond_points := int(surgery_allocation.get("desmond", 0))
	var outcome_key := "mixed"

	if scene_points == 2:
		outcome_key = "scene"
	elif victoria_points == 2:
		outcome_key = "victoria"
	elif desmond_points == 2:
		outcome_key = "desmond"

	dominant_zone = outcome_key
	resolved_outcome = outcome_key
	_apply_f2_outcome(outcome_key)


func _apply_f2_outcome(outcome_key: String) -> void:
	var outcome: Dictionary = F2_OUTCOMES.get(outcome_key, {})
	if outcome.is_empty():
		ending_id = ""
		badge_ids.clear()
		dossier_variant = ""
		push_error("GameState._apply_f2_outcome: unknown outcome '%s'" % outcome_key)
		return

	ending_id = outcome["ending_id"]
	badge_ids = [outcome["badge_id"]]
	dossier_variant = outcome["dossier_variant"]
