extends Node
class_name AirSystem

var air_regions := {}

func update_air(provinces: Dictionary) -> void:
    for province_id in provinces.keys():
        var province = provinces[province_id]
        province["air_coverage"] = clamp(float(province.get("air_coverage", 0.0)) + 0.1, 0.0, 10.0)
        provinces[province_id] = province
