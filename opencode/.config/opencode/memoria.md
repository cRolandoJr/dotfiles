# Memoria persistente (compartida con Claude Code)

Tenés una memoria en archivos en `~/.claude/projects/-home-rolando/memory/`. Es la misma que usa
Claude Code: lo que escribas acá lo lee la otra herramienta, y al revés.

- `MEMORY.md` es el ÍNDICE: una línea por memoria (`- [Título](archivo.md) — gancho`). Se carga al
  inicio de cada sesión. El contenido NO va en el índice.
- Cada memoria es un archivo con un solo hecho, con este encabezado:

```markdown
---
name: <slug-en-kebab-case>
description: <una línea: para decidir si es relevante>
metadata:
  type: user | feedback | project | reference
---

<el hecho; en feedback/project, seguido de **Why:** y **How to apply:**. Enlazar otras con [[slug]].>
```

Reglas:

- Antes de responder sobre algo del índice, ABRIR el archivo: el índice es un resumen.
- Una memoria es de cuando se escribió: si nombra un archivo, función o flag, verificar que exista
  antes de recomendarlo.
- Antes de crear una, buscar si ya hay una que lo cubra y actualizarla. Borrar las que resulten falsas.
- No guardar lo que ya está en el repo (código, historial de git) ni lo que solo importa en esta charla.
- Después de crear el archivo, agregar su línea al índice `MEMORY.md`.
- Las reglas de conducta operativa NO van a memoria: van a `~/.claude/CLAUDE.md`, sección "Reglas
  mecánicas", según el criterio que describe esa sección.
