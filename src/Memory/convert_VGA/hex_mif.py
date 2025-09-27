hex_file = "sekiro.hex"
mif_file = "sekiro.mif"

WIDTH = 6
DEPTH = 430*795

with open(hex_file) as f:
    data = [line.strip() for line in f if line.strip()]

with open(mif_file, "w") as f:
    f.write(f"WIDTH={WIDTH};\n")
    f.write(f"DEPTH={DEPTH};\n")
    f.write("ADDRESS_RADIX=HEX;\n")
    f.write("DATA_RADIX=HEX;\n\n")
    f.write("CONTENT BEGIN\n")

    for addr, value in enumerate(data):
        f.write(f"{addr:05X} : {value};\n")

    f.write("END;\n")
