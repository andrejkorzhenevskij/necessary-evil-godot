extends Node

const PHASE_ORDER := ["F1", "F2", "F3"]
const FILM_METRIC_MAX := 9
const CONTROL_NEXT_MAX := 4
const CHARACTER_METRIC_MAX := 9
const OUTCOMES := {
	"scene": {
		"ending_id": "12A",
		"badge_id": "escalation",
		"dossier_variant": "A",
		"resolution_label": "SCENE DOMINANT",
		"resolution_summary": "Scene carries the strongest accumulated surgery load and becomes the final consequence carrier.",
	},
	"victoria": {
		"ending_id": "12B",
		"badge_id": "mercy",
		"dossier_variant": "B",
		"resolution_label": "VICTORIA DOMINANT",
		"resolution_summary": "Victoria takes the strongest accumulated surgery load and preserves the run through passage.",
	},
	"desmond": {
		"ending_id": "12C",
		"badge_id": "precision_at_cost",
		"dossier_variant": "C",
		"resolution_label": "DESMOND DOMINANT",
		"resolution_summary": "Desmond carries the strongest accumulated surgery load and keeps the run narrow and controlled.",
	},
	"mixed": {
		"ending_id": "12D",
		"badge_id": "neutralized_split",
		"dossier_variant": "D",
		"resolution_label": "SPLIT LOAD",
		"resolution_summary": "No single carrier holds a unique lead, so the run resolves as a split consequence.",
	},
}

var current_phase := "F1"
var completed_phases: Array[String] = []
var dominant_zone: String = ""
var resolved_outcome: String = ""
var ending_id: String = ""
var current_outcome_id: String = ""
var badge_ids: Array[String] = []
var dossier_variant: String = ""
var resolution_label: String = ""
var resolution_summary: String = ""
var surgery_allocation := {
	"scene": 0,
	"victoria": 0,
	"desmond": 0,
}
var film_depth := 1
var film_oblivion := 0
var film_pressure := 0
var control_next := 2
var desmond_integrity := 5
var desmond_trauma := 0
var victoria_integrity := 5
var victoria_trauma := 0
var leonard_integrity := 5
var leonard_trauma := 0
var gameplay_resume_phase := ""
var gameplay_resume_step_index := 0
var gameplay_resume_label := ""
var snapshot_source_phase := ""
var snapshot_show_explanatory_overlay := false


func reset_run() -> void:
	current_phase = PHASE_ORDER[0]
	completed_phases.clear()
	dominant_zone = ""
	resolved_outcome = ""
	ending_id = ""
	current_outcome_id = ""
	badge_ids.clear()
	dossier_variant = ""
	resolution_label = ""
	resolution_summary = ""
	surgery_allocation = {
		"scene": 0,
		"victoria": 0,
		"desmond": 0,
	}
	film_depth = 1
	film_oblivion = 0
	film_pressure = 0
	control_next = 2
	desmond_integrity = 5
	desmond_trauma = 0
	victoria_integrity = 5
	victoria_trauma = 0
	leonard_integrity = 5
	leonard_trauma = 0
	clear_gameplay_resume()
	clear_snapshot_context()


func apply_debug_preset_f2_desmond() -> void:
	reset_run()
	apply_surgery_result("F1", {
		"scene": 0,
		"victoria": 0,
		"desmond": 2,
	})
	clear_gameplay_resume()
	clear_snapshot_context()


func apply_debug_preset_f3_desmond() -> void:
	reset_run()
	apply_surgery_result("F1", {
		"scene": 0,
		"victoria": 0,
		"desmond": 2,
	})
	apply_surgery_result("F2", {
		"scene": 0,
		"victoria": 1,
		"desmond": 1,
	})
	dominant_zone = "desmond"
	current_outcome_id = "12C"
	clear_gameplay_resume()
	clear_snapshot_context()


func ensure_runtime_phase() -> void:
	if not PHASE_ORDER.has(current_phase):
		current_phase = PHASE_ORDER[0]


func get_phase_index(phase_id: String = current_phase) -> int:
	return PHASE_ORDER.find(phase_id)


func get_next_phase(phase_id: String = current_phase) -> String:
	var phase_index := get_phase_index(phase_id)
	if phase_index == -1:
		return PHASE_ORDER[0]
	if phase_index + 1 >= PHASE_ORDER.size():
		return ""
	return PHASE_ORDER[phase_index + 1]


func apply_surgery_result(phase_id: String, allocation: Dictionary) -> void:
	ensure_runtime_phase()
	if not PHASE_ORDER.has(phase_id):
		push_error("GameState.apply_surgery_result: unknown phase '%s'" % phase_id)
		return

	current_outcome_id = _resolve_outcome_id_from_allocation(allocation)
	_accumulate_surgery_allocation(allocation)
	_apply_surgery_metric_deltas(allocation)

	if not completed_phases.has(phase_id):
		completed_phases.append(phase_id)

	var next_phase := get_next_phase(phase_id)
	if next_phase.is_empty():
		current_phase = ""
		resolve_run_from_allocation()
		return

	current_phase = next_phase


func is_run_complete() -> bool:
	return current_phase.is_empty() and not ending_id.is_empty()


func set_dominant_zone(zone_id: String) -> void:
	dominant_zone = zone_id


func set_surgery_allocation(allocation: Dictionary) -> void:
	surgery_allocation = {
		"scene": int(allocation.get("scene", 0)),
		"victoria": int(allocation.get("victoria", 0)),
		"desmond": int(allocation.get("desmond", 0)),
	}


func resolve_f2_outcome() -> void:
	var outcome_key := dominant_zone if OUTCOMES.has(dominant_zone) else _resolve_outcome_key_from_allocation(surgery_allocation)
	resolved_outcome = outcome_key
	_apply_outcome(outcome_key)


func resolve_surgery_allocation() -> void:
	resolve_run_from_allocation()


func resolve_run_from_allocation() -> void:
	var outcome_key := _resolve_outcome_key_from_allocation(surgery_allocation)
	dominant_zone = outcome_key
	resolved_outcome = outcome_key
	_apply_outcome(outcome_key)


func apply_film_delta(depth_delta: int, oblivion_delta: int, pressure_delta: int) -> void:
	film_depth = clampi(film_depth + depth_delta, 0, FILM_METRIC_MAX)
	film_oblivion = clampi(film_oblivion + oblivion_delta, 0, FILM_METRIC_MAX)
	film_pressure = clampi(film_pressure + pressure_delta, 0, FILM_METRIC_MAX)


func apply_control_next_delta(delta: int) -> void:
	control_next = clampi(control_next + delta, 0, CONTROL_NEXT_MAX)


func apply_character_delta(character_id: String, integrity_delta: int, trauma_delta: int) -> void:
	match character_id:
		"desmond":
			desmond_integrity = clampi(desmond_integrity + integrity_delta, 0, CHARACTER_METRIC_MAX)
			desmond_trauma = clampi(desmond_trauma + trauma_delta, 0, CHARACTER_METRIC_MAX)
		"victoria":
			victoria_integrity = clampi(victoria_integrity + integrity_delta, 0, CHARACTER_METRIC_MAX)
			victoria_trauma = clampi(victoria_trauma + trauma_delta, 0, CHARACTER_METRIC_MAX)
		"leonard":
			leonard_integrity = clampi(leonard_integrity + integrity_delta, 0, CHARACTER_METRIC_MAX)
			leonard_trauma = clampi(leonard_trauma + trauma_delta, 0, CHARACTER_METRIC_MAX)
		_:
			push_error("GameState.apply_character_delta: unknown character '%s'" % character_id)


func get_surgery_pass_outcome(allocation: Dictionary) -> String:
	return _resolve_outcome_key_from_allocation(allocation)


func set_gameplay_resume(phase_id: String, step_index: int) -> void:
	gameplay_resume_phase = phase_id
	gameplay_resume_step_index = maxi(step_index, 0)
	gameplay_resume_label = ""


func set_gameplay_resume_branch(phase_id: String, label_name: String) -> void:
	gameplay_resume_phase = phase_id
	gameplay_resume_step_index = 0
	gameplay_resume_label = label_name.strip_edges()


func peek_gameplay_resume() -> Dictionary:
	return {
		"phase": gameplay_resume_phase,
		"step_index": gameplay_resume_step_index,
		"label": gameplay_resume_label,
	}


func consume_gameplay_resume() -> Dictionary:
	var resume_data := {
		"phase": gameplay_resume_phase,
		"step_index": gameplay_resume_step_index,
		"label": gameplay_resume_label,
	}
	clear_gameplay_resume()
	return resume_data


func clear_gameplay_resume() -> void:
	gameplay_resume_phase = ""
	gameplay_resume_step_index = 0
	gameplay_resume_label = ""


func set_snapshot_context(source_phase: String, show_explanatory_overlay: bool) -> void:
	snapshot_source_phase = source_phase.strip_edges()
	snapshot_show_explanatory_overlay = show_explanatory_overlay


func get_snapshot_context() -> Dictionary:
	return {
		"source_phase": snapshot_source_phase,
		"show_explanatory_overlay": snapshot_show_explanatory_overlay,
	}


func clear_snapshot_context() -> void:
	snapshot_source_phase = ""
	snapshot_show_explanatory_overlay = false


func _accumulate_surgery_allocation(allocation: Dictionary) -> void:
	for zone_id: String in ["scene", "victoria", "desmond"]:
		surgery_allocation[zone_id] = int(surgery_allocation.get(zone_id, 0)) + int(allocation.get(zone_id, 0))


func _apply_surgery_metric_deltas(allocation: Dictionary) -> void:
	var pass_outcome := get_surgery_pass_outcome(allocation)

	match pass_outcome:
		"scene":
			apply_film_delta(2, 1, 2)
			apply_control_next_delta(-1)
			apply_character_delta("leonard", -1, 2)
		"victoria":
			apply_film_delta(1, 0, 1)
			apply_control_next_delta(1)
			apply_character_delta("victoria", 1, 1)
		"desmond":
			apply_film_delta(1, 0, 2)
			apply_control_next_delta(0)
			apply_character_delta("desmond", 1, 2)
		"mixed":
			apply_film_delta(1, 1, 1)
			apply_control_next_delta(0)
			if int(allocation.get("scene", 0)) > 0:
				apply_character_delta("leonard", -1, 1)
			if int(allocation.get("victoria", 0)) > 0:
				apply_character_delta("victoria", 0, 1)
			if int(allocation.get("desmond", 0)) > 0:
				apply_character_delta("desmond", 0, 1)


func _resolve_outcome_key_from_allocation(allocation: Dictionary) -> String:
	var scene_points := int(allocation.get("scene", 0))
	var victoria_points := int(allocation.get("victoria", 0))
	var desmond_points := int(allocation.get("desmond", 0))
	var highest_points := maxi(scene_points, maxi(victoria_points, desmond_points))
	var highest_zones := PackedStringArray()

	for zone_id: String in ["scene", "victoria", "desmond"]:
		if int(allocation.get(zone_id, 0)) == highest_points:
			highest_zones.append(zone_id)

	if highest_points > 0 and highest_zones.size() == 1:
		return highest_zones[0]
	return "mixed"


func _resolve_outcome_id_from_allocation(allocation: Dictionary) -> String:
	var outcome_key := _resolve_outcome_key_from_allocation(allocation)
	var outcome_data: Dictionary = OUTCOMES.get(outcome_key, OUTCOMES["mixed"])
	return str(outcome_data.get("ending_id", "12D"))


func _apply_outcome(outcome_key: String) -> void:
	var outcome: Dictionary = OUTCOMES.get(outcome_key, {})
	if outcome.is_empty():
		ending_id = ""
		badge_ids.clear()
		dossier_variant = ""
		resolution_label = ""
		resolution_summary = ""
		push_error("GameState._apply_outcome: unknown outcome '%s'" % outcome_key)
		return

	ending_id = outcome["ending_id"]
	badge_ids = [outcome["badge_id"]]
	dossier_variant = outcome["dossier_variant"]
	resolution_label = outcome["resolution_label"]
	resolution_summary = outcome["resolution_summary"]
