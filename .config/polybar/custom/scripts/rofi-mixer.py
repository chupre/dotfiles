#!/bin/env python3
import os
import re
import argparse

VOLUME_DELTA = 5
res = os.getenv("ROFI_RETV")
ROFI_RETV = int(res) if res is not None else -1
ROFI_INFO = os.getenv("ROFI_INFO")

# Handle custom entry: Open Volume Control
if ROFI_INFO == "OPEN_VOLUME_CONTROL":
    os.system("setsid pavucontrol >/dev/null 2>&1 < /dev/null &")
    quit()

parser = argparse.ArgumentParser(description="Rofi sound mixer")
parser.add_argument(
    "--type",
    type=str,
    nargs="?",
    choices=["sink", "source", "app"],
    default="sink",
    help="'sink' for speakers, 'source' for microphones, 'app' for applications",
)
parser.add_argument("pos_arg", type=str, nargs="?")
args = parser.parse_args()
first_arg = args.pos_arg
dev_type = args.type

if first_arg == "quit":
    quit()

use_hot_keys = "\x00use-hot-keys\x1ftrue\n"
keep_selection = "\x00keep-selection\x1ftrue\n"
enable_markup = "\x00markup-rows\x1ftrue\n"

if dev_type == "app":
    prompt = "\x00prompt\x1fApplications\n"
else:
    prompt = f"\x00prompt\x1fSelect {'Speaker' if dev_type == 'sink' else 'Microphone'}\n"

print(f"{use_hot_keys}{prompt}{keep_selection}{enable_markup}")

# Add the Open Volume Control button

# Helper functions...
def get_device_from_desc(description):
    res = os.popen(
        f'pactl list {dev_type}s | grep -C2 "Description: {description}" | grep Name | cut -d: -f2 | xargs'
    )
    return res.read().strip()

def get_desc_from_device(device):
    res = os.popen(
        f'pactl list {dev_type}s | grep -C2 {device} | grep -e "Description" | cut -d: -f2'
    )
    return res.read().strip()

def get_sink_input_from_app_name(app_name):
    res = os.popen(
        f'pactl list sink-inputs | grep -B20 "application.name = \\"{app_name}\\"" | grep "Sink Input" | cut -d "#" -f2 | xargs'
    )
    return res.read().strip()

if ROFI_RETV == 1:
    if ROFI_INFO == "OPEN_VOLUME_CONTROL":
        os.system("pavucontrol &")
        quit()
    ROFI_DATA = os.getenv("ROFI_DATA")
    if ROFI_DATA:
        desc = ROFI_INFO
        device = os.popen(f'pactl list sinks| grep -C2 "Description: {desc}"|grep Name|cut -d: -f2|xargs').read().strip()
        app_name, sink_input = ROFI_DATA.split("||")
        os.system(f'pactl move-sink-input {sink_input} "{device}"')
        quit()
    elif dev_type == "app":
        app_name, sink_input = ROFI_INFO.split("||")
        print(f"\x00data\x1f{app_name}||{sink_input}")
        print("\x00prompt\x1fSelect Output Sink for {}\n".format(app_name))
        dev_type = "sink"
    else:
        desc = ROFI_INFO
        device = get_device_from_desc(desc)
        os.system(f'pactl set-default-{dev_type} "{device}"')

if ROFI_RETV == 28:
    if dev_type == "app":
        app_name, sink_input = ROFI_INFO.split("||")
        os.system(f"pactl set-sink-input-volume {sink_input} +{VOLUME_DELTA}%")
    else:
        desc = ROFI_INFO
        device = get_device_from_desc(desc)
        os.system(f'pactl set-{dev_type}-volume "{device}" +{VOLUME_DELTA}%')

if ROFI_RETV == 27:
    if dev_type == "app":
        app_name, sink_input = ROFI_INFO.split("||")
        os.system(f"pactl set-sink-input-volume {sink_input} -{VOLUME_DELTA}%")
    else:
        desc = ROFI_INFO
        device = get_device_from_desc(desc)
        os.system(f'pactl set-{dev_type}-volume "{device}" -{VOLUME_DELTA}%')

if ROFI_RETV == 26:
    if dev_type == "app":
        app_name, sink_input = ROFI_INFO.split("||")
        os.system(f"pactl set-sink-input-mute {sink_input} toggle")
    else:
        desc = ROFI_INFO
        device = get_device_from_desc(desc)
        os.system(f'pactl set-{dev_type}-mute "{device}" toggle')

if ROFI_RETV == 25:
    if dev_type != "app":
        device = get_device_from_desc(ROFI_INFO)
        res = os.popen(f"pactl get-sink-volume {device}")
        line = res.read()
        volumes = line.split("/")
        left_volume = f"{volumes[1].strip()}"
        os.system(f"pactl set-sink-volume {device} {left_volume} {left_volume}")

def create_volume_bar(volume_percent):
    try:
        volume_value = int(volume_percent.strip().rstrip("%"))
    except (ValueError, TypeError):
        volume_value = 0

    volume_value = max(0, volume_value)
    bar_length = 10

    if volume_value > 100:
        overflowed_segments = int(round(min(100, volume_value - 100) / 100 * bar_length))
        filled_segments = bar_length - overflowed_segments
    else:
        overflowed_segments = 0
        filled_segments = int(round(min(100, volume_value) / 100 * bar_length))

    filled = "█"
    empty = "<span foreground='grey'>█</span>"
    bar = "<span foreground='red'>" + filled * overflowed_segments + "</span>" + filled * filled_segments + empty * (bar_length - filled_segments - overflowed_segments)
    return f"{bar} {volume_value}%"

def list_sinks_sources():
    res = os.popen(f"pactl list {dev_type}s")
    lines = res.read()
    res = os.popen(f"pactl get-default-{dev_type}")
    def_device = res.read().strip()

    last_device_match = ""
    last_volume_match = ""
    last_volume_percent = ""
    last_mute_match = ""
    prefix = ""
    mute_icon = ""
    rofi_info = ""

    description_re = re.compile(r"\s*Description: ")
    volume_re = re.compile(r"\s*Volume: ")
    mute_re = re.compile(r"\s*Mute: ")

    for line in lines.splitlines():
        if description_re.match(line):
            last_device_match = line.split("Description: ")[1]
        elif mute_re.match(line):
            muted = line.split("Mute: ")
            if muted[1] == "yes":
                last_mute_match = "(Muted)"
                mute_icon = '\x1ficon\x1f<span color="white">ﱝ</span>'
            else:
                mute_icon = ""
                last_mute_match = ""
        elif volume_re.match(line):
            volumes = line.split("/")
            volume_percent_match = re.search(r"(\d+)%", volumes[1])
            if volume_percent_match:
                last_volume_percent = volume_percent_match.group(1)
            volume_bar = create_volume_bar(last_volume_percent)
            last_volume_match = volume_bar
            rofi_info = f"\x00info\x1f{last_device_match}"
            prefix = "" if def_device == get_device_from_desc(last_device_match) else ""
            dev_title = last_device_match if len(last_device_match) < 40 else last_device_match[0:39] + "..."
            print(f"{prefix} {dev_title} {last_volume_match} {last_mute_match}{rofi_info}{mute_icon}".strip())

def list_applications():
    res = os.popen("pactl list sink-inputs")
    lines = res.read()
    app_name = ""
    app_volume = ""
    app_volume_percent = ""
    app_muted = ""
    sink_input = ""
    mute_icon = ""
    current_sink = ""

    sink_input_re = re.compile(r"Sink Input #(\d+)")
    volume_re = re.compile(r"\s*Volume: ")
    mute_re = re.compile(r"\s*Mute: ")
    app_name_re = re.compile(r'\s*application\.name = "(.*)"')
    sink_re = re.compile(r"\s*Sink: (\d+)")

    for line in lines.splitlines():
        sink_input_match = sink_input_re.match(line)
        if sink_input_match:
            if app_name and sink_input:
                rofi_info = f"\x00info\x1f{app_name}||{sink_input}"
                volume_bar = create_volume_bar(app_volume_percent)
                app_title = app_name if len(app_name) < 40 else app_name[0:39] + "..."
                sink_display = build_app_sink_display(current_sink, "")
                print(f"{app_title}{sink_display} {volume_bar} {app_muted}{rofi_info}{mute_icon}".strip())
            sink_input = sink_input_match.group(1)
            app_name = app_volume = app_volume_percent = app_muted = mute_icon = current_sink = ""
        elif volume_re.match(line):
            volumes = line.split("/")
            volume_percent_match = re.search(r"(\d+)%", volumes[1])
            if volume_percent_match:
                app_volume_percent = volume_percent_match.group(1)
        elif mute_re.match(line):
            muted = line.split("Mute: ")
            if muted[1] == "yes":
                app_muted = "(Muted)"
                mute_icon = '\x1ficon\x1f<span color="white">ﱝ</span>'
            else:
                app_muted = ""
                mute_icon = ""
        elif app_name_re.match(line):
            app_name = app_name_re.match(line).group(1)
        elif sink_re.match(line):
            current_sink = sink_re.match(line).group(1)

    if app_name and sink_input:
        rofi_info = f"\x00info\x1f{app_name}||{sink_input}"
        volume_bar = create_volume_bar(app_volume_percent)
        app_title = app_name if len(app_name) < 40 else app_name[0:39] + "..."
        sink_display = build_app_sink_display(current_sink, "")
        print(f"{app_title}{sink_display} {volume_bar} {app_muted}{rofi_info}{mute_icon}".strip())

def build_app_sink_display(current_sink, sink_display):
    res = os.popen(f"pactl list sinks | grep -A3 'Sink #{current_sink}' | grep -e 'Description' | cut -d: -f2")
    sink_desc = res.read().strip()
    if sink_desc:
        sink_display = f" → {sink_desc}"
        if len(sink_display) > 25:
            sink_display = f" → {sink_desc[:22]}..."
    return sink_display

def main():
    if dev_type == "app":
        list_applications()
    else:
        list_sinks_sources()
    
    print(f"\x00custom\x1f24\n<span></span> Open Volume Control\x00info\x1fOPEN_VOLUME_CONTROL")

if __name__ == '__main__':
    main()

