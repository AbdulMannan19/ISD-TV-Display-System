import os
from PIL import Image, ImageDraw

# Configuration
LOGO_PATH = 'assets/images/app_icon.jpeg'
OUTPUT_PATH = 'centered_wallpaper.jpg'
SCREEN_SIZE = (1920, 1080)  # Standard Android TV resolution

def create_centered_wallpaper():
    if not os.path.exists(LOGO_PATH):
        print(f"Error: Logo not found at {LOGO_PATH}")
        return

    # 1. Load the logo
    logo = Image.open(LOGO_PATH)
    
    # 2. Create a premium dark gradient background
    bg_width, bg_height = SCREEN_SIZE
    background = Image.new('RGB', SCREEN_SIZE, (15, 15, 15)) # Base deep dark gray
    
    # Add a subtle radial glow in the center using soft green tones
    draw = ImageDraw.Draw(background)
    for i in range(600, 0, -2):
        # Slowly transition from dark green to the base background color
        r = 15 + i // 40
        g = 15 + i // 12 
        b = 15 + i // 40
        color = (r, g, b)
        draw.ellipse([bg_width//2 - i*2, bg_height//2 - i*2, bg_width//2 + i*2, bg_height//2 + i*2], outline=color)

    # 3. Calculate position to center the logo
    logo_width, logo_height = logo.size
    
    # Scale logo (about 50% of the screen height)
    target_height = int(bg_height * 0.5)
    ratio = target_height / logo_height
    new_size = (int(logo_width * ratio), target_height)
    logo = logo.resize(new_size, Image.LANCZOS)
    logo_width, logo_height = logo.size

    offset = ((bg_width - logo_width) // 2, (bg_height - logo_height) // 2)
    
    # 4. Paste logo onto background and save with maximum quality
    background.paste(logo, offset)
    background.save(OUTPUT_PATH, quality=100, subsampling=0)
    print(f"Successfully created premium {OUTPUT_PATH} at {SCREEN_SIZE[0]}x{SCREEN_SIZE[1]}")

if __name__ == "__main__":
    create_centered_wallpaper()
