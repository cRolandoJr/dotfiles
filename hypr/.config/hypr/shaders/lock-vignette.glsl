#version 320 es

/*
  lock-vignette.glsl — Deep Ocean lockscreen vignette
  Para usar con: hyprctl keyword decoration:screen_shader ~/.config/hypr/shaders/lock-vignette.glsl

  Qué hace este shader:
    1. Lee el pixel del frame ya renderizado (con blur nativo de hyprlock).
    2. Calcula la distancia al centro de la pantalla.
    3. Oscurece los bordes progresivamente (viñeta fotográfica clásica).
    4. Agrega un tinte navy Deep Ocean muy sutil en la zona oscurecida.
    5. El centro queda limpio: el foco visual va naturalmente al reloj y al input.

  Paleta Deep Ocean aplicada:
    navy bg: #0a0e17 = vec3(0.039, 0.055, 0.090)

  Intensidad calibrada:
    darkening 38% en bordes extremos = elegante, no flashy.
    tint alpha 18% = sutil, casi imperceptible.
*/

precision highp float;

in  vec2           v_texcoord;   // UV normalizado (0.0,0.0) = esquina sup-izq, (1.0,1.0) = inf-der
uniform sampler2D  tex;          // frame completo de la pantalla (post-blur de hyprlock)
out vec4           fragColor;    // color de salida del fragmento

void main() {
    // ── 1. Color base del frame ──────────────────────────────────────────────
    vec4 base = texture(tex, v_texcoord);

    // ── 2. Distancia al centro ───────────────────────────────────────────────
    // Centramos las coordenadas: ahora (0,0) = centro, rangos ±0.5 en x e y.
    vec2 centered = v_texcoord - 0.5;

    // En pantalla 16:9: distancia máxima en diagonal ≈ 0.901 (sqrt(0.5²+0.28²))
    // length() es siempre >= 0, con 0 exacto en el centro.
    float dist = length(centered);

    // ── 3. Factor de viñeta ──────────────────────────────────────────────────
    // smoothstep(inner, outer, dist):
    //   dist < inner → 0.0 (zona central, sin efecto)
    //   dist > outer → 1.0 (bordes, máximo oscurecimiento)
    //   entre ambos  → interpolación cúbica suave (S-curve)
    //
    // Valores elegidos:
    //   0.28 = empieza a ~30% del radio (más allá del área donde vive el UI)
    //   0.70 = llega al máximo antes del borde físico extremo
    // Para una viñeta más agresiva: bajar 0.28 o subir 0.70.
    // Para más suave: acercar los dos valores entre sí.
    float vignette = smoothstep(0.28, 0.70, dist);

    // ── 4. Tinte navy Deep Ocean ─────────────────────────────────────────────
    // #0a0e17 en float: R=10/255≈0.039, G=14/255≈0.055, B=23/255≈0.090
    // Aplicamos el tinte solo donde la viñeta ya está oscureciendo (proporcional).
    // tintStrength máximo = 0.18 (18%) → casi imperceptible en bordes, 0 en centro.
    vec3 navyTint    = vec3(0.039, 0.055, 0.090);
    float tintStrength = vignette * 0.18;
    vec3 tinted = mix(base.rgb, navyTint, tintStrength);

    // ── 5. Oscurecimiento multiplicativo ─────────────────────────────────────
    // Multiplicar por (1 - darkening) oscurece el pixel.
    // darkening máximo = vignette * 0.38 → 38% de reducción en bordes extremos.
    // En el centro: vignette=0 → darkening=0 → sin cambio.
    float darkening = vignette * 0.38;
    vec3 finalRgb   = tinted * (1.0 - darkening);

    // Preservamos el canal alpha del frame original.
    fragColor = vec4(finalRgb, base.a);
}
