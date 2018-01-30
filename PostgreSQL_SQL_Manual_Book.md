# 常用PG管理SQL手册
Some individual technical documents for PostgreSQL

---

#### 查询触发器

> select t.tgname, n.nspname, c.relname, p.proname
	from pg_trigger t, pg_class c, pg_namespace n, pg_proc p
		where t.tgrelid = c.oid
          and c.relnamespace = n.oid
          and t.tgfoid = p.oid
          and t.tgisinternal = 'f';
		  

#### 修改字段类型

> alter table 表名 alter column 字段名 type 类型 ;  