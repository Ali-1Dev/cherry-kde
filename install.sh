#!/bin/bash
theme_name=cherry
theme_namespace=com.github.nullxception
src=$(realpath "$(dirname "$0")")

install_aurorae() {
  local dest="$PREFIX/share/aurorae/themes"
  local variants=("solid" "square" "square-solid")

  mkdir -p "$dest"

  [[ -d "$dest/$theme_name" ]] && rm -rf "$dest/$theme_name"
  cp -r "$src/aurorae/$theme_name" "$dest"

  for variant in "${variants[@]}"; do
    [[ -d "$dest/${theme_name}-${variant}" ]] && rm -rf "$dest/${theme_name}-${variant}"
    cp -r "$src/aurorae/$theme_name" "$dest/${theme_name}-${variant}"
    cp -r "$src/aurorae/${theme_name}-${variant}/." "$dest/${theme_name}-${variant}"
    rm "$dest/${theme_name}-${variant}/${theme_name}rc"
  done
}

install_kvantum() {
  local dest="$PREFIX/share/Kvantum"
  local variants=("solid")

  # Destination directory
  # Special Kvantum dest for user-specific install
  [[ $EUID -ne 0 ]] && dest="$HOME/.config/Kvantum"

  mkdir -p "$dest"

  [[ -d "$dest/$theme_name" ]] && rm -rf "$dest/$theme_name"
  cp -r "$src/kvantum/$theme_name" "$dest"

  for variant in "${variants[@]}"; do
    [[ -d "$dest/${theme_name}-${variant}" ]] && rm -rf "$dest/${theme_name}-${variant}"
    cp -r "$src/kvantum/${theme_name}-${variant}" "$dest"
  done
}

install_plasma() {
  local dest="$PREFIX/share/plasma/desktoptheme"
  local variants=("solid")

  mkdir -p "$dest"

  [[ -d "$dest/$theme_name" ]] && rm -rf "$dest/$theme_name"
  cp -r "$src/plasma/desktoptheme/$theme_name" "$dest"
  cp -r "$src/color-schemes/${theme_name}.colors" "$dest/$theme_name/colors"

  for variant in "${variants[@]}"; do
    [[ -d "$dest/$theme_name" ]] && rm -rf $dest/${theme_name}-${variant}
    cp -r "$src/plasma/desktoptheme/$theme_name" "$dest/${theme_name}-${variant}"
    cp -r "$src/plasma/desktoptheme/${theme_name}-${variant}/." "$dest/${theme_name}-${variant}"

    if [[ -f "$src/color-schemes/${theme_name}-${variant}.colors" ]]; then
      cp -r "$src/color-schemes/${theme_name}-${variant}.colors" "$dest/$theme_name/colors"
    fi
  done
}

install_global() {
  local dest="$PREFIX/share/plasma/look-and-feel"
  mkdir -p "$dest"

  [[ -d "$dest/${theme_namespace}.${theme_name}" ]] && rm -rf "$dest/${theme_namespace}.$theme_name"
  cp -r "$src/plasma/look-and-feel/${theme_namespace}.$theme_name" "$dest"
}

install_colors() {
  local konsole_dest="$PREFIX/share/konsole"
  local scheme_dest="$PREFIX/share/color-schemes"

  mkdir -p "$konsole_dest"
  mkdir -p "$scheme_dest"

  cp -r "$src/color-schemes/${theme_name}.colors" "$scheme_dest"
  cp -r "$src/konsole/${theme_name}.colorscheme" "$konsole_dest"
}

install_wallpaper() {
  local dest="$PREFIX/share/wallpapers"
  mkdir -p "$dest"

  [[ -d "$dest/$theme_name" ]] && rm -rf "$dest/$theme_name"
  cp -r "$src/wallpaper/$theme_name" "$dest"
}

main() {
  if [[ -z "$PREFIX" && $EUID -ne 0 ]]; then
    PREFIX="$HOME/.local"
  elif [[ -z "$PREFIX" ]]; then
    PREFIX=/usr
  fi

  echo "Installing ${theme_name} to $PREFIX"
  install_aurorae
  install_colors
  install_global
  install_kvantum
  install_plasma
  install_wallpaper

  if [[ "$clear_cache" == "true" ]]; then
    echo "Clearing KDE caches"
    find ~/.cache -type f -iname '*.kcache' -delete >/dev/null 2>&1
    find ~/.cache -type f -iname '*sma-svgel*' -delete >/dev/null 2>&1
  fi
}

clear_cache=true

parsed=$(getopt --options=p:,c: --longoptions=prefix:,clear-cache: --name "$0" -- "$@")
if [ $? -ne 0 ]; then
  echo 'Invalid argument, exiting.' >&2
  exit 1
fi

eval set -- "$parsed"
unset parsed
while true; do
  case "$1" in
  "-p" | "--prefix")
    PREFIX="$2"
    shift 2
    ;;
  "-c" | "--clear-cache")
    clear_cache="$2"
    shift 2
    ;;
  "--")
    shift
    break
    ;;
  *) ;;

  esac
done

main "$@"
