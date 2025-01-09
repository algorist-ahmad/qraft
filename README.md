# qraft

## SYNTAX

For SQLite only.

### CONTROL

#### connection

```qraft connect```

* relies on $DATABASE or ~/.cache/qraft/databases

```qraft connect <FILE>```

* if file exists, will attempt to load

```qraft connect <FILE>...```

* like previous, but will attach databases

```qraft connect <FILE>/<TABLE>``` 

* equivalent to

    ```
    qraft connect <FilE>
    qraft select <TABLE>
    ```

```qraft connect``` and ```qraft db``` are equivalent.

<!-- #### permission

```qraft ??? <FILE>```

* equivalent to ```chmod -w <FILE>```

```qraft ??? <TABLE>```

* protects table from connected database to -->

### DEFINITION (under construction)

#### ```CREATE```

```qraft create ...```

#### ```ALTER```

```qraft alter...```

#### ```DROP```

```qraft drop...```

### QUERY

```qraft tables```

* if connection exists, lists all database tables and views

```qraft desc <TABLE>```\
```qraft <TABLE> desc```

* describes table, listing all columns and datatypes

```qraft```

* if database not connected, prompts user for connection
* if table not selected, prompts user for selection
* if default query defined, runs it
* else performs a ```SELECT * FROM...```

```qraft <TABLE>```

* equivalent to ```SELECT * FROM <TABLE>```. Table names are matched by pattern. (fuzzy)

```qraft select <TABLE>```

* not to be confused with ```qraft <TABLE>```, make all subsequent queries against this table.

```qraft <FILE>/<TABLE>```

* equivalent to

    ```
    qraft connect <FILE>
    qraft <TABLE>
    ```

```qraft <FILTER>```

* applies filter to table. See #filtering for details

#### filtering

The group ```<FILTER>``` may refer to any combination of the following:

* ```<TABLE>```

    * applies filter to specific table

* ```<COLUMN>```

    * select specific columns from selected table, same as ```SELECT <COL1> <COL2> <COL3> FROM <TABLE>```

* ```<EXPR>```

    * expressions refer to the statements used in ```WHERE``` clauses. Here are the accepted syntaxes for ```<EXPR>```:

        ```
        qraft col=abc
        qraft col!=abc
        qraft col\>99
        qraft col\<99
        qraft col ge 99
        qraft col le 99
        qraft col~pattern
        qraft col is null
        qraft col is not null

        UNDER CONSTRUCTION

        column IN (value1, value2, ...)
        column NOT IN (value1, value2, ...)
        column BETWEEN value1 AND value2
        column NOT BETWEEN value1 AND value2
        condition1 AND condition2
        condition1 OR condition2
        NOT condition
        column REGEXP pattern
        HAVING condition
        column = (SELECT ...)
        column IN (SELECT ...)
        EXISTS (SELECT ...)
        NOT EXISTS (SELECT ...) 
        ```

#### sorting

```
qraft lim=99
qraft shift=99 # offset
qraft +<COL>   # orders by <COL>, ascending
qraft -<COL>   # orders by <COL>, descending
qraft group ...
```

### MANIPULATION

#### INSERT

```
qraft [TABLE] add <COL1>=x <COL2>=y <COL3>=z
```

* ```INSERT INTO [TABLE] ([COLUMNS]) VALUES (<VALUES>);```

#### UPDATE

```
qraft [TABLE] <FILTER> set <COL1>=x <COL2>=y <COL3>=z
```

* ```UPDATE [TABLE] SET <MODS>;```

#### DELETE

```
qraft [TABLE] <FILTER> del
```

* ```DELETE FROM [TABLE] WHERE <FILTER>;```

### TRANSACTION

Here, put syntax relevant to transactions, with example.

### PRAGMA

Here, we shall talk about non-SQL functions such as exporting, pragma functions, etc.

### Options

```-i``` : launches in interactive mode
...
