import zipfile
import os

zip_path = r'c:\Users\abdul\OneDrive\Desktop\Comp Lang NEW\ISD-TV-Display-System\ISD-TV-Display-System\display\bootanimation.zip'
source_dir = r'c:\Users\abdul\OneDrive\Desktop\Comp Lang NEW\ISD-TV-Display-System\ISD-TV-Display-System\display\temp_boot'

if os.path.exists(zip_path):
    os.remove(zip_path)

with zipfile.ZipFile(zip_path, 'w', compression=zipfile.ZIP_STORED) as z:
    # Add desc.txt
    z.write(os.path.join(source_dir, 'desc.txt'), 'desc.txt')
    # Add part0/000.png
    z.write(os.path.join(source_dir, 'part0', '000.png'), 'part0/000.png')

print(f"Created {zip_path} with 0% compression.")
