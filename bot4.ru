import asyncio
from aiogram import Bot, Dispatcher, types, F
from aiogram.types import ReplyKeyboardMarkup, KeyboardButton
import os

API_TOKEN = os.getenv("API_TOKEN")

bot = Bot(token=API_TOKEN)
dp = Dispatcher()

# Клавиатура
kb = ReplyKeyboardMarkup(
    keyboard=[
        [KeyboardButton(text="Есть ли жизнь на Марсе?")],
        [KeyboardButton(text="Привет"), KeyboardButton(text="Помощь")]
    ],
    resize_keyboard=True
)

# Ответ на /start
@dp.message(F.text == "/start")
async def send_welcome(message: types.Message):
    await message.reply("Привет! Я твой бот 🤖.\nВыбирай кнопку ниже:", reply_markup=kb)

# Ответ на кнопку "Есть ли жизнь на Марсе?"
@dp.message(F.text == "Есть ли жизнь на Марсе?")
async def mars_answer(message: types.Message):
    await message.reply("И там её нет...")

# Ответ на кнопку "Привет"
@dp.message(F.text == "Привет")
async def hello_answer(message: types.Message):
    await message.reply("Привет, человек! 👋")

# Ответ на кнопку "Помощь"
@dp.message(F.text == "Помощь")
async def help_answer(message: types.Message):
    await message.reply("Я пока умею отвечать на простые вопросы.\nДоступные кнопки: Марс, Привет, Помощь.")

# Эхо-функция для остальных сообщений
@dp.message()
async def echo(message: types.Message):
    await message.answer(message.text)

async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
