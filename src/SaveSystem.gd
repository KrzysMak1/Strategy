extends Node
class_name SaveSystem

func save(path: String, game_state: GameState) -> void:
    var data = {
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
        "current_day": game_state.current_day,
        "current_month": game_state.current_month,
        "current_year": game_state.current_year
    }
    var dir = DirAccess.open("user://")
    if dir != null:
        if not dir.dir_exists("saves"):
            dir.make_dir("saves")
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(data, "  "))

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
    game_state.current_day = data.get("current_day", game_state.current_day)
    game_state.current_month = data.get("current_month", game_state.current_month)
    game_state.current_year = data.get("current_year", game_state.current_year)
