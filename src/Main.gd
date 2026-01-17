extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var map_controller: MapController = $MapController
@onready var ui_country_label: Label = $CanvasLayer/UI/TopBar/CountryLabel
@onready var ui_date_label: Label = $CanvasLayer/UI/TopBar/DateLabel
@onready var ui_resources_label: Label = $CanvasLayer/UI/TopBar/ResourcesLabel
@onready var ui_focus_label: Label = $CanvasLayer/UI/LeftPanel/FocusLabel
@onready var ui_province_label: Label = $CanvasLayer/UI/RightPanel/ProvinceLabel
@onready var ui_army_label: Label = $CanvasLayer/UI/RightPanel/ArmyLabel
@onready var ui_debug_label: Label = $CanvasLayer/UI/DebugPanel/DebugLabel
@onready var error_banner: Panel = $CanvasLayer/UI/ErrorBanner
@onready var error_banner_label: Label = $CanvasLayer/UI/ErrorBanner/ErrorBannerLabel
@onready var ui_focus_tree: Control = $CanvasLayer/UI/Tabs/FocusTab/ScrollContainer/FocusTreeView
@onready var ui_production_list: ItemList = $CanvasLayer/UI/Tabs/ProductionTab/ProductionList
@onready var ui_research_list: ItemList = $CanvasLayer/UI/Tabs/ResearchTab/TechList
@onready var ui_diplomacy_list: ItemList = $CanvasLayer/UI/Tabs/DiplomacyTab/CountryList
@onready var ui_decision_list: ItemList = $CanvasLayer/UI/Tabs/DecisionsTab/DecisionList
@onready var ui_log: RichTextLabel = $CanvasLayer/UI/Tabs/LogTab/LogText
@onready var event_popup: PopupPanel = $CanvasLayer/UI/EventPopup
@onready var event_text: RichTextLabel = $CanvasLayer/UI/EventPopup/EventText
@onready var event_buttons: VBoxContainer = $CanvasLayer/UI/EventPopup/EventButtons
@onready var data_error_panel: Panel = $CanvasLayer/UI/DataErrorPanel
@onready var data_error_text: RichTextLabel = $CanvasLayer/UI/DataErrorPanel/DataErrorText

var game_state: GameState
var battle_system := BattleSystem.new()

var selected_army_id := ""
var log_buffer: Array = []

const LOG_LIMIT := 50

func _ready() -> void:
    randomize()
    game_state = GameState.new()
    add_child(game_state)
    add_child(battle_system)

    game_state.time_system.connect("ticked", _on_tick)
    game_state.connect("state_updated", _update_ui)
    game_state.logger.entry_added.connect(_on_log_entry)
    map_controller.connect("province_clicked", _on_province_clicked)
    map_controller.setup(game_state.provinces, camera)
    map_controller.set_armies(game_state.armies)
    ui_focus_tree.set("game_state", game_state)
    ui_focus_tree.set("map_controller", map_controller)

    if not game_state.data_errors.is_empty():
        data_error_panel.visible = true
        data_error_text.text = "[b]Błędy danych:[/b]\n" + "\n".join(game_state.data_errors)
        for error in game_state.data_errors:
            game_state.logger.error(error, "Data")

    if ProjectSettings.get_setting("frontline/load_on_start", false):
        game_state.load_state()
        ProjectSettings.set_setting("frontline/load_on_start", false)

    ui_production_list.item_selected.connect(_on_production_selected)
    ui_research_list.item_selected.connect(_on_research_selected)
    ui_diplomacy_list.item_selected.connect(_on_diplomacy_selected)
    ui_decision_list.item_selected.connect(_on_decision_selected)

    _update_ui()

func set_start_context(country_id: String, scenario_id: String) -> void:
    if scenario_id != "":
        game_state.set_scenario(scenario_id)
    if country_id != "":
        game_state.set_selected_country(country_id)

func set_start_country(country_id: String) -> void:
    set_start_context(country_id, "")

func _on_tick(delta_hours: float) -> void:
    game_state.advance_time(int(delta_hours))
    game_state.advance_focus(delta_hours)
    game_state.ai_controller.tick(game_state)
    _advance_armies(delta_hours)
    _resolve_battles()
    _advance_production(delta_hours)
    _advance_research(delta_hours)
    _advance_decisions(delta_hours)
    game_state.supply_system.update_supply(game_state.provinces)
    game_state.air_system.update_air(game_state.provinces)
    game_state.naval_system.update_convoys()
    _trigger_events()
    _update_ui()

func _advance_armies(delta_hours: float) -> void:
    for army_id in game_state.armies.keys():
        var army = game_state.armies[army_id]
        if army.get("path", []).is_empty():
            continue
        army["move_timer"] = army.get("move_timer", 0.0) + delta_hours
        if army["move_timer"] >= 24.0:
            army["move_timer"] = 0.0
            var next_province = army["path"].pop_front()
            army["province_id"] = next_province
        game_state.armies[army_id] = army
    map_controller.set_armies(game_state.armies)

func _resolve_battles() -> void:
    var province_armies := {}
    for army_id in game_state.armies.keys():
        var army = game_state.armies[army_id]
        var province_id = army.get("province_id", "")
        if not province_armies.has(province_id):
            province_armies[province_id] = []
        province_armies[province_id].append(army_id)

    for province_id in province_armies.keys():
        var armies_here = province_armies[province_id]
        if armies_here.size() < 2:
            continue
        var first = game_state.armies[armies_here[0]]
        for idx in range(1, armies_here.size()):
            var other_id = armies_here[idx]
            var other = game_state.armies[other_id]
            if first.get("country_id") == other.get("country_id"):
                continue
            var result = battle_system.resolve_battle(first, other, game_state.units)
            game_state.armies[armies_here[0]] = result["attacker"]
            game_state.armies[other_id] = result["defender"]
            if result["winner"] == "attacker":
                _capture_province(result["attacker"], province_id)
                game_state.armies.erase(other_id)
                _log("%s zdobywa %s" % [result["attacker"].get("name", "Armia"), province_id])
            elif result["winner"] == "defender":
                _log("%s odpiera atak w %s" % [result["defender"].get("name", "Armia"), province_id])

func _capture_province(army: Dictionary, province_id: String) -> void:
    var province = game_state.provinces.get(province_id, {})
    if province.is_empty():
        return
    province["controller"] = army.get("country_id")
    game_state.provinces[province_id] = province

func _advance_production(delta_hours: float) -> void:
    var country_id = game_state.selected_country_id
    game_state.production_system.queues = game_state.production_queues
    game_state.production_system.tick(country_id, game_state.stockpiles, delta_hours)
    game_state.production_queues = game_state.production_system.queues

func _advance_research(delta_hours: float) -> void:
    var country_id = game_state.selected_country_id
    if game_state.research_system.tick(country_id, game_state.technologies, delta_hours):
        _log("Ukończono badania.")

func _advance_decisions(delta_hours: float) -> void:
    var country_id = game_state.selected_country_id
    var state = game_state.decisions_state.get(country_id, {})
    for decision_id in state.keys():
        state[decision_id] = max(0.0, float(state[decision_id]) - delta_hours)
    game_state.decisions_state[country_id] = state

func _trigger_events() -> void:
    if randi() % 2000 != 0:
        return
    var events = game_state.event_system.events
    if events.is_empty():
        return
    var keys = events.keys()
    var event_id = keys[randi() % keys.size()]
    _show_event(events[event_id])

func _on_province_clicked(province_id: String) -> void:
    game_state.set_selected_province(province_id)
    map_controller.set_selected_province(province_id)
    selected_army_id = ""
    for army_id in game_state.armies.keys():
        var army = game_state.armies[army_id]
        if army.get("province_id") == province_id and army.get("country_id") == game_state.selected_country_id:
            selected_army_id = army_id
            break

func _update_ui() -> void:
    var country = game_state.get_country(game_state.selected_country_id)
    ui_country_label.text = "%s | Ideology: %s" % [country.get("name", ""), country.get("ideology", "")]
    ui_date_label.text = "%02d/%02d/%04d" % [game_state.current_day, game_state.current_month, game_state.current_year]
    ui_resources_label.text = "PP: %.1f | Tension: %.0f%% | Civ: %s | Mil: %s" % [game_state.political_power, game_state.world_tension * 100.0, country.get("factories_civilian", 0), country.get("factories_military", 0)]
    var current_focus = game_state.focus_state.get(game_state.selected_country_id, "")
    ui_focus_label.text = "Focus: %s" % (current_focus if current_focus != "" else "(none)")
    var province = game_state.get_province(game_state.selected_province_id)
    if province.is_empty():
        ui_province_label.text = "Select a province"
    else:
        ui_province_label.text = "%s\nOwner: %s\nControl: %s\nInfra: %s\nFactories: %s\nResources: %s\nResistance: %s" % [
            province.get("name", ""),
            province.get("owner", ""),
            province.get("controller", ""),
            province.get("infrastructure", 0),
            province.get("factories", 0),
            province.get("resources", {}).keys(),
            province.get("resistance", 0.0)
        ]
    if selected_army_id != "":
        var army = game_state.armies.get(selected_army_id, {})
        ui_army_label.text = "%s\nOrg: %.0f" % [army.get("name", "Armia"), army.get("organization", 0.0)]
    else:
        ui_army_label.text = "Brak wybranej armii"

    ui_debug_label.text = "Tick: %s | Speed: x%s" % [
        game_state.time_system.hour_accumulator,
        game_state.time_system.speed_levels[game_state.time_system.speed_index]
    ]

    _refresh_lists()
    ui_focus_tree.queue_redraw()

func _refresh_lists() -> void:
    ui_production_list.clear()
    var country_id = game_state.selected_country_id
    for line in game_state.production_queues.get(country_id, []):
        ui_production_list.add_item("%s | Fabryki: %s" % [line.get("equipment", ""), line.get("factories", 0)])

    ui_research_list.clear()
    for tech_id in game_state.technologies.keys():
        ui_research_list.add_item(tech_id)

    ui_diplomacy_list.clear()
    for other_id in game_state.countries.keys():
        if other_id == country_id:
            continue
        ui_diplomacy_list.add_item("%s" % other_id)

    ui_decision_list.clear()
    for decision_id in game_state.decisions.keys():
        ui_decision_list.add_item(decision_id)

func _on_focus_start_pressed() -> void:
    if game_state.focus_state.get(game_state.selected_country_id, "") != "":
        return
    var focus_view = ui_focus_tree
    if focus_view.has_method("start_selected_focus"):
        focus_view.call("start_selected_focus")

func _on_speed_button_pressed(speed_index: int) -> void:
    game_state.time_system.set_speed(speed_index)

func _on_move_button_pressed() -> void:
    if selected_army_id == "" or game_state.selected_province_id == "":
        return
    var path = _find_path(game_state.armies[selected_army_id].get("province_id", ""), game_state.selected_province_id)
    if path.is_empty():
        return
    var army = game_state.armies[selected_army_id]
    army["path"] = path
    game_state.armies[selected_army_id] = army

func _find_path(start_id: String, goal_id: String) -> Array:
    if start_id == goal_id:
        return []
    var queue = [start_id]
    var came_from := {}
    came_from[start_id] = ""
    while queue.size() > 0:
        var current = queue.pop_front()
        if current == goal_id:
            break
        for neighbor in map_controller.get_neighbors(current):
            if not came_from.has(neighbor):
                came_from[neighbor] = current
                queue.append(neighbor)
    if not came_from.has(goal_id):
        return []
    var path = []
    var current = goal_id
    while current != start_id:
        path.push_front(current)
        current = came_from[current]
    return path

func _on_production_selected(_index: int) -> void:
    pass

func _on_research_selected(index: int) -> void:
    var tech_id = ui_research_list.get_item_text(index)
    game_state.research_system.start_research(game_state.selected_country_id, tech_id)

func _on_diplomacy_selected(index: int) -> void:
    var target = ui_diplomacy_list.get_item_text(index)
    if target == "":
        return
    var relation = game_state.diplomacy_system.get_relation(game_state.selected_country_id, target)
    _log("Relacja z %s: %.2f" % [target, relation])

func _on_decision_selected(index: int) -> void:
    var decision_id = ui_decision_list.get_item_text(index)
    var decision = game_state.decisions.get(decision_id, {})
    if decision.is_empty():
        return
    var cooldowns = game_state.decisions_state.get(game_state.selected_country_id, {})
    if float(cooldowns.get(decision_id, 0.0)) > 0.0:
        _log("Decyzja na cooldownie")
        return
    if game_state.political_power < float(decision.get("cost", 25)):
        _log("Brak PP na decyzję")
        return
    game_state.political_power -= float(decision.get("cost", 25))
    _apply_effects(decision.get("effects", {}))
    cooldowns[decision_id] = float(decision.get("cooldown_days", 30)) * 24.0
    game_state.decisions_state[game_state.selected_country_id] = cooldowns
    _log("Decyzja podjęta: %s" % decision_id)

func _apply_effects(effects: Dictionary) -> void:
    for effect_key in effects.keys():
        match effect_key:
            "political_power":
                game_state.political_power += float(effects[effect_key])
            "world_tension":
                game_state.world_tension = clamp(game_state.world_tension + float(effects[effect_key]), 0.0, 1.0)
            "factories":
                var country = game_state.get_country(game_state.selected_country_id)
                country["factories_civilian"] += int(effects[effect_key])
                game_state.countries[game_state.selected_country_id] = country
            "stability":
                var country = game_state.get_country(game_state.selected_country_id)
                country["stability"] = clamp(float(country.get("stability", 0.5)) + float(effects[effect_key]), 0.0, 1.0)
                game_state.countries[game_state.selected_country_id] = country
            "war_support":
                var country = game_state.get_country(game_state.selected_country_id)
                country["war_support"] = clamp(float(country.get("war_support", 0.5)) + float(effects[effect_key]), 0.0, 1.0)
                game_state.countries[game_state.selected_country_id] = country
            _:
                pass

func _show_event(event_data: Dictionary) -> void:
    event_popup.popup_centered()
    event_text.text = "[center][b]%s[/b]\n%s[/center]" % [event_data.get("title", ""), event_data.get("description", "")]
    for child in event_buttons.get_children():
        child.queue_free()
    for option in event_data.get("options", []):
        var button = Button.new()
        button.text = option.get("text", "Opcja")
        button.pressed.connect(func():
            _apply_effects(option.get("effects", {}))
            event_popup.hide()
        )
        event_buttons.add_child(button)

func _log(message: String) -> void:
    game_state.logger.info(message, "Game")

func _on_log_entry(entry: Dictionary) -> void:
    var level = entry.get("level", "INFO")
    var source = entry.get("source", "")
    var message = entry.get("message", "")
    var prefix = "[%s]" % level
    if source != "":
        prefix = "%s [%s]" % [prefix, source]
    log_buffer.append("%s %s" % [prefix, message])
    if log_buffer.size() > LOG_LIMIT:
        log_buffer.pop_front()
    ui_log.text = "\n".join(log_buffer)
    if level == "ERROR":
        _show_error_banner(message)

func _show_error_banner(message: String) -> void:
    error_banner_label.text = "Błąd: %s" % message
    error_banner.visible = true
