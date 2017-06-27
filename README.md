# postgresprodocker
Postgres Professional based on docker ubuntu:latest

#Как собрать контейнер
`docker build -t containername .`
#Как запустить контейнер
`docker run -it --rm -e POSTGRES_PASSWORD=mysecretpassword -e POSTGRES_USER=mydbuser -e POSTGRES_DB=mydb -p 5432:5432 -v $(PWD)/pg_data:/var/lib/postgresql/data -e POSTGRES_INITDB_ARGS='--locale ru_RU.utf8' containername`

`$(PWD)` - абсолютный путь к папке проекта

`--locale ru_RU.utf8` нужно чтобы работал полнотекстовый поиск по русскому языку

#Папка pg_data должна быть пустой для инициализации базы