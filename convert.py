from PIL import Image
import easygui # pip install easygui

'''
TITLE: DE-10 SECURITY SYSTEM - IMAGE CONVERSION UTILITY
GROUP: Richard Augustine (251275608), Clarrie Wang (251292784)
COURSE: Microprocessors & Microcomputers (ECE 3375)
PROFESSORS: Dr. Ken McIssac, Dr. Anestis Dounavis
DATE OF SUBMISSION: April 4, 2026

DESCRIPTION: this script resamples a standard 24-bit image (RGB) into a 16-bit 
RGB565 format (5 bits red, 6 bits green, 5 bits blue). It outputs a 
text file containing hexadecimal values suitable for inclusion in 
assembly 'data' sections or memory initialization files (.coe/.mif).
it also generates a preview image to show the quality loss from bit-reduction.
'''

# ensure the input image file is of size 320x240 for best results
filename = easygui.fileopenbox(title = 'Select Original File', filetypes = ["*.jpg", "*.png"])
output = easygui.filesavebox(title='Save File to...', default=filename)
image = Image.open(filename)

# create a blank canvas for the "preview" image to see the effect of bit-reduction
img = Image.new('RGB', (320, 240), "black")
pixels = img.load()

# open/create a text file to store the hex codes for assembly use
f = open(output + ".txt", "a")

# iterate through every pixel in the 320x240 frame buffer
for y in range(240):
    for x in range(320):
        # get the original r, g, b values (0-255 each)
        colors = image.getpixel((x, y))
        
        # conversion logic (RGB888 to RGB565) ---
        # red: scale 255 down to 31 (5 bits), then format as a 5-digit binary string
        r = format(int(colors[0] * 31 / 255.), '05b')
        
        # green: scale 255 down to 63 (6 bits), then format as a 6-digit binary string
        g = format(int(colors[1] * 63 / 255.), '06b')
        
        # blue: scale 255 down to 31 (5 bits), then format as a 5-digit binary string
        b = format(int(colors[2] * 31 / 255.), '05b')
        
        # concatenate bits into a single 16-bit string (RRRRRGGGGGGBBBBB)
        n = str(r) + str(g) + str(b)
        
        # convert the binary string to a hexadecimal string (e.g., 0x4A1F)
        n1 = hex(int(n, 2))
        
        # write to file for easy copy-pasting into assembly code
        f.write(n1 + ", ")
        
        # update the preview image using the reduced bit depth values
        pixels[x, y] = (int(colors[0] * 31 / 255.), int(colors[1] * 63 / 255.), int(colors[2] * 31 / 255.))

# get rid of the last ", " and close the text file
f.seek(f.tell() - 2) 
f.truncate()
f.close()