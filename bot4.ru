import os
from aiogram import Bot, Dispatcher, types, F
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
from aiohttp import web

API_TOKEN = os.getenv("API_TOKEN")
WEBHOOK_HOST = os.getenv("RENDER_EXTERNAL_URL")
WEBHOOK_PATH = "/webhook"
WEBHOOK_URL = f"{WEBHOOK_HOST}{WEBHOOK_PATH}"

bot = Bot(token=API_TOKEN)
dp = Dispatcher()


# ==== Главное меню ====
def main_menu():
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="Привет 👋", callback_data="hello")],
        [InlineKeyboardButton(text="Помощь ❓", callback_data="help")],
        [InlineKeyboardButton(text="Есть ли жизнь на Марсе?", callback_data="mars")],
        [InlineKeyboardButton(text="Меню 📋", callback_data="menu")]
    ])


# ==== Вложенное меню ====
def about_menu():
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="О боте 🤖", callback_data="about_bot")],
        [InlineKeyboardButton(text="Создатель 👨‍💻", callback_data="creator")],
        [InlineKeyboardButton(text="Назад 🔙", callback_data="back")]
    ])


# ==== Хэндлеры ====
@dp.message(F.text.in_({"start", "/start", "help", "/help"}))
async def send_welcome(message: types.Message):
    await message.answer("Главное меню:", reply_markup=main_menu())


@dp.callback_query(F.data == "hello")
async def process_hello(callback: types.CallbackQuery):
    await callback.message.answer("Привет! Я твой бот 🚀")
    await callback.answer()


@dp.callback_query(F.data == "help")
async def process_help(callback: types.CallbackQuery):
    await callback.message.answer("Я умею отвечать на простые вопросы.")
    await callback.answer()


@dp.callback_query(F.data == "mars")
async def process_mars(callback: types.CallbackQuery):
    await callback.message.answer("И там её нет...")
    await callback.answer()


@dp.callback_query(F.data == "menu")
async def process_menu(callback: types.CallbackQuery):
    await callback.message.answer("Открываю меню 📋", reply_markup=about_menu())
    await callback.answer()


@dp.callback_query(F.data == "about_bot")
async def process_about(callback: types.CallbackQuery):
    await callback.message.answer("Я учебный Telegram-бот 🤖 на aiogram.")
    await callback.answer()


@dp.callback_query(F.data == "creator")
async def process_creator(callback: types.CallbackQuery):
    await callback.message.answer("Создатель: compact 🚀")
    await callback.answer()


@dp.callback_query(F.data == "back")
async def process_back(callback: types.CallbackQuery):
    await callback.message.answer("Возврат в главное меню:", reply_markup=main_menu())
    await callback.answer()


# ==== Webhook сервер ====
async def on_startup(app):
    await bot.set_webhook(WEBHOOK_URL)
    print(f"Webhook set to {WEBHOOK_URL}")

async def on_shutdown(app):
    await bot.delete_webhook()
    await bot.session.close()

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
