
## Para copiar/pegar sin tener e cuenta los números de línea:
# seleccionar usando control + alt o usar :set invnumber. Tb se podría usar :set mouse=a pero es más incómodo


###@ VARIABLES GLOBALES @##

# evitar qie python cree los ficheros en ./__pycache__/ de cache para iniciar más rápido. Activar solo cuando sea necesario
# export PYTHONDONTWRITEBYTECODE=False



# Si .config no existe todavía, lo creamos:
if [[ ! -d $HOME/.config ]]; then 
  mkdir "$HOME/.config"
fi

# Ahora podemos exportar todas estas variables sin problema
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$XDG_CONFIG_HOME/datos"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/.cache"

# De ZSH:
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/.zcachecompdump-${SHORT_HOST}-${ZSH_VERSION}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Flags de compilación
export ARCHFLAGS="-arch x86_64"

# Editores para local y/o remoto:
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
  export VISUAL="nvim"

else
  export EDITOR='nvim'
  export VISUAL="nvim"

fi

# Historial bash/zsh
export HISTSIZE=10000
export SAVEHIST=10000

# Otras terms dan problemas de "echo" al usar algunos comandos. xterm-256color parece ir bien:
export TERM="xterm-256color"

# Manpages:
export MANPATH="/usr/share/man:/usr/local/man:/var/cache/man:/usr/local/share/man:$HOME/man:$MANPATH"

export MANPAGER='nvim +Man!'

# Coloreamos salida de Less:
export LESS="-R --use-color -Dd+r$Du+b"

# Locales
export LC_ALL="es_ES.UTF-8"
export LANG="es_ES.UTF-8"
export LANGUAGE="es_ES.UTF-8"
export LC_ADDRESS="es_ES.UTF-8"
export LC_COLLATE="es_ES.UTF-8"
export LC_CTYPE="es_ES.UTF-8"
export LC_IDENTIFICATION="es_ES.UTF-8"
export LC_MEASUREMENT="es_ES.UTF-8"
export LC_MESSAGES="es_ES.UTF-8"
export LC_MONETARY="es_ES.UTF-8"
export LC_NAME="es_ES.UTF-8"
export LC_NUMERIC="es_ES.UTF-8"
export LC_PAPER="es_ES.UTF-8"
export LC_TELEPHONE="es_ES.UTF-8"
export LC_TIME="es_ES.UTF-8"


# Por defecto, $PATH siempre contendrá lo mismo que haya en $path, pero se define en un array, que es más cómod y poderoso. Por eso no necesitamos definir $PATH aquí, sólo $path:
typeset -U path
path=(/opt/microsoft/msedge/ $path)

