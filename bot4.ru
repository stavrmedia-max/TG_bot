import os
import asyncio
from aiohttp import web
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command

# Берём токен из переменной окружения
API_TOKEN = os.getenv("API_TOKEN")

# Создаём бота и диспетчер
bot = Bot(token=API_TOKEN)
dp = Dispatcher()

# Обработка /start и /help
@dp.message(Command(commands=["start", "help"]))
async def send_welcome(message: types.Message):
    await message.reply("Привет! Я твой бот (работаю на Render через webhook).")

# Эхо-функция (повторяет текст)
@dp.message()
async def echo(message: types.Message):
    await message.answer(message.text)

# Обработка обновлений (webhook)
async def handle(request):
    data = await request.json()
    update = types.Update(**data)
    await dp.feed_update(bot, update)
    return web.Response()

# Настройка вебхука
async def on_startup(app):
    webhook_url = f"{os.getenv('RENDER_EXTERNAL_URL')}/webhook"
    await bot.set_webhook(webhook_url)

async def on_shutdown(app):
    await bot.session.close()

# Запуск aiohttp веб-сервера
def main():
    app = web.Application()
    app.router.add_post("/webhook", handle)
    app.on_startup.append(on_startup)
    app.on_shutdown.append(on_shutdown)
    web.run_app(app, port=int(os.getenv("PORT", 8080)))

if __name__ == "__main__":
    main()
