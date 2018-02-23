# 常用PG管理SQL手册
Some individual technical documents for PostgreSQL

---

#### 查询触发器

> SELECT t.tgname, n.nspname, c.relname, p.proname
	FROM pg_trigger t, pg_class c, pg_namespace n, pg_proc p
		WHERE t.tgrelid = c.oid
          AND c.relnamespace = n.oid
          AND t.tgfoid = p.oid
          AND t.tgisinternal = 'f';
		  

#### 修改字段类型

> alter table 表名 alter column 字段名 type 类型 ;  


#### 导入PG后台日志
> CREATE TABLE postgres_log
    (
        log_time timestamp without time zone,
        user_name text,
        database_name text,
        process_id integer,
        connection_from text,
        session_id text,
        session_line_num bigint,
        command_tag text,
        session_start_time timestamp without time zone,
        virtual_transaction_id text,
        transaction_id bigint,
        error_severity text,
        sql_state_code text,
        message text,
        detail text,
        hint text,
        internal_query text,
        internal_query_pos integer,
        context text,
        query text,
        query_pos integer,
        location text,
        application_name text
    );
    
> COPY postgres_log FROM '/data/pgsql/data/pg_log/postgresql-xxxx-xx-xx_000000.csv' WITH CSV;