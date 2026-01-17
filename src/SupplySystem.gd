extends Node
class_name SupplySystem

var supply_hubs := {}

func update_supply(provinces: Dictionary) -> void:
    for province_id in provinces.keys():
        var province = provinces[province_id]
        province["supply"] = max(0.2, float(province.get("infrastructure", 1)) / 10.0)
        provinces[province_id] = province
