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
use ```
\d 
``` command

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