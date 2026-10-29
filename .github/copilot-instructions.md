
# SQL Server database instructions

## Purpose

This workspace contains queries and code for a SQL Server database (T-SQL syntax). The database name is <DatabaseName></databasename>. Treat it as the target for all queries unless the user names another one.

## Schema reference

- The schema is in `docs/schema.md`. It lists every user table, view, stored procedure, and function, with columns, data types, nullability, primary keys, identity columns, foreign keys, and the SQL definitions of procedures, functions, and views.
- Read `docs/schema.md` before writing any query or answering a question about tables, columns, procedures, or views.
- Use only objects that appear in `docs/schema.md`. If something you need isn't there, say so. Don't guess names.
- If the schema seems out of date (the user mentions a new table, or a column error appears), tell the user to re-export it instead of assuming the change exists.

## Query rules

- Use T-SQL syntax for SQL Server.
- Always qualify object names with their schema, such as `dbo.Customers`.
- Default to `dbo` when the user doesn't name a schema.
- Use parameterized queries or stored procedure parameters. Never build SQL by concatenating user input.
- Return at most 1000 rows unless the user asks for more. Use `TOP (1000)` or `OFFSET ... FETCH`.
- Use explicit JOIN syntax, with join keys taken from the foreign keys listed in `docs/schema.md`.
- Format SQL with uppercase keywords and one clause per line.

## Safety rules

- Treat the database as read-only unless the user explicitly asks for a change.
- Don't write `INSERT`, `UPDATE`, `DELETE`, `MERGE`, `TRUNCATE`, `DROP`, `ALTER`, or `CREATE` statements unless asked. If a change is needed, show the script and explain it, but don't run it.
- Before suggesting any statement that modifies data or schema, state the impact and recommend a backup or a test run.
- Never print, store, or suggest hardcoded credentials, connection strings with passwords, or secrets. Use placeholders such as `<password>`.
- If a procedure or view definition contains credentials or personal data, don't repeat that content in answers.

## Answer style

- Show the SQL first, then a short explanation.
- State which tables and joins you used.
- If a request is ambiguous (for example, "last month" or "active customers"), state your assumption in one line.
- Keep answers concise. Don't repeat the schema back unless asked.

## Business terms

Add the meaning of ambiguous columns, codes, and status values here. Copilot can't infer these from the schema alone.

- `<Table>.<Column>`: <meaning, allowed values, units>
- Example: `Status`: 0 = Pending, 1 = Active, 2 = Closed (confirm these values)
