GRANT ALL PRIVILEGES ON DATABASE awx TO awx;

\connect awx

GRANT ALL ON ALL TABLES IN SCHEMA public TO awx;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO awx;
