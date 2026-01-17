extends Node
class_name ProductionSystem

var queues := {}

func add_line(country_id: String, equipment_id: String, factories: int) -> void:
    var list = queues.get(country_id, [])
    list.append({"equipment": equipment_id, "factories": factories, "progress": 0.0})
    queues[country_id] = list

func tick(country_id: String, stockpiles: Dictionary, hours: float) -> void:
    var list = queues.get(country_id, [])
    for line in list:
        line["progress"] = line.get("progress", 0.0) + hours * max(1, int(line.get("factories", 1)))
        var cost = float(line.get("cost", 120))
        if line["progress"] >= cost:
            line["progress"] = 0.0
            var equipment = line.get("equipment", "")
            var stock = stockpiles.get(country_id, {})
            stock[equipment] = stock.get(equipment, 0) + 10
            stockpiles[country_id] = stock
    queues[country_id] = list
