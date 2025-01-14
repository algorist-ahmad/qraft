# qraft

## OUTPUT

All output to stdout is JSON, save for options --help, --debug, --version, --interactive, --query-only, and export --format csv,tsv,pipe

All error messages and warning MUST be sent to stderr

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
-modifier $modifier 
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

## Command Scenarios and Expected Outputs

Based on this sample table:

Here’s the **employees** table formatted as a markdown table:

|||
|-----|-------------|
| file  | path/to/employees.db |
| table | employees |


| id  | name         | age | department | salary | hire_date   | status   |
|-----|--------------|-----|------------|--------|-------------|----------|
| 1   | John Smith   | 34  | Sales      | 55000  | 2015-04-23  | Active   |
| 2   | Jane Doe     | 28  | Marketing  | 60000  | 2018-07-12  | Active   |
| 3   | Bob Johnson  | 45  | IT         | 72000  | 2010-10-01  | Active   |
| 4   | Alice Brown  | 31  | Sales      | 58000  | 2017-03-15  | Active   |
| 5   | Tom White    | 29  | Marketing  | 52000  | 2020-06-10  | Active   |
| 6   | Sarah Green  | 40  | HR         | 65000  | 2013-09-05  | Active   |
| 7   | Mike Black   | 38  | IT         | 75000  | 2012-11-20  | Inactive |
| 8   | Emma Blue    | 27  | Sales      | 54000  | 2021-01-11  | Active   |
| 9   | Chris Red    | 33  | HR         | 62000  | 2019-08-22  | Active   |
| 10  | Amy Yellow   | 35  | IT         | 70000  | 2014-05-30  | Inactive |

For this section, `q` will be aliased to `qraft`

New Features Explanation

    Primary Key Special Handling:
        If the primary key is of type INTEGER, rows can be identified and manipulated using only integer arguments (e.g., q 1 2 3 delete).

    Add Operations:
        q add supports adding rows with default or specific column values.

    Modify Operations:
        q mod enables updating column values based on conditions.

    Delete Operations:
        q delete supports deleting rows using conditions or primary key values.

    Cache Listing (--list):
        If no database or target is selected, lists cached databases or tables.

    Protect Feature:
        Allows marking databases or tables as read-only to safeguard against accidental modifications.

    Extended Conditions:
        Supports OR (|) and AND (whitespace) combinations for more complex queries.

| **args** | **resulting query** | **explanation** |
|---|---|---|
| `q` | - | Checks cache for a connection. Prompts for a database if none exists. If connected, checks for a target and runs based on `q target`. |
| `q connect` | - | Displays current database info, lists cached databases, or provides usage info. Metadata included in JSON output. |
| `q connect path/to/employees.db` | `.tables` | Queries the database for tables and caches them. Metadata included in JSON output. |
| `q load path/to/employees.db` | `.tables` | Alias for `q connect`. |
| `q connect employees.db employees` | `SELECT * FROM employees;` | Returns all rows from the `employees` table. |
| `q employees` | `SELECT * FROM employees;` | Displays all rows from the `employees` table. |
| `q employees:name,dep,stat` | `SELECT name,department,status FROM employees;` | Selects specific columns by partial name matching. |
| `q employees:+dep,name,-salar` | `SELECT department,name,salary FROM employees ORDER BY department ASC, salary DESC;` | Sorts and selects columns, using `+` for ASC and `-` for DESC. |
| `q employees!age,hire` | `SELECT id,name,department,salary,status FROM employees;` | Excludes specified columns (`age` and `hire_date`). |
| `q dep=Sales` | `SELECT * FROM employees WHERE department='Sales';` | Filters rows where `department` is `Sales`. |
| `q dep!=IT` | `SELECT * FROM employees WHERE department!='IT';` | Filters rows where `department` is not `IT`. |
| `q age>30` | `SELECT * FROM employees WHERE age>30;` | Filters rows where `age` is greater than 30. |
| `q name~Jane` | `SELECT * FROM employees WHERE name LIKE '%Jane%';` | Filters rows where `name` contains `Jane`. |
| `q salary>60000 stat=Active` | `SELECT * FROM employees WHERE salary>60000 AND status='Active';` | Combines multiple conditions using AND. |
| `q lim 3` | `SELECT * FROM employees LIMIT 3;` | Returns the first 3 rows. |
| `q lim 3+9` | `SELECT * FROM employees LIMIT 3 OFFSET 9;` | Skips the first 9 rows and returns 3 rows. |
| `q dep=IT\|dep=Sales stat=active\|stat=unknown age<20\|age>60` | `SELECT * FROM employees WHERE (department='IT' OR department='Sales') AND (status='active' OR status='unknown') AND (age<20 OR age>60);` | Combines AND and OR conditions. |
| `q salary>60000\|salary<30000 stat=active` | `SELECT * FROM employees WHERE (salary>60000 OR salary<30000) AND status='active';` | Combines multiple AND and OR conditions. |
| `q +hire` | `SELECT * FROM employees ORDER BY hire_date ASC;` | Orders by `hire_date` in ascending order. |
| `q -hire` | `SELECT * FROM employees ORDER BY hire_date DESC;` | Orders by `hire_date` in descending order. |
| `q +hire -salary` | `SELECT * FROM employees ORDER BY hire_date ASC, salary DESC;` | Orders by `hire_date` ASC and `salary` DESC. |
| `q employees:-hire,+salary` | `SELECT name,department,status FROM employees ORDER BY hire_date DESC, salary ASC;` | Selects and sorts columns (opposite direction). |
| `q 1 2 3 10` | `SELECT * FROM employees WHERE id=1 OR id=2 OR id=3 OR id=10;` | Filters rows by primary key (`id`). |
| `q add` | `INSERT INTO employees DEFAULT VALUES;` | Adds a new row with default values. |
| `q add name=joe age=30` | `INSERT INTO employees (name, age) VALUES ('joe', 30);` | Adds a row with specified column values. |
| `q salary>60000 set salary=62000` | `UPDATE employees SET salary=62000 WHERE salary>60000;` | Modifies rows based on a condition. |
| `q name=joe set stat=fired` | `UPDATE employees SET status='fired' WHERE name='joe';` | Updates rows where `name` is `joe`. |
| `q 1 2 3 delete` | `DELETE FROM employees WHERE id=1 OR id=2 OR id=3;` | Deletes rows by primary key values. |
| `q transac.begin` | `BEGIN TRANSACTION;` | Begins a transaction. |
| `q transac.commit` | `COMMIT;` | Commits the current transaction. |
| `q pragma foreign_keys=ON` | `PRAGMA foreign_keys=ON;` | Enables foreign key constraints. |
| `q desc employees` | `PRAGMA table_info(employees);` | Describes the structure of the `employees` table. |
| `q export employees` | `SELECT * FROM employees INTO OUTFILE 'emp.tsv';` | Exports the `employees` table to a file. Allows specifying output formats like JSON. |
| `q import employees` | `.mode tab; .import 'emp.tsv' employees;` | Imports data from a file into the `employees` table. |
| `q alter employees add age INTEGER` | `ALTER TABLE employees ADD COLUMN age INTEGER;` | Adds a new column to an existing table. |
| `q alter employees rename name TO full_name` | `ALTER TABLE employees RENAME COLUMN name TO full_name;` | Renames a column in an existing table. |
| `q alter employees drop age` | `ALTER TABLE employees DROP COLUMN age;` | Removes a column from an existing table. |
| `q --version` | - | Displays the current version of the program. |
| `q --help` | - | Displays help information about the available commands. |
| `q --debug` | - | Activates debugging mode for detailed logs during execution. |
| `q employees:id,name,dep,stat dep=IT\|dep=Sales stat=active\|stat=unknown age<20\|age>60 +name -stat lim 100 shift 100` | `SELECT id,name,department,status FROM employees WHERE (department='IT' OR department='Sales') AND (status='active' OR status='unknown') AND (age<20 OR age>60) ORDER BY name ASC, status DESC LIMIT 100 OFFSET 100;` | Ultimate query combining filtering, ordering, and pagination. |
