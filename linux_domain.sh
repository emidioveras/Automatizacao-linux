#!/bin/bash
set -e
## Definindo Variaveis

#URLS

URL_VNC_SERVER="http://10.110.170.23/programas/Formatacao_Linux/VNC-Server-6.11.0-Linux-x64.deb"
URL_GOOGLE="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

#Cores
VERMELHO='\e[1;91m'
AMARELO='\e[1;93m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'

# ------------------------------- TESTES DE CONEXAO ----------------------------------------- #
# Maquina tem internet ?
teste_conexao(){
	if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
		echo -e "${VERMELHO}[ERROR] - Seu computador nao tem conexao de internet. Verifique a rede.${SEM_COR}"
		exit 1
	else
		echo -e "${VERDE}[INFO] - Conexao com a internet funcionando normalmente.${SEM_COR}"
	fi
}
#----------------------------------------------------------------------------------------------#
#Instalando pacotes Flatpacks
install_flatpacks(){
    echo -e "${AMARELO}[INFO] - Instalando pacotes Flatpak${SEM_COR}"
    flatpak install flathub com.anydesk.Anydesk -y
}
#----------------------------------------------------------------------------------------------#
# Atualizacao de repositorios e Sistema
apt_update(){
    sudo apt update -y ; sudo apt upgrade -y
}
#----------------------------------------------------------------------------------------------#
# Removendo travas APT
travas_apt(){
    sudo rm /var/lib//dpkg/lock-frontend
    sudo rm /var/cache/apt/archives/lock
}
#----------------------------------------------------------------------------------------------#
## Programas apt instalar 
PROGRAMAS_PARA_INSTALAR=(
    remmina
    net-tools
)
#----------------------------------------------------------------------------------------------#
DIRETORIO_DOWNLOADS=/$HOME/Downloads

# Instalando programas .DEB

install_deb(){
    echo -e "${AMARELO}[INFO] - Criando pasta e baixando Arquivos...${SEM_COR}"
    mkdir -p $DIRETORIO_DOWNLOADS

    wget -c "$URL_VNC_SERVER" -P "$DIRETORIO_DOWNLOADS"
    wget -c "$URL_GOOGLE" -P "$DIRETORIO_DOWNLOADS"
    echo -e "${VERDE}[INFO] - Arquivos Baixados...${SEM_COR}"

    echo -e "${AMARELO}[INFO] - Instalando os programas${SEM_COR}"
    sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

    echo -e "${VERDE}[INFO] - Programas instalados.${SEM_COR}"
    sudo apt --fix-broken install

    #Instalando programas APT
    for nome_do_programa in "${PROGRAMAS_PARA_INSTALAR[@]}"; do
    if dpkg -l | grep -q $nome_do_programa; then
    echo "[INSTALADO] - $nome_do_programa"
    else
    sudo apt install "$nome_do_programa" -y
    fi
done
}
#----------------------------------------------------------------------------------------------#
#Lockando o DNS e instalando programa para entrada no DOMINIO 

DOMINIO_LINUX(){
    echo -e "${AMARELO}[INFO] - Apagando arquivos e criando link simbolico${SEM_COR}"
    sudo rm /etc/resolv.conf
    sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
    sudo nano /etc/systemd/resolved.conf
    echo -e "${AMARELO}[INFO] - Reiniciando os servicos de internet${SEM_COR}"
    sudo systemctl restart systemd-resolved
    sleep 5
    echo -e "${AMARELO}[INFO] - baixando e instalando Cid${SEM_COR}"
    sudo add-apt-repository ppa:emoraes25/cid -y
    sudo apt update
    sudo apt install cid cid-gtk -y
}
#----------------------------------------------------------------------------------------------#
# Atualizacao e Limpeza 
system_clean(){
    apt update -y
    flatpak update -y
    sudo apt autoclean -y
}
#----------------------------------------------------------------------------------------------#
# EXECUCAO
travas_apt
teste_conexao
apt_update
install_deb
install_flatpacks
DOMINIO_LINUX
system_clean

echo -e "${VERDE}[INFO] - Sistema Configurado e atualizado :)${SEM_COR}"

