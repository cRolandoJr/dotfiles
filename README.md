# dotfiles
Configuración personal de **Hyprland** sobre **NixOS**, gestionada con [home-manager `mkOutOfStoreSymlink`](https://nix-community.github.io/home-manager/options.xhtml#opt-home.file._name_.source).

> **Cómo funciona el enlace:** home-manager crea symlinks que apuntan a archivos *fuera* del Nix store (directamente a `~/projects/dotfiles/…`). Esto significa que podés editar cualquier archivo acá y el cambio aplica **en vivo**, sin hacer `nixos-rebuild`. Solo se necesita rebuild cuando cambiás qué archivos se enlazan, no su contenido.

El repositorio del sistema NixOS (flake, módulos, paquetes) vive por separado en [`~/projects/nix-config/`](https://github.com/cRolandoJr/nix-config). Este repo contiene solo las configuraciones de las apps; aquel repo es el que los *enlaza* al sistema.

---

## 🧩 Componentes

| Módulo | Herramienta | Descripción |
|---|---|---|
| `hypr` | [Hyprland](https://hyprland.org/) 0.55+ | Compositor Wayland — ventanas, animaciones, atajos, rules |
| `waybar` | [Waybar](https://github.com/Alexays/Waybar) | Barra con chip NixOS (gen + dirty-status), workspaces, reloj, red, batería |
| `eww` | [eww](https://elkowar.github.io/eww/) | Hub dashboard (clima, calendario, red, BT) · popup con `SUPER+grave` |
| `foot` | [foot](https://codeberg.org/dnkl/foot) | Terminal Wayland-nativa (migrada desde kitty 2026-07-20) |
| `rofi` | [Rofi](https://github.com/davatorium/rofi) | Launcher + menús de WiFi, wallpapers, clipboard, keybinds |
| `mako` | [Mako](https://github.com/emersion/mako) | Daemon de notificaciones Wayland (DND vía `SUPER+N`) |
| `starship` | [Starship](https://starship.rs/) | Prompt multiplataforma |
| `fastfetch` | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) | Info del sistema al abrir terminal |
| `nvim` | [Neovim](https://neovim.io/) | Editor (lazy.nvim, LSP, treesitter) |
| `yazi` | [Yazi](https://yazi-rs.github.io/) | File manager en terminal (dentro de foot flotante) |
| `khal` | [khal](https://lostpackets.de/khal/) | Calendario CLI integrado al hub eww |
| `qt6ct` | [qt6ct](https://github.com/trialuser02/qt6ct) | Tema Qt6 con paleta Deep Ocean |

---

## 🎨 Identidad visual — Deep Ocean

Paleta unificada en todos los componentes:

| Rol | Color | Hex |
|---|---|---|
| Acento principal | Cyan | `#00b4d8` |
| Acento secundario | Azul NixOS | `#3b82f6` |
| Fondo surface | Navy oscuro | `#0f1623` |
| Texto | Lavanda claro | `#cdd6f4` |
| Destructivo | Rojo suave | `#f87171` |

---

## ✨ Features destacadas

- **Hub eww** (`SUPER+grave`): popup central con clima (Open-Meteo), calendario, estado de red/BT y controles rápidos.
- **Chip NixOS en waybar**: muestra generación actual + símbolo NixOS coloreado (azul = flake limpio, rojo = dirty con cambios sin commitear).
- **Keybinds viewer** (`SUPER+K`): cheatsheet fuzzy de todos los binds extraído en vivo de `binds.conf`, agrupado por sección.
- **Wallhaven fetch** (`SUPER+SHIFT+W`): browser de wallpapers con preview grid (thumbnails cacheados), búsqueda por término y descarga directa.
- **Wallselect local** (`SUPER+W`): selector de wallpapers en `~/Wallpapers/` con thumbnails, borrado con `Alt+D`.
- **Hyprlock con viñeta** (`SUPER+L`): lockscreen con shader GLSL de viñeta Deep Ocean activado en el compositor (Hyprland `decoration:screen_shader`) antes de lanzar hyprlock.
- **Night light manual** (`SUPER+CTRL+N`): toggle 6500K ↔ 3500K vía hyprsunset IPC (schedule deshabilitado por bug en v0.3.3).
- **Spotify en special workspace** (`SUPER+M`): toggle que detecta la ventana por clase Hyprland (no pgrep) porque NixOS empaqueta Spotify como `.spotify-wrapped`.
- **Layout notificación**: daemon que escucha el socket de Hyprland y notifica cambios de distribución de teclado (no depende del bind, captura cualquier cambio).

---

## ⌨️ Atajos de teclado (`SUPER` = tecla modificadora)

| Atajo | Acción |
|---|---|
| `SUPER + Return` / `+ SHIFT` | Terminal foot · flotante |
| `SUPER + Space` | Launcher (Rofi) |
| `SUPER + B / M / T` | Firefox · Spotify (special ws) · Telegram |
| `SUPER + E` / `+ SHIFT` | Yazi (foot flotante) · Thunar |
| `SUPER + W` / `+ SHIFT` | Wallselect local · Wallhaven fetch |
| `SUPER + C` | Clipboard history (cliphist + rofi) |
| `SUPER + L` | Bloquear pantalla (hyprlock + viñeta) |
| `SUPER + A` | WiFi manager (rofi) |
| `SUPER + K` | Keybinds viewer (cheatsheet fuzzy) |
| `SUPER + grave` | Hub dashboard eww (toggle) |
| `SUPER + N` / `+ SHIFT` | DND toggle mako · Dismiss all |
| `SUPER + CTRL + N` | Night light toggle (hyprsunset) |
| `SUPER + CTRL + P` | Ciclar power profile (performance / balanced / saver) |
| `SUPER + SHIFT + R` | Reload waybar (config + style) |
| `SUPER + Q / F / V` | Cerrar · Fullscreen · Flotante toggle |
| `SUPER + D` | Float + resize 1450×800 + centrar |
| `SUPER + P` | Pseudo-tiling |
| `SUPER + R` | Modo resize (flechas, `Esc` para salir) |
| `SUPER + G` | Modo mover flotante (flechas, `SHIFT+flecha` paso grande) |
| `SUPER + J` | Toggle split de layout |
| `SUPER + SHIFT + M` | Salir de Hyprland |
| `SUPER + 1–0` / `+ SHIFT` | Cambiar workspace · mover ventana |
| `SUPER + S` / `+ SHIFT` | Toggle scratchpad · enviar al scratchpad |
| `SUPER + ←↑→↓` | Mover foco |
| `SUPER + SHIFT + ←↑→↓` | Mover ventana (swap) |
| `SUPER + Scroll` | Ciclar workspaces |
| `SUPER + click izq/der` | Mover · redimensionar ventana |
| `Print` | Captura completa → portapapeles |
| `SUPER + SHIFT + C` | Recorte de región → portapapeles |
| `SUPER + CTRL + C` | Recorte → satty (anotar) → guardar + portapapeles |
| Teclas multimedia | Volumen (swayosd) · Brillo · Play/Pausa/Siguiente/Anterior |
| `Alt + Shift` | Cambiar layout de teclado |

---

## 📁 Estructura

```
dotfiles/
├── hypr/             # hyprland.conf + configs/{autostart,binds,environments,monitors,rules,settings}.conf
│                     # scripts/ (lock, spotify-toggle, wallhaven-fetch, keybinds-viewer, …)
│                     # shaders/ (lock-vignette.glsl)
├── waybar/           # config.jsonc + style.css (Deep Ocean)
├── eww/              # eww.yuck + eww.scss + scripts/ (weather, net-status, …)
├── foot/             # foot.ini (tema Deep Ocean)
├── kitty/            # histórico (sin symlink desde 2026-07-20; borrar si foot convence)
├── rofi/             # config.rasi + temas por menú (wallselect, wifi, cliphist, keybinds)
├── mako/             # config
├── starship/         # starship.toml
├── fastfetch/        # config.jsonc + logos/
├── nvim/             # init.lua + lua/{config,plugins}/
├── yazi/             # yazi.toml (opener PDF → firefox)
├── khal/             # config (calendarios: personal + pedco)
└── qt6ct/            # qt6ct.conf + colors/deep-ocean.conf
```

Cada directorio refleja la estructura de `~/.config/`: `hypr/` contiene `.config/hypr/`, etc.

---

## 🔧 Instalación / Cómo usar

Este repo **no usa GNU Stow** ni se instala con un script. Los symlinks los gestiona [home-manager](https://nix-community.github.io/home-manager/) desde el repo NixOS.

**Flujo típico para una máquina nueva:**

1. Clonar este repo en `~/projects/dotfiles/`.
2. Clonar el flake NixOS en `~/projects/nix-config/`.
3. En `nix-config`, el módulo home-manager usa `mkOutOfStoreSymlink` apuntando a las rutas de este repo:
   ```nix
   home.file.".config/hypr".source =
     config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/dotfiles/hypr/.config/hypr";
   ```
4. Aplicar con `sudo nixos-rebuild switch --flake ~/projects/nix-config#<host>`.

Después de eso, editar directamente en `~/projects/dotfiles/` aplica en vivo. No se necesita rebuild para cambios de config; sí se necesita para agregar/quitar symlinks.

> Si estás en Arch u otra distro, podés usar GNU Stow como alternativa (`stow hypr`, `stow waybar`, etc.) pero el setup está pensado y testeado para NixOS.
