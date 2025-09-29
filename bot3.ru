import asyncio
from aiogram import Bot, Dispatcher, types, F

API_TOKEN = "7217070254:AAGbUE1iqJ00L58wTK-supfH6-8mVk8E_bE"

bot = Bot(token=API_TOKEN)
dp = Dispatcher()

# Ответ на /start и /help
@dp.message(F.text.in_(["/start", "/help"]))
async def send_welcome(message: types.Message):
    await message.reply("Привет! Я твой бот.")

# Эхо-функция
@dp.message()
async def echo(message: types.Message):
    await message.answer(message.text)

async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
