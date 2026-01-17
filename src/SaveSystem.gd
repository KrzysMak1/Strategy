extends Node
class_name SaveSystem

const SAVE_VERSION := 1

func save(path: String, game_state: GameState) -> void:
    var data = {
        "save_version": SAVE_VERSION,
        "countries": game_state.countries,
        "provinces": game_state.provinces,
        "units": game_state.units,
        "armies": game_state.armies,
        "stockpiles": game_state.stockpiles,
        "production_queues": game_state.production_queues,
        "research_slots": game_state.research_slots,
        "decisions_state": game_state.decisions_state,
        "relations": game_state.relations,
        "wars": game_state.wars,
        "alliances": game_state.alliances,
        "selected_country_id": game_state.selected_country_id,
        "selected_province_id": game_state.selected_province_id,
        "world_tension": game_state.world_tension,
        "political_power": game_state.political_power,
        "focus_state": game_state.focus_state,
        "focus_progress": game_state.focus_progress,
        "scenario_id": game_state.scenario_id,
        "current_day": game_state.current_day,
        "current_month": game_state.current_month,
        "current_year": game_state.current_year
    }
    _ensure_save_dir()
    _atomic_write(path, JSON.stringify(data, "  "))

func load(path: String, game_state: GameState) -> void:
    if not FileAccess.file_exists(path):
        return
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return
    var content = file.get_as_text()
    var data = JSON.parse_string(content)
    if typeof(data) != TYPE_DICTIONARY:
        return
    var version = int(data.get("save_version", 0))
    if version < SAVE_VERSION:
        data = _migrate_save(data, version)
    game_state.countries = data.get("countries", game_state.countries)
    game_state.provinces = data.get("provinces", game_state.provinces)
    game_state.units = data.get("units", game_state.units)
    game_state.armies = data.get("armies", game_state.armies)
    game_state.stockpiles = data.get("stockpiles", game_state.stockpiles)
    game_state.production_queues = data.get("production_queues", game_state.production_queues)
    game_state.research_slots = data.get("research_slots", game_state.research_slots)
    game_state.decisions_state = data.get("decisions_state", game_state.decisions_state)
    game_state.relations = data.get("relations", game_state.relations)
    game_state.wars = data.get("wars", game_state.wars)
    game_state.alliances = data.get("alliances", game_state.alliances)
    game_state.selected_country_id = data.get("selected_country_id", game_state.selected_country_id)
    game_state.selected_province_id = data.get("selected_province_id", game_state.selected_province_id)
    game_state.world_tension = data.get("world_tension", game_state.world_tension)
    game_state.political_power = data.get("political_power", game_state.political_power)
    game_state.focus_state = data.get("focus_state", game_state.focus_state)
    game_state.focus_progress = data.get("focus_progress", game_state.focus_progress)
    game_state.scenario_id = data.get("scenario_id", game_state.scenario_id)
    game_state.current_day = data.get("current_day", game_state.current_day)
    game_state.current_month = data.get("current_month", game_state.current_month)
    game_state.current_year = data.get("current_year", game_state.current_year)

func _ensure_save_dir() -> void:
    var dir = DirAccess.open("user://")
    if dir != null and not dir.dir_exists("saves"):
        dir.make_dir("saves")

func _atomic_write(path: String, payload: String) -> void:
    var tmp_path = "%s.tmp" % path
    var file = FileAccess.open(tmp_path, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(payload)
    file.flush()
    file.close()
    var dir = DirAccess.open("user://")
    if dir != null:
        var from_path = tmp_path.replace("user://", "")
        var to_path = path.replace("user://", "")
        dir.rename(from_path, to_path)

func _migrate_save(data: Dictionary, version: int) -> Dictionary:
    var migrated = data.duplicate(true)
    if version < 1:
        migrated["save_version"] = SAVE_VERSION
        if not migrated.has("scenario_id"):
            migrated["scenario_id"] = ""
    return migrated
