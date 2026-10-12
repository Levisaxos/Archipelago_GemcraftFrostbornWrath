// GCFW Rules Viewer — UI. Data comes from the apworld source files (GitHub branch, local working copy, or files opened from disk).
(function () {
  "use strict";
  var C = window.RulesCore;
  var REPO = "Levisaxos/Archipelago_GemcraftFrostbornWrath";
  var APWORLD = "apworld/gcfw/";
  var REQUIRED = ["rulesdata_achievements.py", "rulesdata_levels.py", "requirement_tokens.py", "rulesdata_settings.py", "rules.py", "data/game_data.json"];
  var OPTIONAL = ["rulesdata.py", "gating.py", "options.py", "data/vanilla_tree.json"];
  var ACH_KEY_RANK = ["ap_id", "game_id", "description", "details", "vanilla_correction", "requirements", "required_effort", "field_need", "untrackable", "last_checked"];
  var LV_KEY_RANK = ["type", "requirements", "last_checked"];
  var EFFORTS = ["Trivial", "Minor", "Major", "Extreme"];
  var STATUS_RANK = { ok: 0, never: 1, warn: 2, error: 3 };

  var S = {
    source: null, files: {}, fileInfo: {}, warnings: [],
    ach: null, lv: null, achCur: {}, lvCur: {}, stages: [], stageById: {}, tree: {},
    V: null, cache: {}, edit: false, tab: "achievements", tagFilter: null, drawer: null, drafts: { ach: {}, lv: {} },
  };

  // ---------------------------------------------------------------- utils
  function $(id) { return document.getElementById(id); }
  function esc(s) { return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
  function same(a, b) { return JSON.stringify(a) === JSON.stringify(b); }
  function today() { var d = new Date(); return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()); }
  function pad(n) { return n < 10 ? "0" + n : "" + n; }
  function ageDays(s) {
    if (!s || !/^\d{4}-\d{2}-\d{2}$/.test(s)) return null;
    var t = Date.parse(s + "T00:00:00");
    return Math.floor((Date.now() - t) / 86400000);
  }
  function store(k, v) { try { if (v === undefined) localStorage.removeItem(k); else localStorage.setItem(k, JSON.stringify(v)); } catch (e) { /* storage unavailable */ } }
  function load(k) { try { var v = localStorage.getItem(k); return v ? JSON.parse(v) : null; } catch (e) { return null; } }
  function isLocalHost() { return /^(localhost|127\.0\.0\.1|\[::1\])$/.test(location.hostname) || location.protocol === "file:"; }

  // ---------------------------------------------------------------- loading
  function rawUrl(branch, f) { return "https://raw.githubusercontent.com/" + REPO + "/" + encodeURIComponent(branch).replace(/%2F/g, "/") + "/" + APWORLD + f; }
  function fetchText(url) {
    return fetch(url, { cache: "no-cache" }).then(function (r) {
      if (!r.ok) throw new Error(r.status + " " + url);
      return r.text();
    });
  }
  function fetchSource(src) {
    var base = src.indexOf("gh:") === 0 ? null : "../../" + APWORLD;
    var branch = src.slice(3);
    var all = REQUIRED.concat(OPTIONAL);
    return Promise.all(all.map(function (f) {
      var url = base ? base + f : rawUrl(branch, f);
      return fetchText(url).then(function (t) { return [f, t]; }, function (e) {
        if (REQUIRED.indexOf(f) >= 0) throw e;
        return [f, null];
      });
    })).then(function (pairs) {
      var files = {};
      pairs.forEach(function (p) { if (p[1] != null) files[p[0]] = p[1]; });
      return files;
    });
  }
  function fetchCommitInfo(branch) {
    ["rulesdata_achievements.py", "rulesdata_levels.py"].forEach(function (f) {
      fetch("https://api.github.com/repos/" + REPO + "/commits?per_page=1&sha=" + encodeURIComponent(branch) + "&path=" + APWORLD + f)
        .then(function (r) { return r.ok ? r.json() : []; })
        .then(function (j) {
          if (!j || !j[0]) return;
          S.fileInfo[f] = { date: j[0].commit.committer.date.slice(0, 10), msg: j[0].commit.message.split("\n")[0], url: j[0].html_url };
          renderMeta();
        }).catch(function () {});
    });
  }
  function initSources() {
    var sel = $("srcSelect");
    var opts = [];
    if (isLocalHost() && location.protocol !== "file:") opts.push(["local", "Local working copy"]);
    opts.push(["gh:main", "GitHub: main"]);
    sel.innerHTML = opts.map(function (o) { return '<option value="' + esc(o[0]) + '">' + esc(o[1]) + "</option>"; }).join("");
    var want = new URLSearchParams(location.search).get("src") || load("gcfw-rules-src") || opts[0][0];
    if (want.indexOf("gh:") === 0 && want !== "gh:main") addOption(want, "GitHub: " + want.slice(3));
    sel.value = want;
    if (!sel.value) sel.value = opts[0][0];
    fetch("https://api.github.com/repos/" + REPO + "/branches?per_page=100").then(function (r) { return r.ok ? r.json() : []; }).then(function (list) {
      list.forEach(function (b) { addOption("gh:" + b.name, "GitHub: " + b.name); });
    }).catch(function () {});
    function addOption(v, label) {
      if ([].some.call(sel.options, function (o) { return o.value === v; })) return;
      var o = document.createElement("option");
      o.value = v; o.textContent = label;
      sel.appendChild(o);
    }
    sel.onchange = function () { loadFrom(sel.value); };
  }
  function loadFrom(src) {
    $("loading").hidden = false;
    $("loading").className = "loading";
    $("loading").textContent = "Loading rules…";
    S.fileInfo = {};
    store("gcfw-rules-src", src);
    var u = new URL(location.href);
    u.searchParams.set("src", src);
    history.replaceState(null, "", u);
    fetchSource(src).then(function (files) {
      S.source = src;
      S.files = files;
      if (src.indexOf("gh:") === 0) fetchCommitInfo(src.slice(3));
      build();
    }).catch(function (e) {
      $("loading").className = "loading err";
      $("loading").textContent = "Could not load the rules files.\n" + e.message +
        (src === "local" ? "\n\nServe the repository root (e.g. `python -m http.server` in the repo) and open /docs/rules/." : "");
    });
  }
  function openFiles(list) {
    var reads = [].map.call(list, function (f) {
      return f.text().then(function (t) {
        var name = f.name;
        if (/\.json$/.test(name)) name = "data/" + name;
        return [name, t];
      });
    });
    Promise.all(reads).then(function (pairs) {
      var files = Object.assign({}, S.files);
      var names = [];
      pairs.forEach(function (p) { if (REQUIRED.indexOf(p[0]) >= 0 || OPTIONAL.indexOf(p[0]) >= 0) { files[p[0]] = p[1]; names.push(p[0]); } });
      if (!names.length) { alert("None of the selected files are rulesdata files this viewer reads."); return; }
      var missing = REQUIRED.filter(function (f) { return !files[f]; });
      if (missing.length) { alert("Still missing: " + missing.join(", ") + "\nLoad a GitHub source first, or select these files too."); return; }
      S.source = "files:" + (S.source || "").replace(/^files:/, "");
      S.files = files;
      S.openedFiles = names;
      build();
    });
  }

  // ---------------------------------------------------------------- model
  function build() {
    S.warnings = [];
    S.cache = {};
    try {
      S.ach = C.parseEntryFile(S.files["rulesdata_achievements.py"], "achievement_requirements");
      S.lv = C.parseEntryFile(S.files["rulesdata_levels.py"], "level_requirements");
    } catch (e) {
      $("loading").className = "loading err";
      $("loading").textContent = "Could not parse a rulesdata file: " + e.message;
      return;
    }
    var gd = JSON.parse(S.files["data/game_data.json"]);
    S.stages = gd.stages || [];
    S.stageById = {};
    S.stages.forEach(function (s) { S.stageById[s.str_id] = s; });
    S.tree = {};
    if (S.files["data/vanilla_tree.json"]) { try { S.tree = JSON.parse(S.files["data/vanilla_tree.json"]).stages || {}; } catch (e) { S.warnings.push("vanilla_tree.json: " + e.message); } }
    S.achCur = {};
    S.ach.order.forEach(function (n) { S.achCur[n] = C.plain(S.ach.entries[n].original); });
    S.lvCur = {};
    S.lv.order.forEach(function (n) { S.lvCur[n] = C.plain(S.lv.entries[n].original); });
    restoreDrafts();
    rebuildVocab();
    $("loading").hidden = true;
    fillFilterOptions();
    renderAll();
    applyHash();
  }
  function rebuildVocab() {
    var w = [];
    S.V = C.buildVocab(S.files, S.lvCur, S.stages.map(function (s) { return s.str_id; }), w);
    S.vocabWarnings = w;
    S.cache = {};
    S.achNames = {};
    S.ach.order.forEach(function (n) { S.achNames[n] = true; });
  }
  function cls(tok) {
    var c = S.cache[tok];
    if (!c) c = S.cache[tok] = C.classify(tok, S.V, { achievementNames: S.achNames });
    return c;
  }
  function achStatus(name) {
    var a = S.achCur[name];
    var worst = "ok", never = false, tokens = 0;
    C.normalizeReqs(a.requirements).forEach(function (g) {
      var gNever = false;
      g.forEach(function (t) {
        tokens++;
        var r = cls(t);
        if (r.status === "never") gNever = true;
        if (STATUS_RANK[r.status] > STATUS_RANK[worst]) worst = r.status;
      });
      if (gNever) never = true;
    });
    return { worst: worst, never: never, tokens: tokens };
  }
  function isDirtyAch(n) { return !same(S.achCur[n], C.plain(S.ach.entries[n].original)); }
  function isDirtyLv(n) { return !same(S.lvCur[n], C.plain(S.lv.entries[n].original)); }
  function dirtyCounts() {
    return {
      ach: S.ach.order.filter(isDirtyAch).length,
      lv: S.lv.order.filter(isDirtyLv).length,
    };
  }

  // ---------------------------------------------------------------- drafts (unsaved edits survive a reload, per source)
  function draftKey() { return "gcfw-rules-drafts:" + S.source; }
  function saveDrafts() {
    var d = { ach: {}, lv: {} };
    S.ach.order.forEach(function (n) { if (isDirtyAch(n)) d.ach[n] = { value: S.achCur[n], base: C.plain(S.ach.entries[n].original) }; });
    S.lv.order.forEach(function (n) { if (isDirtyLv(n)) d.lv[n] = { value: S.lvCur[n], base: C.plain(S.lv.entries[n].original) }; });
    S.conflicts = S.conflicts || [];
    store(draftKey(), Object.keys(d.ach).length || Object.keys(d.lv).length ? d : undefined);
  }
  function restoreDrafts() {
    S.conflicts = [];
    var d = load(draftKey());
    if (!d) return;
    [["ach", S.ach, S.achCur], ["lv", S.lv, S.lvCur]].forEach(function (t) {
      Object.keys(d[t[0]] || {}).forEach(function (n) {
        if (!t[1].entries[n]) return;
        var it = d[t[0]][n];
        t[2][n] = it.value;
        if (!same(it.base, C.plain(t[1].entries[n].original))) S.conflicts.push(n);
      });
    });
  }

  // ---------------------------------------------------------------- rendering helpers
  function chip(tok) {
    var r = cls(tok);
    var c = r.status === "ok" ? "" : r.status;
    return '<span class="chip ' + c + '" title="' + esc(r.text) + '">' + esc(tok) + "</span>";
  }
  function reqsHtml(reqs) {
    var groups = C.normalizeReqs(reqs);
    if (!groups.length) return '<span class="muted">— none (always in logic)</span>';
    if (groups.length === 1) return '<div class="chips">' + groups[0].map(chip).join("") + "</div>";
    return '<div class="chips">' + groups.map(function (g) {
      return '<span class="group">' + (g.length ? g.map(chip).join("") : '<span class="muted">(empty)</span>') + "</span>";
    }).join('<span class="or">or</span>') + "</div>";
  }
  function checkedHtml(s) {
    var a = ageDays(s);
    if (a === null) return '<span class="age-none">never</span>';
    var c = a > 90 ? "age-old" : "age-ok";
    return '<span class="' + c + ' nowrap" title="' + a + ' days ago">' + esc(s) + "</span>";
  }
  function matchTag(tok, tag) {
    if (!tag) return true;
    if (tag === "Field_" || tag === "Achievement:") return tok.indexOf(tag) === 0;
    return tok === tag || tok.split(":")[0] === tag;
  }
  function tagBase(tok) {
    if (tok.indexOf("Field_") === 0) return "Field_";
    if (tok.indexOf("Achievement:") === 0) return "Achievement:";
    return tok.split(":")[0];
  }

  // ---------------------------------------------------------------- header / meta
  function renderMeta() {
    var src = S.source || "";
    var parts = [];
    if (src.indexOf("gh:") === 0) parts.push("Reading <b>" + esc(src.slice(3)) + "</b> from GitHub");
    else if (src === "local") parts.push("Reading the <b>local working copy</b>");
    else parts.push("Using files opened from disk: " + esc((S.openedFiles || []).join(", ")));
    ["rulesdata_achievements.py", "rulesdata_levels.py"].forEach(function (f) {
      var i = S.fileInfo[f];
      if (i) parts.push(esc(f) + ' last changed <a href="' + esc(i.url) + '" target="_blank" rel="noopener">' + esc(i.date) + "</a> — " + esc(i.msg));
    });
    var w = S.warnings.concat(S.vocabWarnings || []);
    if (w.length) parts.push('<span class="warnline">' + w.length + " parse warning(s) — see Problems</span>");
    $("meta").innerHTML = parts.join(" · ");
  }
  function renderEditBar() {
    var d = dirtyCounts();
    var any = d.ach + d.lv > 0;
    $("dirtyInfo").hidden = !any;
    $("dirtyInfo").textContent = any ? (d.ach + d.lv) + " unsaved edit(s)" : "";
    $("exportAch").hidden = !(S.edit || d.ach);
    $("exportLv").hidden = !(S.edit || d.lv);
    $("exportAch").disabled = !d.ach;
    $("exportLv").disabled = !d.lv;
    $("discardBtn").hidden = !any;
    $("bulkCheck").hidden = !S.edit;
    $("exportAch").textContent = "Export rulesdata_achievements.py" + (d.ach ? " (" + d.ach + ")" : "");
    $("exportLv").textContent = "Export rulesdata_levels.py" + (d.lv ? " (" + d.lv + ")" : "");
  }
  function renderAll() {
    renderMeta();
    renderEditBar();
    renderAch();
    renderLv();
    renderGating();
    renderLegend();
    renderProblems();
  }

  // ---------------------------------------------------------------- achievements
  function fillFilterOptions() {
    var eff = {}, need = {};
    S.ach.order.forEach(function (n) {
      var a = S.achCur[n];
      if (a.required_effort) eff[a.required_effort] = true;
      if (a.field_need) need[a.field_need] = true;
    });
    var effs = EFFORTS.filter(function (e) { return eff[e]; }).concat(Object.keys(eff).filter(function (e) { return EFFORTS.indexOf(e) < 0; }));
    $("fEffort").innerHTML = '<option value="">Any effort</option>' + effs.map(function (e) { return "<option>" + esc(e) + "</option>"; }).join("");
    var needs = Object.keys(need);
    $("fNeed").hidden = !needs.length;
    $("fNeed").innerHTML = '<option value="">Any field need</option>' + ["enter", "engage", "beat"].filter(function (x) { return need[x]; }).concat(needs.filter(function (x) { return ["enter", "engage", "beat"].indexOf(x) < 0; })).map(function (e) { return "<option>" + esc(e) + "</option>"; }).join("");
    var tiles = {};
    S.lv.order.forEach(function (sid) { tiles[sid[0]] = true; });
    $("fTile").innerHTML = '<option value="">All tiles</option>' + Object.keys(tiles).sort().map(function (t) { return "<option>" + t + "</option>"; }).join("");
  }
  function filteredAch() {
    var q = $("q").value.trim().toLowerCase();
    var eff = $("fEffort").value, need = $("fNeed").value, st = $("fStatus").value, ck = $("fChecked").value;
    var list = S.ach.order.filter(function (n) {
      var a = S.achCur[n];
      if (eff && a.required_effort !== eff) return false;
      if (need && a.field_need !== need) return false;
      var toks = [].concat.apply([], C.normalizeReqs(a.requirements));
      if (S.tagFilter && !toks.some(function (t) { return matchTag(t, S.tagFilter); })) return false;
      if (st) {
        var s = achStatus(n);
        if (st === "tracked" && a.untrackable) return false;
        if (st === "untrackable" && !a.untrackable) return false;
        if (st === "error" && s.worst !== "error") return false;
        if (st === "warn" && s.worst !== "warn") return false;
        if (st === "never" && !s.never) return false;
        if (st === "nologic" && s.tokens) return false;
        if (st === "dirty" && !isDirtyAch(n)) return false;
      }
      if (ck) {
        var age = ageDays(a.last_checked);
        if (ck === "never" && age !== null) return false;
        if (ck === "checked" && age === null) return false;
        if (/^\d+$/.test(ck) && age !== null && age <= +ck) return false;
      }
      if (q) {
        var hay = (n + " " + a.description + " " + (a.details || "") + " " + toks.join(" ") + " " + a.ap_id).toLowerCase();
        if (hay.indexOf(q) < 0) return false;
      }
      return true;
    });
    var sort = $("fSort").value;
    list.sort(function (x, y) {
      var a = S.achCur[x], b = S.achCur[y];
      if (sort === "ap") return a.ap_id - b.ap_id;
      if (sort === "checked") return (a.last_checked || "").localeCompare(b.last_checked || "") || x.localeCompare(y);
      if (sort === "effort") return EFFORTS.indexOf(a.required_effort) - EFFORTS.indexOf(b.required_effort) || x.localeCompare(y);
      return x.localeCompare(y);
    });
    return list;
  }
  function renderAch() {
    var list = filteredAch();
    var hasNeed = S.ach.order.some(function (n) { return S.achCur[n].field_need !== undefined; });
    var h = "<thead><tr><th>Achievement</th><th>Description</th><th>Requirements</th><th>Effort</th>" + (hasNeed ? "<th>Field need</th>" : "") + "<th>Flags</th><th>Last checked</th></tr></thead><tbody>";
    h += list.map(function (n) {
      var a = S.achCur[n];
      var flags = (a.untrackable ? '<span class="badge untrack" title="Excluded location: filler only, no access rules">untrackable</span> ' : "") +
        (a.vanilla_correction ? '<span class="badge vc" title="The vanilla description is wrong; requirements follow actual game code">vanilla fix</span>' : "");
      return '<tr class="row' + (isDirtyAch(n) ? " dirtyrow" : "") + '" data-ach="' + esc(n) + '">' +
        '<td class="name">' + esc(n) + "<small>AP " + esc(a.ap_id) + " · game " + esc(a.game_id) + "</small></td>" +
        '<td class="desc">' + esc(a.description) + (a.details ? '<div class="details">' + esc(a.details) + "</div>" : "") + "</td>" +
        "<td>" + reqsHtml(a.requirements) + "</td>" +
        '<td class="nowrap">' + esc(a.required_effort || "") + "</td>" +
        (hasNeed ? '<td class="nowrap">' + esc(a.field_need || "") + "</td>" : "") +
        "<td>" + flags + "</td>" +
        "<td>" + checkedHtml(a.last_checked) + "</td></tr>";
    }).join("") + "</tbody>";
    $("achTable").innerHTML = h;
    $("achCount").textContent = list.length + " of " + S.ach.order.length;
    $("cntAch").textContent = S.ach.order.length;
    var tf = $("tagFilter");
    tf.hidden = !S.tagFilter;
    tf.innerHTML = S.tagFilter ? 'Tag: <span class="chip">' + esc(S.tagFilter) + '</span><button class="linkbtn" id="clearTag">clear</button>' : "";
    if (S.tagFilter) $("clearTag").onclick = function () { S.tagFilter = null; renderAch(); };
  }

  function achDrawer(n) {
    var h = '<div id="dView">' + achView(n) + "</div>";
    if (S.edit) h += achForm(n, S.achCur[n]);
    openDrawer(n, h, "ach:" + n);
    if (S.edit) wireAchForm(n);
  }
  function achView(n) {
    var a = S.achCur[n];
    var o = C.plain(S.ach.entries[n].original);
    var h = "";
    h += '<dl class="kv">' +
      "<dt>AP id / game id</dt><dd>" + esc(a.ap_id) + " / " + esc(a.game_id) + "</dd>" +
      "<dt>Description</dt><dd>" + esc(a.description) + "</dd>" +
      (a.details ? "<dt>Details</dt><dd>" + esc(a.details) + "</dd>" : "") +
      "<dt>Effort</dt><dd>" + esc(a.required_effort || "—") + "</dd>" +
      (a.field_need !== undefined ? "<dt>Field need</dt><dd>" + esc(a.field_need) + "</dd>" : "") +
      "<dt>Untrackable</dt><dd>" + (a.untrackable ? "yes: excluded location, filler only" : "no") + "</dd>" +
      (a.vanilla_correction ? "<dt>Vanilla fix</dt><dd>yes: requirements follow the game code, not the description</dd>" : "") +
      "<dt>Last checked</dt><dd>" + checkedHtml(a.last_checked) + "</dd>";
    Object.keys(a).forEach(function (k) {
      if (ACH_KEY_RANK.indexOf(k) < 0) h += "<dt>" + esc(k) + "</dt><dd><code>" + esc(JSON.stringify(a[k])) + "</code></dd>";
    });
    h += "</dl>";
    h += "<h3>Requirements</h3>" + explainReqs(a.requirements);
    if (isDirtyAch(n)) h += '<p class="dirty">Edited (unsaved). Original requirements: <code>' + esc(JSON.stringify(o.requirements)) + "</code></p>";
    return h;
  }
  function explainReqs(reqs) {
    var groups = C.normalizeReqs(reqs);
    if (!groups.length) return '<p class="muted">No requirements: always in logic (unless untrackable).</p>';
    var h = '<ul class="explainlist">';
    groups.forEach(function (g, i) {
      if (groups.length > 1) h += '<li class="grouphdr">' + (i ? "OR option " : "Option ") + (i + 1) + " (all of these)</li>";
      g.forEach(function (t) {
        var r = cls(t);
        var st = r.stages && r.stages.length ? ' <span class="muted">[' + esc(r.stages.slice(0, 24).join(", ")) + (r.stages.length > 24 ? ", …" : "") + "]</span>" : "";
        h += "<li>" + chip(t) + " " + esc(r.text) + st + "</li>";
      });
    });
    return h + "</ul>";
  }
  function reqsToText(reqs) { return C.normalizeReqs(reqs).map(function (g) { return g.join(", "); }).join("\n"); }
  function textToReqs(text, nested) {
    var groups = text.split(/\n/).map(function (l) { return l.split(",").map(function (t) { return t.trim(); }).filter(Boolean); }).filter(function (g) { return g.length; });
    if (!groups.length) return [];
    if (groups.length === 1 && !nested) return groups[0];
    return groups;
  }
  function tokenDatalist() {
    if ($("tokList")) return "";
    var V = S.V, toks = [];
    toks = toks.concat(Object.keys(V.skills), Object.keys(V.traits), Object.keys(V.elements), V.modes);
    Object.keys(V.levelStats).forEach(function (k) { toks.push(k + ":"); });
    Object.keys(V.pools).forEach(function (k) { toks.push(k + ":"); });
    V.talismanCounters.concat(Object.keys(V.talismanProps), V.specialCounters).forEach(function (k) { toks.push(k + ":"); });
    S.lv.order.forEach(function (s) { toks.push("Field_" + s); });
    return '<datalist id="tokList">' + toks.map(function (t) { return '<option value="' + esc(t) + '">'; }).join("") + "</datalist>";
  }
  function achForm(n, a) {
    var effs = EFFORTS.slice();
    if (a.required_effort && effs.indexOf(a.required_effort) < 0) effs.push(a.required_effort);
    var h = '<h3>Edit</h3><div class="form">' + tokenDatalist();
    h += '<label>Requirements: one OR-option per line, tags inside a line separated by commas (all needed)</label>' +
      '<textarea id="eReq" rows="' + Math.max(3, C.normalizeReqs(a.requirements).length + 1) + '" spellcheck="false">' + esc(reqsToText(a.requirements)) + "</textarea>" +
      '<div class="row2"><input id="eTok" type="text" list="tokList" placeholder="Add a tag (Enter appends it to the last line)"></div>' +
      '<div class="preview" id="eReqPrev"></div>';
    h += '<label>Description (game text)</label><input id="eDesc" type="text" value="' + esc(a.description) + '">';
    h += '<label>Details (plain-language explanation; empty = omit)</label><textarea id="eDet" rows="2">' + esc(a.details || "") + "</textarea>";
    h += '<label>Effort</label><select id="eEff">' + effs.map(function (e) { return "<option" + (e === a.required_effort ? " selected" : "") + ">" + esc(e) + "</option>"; }).join("") + "</select>";
    if (a.field_need !== undefined || S.ach.order.some(function (x) { return S.achCur[x].field_need !== undefined; })) {
      h += '<label>Field need</label><select id="eNeed">' + ["enter", "engage", "beat"].map(function (e) { return "<option" + (e === a.field_need ? " selected" : "") + ">" + e + "</option>"; }).join("") + "</select>";
    }
    h += '<label><input id="eUntr" type="checkbox"' + (a.untrackable ? " checked" : "") + "> Untrackable (excluded location, filler only)</label>";
    h += '<label><input id="eVc" type="checkbox"' + (a.vanilla_correction ? " checked" : "") + "> Vanilla correction (description is wrong vs. game code)</label>";
    h += '<label>Last checked</label><div class="row2"><input id="eChk" type="date" value="' + esc(a.last_checked || "") + '"><button class="btn" id="eToday">Checked today</button><button class="btn ghost" id="eClr">Clear</button></div>';
    h += '<div class="row2" style="margin-top:14px"><button class="btn ghost danger" id="eRevert">Revert this achievement</button></div></div>';
    return h;
  }
  function wireAchForm(n) {
    var nested = Array.isArray((S.ach.entries[n].original.requirements || [])[0]);
    function upd() {
      var a = C.plain(S.achCur[n]);
      a.requirements = textToReqs($("eReq").value, nested);
      a.description = $("eDesc").value;
      var det = $("eDet").value.trim();
      if (det) a.details = det; else delete a.details;
      a.required_effort = $("eEff").value;
      if ($("eNeed")) a.field_need = $("eNeed").value;
      if ($("eUntr").checked) a.untrackable = true; else delete a.untrackable;
      if ($("eVc").checked) a.vanilla_correction = true; else delete a.vanilla_correction;
      var d = $("eChk").value;
      if (d) a.last_checked = d; else delete a.last_checked;
      S.achCur[n] = a;
      $("eReqPrev").innerHTML = reqsHtml(a.requirements);
      changed();
      $("dView").innerHTML = achView(n);
    }
    $("eReqPrev").innerHTML = reqsHtml(S.achCur[n].requirements);
    ["eReq", "eDesc", "eDet", "eEff", "eNeed", "eUntr", "eVc", "eChk"].forEach(function (id) {
      var el = $(id);
      if (el) el.addEventListener(el.tagName === "SELECT" || el.type === "checkbox" || el.type === "date" ? "change" : "input", upd);
    });
    $("eTok").addEventListener("keydown", function (ev) {
      if (ev.key !== "Enter") return;
      ev.preventDefault();
      var t = this.value.trim();
      if (!t) return;
      var ta = $("eReq");
      var lines = ta.value.replace(/\s+$/, "").split("\n");
      if (lines.length === 1 && !lines[0]) lines[0] = t;
      else lines[lines.length - 1] += (lines[lines.length - 1].trim() ? ", " : "") + t;
      ta.value = lines.join("\n");
      this.value = "";
      upd();
    });
    $("eToday").onclick = function () { $("eChk").value = today(); upd(); };
    $("eClr").onclick = function () { $("eChk").value = ""; upd(); };
    $("eRevert").onclick = function () { S.achCur[n] = C.plain(S.ach.entries[n].original); changed(); achDrawer(n); };
  }

  // ---------------------------------------------------------------- fields
  var MONSTER_FIELDS = /^(Wave|Monster|Reaver|Swarmling|Giant|Callable|MarkedMonster)/;
  function stageSortKey(sid) { return sid[0] + ("00" + sid.slice(1)).slice(-3); }
  function filteredLv() {
    var q = $("qf").value.trim().toLowerCase(), tile = $("fTile").value, ck = $("fFieldChecked").value;
    return S.lv.order.slice().sort(function (a, b) { return stageSortKey(a).localeCompare(stageSortKey(b)); }).filter(function (sid) {
      var d = S.lvCur[sid], st = S.stageById[sid] || {};
      if (tile && sid[0] !== tile) return false;
      if (ck) {
        var age = ageDays(d.last_checked);
        if (ck === "never" && age !== null) return false;
        if (ck === "checked" && age === null) return false;
        if (/^\d+$/.test(ck) && age !== null && age <= +ck) return false;
      }
      if (q) {
        var hay = (sid + " " + Object.keys(d).join(" ") + " " + JSON.stringify(d.requirements || []) + " " + (st.required_skills || []).join(" ") + " " + (st.available_gems || []).join(" ")).toLowerCase();
        if (hay.indexOf(q) < 0) return false;
      }
      return true;
    });
  }
  function elementsHtml(d) {
    var els = Object.keys(d).filter(function (k) { return /Count$/.test(k) && !MONSTER_FIELDS.test(k) && d[k]; });
    if (!els.length) return '<span class="muted">—</span>';
    return '<div class="chips">' + els.map(function (k) { return '<span class="badge">' + esc(k.replace(/Count$/, "")) + " " + esc(d[k]) + "</span>"; }).join("") + "</div>";
  }
  function renderLv() {
    var list = filteredLv();
    var hasTree = Object.keys(S.tree).length > 0;
    var h = "<thead><tr><th>Field</th>" + (hasTree ? "<th>Vanilla parent</th>" : "") + "<th>Gate (WIZLOCK + extra requirements)</th><th>Gems</th><th>Waves / monsters</th><th>Elements</th><th>Last checked</th></tr></thead><tbody>";
    h += list.map(function (sid) {
      var d = S.lvCur[sid], st = S.stageById[sid] || {}, t = S.tree[sid];
      var gate = (st.required_skills || []).map(chip).join("");
      var extra = C.normalizeReqs(d.requirements).length ? reqsHtml(d.requirements) : "";
      return '<tr class="row' + (isDirtyLv(sid) ? " dirtyrow" : "") + '" data-lv="' + esc(sid) + '">' +
        '<td class="name">' + esc(sid) + "<small>" + esc((d.type || st.type || "").replace(/_/g, " ").toLowerCase()) + "</small></td>" +
        (hasTree ? '<td class="nowrap">' + (t ? (t.parent ? esc(t.parent) + ' <span class="muted">via ' + esc(t.via) + " · depth " + esc(t.depth) + "</span>" : '<span class="muted">root</span>') : "—") + "</td>" : "") +
        '<td><div class="chips">' + (gate || '<span class="muted">no WIZLOCK</span>') + "</div>" + (extra ? '<div style="margin-top:4px">' + extra + "</div>" : "") + "</td>" +
        "<td>" + esc((st.available_gems || []).join(", ")) + "</td>" +
        '<td class="nowrap">' + esc(d.WaveCount || st.wave_count || "") + " / " + esc(d.MonsterCount || "") + "</td>" +
        "<td>" + elementsHtml(d) + "</td>" +
        "<td>" + checkedHtml(d.last_checked) + "</td></tr>";
    }).join("") + "</tbody>";
    $("lvTable").innerHTML = h;
    $("lvCount").textContent = list.length + " of " + S.lv.order.length;
    $("cntLv").textContent = S.lv.order.length;
  }
  function lvDrawer(sid) {
    var d = S.lvCur[sid];
    var h = '<div id="dView">' + lvView(sid) + "</div>";
    if (S.edit) {
      h += '<h3>Edit</h3><div class="form">' + tokenDatalist() +
        '<label>Extra requirements: one OR-option per line, tags separated by commas</label><textarea id="lReq" rows="3" spellcheck="false">' + esc(reqsToText(d.requirements)) + "</textarea>" +
        '<div class="preview" id="lReqPrev"></div>' +
        '<label>Last checked</label><div class="row2"><input id="lChk" type="date" value="' + esc(d.last_checked || "") + '"><button class="btn" id="lToday">Checked today</button><button class="btn ghost" id="lClr">Clear</button></div>' +
        '<div class="row2" style="margin-top:14px"><button class="btn ghost danger" id="lRevert">Revert this field</button></div></div>';
    }
    openDrawer("Field " + sid, h, "lv:" + sid);
    if (!S.edit) return;
    function upd() {
      var v = C.plain(S.lvCur[sid]);
      var r = textToReqs($("lReq").value, true);
      if (r.length) v.requirements = r; else delete v.requirements;
      var c = $("lChk").value;
      if (c) v.last_checked = c; else delete v.last_checked;
      S.lvCur[sid] = v;
      $("lReqPrev").innerHTML = reqsHtml(v.requirements);
      changed();
      $("dView").innerHTML = lvView(sid);
    }
    $("lReqPrev").innerHTML = reqsHtml(d.requirements);
    $("lReq").addEventListener("input", upd);
    $("lChk").addEventListener("change", upd);
    $("lToday").onclick = function () { $("lChk").value = today(); upd(); };
    $("lClr").onclick = function () { $("lChk").value = ""; upd(); };
    $("lRevert").onclick = function () { S.lvCur[sid] = C.plain(S.lv.entries[sid].original); changed(); lvDrawer(sid); };
  }
  function lvView(sid) {
    var d = S.lvCur[sid], st = S.stageById[sid] || {}, t = S.tree[sid];
    var h = '<dl class="kv">';
    if (t) h += "<dt>Vanilla parent</dt><dd>" + (t.parent ? esc(t.parent) + " (via " + esc(t.via) + "), depth " + esc(t.depth) : "root") + "</dd>";
    h += "<dt>WIZLOCK</dt><dd>" + ((st.required_skills || []).length ? '<div class="chips">' + st.required_skills.map(chip).join("") + "</div>" : "none") + ' <span class="muted">(game_data.json)</span></dd>';
    h += "<dt>Gems</dt><dd>" + esc((st.available_gems || []).join(", ")) + "</dd>";
    h += "<dt>AP ids</dt><dd>token item " + esc(st.item_ap_id) + " · journey " + esc(st.loc_ap_id) + " · stash " + esc(st.wiz_stash_loc_ap_id) + "</dd>";
    h += "<dt>Last checked</dt><dd>" + checkedHtml(d.last_checked) + "</dd>";
    Object.keys(d).forEach(function (k) {
      if (k === "requirements" || k === "last_checked") return;
      h += "<dt>" + esc(k) + "</dt><dd>" + esc(Array.isArray(d[k]) ? d[k].join(", ") : d[k]) + "</dd>";
    });
    h += "</dl><h3>Extra requirements</h3>" + explainReqs(d.requirements);
    var users = S.ach.order.filter(function (n) { return [].concat.apply([], C.normalizeReqs(S.achCur[n].requirements)).indexOf("Field_" + sid) >= 0; });
    if (users.length) h += "<h3>Achievements requiring Field_" + esc(sid) + "</h3><p>" + users.map(function (n) { return '<button class="linkbtn" data-open-ach="' + esc(n) + '">' + esc(n) + "</button>"; }).join(", ") + "</p>";
    return h;
  }

  // ---------------------------------------------------------------- stash keys & gem pouches (mirrors gating.py)
  function parseChoice(src, cls) {
    var m = new RegExp("class " + cls + "\\(Choice\\):([\\s\\S]*?)(?=\\nclass |$)").exec(src || "");
    if (!m) return null;
    var opts = [], def = null, re = /^\s+option_(\w+)\s*=\s*(\d+)/gm, x;
    while ((x = re.exec(m[1]))) opts.push([x[1], +x[2]]);
    var d = /^\s+default\s*=\s*(\d+)/m.exec(m[1]);
    if (d) def = +d[1];
    var dn = /display_name\s*=\s*"([^"]+)"/.exec(m[1]);
    return { opts: opts, def: def, name: dn ? dn[1] : cls };
  }
  function gatingConsts() {
    var g = S.files["gating.py"] || "";
    function num(n, f) { var m = new RegExp("^" + n + "\\s*=\\s*(\\d+)", "m").exec(g); return m ? +m[1] : f; }
    function str(n, f) { var m = new RegExp("^" + n + "\\s*=\\s*\"([^\"]+)\"", "m").exec(g); return m ? m[1] : f; }
    var order;
    try { order = C.findAssign(S.files["rulesdata.py"] || "", "PROGRESSIVE_TILE_ORDER"); } catch (e) { order = null; }
    return {
      found: !!g,
      order: order || null,
      STASH_OFF: num("STASH_OFF", 0), STASH_PER_TILE: num("STASH_PER_TILE", 1), STASH_PER_TILE_PROGRESSIVE: num("STASH_PER_TILE_PROGRESSIVE", 2), STASH_GLOBAL: num("STASH_GLOBAL", 5),
      POUCH_OFF: num("POUCH_OFF", 0), POUCH_PER_TILE: num("POUCH_PER_TILE", 1), POUCH_PER_TILE_PROGRESSIVE: num("POUCH_PER_TILE_PROGRESSIVE", 2), POUCH_GLOBAL: num("POUCH_GLOBAL", 5),
      FIELD_PER_STAGE: num("FIELD_PER_STAGE", 0), FIELD_PER_STAGE_PROGRESSIVE: num("FIELD_PER_STAGE_PROGRESSIVE", 1), FIELD_PER_TILE: num("FIELD_PER_TILE", 2), FIELD_PER_TILE_PROGRESSIVE: num("FIELD_PER_TILE_PROGRESSIVE", 3),
      PROG_POUCH: str("PROG_GEMPOUCH_PER_TILE_NAME", "Progressive Gempouch"),
      PROG_STASH_TILE: str("PROG_STASH_PER_TILE_NAME", "Progressive Stash Tile Key"),
      PROG_FIELD_STAGE: str("PROG_FIELD_PER_STAGE_NAME", "Progressive Field Token (per-stage)"),
      PROG_FIELD_TILE: str("PROG_FIELD_PER_TILE_NAME", "Progressive Field Token (per-tile)"),
    };
  }
  function renderGating() {
    var K = gatingConsts();
    var opt = {
      field: parseChoice(S.files["options.py"], "FieldTokenGranularity"),
      stash: parseChoice(S.files["options.py"], "StashKeyGranularity"),
      pouch: parseChoice(S.files["options.py"], "GemPouchGranularity"),
    };
    var saved = load("gcfw-rules-gating") || {};
    var startSel = saved.start || "W1";
    var sel = {};
    function selHtml(key, o) {
      if (!o) return "";
      var v = saved[key] !== undefined && o.opts.some(function (p) { return p[1] === saved[key]; }) ? saved[key] : o.def;
      sel[key] = v;
      return "<label>" + esc(o.name) + ' <select data-gopt="' + key + '">' + o.opts.map(function (p) { return '<option value="' + p[1] + '"' + (p[1] === v ? " selected" : "") + ">" + esc(p[0]) + "</option>"; }).join("") + "</select></label>";
    }
    var sids = S.lv.order.slice().sort(function (a, b) { return stageSortKey(a).localeCompare(stageSortKey(b)); });
    $("gatingOpts").innerHTML = selHtml("field", opt.field) + selHtml("stash", opt.stash) + selHtml("pouch", opt.pouch) +
      '<label>Starting stage <select data-gopt="start">' + sids.map(function (s) { return "<option" + (s === startSel ? " selected" : "") + ">" + s + "</option>"; }).join("") + "</select></label>";
    [].forEach.call($("gatingOpts").querySelectorAll("select"), function (s) {
      s.onchange = function () {
        var cur = load("gcfw-rules-gating") || {};
        cur[s.dataset.gopt] = s.dataset.gopt === "start" ? s.value : +s.value;
        store("gcfw-rules-gating", cur);
        renderGating();
      };
    });
    var order = K.order || sids.map(function (s) { return s[0]; }).filter(function (t, i, a) { return a.indexOf(t) === i; });
    var startTile = startSel[0];
    var progOrder = [startTile].concat(order.filter(function (t) { return t !== startTile; }));
    var fGran = sel.field, sGran = sel.stash, pGran = sel.pouch;
    var freeTile = fGran === K.FIELD_PER_TILE || fGran === K.FIELD_PER_TILE_PROGRESSIVE;
    function stashFor(tile) {
      if (!opt.stash || sGran === K.STASH_OFF) return '<span class="muted">not gated</span>';
      if (sGran === K.STASH_PER_TILE) return esc("Wizard Stash Tile " + tile + " Key");
      if (sGran === K.STASH_PER_TILE_PROGRESSIVE) return esc(K.PROG_STASH_TILE) + " ×" + (progOrder.indexOf(tile) + 1);
      if (sGran === K.STASH_GLOBAL) return "Wizard Stash Master Key";
      return "?";
    }
    function pouchFor(tile) {
      if (!opt.pouch || pGran === K.POUCH_OFF) return '<span class="muted">not gated</span>';
      var base;
      if (pGran === K.POUCH_PER_TILE) base = esc("Gempouch (" + tile + ")");
      else if (pGran === K.POUCH_PER_TILE_PROGRESSIVE) base = esc(K.PROG_POUCH) + " ×" + (progOrder.indexOf(tile) + 1);
      else if (pGran === K.POUCH_GLOBAL) base = "Master Gempouch";
      else base = "?";
      return base;
    }
    function tokenFor(tile, tileSids) {
      if (!opt.field) return "—";
      if (fGran === K.FIELD_PER_STAGE) return "one “&lt;field&gt; Field Token” per field";
      if (fGran === K.FIELD_PER_TILE) return esc(tile + " Tile Field Token");
      if (fGran === K.FIELD_PER_TILE_PROGRESSIVE) return esc(K.PROG_FIELD_TILE) + " ×" + (progOrder.indexOf(tile) + 1);
      if (fGran === K.FIELD_PER_STAGE_PROGRESSIVE) return esc(K.PROG_FIELD_STAGE) + " ×N (by field position)";
      return "?";
    }
    var h = "<thead><tr><th>Tile</th><th>Fields</th><th>Field token</th><th>Stash key (stash check)</th><th>Gem pouch (gems on the field)</th></tr></thead><tbody>";
    order.forEach(function (tile) {
      var tileSids = sids.filter(function (s) { return s[0] === tile; });
      if (!tileSids.length) return;
      var noPouch = tileSids.filter(function (s) { return !((S.stageById[s] || {}).required_skills || []).some(function (r) { return r.indexOf("gemPouch:") === 0; }); });
      var free = freeTile ? tile === startTile : false;
      var pouch = pouchFor(tile);
      if (free && pGran !== K.POUCH_OFF) pouch += ' <span class="badge" title="Free starter fields skip the pouch gate (Hollow Gems substitute)">free on starter tile</span>';
      if (!freeTile && pGran !== K.POUCH_OFF && tile === startTile) pouch += ' <span class="badge">' + esc(startSel) + " exempt (starter)</span>";
      if (noPouch.length && pGran !== K.POUCH_OFF) pouch += ' <span class="badge" title="No gemPouch WIZLOCK in game_data.json">no pouch gate: ' + esc(noPouch.join(", ")) + "</span>";
      h += '<tr><td class="name">' + esc(tile) + (progOrder.indexOf(tile) >= 0 ? "<small>#" + (progOrder.indexOf(tile) + 1) + " in order</small>" : "") + "</td>" +
        "<td>" + esc(tileSids.join(", ")) + "</td><td>" + tokenFor(tile, tileSids) + "</td><td>" + stashFor(tile) + "</td><td>" + pouch + "</td></tr>";
    });
    $("gatingTable").innerHTML = h + "</tbody>";
    $("gatingExplain").innerHTML =
      "<p><b>Stash keys and gem pouches have no hand-written requirements.</b> They are derived from the YAML options by <code>gating.py</code>; this table mirrors that logic for the chosen options. Progressive items unlock tiles in <code>PROGRESSIVE_TILE_ORDER</code>" + (K.order ? "" : " (not found: alphabetical shown)") + ", with the starting tile moved to the front.</p>" +
      "<p><b>Wizard stash check</b> (<code>Complete &lt;field&gt; - Wizard stash</code>) = everything the field's journey check needs + the stash key. " +
      "<b>Gem pouch</b> = the field's <code>gemPouch:&lt;tile&gt;</code> WIZLOCK from <code>game_data.json</code>; without it only Hollow Gems are available there, which clear the field but don't count for gem-type achievements.</p>" +
      (K.found ? "" : '<p class="warnline">gating.py not loaded: built-in defaults used.</p>');
  }

  // ---------------------------------------------------------------- legend
  function usage() {
    var u = {};
    function add(t, where) { var b = tagBase(t); (u[b] = u[b] || { ach: 0, lv: 0 })[where]++; }
    S.ach.order.forEach(function (n) { [].concat.apply([], C.normalizeReqs(S.achCur[n].requirements)).forEach(function (t) { add(t, "ach"); }); });
    S.lv.order.forEach(function (n) { [].concat.apply([], C.normalizeReqs(S.lvCur[n].requirements)).forEach(function (t) { add(t, "lv"); }); });
    S.stages.forEach(function (s) { (s.required_skills || []).forEach(function (t) { add(t, "lv"); }); });
    return u;
  }
  function maxOf(fields) {
    if (typeof fields === "string") fields = [fields];
    var m = 0;
    S.lv.order.forEach(function (s) { fields.forEach(function (f) { m = Math.max(m, S.lvCur[s][f] || 0); }); });
    return m;
  }
  function renderLegend() {
    var V = S.V, u = usage();
    function useCell(base) {
      var x = u[base];
      if (!x) return '<td class="use muted">unused</td>';
      return '<td class="use">' + (x.ach ? '<button class="linkbtn" data-tag="' + esc(base) + '">' + x.ach + " achievement" + (x.ach > 1 ? "s" : "") + "</button>" : "") + (x.lv ? (x.ach ? " · " : "") + x.lv + " field use" + (x.lv > 1 ? "s" : "") : "") + "</td>";
    }
    function sec(title, lead, rows) {
      return '<div class="legend-sec"><h3>' + title + "</h3>" + (lead ? '<p class="lead">' + lead + "</p>" : "") + "<table>" + rows.join("") + "</table></div>";
    }
    function row(tok, meaning, base) { return '<tr><td><span class="chip">' + esc(tok) + "</span></td><td>" + meaning + "</td>" + useCell(base || tok) + "</tr>"; }
    var h = "";
    h += '<div class="legend-sec"><h3>How requirements work</h3>' +
      "<p>A requirement is a list of tags that must <b>all</b> be met (AND). A list of lists is a set of alternatives: <b>any one</b> inner list is enough (OR of ANDs, \"DNF\"). In the tables an OR option is drawn as a dashed box.</p>" +
      "<p>Tags that point to a field (elements, field stats) are bound to the <b>same</b> field when they sit in one AND list: <code>[eShrine, minWave:50]</code> means one field with both a shrine and 50 waves.</p>" +
      '<p>Tag colours: <span class="chip">ok</span> recognised · <span class="chip warn">warning</span> recognised but always passes (stub / pacing) · <span class="chip never">never</span> intentionally never in logic (mode not in the randomizer) · <span class="chip error">error</span> unknown tag, or a count no field reaches. Hover a tag to see what it means.</p>' +
      "<p>Everything below is read live from <code>requirement_tokens.py</code>, <code>rulesdata_settings.py</code>, <code>rules.py</code> and the field data, so the legend follows the loaded branch.</p></div>";

    h += sec("Skills (s…)", "The skill item must be received. Gem skills also need a field where you can actually make gems (its pouch), or a field that already offers that gem.",
      Object.keys(V.skills).map(function (t) { return row(t, esc(V.skills[t]) + (V.gemTokens[t] ? ' <span class="badge">gem: ' + esc(V.gemTokens[t]) + "</span>" : "")); }));
    h += sec("Battle traits (t…)", "The battle-trait item must be received.",
      Object.keys(V.traits).map(function (t) { return row(t, esc(V.traits[t])); }));
    var elRows = Object.keys(V.elements).map(function (t) {
      var names = V.elements[t];
      var f = names.length === 1 ? C.elementCountField(names[0]) : null;
      var pascal = f ? f.replace(/Count$/, "") : null;
      var extra = "";
      if (pascal && V.stubElements.indexOf(pascal) >= 0) extra += ' <span class="badge vc">stub: always passes</span>';
      else if (pascal === "WizardStash") extra += ' <span class="badge">uses stash keys; :N = N stashes openable</span>';
      else if (f && V.presentCountFields[f]) extra += ' <span class="badge">' + esc(t) + ":N up to " + maxOf(f) + "</span>";
      else if (f) extra += ' <span class="badge">no per-field count: :N errors</span>';
      if (V.interactSkill[t]) extra += ' <span class="badge">also needs ' + esc(V.interactSkill[t]) + "</span>";
      return row(t, (names.length > 1 ? "Any of: " : "") + esc(names.join(", ")) + extra);
    });
    h += sec("Elements and weather (e… / w…)", "A field reachable in logic that contains the element. <code>eX:N</code> = a field with at least N of them (count read from <code>&lt;X&gt;Count</code> in rulesdata_levels.py; a count no field reaches is an error).", elRows);
    h += sec("Field stats (name:N)", "A field reachable in logic whose stat is at least N. The maximum is the largest value on any field: higher can never be met.",
      Object.keys(V.levelStats).map(function (t) {
        var f = V.levelStats[t];
        return row(t + ":N", esc(typeof f === "string" ? f : f.join(" or ")) + ' <span class="badge">max ' + maxOf(f) + "</span>", t);
      }));
    h += sec("Skill pools (name:N)", "At least N of the listed items received. <code>gemSkills:N</code> is special: a single beatable field must allow N gem types (its pouch + held skills).",
      Object.keys(V.pools).map(function (t) {
        var names = V.pools[t].map(function (x) { return x.replace(/ (Skill|Battle Trait)$/, ""); });
        return row(t + ":N", esc(V.poolDesc[t] || "") + ' <span class="badge">' + names.length + " items</span><br><span class=\"muted\">" + esc(names.join(", ")) + "</span>", t);
      }));
    h += sec("Talismans", "Counted from progression talisman fragments the player holds.",
      V.talismanCounters.map(function (t) { return row(t + ":N", "Hold at least N fragments of this kind" + (t === "talismanFragments" && Object.keys(V.talismanFloor).length ? " (floor: " + esc(JSON.stringify(V.talismanFloor)) + " fields unlocked)" : ""), t); })
        .concat(Object.keys(V.talismanProps).map(function (t) { return row(t + ":N", "Summed talisman property #" + V.talismanProps[t] + " of held fragments (at max upgrade) ≥ N", t); })));
    var spDesc = {
      min_wl: "Wizard-level floor. Not checked inside the requirement; enforced as a separate WL gate on the location.",
      fieldToken: "At least N fields clearable in logic.",
      talismanRow: "At least N complete talisman rows.",
      talismanColumn: "At least N complete talisman columns.",
      skillPoints: "Pacing only: always passes on the server (skill points are filler). The mod still tracks it for the tooltip.",
      gemPouch: "Field WIZLOCK only (<code>gemPouch:&lt;tile&gt;</code> in game_data.json): the tile's gem pouch.",
      talismanFragments: "See Talismans.",
    };
    h += sec("Special counters", "Handled by dedicated branches in <code>rules.py</code> <code>_compile_req</code>.",
      V.specialCounters.filter(function (t) { return V.talismanCounters.indexOf(t) < 0; }).map(function (t) { return row(t === "gemPouch" ? "gemPouch:<tile>" : t + ":N", spDesc[t] || '<span class="muted">no legend text yet: see rules.py</span>', t); }));
    h += sec("References", "", [
      row("Field_<sid>", "That exact field must be clearable (beatable) in logic. Also binds the AND list to that field.", "Field_"),
      row("Achievement:<name>", "Another achievement location must be reachable. Only checked under progressive field-token modes; ignored otherwise.", "Achievement:"),
    ]);
    h += sec("Modes (m…)", "Endurance / Trial are not part of the randomizer. Any AND list containing one is never in logic: keep it only as documentation of the vanilla requirement.",
      V.modes.map(function (t) { return row(t, "never satisfiable"); }));
    var docA = C.moduleDocstring(S.files["rulesdata_achievements.py"]);
    var docL = C.moduleDocstring(S.files["rulesdata_levels.py"]);
    h += '<div class="legend-sec"><h3>Entry keys</h3><p class="lead"><code>last_checked</code> ("YYYY-MM-DD") is the date someone last verified the entry in-game; the apworld ignores it. The rest is documented in the file headers:</p>' +
      "<pre>" + esc(docA) + "</pre>" + (docL ? '<p class="lead" style="margin-top:8px">rulesdata_levels.py</p><pre>' + esc(docL) + "</pre>" : "") + "</div>";
    $("legend").innerHTML = h;
  }

  // ---------------------------------------------------------------- problems
  function renderProblems() {
    var tracked = [], untr = [], warns = [], nevers = [], lvp = [];
    S.ach.order.forEach(function (n) {
      var a = S.achCur[n];
      C.normalizeReqs(a.requirements).forEach(function (g) {
        g.forEach(function (t) {
          var r = cls(t);
          var item = '<li><button class="linkbtn" data-open-ach="' + esc(n) + '">' + esc(n) + "</button> " + chip(t) + " " + esc(r.text) + "</li>";
          if (r.status === "error") (a.untrackable ? untr : tracked).push(item);
          else if (r.status === "warn") warns.push(item);
        });
        if (g.some(function (t) { return cls(t).status === "never"; })) nevers.push(n);
      });
    });
    S.lv.order.forEach(function (sid) {
      [].concat.apply([], C.normalizeReqs(S.lvCur[sid].requirements)).concat((S.stageById[sid] || {}).required_skills || []).forEach(function (t) {
        var r = cls(t);
        if (r.status !== "ok") lvp.push('<li><button class="linkbtn" data-open-lv="' + esc(sid) + '">' + esc(sid) + "</button> " + chip(t) + " " + esc(r.text) + "</li>");
      });
    });
    var w = S.warnings.concat(S.vocabWarnings || []);
    function box(title, items, lead, collapsed) {
      if (!items.length) return "";
      var body = "<ul>" + items.join("") + "</ul>";
      return '<div class="prob"><h3>' + title + " (" + items.length + ")</h3>" + (lead ? '<p class="muted">' + lead + "</p>" : "") + (collapsed ? "<details><summary>show</summary>" + body + "</details>" : body) + "</div>";
    }
    var h = "";
    h += box("Parse warnings", w.map(function (x) { return "<li>" + esc(x) + "</li>"; }), "The viewer could not read part of the vocabulary; validation may be off.");
    h += box("Draft conflicts", (S.conflicts || []).map(function (n) { return "<li>" + esc(n) + "</li>"; }), "Your unsaved edits were made against an older version of these entries. Review them before exporting.");
    h += box("Errors in tracked achievements", tracked, "These generate as real locations. An unknown tag makes generation raise; an unreachable count makes that OR option dead.");
    h += box("Errors in untrackable achievements", untr, "Excluded locations: informational only.", true);
    h += box("Field problems", lvp, "");
    h += box("Warnings", warns, "Recognised tags that always pass (stubs, pacing tokens).", true);
    h += box("Achievements with a never-in-logic option", nevers.map(function (n) { return '<li><button class="linkbtn" data-open-ach="' + esc(n) + '">' + esc(n) + "</button>" + (C.normalizeReqs(S.achCur[n].requirements).every(function (g) { return g.some(function (t) { return cls(t).status === "never"; }); }) ? ' <span class="badge untrack">all options never</span>' : "") + "</li>"; }), "At least one OR option uses an Endurance/Trial mode tag.", true);
    if (!h) h = '<div class="prob"><h3>No problems found</h3></div>';
    $("problems").innerHTML = h;
    var bad = tracked.length + lvp.filter(function (x) { return x.indexOf("chip error") >= 0; }).length;
    $("cntProb").textContent = bad || "";
    $("cntProb").className = bad ? "bad" : "";
  }

  // ---------------------------------------------------------------- drawer / tabs / hash
  function openDrawer(title, html, key) {
    S.drawer = key;
    $("drawerTitle").textContent = title;
    $("drawerBody").innerHTML = html;
    $("drawer").hidden = false;
    setHash();
  }
  function closeDrawer() { S.drawer = null; $("drawer").hidden = true; setHash(); }
  function setTab(t) {
    S.tab = t;
    [].forEach.call(document.querySelectorAll("#tabs button"), function (b) { b.classList.toggle("on", b.dataset.tab === t); });
    [].forEach.call(document.querySelectorAll(".tab"), function (s) { s.classList.toggle("on", s.id === "tab-" + t); });
    setHash();
  }
  function setHash() {
    var p = new URLSearchParams();
    if (S.tab !== "achievements") p.set("tab", S.tab);
    if (S.drawer) p.set("open", S.drawer);
    var h = p.toString();
    history.replaceState(null, "", location.pathname + location.search + (h ? "#" + h : ""));
  }
  function applyHash() {
    var p = new URLSearchParams(location.hash.slice(1));
    if (p.get("tab")) setTab(p.get("tab"));
    var o = p.get("open");
    if (o && o.indexOf("ach:") === 0 && S.achCur[o.slice(4)]) achDrawer(o.slice(4));
    if (o && o.indexOf("lv:") === 0 && S.lvCur[o.slice(3)]) lvDrawer(o.slice(3));
  }
  function changed() {
    saveDrafts();
    rebuildVocab();
    renderEditBar();
    renderAch();
    renderLv();
    renderProblems();
    clearTimeout(changed.t);
    changed.t = setTimeout(renderLegend, 300);
  }

  // ---------------------------------------------------------------- export
  function download(name, text) {
    var blob = new Blob([text], { type: "text/x-python" });
    var a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = name;
    document.body.appendChild(a);
    a.click();
    setTimeout(function () { URL.revokeObjectURL(a.href); a.remove(); }, 1000);
  }
  function exportAch() {
    download("rulesdata_achievements.py", C.exportEntryFile(S.ach, S.achCur, { style: "achievements", keyRank: ACH_KEY_RANK }));
  }
  function exportLv() {
    download("rulesdata_levels.py", C.exportEntryFile(S.lv, S.lvCur, { style: "levels", keyRank: LV_KEY_RANK }));
  }

  // ---------------------------------------------------------------- wiring
  function wire() {
    $("tabs").onclick = function (e) { var b = e.target.closest("button"); if (b) setTab(b.dataset.tab); };
    ["q", "fEffort", "fNeed", "fStatus", "fChecked", "fSort"].forEach(function (id) { $(id).addEventListener("input", renderAch); });
    ["qf", "fTile", "fFieldChecked"].forEach(function (id) { $(id).addEventListener("input", renderLv); });
    $("achTable").onclick = function (e) { var r = e.target.closest("tr[data-ach]"); if (r) achDrawer(r.dataset.ach); };
    $("lvTable").onclick = function (e) { var r = e.target.closest("tr[data-lv]"); if (r) lvDrawer(r.dataset.lv); };
    document.body.addEventListener("click", function (e) {
      var b = e.target.closest("[data-open-ach]");
      if (b) { achDrawer(b.dataset.openAch); return; }
      b = e.target.closest("[data-open-lv]");
      if (b) { lvDrawer(b.dataset.openLv); return; }
      b = e.target.closest("[data-tag]");
      if (b) { S.tagFilter = b.dataset.tag; setTab("achievements"); renderAch(); window.scrollTo(0, 0); }
    });
    $("drawerClose").onclick = closeDrawer;
    document.addEventListener("keydown", function (e) { if (e.key === "Escape" && !$("drawer").hidden) closeDrawer(); });
    $("editToggle").onchange = function () {
      S.edit = this.checked;
      renderEditBar();
      if (S.drawer) applyDrawer(S.drawer);
    };
    $("exportAch").onclick = exportAch;
    $("exportLv").onclick = exportLv;
    $("discardBtn").onclick = function () {
      if (!confirm("Discard all unsaved edits?")) return;
      S.ach.order.forEach(function (n) { S.achCur[n] = C.plain(S.ach.entries[n].original); });
      S.lv.order.forEach(function (n) { S.lvCur[n] = C.plain(S.lv.entries[n].original); });
      S.conflicts = [];
      changed();
      if (S.drawer) applyDrawer(S.drawer);
    };
    $("bulkCheck").onclick = function () {
      var list = filteredAch();
      if (!confirm("Set last_checked = " + today() + " on " + list.length + " achievement(s)?")) return;
      list.forEach(function (n) { var a = C.plain(S.achCur[n]); a.last_checked = today(); S.achCur[n] = a; });
      changed();
    };
    $("reloadBtn").onclick = function () { loadFrom($("srcSelect").value); };
    $("fileInput").onchange = function () { if (this.files.length) openFiles(this.files); this.value = ""; };
  }
  function applyDrawer(key) {
    if (key.indexOf("ach:") === 0) achDrawer(key.slice(4));
    else if (key.indexOf("lv:") === 0) lvDrawer(key.slice(3));
  }

  wire();
  initSources();
  loadFrom($("srcSelect").value);
})();
