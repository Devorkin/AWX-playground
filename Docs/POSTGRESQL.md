# Configuring External PostgreSQL connection
- Using "awx" as database name, by default
- Using "awx" as username, by default
<br /><br />
- Create a new database and assign permissions to it as below
    - Replace "SECRET" with a generated password
```sql
# Create new database
CREATE USER awx WITH PASSWORD 'SECRET';

## Set permissions
GRANT ALL PRIVILEGES ON DATABASE awx TO awx;

\connect awx

GRANT ALL ON ALL TABLES IN SCHEMA public TO awx;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO awx;
```
