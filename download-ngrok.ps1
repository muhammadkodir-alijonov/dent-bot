# NGROK DOWNLOAD & SETUP

## Option 1: Download ngrok
1. https://ngrok.com/download ga o'ting
2. Windows 64-bit yuklab oling
3. ZIP faylni extract qiling
4. ngrok.exe ni PATH ga qo'shing yoki loyiha papkasiga qo'ying

## Option 2: Docker bilan (tavsiya)
docker run -it --rm --net=host ngrok/ngrok:latest http 8000

## Option 3: PowerShell bilan yuklab olish
# Bu script ngrok'ni avtomatik yuklab oladi:

$url = "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip"
$output = "ngrok.zip"
Invoke-WebRequest -Uri $url -OutFile $output
Expand-Archive -Path $output -DestinationPath "." -Force
Remove-Item $output

# Keyin ishlatish:
./ngrok config add-authtoken YOUR_TOKEN
./ngrok http 8000