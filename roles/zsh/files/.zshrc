######.ZSHRC #######


# Primero habilitamos las opciones con las que queremos que inicie zsh:
source "$ZDOTDIR/.zoptions"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh//.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
#source /opt/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.config/zsh//.p10k.zsh.
#[[ ! -f ~/.config/zsh//.p10k.zsh ]] || source ~/.config/zsh//.p10k.zsh




## RUN_HELP ##

# Directorio en el que buscar ficheros de ayuda. Se tienen en cuenta diferentes didstros y versiones:
export HELPDIR="/usr/share/zsh/help $HOME/.local/share/zsh/help /etc/zsh/help ~/.config/zsh/help ~/Library/Application Support/zsh/help /usr/share/zsh/$(zsh --version | cut -d' ' -f2)/help $HELPDIR"
# Evitamos que nos de un error en caso de haber sido eliminado el alias previamente:
unalias run-help 2>/dev/null
# Cargamos la función:
autoload -Uz run-help
# A partir de ahora podremos usar help o run-help indistintamente para ver la ayuda:
alias help=run-help
# Cargamos algunos módulos de ayuda
autoload run-help-btrfs
autoload run-help-git
autoload run-help-ip
autoload run-helpopenssl
autoload run-help-p4
autoload run-help-sudo
autoload run-help-svk
autoload run-help-svn

# Escribimos el comando y pusalmos F1 para mostrar ayuda sobre ese comando, gracias a la ayuda de la función run-help:
bindkey '^[OP' run-help
###############


# Definimos contenedor para los plugins:
export ZSH_PLUGINS="/opt/zsh-plugins"

# fpath es solo para funciones:
fpath=($ZSH_PLUGINS/zsh-completions/src $fpath)

# Autoload all shell functions from all directories in $fpath (following symlinks) that have the executable bit on (the executable bit is not necessary, but gives you an easy way to stop the  autoloading of a particular shell function). $fpath should not be empty for this to work.
for func in $^fpath/*(N-.x:t); do
    autoload "$func"
done


### History ###
export HISTFILE="$ZDOTDIR/.zhistory" # Ruta del fichero de historial"
export HISTSIZE=1024 # Tamaño del fichero
export SAVEHIST=5000 # Número de comandos almacenados en el HISTFILE
###############



### BINDKEYS ###
#bindkey -e #funcionamiento tipo emacs
bindkey '^H' backward-delete-char #es necesario activar el binding de ^H en la aplicación de terminal (mobaxterm)
#bindkey '^?' backward-delete-word #teclas de control + retroceso borra la PALABRA previa. Funciona mal en ocasiones.
bindkey '^[[3~'   delete-char # borra caracter actual
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
# bindkey '^[[3;5~' kill-word. Es posible que dé problemas en algunos casos.
# Para buscar por el hisorial usando la tecla up o down (escribimos por ejemplo "cd /etc/" y pusamos arriba o abajo. Nos mostrará solo las entradas de hisorial que comienzan por cd /etc/...):
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
#tecla arriba:
bindkey '^[[A'    up-line-or-beginning-search
#tecla abajo:
bindkey '^[[B'    down-line-or-beginning-search
# tecla av pag
bindkey '^[[6~'   up-line-or-beginning-search
# tecla re pag
bindkey '^[[5~'   down-line-or-beginning-search
bindkey '^[[Z'    undo                               # shift + tab undo last action
# ejecutar comando con sudo. Revisar el keybinding:
# run-with-sudo () { LBUFFER="sudo $LBUFFER" }
run-with-sudo() {
  LBUFFER="sudo $LBUFFER"
}



precmd () print ""
zle -N run-with-sudo
bindkey '^[^[' run-with-sudo


### Funciones
# Busca los ficheros más grandes de un directorio
function grandes () {
    du -h -x -s -- * 2> /dev/null | sort -r -h | head -20;
}

# Crear un arbol de directorios y se posiciona en el último de ellos:
function mkd() {
  [[ -n ${1} ]] || { echo "Error: Debe especificar un nombre de directorio." ; return 1 ; }

  if [ ! -d "$1" ]; then
    mkdir -p "$1" 1> /dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "\nSe ha creado el directorio $1 correctamente"
    fi
  fi

  cd "$1"
}

#Muestra el branch de git actual. Se escribe a mano ya que no existe ene l plugin git.zsh
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
#Muestra dos [] en las que se detalla el estado de los repos .git:
parse_git_dirty() {
  STATUS="$(LANGUAGE=en git status 2> /dev/null)"
  if [[ $? -ne 0 ]]; then printf ""; return; else printf ' ['; fi
  if echo "${STATUS}" | grep -c "renamed:"         &> /dev/null; then printf ' >'; else printf ""; fi
  if echo "${STATUS}" | grep -c "branch is ahead:" &> /dev/null; then printf ' !'; else printf ""; fi
  if echo "${STATUS}" | grep -c "new file::"       &> /dev/null; then printf ' +'; else printf ""; fi
  if echo "${STATUS}" | grep -c "Untracked files:" &> /dev/null; then printf ' ?'; else printf ""; fi
  if echo "${STATUS}" | grep -c "modified:"        &> /dev/null; then printf ' *'; else printf ""; fi
  if echo "${STATUS}" | grep -c "deleted:"         &> /dev/null; then printf ' -'; else printf ""; fi
  printf ' ]'
}

#Vigilante:
#muestra si alguien inicia sesión. Si alguien incia, se mostrará después de ejecutar cualquier comando, y no de forma automática:
watch=(notme)         # watch for everybody but me
LOGCHECK=30           # check every 60 sec for login/logout activity
WATCHFMT="%n %a %l desde %m el $(date +"%A %d de %B de %Y a las %T")"


# Auto logout (1 hora)
# Cuando se bloquea una terminal virtual, no es capaz de aceptar la contraseña. Revisar opciones para vlock antes de volver a habilitarlo.
#TMOUT=3600
#TRAPALRM () {
#  clear
#  echo Inactivity timeout on $TTY
#  echo
#  vlock -c
#  echo
#  echo Terminal unlocked. [ Press Enter ]
#}



# Cada vez que se intenta ejecutar un comando que no está instalado, realiza una búsqueda con "pacman -F" y devuelve el paquete que contiene ese comando
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=(
        ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"}
    )
    if (( ${#entries[@]} ))
    then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}"
        do
            # (repo package version file)
            local fields=(
                ${(0)entry}
            )
            if [[ "$pkg" != "${fields[2]}" ]]
            then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}


#este código define un alias para abrir archivos HTML y HTM usando un navegador web. Cuando intenta abrir un archivo de este tipo, se activa la función pick-web-browseralias, que presumiblemente se encarga de seleccionar y abrir el navegador adecuado:
autoload -U pick-web-browser
alias -s {html,htm}=pick-web-browser


# Sistema de autocompletado de zsh:
autoload -Uz compinit
# (-d) en caso de que lo queramos cargar, eliminando previamente la caché existente en el fichero:
compinit # -d ~/.config/zsh/.zcache

# Load colors so we can access $fg and more.
autoload -U colors
colors


# Hacer que los nuevos ejecutables sean añadidos al completion sin tener que reiniciar la terminal:
zstyle ':completion:*' rehash true
#muestra un menu al utilizar el automcpletado con tab (parece no funcionar bien):
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true # permite mostrar "../" al usar tab

# }}}
# {{{ Fancy menu selection when there's ambiguity
#Para pruebas:
zstyle ':completion:*' menu yes select interactive
zstyle ':completion:*' menu yes=long select=long interactive
zstyle ':completion:*' menu yes=10 select=10 interactive
#colores en completion
zstyle ':completion:*' list-colors "$LS_COLORS"
#When you match files using the completion, they will be ordered by date of modification
zstyle ':completion:*' file-sort modification
# cache de completion
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.config/zsh/.zcache
# fichero particular para los completados de zsh:
#zstyle :compinstall filename '~/.config/zsh/.zshrc'
#No consigo que funcione, o no sé usarlo
#zstyle :completion:ls color red
#zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
#zstyle ':completion:*' completer _complete _match _approximate
#zstyle ':completion:*:match:*' original only
#zstyle ':completion:*:approximate:*' max-errors 1 numeric
#Ignore completion functions for commands you don’t have:
#zstyle ':completion:*:functions' ignored-patterns '_*'
#Completing process IDs with menu selection:
#zstyle ':completion:*:*:kill:*' menu yes select
#zstyle ':completion:*:kill:*'   force-list always


#añadimos el plugin de git para poder usar sus funciones (da errores.no encuentra compdef... y es muy lento con el promt):
#source ~/.config/zsh/plugins/git/git.plugin.zsh
#añadimos el plugin de autosugestions:
source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
#syntax-highligfhting. Siempre debe ir al final del zshrc:
source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
#Imagine that you’re in the folder ~/a/b/c/d. You can jump directly to a with the command bd a. https://github.com/Tarrasch/zsh-bd
source "$ZSH_PLUGINS/bd.zsh"
# Para usar junto con fzf:
source "$ZSH_PLUGINS/fzf/fzf.plugin.zsh"
source "/usr/share/fzf/key-bindings.zsh"


#PROMPTS:

#Dependiendo del tipo de usuario que seam mostrará $ o #:
if [[ $EUID == 0 ]]; then
PROMPT="%{$fg[blue]%} %{$fg[blue]%}%n%{$fg[red]%}@%{$fg[blue]%}%m# %F{015}%~ %F{006}%(?..%{$fg[red]%})%b "
else
PROMPT="%{$fg[blue]%} %{$fg[blue]%}%n%{$fg[red]%}@%{$fg[blue]%}%m$ %F{015}%~ %F{006}%(?..%{$fg[red]%})%b "
fi
#hacemos uso de algunas funciones que nos da git.zsh y las mostramos en el prompt derecho,además de la hora:
RPROMPT="%B%F{006}$(parse_git_branch)%F{003}$(parse_git_dirty) %B%F{015}%T %D{%A} %D{%d}/%D{%m}/%D{%Y}"
#dejamos un espacio en blanco entre cada comando:
precmd () (`print ""`)

# Más SOURCES:
source "$ZDOTDIR/.zprofile"
source "$ZDOTDIR/.zaliases"
