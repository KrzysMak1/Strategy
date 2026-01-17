extends Node
class_name GameState

signal state_updated

var data_loader: DataLoader
var time_system: GameTime

var countries := {}
var provinces := {}
var units := {}
var focus_trees := {}
var technologies := {}
var events := {}
var decisions := {}

var selected_country_id := ""
var selected_province_id := ""

var world_tension := 0.05
var political_power := 120.0
var difficulty := "normal"
var current_day := 1
var current_month := 1
var current_year := 1936

var focus_state := {}
var focus_progress := {}
var autosave_timer: Timer

var save_system := SaveSystem.new()
var production_system := ProductionSystem.new()
var research_system := ResearchSystem.new()
var diplomacy_system := DiplomacySystem.new()
var supply_system := SupplySystem.new()
var air_system := AirSystem.new()
var naval_system := NavalSystem.new()
var event_system := EventSystem.new()
var decision_system := DecisionSystem.new()
var ai_controller := AIController.new()
var logger := Logger.new()

var armies := {}
var stockpiles := {}
var production_queues := {}
var research_slots := {}
var decisions_state := {}
var relations := {}
var wars := []
var alliances := {}
var data_errors := []

func _ready() -> void:
    data_loader = DataLoader.new()
    time_system = GameTime.new()
    add_child(time_system)
    autosave_timer = Timer.new()
    autosave_timer.wait_time = 120.0
    autosave_timer.autostart = true
    autosave_timer.one_shot = false
    autosave_timer.connect("timeout", _on_autosave)
    add_child(autosave_timer)
    add_child(logger)
    add_child(production_system)
    add_child(research_system)
    add_child(diplomacy_system)
    add_child(supply_system)
    add_child(air_system)
    add_child(naval_system)
    add_child(event_system)
    add_child(decision_system)
    add_child(ai_controller)
    _load_data()

func _load_data() -> void:
    var data = data_loader.load_all()
    data_errors = data_loader.errors.duplicate()
    countries = data.get("countries", {})
    provinces = data.get("provinces", {})
    units = data.get("units", {})
    focus_trees = data.get("focus_trees", {})
    armies = data.get("armies", {})
    technologies = data.get("technologies", {})
    events = data.get("events", {})
    decisions = data.get("decisions", {})
    decision_system.load_decisions(data.get("decisions", {}))
    event_system.load_events(data.get("events", {}))
    selected_country_id = countries.keys()[0] if countries.size() > 0 else ""
    _initialize_country_state()
    emit_signal("state_updated")

func _initialize_country_state() -> void:
    for country_id in countries.keys():
        var country = countries[country_id]
        stockpiles[country_id] = country.get("stockpile", {}).duplicate(true)
        production_queues[country_id] = country.get("starting_production", []).duplicate(true)
        research_slots[country_id] = country.get("research_slots", 2)
        decisions_state[country_id] = {}
        relations[country_id] = {}
        focus_state[country_id] = ""
        focus_progress[country_id] = 0.0
    for a in countries.keys():
        for b in countries.keys():
            if a == b:
                continue
            diplomacy_system.set_relation(a, b, 0.0)

func get_country(country_id: String) -> Dictionary:
    return countries.get(country_id, {})

func get_province(province_id: String) -> Dictionary:
    return provinces.get(province_id, {})

func set_selected_province(province_id: String) -> void:
    selected_province_id = province_id
    emit_signal("state_updated")

func set_selected_country(country_id: String) -> void:
    selected_country_id = country_id
    emit_signal("state_updated")

func advance_focus(delta_hours: float) -> void:
    for country_id in focus_state.keys():
        var focus_id = focus_state[country_id]
        if focus_id == "":
            continue
        var focus_data = data_loader.get_focus(focus_id)
        if focus_data.is_empty():
            focus_state[country_id] = ""
            focus_progress[country_id] = 0.0
            continue
        focus_progress[country_id] += delta_hours
        if focus_progress[country_id] >= float(focus_data.get("time_hours", 168)):
            _apply_focus_effects(focus_data, country_id)
            focus_state[country_id] = ""
            focus_progress[country_id] = 0.0
            emit_signal("state_updated")

func start_focus(focus_id: String) -> void:
    if focus_state.get(selected_country_id, "") != "":
        return
    focus_state[selected_country_id] = focus_id
    focus_progress[selected_country_id] = 0.0
    emit_signal("state_updated")

func _apply_focus_effects(focus_data: Dictionary, country_id: String) -> void:
    var effects = focus_data.get("effects", {})
    for effect_key in effects.keys():
        match effect_key:
            "political_power":
                if country_id == selected_country_id:
                    political_power += float(effects[effect_key])
            "world_tension":
                world_tension = clamp(world_tension + float(effects[effect_key]), 0.0, 1.0)
            "factories":
                var factories = int(effects[effect_key])
                var country = get_country(country_id)
                country["factories_civilian"] += factories
                countries[country_id] = country
            "stability":
                var country = get_country(country_id)
                country["stability"] = clamp(float(country.get("stability", 0.5)) + float(effects[effect_key]), 0.0, 1.0)
                countries[country_id] = country
            "war_support":
                var country = get_country(country_id)
                country["war_support"] = clamp(float(country.get("war_support", 0.5)) + float(effects[effect_key]), 0.0, 1.0)
                countries[country_id] = country
            _:
                pass
    emit_signal("state_updated")

func save_state(path: String = "user://saves/autosave.json") -> void:
    save_system.save(path, self)

func load_state(path: String = "user://saves/autosave.json") -> void:
    save_system.load(path, self)
    emit_signal("state_updated")

func _on_autosave() -> void:
    var autosave_enabled = ProjectSettings.get_setting("frontline/autosave", true)
    if autosave_enabled:
        save_state()

func advance_time(hours: int) -> void:
    for _i in range(hours):
        current_day += 1
        if current_day > 30:
            current_day = 1
            current_month += 1
            if current_month > 12:
                current_month = 1
                current_year += 1

func get_neighbors(province_id: String) -> Array:
    var province = provinces.get(province_id, {})
    if province.is_empty():
        return []
    var grid = province.get("grid", [0, 0])
    var neighbors = []
    var offsets = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
    for offset in offsets:
        var check = Vector2i(grid[0] + offset.x, grid[1] + offset.y)
        for candidate_id in provinces.keys():
            var candidate = provinces[candidate_id]
            var candidate_grid = candidate.get("grid", [0, 0])
            if candidate_grid[0] == check.x and candidate_grid[1] == check.y:
                neighbors.append(candidate_id)
                break
    return neighbors
