# Stage 1: сборка бинарника
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Копируем только файлы зависимостей (для кэширования слоёв)
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код (без tracker.db!)
COPY main.go parcel.go parcel_test.go ./

# Собираем статический бинарник
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/tracker .

# Stage 2: финальный минимальный образ
FROM alpine:3.19

WORKDIR /app

# Из builder забираем ТОЛЬКО бинарник
COPY --from=builder /app/tracker /app/tracker

# БД создаётся приложением при первом запуске, удалять ничего не нужно
CMD ["./tracker"]