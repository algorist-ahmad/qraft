# qraft

## SYNTAX (needs revision)

These syntaxes apply to SQLite only.

### CONTROL

#### connection

`qraft connect`

- relies on $DATABASE or ~/.cache/qraft/databases or user interaction

`qraft connect <FILE>`

- if file exists, will attempt to load

`qraft connect <FILE>...`

- like previous, but will attach databases

`qraft connect <FILE>/<TABLE>`

- equivalent to
  ```
  qraft connect <FILE>
  qraft select <TABLE>
  ```

`qraft load` and `qraft connect` and `qraft db` are equivalent.

`qraft load <FILE>`

- Alias for `qraft connect <FILE>`.

`qraft load <FILE>...`

- Alias for `qraft connect <FILE>...`.

`qraft load <FILE>/<TABLE>`

- Alias for `qraft connect <FILE>/<TABLE>`.

#### permission

`qraft protect <FILE>`

- Equivalent to `chmod -w <FILE>`.

`qraft protect <TABLE>`

- Protects table from being altered in the connected database.

### DEFINITION

#### `CREATE`

`qraft create table <TABLE> (<COLUMN> <DATATYPE> [...]);`

- Creates a new table.

#### `ALTER`

`qraft alter table <TABLE> add <COLUMN> <DATATYPE>`

- Adds a new column to a table.

`qraft alter table <TABLE> rename to <NEW_TABLE>`

- Renames a table.

#### `DROP`

`qraft drop table <TABLE>`

- Drops a table.

`qraft drop view <VIEW>`

- Drops a view.

### QUERY

`qraft tables`

- If connection exists, lists all database tables and views.

`qraft desc <TABLE>`\
`qraft <TABLE> desc`

- Describes table, listing all columns and datatypes.

`qraft`

- If database not connected, prompts user for connection.
- If table not selected, prompts user for selection.
- If default query defined, runs it.
- Else performs a `SELECT * FROM...`.

`qraft <TABLE>`

- Equivalent to `SELECT * FROM <TABLE>`. Table names are matched by pattern (fuzzy).

`qraft <TABLE>:<COL1>,<COL2>,<COL3>...`

- Equivalent to `SELECT <COL1>,<COL2>,<COL3>... FROM <TABLE>`. Column names need not to match exactly, the engine will figure out which columns are refererred to via fuzzy search.

`qraft <TABLE> hide <COL1> COL2> ...`

- Selects all column from `<TABLE>` EXCEPT the ones mentionned after `hide`. These columns would be hidden. Column names need not to match exactly, the engine will figure out which columns are refererred to via fuzzy search.

`qraft select <TABLE>`\
`qraft target <TABLE>`

- Makes all subsequent queries against this table.

`qraft <FILE>/<TABLE>`

- Equivalent to
  ```
  qraft connect <FILE>
  qraft <TABLE>
  ```

`qraft <FILTER>`

- Applies filter to table. See #filtering for details.

#### filtering

The group `<FILTER>` may refer to any combination of the following:

- `<TABLE>`

  - Applies filter to specific table.

- `<COLUMN>`

  - Select specific columns from selected table, same as `SELECT <COL1> <COL2> <COL3> FROM <TABLE>`.

- `<CONDITION>`

  - Conditions refer to the statements used in `WHERE` clauses. Here are the accepted syntaxes for `<CONDITION>`:
    ```
    qraft col=abc
    qraft col!=abc
    qraft col\>99
    qraft col\<99
    qraft col\ge99
    qraft col\le99
    qraft col~pattern
    qraft col null
    qraft col !null
    ```
    <!-- qraft col\c(value1, value2, ...)
    qraft col not in (value1, value2, ...)
    qraft col between value1 and value2
    qraft col not between value1 and value2
    qraft condition1 and condition2
    qraft condition1 or condition2
    qraft not condition
    qraft col = (select ...)
    qraft col in (select ...)
    qraft exists (select ...)
    qraft not exists (select ...)
    ``` -->

    All ```<CONDITIONS>``` are naturally joined by **AND**. To join ```<CONDITION>``` by **OR**, must do it as such:

    ```
    qraft name=joe/or/jack
    ```

    Multiple **OR** and **AND** conditions may be combined as such:

    ```
    qraft 
    ```

#### sorting

```
qraft lim=99
qraft shift=99 # offset
qraft +<COL>   # orders by <COL>, ascending
qraft -<COL>   # orders by <COL>, descending
qraft group <COL>
```

### MANIPULATION

#### INSERT

```
qraft [TABLE] add <COL1>=x <COL2>=y <COL3>=z
```

- `INSERT INTO [TABLE] ([COLUMNS]) VALUES (<VALUES>);`

`qraft [TABLE] add default`

- Inserts default values into all columns.

#### UPDATE

```
qraft [TABLE] <FILTER> set <COL1>=x <COL2>=y <COL3>=z
```

- `UPDATE [TABLE] SET <MODS> WHERE <FILTER>;`

#### DELETE

```
qraft [TABLE] <FILTER> del
```

- `DELETE FROM [TABLE] WHERE <FILTER>;`

### TRANSACTION

#### Begin Transaction

```
qraft transaction begin
```

- Starts a new transaction.

#### Commit Transaction

```
qraft transaction commit
```

- Commits the current transaction.

#### Rollback Transaction

```
qraft transaction rollback
```

- Rolls back the current transaction.

### PRAGMA

`qraft pragma <COMMAND>`

- Executes a pragma command, e.g., `qraft pragma cache_size=1000`.

#### Exporting

`qraft export <TABLE> to <FILE>`

- Exports table data to a file in TSV format.

`qraft import <FILE> into <TABLE>`

- Imports data from a TSV file into a table.

### Options

`-i`: Launches in interactive mode.

`--help`: Displays help information.

`--version`: Displays the version of the tool.

### Summary

```
qraft connect
qraft connect <FILE>
qraft connect <FILE>...
qraft connect <FILE>/<TABLE>
qraft load
qraft load <FILE>
qraft load <FILE>...
qraft load <FILE>/<TABLE>
qraft protect <FILE>
qraft protect <TABLE>
qraft create table <TABLE> (<COLUMN> <DATATYPE> [...])
qraft alter table <TABLE> add <COLUMN> <DATATYPE>
qraft alter table <TABLE> rename to <NEW_TABLE>
qraft drop table <TABLE>
qraft drop view <VIEW>
qraft tables
qraft desc <TABLE>
qraft <TABLE> desc
qraft
qraft <TABLE>
qraft select <TABLE>
qraft target <TABLE>
qraft <FILE>/<TABLE>
qraft <FILTER>
qraft col=abc
qraft col!=abc
qraft col\>99
qraft col\<99
qraft col ge 99
qraft col le 99
qraft col~pattern
qraft col is null
qraft col is not null
qraft col in (value1, value2, ...)
qraft col not in (value1, value2, ...)
qraft col between value1 and value2
qraft col not between value1 and value2
qraft condition1 and condition2
qraft condition1 or condition2
qraft not condition
qraft col regexp pattern
qraft col = (select ...)
qraft col in (select ...)
qraft exists (select ...)
qraft not exists (select ...)
qraft lim=99
qraft shift=99
qraft +<COL>
qraft -<COL>
qraft group <COL>
qraft [TABLE] add <COL1>=x <COL2>=y <COL3>=z
qraft [TABLE] add default
qraft [TABLE] <FILTER> set <COL1>=x <COL2>=y <COL3>=z
qraft [TABLE] <FILTER> del
qraft transaction begin
qraft transaction commit
qraft transaction rollback
qraft pragma <COMMAND>
qraft export <TABLE> to <FILE>
qraft import <FILE> into <TABLE>
-i
--verbose
--help
--version
```
