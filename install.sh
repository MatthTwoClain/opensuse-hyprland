#!/bin/bash

# 1. Déclaration des variabes

# Attribue des couleurs pour les messages affiché
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Set the name of the log file to include the current date and time
LOG="main_install-$(date +%d-%H%M%S).log"

# Initialise les variables pour les réponses utilisateurs
bluetooth=""
dots=""
gtk_themes=""
nvidia=""
rog=""
sddm=""
thunar=""
xdph=""
zsh=""

# Definie le dossier où les scripts sont localisé
script_directory=install-scripts


# 2. Déclaration des fonctions

# Fonction pour coloriser le prompts
colorize_prompt() {
    local color="$1"
    local message="$2"
    echo -n "${color}${message}$(tput sgr0)"
}

# Fonction pour demander oui/non et enregistrer les réponses dans une variable (accepter Oo ou Nn)
demande_oui_non() {
    local response
    while true; do
        read -p "$(colorize_prompt "$CAT" "$1 (Y/N): ")" -r reponce
        case "$response" in
            [Yy]* ) eval "$2='Y'"; return 0;;
            [Nn]* ) eval "$2='N'"; return 1;;
            * ) echo "Repondez avec Y/y or N/n.";;
        esac
    done
}

# Fonction pour demander une question custom avec des options spécifique et enregistrée la responce dans une variable
demande_custom_option() {
    local prompt="$1"
    local valid_options="$2"
    local response_var="$3"

    while true; do
        read -p "$(colorize_prompt "$CAT"  "$prompt ($valid_options): ")" choix
        if [[ " $valid_options " == *" $choice "* ]]; then
            eval "$response_var='$choice'"
            return 0
        else
            echo "Choisissez une des options: $valid_options"
        fi
    done
}

# Fonction pour executer un script si il existe et le rendre executable
execute_script() {
    local script="$1"
    local script_path="$script_directory/$script"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            "$script_path"
        else
            echo "Echec de rendre le script '$script' executable."
        fi
    else
        echo "Script '$script' non trouvé dans '$script_directory'."
    fi
}


# 3. Vérification initiales

# Check si en root. Si root, le script s'arrête
if [[ $EUID -eq 0 ]]; then
    echo "Le script ne doit pas être executé avec root! Sorti......."
    exit 1
fi

clear


# 4. Corps principales du script

# Message bienvenue
echo "$(tput setaf 6)Bienvenue sur OpenSUSE (Tumbleweed)- Hyprland Install Script!$(tput sgr0)"
echo

# Creer un Dossier pour les logs d'Installation
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi


# Collecter les réponse utilisateur à toute les questions
printf "\n"
demande_oui_non "-Est ce que tu as un gpu nvidia gpu dans ton system?" nvidia
printf "\n"
demande_oui_non "-Installer les themes GTK (requit pour Dark/Light fonction)?" gtk_themes
printf "\n"
demande_oui_non "-Veux-tu configurer le Bluetooth?" bluetooth
printf "\n"
demande_oui_non "-Veux tu installer Thunar file manager?" thunar
printf "\n"
demande_oui_non "-Installer & configurer SDDM log-in Manager plus (OPTIONAL) SDDM Theme?" sddm
printf "\n"
demande_oui_non "-Installer XDG-DESKTOP-PORTAL-HYPRLAND? (for proper Screen Share ie OBS)" xdph
printf "\n"
demande_oui_non "-Installer zsh & oh-my-zsh plus (OPTIONAL) pokemon-colorscripts?" zsh
printf "\n"
demande_oui_non "-Installation sur un Asus ROG?" rog
printf "\n"
demande_oui_non "-Veux tu télécharger et installer pre-configured Hyprland dotfiles?" dots
printf "\n"

# Assure que tout ce qui est dans le dossier script est rendu executable
chmod +x install-scripts/*

# Installation hyprland packages
execute_script "00-packman.sh"
execute_script "01-dependencies.sh"
execute_script "02-hypr-pkgs.sh"
execute_script "fonts.sh"
execute_script "nwg-look.sh"
execute_script "swaylock-effects.sh"
execute_script "cliphist.sh"
execute_script "wlogout.sh"
execute_script "force-install.sh"

if [ "$nvidia" == "O" ]; then
    execute_script "nvidia.sh"
else
    execute_script "hyprland.sh"
fi

if [ "$gtk_themes" == "O" ]; then
    execute_script "gtk_themes.sh"
fi

if [ "$bluetooth" == "O" ]; then
    execute_script "bluetooth.sh"
fi

if [ "$thunar" == "O" ]; then
    execute_script "thunar.sh"
fi

if [ "$sddm" == "O" ]; then
    execute_script "sddm.sh"
fi

if [ "$xdph" == "O" ]; then
    execute_script "xdph.sh"
fi

if [ "$zsh" == "O" ]; then
    execute_script "zsh.sh"
fi

if [ "$rog" == "O" ]; then
    execute_script "rog.sh"
fi

execute_script "InputGroup.sh"

if [ "$dots" == "O" ]; then
    execute_script "dotfiles.sh"
fi


clear

printf "\n${OK} Youpi! Installation Complete.\n"
printf "\n"
sleep 2
printf "\n${NOTE} Tu peux démarrer Hyprland en tapant Hyprland (Si SDDM n'est pas installé) (note la Majuscule H!).\n"
printf "\n"
printf "\n${NOTE} Il est fortement recommandé de redémarrer le systeme.\n\n"

read -rp "${CAT} Veux tu redemarrer maintenant ? (o/n): " HYP

if [[ "$HYP" =~ ^[Oo]$ ]]; then
    if [[ "$nvidia" == "O" ]]; then
        echo "${NOTE} NVIDIA GPU detected. Rebooting the system..."
        systemctl reboot
    else
        systemctl reboot
    fi    
fi
