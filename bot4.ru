import os
import asyncio
from aiohttp import web
from aiogram import Bot, Dispatcher, types, F

# токен берём из переменной окружения
API_TOKEN = os.getenv("API_TOKEN")

# Render даёт ссылку на сервис (переменная RENDER_EXTERNAL_URL)
WEBHOOK_HOST = os.getenv("RENDER_EXTERNAL_URL")
WEBHOOK_PATH = "/webhook"
WEBHOOK_URL = f"{WEBHOOK_HOST}{WEBHOOK_PATH}"

bot = Bot(token=API_TOKEN)
dp = Dispatcher()


# --- handlers ---
@dp.message(F.text.in_(['/start', '/help']))
async def send_welcome(message: types.Message):
    await message.reply("Привет! Я твой бот.")


@dp.message()
async def echo(message: types.Message):
    # пример кастомного ответа
    if message.text.lower() == "есть ли жизнь на марсе?":
        await message.answer("И там её нет...")
    else:
        await message.answer(message.text)


# --- webhook logic ---
async def on_startup(app):
    await bot.set_webhook(WEBHOOK_URL)


async def on_shutdown(app):
    await bot.delete_webhook()


async def handle(request):
    data = await request.json()
    update = types.Update(**data)
    await dp.feed_update(bot, update)
    return web.Response()


# --- aiohttp app ---
app = web.Application()
app.router.add_post(WEBHOOK_PATH, handle)
app.on_startup.append(on_startup)
app.on_shutdown.append(on_shutdown)


if __name__ == "__main__":
    web.run_app(app, host="0.0.0.0", port=int(os.getenv("PORT", 10000)))
