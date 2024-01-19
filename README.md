# <a name="up">Пример инстркуции - Deploy сервисов v1.</a>
Требования к подготовке сервисов: в Container Registry подготовить образы для ручного развертывания на прод. Подготовить инструкцию для ручного развертывания. 

---

- [Технические требования](#rec)
- [Архитектура](#arc)
- [Установка фронтэнда](#front)
    - [step.step_kabinet](#step_kabinet)
    - [step.step_front](#step_front)
- [Установка бэкэнда](#back)
    - [step.step](#step)
    - [step.accruals](#accruals)
    - [step.users](#users)
    - [step.activity](#activity)
- [Установка реестров](#reg)
- [Настройка nginx](#nginx)
- [Сборка образов вручную](#images)

[up](#up)

# <a name="rec">Технические требования</a>
- git
- postgresql 14.8 и выше
- [docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) (не забыть после установки добавить пользователя в группу docker `sudo usermod -aG docker ${USER}` и потом перелогинится)
- nginx

[up](#up)

# <a name="arc">Архитектура</a>
Схема взаимодействия сервисов в проекте.
![step scheme](https://github.com/mucasgun/ci/assets/128498037/c6b70978-7a64-4cd4-9224-d4668230fb40)


Пример сетевой связанности для тестового стенда.
![nginx_scheme_mydomen](https://github.com/mucasgun/ci/assets/128498037/b19e4b95-ba7f-461b-89b9-e9c0700d2c0d)



[up](#up)






# <a name="front">Установка фронтэнда</a>
Для сервисов фронтэнда настроена автоматизированная сборка и доставка приложений на тестовый сервер. 

В Container Registry в зависимости от ветки билдятся образы для тестового (ветка stage) с тегом `latest` и для  прод. сервера (ветка prod) с тегом `latest` 

Если необходимо измененить значения переменных для сборки, то их можно поменять в Settings -> CI/CD -> Variables.

## <a name="step_kabinet">Сервис step.step_kabinet</a>


Необходимые переменные (пример заполнения для тестового сервера):
```
NEXT_PUBLIC_REACT_APP_API_URL=https://api...
```
##### Первичная установка
1. Cоздать для сервиса отдельную директорию.
2. Скачать docker-compose файл, необходимо изменить значение mysecretoken на свое:
```sh
curl -o docker-compose.yml --header 'PRIVATE-TOKEN: <mysecretoken>' "https://git.mydomen.com/api/v4/projects/145/repository/files/docker-compose.yml/raw?ref=prod"
```
3. Авторизоваться в Container Registry (заменить значения myusername, mypassword на свои):
```sh
docker login docker.mydomen.com
```
4. Запустить контейнер приложения:
```sh
docker compose up -d
```
##### Обновление версии
1. Перейти в директорию сервиса.
2. Удалить контейнер и образ:
```sh
docker compose down
docker rmi docker.mydomen.com/mydomen.start/step/step_kabinet/prod:latest
```
3. Повторить п. 2-4 раздела "Первичная установка".

[up](#up)

## <a name="step_front">Сервис step.step_front (плагины)</a>

Необходимые переменные (пример заполнения для тестового сервера):
```
REACT_APP_API_URL=https://api...
REACT_APP_API_URL_ACCRUALS=https://api....
REACT_APP_NODE_ID=d3d45520
```
##### Первичная установка
1. Cоздать для сервиса отдельную директорию.
2. Скачать docker-compose файл, необходимо изменить значение mysecretoken на свое:
```sh
curl -o docker-compose.yml --header 'PRIVATE-TOKEN: <mysecretoken>' "https://git.mydomen.com/api/v4/projects/137/repository/files/docker-compose.yml/raw?ref=prod"
```
3. Авторизоваться в Container Registry (заменить значения myusername, mypassword на свои):
```sh
docker login docker.mydomen.com
```
4. Запустить контейнер приложения:
```sh
docker compose up -d
```
##### Обновление версии
1. Перейти в директорию сервиса.
2. Удалить контейнер и образ:
```sh
docker compose down
docker rmi docker.mydomen.com/mydomen.start/step/step_front/prod:latest
```
3. Повторить п. 2-2 раздела "Первичная установка".

[up](#up)




# <a name="back">Установка бэкэнда</a>
Для сервисов бэкэнда настроена автоматизированная сборка и доставка приложений на тестовый сервер. 

В Container Registry в зависимости от ветки билдятся образы для тестового (ветка stage) с тегом `latest` и для  прод. сервера (ветка prod) с тегом `latest`

## <a name="step">Сервис step.step</a>
1. Cоздать отдельную директорию для сервиса
2. Перейти в директорию сервиса, дальнейшие действия выполнять в ней.
3. В каждой из директории создать файл `.env.dev`, заполнить значениями для прод. сервера. Пример заполнения файла:
```sh
SECRET_KEY=mysecretkey78849
DB_NAME=registries
USER=postgres
```
Перечень переменных в файле `.env.dev`

| Переменная | Пример | Описание |
| ------ | ------ | ------ |
| SECRET_KEY | mysecretkey78849 | key to securing signed data | 
| DEBUG | 0 | включение режима отладки DEBUG=1, выключение DEBUG=0 | 
| DJANGO_ALLOWED_HOSTS | 127.0.0.1 | список хостов/доменов, для которых может работать текущий сайт | 
| DJANGO_CORS_ALLOWED_ORIGINS | http://127.0.0.1:3000 | список источников, авторизованных для выполнения межсайтовых HTTP-запросов | 
| BASE_URL_RAIDA | https://api.. | URL Райды |
| USER_RAIDA | user | пользователь Райды 
| PASSWD_RAIDA | mysecretpassword | пароль пользователя Райды |
| NODE_ID | d3d45520 | значение NODE_ID в Райде, связанное с данным сервисом |
| PROCESS_ID_CONTESTS | f0136ed7 | значение PROCESS_ID_CONTESTS в Райде, связанное с данным сервисом |
| PROCESS_ID_DOCONTESTS | c6988fb67 | значение PROCESS_ID_DOCONTESTS в Райде, связанное с данным сервисом |

4. Скачать docker-compose.yml, необходимо изменить значение mysecretoken на свое:
```sh
curl -o docker-compose.yml --header 'PRIVATE-TOKEN: <mysecretoken>' "https://git.mydomen.com/api/v4/projects/117/repository/files/docker-compose.yml/raw?ref=prod"
```
5. Авторизоваться в Container Registry (заменить значения myusername, mypassword на свои):
```sh
docker login docker.mydomen.com
```
6. Запустить контейнер приложения:
```sh
docker compose up -d
```
##### Обновление версии
1. Перейти в директорию сервиса.
2. Удалить контейнер и образ:
```sh
docker compose down
docker rmi docker.mydomen.com/mydomen.start/step/step/prod:latest
```
3. Повторить п. 4-6 раздела "Первичная установка" (при изменении перечня переменных и п.3).

[up](#up)

## <a name="accruals">Сервис step.accruals</a>
1. Cоздать отдельную директорию для сервиса
2. Перейти в директорию сервиса, дальнейшие действия выполнять в ней.
3. В каждой из директории создать файл `.env.dev`, заполнить значениями для прод. сервера.

Перечень переменных в файле `.env.dev`

| Переменная | Пример | Описание |
| ------ | ------ | ------ |
| SECRET_KEY | mysecretkey78849 | key to securing signed data | 
| DEBUG | 0 | включение режима отладки DEBUG=1, выключение DEBUG=0 | 
| DJANGO_ALLOWED_HOSTS | 127.0.0.1 | список хостов/доменов, для которых может работать текущий сайт | 
| DJANGO_CORS_ALLOWED_ORIGINS | http://127.0.0.1:3000 | список источников, авторизованных для выполнения межсайтовых HTTP-запросов |
| BASE_URL_RAIDA | https://api... | URL Райды | 
| BASE_URL_SERVICES | https://api... | URL бэкэнда | 
| USER_RAIDA | user | пользователь Райды 
| PASSWORD_RAIDA | mysecretpassword | пароль пользователя Райды |
| NODE_ID | d3d45520 | значение NODE_ID в Райде, связанное с данным сервисом |
| PROCESS_ID_CONTESTS | f0136ed7 | значение PROCESS_ID_CONTESTS в Райде, связанное с данным сервисом |

4. Скачать docker-compose.yml, необходимо изменить значение mysecretoken на свое:
```sh
curl -o docker-compose.yml --header 'PRIVATE-TOKEN: <mysecretoken>' "https://git.mydomen.com/api/v4/projects/148/repository/files/docker-compose.yml/raw?ref=prod"
```
5. Авторизоваться в Container Registry (заменить значения myusername, mypassword на свои):
```sh
docker login docker.mydomen.com
```
6. Запустить контейнер приложения:
```sh
docker compose up -d
```
##### Обновление версии
1. Перейти в директорию сервиса.
2. Удалить контейнер и образ:
```sh
docker compose down
docker rmi docker.mydomen.com/mydomen.start/step/accruals/prod:latest
```
3. Повторить п. 4-6 раздела "Первичная установка" (при изменении перечня переменных и п.3).

[up](#up)

## <a name="users">Сервис step.users</a>
1. Cоздать отдельную директорию для сервиса
2. Перейти в директорию сервиса, дальнейшие действия выполнять в ней.
3. В каждой из директории создать файл `.env.dev`, заполнить значениями для прод. сервера. 

Перечень переменных в файле `.env.dev`

| Переменная | Пример | Описание |
| ------ | ------ | ------ |
| SECRET_KEY | mysecretkey78849 | key to securing signed data | 
| DEBUG | 0 | включение режима отладки DEBUG=1, выключение DEBUG=0 | 
| DJANGO_ALLOWED_HOSTS | 127.0.0.1 | список хостов/доменов, для которых может работать текущий сайт | 
| DJANGO_CORS_ALLOWED_ORIGINS | http://127.0.0.1:3000 | список источников, авторизованных для выполнения межсайтовых HTTP-запросов |
| BASE_URL_RAIDA | https://api... | URL Райды | 
| USER_RAIDA | user | пользователь Райды 
| PASSWORD_RAIDA | mysecretpassword | пароль пользователя Райды |
| NODE_ID | d3d45520 | значение NODE_ID в Райде, связанное с данным сервисом |

4. Скачать docker-compose.yml, необходимо изменить значение mysecretoken на свое:
```sh
curl -o docker-compose.yml --header 'PRIVATE-TOKEN: <mysecretoken>' "https://git.mydomen.com/api/v4/projects/149/repository/files/docker-compose.yml/raw?ref=prod"
```
5. Авторизоваться в Container Registry (заменить значения myusername, mypassword на свои):
```sh
docker login docker.mydomen.com
```
6. Запустить контейнер приложения:
```sh
docker compose up -d
```
##### Обновление версии
1. Перейти в директорию сервиса.
2. Удалить контейнер и образ:
```sh
docker compose down
docker rmi docker.mydomen.com/mydomen.start/step/users/prod:latest
```
3. Повторить п. 4-6 раздела "Первичная установка" (при изменении перечня переменных и п.3).

[up](#up)

## <a name="activity">Сервис step.activity</a>
1. Cоздать отдельную директорию для сервиса
2. Перейти в директорию сервиса, дальнейшие действия выполнять в ней.
3. В каждой из директории создать файл `.env.dev`, заполнить значениями для прод. сервера. 

Перечень переменных в файле `.env.dev`

| Переменная | Пример | Описание |
| ------ | ------ | ------ |
| SECRET_KEY | mysecretkey78849 | key to securing signed data | 
| DEBUG | 0 | включение режима отладки DEBUG=1, выключение DEBUG=0 | 
| DJANGO_ALLOWED_HOSTS | 127.0.0.1 | список хостов/доменов, для которых может работать текущий сайт | 
| DJANGO_CORS_ALLOWED_ORIGINS | http://127.0.0.1:3000 | список источников, авторизованных для выполнения межсайтовых HTTP-запросов |
| BASE_URL_REGISTRY | https://reg... | URL Реестров | 

4. Скачать docker-compose.yml, необходимо изменить значение mysecretoken на свое:
```sh
curl -o docker-compose.yml --header 'PRIVATE-TOKEN: <mysecretoken>' "https://git.mydomen.com/api/v4/projects/147/repository/files/docker-compose.yml/raw?ref=prod"
```
5. Авторизоваться в Container Registry (заменить значения myusername, mypassword на свои):
```sh
docker login docker.mydomen.com
```
6. Запустить контейнер приложения:
```sh
docker compose up -d
```
##### Обновление версии
1. Перейти в директорию сервиса.
2. Удалить контейнер и образ:
```sh
docker compose down
docker rmi docker.mydomen.com/mydomen.start/step/activity/prod:latest
```
3. Повторить п. 4-6 раздела "Первичная установка" (при изменении перечня переменных и п.3).

[up](#up)





# <a name="reg">Установка реестров</a>
Требуется БД PostgreSQL версии 14.8 и выше. Перед установкой убедиться, что БД доступна для подключения.
Образ опубликован в Container Registry после ручной сборки.  
##### Первичная установка
1. Cоздать для сервиса отдельную директорию.
2. В этой директории создать файл `.env.dev`, заполнить значениями для прод. сервера. Перечень переменных и пример заполнения файла:
```sh
SECRET_KEY=mysecretkey78849
DB_NAME=step
USER=step
PASSWORD=mysecretpasswd78849
HOST=192.168.1.112
PORT=5432
DJANGO_ALLOWED_HOSTS=127.0.0.1
DJANGO_CORS_ALLOWED_ORIGINS=https://api...
DEBUG=True
```
3. Скачать docker-compose файл, необходимо изменить значение mysecretoken на свое:
```sh
curl -o docker-compose.yml --header 'PRIVATE-TOKEN: <mysecretoken>' "https://git.mydomen.com/api/v4/projects/140/repository/files/docker-compose.yml/raw?ref=develop"
```
4. Авторизоваться в Container Registry (заменить значения myusername, mypassword на свои):
```sh
docker login docker.mydomen.com
```
5. Запустить контейнер приложения:
```sh
docker compose up -d
```
##### Обновление версии
1. Перейти в директорию сервиса.
2. Удалить контейнер и образ:
```sh
docker compose down
docker rmi docker.mydomen.com/mydomen.start/step/re_step:latest
```
3. Повторить п. 3-5 раздела "Первичная установка" (при изменениии перечня переменных и п. 2).

[up](#up)

# <a name="nginx">Настройка nginx</a>
Изменение доменных имен сервисов осуществляется через переменные контейнеров. 
Изменение location для сервисов бэкэнда не предусмотрено.

В конфигурацию nginx добавить client_max_body_size 60M;

[up](#up)

# <a name="images">Сборка образов вручную</a>
В случае необходимости можно вручную собрать и запустить контейнеры сервисов (не забывая остановить и удалить старые).
1. склонировать репозиторий
2. в файле docker-compose.yml раскомментировать строку `#build .` и закомментровать строку `image: ...`
3. запустить билд
```sh
docker compose build
```
4. запустить контейнеры
```
docker compose up -d
```


[up](#up)
