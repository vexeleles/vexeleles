# Starlify Shop — бот + Mini App

```
bot/      Telegram-бот (aiogram) + API для Mini App (webapi.py)
webapp/   Mini App: index.html + assets/ (эмблемы)
```

## Запуск бота
```bash
cd bot
python -m venv venv
venv\Scripts\activate            # Linux/Mac: source venv/bin/activate
pip install -r requirements.txt
copy .env.example .env           # Linux/Mac: cp — и заполните токены и ADMIN_IDS
python main.py
```
Ваш прежний `starlify_shop.db` в архив не клал, чтобы не затереть данные: положите его в папку `bot/` (или бот создаст новый).

## Как Mini App связывается с ботом
Бот сам отдаёт сайт и API с одного адреса. Бесплатный запуск без карты — DEPLOY_FREE.md, VPS — DEPLOY_GUIDE.md.
- Для теста: `cloudflared tunnel --url http://localhost:8080` выдаст адрес вида `https://xxxx.trycloudflare.com`.
- Постоянно: VPS + домен (nginx/caddy проксирует на порт 8080).

Впишите адрес в `webapp/index.html` → `CONFIG.apiBase`, например `"https://xxxx.trycloudflare.com/api"`.
Затем загрузите папку `webapp/` на Netlify (Deploys → перетащить папку). Без рабочего API магазин ничего не засчитывает — так и задумано.

## Как поменять эмблемы
Эмблемы: `stars`, `premium`, `ton`, `crypto` (CryptoBot), `coin` (монеты).
1. Положите свой файл в `webapp/assets/` (svg/png/webp, лучше квадрат от 128x128).
2. В `webapp/index.html` найдите `CUSTOM_EMBLEMS` и впишите путь:
```js
const CUSTOM_EMBLEMS = { stars:"", premium:"", ton:"assets/ton.png", crypto:"", coin:"" };
```
Пусто = встроенная эмблема. Перезалейте `webapp/` на Netlify и заново откройте Mini App.
Иконки интерфейса (корзина, профиль и т.д.) лежат в объекте `ICONS` там же.
Аватарка самого бота: @BotFather -> `/setuserpic`.

## Безопасность
- Токены только в `.env`. Если `.env` с токенами уже кому-то уходил, перевыпустите их: @BotFather -> Revoke current token, @CryptoBot -> Crypto Pay -> пересоздать токен приложения.
- Цену, счёт CryptoBot и проверку оплаты делает сервер, Mini App не доверяем.
- Оплата картой подтверждается админом вручную кнопками в боте.

## Цены и курсы из админки
В боте: `/admin` → «⚙️ Изменение цен/инфо». Меняются без перезапуска:
- Курс Stars (грн за 1 ⭐), Premium 3 мес. / 6 мес. / 1 год
- Мин. количество Stars (по умолчанию 50)
- Курс TON (грн): `0` = брать живой курс из CryptoBot
- Курс доллара (грн): по нему считаются крипто-счета
- Карта, поддержка, отзывы, % рефералов, скидка на открытие
