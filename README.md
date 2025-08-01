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
# Установка и настройка

## 1. Клонирование репозитория
```
    git clone git@github.com:assugan/test_task.git
    cd test-task
```
## 2. Установка скрипта
  Скопируйте `.service` и `.timer` в `/etc/systemd/system`:
```
    sudo cp test_monitor.sh /usr/local/bin/test_monitor.sh
    sudo chmod +x /usr/local/bin/test_monitor.sh
```
## 3. Установка systemd unit-файлов
  Скопируйте `.service` и `.timer` в `/etc/systemd/system`:
```
    sudo cp test_monitor.service /etc/systemd/system/
    sudo cp test_monitor.timer /etc/systemd/system/
```
  Обновите конфигурацию systemd:

    `sudo systemctl daemon-reload`

## 4. Включение таймера

    `sudo systemctl enable --now test_monitor.timer`

  Проверьте работу:
  
    `systemctl list-timers | grep test_monitor`

# Проверка работы
## Проверка успешных и неуспешных подключений

