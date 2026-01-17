import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"


def load_json(path: Path):
    return json.loads(path.read_text()) if path.exists() else {}


def test_countries():
    countries = load_json(DATA / "countries.json")
    assert len(countries) >= 8
    for tag, country in countries.items():
        assert country["id"] == tag
        assert "name" in country
        assert "starting_production" in country


def test_regions():
    regions = load_json(DATA / "regions.json")
    assert len(regions) >= 120
    for region in regions.values():
        assert "owner" in region
        assert "grid" in region


def test_focus_trees():
    trees = load_json(DATA / "focus_trees.json")
    assert "GER" in trees
    for tree in trees.values():
        assert "nodes" in tree
        for node in tree["nodes"]:
            assert "id" in node
            assert "name" in node

def test_technologies_units_events():
    technologies = load_json(DATA / "technologies.json")
    units = load_json(DATA / "units.json")
    events = load_json(DATA / "events.json")
    assert len(technologies) >= 60
    assert len(units) >= 20
    assert len(events) >= 80

def test_decisions_armies():
    decisions = load_json(DATA / "decisions.json")
    armies = load_json(DATA / "armies.json")
    assert len(decisions) >= 3
    assert len(armies) >= 8


def test_scenarios():
    scenarios = load_json(DATA / "scenarios.json")
    assert len(scenarios) >= 3
    for scenario_id, scenario in scenarios.items():
        assert scenario["id"] == scenario_id
        assert "name" in scenario
        assert "start_date" in scenario
        assert "end_date" in scenario
        assert "playable_countries" in scenario

if __name__ == "__main__":
    test_countries()
    test_regions()
    test_focus_trees()
    test_technologies_units_events()
    test_decisions_armies()
    test_scenarios()
    print("Data validation passed.")
