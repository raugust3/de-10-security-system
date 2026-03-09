from PIL import Image
import easygui # pip install easygui

'''
TITLE: DE-10 SECURITY SYSTEM - IMAGE RESIZE UTILITY
GROUP: Richard Augustine (251275608), Clarrie Wang (251292784)
COURSE: Microprocessors & Microcomputers (ECE 3375)
PROFESSORS: Dr. Ken McIssac, Dr. Anestis Dounavis
DATE OF SUBMISSION: April 4, 2026

DESCRIPTION: this script resizes an input image to 320x240 pixels, to be 
used as input for the image conversion utility (convert.py).
'''

input_file = easygui.fileopenbox(title='Select Original File', filetypes=["*.jpg", "*.png"])
output_path = easygui.filesavebox(title='Save File to...', default='resized_image.jpg')

if input_file and output_path:
    try:
        with Image.open(input_file) as img:
            # Convert to RGB to strip Alpha channels (prevents errors with PNG -> JPG)
            img = img.convert("RGB")
            
            # Resize to the exact VGA buffer dimensions
            resized_img = img.resize((320, 240), Image.Resampling.LANCZOS)
            
            resized_img.save(output_path)
            print(f"Success! Saved to: {output_path}\nDimensions: 320x240", "Process Complete")
            
    except Exception as e:
        easygui.exceptionbox(f"Error occurred: {e}")
else:
    print("Operation cancelled by user.")