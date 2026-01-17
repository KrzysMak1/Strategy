extends Node
class_name Army

var id := ""
var country_id := ""
var units := []
var location := ""
var experience := 0.0
var commander := ""

func move_to(province_id: String) -> void:
    location = province_id
