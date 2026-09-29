// Regresión del plugin: nix shell nixpkgs#bun -c bun ~/.config/opencode/tests/mechanical-rules.test.mjs
// El primer caso fija el bug del 28-sep: exportar otra función la carga como plugin y tira el servidor.
const mod = await import(process.env.PLUGIN ?? new URL("../plugins/mechanical-rules.js", import.meta.url).pathname)
const exported = Object.keys(mod)
const hooks = await mod.MechanicalRules({})
const bloquea = async (cmd) => { try { await hooks["tool.execute.before"]({ tool: "bash" }, { args: { command: cmd } }); return false } catch { return true } }
const casos = [
  ["solo exporta el plugin", exported.length === 1 && exported[0] === "MechanicalRules"],
  ["bloquea pipe + $?", await bloquea("make test | tail -3; echo $?")],
  ["deja pasar git status", !(await bloquea("git status --short"))],
  ["deja pasar con escape", !(await bloquea("make test | tail -3; echo $? # REGLA-OK:pipe"))],
]
let otra = false; try { await hooks["tool.execute.before"]({ tool: "read" }, { args: {} }) } catch { otra = true }
casos.push(["ignora otras herramientas", !otra])
let f = 0; for (const [n, ok] of casos) { if (!ok) f++; console.log(`${ok ? "OK  " : "FALLA"} ${n}`) }
console.log(`resumen: ${f} fallos`)
