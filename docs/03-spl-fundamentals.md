# 03 - SPL fundamentals

**Time:** about 60 minutes. Run every search, then explain it out loud in one sentence. Use **All time** for tutorial data and **Last 60 minutes** for your own Windows events.

## How a search is built

```
<where to look> | <transform> | <filter> | <sort or format>
```

- **index**: where the data is stored. **sourcetype**: its format. **source**: the file or feed. **host**: the machine it came from.
- Put the most specific filters first (index, sourcetype, host, field values), then add pipes.
- AND is implied. `OR` and `NOT` must be capitalized.

## 1. Search basics

```
index=main
index=main sourcetype=access_combined*
index=main error
index=main sourcetype=access_combined* status=404
index=main sourcetype=access_combined* (status=404 OR status=500) NOT clientip=10.*
index=main source="WinEventLog:Security" EventCode=4625
```

Also try: the time picker presets, `earliest=-7d@d latest=now`, clicking values in the field sidebar and choosing **Add to search**, and the **Events / Patterns / Statistics / Visualization** tabs.

**Checkpoint:** explain why `status=404` is more precise than the bare word `404`.

## 2. Transforming commands

| Command | Purpose |
| --- | --- |
| `stats` | Count, sum, average, grouped by fields |
| `top` / `rare` | Most or least common values |
| `timechart` | Counts over time |
| `sort` | Order results (`- field` is descending) |
| `where` | Filter after calculating |
| `dedup` | Remove duplicates by a field |
| `table` | Choose columns |
| `head` / `tail` | First or last N |

```
index=main sourcetype=access_combined* | stats count by status
index=main sourcetype=access_combined* | top limit=10 clientip
index=main sourcetype=access_combined* | rare limit=10 uri_path
index=main sourcetype=access_combined* | timechart span=1h count by status
index=main sourcetype=access_combined* | stats count by clientip | where count > 50 | sort - count
index=main sourcetype=access_combined* | stats count, dc(clientip) AS unique_ips, sum(bytes) AS total_bytes by host
index=main sourcetype=access_combined* status=404 | table _time clientip uri_path status | head 20
index=main source="WinEventLog:Security" | stats count by EventCode | sort - count
```

**Skeleton to memorize:** `index=... | stats count by <field> | where count > N | sort - count`

## 3. eval, rex and fields

```
index=main sourcetype=access_combined* | eval result=if(status>=400,"error","ok") | stats count by result

index=main sourcetype=access_combined*
| eval class=case(status<300,"success",status<400,"redirect",status<500,"client_error",true(),"server_error")
| stats count by class

index=main sourcetype=access_combined*
| eval mb=round(bytes/1024/1024,2)
| stats sum(mb) AS total_mb by clientip
| sort - total_mb
| head 10
```

Windows example (target account of a failed logon):

```
index=main source="WinEventLog:Security" EventCode=4625
| eval target_user=mvindex(Account_Name,1)
| stats count by target_user, Logon_Type
```

`rex` example (extract text with a regular expression):

```
index=main source="WinEventLog:Security" EventCode=4625
| rex field=_raw "Failure Reason:\s+(?<failure_reason>.+)"
| stats count by failure_reason
```

Build `rex` slowly: test it with `| head 5` and confirm the new field appears in the **Interesting Fields** sidebar. If it is empty, simplify the pattern.

**Concept:** most field extraction happens at search time, so adding a `rex` never changes the stored data.

## 4. Optional lookup (Prices.csv)

1. **Settings > Lookups > Lookup table files > Add new**: upload `prices.csv`.
2. **Settings > Lookups > Lookup definitions > Add new**: create a definition that points at the file.
3. Use `| lookup <definition> <key_field> OUTPUT <new_field>` in a search.

## Checkpoint

- [ ] You can explain every search above without reading it
- [ ] You can write `stats ... | where ... | sort` from memory
- [ ] You saved at least one screenshot of a `stats` result
