create extension pg_mon;
create extension pg_stat_statements;

set pg_stat_statements.track = 'all';

create table t (i int, j text);
create table t2 (i int, j text);
insert into t values (generate_series(1,10), repeat('bsdshkjd3h', 10));
insert into t2 values (generate_series(1,10), repeat('sdsfefedc', 10));
analyze t;
analyze t2;

-- Seq scan query output
select pg_mon_reset();
select pg_stat_statements_reset();
select * from t;
select expected_rows, actual_rows, seq_scans, hist_time_ubounds, hist_time_freq from pg_mon where seq_scans IS NOT NULL;

create index on t(i);
analyze t;
set random_page_cost = 0;

--Index scan output
select pg_mon_reset();
select pg_stat_statements_reset();
select count(*) from t where i < 5;
select expected_rows, actual_rows, seq_scans, index_scans, hist_time_ubounds, hist_time_freq from pg_mon where index_scans IS NOT NULL;

--Join output
select pg_mon_reset();
select pg_stat_statements_reset();
select * from t, t2 where t.i = t2.i;
select expected_rows, actual_rows, seq_scans, index_scans, hash_join_count, hist_time_ubounds, hist_time_freq from pg_mon where hash_join_count > 0;

set enable_hashjoin = 'off';
select pg_mon_reset();
select pg_stat_statements_reset();
select * from t, t2 where t.i = t2.i;
select expected_rows, actual_rows, seq_scans, index_scans, merge_join_count, hist_time_ubounds, hist_time_freq from pg_mon where merge_join_count > 0;

set enable_mergejoin = 'off';
select pg_mon_reset();
select pg_stat_statements_reset();
select * from t, t2 where t.i = t2.i;
select expected_rows, actual_rows, seq_scans, index_scans, nested_loop_join_count, hist_time_ubounds, hist_time_freq from pg_mon where nested_loop_join_count > 0;