# Frontline Dominion

Strategiczna gra RTS/Grand Strategy osadzona w latach 1936–1948. Projekt jest data-driven i oparty o Godot 4.x (GDScript) z renderem 2D.

## Uruchomienie
1. Zainstaluj Godot 4.x.
2. Otwórz projekt w `project.godot`.
3. Uruchom scenę `MainMenu` i wybierz kraj.

## Sterowanie
- **WASD**: przesuwanie mapy
- **Scroll**: zoom
- **Klik** na prowincję: panel informacji
- **1-5**: tryby mapy (polityczny, infrastruktura, zaopatrzenie, opór, lotnictwo)

## Walidacja danych
Uruchom:
```bash
python tests/validate_data.py
```

## Dodanie focusa
1. Otwórz `data/focus_trees.json`.
2. Dodaj nowy wpis w `nodes` dla danego kraju:
   ```json
   {"id": "TAG_focus", "name": "Nazwa", "description": "Opis", "time_hours": 168, "prerequisites": [], "effects": {"political_power": 5}}
   ```
3. Uruchom grę ponownie.

## Dodanie kraju
1. Dodaj wpis w `data/countries.json`.
2. Dodaj przynajmniej jedną prowincję w `data/regions.json` (pole `owner`).
3. Dodaj drzewko w `data/focus_trees.json`.

## Moddowanie
Utwórz folder `data/mods/<nazwa_modu>` i dodaj pliki `countries.json`, `regions.json`, `focus_trees.json`.

## Zapis i odczyt
- Autozapis co 2 minuty do `user://saves/autosave.json` (można wyłączyć w menu ustawień).
- Ręczne wywołanie dostępne w kodzie (`GameState.save_state()` / `GameState.load_state()`).

## Known Issues
- AI i dyplomacja są uproszczone i będą rozwijane w kolejnych wersjach.
- Fokusy mają generowane opisy, wymagają dalszej narracyjnej redakcji.
