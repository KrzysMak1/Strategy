# SYSTEMS

## Przepływ danych
1. `DataLoader` ładuje JSON z `data/` i nadpisuje danymi z `data/mods/*`.
2. `GameState` inicjalizuje systemy i stan gry.
3. `GameTime` emituje ticki, `Main.gd` steruje logiką w pętli.
4. UI odświeża się po sygnale `state_updated`.

## Event Bus
`EventBus` jest centralnym kanałem sygnałów między systemami.

```
EventBus.emit_event(event_id: String, payload: Dictionary)
```

Docelowo systemy (AI, dyplomacja, wydarzenia) publikują zdarzenia, a UI i log je subskrybują.

## Scenariusze
`GameState` stosuje scenariusz na starcie gry:
- ustawia datę startową,
- ustawia world tension,
- ładuje relacje, sojusze i wojny,
- ustawia startowe focusy.

## Safe Mode
Jeśli walidacja danych kończy się błędami po wczytaniu modów:
- `DataLoader` przełącza się na Safe Mode,
- mody są wyłączane,
- lista błędów jest pokazywana w UI.
