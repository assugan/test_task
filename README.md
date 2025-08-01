# Bash-скрипт для мониторинга процесса `test` с использованием systemd

## Задание

**Написать скрипт на bash для мониторинга процесса `test` в среде Linux.**

Скрипт должен отвечать следующим требованиям:

1. Запускаться при запуске системы (предпочтительно написать юнит systemd в дополнение к скрипту)  
2. Отрабатывать каждую минуту  
3. Если процесс запущен, то стучаться (по HTTPS) на `https://test.com/monitoring/test/api`  
4. Если процесс был перезапущен, писать в лог `/var/log/monitoring.log`  
5. Если сервер мониторинга не доступен, также писать в лог 

---

## Структура
```
test-task/
├── README.md                     # описание проекта
├── test_monitor.sh               # основной Bash-скрипт мониторинга
├── test_monitor.service          # systemd unit: выполняет скрипт однократно
└── test_monitor.timer            # systemd таймер: запускает сервис каждую минуту
```

## Описание файлов

### test_monitor.sh
- Основной Bash-скрипт, выполняющий следующие действия:
	- Проверяет наличие процесса test через `pgrep -x`
	- Если найден:
	  - Получает текущий PID
	  - Сравнивает его с сохранённым значением из `/var/run/test_monitor_state`
	  - Если PID изменился — пишет в лог `/var/log/monitoring.log`
	  - Выполняет HTTPS-запрос на заданный API-адрес
	  - Если сервер недоступен — также пишет в лог
	- Если процесс `test` не запущен — скрипт завершает выполнение

### test_monitor.service
- Однократный `systemd unit` для запуска скрипта:
     - Использует `Type=oneshot`, т.е. запускается и завершает выполнение сразу.

### test_monitor.timer
- Systemd таймер, который выполняет `.service` каждую минуту:
     - `OnBootSec=1min` — первый запуск через минуту после старта
     - `OnUnitActiveSec=1min` — последующие запускаются каждую минуту

# Установка и настройка

## 1. Клонирование репозитория
```
    git clone git@github.com:assugan/test_task.git
    cd test-task
```
## 2. Установка скрипта
###  Скопируйте `.service` и `.timer` в `/etc/systemd/system`:
```
    sudo cp test_monitor.sh /usr/local/bin/test_monitor.sh
    sudo chmod +x /usr/local/bin/test_monitor.sh
```
## 3. Установка systemd unit-файлов
###  Скопируйте `.service` и `.timer` в `/etc/systemd/system`:
```
    sudo cp test_monitor.service /etc/systemd/system/
    sudo cp test_monitor.timer /etc/systemd/system/
```
###  Обновите конфигурацию systemd:
```
    sudo systemctl daemon-reload
```
## 4. Включение таймера
```
    sudo systemctl enable --now test_monitor.timer
```
###  Проверьте работу:
```  
    systemctl list-timers | grep test_monitor
```
# Проверка работы
## Проверка успешных и неуспешных подключений

    1. Чтобы проверить запросы к серверу, можно временно изменить URL на рабочий, например:
```
    API_URL="https://api.github.com"
```
    2. И в `test_monitor.sh` временно включить отладочное логирование: 
```
    echo "$(date '+%Y-%m-%d %H:%M:%S') Successfully pinged $API_URL" >> "$LOG_FILE"
```
    3. Затем вручную запустить:
```
    sudo systemctl start test_monitor.service
    cat /var/log/monitoring.log
```
## Проверка логирования перезапуска процесса

    1.	Создайте фейковый процесс `test`:
```
    echo -e '#!/bin/bash\nsleep 9999' | sudo tee /usr/local/bin/test > /dev/null
    sudo chmod +x /usr/local/bin/test
    /usr/local/bin/test &
```
    2.	Перезапустите его:
```
    pkill test
    /usr/local/bin/test &
```
	4.	Проверьте лог:
```
    cat /var/log/monitoring.log
```
## Пример логов
```
    2025-07-31 13:17:44 Process test restarted: Old PID=4497, New PID=4660
    2025-07-31 13:18:00 Successfully pinged https://api.github.com
    2025-07-31 13:19:01 Monitoring server not reachable at https://test.com/monitoring/test/api
```
