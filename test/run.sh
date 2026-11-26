#!/usr/bin/env bash
# Headless checks for this config against the projects in test/fixtures.
# Needs on PATH: nvim 0.12+, tree-sitter, node, java 21+, gradle, and java@temurin-25 installed
# with mise for jdtls (CI installs them all with mise).
#   test/run.sh            everything
#   test/run.sh lsp dap    only some groups (startup, lsp, neotest, dap)
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
checks=$here/checks
fx=$here/fixtures
groups=${*:-startup lsp neotest dap}
failed=0

check() { # check <dir> <lua globals> <check>
  local dir=$1 globals=$2 script=$3
  if ! (cd "$dir" && nvim --headless "+lua ${globals:-_ = nil}" "+luafile $checks/$script.lua"); then
    failed=$((failed + 1))
  fi
  echo
}

has() { [[ " $groups " == *" $1 "* ]]; }

echo "== install plugins, parsers and tools"
nvim --headless "+lua require('trinne.tools').sync()" +qa
for d in vitest-oxc jest-biome eslint-prettier; do
  [ -d "$fx/$d/node_modules" ] || (cd "$fx/$d" && npm ci --no-audit --no-fund --silent)
done

if has startup; then
  echo "== startup"
  check "$fx" "" startup
fi

if has lsp; then
  echo "== language servers and formatters"
  check "$fx/vitest-oxc" 'FILE="src/lint-example.ts" WANT={"oxlint","tsc"} UNWANTED={"vtsls","biome","eslint"} MIN_DIAG=2 FORMATTER="oxfmt"' lsp
  check "$fx/jest-biome" 'FILE="src/sum.js" WANT={"biome","vtsls"} UNWANTED={"oxlint","eslint"} FORMATTER="biome"' lsp
  check "$fx/eslint-prettier" 'FILE="src/lint-example.js" WANT={"eslint","vtsls"} UNWANTED={"oxlint","biome","tailwindcss"} MIN_DIAG=1 FORMATTER="prettierd"' lsp
  check "$fx/kotlin-gradle" 'FILE="src/main/kotlin/demo/Calculator.kt" WANT={"kotlin_lsp"} FORMATTER="ktlint"' lsp
  check "$fx/java-gradle" 'FILE="src/main/java/demo/Calculator.java" WANT={"jdtls"} FORMATTER=nil' lsp
fi

if has neotest; then
  echo "== tests (neotest)"
  check "$fx/vitest-oxc" 'FILE="src/sum.test.ts" ADAPTER="neotest-vitest" PASSED=1 FAILED=1' neotest
  check "$fx/jest-biome" 'FILE="src/sum.test.js" ADAPTER="neotest-jest" PASSED=1 FAILED=0' neotest
  check "$fx/kotlin-gradle" 'FILE="src/test/kotlin/demo/CalculatorTest.kt" ADAPTER="neotest-gradle-kotlin" PASSED=2 FAILED=1' neotest
  check "$fx/kotlin-gradle" 'FILE="src/test/kotlin/demo/CalculatorSpec.kt" ADAPTER="neotest-gradle-kotlin" PASSED=1 FAILED=0' neotest
  check "$fx/java-gradle" 'FILE="src/test/java/demo/CalculatorTest.java" ADAPTER="neotest-java" PASSED=1 FAILED=1' neotest
fi

if has dap; then
  echo "== debugging (nvim-dap)"
  # <leader>td on the test under the cursor
  debug_test='function(run) vim.cmd.edit(TEST[1]) vim.api.nvim_win_set_cursor(0, { TEST[2], 0 }) vim.api.nvim_feedkeys(vim.keycode("<leader>td"), "mx", false) end'
  check "$fx/vitest-oxc" "NAME='node launch' BREAK={'src/sum.ts',3} EXPECT_VAR='total=3' START=function(run) local c = vim.deepcopy(require('dap').configurations.typescript[1]) c.program = vim.fn.fnamemodify('src/server.ts', ':p') c.console = 'internalConsole' run(c) end" dap
  check "$fx/vitest-oxc" "NAME='vitest test' BREAK={'src/sum.ts',3} TEST={'src/sum.test.ts',6} EXPECT_VAR='total=3' START=$debug_test" dap
  check "$fx/jest-biome" "NAME='jest test' BREAK={'src/sum.js',3} TEST={'src/sum.test.js',5} EXPECT_VAR='total=3' START=$debug_test" dap
  check "$fx/kotlin-gradle" "NAME='kotlin test' BREAK={'src/main/kotlin/demo/Calculator.kt',5} TEST={'src/test/kotlin/demo/CalculatorTest.kt',12} EXPECT_VAR='a=1' START=$debug_test" dap
  check "$fx/java-gradle" "NAME='java test' BREAK={'src/main/java/demo/Calculator.java',6} TEST={'src/test/java/demo/CalculatorTest.java',12} EXPECT_VAR='sum=3' START=$debug_test" dap
fi

if [ "$failed" -gt 0 ]; then
  echo "$failed check(s) failed"
  exit 1
fi
echo "all checks passed"
