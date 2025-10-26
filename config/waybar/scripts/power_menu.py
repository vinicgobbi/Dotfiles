#!/usr/bin/env python3
import subprocess
import sys
import json

# Lista de opções do menu, na ordem desejada
MENU_OPTIONS = [
    ("Desligar", "🔴 Desligar"),
    ("Reiniciar", "🔄 Reiniciar"),
    ("Suspender", "🌙 Suspender"),
    ("Hibernar", "💤 Hibernar"),
    ("Cancelar", "❌ Cancelar")
]

def show_menu():
    # Prepara as opções para fuzzel
    options_for_fuzzel = [text for _, text in MENU_OPTIONS]

    # Executa o fuzzel
    proc = subprocess.run(
        ["fuzzel", "--dmenu", "--prompt", "Energia:"],
        input="\n".join(options_for_fuzzel),
        text=True,
        capture_output=True
    )
    choice = proc.stdout.strip()

    # Verifica a escolha
    for action, text in MENU_OPTIONS:
        if action in choice:
            if action == "Desligar":
                subprocess.run(["systemctl", "poweroff"])
            elif action == "Reiniciar":
                subprocess.run(["systemctl", "reboot"])
            elif action == "Suspender":
                subprocess.run(["systemctl", "suspend"])
            elif action == "Hibernar":
                subprocess.run(["systemctl", "hibernate"])
            # Cancelar ou qualquer outro não faz nada
            break

def main():
    if "--show-menu" in sys.argv:
        show_menu()
    else:
        # Retorna o ícone do plug elétrico para o Waybar
        print(json.dumps({"icon": "🔌"}))

if __name__ == "__main__":
    main()
