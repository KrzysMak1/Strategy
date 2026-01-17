extends Control

@onready var new_game_button: Button = $CenterContainer/VBoxContainer/NewGameButton
@onready var load_button: Button = $CenterContainer/VBoxContainer/LoadButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var settings_panel: Panel = $SettingsPanel
@onready var autosave_check: CheckBox = $SettingsPanel/VBoxContainer/AutosaveCheck

func _ready() -> void:
    new_game_button.pressed.connect(_on_new_game)
    load_button.pressed.connect(_on_load)
    settings_button.pressed.connect(_on_settings)
    quit_button.pressed.connect(_on_quit)
    autosave_check.toggled.connect(_on_autosave_toggled)
    autosave_check.button_pressed = ProjectSettings.get_setting("frontline/autosave", true)

func _on_new_game() -> void:
    get_tree().change_scene_to_file("res://src/CountrySelect.tscn")

func _on_load() -> void:
    ProjectSettings.set_setting("frontline/load_on_start", true)
    ProjectSettings.save()
    var game = load("res://src/Main.tscn")
    if game:
        get_tree().change_scene_to_packed(game)

func _on_settings() -> void:
    settings_panel.visible = not settings_panel.visible

func _on_quit() -> void:
    get_tree().quit()

func _on_autosave_toggled(enabled: bool) -> void:
    ProjectSettings.set_setting("frontline/autosave", enabled)
    ProjectSettings.save()
