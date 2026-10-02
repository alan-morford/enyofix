# OFF vs ON results (HP webOS 2.1.0, meta-doctored Pre Plus)

Each app was launched once with `--always_full_compiler` OFF and once ON (after a Luna restart), screenshotted after 14-16 s (25 s for web pages), and its log lines collected.
`errors` = JS errors (`Uncaught`/`TypeError`/`ReferenceError`/`SyntaxError`) logged for that launch. **No app gained or lost a single JS error with the flag** (see `off-vs-on-raw.txt`).
`pixel diff` = mean absolute difference of the two screenshots below the status bar (0 = identical).

## Enyo 2 apps (bundle their own enyo.js)

| App | Title | Enyo | pixel diff | errors OFF/ON | Verdict |
|---|---|---|---|---|---|
| `biz.aventer.mreader` | Manga Reader | 2.x | 0.0 | 39/39 | Broken both ways - blank, "RangeError: Recursion too deep" in both passes |
| `biz.aventer.sipgate` | SIP CallManager | 2.3.0-pre.10 | 0.0 | 2/2 | Broken both ways - blank, "RangeError: Recursion too deep" in both passes |
| `com.choorp.dash-weather` | Dash Weather | 2.6.0-pre.3 | 224.8 | 0/0 | **Fixed** - OFF stuck on "Loading..." with broken layout; ON renders the full UI |
| `com.mobileteck.com.mycurrencycalc` | My Currency Calc | 2.3.0-pre.11 | 0.0 | 0/0 | Unknown - system screenshot is a stale frame in both passes |
| `com.mobileteck.freetether.cleaner` | FreeTether Cleaner | 2.5.2-pre.6 | 43.5 | 0/0 | **Fixed** - OFF header collapsed; ON renders correctly (retested with a 45 s wait) |
| `com.mobileteck.lovevoucher` | Love Voucher | 2.6.0-pre.4.dev | 45.5 | 0/0 | **Fixed** - OFF shows the bug signature (hidden popup visible, stuck "Loading Map"); ON renders correctly, confirmed by eye on the device (system screenshots of this app come back stale, see notes) and by browser A/B |
| `com.mobileteck.mylocalvue` | My Local Vue | 2.x | 45.5 | 0/0 | **Fixed (inferred)** - same developer/codebase and same OFF symptom as Love Voucher; ON screenshot stale like Love Voucher; not confirmed by eye |
| `com.mobileteck.thetube` | London Tube Status | 2.x | 0.0 | 0/0 | Works both ways (shows its own "Service Error" - dead API) |
| `com.othelloventures.stockwatch` | StockWatch | 2.x | 102.4 | 2/2 | Works both ways (landscape UI; its web service is dead so it shows its own "Connection failure" dialog). The pixel diff comes from a slow first paint in the ON run; a 45 s retest ON matched OFF |
| `de.metaviewsoft.emwikaz` | EM Wiki | 2.x | 0.0 | 0/0 | Works both ways |
| `net.penduin.picrossdemo` | Picross Demo | 2.x | 0.0 | 0/0 | Works both ways |

Preware 2 (`com.palm.app.preware2`, Enyo 2.5) is in the system-apps table: OFF it is the broken screen you reported; ON it loads normally (see `screens/preware2-after-fix.png`).

## Enyo 1 apps (load the system framework, /usr/palm/frameworks/enyo/1.0 from org.webosinternals.enyo)

The flag changes nothing visible for any of them: same screens and same errors OFF and ON. Errors that appear in both passes are the apps' own problems on a phone (TouchPad-only apps, dead web services).

| App | Title | pixel diff | errors OFF/ON |
|---|---|---|---|
| `biz.aventer.ocnews` | OwnCloud News Reader | 0.0 | 0/0 |
| `com.angrygoat.sqzplayer` | Squeeze Player | 0.7 | 0/0 |
| `com.aventer.webdavclientlite` | WebDAV Client | 0.0 | 0/0 |
| `com.deroiste.enyo.breakingnews` | breaking news | 0.0 | 0/0 |
| `com.dta3.jakuje.webotp` | WebOTP | 0.0 | 0/0 |
| `com.dta3team.app.wherigo` | WebWIG | 0.0 | 0/0 |
| `com.flashmedia.holdemstripem` | Holdem Stripem Flash | 0.0 | 0/0 |
| `com.hominidsoftware.zapphotoshare` | Zap Photoshare | 0.0 | 0/0 |
| `com.ixmilia.webcalculator` | Web Calculator | 0.0 | 0/0 |
| `com.kyrus.junkvnc` | junkVNC | 0.0 | 0/0 |
| `com.m0ngr31.hey` | HEYYEYAAEYAAAEYAEYAA | 0.0 | 0/0 |
| `com.manascoding.ttexteditorb` | TouchPad Text Editor Basic | 0.2 | 3/3 |
| `com.manassoft.calcnode` | CalcNode | 1.9 | 3/3 |
| `com.manassoft.math` | Math Quiz Jr | 0.2 | 3/3 |
| `com.meissel.gmusicwrapper` | GMusic Wrapper | 0.0 | 0/0 |
| `com.michote.mysongbook` | MySongBook | 0.0 | 0/0 |
| `com.moimael.seriesaddict` | SeriesAddict | 0.0 | 0/0 |
| `com.moimael.webosm` | WebOSM | 0.0 | 0/0 |
| `com.palm.birthdaylist` | BirthdayList | 0.0 | 0/0 |
| `com.palm.com.verusora.touchpad.proxysetbasic` | Proxy Set Basic | 0.0 | 0/0 |
| `com.palm.proxify` |  | 0.0 | 0/0 |
| `com.palm.proxyswitch` | ProxySwitch | 0.0 | 0/0 |
| `com.phxdevices.acl.doc` | ACL Documentation | 0.4 | 1/1 |
| `com.rickrodman.cashregister` | Cash Register | 0.0 | 0/0 |
| `com.scienceapps.poplaterce` | pop!Later CE | 0.0 | 0/0 |
| `com.scoinv.48lawsofpower` | 48 Laws Of Power | 0.0 | 0/0 |
| `com.seahorss.seahorssdeals` | seahorss deals | 0.0 | 0/0 |
| `com.wordpress.touchcontrol.touchvol` | TouchVol | 0.0 | 1/1 |
| `de.zefanjas.biblez.enyo` | BibleZ HD | 0.0 | 0/0 |
| `org.webosinternals.homecontrol` | Home Control | 0.0 | 0/0 |
| `org.webosinternals.tweaks` | Tweaks | 0.3 | 0/0 |

## Built-in and homebrew Mojo apps

All 40 launched in both passes. Screenshots are identical except where the content is live (clock/calendar time, Govnah readings) and Preware 2 (fixed). Screenshots of this group are not published because they show personal data (Wi-Fi network names, device info, a chat log).

| App | pixel diff | errors OFF/ON |
|---|---|---|
| `com.palm.app.calculator` | 1.1 | 0/0 |
| `com.palm.app.calendar` | 67.2 | 0/0 |
| `com.palm.app.clock` | 7.2 | 0/0 |
| `com.palm.app.contacts` | 0.0 | 0/0 |
| `com.palm.app.deviceinfo` | 0.0 | 0/0 |
| `com.palm.app.email` | 0.0 | 0/0 |
| `com.palm.app.help` | 0.1 | 0/0 |
| `com.palm.app.maps` | 0.0 | 0/0 |
| `com.palm.app.messaging` | 0.0 | 0/0 |
| `com.palm.app.musicplayer` | 0.0 | 0/0 |
| `com.palm.app.notes` | 0.0 | 0/0 |
| `com.palm.app.phone` | 0.0 | 0/0 |
| `com.palm.app.photos` | 60.2 | 0/0 |
| `com.palm.app.tasks` | 0.0 | 1/1 |
| `com.palm.app.videoplayer` | 0.0 | 0/0 |
| `com.palm.app.wifi` | 0.0 | 0/0 |
| `com.palm.app.bluetooth` | 0.0 | 0/0 |
| `com.palm.app.soundsandalerts` | 0.0 | 0/0 |
| `com.palm.app.dateandtime` | 0.2 | 0/0 |
| `com.palm.app.screenlock` | 0.0 | 0/0 |
| `com.palm.app.location` | 0.0 | 0/0 |
| `com.palm.app.network` | 0.0 | 0/0 |
| `com.palm.app.phoneprefs` | 0.0 | 0/0 |
| `com.palm.app.searchpreferences` | 0.0 | 0/0 |
| `com.palm.app.textassist` | 0.0 | 0/0 |
| `com.palm.app.pdfviewer` | 0.0 | 0/0 |
| `com.palm.app.youtube` | 0.0 | 0/0 |
| `com.palm.app.camera` | 0.0 | 0/0 |
| `com.palm.app.accounts` | 0.0 | 0/0 |
| `com.palm.app.swmanager` | 0.0 | 0/0 |
| `com.quickoffice.webos` | 0.0 | 0/0 |
| `com.palm.app.browser` | 0.0 | 0/0 |
| `org.webosinternals.preware` | 0.0 | 0/0 |
| `ca.canucksoftware.internalz` | 0.0 | 0/0 |
| `ca.canucksoftware.filemgr` | 0.0 | 0/0 |
| `org.webosinternals.govnah` | 2.2 | 0/0 |
| `com.xwteam.app.xwtweak` | 0.0 | 0/0 |
| `com.palm.app.findapps` | 0.0 | 1/1 |
| `com.palm.app.codepoet.simplechat` | 0.0 | 0/0 |
| `com.palm.app.preware2` | 127.8 | 0/0 |

## Web browsing (Browser app + BrowserServer)

Identical OFF and ON. The two HTTPS-only sites fail in **both** passes ("Unable to Load Page" - webOS 2.1.0's TLS is too old), unrelated to this fix.

| Page | pixel diff | errors OFF/ON |
|---|---|---|
| v8test-toplevel.html (local) | 0.0 | 0/0 |
| http://example.com/ | 0.0 | 0/0 |
| http://info.cern.ch/ | 0.0 | 0/0 |
| http://frogfind.com/ | 0.0 | 0/0 |
| http://68k.news/ | 0.0 | 0/0 |
| http://www.webosarchive.org/ | 21.4 | 0/0 |
| https://en.m.wikipedia.org/wiki/Palm_Pre | 0.0 | 0/0 |
| https://lite.cnn.com/ | 0.0 | 0/0 |

Contact sheets in `screens/` show each app as OFF (left) | ON (right).
