import os
from aiogram import Bot, Dispatcher, types, F
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
from aiohttp import web

API_TOKEN = os.getenv("API_TOKEN")
WEBHOOK_PATH = "/webhook"
WEBHOOK_HOST = os.getenv("RENDER_EXTERNAL_URL")  # Render URL (например: https://tg-bot-xxx.onrender.com)
WEBHOOK_URL = f"{WEBHOOK_HOST}{WEBHOOK_PATH}"

bot = Bot(token=API_TOKEN)
dp = Dispatcher()

# --- Главное меню ---
def main_menu():
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="Привет 👋", callback_data="hello")],
        [InlineKeyboardButton(text="Помощь ❓", callback_data="help")],
        [InlineKeyboardButton(text="Есть ли жизнь на Марсе? 🚀", callback_data="mars")],
        [InlineKeyboardButton(text="О боте 🤖", callback_data="about")]
    ])
    return keyboard


# --- Вложенное меню "О боте" ---
def about_menu():
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="Создатель 👨‍💻", callback_data="creator")],
        [InlineKeyboardButton(text="Назад 🔙", callback_data="back_to_main")]
    ])
    return keyboard


# --- Команда /start ---
@dp.message(F.text == "/start")
async def start_handler(message: types.Message):
    await message.answer("Главное меню:", reply_markup=main_menu())


# --- Обработка кнопок ---
@dp.callback_query()
async def handle_menu(callback: types.CallbackQuery):
    if callback.data == "hello":
        await callback.message.answer("Привет! Я твой бот 🚀")
    elif callback.data == "help":
        await callback.message.answer("Список команд: /start — открыть меню")
    elif callback.data == "mars":
        await callback.message.answer("И там её нет... 🌌")
    elif callback.data == "about":
        await callback.message.answer("Открываю меню 'О боте':", reply_markup=about_menu())
    elif callback.data == "creator":
        await callback.message.answer("Создатель: compact 🚀")
    elif callback.data == "back_to_main":
        await callback.message.answer("Возвращаюсь в главное меню:", reply_markup=main_menu())

    await callback.answer()  # убираем "часики" у кнопки


# --- Webhook ---
async def on_startup(app):
    await bot.set_webhook(WEBHOOK_URL)


async def on_shutdown(app):
    await bot.delete_webhook()


async def handle(request):
    data = await request.json()
    update = types.Update(**data)
    await dp.feed_update(bot, update)
    return web.Response()


def main():
    app = web.Application()
    app.router.add_post(WEBHOOK_PATH, handle)

    app.on_startup.append(on_startup)
    app.on_shutdown.append(on_shutdown)

    web.run_app(app, host="0.0.0.0", port=int(os.getenv("PORT", 10000)))


if __name__ == "__main__":
    main()
