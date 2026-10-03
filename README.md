# enyofix: Enyo 2 apps on webOS 2.0 and 2.1

Enyo 2 apps such as Preware 2 open on webOS 2.0.x-2.1.x (verified on 2.0.1, 2.1.0 and 2.1.2) but display broken: panels collapse, popups that should
be hidden show up ("Message / I am a fish."), and screens never finish loading. This repo has the cause, a
small installable fix (`org.webosarchive.v8fix`), and the test results.

Tested on a meta-doctored Palm Pre Plus (castle) running HP webOS 2.1.0 (build Nova-WR-Castle 285,
WebKit 532.2), 2026-10-01/02. On 2026-10-03 the bug and the fix were also confirmed on an HP Veer running
HP webOS 2.1.2 (see "Which webOS versions" below).

## Cause: a V8 code generation bug, not the meta-doctor

The V8 JavaScript engine in webOS 2.1.0 (`/usr/lib/libv8.so`, dated 2011-03-03, the stock binary from the
Pre 2's 2.1.0 doctor) compiles this expression wrong with its default ("classic") code generator:

```js
var e = {};
(true ? false : 0) || (e.k = 1);   // e.k should be 1; on webOS 2.1.0 the assignment never runs
```

A conditional (`?:`) whose value is `false`, used as the left side of `||`, is treated as truthy, so the
right side is skipped. Storing the conditional in a variable first works. See
`research/probes/v8-ternary-microtests.js` for the cases that were checked.

UglifyJS turns Enyo 2's `enyo.mixin` into exactly that shape:

```js
a[l]!==t&&(r.exists&&!t||r.ignore&&e[l]||(r.filter?!r.filter(l,t,n,e,r):0)||(e[l]=t))
```

So on webOS 2.1.0, `enyo.mixin(target, src, {filter: fn})` copies nothing. Enyo uses that call to apply
its mixins (`ObserverSupport`, `BindingSupport`, ...) to every kind. The mixins' data defaults never
reach the prototypes:

- `_observing` and `_observeCount` stay `undefined`, the first `stopNotifications()` makes
  `_observeCount` `NaN`, and notifications never turn back on.
- No `*Changed` handler ever runs (`classesChanged`, `showingChanged`, ...). Controls keep the classes and
  visibility they were first rendered with, which gives the broken layouts.

Proof on the device: rewriting only that one minified function as plain `if` statements makes Preware 2
(and Love Voucher) render correctly in the 2.1.0 browser
(`research/results/screens/preware2-browser-*.png`, `lovevoucher-browser-unpatched-vs-patched.png`).

The meta-doctor itself is not involved.

### Which webOS versions

Each webOS Doctor's own `node` and `libv8.so` were run under qemu-arm (`-cpu cortex-a8`, the doctor's
rootfs as `-L`) with `research/probes/v8-ternary-bug.js` and `research/probes/v8-mixin-hot.js` (the real
minified mixin body, run 20,000 times so any optimizing tier gets a turn):

| Doctor | Build | `libv8.so` | Probe | Mixin, 20,000 runs | With `--always_full_compiler` |
|---|---|---|---|---|---|
| Palm webOS 2.0.1 (Pre 2) | Nova-WR-Roadrunner 79 | 3,512,177 B | bug | wrong every run | OK |
| HP webOS 2.1.0 (Pre Plus) | Nova-WR-Castle 285 | 3,515,430 B | bug | wrong every run | OK |
| HP webOS 2.1.2 (Veer, AT&T) | Nova-ATT-Broadway 2296 | 3,515,430 B (*) | bug | wrong every run | OK |
| HP webOS 2.2.0 (Pre 3) | Nova-WR-Mantaray 3171 | 4,092,932 B | OK | OK | OK |
| HP webOS 2.2.3 (Pre 3, AT&T) | Nova-ATT-Mantaray 2207 | 4,092,932 B | OK | OK | OK |

(*) Identical to 2.1.0's except 4 bytes, the `.gnu_debuglink` CRC: same code.

The emulator gives the same result as the 2.1.0 phone, and the Veer on 2.1.2 confirmed it on hardware
(bug present; v8fix 1.0.0 fixed it after a restart). webOS 2.2.x phones and 3.0.x TouchPads ship the newer V8
and need nothing. webOS 2.0.0 was not tested; the package
tests the device for the bug before patching, so it only changes a 2.0.0 phone that has it.

Why the "Enyo 1.0" package (`org.webosinternals.enyo`) doesn't help: it installs the Enyo 1 framework that
Enyo 1 apps load from the system. Enyo 2 apps bundle their own `enyo.js` and never load it, and the bug
is in the engine, not in a framework.

## The fix: `--always_full_compiler`

V8 in webOS 2.0.x-2.1.x also has a "full" code generator, which compiles this correctly. The V8 flag
`--always_full_compiler` makes it the only one used. LunaSysMgr, which runs every app, reads its V8 flags
from the `[JavaScript] Flags=` line in `/etc/palm/browser.conf`. The node binary links the same
`libv8.so`, which made it possible to test the flag safely:

| node run | result |
|---|---|
| default | bug |
| `--always_full_compiler` | correct |
| `--nofull_compiler`, `--noopt`, `--nooptimize_ast`, `--use_flow_graph`, `--nolazy` | bug |

Performance cost (node, same V8, `research/probes/v8-bench.js`): recursion-heavy code is about 25% slower,
while object, string and dictionary work is about the same or slightly faster.

On the device (LunaSysMgr, fresh Luna restart, the same 8-app workload each time:
Email, Contacts, Messaging, Calendar, Preware 2, Preware, Dash Weather, Browser):

| run | idle RSS | peak (VmHWM) | final RSS | Luna CPU during the workload |
|---|---|---|---|---|
| flag ON #1 | 41,364 kB | 53,508 kB | 53,420 kB | 367 ticks |
| flag OFF | 41,372 kB | 53,608 kB | 53,412 kB | 542 ticks |
| flag ON #2 | 41,032 kB | 54,012 kB | 53,196 kB | 359 ticks |

Memory is unchanged within noise. CPU was lower with the flag, but that rests on a single OFF run,
so read it as "no worse".

The web browser (BrowserServer) reads its flags from `/etc/palm/browser-app.conf`. The package leaves that
file alone, so web pages run exactly as before.

## The package: `v8fix/`

`v8fix/bin/org.webosarchive.v8fix_1.0.2_all.ipk` (6844 bytes, md5 `0cb23b2bfb3ca8b2a33399d3118a001a`).
It is also proposed for the WOSA Modernize feed (webOSArchive/preware-modernize-feed).
Rebuild it with `v8fix/build.sh`.

- **Install** (`postinst` / `pmPostInstall.script`, run as root):
  1. It does nothing unless `/etc/palm-build-info` says webOS **2.0.x or 2.1.x**. Preware's "ignore device"
     setting, WebOS Quick Install and plain `ipkg` skip the feed's version gate, so the script has
     its own.
  2. If the flag is already set, it does nothing.
  3. It also **tests for the bug** with the device's own node (same
     `libv8.so`). It patches only if the bug is present **and** the flag fixes it, so on any other webOS
     version it does nothing.
  4. It backs up `browser.conf` to `browser.conf.v8fix-orig`, appends the flag to the `Flags=` line of the
     `[JavaScript]` section only, checks the result, and restores the backup if the edit failed.
- **Remove** (`prerm`): removes only the flag token, so other changes to the file are kept, and deletes the
  backup. It does not restart Luna, because prerm can run inside LunaSysMgr.
- Restart Luna after installing or removing (`PostInstallFlags`/`PostRemoveFlags: RestartLuna`). If Enyo 2 apps
  still look broken (seen on the Veer after a WebOS Quick Install), restart the phone.
- No dependencies. Version gating lives in the feed index (`MinWebOSVersion` 2.0.0, `MaxWebOSVersion` 2.1.2),
  not in the control file, following the feed's conventions.

Tested install and remove paths on the device:

| Path | Result |
|---|---|
| Palm App Installer (`appinstaller/installNoVerify`, same as WebOS Quick Install / palm-install) | install OK, `pmPostInstall.script` applied the flag |
| Preware's package service (`ipkgservice/install` from an HTTP URL, same as a feed install) | install OK, `postinst` applied the flag |
| Preware's package service (`ipkgservice/remove`) | remove OK, `prerm` ran, `browser.conf` byte-identical to the original |
| Preware's package service, upgrade 1.0.0 -> 1.0.1 | OK, the flag stays set once |
| 1.0.1 postinst run against a fake 2.2.4 / 3.0.5 / 1.4.5 build-info | refuses ("for webOS 2.1.0 only"), `browser.conf` untouched |
| 1.0.0 via WebOS Quick Install on an HP Veer, webOS 2.1.2 (2026-10-03) | flag applied, Enyo 2 fixed after a restart |
| 1.0.2 postinst + prerm, dry run against the 2.0.1 / 2.1.0 / 2.1.2 / 2.2.0 / 2.2.3 doctors' own build-info, `browser.conf` and node (qemu) | 2.0.1 / 2.1.0 / 2.1.2: flag added once, reinstall adds nothing, prerm restores the file byte-identical. 2.2.0 / 2.2.3 and fake 1.4.5 / 2.2.4 / 3.0.5: refused, untouched |
| Palm App Installer remove | refused (`returnValue: false`): it only removes packages that have an `appinfo.json`. Remove the package from Preware. |

## Test results (summary; details in `research/results/RESULTS.md`)

90 launches, each done once with the flag OFF and once ON, comparing screenshots and JS errors:

- **No regressions found.** No app gained or lost a single JS error with the flag. All 40 Mojo apps (built-in
  and installed homebrew, including the original Preware, Internalz, FileMgr, Govnah and XWTweak) look the same,
  apart from live content such as clocks.
- **Web browsing unchanged:** 8 pages render identically OFF and ON. The two HTTPS-only sites fail in both
  passes because 2.1.0's TLS is too old.
- **Enyo 2 apps (11 from the feeds, plus Preware 2):**
  - Fixed: **Preware 2**, Dash Weather, FreeTether Cleaner and Love Voucher; My Local Vue is very likely
    fixed too (inferred, see RESULTS.md).
  - Working either way: StockWatch, London Tube Status, EM Wiki, Picross Demo.
  - Broken either way: Manga Reader and SIP CallManager ("Recursion too deep" in both).
  - Unknown: My Currency Calc (its screenshot is stale in both passes).
- **Enyo 1 apps (31 installable from the feeds):** unchanged; the system Enyo 1 framework does not hit
  the bug.
- **Preware 2 after the packaged fix and a clean Luna restart:** loads all feeds (Available 941,
  Installed 67, List of Everything 1008). See `research/results/screens/preware2-after-fix.png`.

Caveats:
- For a few apps (Love Voucher, My Local Vue, My Currency Calc, Photos), `takeScreenShot` returns the
  previous card's pixels instead of the app. Love Voucher's "blank" ON screenshot was checked by eye on
  the phone and showed the real UI.
- Launch-and-screenshot testing proves that apps start and render, not every feature. Preware 2 was also
  seen loading and counting its feeds, but installing or removing an app through Preware 2's UI was not
  driven, because there's no touch injection on this device.

## Repo layout

```
v8fix/                     the package (control scripts, payload README, build.sh, built ipk)
research/probes/           V8 bug reproductions and the benchmark (run with the device's node)
research/harness/          on-device test runner (runapps.sh/runall.sh), app lists, local HTTP server,
                           feed scanner (classify*.py) and OFF/ON comparison (compare.py)
research/results/          RESULTS.md, raw comparison, OFF|ON contact sheets for the Enyo apps and web pages
```

Note: `research/probes/v8test-toplevel.html` does **not** show the bug, because V8 compiles top-level page
code with the full compiler anyway. Put the test inside a function (as `v8-ternary-microtests.js` does) to
see it.
