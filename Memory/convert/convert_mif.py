def convert_hex_to_mif(input_hex_path, output_mif_path, width, depth):
    """
    Chuyển đổi một file hex thành một file mif.

    Tham số:
    input_hex_path (str): Đường dẫn đến file hex đầu vào.
    output_mif_path (str): Đường dẫn đến file mif đầu ra.
    width (int): Độ rộng của từ dữ liệu (ví dụ: 16 cho 16-bit).
    depth (int): Độ sâu của bộ nhớ (tổng số từ dữ liệu).
    """

    # Đọc dữ liệu từ file hex
    try:
        with open(input_hex_path, 'r') as f_in:
            hex_data = f_in.read().split()
    except FileNotFoundError:
        print(f"Lỗi: Không tìm thấy file đầu vào '{input_hex_path}'.")
        return

    # Kiểm tra xem dữ liệu có đủ với độ sâu của bộ nhớ không
    if len(hex_data) < depth:
        print(f"Cảnh báo: Số lượng dữ liệu hex ({len(hex_data)}) ít hơn độ sâu bộ nhớ ({depth}).")
        hex_data.extend(["0000"] * (depth - len(hex_data)))  # Thêm dữ liệu 0 vào cuối

    # Mở file mif để ghi dữ liệu
    with open(output_mif_path, 'w') as f_out:
        # Ghi phần tiêu đề của file .mif
        f_out.write(f"WIDTH={width};\n")
        f_out.write(f"DEPTH={depth};\n")
        f_out.write("ADDRESS_RADIX=HEX;\n")
        f_out.write("DATA_RADIX=HEX;\n")
        f_out.write("CONTENT BEGIN\n")

        # Ghi từng địa chỉ và dữ liệu tương ứng
        for i in range(depth):
            address = f"{i:0{len(str(hex(depth-1)[2:]))}X}"
            data = hex_data[i]
            f_out.write(f"    {address} : {data};\n")

        # Ghi phần kết thúc của file .mif
        f_out.write("END;\n")

    print(f"Chuyển đổi thành công! File '{output_mif_path}' đã được tạo.")

# --- Cách sử dụng script ---
if __name__ == "__main__":
    # Thay đổi các giá trị này để phù hợp với dự án của bạn
    input_hex_file = "image.hex"  # Tên file hex đầu vào
    output_mif_file = "image.mif"  # Tên file mif đầu ra
    data_width = 6  # Độ rộng dữ liệu, ví dụ 16 bit cho màu RGB565
    memory_depth = 350 * 190  # Tổng số pixel của ảnh đã resize

    convert_hex_to_mif(input_hex_file, output_mif_file, data_width, memory_depth)