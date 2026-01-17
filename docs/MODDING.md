# MODDING

## Struktura
- Bazowe dane: `res://data/*.json`
- Mody: `res://data/mods/<nazwa_moda>/*.json`
- Ładowanie: base → mod overrides (merge/override po kluczu).

## Nadpisywanie danych
Każdy plik JSON w modzie może nadpisać lub dodać wpisy:
- `countries.json`, `regions.json`, `focus_trees.json`, `decisions.json`, `armies.json`, `scenarios.json`.

Przykład (mod dodaje nowy scenariusz):

```json
{
  "custom_scenario": {
    "id": "custom_scenario",
    "name": "Mój start",
    "description": "Start testowy",
    "start_date": "1937-01-01",
    "end_date": "1948-12-31",
    "world_tension": 0.2,
    "playable_countries": ["GER"],
    "alliances": {},
    "relations": [],
    "wars": [],
    "starting_focuses": {
      "GER": "GER_01"
    }
  }
}
```

## Safe Mode
Jeśli walidacja danych wykryje błędy po wczytaniu modów:
- gra uruchamia się w Safe Mode,
- mody są wyłączane,
- lista błędów pojawia się na panelu diagnostycznym.

## Porady
- Utrzymuj spójne ID i nie kasuj wpisów bazowych, jeśli nie jest to wymagane.
- Testuj `tests/validate_data.py` przed grą.
