# bash1c

bash1c is a collection of Bash + Perl scripts for analysing 1C:Enterprise 8.x logs: mainly the technological log (технологический журнал, ТЖ) with events such as `CALL`, `SDBL`, `DBMSSQL`, `EXCP` and `CONN`, and also the event log (журнал регистрации, `1Cv8.lgf` / `*.lgp`) for session/license counts. Each script prints a top list of the heaviest contexts, descriptions or events by duration or count. It is for 1C administrators and performance engineers, mostly on Windows with Git Bash. Unmaintained since 2019-02-27.

## Layout

- `STAT.CALL.by.Context.sh`, `STAT.SDBL.by.Context.sh`, `STAT.DBMSSQL.by.Context.sh` - total and average duration of `CALL` / `SDBL` / `DBMSSQL` events grouped by `Context`, top 10 by duration.
- `STAT.EXCP.by.Descr.sh` - `EXCP` events grouped by `Descr` (IP addresses, UUIDs and timestamps masked), top 10 by count.
- `STAT.by.Events.sh` - all events grouped by event name, top 10 by count.
- `Duration.by.time.sh` - closed connections (`CONN` with `connection closed`) grouped by minute, top 50 by count.
- `Events.by.connectID.sh` - prints `DBMSSQL` events one per line with variable properties (date, pid, user, computer and others) masked as `{name}` placeholders, sorted, first 1500 lines; a `connectID` filter is commented out.
- `Formatted.events.sh` - prints all events, one event per line, with properties separated by `[][][]`.
- `parse.old.zhr.sh` - splits an old-format event log `.lgp` file into per-day `.lgp` files.
- `lic.stat.pl` - counts concurrent sessions per hour from `1Cv8.lgf` and `*.lgp` and writes `result.csv` into the log folder.
- `lic.stat.with.graph.pl` - the same plus `report.html` with a chart; Chart.js 2.7.1 (MIT) is embedded as one base64 string.
- `Perl Only/Count.sdbl.by.context.pl` - pure-Perl variant: walks a log folder, filters events listed in `@actions` (default `DBMSSQL`) and aggregates duration by context.
- `NppBash++64.7z`, `NppBash++64.exe` - about 63 MB each: a portable Windows bundle of Notepad++, NppExec and Git Bash for running the scripts (per commit messages). Third-party binaries.

## Setup / Build / Run / Test

No build, package manifest, CI or tests. The scripts need `bash`, `grep` and `perl` (5.x); file modes are not executable, so call the interpreter explicitly.

- Shell scripts: edit the hardcoded log glob first (for example `/c/v8/logs/*/*.log` in `STAT.SDBL.by.Context.sh`), then run `bash STAT.SDBL.by.Context.sh`.
- Event-log scripts: set `$folder` (the infobase event log folder with `1Cv8.lgf`) in `lic.stat.pl` or `lic.stat.with.graph.pl`, then run `perl lic.stat.pl`.
- Pure Perl: set `$logs` and `@actions` in `Perl Only/Count.sdbl.by.context.pl`, then run `perl "Perl Only/Count.sdbl.by.context.pl"`.
- Expected tech log layout (from the regexes): `<logs>/<process>_<pid>/YYMMDDHH.log`.
- To check a change, run the old and new script on the same small sample of logs and compare the output.

## Conventions

- Shell scripts share one pipeline: `grep -r ".*" -H <glob>` -> Perl stage 1 (strip BOM, glue multi-line events into one line, prepend `dt=`, `time=`, `prc=`, `pid=`, `dur=`, `evnt=` taken from the file path and event header) -> Perl stage 2 (aggregate into hashes, print in `END`). Reuse stage 1 when adding a script.
- Output lines end with `\r\n`; the report header is `=====TIME TOTAL(ms):... COUNT:... AVG(ms):...`, rows look like `N: [][][] TIME(ms):... [][][] BY:<key>`.
- Comments are in Russian. Script names follow `STAT.<EVENT>.by.<Key>.sh`.
- Default branch `master`. Commit messages are free-form Russian.

## Gotchas and boundaries

- Input paths are hardcoded and differ per script (`/c/v8/logs`, `/c/v7/logs`, `/c/1c_logs/logs`, `/c/1c_info/logs`, `/c/1c_logs/v8/logs`, `/d/zhr`, `$folder`, `$logs`). If asked to parametrize, keep the current value as the default.
- Durations are divided by 1000 and labelled `ms`; check the unit for your platform version before trusting absolute numbers.
- `lic.stat.with.graph.pl` is one very long line of base64; never reformat or rewrap it.
- `parse.old.zhr.sh` appends to files named `<YYYYMMDD>000000.lgp` in a hardcoded Windows folder; running it twice duplicates data.
- `Perl Only/Count.sdbl.by.context.pl` uses `use encoding 'utf8'`, which newer Perl releases reject (recalled, unverified; check with the target Perl).
- The repository is large (about 130 MB of history, mostly the NppBash binaries): clone with `--depth 1`, do not add more binaries, never modify `NppBash++64.*`.
- No license file in the repo. No `.cursor/rules` or Copilot instructions.
