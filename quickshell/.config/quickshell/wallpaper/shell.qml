// Superficie que pinta el wallpaper: capa Background con exclusionMode Ignore,
// para quedar debajo de waybar sin reservar espacio ni reacomodar ventanas.
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
