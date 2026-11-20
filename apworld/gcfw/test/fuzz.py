"""Random-settings seed fuzzer for the GCFW world.

Every fuzz seed number deterministically decides the player count (1-3 GCFW slots) and every player's options, then runs the same pipeline as Archipelago's Main.py in-process:
generate_early -> create_regions -> create_items -> set_rules -> connect_entrances -> generate_basic -> pre_fill -> fill -> post_fill -> progression balancing -> finalize -> accessibility/beatable check -> generate_output -> fill_slot_data (JSON round-trip) -> Universal Tracker regen parity.

A failing seed is fully reproducible from its number: `--repro <seed>` re-runs it in-process with the full traceback, and the failure folder holds a player YAML per slot for reproducing with the regular ArchipelagoGenerate.exe.

Run from the root of an Archipelago SOURCE checkout that has this world linked in as worlds/gcfw:
    python -m worlds.gcfw.test.fuzz --seeds 300 --workers 6
    python -m worlds.gcfw.test.fuzz --repro 1234567
    python -m worlds.gcfw.test.fuzz --seeds 50 --players 3

The same `run_seed` is used by test_fuzz.py so a few random seeds also run as part of the normal unit tests.
"""
from __future__ import annotations

import argparse
import json
import os
import random
import sys
import tempfile
import time
import traceback
from typing import Any, Dict, List, Optional

GAME = "GemCraft: Frostborn Wrath"

# Common (per-game) options worth randomizing. The rest (local_items, start_inventory, plando, item_links, ...) are left at default — they are core-AP features, not GCFW logic.
COMMON_RANDOMIZED = ("accessibility", "progression_balancing")

# Player-count weights: mostly solo (fast), with enough multi-slot seeds to exercise own_world / different_world field token placement and cross-world fill.
PLAYER_WEIGHTS = {1: 60, 2: 25, 3: 15}

# Seeds slower than this are reported as SLOW (still a pass).
SLOW_SECONDS = 120.0
# Seeds still running after this are aborted and reported as a failure (TIGHT if an achievements-off slot is involved).
DEFAULT_TIMEOUT = 300.0


# ---------------------------------------------------------------------------
# Option rolling
# ---------------------------------------------------------------------------

def _roll_value(option_cls, rng: random.Random) -> Any:
    from Options import Choice, OptionSet, Range, Toggle

    if issubclass(option_cls, Range):
        lo, hi = option_cls.range_start, option_cls.range_end
        # Bias towards the extremes — edge values are where generation breaks.
        r = rng.random()
        if r < 0.15:
            return lo
        if r < 0.30:
            return hi
        return rng.randint(lo, hi)
    if issubclass(option_cls, (Choice, Toggle)):
        return option_cls.name_lookup[rng.choice(sorted(option_cls.name_lookup))]
    if issubclass(option_cls, OptionSet) and option_cls.valid_keys:
        keys = sorted(option_cls.valid_keys)
        return sorted(rng.sample(keys, rng.randint(0, len(keys))))
    return None  # leave at default


def roll_player_options(rng: random.Random, players: int) -> Dict[str, Any]:
    """Roll one player's options, then repair the combinations generate_early deliberately rejects (those are covered by test_invariants instead)."""
    from Options import PerGameCommonOptions
    from worlds.AutoWorld import AutoWorldRegister

    world_type = AutoWorldRegister.world_types[GAME]
    common = set(PerGameCommonOptions.type_hints)
    options: Dict[str, Any] = {}
    for name, option_cls in world_type.options_dataclass.type_hints.items():
        if name in common and name not in COMMON_RANDOMIZED:
            continue
        value = _roll_value(option_cls, rng)
        if value is not None:
            options[name] = value

    # Hard/Extreme refuse to generate with Endurance disabled.
    if options.get("difficulty") in ("hard", "extreme") and options.get("disable_endurance") == "true":
        if rng.random() < 0.5:
            options["disable_endurance"] = "false"
        else:
            options["difficulty"] = rng.choice(["easy", "medium"])
    # own_world / different_world need a second slot.
    if players == 1:
        options["field_token_placement"] = "any_world"
    # random_starting_stages = 0 means "use the explicit list", which must be non-empty.
    if options.get("random_starting_stages") == 0 and not options.get("starting_stages"):
        options["starting_stages"] = sorted(rng.sample(["W1", "W2", "W3", "W4"], rng.randint(1, 4)))
    return options


def roll_seed(seed: int, players: Optional[int] = None) -> List[Dict[str, Any]]:
    rng = random.Random(seed)
    n = players or rng.choices(list(PLAYER_WEIGHTS), weights=list(PLAYER_WEIGHTS.values()))[0]
    return [roll_player_options(rng, n) for _ in range(n)]


# ---------------------------------------------------------------------------
# Generation
# ---------------------------------------------------------------------------

class _Stage:
    """Tracks which pipeline stage is running so a failure reports where it happened."""
    def __init__(self) -> None:
        self.name = "setup"
        self.times: Dict[str, float] = {}
        self._t = time.perf_counter()

    def __call__(self, name: str) -> None:
        now = time.perf_counter()
        self.times[self.name] = round(now - self._t, 3)
        self.name, self._t = name, now


def _check_ut_regen(world, slot_data: dict, options: Dict[str, Any]) -> None:
    """Universal Tracker regenerates a solo world from slot_data via interpret_slot_data -> re_gen_passthrough. That rebuild must reproduce the server world's location set and starting state, or the tracker disagrees with the seed."""
    from BaseClasses import CollectionState, MultiWorld
    from argparse import Namespace
    from worlds.AutoWorld import AutoWorldRegister, call_all

    world_type = AutoWorldRegister.world_types[GAME]
    passthrough = world_type.interpret_slot_data(json.loads(json.dumps(slot_data)))
    assert passthrough is not None, "interpret_slot_data returned None (UT would not regen)"

    mw = MultiWorld(1)
    mw.game = {1: GAME}
    mw.player_name = {1: "Tracker"}
    mw.set_seed(None)  # deliberately a DIFFERENT seed: nothing may depend on re-rolling
    mw.re_gen_passthrough = {GAME: passthrough}
    mw.generation_is_fake = True
    args = Namespace()
    for key, option in world_type.options_dataclass.type_hints.items():
        setattr(args, key, {1: option.from_any(options.get(key, option.default))})
    mw.set_options(args)
    mw.state = CollectionState(mw)
    for step in ("generate_early", "create_regions", "create_items", "set_rules"):
        call_all(mw, step)
    ut_world = mw.worlds[1]

    def addressed(w) -> set:
        return {loc.name for loc in w.multiworld.get_locations(w.player) if loc.address is not None}

    real_locs, ut_locs = addressed(world), addressed(ut_world)
    assert real_locs == ut_locs, (
        f"UT regen location set differs: {len(real_locs - ut_locs)} missing in UT "
        f"(e.g. {sorted(real_locs - ut_locs)[:5]}), {len(ut_locs - real_locs)} extra in UT "
        f"(e.g. {sorted(ut_locs - real_locs)[:5]})")
    assert ut_world.start_sids == world.start_sids, f"UT starting stages {ut_world.start_sids} != real {world.start_sids}"
    real_pre = sorted(i.name for i in world.multiworld.precollected_items[world.player])
    ut_pre = sorted(i.name for i in mw.precollected_items[1])
    assert real_pre == ut_pre, f"UT precollected items differ: real={real_pre} ut={ut_pre}"


def build_multiworld(options: List[Dict[str, Any]], seed: Optional[int] = None):
    """Run generate_early .. pre_fill exactly like Main.py, including the local/non-local item cleanup after generate_early and locality_rules after set_rules — test.general.setup_multiworld skips both, which would silently ignore local_items / non_local_items."""
    from test.general import setup_multiworld
    from worlds.AutoWorld import AutoWorldRegister, call_all
    from worlds.generic.Rules import exclusion_rules, locality_rules

    world_type = AutoWorldRegister.world_types[GAME]
    mw = setup_multiworld([world_type] * len(options), steps=("generate_early",), seed=seed, options=options)
    for player in mw.player_ids:
        opts = mw.worlds[player].options
        opts.non_local_items.value -= opts.local_items.value
        opts.non_local_items.value -= set(mw.local_early_items[player])
    if mw.players == 1:
        mw.worlds[1].options.non_local_items.value = set()
        mw.worlds[1].options.local_items.value = set()
    for step in ("create_regions", "create_items", "set_rules"):
        call_all(mw, step)
    for player in mw.player_ids:
        exclusion_rules(mw, player, mw.worlds[player].options.exclude_locations.value)
    if mw.players > 1:
        locality_rules(mw)
    for step in ("connect_entrances", "generate_basic", "pre_fill"):
        call_all(mw, step)
    return mw


def is_tight_failure(result: Dict[str, Any]) -> bool:
    """A fill failure (or timeout) on a seed that is tight by design — accepted, reported separately as TIGHT and not counted as a failure (user decisions, 2026-11-20):
    - some slot has achievements off: it only has the 244 Journey + Wizard stash checks, so fine-grained gating can run out of room;
    - some slot is different_world with per-stage field tokens: all 121 tokens must fit into the OTHER worlds' early spheres, which a small partner can't absorb."""
    if result.get("stage") != "fill":
        return False
    return any(
        o.get("achievement_required_effort") == "off"
        or (o.get("field_token_placement") == "different_world"
            and str(o.get("field_token_granularity", "")).startswith("per_stage"))
        for o in result["options"])


def run_seed(seed: int, players: Optional[int] = None, ut_check: bool = True,
             timeout: Optional[float] = DEFAULT_TIMEOUT) -> Dict[str, Any]:
    """Generate one fuzz seed end to end. Never raises: returns a result dict with ok / stage / error / traceback.

    `timeout` (seconds) aborts a seed that runs too long — AP's swap fill can grind for 20+ minutes on a dead end. It works by interrupting the main thread, so it only applies when called from the main thread (worker processes, pytest)."""
    import _thread
    import threading
    from Fill import balance_multiworld_progression, distribute_items_restrictive
    from worlds.AutoWorld import call_all

    options = roll_seed(seed, players)
    result: Dict[str, Any] = {"seed": seed, "players": len(options), "options": options, "ok": False}
    stage = _Stage()
    t0 = time.perf_counter()
    timed_out = threading.Event()
    timer = None
    if timeout and threading.current_thread() is threading.main_thread():
        timer = threading.Timer(timeout, lambda: (timed_out.set(), _thread.interrupt_main()))
        timer.daemon = True
        timer.start()
    try:
        stage("gen_steps")
        mw = build_multiworld(options, seed)

        stage("fill")
        distribute_items_restrictive(mw)
        call_all(mw, "post_fill")
        if mw.players > 1 and any(mw.worlds[p].options.progression_balancing.value for p in mw.player_ids):
            stage("progression_balancing")
            balance_multiworld_progression(mw)
        stage("finalize")
        call_all(mw, "finalize_multiworld")
        call_all(mw, "pre_output")

        stage("validate_fill")
        unfilled = [loc.name for loc in mw.get_locations() if loc.item is None]
        assert not unfilled, f"{len(unfilled)} unfilled locations, e.g. {unfilled[:5]}"
        assert mw.can_beat_game(mw.state.__class__(mw)), "Seed is not beatable"
        assert mw.fulfills_accessibility(), "Accessibility requirements not met"

        stage("generate_output")
        with tempfile.TemporaryDirectory() as tmp:
            call_all(mw, "generate_output", tmp)

        stage("fill_slot_data")
        slot_datas = {}
        for player in mw.player_ids:
            slot_data = mw.worlds[player].fill_slot_data()
            json.dumps(slot_data)  # must be JSON-serializable for the multidata
            slot_datas[player] = slot_data

        if ut_check:
            stage("ut_regen")
            _check_ut_regen(mw.worlds[1], slot_datas[1], options[0])

        stage("done")
        result["ok"] = True
    except BaseException as exc:  # noqa: BLE001 — report everything, including assertion/fill errors
        if isinstance(exc, KeyboardInterrupt) and not timed_out.is_set():
            raise
        result["stage"] = stage.name
        if timed_out.is_set():
            result["error"] = f"Timeout: still in stage '{stage.name}' after {timeout:.0f}s"
            result["timeout"] = True
        else:
            result["error"] = f"{type(exc).__name__}: {exc}"[:2000]
        result["traceback"] = traceback.format_exc()
        result["tight"] = is_tight_failure(result)
    finally:
        if timer is not None:
            timer.cancel()
    result["seconds"] = round(time.perf_counter() - t0, 2)
    result["stage_times"] = stage.times
    return result


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _settings_text(res: Dict[str, Any]) -> str:
    """Human-readable dump of every slot's rolled settings."""
    lines = []
    for i, opts in enumerate(res["options"], 1):
        lines.append(f"  Player {i}:")
        lines += [f"    {k}: {v}" for k, v in opts.items()]
    return "\n".join(lines)


def _failure_header(res: Dict[str, Any]) -> str:
    kind = "TIGHT (accepted by design)" if res.get("tight") else "FAIL"
    first_error_line = res.get("error", "").splitlines()[0] if res.get("error") else ""
    return (f"seed {res['seed']}  [{kind}]  players={res['players']}  stage={res.get('stage')}  {res['seconds']}s\n"
            f"error: {first_error_line}\n"
            f"repro: python -m worlds.gcfw.test.fuzz --repro {res['seed']}\n"
            f"settings:\n{_settings_text(res)}\n")


def _write_failure(out_dir: str, res: Dict[str, Any]) -> None:
    """One folder per failing seed: error.txt (settings + full traceback) and a player YAML per slot that ArchipelagoGenerate.exe accepts. Real failures go in failures/, accepted tight ones in tight/."""
    import yaml
    fail_dir = os.path.join(out_dir, "tight" if res.get("tight") else "failures", f"seed_{res['seed']}")
    os.makedirs(fail_dir, exist_ok=True)
    with open(os.path.join(fail_dir, "error.txt"), "w", encoding="utf-8") as f:
        f.write(_failure_header(res) + "\ntraceback:\n" + res.get("traceback", ""))
    for i, opts in enumerate(res["options"], 1):
        doc = {"name": f"Fuzz{i}", "game": GAME, GAME: opts}
        with open(os.path.join(fail_dir, f"Fuzz{i}.yaml"), "w", encoding="utf-8") as f:
            yaml.safe_dump(doc, f, sort_keys=False)


def _worker(args):
    seed, players, ut_check, timeout = args
    return run_seed(seed, players, ut_check, timeout)


def main(argv: Optional[List[str]] = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    p.add_argument("--seeds", type=int, default=100, help="number of seeds to generate (default 100)")
    p.add_argument("--start-seed", type=int, default=None, help="first seed number; seeds are start..start+N-1 (default: random)")
    p.add_argument("--workers", type=int, default=max(1, min(8, (os.cpu_count() or 2) - 1)))
    p.add_argument("--players", type=int, default=None, help="force this many GCFW slots per seed (default: weighted 1-3)")
    p.add_argument("--timeout", type=float, default=DEFAULT_TIMEOUT, help=f"abort a seed after this many seconds (default {DEFAULT_TIMEOUT:.0f}, 0 = never)")
    p.add_argument("--no-ut-check", action="store_true", help="skip the Universal Tracker regen parity check")
    p.add_argument("--out", default=None, help="results folder (default: output/gcfw_fuzz/<timestamp>)")
    p.add_argument("--repro", type=int, default=None, help="re-run ONE seed in-process and print its traceback")
    a = p.parse_args(argv)

    if a.repro is not None:
        res = run_seed(a.repro, a.players, not a.no_ut_check, a.timeout or None)
        print(json.dumps({k: v for k, v in res.items() if k != "traceback"}, indent=2))
        if not res["ok"]:
            print(res["traceback"])
        return 0 if res["ok"] else 1

    start = a.start_seed if a.start_seed is not None else random.randrange(1, 2 ** 31)
    out_dir = a.out or os.path.join("output", "gcfw_fuzz", time.strftime("%Y%m%d-%H%M%S"))
    os.makedirs(out_dir, exist_ok=True)
    jobs = [(start + i, a.players, not a.no_ut_check, a.timeout or None) for i in range(a.seeds)]
    run_log = open(os.path.join(out_dir, "run.log"), "w", encoding="utf-8")

    def log(line: str = "") -> None:
        """Print to the console AND append to <out>/run.log, so a run can be read back after the window closes."""
        print(line, flush=True)
        run_log.write(line + "\n")
        run_log.flush()

    log(f"GCFW fuzz {time.strftime('%Y-%m-%d %H:%M:%S')}: {a.seeds} seeds ({start}..{start + a.seeds - 1}), "
        f"{a.workers} workers, timeout {a.timeout:.0f}s -> {os.path.abspath(out_dir)}")

    results: List[Dict[str, Any]] = []
    t0 = time.perf_counter()

    def report(res: Dict[str, Any]) -> None:
        results.append(res)
        tag = "OK  " if res["ok"] else ("TIGHT" if res.get("tight") else "FAIL")
        if res["ok"] and res["seconds"] > SLOW_SECONDS:
            tag = "SLOW"
        line = f"[{len(results):4d}/{a.seeds}] {tag} seed={res['seed']} p={res['players']} {res['seconds']:6.1f}s"
        if not res["ok"]:
            line += f"  @{res['stage']}: {res['error'].splitlines()[0][:200]}"
            _write_failure(out_dir, res)
        log(line)

    if a.workers <= 1:
        for job in jobs:
            report(_worker(job))
    else:
        import concurrent.futures as cf
        with cf.ProcessPoolExecutor(max_workers=a.workers) as pool:
            for fut in cf.as_completed([pool.submit(_worker, job) for job in jobs]):
                report(fut.result())

    fails = [r for r in results if not r["ok"] and not r.get("tight")]
    tight = [r for r in results if not r["ok"] and r.get("tight")]
    times = sorted(r["seconds"] for r in results if r["ok"])
    summary = {
        "seeds": len(results), "passed": len(results) - len(fails) - len(tight), "failed": len(fails),
        "tight_accepted": len(tight), "tight_seeds": [r["seed"] for r in tight],
        "start_seed": start, "wall_seconds": round(time.perf_counter() - t0, 1),
        "median_seconds": times[len(times) // 2] if times else None,
        "max_seconds": times[-1] if times else None,
        "failures_by_stage": {},
        "failures": [{"seed": r["seed"], "players": r["players"], "stage": r["stage"], "error": r["error"]} for r in fails],
    }
    for r in fails:
        summary["failures_by_stage"][r["stage"]] = summary["failures_by_stage"].get(r["stage"], 0) + 1
    with open(os.path.join(out_dir, "summary.json"), "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
    with open(os.path.join(out_dir, "results.jsonl"), "w", encoding="utf-8") as f:
        for r in sorted(results, key=lambda r: r["seed"]):
            f.write(json.dumps({k: v for k, v in r.items() if k != "traceback"}) + "\n")

    # failures.txt: every failing seed with its full settings, real failures first.
    with open(os.path.join(out_dir, "failures.txt"), "w", encoding="utf-8") as f:
        f.write(f"GCFW fuzz {start}..{start + a.seeds - 1}: {len(fails)} FAILED, {len(tight)} TIGHT (accepted)\n")
        for title, group in (("FAILED", fails), ("TIGHT (accepted by design)", tight)):
            f.write(f"\n===== {title}: {len(group)} =====\n")
            for r in sorted(group, key=lambda r: r["seed"]):
                f.write("\n" + _failure_header(r))

    log()
    log(f"PASSED {summary['passed']}/{summary['seeds']}  FAILED {summary['failed']}  "
        f"TIGHT (accepted by design) {summary['tight_accepted']}  "
        f"median {summary['median_seconds']}s  max {summary['max_seconds']}s  wall {summary['wall_seconds']}s")
    for r in fails:
        log(f"  seed {r['seed']} (p={r['players']}) @{r['stage']}: {r['error'].splitlines()[0][:200]}")
    log(f"Results: {os.path.abspath(out_dir)}")
    if fails or tight:
        log(f"Failing seeds + their settings: {os.path.abspath(os.path.join(out_dir, 'failures.txt'))}")
    run_log.close()
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
