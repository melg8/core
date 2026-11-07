Сюда scripts\03-setup-database.bat складывает дампы MySQL:

    logon.sql       -> база realmd
    mangos.sql      -> база mangos   (world)
    characters.sql  -> база characters
    logs.sql        -> база logs

Если файлов нет, скрипт сам скачает последний снимок из релиза
https://github.com/vmangos/core/releases/tag/db_latest

Можно также положить файлы сюда вручную (например, из CI-артефакта
development-mysql-dump -> mysql-dump\) и запустить scripts\03-setup-database.bat.
