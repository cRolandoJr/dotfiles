// Hace cumplir en opencode las mismas "Reglas mecánicas" que el hook PreToolUse de Claude Code.
// No duplica reglas: le pasa el comando al MISMO script (~/.claude/hooks/mechanical-rules-bash.sh)
// con el JSON que espera y, si responde "deny", corta la ejecución lanzando un error con el motivo.
import { spawnSync } from "node:child_process"
import { homedir } from "node:os"
import { join } from "node:path"

const SCRIPT = join(homedir(), ".claude/hooks/mechanical-rules-bash.sh")

// Devuelve el motivo del bloqueo, o null si el comando pasa.
// NO se exporta: opencode carga como plugin CADA función exportada del archivo, y esta
// devuelve null → "null is not an object (evaluating 'C.config')" y se cae el servidor.
function denyReason(command) {
  const r = spawnSync("bash", [SCRIPT], {
    input: JSON.stringify({ tool_input: { command } }),
    encoding: "utf8",
  })
  // Fail-closed: si el script no corre, el comando no pasa sin revisión.
  if (r.error || r.status !== 0) return `hook de reglas mecánicas no pudo correr: ${r.error ?? r.stderr}`
  if (!r.stdout.trim()) return null
  const out = JSON.parse(r.stdout).hookSpecificOutput
  return out?.permissionDecision === "deny" ? out.permissionDecisionReason : null
}

export const MechanicalRules = async () => ({
  "tool.execute.before": async (input, output) => {
    if (input.tool !== "bash") return
    const reason = denyReason(output.args.command)
    if (reason) throw new Error(`BLOQUEADO por una regla mecánica del CLAUDE.md:\n${reason}`)
  },
})
