# Data types
## NUMBER VALUES 
SERIAL = automatically generates a sequence of integers (useful for primary keys.) Similiar to Mysql AUTO_INCREMENT.
INTEGER = or INT. Typical choice for integer values.
SMALLINT = used for smaller integer values.

CREATE TABLE integer_example (
    id SERIAL PRIMARY KEY,
    quantity INTEGER,
    small_quantity SMALLINT
);

## Text types
TEXT: Stores variable-length strings of unlimited length.
VARCHAR(n): Stores variable-length strings with a maximum length of n.
CHAR(n): Stores fixed-length strings of length n. If the string is shorter, it's padded with spaces


CREATE TABLE text_example (
    id SERIAL PRIMARY KEY,
    name TEXT,
    short_name VARCHAR(50),
    code CHAR(5)
);

## Date types
DATE: Stores only the date (year, month, day).
TIME: Stores only the time (hour, minute, second).
TIMESTAMP: Stores both date and time without time zone information.
TIMESTAMPTZ: Stores both date and time with time zone information.

CREATE TABLE datetime_example (
    id SERIAL PRIMARY KEY,
    event_date DATE,
    event_time TIME,
    event_timestamp TIMESTAMP,
    event_timestamptz TIMESTAMPTZ
);

## Boolean type
BOOLEAN: Stores true/false values

CREATE TABLE boolean_example (
    id SERIAL PRIMARY KEY,
    is_active BOOLEAN
);

# PRIMARY KEY
- It must contain unique values.
- It cannot contain NULL values.
- A table can have only one primary key.

1. Using primary key with column definition:
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY
);

2. Using the primary key constraint separately:
CREATE TABLE customers (
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    PRIMARY KEY (customer_id)
);

## Error on duplicated primary key:
postgres=# SELECT * FROM users;
 user_id |  username  |         email          | registration_date 
---------+------------+------------------------+-------------------
       1 | john_doe   | john.doe@example.com   | 2023-10-26
       2 | jane_smith | jane.smith@example.com | 2023-10-27
(2 rows)

postgres=# INSERT INTO users (user_id, username, email, registration_date) VALUES (1, 'duplicate_user', 'dup@example.com', '2023-10-28');
ERROR:  duplicate key value violates unique constraint "users_pkey"
DETAIL:  Key (user_id)=(1) already exists.

# Add Basic Constraints (NOT NULL, UNIQUE)
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    hire_date DATE
);

## Error on adding null values to not null constraints:
postgres=# INSERT INTO employees (first_name, last_name, email, hire_date) VALUES (NULL, 'Smith', 'john.smith@example.com', '2023-10-27');
ERROR:  null value in column "first_name" of relation "employees" violates not-null constraint
DETAIL:  Failing row contains (1, null, Smith, john.smith@example.com, 2023-10-27).

## Error on adding not unique value to unique constrains:
postgres=# INSERT INTO employees (first_name, last_name, email, hire_date) VALUES ('Jane', 'Doe', 'john.smith@example.com', '2023-10-28');
ERROR:  duplicate key value violates unique constraint "employees_email_key"
DETAIL:  Key (email)=(john.smith@example.com) already exists.

# Inspect tables:
use ```\d ``` command

Inspect specific table:
\d employees:
```
postgres=# \d employees
                                           Table "public.employees"
   Column    |          Type          | Collation | Nullable |                    Default                     
-------------+------------------------+-----------+----------+------------------------------------------------
 employee_id | integer                |           | not null | nextval('employees_employee_id_seq'::regclass)
 first_name  | character varying(50)  |           | not null | 
 last_name   | character varying(50)  |           | not null | 
 email       | character varying(100) |           |          | 
 hire_date   | date                   |           |          | 
Indexes:
    "employees_pkey" PRIMARY KEY, btree (employee_id)
    "employees_email_key" UNIQUE CONSTRAINT, btree (email)
```

List all tables: \dt

exit: \q

# Write out database to text file:
sudo -u postgres psql -d <database_name> -c "SQL QUERY HERE" > ~/project/database_schema_result.txt



# Data filtering and simple queries

1. Filtering Data with WHERE
Use the WHERE clause to retrieve specific rows that match a condition.

Example: SELECT * FROM employees WHERE department = 'Sales';
What it does: Filters the table to only show employees in a specific department.
2. Pattern Matching with LIKE and ILIKE
Use wildcards to find records where a column matches a specific pattern.

% represents zero or more characters.
_ represents exactly one character.
Example: SELECT * FROM employees WHERE name LIKE '%o%';
What it does: Finds names containing the letter "o". (Note: ILIKE is the case-insensitive version).
3. Sorting Results with ORDER BY
Use ORDER BY to organize your data.

Example: SELECT * FROM employees ORDER BY salary DESC;
What it does: Sorts the list by salary from highest to lowest (DESC for descending).
4. Limiting Results with LIMIT and OFFSET
These are used to control the number of rows returned and where to start.

Example: SELECT * FROM employees LIMIT 3 OFFSET 2;
What it does: Returns 3 rows, but skips the first 2 rows. This is very common for implementing "pagination" (like page 1, page 2 of results).
Summary Table
Command / Keyword	Purpose
SELECT * FROM ...	Retrieves all columns from a table.
WHERE	Filters rows based on a condition.
LIKE / ILIKE	Searches for a specific pattern in a string.
ORDER BY	Sorts the result set (default is ASC, use DESC for reverse).
LIMIT	Restricts the number of rows returned.
OFFSET	Skips a specific number of rows before starting to return data.


# Query data using Inner join

An INNER JOIN returns only the rows where there is a match in both tables being joined. If there is no match, the row is excluded from the result.
```
SELECT orders.order_id, customers.first_name, orders.order_date, orders.total_amount
FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id;
```

## Using aliases 

For more complex queries, you can use aliases to make the query more readable. The previous query can be rewritten using aliases:
```
SELECT o.order_id, c.first_name, o.order_date, o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;
```

# LEFT, RIGHT and FULL OUTER JOIN
- LEFT OUTER JOIN (or LEFT JOIN): Returns all rows from the left table and the matching rows from the right table. If there's no match in the right table, NULL values are returned for the right table's columns.
- RIGHT OUTER JOIN (or RIGHT JOIN): Returns all rows from the right table and the matching rows from the left table. If there's no match in the left table, NULL values are returned for the left table's columns.
- FULL OUTER JOIN (or FULL JOIN): Returns all rows from both tables. If there's no match in one table, NULL values are returned for the other table's columns.

In short: (we have customers and orders table, and orders.customer_id references to customer.customer_id)
LEFT OUTER JOIN includes all rows from the customers table, even if there are no matching orders.
RIGHT OUTER JOIN includes all rows from the orders table. In our case, it behaves like an INNER JOIN because all orders have a corresponding customer.
FULL OUTER JOIN includes all rows from both tables.

# Advanced data types

## PostgreSQL stores two kind of JSON type: JSON and JSONB
The JSON data type stores an exact copy of the JSON input text, while the JSONB data type stores JSON data in a decomposed binary format. JSONB is generally preferred because it offers better performance for querying and indexing.
JSONB 
```
INSERT INTO products (data) VALUES ('{"name": "Laptop", "price": 1200, "features": ["16GB RAM", "512GB SSD"]}');
INSERT INTO products (data) VALUES ('{"name": "Keyboard", "price": 75, "features": ["Mechanical", "RGB Backlight"]}');
SELECT data -> 'features' ->> 0 FROM products WHERE id = 1;
```

->> operator: returns the result as text

Query json value:
SELECT data ->> 'name' FROM products WHERE id = 1;

## Array columns
```
TEXT[]
Use @> and && operator to filter data efficiently.
Filter them by using UNNEST
```

## UUID (Universally Unique Identifiers)
```
Create extension to provide UUID generation:
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

# Role and permission management
1. Create role

NOLOGIN attribute = this role cannot be used to directly connect to the database\
``` 
CREATE ROLE reporting_role NOLOGIN 
```
To view database users use: ``` \du ```

2. Grant database privileges
```
CREATE DATABASE reporting_db;
```

Connect to database: 
```
\c reporting_db
```

Create simple table:
```
CREATE TABLE sales_data (
    id SERIAL PRIMARY KEY,
    product VARCHAR(255),
    amount DECIMAL
);
```


Grant SELECT privilege on the sales_data to the reporting_role:
This will enable any role or user that is member of reporting_role to read from the sales_data table.
```
GRANT SELECT ON sales_data TO reporting_role;
```

3. Create user and Test Privileges

Create a user and grant membership of the reporting_role:
```
CREATE USER report_user;
GRANT reporting_role TO report_user;
```

Insert sample data into the sales_data table:
```
INSERT INTO sales_data (product, amount) VALUES ('Laptop', 1200.00), ('Mouse', 25.00), ('Keyboard', 75.00);
```

Connect to the database as __report_user__:
```
psql -d reporting_db -U report_user
```

Test the privileges: (SELECT)
```
SELECT * FROM sales_data;
```
Insert will throw a permission denied error.

4. Revoke privileges

Connect to the database: ```sudo -u postgresl psql```\
Connect to the report_db ```\c reporting_db```

Revoke the privilege:
```
REVOKE SELECT ON sales_data FROM reporting_role;
```
