#!/bin/sh

ACTION_TYPE=$1

# Define as variáveis baseado na ação
if [ "$ACTION_TYPE" = "shutdown" ]; then
    CMD="systemctl poweroff"
    TITLE="Desligar"
    TEXT="<big><b>Você realmente quer desligar?</b></big>\n\nA ação será executada automaticamente em 60 segundos."
    BTN_OK="Desligar agora"
elif [ "$ACTION_TYPE" = "reboot" ]; then
    CMD="systemctl reboot"
    TITLE="Reiniciar"
    TEXT="<big><b>Você realmente quer reiniciar?</b></big>\n\nA ação será executada automaticamente em 60 segundos."
    BTN_OK="Reiniciar agora"
else
    exit 1
fi

# Chamar o YAD
yad --title="$TITLE" \
    --text="$TEXT" \
    --window-icon="dialog-warning" \
    --center \
    --on-top \
    --timeout=60 \
    --timeout-indicator=bottom \
    --button="$BTN_OK:0" \
    --button="Cancelar:1"

EXIT_CODE=$?

# ==========================================================
# Lógica de Saída do YAD:
# 0 = Botão OK ("Desligar agora") foi clicado
# 1 = Botão "Cancelar" foi clicado
# 70 = O Timeout de 60 segundos foi atingido
# 252 = A janela foi fechada (pelo 'X' ou ESC)
#
# Nós queremos executar a ação se o usuário clicar OK (0)
# OU se o tempo estourar (70).
# ==========================================================

if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 70 ]; then
    $CMD
fi

# Se o código for 1 ou 252 (Cancelar/Fechar), o script
# simplesmente termina e nada acontece.