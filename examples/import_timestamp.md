# Get the DateTime of the last import

```sql
    SELECT value as timestamp
    FROM osm2pgsql_properties
    WHERE property = 'import_timestamp'
```
