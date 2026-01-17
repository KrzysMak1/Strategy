# TASKS

> Duża checklista zgodna z wymaganiami projektu. Używaj jej jako źródła prawdy dla planu pracy.

## Milestone 0 — INFRA (przed rozbudową treści)
- [ ] Utworzyć i utrzymywać `docs/TASKS.md`, `docs/PROGRESS.md`, `docs/KNOWN_ISSUES.md`.
- [ ] Dodać `docs/DATA_SCHEMA.md` (pełny opis JSON).
- [ ] Dodać `docs/MODDING.md`.
- [ ] Dodać `docs/SYSTEMS.md` (architektura + przepływ danych).
- [ ] Spójny Event Bus / sygnały między systemami.
- [ ] Ustandaryzować ID (snake_case) + walidacja w `validate_data.py`.
- [ ] Safe Mode: przy błędach danych uruchomić ekran diagnostyki + wyłączać mody.
- [ ] Wersjonowanie i migracje zapisów.

## Milestone 1 — Scenariusze 1936–1948 + start dla wielu dat
- [ ] `data/scenarios.json` (id, name, start_date, end_date, opis, lista krajów, relacje, sojusze, napięcie świata, wojny, ustawy/polityka, focusy startowe, armie/stockpile/produkcja/research).
- [ ] UI: wybór scenariusza → wybór kraju → start kampanii.
- [ ] GameTime: prawdziwa data, tick dzienny, eventy datowe, sezony.
- [ ] Tryb szybkości (1–5) + pauza + step-day (debug).

## Milestone 2 — Mapa (duża, czytelna, wielowarstwowa)
- [ ] Rozbudować `regions.json` do 600–1500 prowincji.
- [ ] Prowincje: owner, controller, neighbors, terrain, climate, infra, supply, vp, resources, ports/airfields.
- [ ] Map modes: owner, controller, frontlines, supply, infra, resistance, resources (wybór zasobu), air zones, sea zones, influence blocs.
- [ ] Ulepszyć selekcję: tooltip + panel prowincji + skrót do centrum.
- [ ] Opty: cache i aktualizacja tylko przy zmianach.

## Milestone 3 — Polityka, prawa, ideologie
- [ ] PoliticsSystem: ideologie (min. 4), poparcie, stabilność, war_support/war_weariness.
- [ ] Rząd, wybory (demokracje), przewroty/zamachy (niestabilne państwa).
- [ ] Represje vs wolności (trade-off), propaganda jako decyzje.
- [ ] LawsSystem: gospodarka, handel, pobór, prawa pracy/produkcji, konsumpcja cywilna.
- [ ] Tooltipy z efektami i wymaganiami.

## Milestone 4 — Wojsko (rozkazy, front, bitwy, sprzęt, doktryny)
- [ ] Ruch: A*/BFS z kosztami terenu i infra.
- [ ] Kolejka rozkazów, cancel, priorytety.
- [ ] Front: segmenty, przypinanie armii, auto-rozstawienie (AI) + ręczne korekty.
- [ ] Bitwy: org, entrenchment, planning, soft/hard attack, piercing/armor.
- [ ] Pogoda/sezony, teren, fortyfikacje.
- [ ] Straty manpower + sprzęt (stockpile), uzupełnienia zależne od supply i produkcji.
- [ ] Templates dywizji: bataliony + kompanie wsparcia, koszty, wymagania, statystyki.
- [ ] Dowódcy/traits + XP armii + doktryny.
- [ ] Conscription pool + rotacja jednostek.

## Milestone 5 — Powietrze + morze (uproszczone, ale działające)
- [ ] AirSystem: air zones, misje (AS, CAS, interception, strategic bombing).
- [ ] Straty samolotów, produkcja i uzupełnienia.
- [ ] Wpływ na bitwy lądowe.
- [ ] NavalSystem: sea zones, konwoje (handel + supply overseas).
- [ ] Raiding/blockade.
- [ ] UI: panel lotnictwa i marynarki + map mode stref.

## Milestone 6 — Ekonomia (produkcja, budowa, zasoby, handel)
- [ ] Production: linie, efficiency, throughput, priorytety, konwersje.
- [ ] Braki surowców i ich wpływ.
- [ ] Stockpile sprzętu + rozdział na armie.
- [ ] Budowa: kolejka, priorytety regionów.
- [ ] Budynki: fabryki, infra, porty, lotniska, forty, radar (opcjonalnie).
- [ ] Zasoby: stal, ropa, aluminium, guma, tungsten, chrom + handel.
- [ ] Lend-lease (uproszczony) + sankcje/embargo.

## Milestone 7 — Logistyka + okupacja + post-war
- [ ] Supply hubs, porty, railways jako wąskie gardła.
- [ ] Propagacja po infra, truck usage (koszt ciężarówek).
- [ ] Tooltipy supply: źródło, straty, braki.
- [ ] Okupacja: compliance/resistance, sabotaż.
- [ ] Polityka okupacyjna (ustawy) + decyzje.
- [ ] 1945–1948: ReconstructionSystem, demobilizacja, strefy wpływów.
- [ ] Program atomowy/rocket (late game, drogi, ryzykowny).

## Mega content — focus/events/decisions/tech/units
- [ ] Focus trees: min. 16 krajów grywalnych.
- [ ] Mega drzewa (GER, SOV, UK, USA) 80–140 focusów.
- [ ] Duże drzewa (JAP, ITA, FRA, POL, CHI, SPA) 60–100.
- [ ] Pozostałe (ROU, HUN, CZE, SWE, TUR, CAN itd.) 35–80.
- [ ] 3 akty: pre-war, war, post-war.
- [ ] Alternatywne ścieżki (ideologie, sojusze, regionalne wojny).
- [ ] Events: duże łańcuchy pre-war/war/post-war, wybory, cooldowny, wagi.
- [ ] Decisions: propaganda, pobór, inwestycje, reformy, embargo, lend-lease.
- [ ] Technologies: 250–400 techów + blokady datą.
- [ ] Units: 80–150 pozycji (sprzęt + jednostki).

## AI — gra, nie random
- [ ] AI strategiczne: ocena tension, frontów, supply, braków sprzętu.
- [ ] Focus scoring zależny od epoki.
- [ ] Produkcja pod straty i plany.
- [ ] Badania pod doktrynę i teatr działań.
- [ ] AI wojskowe: obrona VP, supply hubs, nie atakuje bez przewagi.
- [ ] AI dyplomatyczne: gwarancje, sojusze, embargo, presja po 1945.
- [ ] Poziomy trudności + modyfikatory.

## Save/Load
- [ ] Autosave + sloty ręczne + nazwy i daty.
- [ ] Atomic save (tmp → rename).
- [ ] save_version + migrator.
- [ ] Zapis ustawień: map mode, UI, prędkość, filtry.

## Modding + tooling
- [ ] Mod loader: base → mod overrides → merge + raport konfliktów.
- [ ] Menedżer modów w menu (enable/disable + kolejność).
- [ ] tools/: lint_data.py, focus_graph_audit.py, event_audit.py, balance_report.py.
- [ ] scenario_builder.py + localization_audit.py.
- [ ] Scenario/Content Editor (Godot).

## Jakość
- [ ] tests/validate_data.py: spójność ID, brak duplikatów, scenariusze, mapa, focus graph.
- [ ] Benchmark: AI vs AI 24 miesiące → CSV.
- [ ] GitHub Actions: validate_data.py + tool audits.

## UX / Polish / Lokalizacja
- [ ] Tooltipy wszędzie (dlaczego zablokowane).
- [ ] Game Log: filtrowanie (dyplomacja, wojna, ekonomia, eventy).
- [ ] Lokalizacja: en + pl (strings.json), fallback, audit narzędzie.
- [ ] UI: spójne marginesy, font, ikonki placeholder (SVG), responsywność.

## Raport końcowy
- [ ] Release notes.
- [ ] Statystyki contentu (scenariusze, prowincje, kraje, focusy, tech, eventy, decyzje, jednostki).
- [ ] Instrukcja uruchomienia (Godot 4.x) + validate_data.py + tools/.
- [ ] Mini tutorial moddingu: scenariusz + kraj + 3 focusy + 1 event + 1 decyzja.
- [ ] Aktualny `docs/KNOWN_ISSUES.md` + niedokończone zadania w `docs/TASKS.md`.
