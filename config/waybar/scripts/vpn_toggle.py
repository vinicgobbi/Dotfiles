#!/usr/bin/env python3
import subprocess
import sys
import json
import signal
import argparse
import shutil

vpn_name = "FAESA"

def nmcli_available():
    return shutil.which("nmcli") is not None

def vpn_configured():
    """Retorna True se existir um perfil de conexão com esse nome (ativo ou não)"""
    result = subprocess.run(
        ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"],
        capture_output=True, text=True
    )
    for line in result.stdout.strip().splitlines():
        name, type_ = line.split(":", 1)
        if name == vpn_name and type_ == "vpn":
            return True
    return False

def get_vpn_active():
    """Retorna True se a VPN especificada estiver ativa"""
    result = subprocess.run(
        ["nmcli", "-t", "-f", "NAME,TYPE,STATE", "connection", "show", "--active"],
        capture_output=True, text=True
    )
    for line in result.stdout.strip().splitlines():
        name, type_, *_ = line.split(":")
        if name == vpn_name and type_ == "vpn":
            return True
    return False

def notify(state):
    """Dispara notificação quando VPN conecta/desconecta"""
    if state:
        subprocess.run(["notify-send", "VPN", f"{vpn_name} conectada", "-u", "normal"])
    else:
        subprocess.run(["notify-send", "VPN", f"{vpn_name} desconectada", "-u", "normal"])

def write_state(active):
    output = {
        'text': vpn_name,
        'class': 'active' if active else 'inactive',
        'alt': 'active' if active else 'inactive'
    }
    sys.stdout.write(json.dumps(output) + '\n')
    sys.stdout.flush()

def hide():
    """Linha vazia = waybar oculta o módulo"""
    sys.stdout.write('\n')
    sys.stdout.flush()

def toggle_vpn():
    if not vpn_configured():
        return
    if get_vpn_active():
        subprocess.run(["nmcli", "connection", "down", vpn_name])
    else:
        subprocess.run(["nmcli", "connection", "up", vpn_name])

signal.signal(signal.SIGINT, lambda s,f: sys.exit(0))
signal.signal(signal.SIGTERM, lambda s,f: sys.exit(0))

parser = argparse.ArgumentParser()
parser.add_argument("--toggle", action="store_true", help="Toggle VPN on click")
args = parser.parse_args()

# Sem NetworkManager instalado: não tem o que mostrar, módulo fica oculto
if not nmcli_available():
    if args.toggle:
        sys.exit(0)
    hide()
    sys.exit(0)

if args.toggle:
    toggle_vpn()
    sys.exit(0)

# Perfil VPN não cadastrado nesta máquina: módulo fica oculto
if not vpn_configured():
    hide()
    sys.exit(0)

# Loop contínuo de monitoramento
proc = subprocess.Popen(["nmcli", "monitor"], stdout=subprocess.PIPE, text=True)

# Estado inicial real
last_state = get_vpn_active()
write_state(last_state)

for line in proc.stdout:
    line = line.strip()
    if not vpn_configured():
        # perfil removido em tempo real: some da barra
        hide()
        last_state = None
        continue
    current_state = get_vpn_active()
    if current_state != last_state:
        write_state(current_state)
        notify(current_state)   # dispara notificação
        last_state = current_state
