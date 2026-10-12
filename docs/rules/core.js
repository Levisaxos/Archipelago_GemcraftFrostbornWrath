// GCFW Rules Viewer — core: Python-literal parsing, tag vocabulary, validation, export.
// Works in the browser (window.RulesCore) and in Node (module.exports) so the export round-trip can be tested headless.
(function (root) {
  "use strict";

  // ------------------------------------------------------------------ //
  // Python literal parser (dict / list / tuple / set / str / num / bool / None)
  // Records source offsets for dict entries so unchanged text can be spliced back verbatim on export.
  // ------------------------------------------------------------------ //
  function PyParser(src) {
    this.s = src;
    this.i = 0;
  }
  PyParser.prototype.ws = function () {
    var s = this.s;
    for (;;) {
      var c = s[this.i];
      if (c === " " || c === "\t" || c === "\r" || c === "\n" || c === "\\" && (s[this.i + 1] === "\n" || s[this.i + 1] === "\r")) {
        this.i++;
      } else if (c === "#") {
        while (this.i < s.length && s[this.i] !== "\n") this.i++;
      } else {
        return;
      }
    }
  };
  PyParser.prototype.fail = function (msg) {
    var line = this.s.slice(0, this.i).split("\n").length;
    throw new Error(msg + " (line " + line + ")");
  };
  PyParser.prototype.value = function () {
    this.ws();
    var s = this.s, c = s[this.i];
    if (c === "{") return this.braces();
    if (c === "[") return this.seq("[", "]").items;
    if (c === "(") {
      var r = this.seq("(", ")");
      return r.items;
    }
    if (c === '"' || c === "'" || /[rRuU]/.test(c) && (s[this.i + 1] === '"' || s[this.i + 1] === "'")) {
      var out = this.str();
      // implicit concatenation of adjacent string literals
      for (;;) {
        var save = this.i;
        this.ws();
        var d = s[this.i];
        if (d === '"' || d === "'") out += this.str();
        else { this.i = save; break; }
      }
      return out;
    }
    var m = /^-?(?:\d[\d_]*)(?:\.\d+)?(?:[eE][-+]?\d+)?/.exec(s.slice(this.i, this.i + 40));
    if (m) {
      this.i += m[0].length;
      return Number(m[0].replace(/_/g, ""));
    }
    m = /^[A-Za-z_][A-Za-z0-9_]*/.exec(s.slice(this.i, this.i + 60));
    if (m) {
      var w = m[0];
      this.i += w.length;
      if (w === "True") return true;
      if (w === "False") return false;
      if (w === "None") return null;
      this.ws();
      if ((w === "frozenset" || w === "set" || w === "tuple" || w === "list") && s[this.i] === "(") {
        this.i++;
        this.ws();
        var inner = s[this.i] === ")" ? [] : this.value();
        this.ws();
        if (s[this.i] !== ")") this.fail("expected ')' after " + w);
        this.i++;
        if (inner && inner.__set) return inner.items;
        return inner;
      }
      this.fail("unsupported expression '" + w + "'");
    }
    this.fail("unexpected character '" + c + "'");
  };
  PyParser.prototype.str = function () {
    var s = this.s;
    if (/[rRuU]/.test(s[this.i])) this.i++;
    var q = s[this.i];
    var triple = s.substr(this.i, 3) === q + q + q;
    this.i += triple ? 3 : 1;
    var out = "";
    for (;;) {
      if (this.i >= s.length) this.fail("unterminated string");
      var c = s[this.i];
      if (triple ? s.substr(this.i, 3) === q + q + q : c === q) {
        this.i += triple ? 3 : 1;
        return out;
      }
      if (c === "\\") {
        var n = s[this.i + 1];
        this.i += 2;
        var map = { n: "\n", t: "\t", r: "\r", "\\": "\\", "'": "'", '"': '"', "0": "\0" };
        if (n in map) out += map[n];
        else if (n === "u") { out += String.fromCharCode(parseInt(s.substr(this.i, 4), 16)); this.i += 4; }
        else if (n === "x") { out += String.fromCharCode(parseInt(s.substr(this.i, 2), 16)); this.i += 2; }
        else if (n === "\n") { /* line continuation */ }
        else out += "\\" + n;
        continue;
      }
      out += c;
      this.i++;
    }
  };
  PyParser.prototype.seq = function (open, close) {
    this.i++;
    var items = [];
    for (;;) {
      this.ws();
      if (this.s[this.i] === close) { this.i++; return { items: items }; }
      items.push(this.value());
      this.ws();
      if (this.s[this.i] === ",") this.i++;
      else if (this.s[this.i] !== close) this.fail("expected ',' or '" + close + "'");
    }
  };
  // Dict (with offsets) or set literal.
  PyParser.prototype.braces = function () {
    var s = this.s;
    var start = this.i;
    this.i++;
    var dict = null, set = null;
    var entries = [];
    for (;;) {
      this.ws();
      if (s[this.i] === "}") { this.i++; break; }
      var keyStart = this.i;
      var k = this.value();
      this.ws();
      if (s[this.i] === ":" && set === null) {
        dict = dict || {};
        this.i++;
        this.ws();
        var valueStart = this.i;
        var v = this.value();
        var valueEnd = this.i;
        dict[k] = v;
        entries.push({ key: k, keyStart: keyStart, valueStart: valueStart, valueEnd: valueEnd });
      } else {
        set = set || [];
        set.push(k);
      }
      this.ws();
      if (s[this.i] === ",") this.i++;
      else if (s[this.i] !== "}") this.fail("expected ',' or '}'");
    }
    if (set) return { __set: true, items: set };
    dict = dict || {};
    Object.defineProperty(dict, "__entries", { value: entries, enumerable: false });
    Object.defineProperty(dict, "__span", { value: [start, this.i], enumerable: false });
    return dict;
  };

  // Find `name = <literal>` at top level (column 0) and parse it. Returns undefined when absent.
  function findAssign(src, name) {
    var re = new RegExp("^" + name.replace(/[$]/g, "\\$") + "\\s*(?::[^=\\n]+)?=\\s*", "m");
    var m = re.exec(src);
    if (!m) return undefined;
    var p = new PyParser(src);
    p.i = m.index + m[0].length;
    var v = p.value();
    if (v && v.__set) v = v.items;
    return v;
  }

  function moduleDocstring(src) {
    var m = /^\s*(?:#[^\n]*\n\s*)*("""|''')([\s\S]*?)\1/.exec(src);
    return m ? m[2].replace(/^\r?\n/, "") : "";
  }

  // ------------------------------------------------------------------ //
  // Vocabulary — built from requirement_tokens.py, rulesdata_settings.py and rules.py
  // ------------------------------------------------------------------ //
  var FALLBACK_SPECIAL_COUNTERS = ["min_wl", "fieldToken", "talismanRow", "talismanColumn", "skillPoints"];

  function buildVocab(files, levels, stages, warnings) {
    var rt = files["requirement_tokens.py"] || "";
    var st = files["rulesdata_settings.py"] || "";
    var rules = files["rules.py"] || "";
    function need(src, name, file, fallback) {
      var v;
      try { v = findAssign(src, name); } catch (e) { warnings.push(file + ": could not parse " + name + " — " + e.message); }
      if (v === undefined) {
        if (fallback !== undefined) warnings.push(file + ": " + name + " not found — using built-in fallback");
        else warnings.push(file + ": " + name + " not found");
        return fallback;
      }
      return v;
    }
    var vocab = {};
    vocab.skills = need(rt, "skill_prefix_map", "requirement_tokens.py", {});
    vocab.traits = need(rt, "trait_prefix_map", "requirement_tokens.py", {});
    vocab.elements = need(rt, "element_prefix_map", "requirement_tokens.py", {});
    vocab.modes = need(rt, "mode_tokens", "requirement_tokens.py", []);
    vocab.levelStats = need(rt, "level_stat_counters", "requirement_tokens.py", {});

    // skill_counter_pools mirrors the build loop at the bottom of requirement_tokens.py.
    var groups = need(st, "skill_groups", "rulesdata_settings.py", {});
    var cats = need(st, "game_skills_categories", "rulesdata_settings.py", {});
    var pools = {}, poolDesc = {};
    Object.keys(groups).forEach(function (n) {
      pools[n] = groups[n].members.map(function (m) { return m + " Skill"; });
      poolDesc[n] = groups[n].description || "";
    });
    Object.keys(cats).forEach(function (n) {
      var suffix = n === "BattleTraits" ? " Battle Trait" : " Skill";
      var items = cats[n].members.map(function (m) { return m + suffix; });
      pools[n] = items;
      pools[n[0].toLowerCase() + n.slice(1)] = items;
      poolDesc[n] = poolDesc[n[0].toLowerCase() + n.slice(1)] = cats[n].description || "";
    });
    var all = (pools.GemSkills || []).concat(pools.OtherSkills || []);
    pools.skills = pools.Skills = all;
    poolDesc.skills = poolDesc.Skills = "The 24 in-game skills (gem skills + other skills, NOT battle traits)";
    vocab.pools = pools;
    vocab.poolDesc = poolDesc;

    // rules.py-only tables
    var frag = /_TALISMAN_FRAGMENT_COUNTERS[^=]*=\s*\{([\s\S]*?)\n\}/.exec(rules);
    vocab.talismanCounters = frag ? (frag[1].match(/"(\w+)"\s*:/g) || []).map(function (x) { return x.slice(1, x.indexOf('"', 1)); }) : [];
    if (!frag) warnings.push("rules.py: _TALISMAN_FRAGMENT_COUNTERS not found");
    vocab.talismanFloor = need(rules, "_TALISMAN_FRAGMENTS_TOKEN_FLOOR", "rules.py", {});
    vocab.talismanProps = need(rules, "_TALISMAN_PROPERTY_TOKENS", "rules.py", {});
    vocab.stubElements = need(rules, "_STUB_ELEMENTS", "rules.py", []);
    vocab.gemTokens = need(rules, "_GEM_TOKEN_TO_GEM_NAME", "rules.py", {});
    vocab.interactSkill = need(rules, "_ELEMENT_INTERACT_SKILL", "rules.py", {});
    var specials = {};
    var re = /group_name == "(\w+)"/g, m;
    while ((m = re.exec(rules))) specials[m[1]] = true;
    if (!Object.keys(specials).length) {
      warnings.push("rules.py: no `group_name == \"...\"` counters found — using built-in fallback list");
      FALLBACK_SPECIAL_COUNTERS.forEach(function (k) { specials[k] = true; });
    }
    delete specials.gemSkills; delete specials.GemSkills;
    vocab.specialCounters = Object.keys(specials);
    vocab.prefixTokens = [];
    re = /req\.startswith\("([^"]+)"\)/g;
    while ((m = re.exec(rules))) if (vocab.prefixTokens.indexOf(m[1]) < 0) vocab.prefixTokens.push(m[1]);

    // Per-stage <Pascal>Count fields present anywhere (mirrors _PRESENT_COUNT_FIELDS).
    var present = {};
    Object.keys(levels).forEach(function (sid) {
      var d = levels[sid];
      Object.keys(d).forEach(function (f) {
        if (/Count$/.test(f) && typeof d[f] === "number" && d[f] > 0) present[f] = true;
      });
    });
    vocab.presentCountFields = present;
    vocab.levels = levels;
    vocab.stageIds = stages;
    return vocab;
  }

  function elementCountField(display) {
    return display.split(/\s+/).filter(Boolean).map(function (p) { return p[0].toUpperCase() + p.slice(1); }).join("") + "Count";
  }
  function isPrefixToken(tok, letters) {
    return tok.length >= 2 && letters.indexOf(tok[0]) >= 0 && tok[1] === tok[1].toUpperCase() && tok[1] !== tok[1].toLowerCase();
  }
  function qualifying(levels, fields, n) {
    if (typeof fields === "string") fields = [fields];
    return Object.keys(levels).filter(function (sid) {
      var d = levels[sid];
      return Math.max.apply(null, fields.map(function (f) { return d[f] || 0; })) >= n;
    });
  }

  // ------------------------------------------------------------------ //
  // Token classification — mirrors rules.py `_compile_req` dispatch order.
  // Result: { status: ok|warn|never|error, cat, base, count, text, stages? }
  //   ok    - recognised and gateable
  //   warn  - recognised but suspicious (stub, no-op, over pool size, ...)
  //   never - recognised, intentionally never satisfiable (mode tokens)
  //   error - generation would raise / requirement can never be met
  // ------------------------------------------------------------------ //
  function classify(raw, V, ctx) {
    var tok = String(raw).trim();
    var r = { token: tok, status: "ok", cat: "?", base: tok, count: null, text: "" };
    if (!tok) { r.status = "error"; r.text = "Empty token"; return r; }

    if (tok.indexOf("Field_") === 0) {
      var sid = tok.slice(6);
      r.cat = "field"; r.base = "Field_<sid>";
      if (V.stageIds.indexOf(sid) < 0) { r.status = "error"; r.text = "Unknown field '" + sid + "'"; }
      else r.text = "Field " + sid + " must be clearable (beatable) in logic";
      return r;
    }
    if (tok.indexOf("Achievement:") === 0) {
      r.cat = "achievement"; r.base = "Achievement:<name>";
      var an = tok.slice(12).trim();
      if (ctx && ctx.achievementNames && !ctx.achievementNames[an] && !ctx.achievementNames[an.replace(/^Achievement:\s*/, "")]) {
        r.status = "warn"; r.text = "Unknown achievement '" + an + "' (only checked under progressive field tokens)";
      } else r.text = "Achievement location " + an + " reachable (progressive field-token modes only; ignored otherwise)";
      return r;
    }
    if (V.modes.indexOf(tok) >= 0) {
      r.cat = "mode"; r.status = "never";
      r.text = "Game mode not available in the randomizer (journey only) — this AND-group is never in logic";
      return r;
    }
    if (V.skills[tok] || V.traits[tok]) {
      var item = V.skills[tok] || V.traits[tok];
      r.cat = V.skills[tok] ? "skill" : "trait";
      r.text = "Needs item: " + item;
      if (V.gemTokens[tok]) r.text += " + a field where you can make gems (or a field that already offers " + V.gemTokens[tok] + " gems)";
      return r;
    }
    if (V.elements[tok]) {
      var names = V.elements[tok];
      r.cat = tok[0] === "w" ? "weather" : "element";
      r.text = names.length > 1 ? "A reachable field with any of: " + names.join(", ") : "A reachable field containing: " + names[0];
      if (V.interactSkill[tok]) r.text += " + item " + V.interactSkill[tok];
      if (names.length === 1 && V.stubElements.indexOf(elementCountField(names[0]).replace(/Count$/, "")) >= 0) {
        r.status = "warn"; r.text += " — STUB element: always passes";
      }
      return r;
    }
    var ci = tok.indexOf(":");
    if (ci < 0) {
      r.status = "error";
      r.text = isPrefixToken(tok, "e") ? "Unknown element token (not in element_prefix_map)" :
        isPrefixToken(tok, "st") ? "Unknown skill/trait token" : "Unrecognized requirement — generation raises";
      return r;
    }
    var g = tok.slice(0, ci).trim(), cs = tok.slice(ci + 1).trim();
    r.base = g + ":N";
    if (g === "gemPouch") {
      // Field-level WIZLOCK token from game_data.json required_skills: gemPouch:<tile letter>.
      r.cat = "pouch"; r.base = "gemPouch:<tile>"; r.count = cs;
      if (!/^[A-Z]$/.test(cs)) { r.status = "error"; r.text = "gemPouch needs a tile letter"; }
      else r.text = "Gem pouch for tile " + cs + " (depends on gem_pouch_granularity; free starter fields are exempt)";
      return r;
    }
    if (!/^-?\d+$/.test(cs)) { r.status = "error"; r.text = "Count after ':' must be an integer"; r.cat = "?"; return r; }
    var n = parseInt(cs, 10);
    r.count = n;

    if (g === "min_wl") {
      r.cat = "pacing";
      r.text = "Wizard-level floor " + n + " (enforced separately as a WL gate; no-op inside the requirement)";
      return r;
    }
    if (V.elements[g] && V.elements[g].length > 1) {
      r.cat = "element"; r.text = "A reachable field with any of: " + V.elements[g].join(", ") + " (count ignored)";
      return r;
    }
    if (isPrefixToken(g, "e")) {
      r.cat = "element";
      var pascal = V.elements[g] ? elementCountField(V.elements[g][0]).replace(/Count$/, "") : g.slice(1);
      if (pascal === "WizardStash") {
        r.text = n <= 1 ? "Any wizard stash reachable (key + field)" : n + " wizard stashes openable (keys + fields beaten)";
        return r;
      }
      if (V.stubElements.indexOf(pascal) >= 0) {
        r.status = "warn"; r.text = "STUB element " + pascal + ": always passes"; return r;
      }
      var field = pascal + "Count";
      if (!V.presentCountFields[field]) {
        r.status = "error"; r.text = "No field has a '" + field + "' value — generation fails loud"; return r;
      }
      var q = qualifying(V.levels, field, n);
      r.stages = q;
      if (!q.length) { r.status = "error"; r.text = "No field has " + field + " ≥ " + n + " — never satisfiable"; return r; }
      r.text = "A reachable field with ≥ " + n + " " + pascal + " (" + q.length + " fields)";
      if (V.interactSkill["e" + pascal]) r.text += " + item " + V.interactSkill["e" + pascal];
      if (pascal === "Apparition") r.text += "; Ritual trait also satisfies small counts";
      return r;
    }
    if (V.pools[g]) {
      r.cat = "pool";
      var size = V.pools[g].length;
      r.text = "At least " + n + " of " + size + " " + (V.poolDesc[g] || g);
      if (g === "gemSkills" || g === "GemSkills") r.text += " — counted per field: a beatable field whose pouch + held skills give ≥ " + n + " gem types";
      if (n > size) { r.status = "error"; r.text += " — pool only has " + size; }
      return r;
    }
    if (V.levelStats[g] !== undefined) {
      r.cat = "stat";
      var fs = V.levelStats[g];
      var q2 = qualifying(V.levels, fs, n);
      r.stages = q2;
      var fl = typeof fs === "string" ? fs : fs.join(" / ");
      if (!q2.length) { r.status = "error"; r.text = "No field has " + fl + " ≥ " + n + " — never satisfiable"; return r; }
      r.text = "A reachable field with " + fl + " ≥ " + n + " (" + q2.length + " fields)";
      return r;
    }
    if (V.talismanCounters.indexOf(g) >= 0) {
      r.cat = "talisman";
      r.text = "Hold ≥ " + n + " progression talisman fragments (" + g + ")";
      if (g === "talismanFragments" && V.talismanFloor[n] !== undefined) r.text += " and ≥ " + V.talismanFloor[n] + " fields unlocked";
      return r;
    }
    if (V.talismanProps[g] !== undefined) {
      r.cat = "talisman";
      r.text = "Held fragments' summed property #" + V.talismanProps[g] + " (at max upgrade) ≥ " + n;
      return r;
    }
    if (V.specialCounters.indexOf(g) >= 0) {
      r.cat = "special";
      var sp = {
        fieldToken: "At least " + n + " fields clearable in logic",
        talismanRow: "At least " + n + " complete talisman rows",
        talismanColumn: "At least " + n + " complete talisman columns",
        skillPoints: "Skill points " + n + " — pacing only, always passes server-side",
        gemPouch: "Gem pouch for tile " + n,
      };
      r.text = sp[g] || ("Special counter " + g + " (see rules.py)");
      if (g === "skillPoints") r.status = "warn";
      return r;
    }
    r.status = "error"; r.text = "Unrecognized counter '" + g + "' — generation raises";
    return r;
  }

  function normalizeReqs(reqs) {
    if (!reqs || !reqs.length) return [];
    return Array.isArray(reqs[0]) ? reqs : [reqs];
  }

  // ------------------------------------------------------------------ //
  // Entry-splicing model of a `name = { "Key": {...}, ... }` file.
  // Unchanged entries are emitted byte-for-byte; edited entries re-emit
  // unchanged keys from their original source text.
  // ------------------------------------------------------------------ //
  function parseEntryFile(src, varName) {
    var re = new RegExp("^" + varName + "\\s*(?::[^=\\n]+)?=\\s*", "m");
    var m = re.exec(src);
    if (!m) throw new Error(varName + " not found");
    var p = new PyParser(src);
    p.i = m.index + m[0].length;
    var dict = p.value();
    var ents = dict.__entries;
    var eol = /\r\n/.test(src) ? "\r\n" : "\n";
    function lineStart(i) { return src.lastIndexOf("\n", i - 1) + 1; }
    function lineEndAfter(i) {
      var j = i;
      while (j < src.length && (src[j] === " " || src[j] === "\t")) j++;
      if (src[j] === ",") j++;
      var nl = src.indexOf("\n", j);
      return nl < 0 ? src.length : nl + 1;
    }
    var segments = [];
    var cursor = 0;
    var entries = {};
    var order = [];
    ents.forEach(function (e) {
      var a = lineStart(e.keyStart), b = lineEndAfter(e.valueEnd);
      segments.push({ gap: src.slice(cursor, a) });
      var inner = dict[e.key];
      var keyRaw = {};
      (inner.__entries || []).forEach(function (ie) {
        keyRaw[ie.key] = src.slice(ie.valueStart, ie.valueEnd);
      });
      entries[e.key] = {
        name: e.key,
        raw: src.slice(a, b),
        original: inner,
        keyOrder: (inner.__entries || []).map(function (ie) { return ie.key; }),
        keyRaw: keyRaw,
      };
      order.push(e.key);
      segments.push({ entry: e.key });
      cursor = b;
    });
    segments.push({ gap: src.slice(cursor) });
    return { src: src, eol: eol, segments: segments, entries: entries, order: order, data: dict };
  }

  function pyStr(s) {
    return JSON.stringify(s).replace(new RegExp("[" + String.fromCharCode(0x2028, 0x2029) + "]", "g"), function (c) { return "\\u" + c.charCodeAt(0).toString(16); });
  }
  function pyVal(v) {
    if (v === true) return "True";
    if (v === false) return "False";
    if (v === null || v === undefined) return "None";
    if (typeof v === "number") return String(v);
    if (typeof v === "string") return pyStr(v);
    if (Array.isArray(v)) return "[" + v.map(pyVal).join(", ") + "]";
    return "{" + Object.keys(v).map(function (k) { return pyStr(k) + ": " + pyVal(v[k]); }).join(", ") + "}";
  }
  function same(a, b) { return JSON.stringify(a) === JSON.stringify(b); }

  // style: "achievements" (flat if one group, multi-line DNF otherwise) or "levels" (DNF on one line)
  function serializeReqs(reqs, style, eol, wasNested) {
    var groups = normalizeReqs(reqs);
    if (!groups.length) return "[]";
    if (style === "levels") return "[" + groups.map(pyVal).join(", ") + "]";
    if (groups.length === 1 && !wasNested) return pyVal(groups[0]);
    return "[" + eol + groups.map(function (g) { return "            " + pyVal(g) + "," + eol; }).join("") + "        ]";
  }

  // keyRank: canonical key order used to place newly added keys.
  function serializeEntry(entry, value, opts) {
    var eol = opts.eol;
    var keys = entry.keyOrder.filter(function (k) { return value[k] !== undefined; });
    Object.keys(value).forEach(function (k) {
      if (keys.indexOf(k) >= 0 || value[k] === undefined) return;
      var rank = opts.keyRank.indexOf(k);
      var at = keys.length;
      if (rank >= 0) {
        for (var i = 0; i < keys.length; i++) {
          var r2 = opts.keyRank.indexOf(keys[i]);
          if (r2 > rank) { at = i; break; }
        }
      }
      keys.splice(at, 0, k);
    });
    var out = "    " + pyStr(entry.name) + ": {" + eol;
    keys.forEach(function (k) {
      var text;
      if (entry.keyRaw[k] !== undefined && same(entry.original[k], value[k])) text = entry.keyRaw[k];
      else if (k === "requirements") text = serializeReqs(value[k], opts.style, eol, Array.isArray((entry.original.requirements || [])[0]));
      else text = pyVal(value[k]);
      out += "        " + pyStr(k) + ": " + text + "," + eol;
    });
    return out + "    }," + eol;
  }

  // current: { name: valueObject } with the edited values (only keys present in `changed` are re-serialized).
  function exportEntryFile(model, current, opts) {
    opts = Object.assign({ eol: model.eol }, opts);
    var out = "";
    model.segments.forEach(function (seg) {
      if (seg.gap !== undefined) { out += seg.gap; return; }
      var e = model.entries[seg.entry];
      var v = current[seg.entry];
      if (!v || same(v, plain(e.original))) out += e.raw;
      else out += serializeEntry(e, v, opts);
    });
    return out;
  }

  function plain(o) { return JSON.parse(JSON.stringify(o)); }

  var api = {
    PyParser: PyParser,
    findAssign: findAssign,
    moduleDocstring: moduleDocstring,
    buildVocab: buildVocab,
    classify: classify,
    normalizeReqs: normalizeReqs,
    parseEntryFile: parseEntryFile,
    exportEntryFile: exportEntryFile,
    serializeEntry: serializeEntry,
    pyVal: pyVal,
    plain: plain,
    elementCountField: elementCountField,
  };
  if (typeof module !== "undefined" && module.exports) module.exports = api;
  else root.RulesCore = api;
})(this);
