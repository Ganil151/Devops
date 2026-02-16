# 🛠️ JSON Challenge: The Log Parser

**Scenario**: You are an On-Call Engineer. Your production database has slowed down, and you have been given a 10MB "Minified" JSON log file. You cannot read it with standard terminal tools.

**Task**: Use `jq` to parse the provided log fragment and isolate the critical data needed for the post-mortem.

## Provided Fragment: `raw_logs.json`
```json
[{"timestamp":"2026-01-24T00:01:00Z","level":"info","msg":"ping"}, {"timestamp":"2026-01-24T00:05:00Z","level":"error","msg":"db_connection_refused","code":500}, {"timestamp":"2026-01-24T00:06:00Z","level":"warn","msg":"retrying"}, {"timestamp":"2026-01-24T00:07:00Z","level":"error","msg":"out_of_memory","code":503}]
```

## Requirements:
1. **Pretty-Print**: Transform the minified JSON into a human-readable format.
2. **Filter Errors**: Extract ONLY the entries where `"level"` is `"error"`.
3. **Data Selection**: For those error entries, output ONLY the `timestamp` and the `msg` fields.
4. **Final Output Format**: Your final output should look like this:
   ```json
   {
     "time": "2026-01-24T00:05:00Z",
     "error": "db_connection_refused"
   }
   ```

## Deliverable:
Save the `jq` command strings you used in `solutions/jq_query_solution.sh`.
