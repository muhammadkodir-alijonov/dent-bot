import asyncio
import logging
import os
import ssl
import aiohttp
from aiogram import Bot, Dispatcher, types
from aiogram.filters import CommandStart
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")

# Bot va Dispatcher yaratish
bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

@dp.message(CommandStart())
async def start_handler(message: types.Message):
    """Start komandasi - manzil button bilan"""
    
    welcome_text = """
🦷 **Stomatologiya Klinikamizga xush kelibsiz!**

Bizning xizmatlar:
• Plomba qo'yish
• Karonka o'rnatish  
• Implant operatsiyalari
• Ortodontiya (tish to'g'rilash)
• Profilaktika xizmatlari

📞 **Bog'lanish:** +998901234567
📍 **Manzil:** Namangan, Xo'jand qishlog'i

Quyidagi tugma orqali bizning manzilimizni ko'rishingiz mumkin:
    """
    
    # Inline keyboard yaratish
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [
            InlineKeyboardButton(
                text="📍 Klinika manzili", 
                url="https://maps.app.goo.gl/PXf3WKvqqwngj4PA6"
            )
        ]
    ])
    
    await message.answer(
        welcome_text,
        parse_mode="Markdown",
        reply_markup=keyboard
    )

@dp.message()
async def all_messages_handler(message: types.Message):
    """Barcha xabarlarga manzil button bilan javob"""
    welcome_text = """
🦷 **Stomatologiya Klinikamizga xush kelibsiz!**

Bizning xizmatlar:
• Plomba qo'yish
• Karonka o'rnatish  
• Implant operatsiyalari
• Ortodontiya (tish to'g'rilash)
• Profilaktika xizmatlari

📞 **Bog'lanish:** +998994928385
📍 **Manzil:** Namangan, Xo'jand qishlog'i

Quyidagi tugma orqali bizning manzilimizni ko'rishingiz mumkin:
    """
    
    # Inline keyboard yaratish
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [
            InlineKeyboardButton(
                text="📍 Klinika manzili", 
                url="https://maps.app.goo.gl/PXf3WKvqqwngj4PA6"
            )
        ]
    ])
    
    try:
        await message.answer(
            welcome_text,
            parse_mode="Markdown",
            reply_markup=keyboard
        )
    except Exception as e:
        logging.error(f"Message handler error: {e}")
        await message.answer("Xatolik yuz berdi")

async def setup_bot():
    """Bot setup function"""
    if not BOT_TOKEN:
        logging.warning("BOT_TOKEN not found. Telegram bot will not work.")
        return
    
    try:
        # Bot ma'lumotlarini olish (timeout bilan)
        bot_info = await asyncio.wait_for(bot.get_me(), timeout=10.0)
        logging.info(f"Bot started: @{bot_info.username}")
        
        # Webhook o'rnatish (production uchun)
        # await bot.set_webhook(f"{WEBAPP_URL}/webhook")
        
        # Polling boshqarish (development uchun)
        asyncio.create_task(start_polling())
        
    except asyncio.TimeoutError:
        logging.error("Bot setup timeout: Telegram API ga ulanib bo'lmadi")
        raise Exception("Telegram API timeout")
    except Exception as e:
        logging.error(f"Bot setup error: {e}")
        raise

async def start_polling():
    """Bot polling boshqarish"""
    try:
        await dp.start_polling(bot)
    except Exception as e:
        logging.error(f"Polling error: {e}")

# Webhook handler (production uchun)
async def webhook_handler(update_data: dict):
    """Webhook orqali kelgan update larni qayta ishlash"""
    try:
        update = types.Update(**update_data)
        await dp.feed_update(bot, update)
    except Exception as e:
        logging.error(f"Webhook error: {e}")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    asyncio.run(setup_bot())