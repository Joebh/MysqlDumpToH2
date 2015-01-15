# MysqlDumpToH2
Bash Script to convert an ansi mysqldump to h2 compatible.
For DDL scripts I generate like
 mysqldump --compatible=ansi --ignore-table=global.plan_price_to_copy --ignore-table=global.plan_rate_to_copy --skip-triggers --no-data -u <user> -p<password> <db> > DDL.sql

For DML scripts I generate like
mysqldump --compatible=ansi --skip-triggers --extended-insert=FALSE  --no-create-info -u <user> -p<password> <db> > DML.sql

./h2dump.sh DDL.sql DML.sql
