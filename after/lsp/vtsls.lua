-- vtsls for projects on TypeScript < 7 and plain JS; TypeScript 7+ projects use the native
-- `tsc --lsp` instead (after/lsp/tsc.lua). See lua/trinne/typescript.lua.
return { root_dir = require("trinne.typescript").root_dir("vtsls", false) }
