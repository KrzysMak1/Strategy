extends Node
class_name DiplomacySystem

var relations := {}

func set_relation(a: String, b: String, value: float) -> void:
    relations["%s_%s" % [a, b]] = value

func get_relation(a: String, b: String) -> float:
    return relations.get("%s_%s" % [a, b], 0.0)
