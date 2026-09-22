// SPIKE DESCARTABLE — sólo la superficie de wallpaper de Ryoku, sin su shell.
// Capa Background + exclusionMode Ignore: queda DEBAJO de waybar y no reserva
// espacio, así que no reacomoda ventanas. Estructura copiada de shell.qml:154
// (Variants -> Scope -> Wallpaper + ventana), que es el patrón probado del repo.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "modules/wallpaper" as WallpaperMod

ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen
            required property var modelData

            WallpaperMod.Wallpaper {
                id: wp
                screen: perScreen.modelData
            }

            PanelWindow {
                screen: perScreen.modelData
                WlrLayershell.layer: WlrLayer.Background
                WlrLayershell.namespace: "wallonly-spike"
                exclusionMode: ExclusionMode.Ignore
                color: "black"

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WallpaperMod.Backdrop {
                    anchors.fill: parent
                    dpr: perScreen.modelData && perScreen.modelData.devicePixelRatio
                        ? perScreen.modelData.devicePixelRatio : 1
                    url: wp.wallpaperUrl
                    fit: wp.fit
                    transition: wp.transition
                    videoUrl: wp.videoUrl
                    live: wp.live
                    videoMuted: wp.videoMuted
                    videoVolume: wp.videoVolume
                }
            }
        }
    }
}
