import asyncio
import logging
import os
import ssl
from typing import Optional
from dotenv import load_dotenv

# Telegram bot import'lari faqat mavjud bo'lsa
try:
    from aiogram import Bot, Dispatcher, types
    from aiogram.filters import CommandStart
    from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton, ReplyKeyboardMarkup, KeyboardButton
    AIOGRAM_AVAILABLE = True
except ImportError:
    AIOGRAM_AVAILABLE = False
    print("Aiogram kutubxonasi topilmadi, telegram bot ishlamaydi")

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")

# Bot va Dispatcher yaratish (faqat token mavjud bo'lsa)
bot: Optional[Bot] = None
dp: Optional[Dispatcher] = None

if AIOGRAM_AVAILABLE and BOT_TOKEN and BOT_TOKEN != "your-telegram-bot-token-here":
    try:
        bot = Bot(token=BOT_TOKEN)
        dp = Dispatcher()
        print("Telegram bot muvaffaqiyatli yaratildi")
    except Exception as e:
        print(f"Telegram bot yaratishda xatolik: {e}")
        bot = None
        dp = None
else:
    print("Telegram bot tokeni topilmadi yoki aiogram o'rnatilmagan")

# Botni faqat mavjud bo'lganda sozlash
if bot and dp:
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
        
        # Reply keyboard ham qo'shamiz
        reply_keyboard = ReplyKeyboardMarkup(
            keyboard=[
                [
                    KeyboardButton(text="📞 Telefon raqam")
                ],
                [
                    KeyboardButton(text="📍 Manzil")
                ]
            ],
            resize_keyboard=True,
            one_time_keyboard=False
        )
        
        await message.answer(
            welcome_text,
            parse_mode="Markdown",
            reply_markup=keyboard
        )

@dp.message()
async def all_messages_handler(message: types.Message):
    """Barcha xabarlarga javob - text message'lar uchun"""
    
    # Agar "Telefon raqam" tugmasi bosilsa
    if message.text == "📞 Telefon raqam":
        phone_text = """
📞 **Bizning kontakt ma'lumotlarimiz:**

**Telefon:** +998994928385
**Telegram:** @stom_namangan

Bu raqamni nusxalab, telefon ilovasida qo'ng'iroq qilishingiz mumkin.
        """
        await message.answer(phone_text, parse_mode="Markdown")
        return
    
    # Agar "Manzil" tugmasi bosilsa  
    if message.text == "📍 Manzil":
        keyboard = InlineKeyboardMarkup(inline_keyboard=[
            [
                InlineKeyboardButton(
                    text="📍 Klinika manzili", 
                    url="https://maps.app.goo.gl/PXf3WKvqqwngj4PA6"
                )
            ]
        ])
        await message.answer("Bizning manzilimiz:", reply_markup=keyboard)
        return
    
    # Boshqa barcha message'larga standart javob"""
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

# Callback handler qo'shish kerak
if bot and dp:
    @dp.callback_query()
    async def callback_handler(callback: types.CallbackQuery):
        """Callback tugmalari uchun handler"""
        if callback.data == "phone_number":
            phone_text = """
📞 **Bizning kontakt ma'lumotlarimiz:**

**Telefon:** +998994928385
**Telegram:** @stom_namangan

Bu raqamni nusxalab, telefon ilovasida qo'ng'iroq qilishingiz mumkin.
            """
            await callback.message.answer(phone_text, parse_mode="Markdown")
            await callback.answer("Telefon raqam ko'rsatildi")

async def get_bot_info():
    """Bot ma'lumotlarini olish"""
    if not BOT_TOKEN:
        return {"available": False, "error": "BOT_TOKEN not found"}
    
    try:
        bot_info = await asyncio.wait_for(bot.get_me(), timeout=10.0)
        return {
            "available": True,
            "id": bot_info.id,
            "username": bot_info.username,
            "first_name": bot_info.first_name
        }
    except asyncio.TimeoutError:
        return {"available": False, "error": "Timeout"}
    except Exception as e:
        return {"available": False, "error": str(e)}

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