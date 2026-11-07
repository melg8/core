# Локальный сервер VMaNGOS (WoW 1.12.1) — пошаговый запуск

Все скрипты лежат в папке `scripts\`. Настройки — в одном файле
`scripts\00-server-config.bat` (пути, MySQL, порты, клиент).

## Порядок запуска

| Шаг | Скрипт | Что делает |
|----|--------|------------|
| 1 | `scripts\01-check-setup.bat` | Проверяет сборку, данные карт, MySQL, базы, клиент |
| 2 | `scripts\02-start-mysql.bat` | Запускает MySQL из XAMPP (служба или отдельный процесс) |
| 3 | `scripts\03-setup-database.bat` | Создаёт базы, скачивает/импортирует дампы, правит конфиги |
| 4 | `scripts\04-start-server.bat` | Запускает `realmd.exe` и `mangosd.exe` |
| 5 | `scripts\05-create-account.bat` | Создаёт аккаунт и выдаёт GM-права |
| 6 | `scripts\06-play.bat` | Пишет `realmlist.wtf` и запускает `wow.exe` |
| — | `scripts\07-stop-server.bat` | Корректно останавливает сервер |
| — | `scripts\08-install-mysql-service.bat` | (опционально) ставит MySQL службой Windows |

Первый запуск: `01` → `02` → `03` → `04` → `05` → `06` (все из `scripts\`).
Дальше достаточно `02` (если MySQL не служба) → `04` → `06`.

## Что важно знать

### Сборка
Скрипты ничего не собирают. Сначала должен отработать `build.bat` в корне
проекта: в `bin\` появятся `mangosd.exe`, `realmd.exe`, `mangosd.conf`,
`realmd.conf`, а также `maps\`, `vmaps\`, `mmaps\`, `5875\dbc\`.

### MySQL
- По умолчанию скрипты рассчитаны на XAMPP: `C:\xampp\mysql`,
  администратор `root` **без пароля** (используется только скриптами).
  Если у тебя иначе — поправь `MYSQL_HOME`, `MYSQL_USER`, `MYSQL_PASS`
  в `scripts\00-server-config.bat`.
- Для самого сервера `scripts\03-setup-database.bat` создаёт отдельного
  пользователя MySQL `mangos` / `mangos` (`DB_USER` / `DB_PASS`) и
  прописывает его в `bin\mangosd.conf` и `bin\realmd.conf`.
  Пустой пароль тут использовать нельзя: парсер строки подключения ядра
  пропускает пустые поля и сдвигает остальные значения.
- `scripts\02-start-mysql.bat` сначала пробует службу `MySQL`, затем
  запускает `mysqld.exe` отдельным свёрнутым окном. Это окно закрывать
  нельзя.
- Надёжный вариант — один раз запустить
  `scripts\08-install-mysql-service.bat` от администратора: MySQL будет
  стартовать сам после перезагрузки.
- **Не запускай MySQL кнопкой в XAMPP Control Panel** — на этой машине
  панель молча роняет mysqld сразу после создания сокета. Скрипты
  используют рабочий способ.

### Базы данных
- `scripts\03-setup-database.bat` берёт готовые дампы из GitHub-релиза
  [`db_latest`](https://github.com/vmangos/core/releases/tag/db_latest)
  (это тот же снимок, что собирает CI: база `world_full_14_june_2021`
  + все миграции). Если дампы уже лежат в `db\` — скачивание пропускается.
- Импорт старых дампов требует ослабленного `sql_mode` и большого
  `max_allowed_packet`; скрипт выставляет это сам.
- Повторный импорт с нуля: `scripts\03-setup-database.bat reimport`
  (**удалит** текущие базы `realmd`, `mangos`, `characters`, `logs`).
- `03` также обновляет устаревшие `bin\mangosd.conf` / `bin\realmd.conf`
  из свежих шаблонов (старые сохраняются как `*.conf.bak`) и прописывает
  в них актуальные подключения к MySQL. `StrictVersionCheck` остаётся
  выключенным, чтобы работали модифицированные клиенты.

### Аккаунты
В этом ядре пароль хранится в SRP6-виде (`account.v` / `account.s`),
поэтому SQL-вставкой аккаунт не создать. `scripts\05-create-account.bat`:
1. копирует в буфер обмена команды
   `account create <логин> <пароль>` и `account set gmlevel <логин> 3`;
2. ты вставляешь их в окно **VMaNGOS mangosd** и жмёшь Enter;
3. скрипт проверяет, что аккаунт появился в базе.

Логин и пароль — латиница/цифры/`_` (так проще для консоли).
Аккаунт по умолчанию: `admin` / `admin` (меняется в
`scripts\00-server-config.bat`).

### Клиент
- Нужен чистый WoW **1.12.1 (build 5875)**.
- `scripts\06-play.bat` при первом запуске спросит папку с `wow.exe` и
  запомнит её в `client-dir.txt` в корне проекта.
- Скрипт пишет в клиент `realmlist.wtf`:
  `set realmlist 127.0.0.1` (адрес берётся из `REALM_ADDRESS`).
- Если сервер не запущен, скрипт предложит запустить его.

### Остановка
- `scripts\07-stop-server.bat` копирует в буфер обмена команду
  `server shutdown 0` (корректное сохранение). Вставь её в окно
  `mangosd` и нажми Enter — скрипт ждёт до 60 секунд и только потом
  предлагает принудительное завершение.
- `realmd` можно убивать без последствий.

## Если что-то не работает

| Симптом | Что делать |
|---------|------------|
| `MySQL не запущен` | `scripts\02-start-mysql.bat`; проверь `C:\xampp\mysql\data\mysql_error.log` |
| MySQL стартует из консоли, но не из панели XAMPP | не жми кнопку Start в `xampp-control.exe`; используй `scripts\02-start-mysql.bat` или `scripts\08-install-mysql-service.bat` |
| `Index for table 'db' is corrupt` | `C:\xampp\mysql\bin\mysqlcheck.exe -h 127.0.0.1 -u root --auto-repair mysql` |
| `mangosd не открыл порт 8085` | смотри `bin\Server.log`, `bin\DBErrors.log`, окно `VMaNGOS mangosd` |
| `Config contains invalid realmID` | `scripts\03-setup-database.bat` (создаёт запись `realmlist` id=1) |
| Ошибки доступа к БД | `scripts\03-setup-database.bat` (правит `*.conf` под `MYSQL_*`) |
| Клиент не видит сервер | проверь `realmlist.wtf` и что `realmd` слушает 3724 |
| Импорт падает на zero-date | `03` уже выставляет `sql_mode=''`; если правил вручную — выставь снова |
| Долгая загрузка мира | это нормально при первом старте, жди до 1–2 минут |

## Ручные проверки

```bat
netstat -ano | findstr ":3306"
netstat -ano | findstr ":3724"
netstat -ano | findstr ":8085"
```

Консоль `mangosd` понимает команды: `server info`, `save all`,
`server shutdown 0`, `account create ...`, `account set gmlevel ...`.

## Файлы

```
build.bat                     сборка ядра (в корне проекта)
scripts\00-server-config.bat  настройки (правь только его)
scripts\01-check-setup.bat    проверка
scripts\02-start-mysql.bat    запуск MySQL
scripts\03-setup-database.bat базы + конфиги
scripts\04-start-server.bat   realmd + mangosd
scripts\05-create-account.bat аккаунт + GM
scripts\06-play.bat           realmlist.wtf + wow.exe
scripts\07-stop-server.bat    остановка
scripts\08-install-mysql-service.bat  MySQL как служба (опционально)
tools\patch-db-config.ps1     правка подключений в конфигах
tools\fetch-db-dump.ps1       скачивание дампов с GitHub
db\                           сюда кладутся/скачиваются *.sql
client-dir.txt                путь к клиенту (создаётся автоматически)
```
