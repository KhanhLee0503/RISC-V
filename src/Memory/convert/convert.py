from PIL import Image

# Use a try-except block to handle file not found errors
try:
    # Open the image file
    image = Image.open("image.png")
    pixels = image.load()
    
    # Get the actual dimensions of the image
    width, height = image.size

    # Open the binary output file in binary write mode
    with open("image.hex", "wb") as out_file:
        # Loop through a specific region of the image
        for y in range(190):
            for x in range(350):
                # Check if the pixel coordinates are within the image boundaries
                if x < width and y < height:
                    pixel_value = pixels[x, y]
                    
                    # Convert the pixel value to a single byte
                    # Handles both RGB tuples and grayscale integer values
                    if isinstance(pixel_value, tuple):
                        # Extract the red channel (index 0) from the tuple
                        out_file.write(bytes([pixel_value[0]]))
                    else:
                        # For grayscale images, the value is already an integer
                        out_file.write(bytes([pixel_value]))
                else:
                    # Write a zero byte if the coordinates are out of bounds
                    out_file.write(bytes([0]))
    print("Conversion successful: image.hex has been created.")

except FileNotFoundError:
    print("Error: The file 'image.png' was not found.")
except Exception as e:
    print(f"An unexpected error occurred: {e}")