"""Lightweight phase + per-rule timing for fill diagnostics.

All timing output goes to stderr with a `[gcfw timing]` prefix. Easy to grep
for in Archipelago's generation log. Set GCFW_TIMING=0 in env to silence.

Remove this module + its imports once perf work is done.
"""
from __future__ import annotations

import os
import sys
import time
from collections import defaultdict
from contextlib import contextmanager
from typing import Callable

ENABLED = os.environ.get("GCFW_TIMING", "1") != "0"


def log(msg: str) -> None:
    if ENABLED:
        print(f"[gcfw timing] {msg}", file=sys.stderr, flush=True)


@contextmanager
def phase(label: str):
    """Time a code block. Usage: `with phase("set_rules"): ...`."""
    if not ENABLED:
        yield
        return
    t0 = time.perf_counter()
    try:
        yield
    finally:
        dt = time.perf_counter() - t0
        log(f"{label}: {dt*1000:.1f} ms")


# ---------------------------------------------------------------------------
# Per-rule call counter — wraps an access_rule lambda to record how many
# times Archipelago's fill calls it. Top callers are usually the bottleneck.
# ---------------------------------------------------------------------------

_call_counts: dict[str, int] = defaultdict(int)
_call_times: dict[str, float] = defaultdict(float)


def wrap_rule(label: str, fn: Callable) -> Callable:
    """Wrap an access_rule with a counter. Returns the original `fn` unwrapped
    when timing is disabled."""
    if not ENABLED:
        return fn

    def wrapped(state):
        t0 = time.perf_counter()
        try:
            return fn(state)
        finally:
            _call_counts[label] += 1
            _call_times[label] += time.perf_counter() - t0
    return wrapped


def report_top_rules(top_n: int = 30) -> None:
    """Dump the top-N rules by total time. Call from fill_slot_data."""
    if not ENABLED or not _call_counts:
        return
    log(f"top {top_n} rules by total eval time:")
    log(f"  {'calls':>10}  {'total_ms':>10}  {'avg_us':>9}  label")
    rows = sorted(_call_times.items(), key=lambda kv: -kv[1])[:top_n]
    for label, total_s in rows:
        n = _call_counts[label]
        avg_us = (total_s / n) * 1e6 if n else 0
        log(f"  {n:>10}  {total_s*1000:>10.1f}  {avg_us:>9.1f}  {label}")
    grand = sum(_call_times.values())
    grand_calls = sum(_call_counts.values())
    log(f"all rules combined: {grand_calls} calls, {grand*1000:.1f} ms total")


def reset() -> None:
    _call_counts.clear()
    _call_times.clear()
