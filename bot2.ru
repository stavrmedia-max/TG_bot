from aiogram import Bot, Dispatcher, executor, types

API_TOKEN = "7217070254:AAGbUE1iqJ00L58wTK-supfH6-8mVk8E_bE"  # вставь свой токен сюда

bot = Bot(token=API_TOKEN)
dp = Dispatcher(bot)

@dp.message_handler(commands=["start", "help"])
async def send_welcome(message: types.Message):
    await message.reply("Привет! Я твой бот.")

@dp.message_handler()
async def echo(message: types.Message):
    await message.answer(message.text)

if __name__ == "__main__":
    executor.start_polling(dp, skip_updates=True)
