import os
import sys
import argparse
from PIL import Image

def strip_metadata(input_path, output_path):
    """
    Removes EXIF metadata by creating a new image from the data
    and saving it without the original info.
    """
    try:
        # Open the image
        img = Image.open(input_path)
        
        # We create a new image with the same mode and size.
        # This effectively drops all metadata attached to the original object.
        data = list(img.getdata())
        image_without_exif = Image.new(img.mode, img.size)
        image_without_exif.putdata(data)
        
        # Save to output
        image_without_exif.save(output_path)
        print(f"✓ Cleaned: {os.path.basename(input_path)}")
        return True
    except (IOError, OSError, ValueError) as e:
        # Catches UnidentifiedImageError (subclass of OSError in recent Pillow)
        print(f"✗ Failed (Invalid Image): {os.path.basename(input_path)} - {str(e)}")
        return False
    except Exception as e:
        print(f"✗ Failed: {os.path.basename(input_path)} - {str(e)}")
        return False

def main():
    parser = argparse.ArgumentParser(description="GoDark: Image Metadata Stripper")
    parser.add_argument("input", help="File or Directory to process")
    parser.add_argument("-o", "--output", default="cleaned_images", help="Output directory (default: cleaned_images)")
    
    args = parser.parse_args()
    
    # Create output directory
    if not os.path.exists(args.output):
        os.makedirs(args.output)
        print(f"Created output directory: {args.output}")

    if os.path.isfile(args.input):
        filename = os.path.basename(args.input)
        out_path = os.path.join(args.output, filename)
        strip_metadata(args.input, out_path)
        
    elif os.path.isdir(args.input):
        print(f"Scanning directory: {args.input}")
        for filename in os.listdir(args.input):
            if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.tiff', '.bmp')):
                in_path = os.path.join(args.input, filename)
                out_path = os.path.join(args.output, filename)
                strip_metadata(in_path, out_path)
    else:
        print("Error: Input path not found.")

if __name__ == "__main__":
    main()
