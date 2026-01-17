extends Control

@onready var list: ItemList = $CenterContainer/VBoxContainer/CountryList
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton

var countries := {}

func _ready() -> void:
    var loader = DataLoader.new()
    var data = loader.load_all()
    countries = data.get("countries", {})
    var keys = countries.keys()
    keys.sort()
    for country_id in keys:
        var country = countries[country_id]
        list.add_item("%s (%s)" % [country.get("name", ""), country_id])
    start_button.pressed.connect(_on_start)
    back_button.pressed.connect(_on_back)

func _on_start() -> void:
    if list.get_selected_items().is_empty():
        return
    var index = list.get_selected_items()[0]
    var keys = countries.keys()
    keys.sort()
    var country_id = keys[index]
    var game_scene = load("res://src/Main.tscn")
    if game_scene:
        var packed = game_scene
        get_tree().change_scene_to_packed(packed)
        await get_tree().process_frame
        var root = get_tree().current_scene
        if root and root.has_method("set_start_country"):
            root.set_start_country(country_id)

func _on_back() -> void:
    get_tree().change_scene_to_file("res://src/MainMenu.tscn")
