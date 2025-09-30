import os
import asyncio
from aiohttp import web
from aiogram import Bot, Dispatcher, types, F

API_TOKEN = os.getenv("API_TOKEN")
WEBHOOK_HOST = "https://tg-bot-xu7z.onrender.com"   # твой Render URL
WEBHOOK_PATH = "/webhook"
WEBHOOK_URL = f"{WEBHOOK_HOST}{WEBHOOK_PATH}"

bot = Bot(token=API_TOKEN)
dp = Dispatcher()

# --- Хэндлеры ---
@dp.message(F.text.in_({"/start", "/help"}))
async def send_welcome(message: types.Message):
    await message.reply("Привет! Я твой бот (webhook).")

from aiogram.types import ReplyKeyboardMarkup, KeyboardButton
from aiogram import F

# --- Кнопка ---
kb = ReplyKeyboardMarkup(
    keyboard=[
        [KeyboardButton(text="Есть ли жизнь на Марсе?")]
    ],
    resize_keyboard=True
)

# --- Ответ на кнопку ---
@dp.message(F.text == "Есть ли жизнь на Марсе?")
async def mars_answer(message: types.Message):
    await message.answer("И там её нет...")

# --- Обновляем /start ---
@dp.message(F.text == "/start")
async def send_welcome(message: types.Message):
    await message.answer("Привет! Я твой бот. Жми кнопку 👇", reply_markup=kb)


@dp.message()
async def echo(message: types.Message):
    await message.answer(message.text)

# --- Webhook обработчик ---
async def handle_webhook(request):
    update = await request.json()
    await dp.feed_webhook_update(bot, update)
    return web.Response()

# --- Старт приложения ---
async def on_startup(app):
    await bot.set_webhook(WEBHOOK_URL)

async def on_shutdown(app):
    await bot.delete_webhook()
    await bot.session.close()

def main():
    app = web.Application()
    app.router.add_post(WEBHOOK_PATH, handle_webhook)
    app.on_startup.append(on_startup)
    app.on_shutdown.append(on_shutdown)
    web.run_app(app, host="0.0.0.0", port=int(os.getenv("PORT", 10000)))

if __name__ == "__main__":
    main()
