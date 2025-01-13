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

| **args** | **resulting query** | **explanation** |
|---|---|---|
| `q` | - | Checks cache if a connection exists. If not, prompts the user to pick a database from a list of cached databases also stored in cache. If list is empty, tell user to do `q connect <FILE>` instead.<br> If a connection is found, that is, "database" in cache is set to a valid sqlite3 file, then next step is to check if a target is set in cache. If not, get a list of all tables from the database and prompt user to pick a target. If target is found, do `q <TARGET>` and let the program handle the rest. See `q target` examples below. |
| `q connect ` | - | If connected, print info about current database file. If not, check if database file paths are stored in cache, and print them. Else give usage info. Include meta data in json output. |
| `q connect invalid/file` | return error | Handle error gracefully. |
| `q connect path/to/employees.db` | `.tables` | Queries the file for tables and views and store them in cache. Include meta data in json output. |
| `q connect employees.db employees` | `SELECT * FROM employees;` | Returns all rows from the `employees` table. |
| `q load path/to/employees.db` | `.tables` | Alias for `q connect`. |
| `q employees` | `SELECT * FROM employees;` | Displays all rows from the `employees` table. |
| `q employees:name,dep,stat` | `SELECT name,department,status FROM employees;` | Notice how I didn't need to type the entire column names. The program should be able to figure  it out. |
| `q employees:+dep,name,-salar` | `SELECT department,name,salary FROM employees ORDER BY department ASC, salary DESC;` | You can simultaneously sort and select columns by prefixing with '+' (ASC) or '-' (DESC). Only these columns are displayed.  |
| `q employees!age,hire` | `SELECT id,name,department,salary,status FROM employees;` | This syntax allows to choose which columns to EXCLUDE from SELECT, in this case, hide age and hire_date. |
| `q +dep,name,-salar | `SELECT department,name,salary FROM employees ORDER BY department ASC, salary DESC;` | If `q target employees` is run first, stores target=employees in cache, and all subsequent queries are run against this table by default. |
|  |  |  |
|  |  |  |
| `q desc employees` | `PRAGMA table_info(employees);` | Describes the structure of the `employees` table. |
| `q employees col=Sales` | `SELECT * FROM employees WHERE department='Sales';` | Rows where `department` is `Sales`. |
|  |  |  |
| `q employees col!=IT` | `SELECT * FROM employees WHERE department!='IT';` | Rows where `department` is not `IT`. |
| `q employees col>30` | `SELECT * FROM employees WHERE age>30;` | Rows where `age` is greater than 30. |
| `q employees col<40` | `SELECT * FROM employees WHERE age<40;` | Rows where `age` is less than 40. |
| `q employees col ge 35` | `SELECT * FROM employees WHERE age>=35;` | Rows where `age` is greater than or equal to 35. |
| `q employees col le 30` | `SELECT * FROM employees WHERE age<=30;` | Rows where `age` is less than or equal to 30. |
| `q employees col~Jane` | `SELECT * FROM employees WHERE name LIKE 'Jane';` | Rows where `name` matches `Jane`. |
| `q employees col is null` | `SELECT * FROM employees WHERE col IS NULL;` | Rows where `col` is `NULL`. |
| `q employees col is not null` | `SELECT * FROM employees WHERE col IS NOT NULL;` | Rows where `col` is not `NULL`. |
| `q employees department='Marketing'` | `SELECT * FROM employees WHERE department='Marketing';` | Rows where `department` is `Marketing`. |
| `q employees salary>60000 and status='Active'` | `SELECT * FROM employees WHERE salary>60000 AND status='Active';` | Rows where `salary` is greater than 60000 and `status` is `Active`. |
| `q employees salary>60000 or department='IT'` | `SELECT * FROM employees WHERE salary>60000 OR department='IT';` | Rows where `salary` is greater than 60000 or `department` is `IT`. |
| `q employees hire_date>'2015-01-01'` | `SELECT * FROM employees WHERE hire_date>'2015-01-01';` | Rows where `hire_date` is after January 1, 2015. |
| `q employees lim=3` | `SELECT * FROM employees LIMIT 3;` | Returns the first 3 rows of the `employees` table. |
| `q employees shift=2` | `SELECT * FROM employees OFFSET 2;` | Skips the first 2 rows and returns the rest. |
| `q employees +salary` | `SELECT * FROM employees ORDER BY salary ASC;` | Rows sorted by `salary` in ascending order. |
| `q employees -age` | `SELECT * FROM employees ORDER BY age DESC;` | Rows sorted by `age` in descending order. |
| `q employees transaction begin` | `BEGIN TRANSACTION;` | Begins a transaction. |
| `q employees transaction commit` | `COMMIT;` | Commits the current transaction. |
| `q employees pragma foreign_keys=ON` | `PRAGMA foreign_keys=ON;` | Enables foreign key constraints. |
| `q employees export employees to emp.csv` | `SELECT * FROM employees INTO OUTFILE 'emp.csv';` | Exports the `employees` table to a CSV file named `emp.csv`. |
| `q employees import emp.csv into employees` | `.mode csv; .import 'emp.csv' employees;` | Imports data from a CSV file into the `employees` table. |
| `q employees col regexp '^J.*'` | `SELECT * FROM employees WHERE name REGEXP '^J.*';` | Rows where `name` starts with `J`. |
