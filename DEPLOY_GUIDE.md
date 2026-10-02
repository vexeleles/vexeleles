# Starlify Shop — деплой (бот + Mini App + оплата как одно целое)

Теперь **всё запускается одной программой на одном адресе**: бот сам отдаёт сайт (`/`), API (`/api/...`) и эмблемы (`/assets/...`).
Netlify, cloudflared и правка `apiBase` в `index.html` **больше не нужны** — адрес API и username бота подставляются автоматически.

## Что нужно сделать вам (один раз)

### 1. Токены
- **BOT_TOKEN** — @BotFather → `/newbot` (или `/mybots` → API Token).
- **CRYPTO_BOT_TOKEN** — @CryptoBot → Crypto Pay → My Apps → Create App → API Token.
- **ADMIN_IDS** — ваш Telegram ID (@userinfobot), несколько — через запятую.

### 2. Хостинг (выберите один)

**A. VPS — рекомендую.** Timeweb Cloud / Hetzner / Selectel, Ubuntu 22.04/24.04, 1 CPU / 1 ГБ RAM хватит (~200–400 ₽/мес). Нужен домен (≈100–1000 ₽/год): создайте A-запись `shop.ваш-домен.ru` → IP сервера.

**B. Railway / Render** — проще, без Linux. Нужен платный always-on план (бесплатные «засыпают», бот перестанет отвечать). Домен выдают сами, но подключите **Volume/Disk** к `/data`, иначе база удалится при каждом деплое.

> Бесплатный Netlify/Vercel/GitHub Pages для этого проекта не подходят: бот должен работать 24/7.

### 3. Деплой на VPS (команды копируйте по порядку)
```bash
# на сервере
curl -fsSL https://get.docker.com | sh
# загрузите проект (scp/FileZilla или git) в папку ~/StarlifyShop, затем:
cd ~/StarlifyShop
cp bot/.env.example bot/.env && nano bot/.env      # впишите токены, ADMIN_IDS и SHOP_WEBAPP_URL=https://shop.ваш-домен.ru
nano Caddyfile                                       # замените shop.example.com на ваш домен
docker compose up -d --build
docker compose logs -f bot                           # ждём "Система StarlifyShop запущена."
```
HTTPS-сертификат Caddy получит сам. Проверка: откройте `https://shop.ваш-домен.ru/api/health` → `{"ok": true}`.

Обновление после правок: загрузить файлы и `docker compose up -d --build`.
Старую базу перенесите так: `docker compose cp starlify_shop.db bot:/data/starlify_shop.db && docker compose restart bot`.

### 3б. Деплой на Railway/Render
1. Залейте проект в **приватный** GitHub-репозиторий (`.env` не коммитить — он в `.gitignore`).
2. New Project → Deploy from repo → сборка по `Dockerfile` в корне.
3. Variables: `BOT_TOKEN`, `CRYPTO_BOT_TOKEN`, `ADMIN_IDS`, `SHOP_WEBAPP_URL` (выданный публичный https-адрес сервиса), `DB_PATH=/data/starlify_shop.db`.
4. Подключите Volume, mount path `/data`. Порт подхватывается автоматически (`PORT`).

### 4. Что бот делает сам после запуска
- ставит кнопку «🛍 Магазин» в главное меню и синюю кнопку меню у строки ввода (в BotFather ничего настраивать не надо);
- подставляет в Mini App свой `@username` и адрес API;
- цену, счёт CryptoBot и проверку оплаты считает сервер — страницу подделать нельзя.

### 5. Настройка оплаты внутри бота (админ-панель)
Реквизиты карты (`card_number`, `card_name`), курс Stars и цены Premium берутся из настроек бота в БД — задайте их через админ-команды бота. Оплата картой подтверждается вами кнопками в боте; CryptoBot подтверждается автоматически по кнопке «Проверить оплату».

## Проверка (чек-лист)
1. ☐ `/api/health` отвечает `{"ok": true}` по https
2. ☐ В боте `/start` → есть кнопка «🛍 Магазин» → открывается магазин, цены не нулевые
3. ☐ Тестовый заказ → счёт CryptoBot (для проверки можно `CRYPTO_BOT_TESTNET=true` + токен из @CryptoTestnetBot) → оплата → «Проверить оплату» → статус ВЫПОЛНЕН, вам приходит уведомление
4. ☐ Заказ картой → вам приходит сообщение с кнопками подтверждения

## Безопасность
- Токены только в `bot/.env`. Если токен где-то «светился» — перевыпустите (@BotFather → Revoke; CryptoBot → пересоздать токен приложения).
- Делайте бэкап `/data/starlify_shop.db` (там заказы и пользователи).

## Локальный тест на своём ПК (без домена)
`cd bot && python main.py` → сайт на `http://localhost:8080/`. Для Telegram нужен https: `cloudflared tunnel --url http://localhost:8080`, адрес из вывода — в `SHOP_WEBAPP_URL`.
