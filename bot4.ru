import asyncio
import os
from aiogram import Bot, Dispatcher, types, F
from aiogram.types import (
    ReplyKeyboardMarkup, KeyboardButton,
    InlineKeyboardMarkup, InlineKeyboardButton
)

API_TOKEN = os.getenv("API_TOKEN")

bot = Bot(token=API_TOKEN)
dp = Dispatcher()

# ===== Постоянные кнопки (ReplyKeyboard) =====
main_kb = ReplyKeyboardMarkup(
    keyboard=[
        [KeyboardButton(text="Привет 👋"), KeyboardButton(text="Помощь ❓")],
        [KeyboardButton(text="Есть ли жизнь на Марсе?")],
        [KeyboardButton(text="Меню 📋")]
    ],
    resize_keyboard=True
)

# ===== Inline-клавиатуры =====
def get_inline_keyboard():
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="Привет 👋", callback_data="hello")],
        [InlineKeyboardButton(text="Помощь ❓", callback_data="help")],
        [InlineKeyboardButton(text="Есть ли жизнь на Марсе?", callback_data="mars")],
        [InlineKeyboardButton(text="Меню 📋", callback_data="menu")]
    ])

def get_submenu():
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="О боте 🤖", callback_data="about")],
        [InlineKeyboardButton(text="Создатель 🧑‍💻", callback_data="author")],
        [InlineKeyboardButton(text="Назад 🔙", callback_data="back")]
    ])

# ===== Команды =====
@dp.message(F.text.lower().in_({"start", "старт", "/start"}))
async def send_welcome(message: types.Message):
    await message.reply(
        "Привет! Я твой бот.\n"
        "Выбирай кнопку внизу или под сообщением 👇",
        reply_markup=main_kb
    )
    await message.answer("А вот inline-кнопки:", reply_markup=get_inline_keyboard())

@dp.message(F.text.lower().in_({"help", "помощь", "/help"}))
async def send_help(message: types.Message):
    await message.reply("Я могу:\n— Приветствовать\n— Отвечать на вопросы\n— Показывать меню\n— Повторять сообщения")

# ===== Обработчики Reply-кнопок =====
@dp.message(F.text.lower() == "привет 👋")
async def reply_hello(message: types.Message):
    await message.reply("Привет! Рад тебя видеть 👋")

@dp.message(F.text.lower() == "помощь ❓")
async def reply_help(message: types.Message):
    await message.reply("Помощь: просто напиши текст, и я повторю его.")

@dp.message(F.text.lower() == "есть ли жизнь на марсе?")
async def mars_answer(message: types.Message):
    await message.reply("И там её нет...")

@dp.message(F.text.lower() == "меню 📋")
async def reply_menu(message: types.Message):
    await message.answer("Открываю меню 📋", reply_markup=get_submenu())

# ===== Inline-кнопки =====
@dp.callback_query()
async def callbacks(callback: types.CallbackQuery):
    if callback.data == "hello":
        await callback.message.answer("Привет! Рад тебя видеть 👋")
    elif callback.data == "help":
        await callback.message.answer("Помощь: просто напиши текст, и я повторю его.")
    elif callback.data == "mars":
        await callback.message.answer("И там её нет...")
    elif callback.data == "menu":
        await callback.message.edit_text("📋 Меню:", reply_markup=get_submenu())
    elif callback.data == "about":
        await callback.message.answer("Я тестовый Telegram-бот, созданный на Python 🐍 с помощью aiogram.")
    elif callback.data == "author":
        await callback.message.answer("Создатель: StavrMedia 🚀")
    elif callback.data == "back":
        await callback.message.edit_text("Главное меню:", reply_markup=get_inline_keyboard())

    await callback.answer()

# ===== Эхо =====
@dp.message()
async def echo(message: types.Message):
    await message.answer(message.text)

# ===== Запуск =====
async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
