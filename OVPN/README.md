# Perfis OpenVPN

Coloque aqui dentro todos os arquivos `.ovpn` que devem ser importados pelo
`post-install.sh` durante a seção "Perfis OpenVPN".

O script lê todo `*.ovpn` presente nesta pasta e importa cada um como uma
conexão do NetworkManager. Se um arquivo declarar `dhcp-option DNS` e/ou
`dhcp-option DOMAIN`, esses valores são aplicados automaticamente via `nmcli`.

Os arquivos `.ovpn` (e certificados/chaves que venham com eles) não devem ser
versionados — só este README fica no repositório (veja `.gitignore`).
