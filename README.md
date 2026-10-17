# bash1c

bash1c is a set of Bash and Perl scripts for analysing 1C:Enterprise 8.x logs, first of all the technological log (технологический журнал, ТЖ / tech journal). They aggregate `CALL`, `SDBL`, `DBMSSQL`, `EXCP` and `CONN` events by context, description or time and print the top entries by duration or count, and they count concurrent sessions (licenses) from the event log (журнал регистрации). The scripts are meant for 1C administrators and performance engineers and were written for Git Bash on Windows.

> Скрипты BASH(+PERL) для обработки журналов 1С. В первую очередь - ТЖ.

## Scripts

| Script | What it reports |
| --- | --- |
| `STAT.CALL.by.Context.sh` | `CALL` duration by `Context`, top 10 |
| `STAT.SDBL.by.Context.sh` | `SDBL` duration by `Context`, top 10 |
| `STAT.DBMSSQL.by.Context.sh` | `DBMSSQL` duration by `Context`, top 10 |
| `STAT.EXCP.by.Descr.sh` | `EXCP` by description (IPs, UUIDs, dates masked), top 10 by count |
| `STAT.by.Events.sh` | all events by event name, top 10 by count |
| `Duration.by.time.sh` | closed connections (`CONN`) per minute, top 50 |
| `Events.by.connectID.sh` | normalized `DBMSSQL` events, one per line |
| `Formatted.events.sh` | all events, one per line |
| `parse.old.zhr.sh` | splits an old-format event log `.lgp` into per-day files |
| `lic.stat.pl` | concurrent sessions per hour from `1Cv8.lgf` / `*.lgp` into `result.csv` |
| `lic.stat.with.graph.pl` | the same plus an HTML chart `report.html` (embedded Chart.js) |
| `Perl Only/Count.sdbl.by.context.pl` | pure-Perl aggregation of selected events by context |

`NppBash++64.7z` and `NppBash++64.exe` contain a portable Windows bundle of Notepad++, NppExec and Git Bash for running the scripts.

## Requirements

- `bash`, `grep` and `perl` 5 (on Windows: Git Bash).
- Tech log folders in the usual layout `<logs>/<process>_<pid>/YYMMDDHH.log`.

## Usage

The log locations are hardcoded at the top of every script. Edit them, then run the script with its interpreter:

```bash
# after setting the log glob in the grep line, for example /c/v8/logs/*/*.log
bash STAT.SDBL.by.Context.sh

# after setting $folder to the infobase event log folder
perl lic.stat.with.graph.pl
```

Output starts with a summary line `=====TIME TOTAL(ms):... COUNT:... AVG(ms):...` followed by the top entries.
