#!/bin/bash

createTables=$(cat $1)

#remove all dash comments
#remove all tick marks
#bigint replaced with numberic
#int sizes to just integer
#delete lock tables lines
#remove all key lines
#convert all enums to varchars
#delete all CONSTRAINT "xxxNamexxx"
#remove KEY "xxxxNamexxxx" from all unique constraints
#remove all default values
#remove character sets
function filter {
    echo "$1" | sed -e "/^--/d" \
    -e 's/CHARACTER SET latin1 COLLATE latin1_general_cs //g' \
    -e 's/CHARACTER SET latin1 COLLATE latin1_general_ci //g' \
    -e 's/ COLLATE latin1_general_cs//g' \
    -e 's/ COLLATE latin1_general_ci//g' \
    -e 's/ NOT NULL//g' \
	-e 's/`//g' \
	-e '/^DROP TABLE/d' \
	-e 's/ COMMENT [^\n]*/,/g' \
	-e 's/bigint/numeric/g' \
	-e 's/double\(([^(]*)\)/double/' \
	-e 's/[^ ]*int([0-9]*)/integer/g' \
	-e '/^\/\*.*\*\//d' \
	-e '/LOCK TABLES/d' \
	-e '/^\/\*/,/\*\//c\;' \
	-e '/^CREATE TABLE/,/);/{/^  KEY/d; }' \
	-e 's/enum(.*)/varchar(255)/g' \
	-e 's/CONSTRAINT "[^"]*"/ADD/g' \
	-e 's/UNIQUE KEY "[^"]*"/UNIQUE/g' \
	-e 's/ DEFAULT [^\n]*/,/g' \
	-e 's/CHARACTER SET [^ ]*//g' \
	-e 's/^CREATE TABLE/CREATE TABLE IF NOT EXISTS/g' \
	-e 's/ text / varchar(65535) /g' \
	-e "s/\\\'/''/g" \
	| sed -r 's/"(.*)"/"\U\1"/g' \
	| sed -r '/UNIQUE/  s/([^,]*)\([0-9]*\)/\1/g'
}

createTables=$(filter "$createTables")

foreignKeys=$(echo "$createTables" | sed -r 's/CREATE TABLE IF NOT EXISTS ("[^"]*") \(/ALTER TABLE \1/g' | sed -n -e '/ALTER TABLE/,/);/ {/ALTER TABLE/ {x} ; /FOREIGN/ {x;p;x;p} }' | sed -r -e '/REFERENCES/ s/,//g' -e 's/(REFERENCES .*)/\1;/g')

#delete create tables foreign key
createTables=$(echo "$createTables" | sed '/ADD FOREIGN KEY/d' | sed -n '/CREATE TABLE/,/);/ {/);/ {x ; s/,$//g; p; x; p} ; /);/ !{x ; p}}' | sed '/CREATE TABLE/,/);/ !{d}')

echo "$createTables"
echo "$foreignKeys"

if [ $# -eq 2 ]
    then
    filter "$(cat $2)"
fi

