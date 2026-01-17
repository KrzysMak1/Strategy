# DATA_SCHEMA

> Opis struktury JSON. Wszystkie dane są **data-driven** w `/data/*.json` i mogą być nadpisywane w `/data/mods/*`.

## `countries.json`
Słownik `country_id -> Country`.

```
Country {
  id: string,
  name: string,
  ideology: string,
  capital: string,
  factories_civilian: int,
  factories_military: int,
  stability: float,
  war_support: float,
  stockpile: { [unit_id]: int },
  starting_production: [ProductionLine],
  research_slots: int
}
```

## `regions.json`
Słownik `province_id -> Province`.

```
Province {
  name: string,
  owner: string,
  controller: string,
  grid: [int, int],
  infrastructure: int,
  factories: int,
  resources: { [resource_id]: int },
  resistance: float
}
```

## `units.json`
Słownik `unit_id -> Unit`.

```
Unit {
  name: string,
  type: string,
  soft_attack: float,
  hard_attack: float,
  defense: float,
  breakthrough: float,
  cost: int
}
```

## `technologies.json`
Słownik `tech_id -> Tech`.

```
Tech {
  name: string,
  description: string,
  cost: float,
  year: int
}
```

## `focus_trees.json`
Słownik `country_id -> FocusTree`.

```
FocusTree {
  name: string,
  nodes: [FocusNode]
}

FocusNode {
  id: string,
  name: string,
  description: string,
  prerequisites: [string],
  time_hours: float,
  effects: { [effect_id]: number }
}
```

## `events.json`
Słownik `event_id -> Event`.

```
Event {
  id: string,
  title: string,
  description: string,
  options: [EventOption]
}
```

## `decisions.json`
Słownik `decision_id -> Decision`.

```
Decision {
  id: string,
  name: string,
  description: string,
  cost: float,
  cooldown: float,
  effects: { [effect_id]: number }
}
```

## `armies.json`
Słownik `army_id -> Army`.

```
Army {
  name: string,
  country_id: string,
  province_id: string,
  unit_id: string,
  organization: float
}
```

## `scenarios.json`
Słownik `scenario_id -> Scenario`.

```
Scenario {
  id: string,
  name: string,
  description: string,
  start_date: "YYYY-MM-DD",
  end_date: "YYYY-MM-DD",
  world_tension: float,
  playable_countries: [string],
  alliances: {
    [alliance_id]: { name: string, members: [string] }
  },
  relations: [ { a: string, b: string, value: float } ],
  wars: [ { attackers: [string], defenders: [string], start_date: "YYYY-MM-DD" } ],
  starting_focuses: { [country_id]: string }
}
```
