# Data Format

## countries.json
```json
{
  "TAG": {
    "id": "TAG",
    "name": "Nazwa",
    "ideology": "democracy|fascism|communism|neutral",
    "color": [0.1, 0.2, 0.3],
    "capital": "prov_x_y",
    "factories_civilian": 10,
    "factories_military": 5,
    "stability": 0.6,
    "war_support": 0.4
  }
}
```

## regions.json
```json
{
  "prov_0_0": {
    "id": "prov_0_0",
    "name": "Region",
    "owner": "TAG",
    "controller": "TAG",
    "owner_color": [0.4, 0.4, 0.4],
    "grid": [0, 0],
    "infrastructure": 3,
    "factories": 1,
    "resources": {"steel": 3},
    "population": 120,
    "resistance": 0.1,
    "supply": 4,
    "air_coverage": 2
  }
}
```

## focus_trees.json
```json
{
  "TAG": {
    "id": "TAG",
    "name": "Drzewko",
    "nodes": [
      {
        "id": "TAG_focus_id",
        "name": "Nazwa focusa",
        "description": "Opis",
        "time_hours": 168,
        "prerequisites": ["OTHER_FOCUS"],
        "effects": {"factories": 1, "political_power": 5}
      }
    ]
  }
}
```

## decisions.json
```json
{
  "decision_id": {
    "id": "decision_id",
    "name": "Nazwa decyzji",
    "description": "Opis",
    "cost": 25,
    "cooldown_days": 30,
    "effects": {"political_power": -5, "factories": 1}
  }
}
```

## armies.json
```json
{
  "ARM_TAG_1": {
    "id": "ARM_TAG_1",
    "name": "1 Armia",
    "country_id": "TAG",
    "province_id": "prov_0_0",
    "units": [{"type": "infantry", "count": 6}],
    "organization": 40.0,
    "path": []
  }
}
```

## technologies.json
```json
{
  "tech_id": {
    "id": "tech_id",
    "name": "Nazwa",
    "category": "infantry|air|navy|industry",
    "year": 1936,
    "cost": 120,
    "effects": {"attack": 0.02}
  }
}
```
