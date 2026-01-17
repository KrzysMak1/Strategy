extends Node
class_name BattleSystem

func resolve_battle(attacker: Dictionary, defender: Dictionary, units: Dictionary) -> Dictionary:
    var atk_power = _army_attack(attacker, units)
    var def_power = _army_defense(defender, units)
    var atk_org = attacker.get("organization", 30.0)
    var def_org = defender.get("organization", 30.0)

    def_org -= atk_power * 0.05
    atk_org -= def_power * 0.03

    attacker["organization"] = max(atk_org, 0.0)
    defender["organization"] = max(def_org, 0.0)

    var result := {
        "attacker": attacker,
        "defender": defender,
        "winner": ""
    }

    if defender["organization"] <= 0.0:
        result["winner"] = "attacker"
    elif attacker["organization"] <= 0.0:
        result["winner"] = "defender"

    return result

func _army_attack(army: Dictionary, units: Dictionary) -> float:
    var total = 0.0
    for unit in army.get("units", []):
        var template = units.get(unit.get("type", ""), {})
        total += float(template.get("attack", 1)) * float(unit.get("count", 1))
    return total

func _army_defense(army: Dictionary, units: Dictionary) -> float:
    var total = 0.0
    for unit in army.get("units", []):
        var template = units.get(unit.get("type", ""), {})
        total += float(template.get("defense", 1)) * float(unit.get("count", 1))
    return total
