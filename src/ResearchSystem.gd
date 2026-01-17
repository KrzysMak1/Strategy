extends Node
class_name ResearchSystem

var active_research := {}
var progress := {}

func start_research(country_id: String, tech_id: String) -> void:
    active_research[country_id] = tech_id
    progress[country_id] = 0.0

func tick(country_id: String, techs: Dictionary, hours: float) -> bool:
    if not active_research.has(country_id):
        return false
    var tech_id = active_research[country_id]
    var tech = techs.get(tech_id, {})
    if tech.is_empty():
        return false
    progress[country_id] = progress.get(country_id, 0.0) + hours
    var cost = float(tech.get("cost", 120))
    if progress[country_id] >= cost:
        active_research.erase(country_id)
        progress.erase(country_id)
        return true
    return false
