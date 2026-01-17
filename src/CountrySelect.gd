extends Control

@onready var scenario_list: ItemList = $CenterContainer/VBoxContainer/ScenarioList
@onready var scenario_details: RichTextLabel = $CenterContainer/VBoxContainer/ScenarioDetails
@onready var list: ItemList = $CenterContainer/VBoxContainer/CountryList
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton

var countries := {}
var scenarios := {}
var scenario_ids: Array = []
var country_ids: Array = []
var selected_scenario_id := ""

func _ready() -> void:
    var loader = DataLoader.new()
    var data = loader.load_all()
    countries = data.get("countries", {})
    scenarios = data.get("scenarios", {})
    scenario_ids = scenarios.keys()
    scenario_ids.sort()
    for scenario_id in scenario_ids:
        var scenario = scenarios[scenario_id]
        scenario_list.add_item("%s (%s)" % [scenario.get("name", ""), scenario_id])
    start_button.pressed.connect(_on_start)
    back_button.pressed.connect(_on_back)
    scenario_list.item_selected.connect(_on_scenario_selected)
    if scenario_ids.is_empty():
        scenario_details.text = "[b]Brak scenariuszy.[/b]"
    else:
        scenario_list.select(0)
        _on_scenario_selected(0)

func _on_start() -> void:
    if list.get_selected_items().is_empty() or selected_scenario_id == "":
        return
    var index = list.get_selected_items()[0]
    var country_id = country_ids[index]
    var game_scene = load("res://src/Main.tscn")
    if game_scene:
        var packed = game_scene
        get_tree().change_scene_to_packed(packed)
        await get_tree().process_frame
        var root = get_tree().current_scene
        if root and root.has_method("set_start_context"):
            root.set_start_context(country_id, selected_scenario_id)

func _on_back() -> void:
    get_tree().change_scene_to_file("res://src/MainMenu.tscn")

func _on_scenario_selected(index: int) -> void:
    if index < 0 or index >= scenario_ids.size():
        return
    selected_scenario_id = scenario_ids[index]
    var scenario = scenarios.get(selected_scenario_id, {})
    var playable = scenario.get("playable_countries", [])
    country_ids = playable.duplicate()
    if country_ids.is_empty():
        country_ids = countries.keys()
        country_ids.sort()
    list.clear()
    for country_id in country_ids:
        var country = countries.get(country_id, {})
        list.add_item("%s (%s)" % [country.get("name", ""), country_id])
    scenario_details.text = "[b]%s[/b]\n%s\nStart: %s → %s\nKraje grywalne: %s" % [
        scenario.get("name", ""),
        scenario.get("description", ""),
        scenario.get("start_date", ""),
        scenario.get("end_date", ""),
        ", ".join(country_ids)
    ]
