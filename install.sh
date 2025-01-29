#!/bin/bash
#
#
# Autor Emidio Veras
#
# Como Usar?
# 	$ ./install.sh
#
set -e

# NOMEANDO VARIAVEIS#


#URLS de PROGRAMAS EXTERNOS
URL_VNC_VIEWER="https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-7.13.1-Linux-x64.deb"
URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_DBEAVER="https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"

## Diretorio
DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"

#Cores
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'

#Funcoes
apt_update(){
	sudo apt update && sudo apt upgrade -y
}

# ------------------------------- TESTES DE CONEXAO ----------------------------------------- #
# Maquina tem internet ?
teste_conexao(){
	if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
		echo -e "${VERMELHO}[ERROR] - Seu computador não tem conexão de internet. Verifique a rede.${SEM_COR}"
		exit 1
	else
		echo -e "${VERDE}[INFO] - Conexão com a internet funcionando normalmente.${SEM_COR}"
	fi
}
# -------------------------------------------------------------------------------------------#
#Adquirindo horario correto
ntp(){
	echo -e "${VERDE}[INFO] - Atualizando horario do sistema${SEM_COR}"
	timedatectl set-timezone America/Fortaleza
	echo -e "${VERDE}[INFO] - Horario Atualizado"
}

#Removendo Travas eventuais do apt##
travas_apt(){
	sudo rm /var/lib//dpkg/lock-frontend
	sudo rm /var/cache/apt/archives/lock
}
# -------------------------------------------------------------------------------------------#

##Deb Softwares para instalar
PROGRAMAS_PARA_INSTALAR=(
	net-tools
	remmina
)
# -------------------------------------------------------------------------------------------#

#Baixando e instalando programas .DEB

install_debs(){
	echo -e "${VERDE}[INFO] - Baixando pacotes .deb${SEM_COR}"
	mkdir -p "$DIRETORIO_DOWNLOADS"
	wget -c "$URL_GOOGLE_CHROME" -P "$DIRETORIO_DOWNLOADS"
	wget -c "$URL_VNC_VIEWER" -P "$DIRETORIO_DOWNLOADS"
	wget -c "$URL_DBEAVER" -P "$DIRETORIO_DOWNLOADS"

	##Instalando pacotes .deb Baixados
	echo -e "${VERDE}[INFO] - Instalandos pacotes .deb baixados${SEM_COR}"
	sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

	##Instalar programas do APT
	echo -e "${VERDE}[INFO] - Instalando pacotes apt baixados${SEM_COR}"

	for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
	if dpkg -l | grep -q $nome_do_programa; then #Só instala se já tiver instalado
	echo "[INSTALADO] - $nome_do_programa"
    else
	sudo apt install "$nome_do_programa" -y
	fi
done
}

# -------------------------------------------------------------------------------------------#
##Instalando pacotes Flatpak

install_flatpacks(){
	echo -e "${VERDE}[INFO] - Instalando Pacotes Flatpak${SEM_COR}"

	flatpak install flathub com.spotify.Client -y
	flatpak install flathub com.anydesk.Anydesk -y
	flatpak install flathub com.visualstudio.code -y
}

# -------------------------------------------------------------------------------------------#
#Pos Instalacao Atualizacao e limpeza

system_clean(){
	apt_update -y
	flatpak update -y
	sudo apt autoclean -y
}
#-------------------------------EXECUCAO------------------------------------------------------#
travas_apt
teste_conexao
apt_update
install_debs
install_flatpacks
apt_update
system_clean

## Finalizacao

echo -e "${VERDE}[INFO] - Deu bom!${SEM_COR}"

