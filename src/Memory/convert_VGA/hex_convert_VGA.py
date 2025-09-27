from PIL import Image

# Mở hình ảnh
img = Image.open('sekiro_image.png')
# Chuyển sang định dạng RGB
img = img.convert('RGB')
pixels = img.load()

width, height = img.size
hex_data = []

# Đọc từng pixel
for y in range(height):
    for x in range(width):
        r, g, b = pixels[x, y]
        # Chuyển đổi 24-bit sang 6-bit màu
        r6 = r >> 6
        g6 = g >> 6
        b6 = b >> 6
        color_6bit = (r6 << 4) | (g6 << 2) | b6
        hex_data.append(color_6bit)

# Ghi dữ liệu hex vào file
with open('sekiro.hex', 'w') as f:
    for value in hex_data:
        # Ghi từng giá trị 6-bit dưới dạng 2 chữ số hex
        f.write(f'{value:02X}\n')