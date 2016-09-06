Telegram bot that helps FabLab to create a schedule

GUI from web browser - http://booking.fablab61.ru/

[Информация для разработчиков](https://bitbucket.org/serikov/fab_booking_bot/wiki/Developers%20Guide)


### Update object


```
{
    "message": {
        "chat": {
            "first_name": "Pavel",
            "id": 218718957,
            "last_name": "Serikov",
            "type": "private",
            "username": "serikoff"
        },
        "date": 1466636878,
        "from": {
            "first_name": "Pavel",
            "id": 218718957,
            "last_name": "Serikov",
            "username": "serikoff"
        },
        "message_id": 2,
        "text": "test"
    },
    "update_id": 887242539

}
```

Result of getUpdates method:


```
{

    "ok": true,
    "result": [
        {
            "message": {
                "chat": {
                    "first_name": "Pavel",
                    "id": 218718957,
                    "last_name": "Serikov",
                    "type": "private",
                    "username": "serikoff"
                },
                "date": 1466640365,
                "from": {
                    "first_name": "Pavel",
                    "id": 218718957,
                    "last_name": "Serikov",
                    "username": "serikoff"
                },
                "message_id": 18,
                "text": "che delaesh"
            },
            "update_id": 887242555
        },
        {
    	message": {
    		...
 ```


### json.conf

#### keyboard_key

Пое, которое используется для задания клавиатуры к экрану

#### screen_starts_only_from_cmd

Если установлено на true, то screen запустится только по команде, начинающейся со /

#### is_session_end

Последний скрин с которого будут записаны данные. Далее вызывается обработчик

#### Указания по редактированию

Если меняешь name screen, то не забудь просмотреть и root




### Что делает Serikoff::Telegram::Polling ?

1) Срабатывает только если на сервере есть Updates, чтоб не обрабатывать лишнее

2) Складывает все пришедшие Updates в буфер  и сортирует по chat_id для разграничения по пользователям. 
В итоге реагируем только на последнее сообщение от каждого пользователя за polling interval. Т.е. в каждый polling получаем последнее сообщение от каждого chat_id 

3) Удаляет прочитанные сообщения с сервера используя offset


### Что делает Serikoff::Telegram::Screens ?

Осуществляет навигацию по экранам, согласно json конфигу. Также хранит в памяти current_screen и previous_screen

### Что делает Serikoff::Telegram::Sessions ?

Хранит в памяти все сообщения между конкретными сообщениями.
Если экран не был первым, то записывает также в ключ reply_to_screen предыдущий экран



### Goole API

Логин: fablab61ru@gmail.com
Пароль: sexeachdaykeepthedoctoraway

How to: Mojolicious::Plugin::Oauth


