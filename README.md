# Пример службы systemd 

В репозитории реализован пример службы `systemd` в рамках тестового задания.

## Принцип работы 

1. Служба мониторит заданный процесс (см. "Установка службы")
2. Если процесс запущен, отправляется запрос по заданной конечной точке
3. Если процесс был перезапущен, пишет об этом в лог
4. Если процесса нет, то ничего не делает

## Скрипт

Скрипт отправляет запрос со следующими данными:

- `name` -- имя процесса
- `PID` -- PID процесса
- `date` -- время выполнения скрипта в формате `YYYY-mm-ddTHH:MM:SS`

Для однократного запуска:

```console
foo@bar:~$ ./monitoring -e [ENDPOINT] -p [PROCESS_NAME]
```

- `[PROCESS_NAME]` -- имя процесса, который нужно мониторить (по умол. `test`)
- `[ENDPOINT]` -- конечная точка, куда нужно стучаться в случае запущенного процесса (по умол. `https://test.com/monitoring/test/api`)

## Установка службы

Для установки необходимы права администратора.

```console
foo@bar:~$ sudo ./install.sh -e [ENDPOINT] -p [PROCESS_NAME]
```

- `[PROCESS_NAME]` -- имя процесса, который нужно мониторить (по умол. `test`)
- `[ENDPOINT]` -- конечная точка, куда нужно стучаться в случае запущенного процесса (по умол. `https://test.com/monitoring/test/api`)

## Проверка

Для проверки можно использовать сервис [PutsReq](https://putsreq.com/). Для этого нужно:

1. Зайти на сайт;
2. Нажать "Create a PutsReq";
3. Вставить в поле "Responce builder" код ниже:
```javascript
// Build a response
var msg = 'Hello World';

if(request.params.name) {
  msg = 'Process: ' + request.params.name + '\n';
}

if (request.params.pid) {
    msg += 'PID: ' + request.params.pid + '\n';
}

if (request.params.date) {
    msg += 'Date: ' + request.params.date + '\n';
}

response.body = msg;
```
4. Скопировать URL;
5. Запустить скрипт командой:
```console
foo@bar:~$ ./monitoring -e [URL] -p [PROCESS_NAME]
```

В поле "Responce" должен появиться ответ, похожий на следующий:
```
Process: emacs
PID: 448899
Date: 2025-05-19T21:59:55
```

# Примечания

1. По умолчанию, служба отрабатывает раз в 20 секунд. Чтобы это
   изменить, нужно поменять значение `OnUnitActiveSec` в файле
   `monitoring.timer.template`.
2. Установочный скрипт копирует исполняемый файл в директорию
   `/usr/bin/`, которая должна быть включена в переменную `PATH`.
