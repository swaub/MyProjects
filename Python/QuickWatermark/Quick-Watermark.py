import os
from PIL import Image, ImageDraw, ImageFont
import argparse

def add_watermark(input_folder, output_folder, text):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Process files
    for filename in os.listdir(input_folder):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.webp')):
            try:
                img_path = os.path.join(input_folder, filename)
                img = Image.open(img_path).convert("RGBA")
                
                # Create drawing object
                txt = Image.new('RGBA', img.size, (255, 255, 255, 0))
                d = ImageDraw.Draw(txt)
                
                # Basic font scaling (using default font if custom font not found)
                width, height = img.size
                font_size = int(height / 20)
                
                font = None
                # List of potential system fonts (Windows, Linux, macOS)
                possible_fonts = ["arial.ttf", "Arial.ttf", "DejaVuSans.ttf", "LiberationSans-Regular.ttf", "FreeSans.ttf"]
                
                for font_name in possible_fonts:
                    try:
                        font = ImageFont.truetype(font_name, font_size)
                        break
                    except IOError:
                        continue
                
                if font is None:
                    print(f"Warning: No system font found. Using default (non-scalable).")
                    font = ImageFont.load_default()

                # Position at bottom right
                # textbbox is available in newer Pillow versions
                bbox = d.textbbox((0, 0), text, font=font)
                textwidth = bbox[2] - bbox[0]
                textheight = bbox[3] - bbox[1]
                
                x = width - textwidth - 20
                y = height - textheight - 20
                
                # Draw text with transparency (white with 50% alpha)
                d.text((x, y), text, fill=(255, 255, 255, 128), font=font)
                
                # Combine and save
                watermarked = Image.alpha_composite(img, txt)
                out_filename = f"watermarked_{filename}"
                watermarked.convert("RGB").save(os.path.join(output_folder, out_filename), "JPEG")
                print(f"✓ Processed: {filename}")
                
            except Exception as e:
                print(f"✗ Failed: {filename} ({e})")

def main():
    parser = argparse.ArgumentParser(description="Apply text watermarks to all images in a folder.")
    parser.add_argument("input", help="Folder containing source images")
    parser.add_argument("-o", "--output", default="watermarked_output", help="Folder for output (default: watermarked_output)")
    parser.add_argument("-t", "--text", default="© Copyright", help="Watermark text (default: © Copyright)")
    
    args = parser.parse_args()
    
    if not os.path.isdir(args.input):
        print(f"Error: Input directory '{args.input}' not found.")
        return

    add_watermark(args.input, args.output, args.text)
    print("\nWatermarking complete!")

if __name__ == "__main__":
    main()
