#!/usr/bin/env python3
import glob
import json
import sys
import time

ICONS = ["", "", "", "", ""]


def find_battery():
    batteries = sorted(glob.glob("/sys/class/power_supply/BAT*"))
    return batteries[0] if batteries else None


def read(path):
    with open(path) as f:
        return f.read().strip()


def icon_for(capacity):
    idx = min(capacity * len(ICONS) // 100, len(ICONS) - 1)
    return ICONS[idx]


def build_state(bat):
    capacity = int(read(f"{bat}/capacity"))
    status = read(f"{bat}/status")

    # No carregador e cheia: nada para avisar, módulo fica oculto
    if status == "Full" and capacity >= 100:
        return None

    icon = icon_for(capacity)
    text = f"<span size='135%' font_family='FiraCode Nerd Font Mono'>{icon}</span> {capacity}%"
    return {
        "text": text,
        "tooltip": f"{status} - {capacity}%",
        "class": status.lower().replace(" ", "-"),
    }


def hide():
    sys.stdout.write("\n")
    sys.stdout.flush()


def write_state(state):
    sys.stdout.write(json.dumps(state) + "\n")
    sys.stdout.flush()


bat = find_battery()
if not bat:
    hide()
    sys.exit(0)

last_state = "__unset__"
while True:
    state = build_state(bat)
    if state != last_state:
        write_state(state) if state is not None else hide()
        last_state = state
    time.sleep(10)
