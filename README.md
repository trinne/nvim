# nvim

My Neovim config. It needs **Neovim 0.12+** and is built on what Neovim now does itself:
the `vim.pack` plugin manager, `vim.lsp.config` / `vim.lsp.enable`, the default LSP keymaps,
treesitter highlighting and `:Undotree`.

It is installed and kept up to date by [trinne/dotfiles](https://github.com/trinne/dotfiles),
which also installs Neovim, the `tree-sitter` CLI and a C compiler, and sets the color theme.

## Install

```sh
git clone https://github.com/trinne/nvim ~/.config/nvim
nvim   # first start installs plugins, treesitter parsers and language servers
```

Language servers, formatters and debug adapters are installed by mason, but only for runtimes
that are on `PATH` when nvim starts: Node tools need `node`, Python tools need `python3`, and
Java/Kotlin tools need `java`. In a devbox container, the project's `mise.toml` provides them.
The list is in [`lua/trinne/tools.lua`](lua/trinne/tools.lua).

## Layout

```
init.lua                      load order
nvim-pack-lock.json           exact plugin revisions (commit it after updating)
lua/trinne/
  options.lua keymaps.lua autocmds.lua
  pack.lua                    every plugin, one vim.pack.add() call
  theme.lua                   colorscheme from the dotfiles theme (~/.config/dotfiles/theme)
  tools.lua                   mason tools and the servers they enable
  lsp.lua                     LSP keymaps and diagnostics
  typescript.lua              TypeScript 7 (native tsc) vs older TypeScript (vtsls)
  neotest_gradle.lua          neotest adapter for Kotlin (Gradle)
  plugins/                    setup and keymaps per area: ui, editor, treesitter, completion,
                              lsp, format, git, java, debug, test, db
after/lsp/                    overrides for nvim-lspconfig's server configs
test/                         headless checks and fixture projects (CI)
```

## Plugins

| Area | Plugins |
|---|---|
| UI | snacks.nvim (picker, explorer, lazygit, notifications, indent guides), which-key, lualine, mini.icons, mini.pairs, tokyonight / nord / catppuccin |
| Editing | nvim-treesitter (`main`), nvim-treesitter-textobjects, nvim-ts-autotag, harpoon, todo-comments |
| Completion | blink.cmp, friendly-snippets, lazydev |
| LSP and formatting | nvim-lspconfig (configs only), mason, conform, nvim-jdtls |
| Git | gitsigns (+ snacks lazygit and git pickers) |
| Debug and test | nvim-dap, nvim-dap-view, neotest with vitest, jest and Java adapters, plus a built-in Kotlin adapter |
| Databases | vim-dadbod, vim-dadbod-ui, vim-dadbod-completion |

**Updating plugins:**
1. Run `:PackUpdate` and review the changes.
2. `:write` applies them, and `:quit` discards them.
3. Commit `nvim-pack-lock.json`.

To remove a plugin, delete it from `pack.lua` and run `:lua vim.pack.del({ "name" })`.

## Languages

| | Language servers | Formatter |
|---|---|---|
| TypeScript / JavaScript | `tsc --lsp` in TypeScript 7+ projects, otherwise vtsls; html, cssls, jsonls, tailwindcss | see below |
| Kotlin | kotlin-lsp (JetBrains) | ktlint |
| Java | jdtls (nvim-jdtls) | jdtls |
| Python | basedpyright, ruff | ruff |
| Clojure | clojure-lsp | clojure-lsp |
| Lua, shell, TOML, YAML, Docker | lua_ls, bashls (+ shellcheck), taplo, yamlls, dockerls | stylua, shfmt, taplo |

**Web projects get the tools they are set up for.** The config files are looked up from the
file upwards, and the project's own `node_modules/.bin` binaries are preferred over mason's:

| Config in the project | Lint (LSP) | Format on save |
|---|---|---|
| `biome.json(c)` | biome | biome |
| `.oxlintrc.json`, `oxlint.config.ts` | oxlint | – |
| `.oxfmtrc.json(c)`, `oxfmt.config.ts` | – | oxfmt |
| `eslint.config.*`, `.eslintrc*` | eslint | – |
| none of the formatter configs | – | prettier (prettierd) |

Linters can be combined, for example oxlint together with eslint. Only one formatter runs, in
the order biome → oxfmt → prettier. `<leader>ci` shows which servers and which formatter the
current buffer uses. `<leader>cF` toggles format on save.

## Tests and debugging

Tests run with **neotest**: `<leader>tt` runs the nearest test, `<leader>tf` the file and
`<leader>td` debugs the nearest test.

| | Tests | Debug a test | Debug the app |
|---|---|---|---|
| Vitest, Jest | neotest-vitest, neotest-jest | js-debug | `Node: launch current file` (TypeScript runs directly) or `Node: attach` to `node --inspect` (port 9229) |
| Browser | – | – | `Chrome: attach` to `--remote-debugging-port=9222` |
| Kotlin (JUnit 5, kotlin.test, Kotest) | Gradle (`lua/trinne/neotest_gradle.lua`) | kotlin-debug-adapter | `JVM: attach (port 5005)`, e.g. `./gradlew bootRun --debug-jvm` |
| Java (JUnit 5) | neotest-java (through jdtls) | java-debug | main classes found by jdtls, or `JVM: attach (port 5005)` |

- `<leader>dc` starts a session or continues one, and lists the configurations. These include
  the ones in the project's `.vscode/launch.json`.
- The debug view (nvim-dap-view) opens and closes with the session.
- **Kotlin tests:**
  - Each test runs through Gradle with `--rerun`, so the project's own build setup applies.
  - The results come from Gradle's JUnit XML reports.
  - Kotest specs run as a whole spec class.
- **Containers:** in a devbox container, the browser runs on the host. Start Chrome there with
  `--remote-debugging-port=9222`; the attach configuration connects to
  `host.containers.internal` (Podman), and `host.docker.internal` works with Docker.
- **Limitation, Kotlin app attach:**
  - kotlin-debug-adapter installs its breakpoints only after it has attached, and by then the JVM
    is already running again.
  - Code that runs right at startup (the first lines of `main`) is not stopped. Request handlers
    and anything later are.
  - Tests are not affected: test JVM startup gives the adapter enough time.

## Keymaps

Leader is `<space>`. **which-key** shows what follows a prefix after a short pause. Two more
ways to look keys up:
- `<leader>?` lists the keymaps of the current buffer.
- `<leader>fk` searches all keymaps.

**Neovim's built-in LSP keys** work everywhere:
- `grn` rename, `gra` code action, `grr` references, `gri` implementation, `grt` type definition
- `gO` symbols, `K` hover, `<C-s>` signature help (insert mode)
- `[d` / `]d` diagnostics, `<C-w>d` the diagnostic under the cursor
- visual `an` / `in` grow / shrink the selection by syntax node

My own keys are listed below. Where a built-in key does the same thing, it is in parentheses.

| Group | Keys |
|---|---|
| Find | `<leader>ff` files, `<C-p>` git files, `<leader>fg` grep, `<leader>ps` grep for input, `<leader>fw` word, `<leader>fb` buffers, `<leader>fr` recent, `<leader>fm` marks, `<leader>fh` help, `<leader>fx` / `fX` diagnostics (buffer / all), `<leader>ft` TODOs, `<leader>f.` resume, `<leader>ne` nvim config |
| LSP | `gd` definition, `gD` declaration, `gi` implementation (`gri`), `<leader>rn` rename (`grn`), `<leader>ca` code action (`gra`), `<leader>fs` / `fS` symbols, `<leader>fc` / `fo` incoming / outgoing calls, `<leader>ch` inlay hints, `<leader>rs` restart |
| Code | `<leader>cf` format, `<leader>cF` toggle format on save, `<leader>ci` tools for this buffer; Java: `<leader>o` organize imports, `<leader>ev` / `ec` / `em` extract variable / constant / method |
| Files | `<leader>pv` explorer, `<leader>pf` reveal file, `<leader>ja` add to harpoon, `<leader>jj` harpoon menu, `<leader>1`–`4` harpoon files, `<leader>u` undo tree |
| Git | `<leader>lg` lazygit, `]h` / `[h` hunks, `<leader>hs` / `hr` stage / reset hunk, `hS` / `hR` buffer, `hp` preview, `hb` / `hB` blame, `hd` / `hD` diff, `hl` file log, `hc` changed files, `ih` hunk text object |
| Test | `<leader>tt` nearest, `tf` file, `tl` last, `td` debug nearest, `tx` stop, `ts` summary, `to` / `tO` output, `tw` watch, `]x` / `[x` failed tests |
| Debug | `<leader>bb` breakpoint, `bc` conditional, `bl` log point, `br` clear, `ba` list; `<leader>dc` start / continue, `dj` / `dk` / `do` step over / into / out, `dC` run to cursor, `dl` run last, `dt` terminate, `dd` disconnect, `du` debug view, `dr` REPL, `di` watch, `ds` scopes, `df` frames |
| Database | `<leader>D` database UI, `<leader>S` run query |
| Text objects | `af` / `if` call, `am` / `im` function, `ac` / `ic` class, `aa` / `ia` argument, `ai` / `ii` conditional, `al` / `il` loop, `a=` / `i=` / `l=` / `r=` assignment; `]m` / `[m` (`]M` / `[M` end) and the same for `f`, `c`, `i`, `l`; repeat with `;` / `,`; `<leader>na` / `pa` swap argument, `nm` / `pm` swap function |
| Editing | visual `J` / `K` move lines, `<leader>y` / `Y` yank to clipboard, visual `<leader>p` paste without yanking, visual `<leader>d` delete without yanking, `<leader>s` substitute word, `<M-k>` / `<M-j>` quickfix |
| Completion | `<CR>` accept, `<C-Space>` open, `<C-n>` / `<C-p>` select, `<C-d>` / `<C-u>` scroll docs, `<C-k>` signature |

**Changes from the old config:**

| Was | Now | Why |
|---|---|---|
| `gr`, `gR` | `grr` | the old keys blocked Neovim's `gr*` keys |
| `gt` | `grt` | `gt` switches tabs |
| `<leader>d` (normal mode, void delete), `<leader>d` (line diagnostics) | `"_d`, `<C-w>d` | the old keys clashed with the debug keys |
| `<leader>t`, `<leader>T` | `<leader>tt`, `<leader>tf` | clashed with the other test keys |
| `<leader>tt` (trouble) | `<leader>fX` | the test keys took `<leader>tt` |
| `<leader>hm`, `hu`, `ht` (harpoon) | `<leader>ja`, `jj` | clashed with the git hunk keys |
| `<leader>f` (format), `<leader>l` (lint) | `<leader>cf`, automatic | `<leader>f` is the find group; linting runs through the language servers |
| `<leader>dui`, `dur` | `<leader>du` | nvim-dap-view replaces nvim-dap-ui |

## Checks

`test/run.sh` runs headless checks against the projects in `test/fixtures`.
- They check that startup works and that the themes load.
- They check which language servers and formatters each kind of project gets.
- They run tests through neotest and debug them with nvim-dap.

CI runs them on every push and weekly.
