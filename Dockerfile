# будем использовать multistage build, сначала соберём приложение в большом образе с Go
# затем скопируем готовый исполняемый файл в маленький базовый образ
# сборка базового образа
FROM golang:1.24.2 AS builder

# установка рабочей директории, под линукс
WORKDIR /usr/src/app 

# копирование файлов для первичной сборки
COPY go.mod go.sum ./ 

# загрузка зависимостей
RUN go mod download

# копирование исходного кода, чтобы потом собрать приложение
COPY *.go ./ 

# сборка приложения
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./parcel_service

# базовая сборка завершена, теперь финальный этап, собираем компактный образ
FROM alpine:latest

# снова указываем рабочую директорию
WORKDIR /usr/src/app 

# копируем бинарник
COPY --from=builder /usr/src/app/parcel_service ./

# копирование файла БД
COPY tracker.db ./ 

# запускаем приложение
CMD ["./parcel_service"]



