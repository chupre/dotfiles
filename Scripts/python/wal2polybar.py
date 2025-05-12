import colorsys
import json
import os
import re

# Paths
PYWAL_COLORS_JSON = os.path.expanduser("~/.cache/wal/colors.json")
POLYBAR_COLORS_FILE = "/home/denis/.config/polybar/shapes/colors.ini"
ROFI_COLORS_FILE = "/home/denis/.config/rofi/themes/colors.rasi"

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb):
    return "#{:02X}{:02X}{:02X}".format(*rgb)

def get_pywal_dominant_color():
    if not os.path.exists(PYWAL_COLORS_JSON):
        raise FileNotFoundError(f"pywal colors file not found: {PYWAL_COLORS_JSON}")
    
    with open(PYWAL_COLORS_JSON, "r") as f:
        colors = json.load(f)
    
    # You can choose color0, color1, or "special" background depending on taste
    return hex_to_rgb(colors["colors"]["color0"])

def generate_shades(rgb, num_shades=8):
    r, g, b = [x / 255.0 for x in rgb]
    h, l, s = colorsys.rgb_to_hls(r, g, b)

    min_l = max(0.05, l - 0.35)
    max_l = min(0.95, l + 0.35)
    lightness_values = [min_l + x * (max_l - min_l) / (num_shades - 1) for x in range(num_shades)]

    shades = []
    for li in lightness_values:
        r, g, b = colorsys.hls_to_rgb(h, li, s)
        rgb_shade = (int(r * 255), int(g * 255), int(b * 255))
        shades.append(rgb_to_hex(rgb_shade))
    return shades

def update_polybar_colors(shades):
    with open(POLYBAR_COLORS_FILE, "r") as file:
        lines = file.readlines()

    new_lines = []
    for line in lines:
        match = re.match(r'^(?!;;)\s*(shade[1-8])\s*=\s*#[0-9A-Fa-f]+', line)
        if match:
            index = int(match.group(1)[-1]) - 1
            new_line = f"{match.group(1)} = {shades[index]}\n"
            new_lines.append(new_line)
        else:
            new_lines.append(line)

    with open(POLYBAR_COLORS_FILE, "w") as file:
        file.writelines(new_lines)

    print(f"✅ Updated Polybar shades in: {POLYBAR_COLORS_FILE}")

def update_rofi_colors(shades):
    with open(ROFI_COLORS_FILE, "r") as file:
        lines = file.readlines()

    replacements = {
        "bg1": shades[1] + "FF",
        "bg2": shades[2] + "FF",
        "bg3": shades[3] + "FF",
    }

    new_lines = []
    for line in lines:
        match = re.match(r'^(\s*)(bg[123])\s*:\s*#[0-9A-Fa-f]{8};', line)
        if match:
            indent, key = match.groups()
            new_color = replacements.get(key, "")
            if new_color:
                new_line = f"{indent}{key}:   {new_color};\n"
                new_lines.append(new_line)
                continue
        new_lines.append(line)

    with open(ROFI_COLORS_FILE, "w") as file:
        file.writelines(new_lines)

    print(f"✅ Updated Rofi colors in: {ROFI_COLORS_FILE}")

def main():
    base_rgb = get_pywal_dominant_color()
    shades = generate_shades(base_rgb)
    update_polybar_colors(shades)
    update_rofi_colors(shades)

if __name__ == "__main__":
    main()
