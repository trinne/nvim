-- Java: eclipse.jdt.ls through nvim-jdtls (refactorings, test and debug support on top of LSP).
--
-- jdtls, java-debug and java-test are installed by mason (lua/trinne/tools.lua) when `java` is
-- on PATH, e.g. from the project's mise.toml. jdtls itself runs on Java 25+: the project's Java
-- when it is new enough, otherwise $JDTLS_JAVA_HOME or mise's java@temurin-25. The project's
-- own JDK is still used to build and run the code.
local function mason_path(...)
  return vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", ...)
end

local function glob(pattern)
  return vim.fn.glob(pattern, true, true)
end

local function bundles()
  local jars = glob(mason_path("java-debug-adapter", "extension", "server", "com.microsoft.java.debug.plugin-*.jar"))
  for _, jar in ipairs(glob(mason_path("java-test", "extension", "server", "*.jar"))) do
    local name = vim.fs.basename(jar)
    if name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and name ~= "jacocoagent.jar" then
      jars[#jars + 1] = jar
    end
  end
  return jars
end

local jdtls_min_java = 25

local function java_major(java)
  local out = vim.system({ java, "-version" }, { text = true }):wait()
  local version = (out.stderr or ""):match('version "([%d.]+)')
  return version and tonumber(version:match("^%d+")) or 0
end

--- A java binary that can run jdtls, or nil
local jdtls_java_cache
local function jdtls_java()
  if jdtls_java_cache ~= nil then
    return jdtls_java_cache or nil
  end
  local candidates = { "java" }
  if vim.env.JDTLS_JAVA_HOME then
    table.insert(candidates, 1, vim.fs.joinpath(vim.env.JDTLS_JAVA_HOME, "bin", "java"))
  end
  if vim.fn.executable("mise") == 1 then
    local out = vim.system({ "mise", "where", "java@temurin-" .. jdtls_min_java }, { text = true }):wait()
    if out.code == 0 then
      candidates[#candidates + 1] = vim.fs.joinpath(vim.trim(out.stdout), "bin", "java")
    end
  end
  for _, java in ipairs(candidates) do
    if vim.fn.executable(java) == 1 and java_major(java) >= jdtls_min_java then
      jdtls_java_cache = java
      return java
    end
  end
  jdtls_java_cache = false
  vim.notify(
    ("jdtls needs Java %d+: run `mise install java@temurin-%d` (or set $JDTLS_JAVA_HOME) and restart nvim"):format(
      jdtls_min_java,
      jdtls_min_java
    ),
    vim.log.levels.WARN
  )
end

--- The jdtls launch command, without mason's Python wrapper (the container has no Python)
local function cmd(root)
  local home = mason_path("jdtls")
  local launcher = glob(vim.fs.joinpath(home, "plugins", "org.eclipse.equinox.launcher_*.jar"))[1]
  if not launcher then
    return nil
  end
  local java = jdtls_java()
  if not java then
    return nil
  end
  local os_config = vim.uv.os_uname().sysname == "Darwin" and "config_mac" or "config_linux"
  local project = vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 8)
  return {
    java,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.level=WARNING",
    "-Xmx2g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", launcher,
    "-configuration", vim.fs.joinpath(home, os_config),
    "-data", vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls", project),
  }
end

local root_markers = { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", "pom.xml", "build.gradle", "build.gradle.kts", ".git" }

local settings = {
  java = {
    signatureHelp = { enabled = true },
    contentProvider = { preferred = "fernflower" }, -- decompile library classes
    completion = {
      favoriteStaticMembers = {
        "org.assertj.core.api.Assertions.*",
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "org.mockito.Mockito.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
      },
      filteredTypes = { "com.sun.*", "io.micrometer.shaded.*", "java.awt.*", "jdk.*", "sun.*" },
    },
    sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
    codeGeneration = {
      toString = { template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}" },
      hashCodeEquals = { useJava7Objects = true },
      useBlocks = true,
    },
  },
}

local function on_attach(_, bufnr)
  local jdtls = require("jdtls")
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end
  map("n", "<leader>o", jdtls.organize_imports, "Organize imports")
  map({ "n", "x" }, "<leader>ev", function()
    jdtls.extract_variable(vim.fn.mode() ~= "n")
  end, "Extract variable")
  map({ "n", "x" }, "<leader>ec", function()
    jdtls.extract_constant(vim.fn.mode() ~= "n")
  end, "Extract constant")
  map("x", "<leader>em", function()
    jdtls.extract_method(true)
  end, "Extract method")
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("trinne.java", { clear = true }),
  pattern = "java",
  callback = function(ev)
    local root = vim.fs.root(ev.buf, root_markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(ev.buf))
    local command = cmd(root)
    if not command then
      return -- jdtls not installed (no Java on PATH when nvim started) or no Java 25 to run it
    end
    require("jdtls").start_or_attach({
      name = "jdtls",
      cmd = command,
      root_dir = root,
      settings = settings,
      init_options = { bundles = bundles() },
      capabilities = require("blink.cmp").get_lsp_capabilities(),
      on_attach = on_attach,
    })
  end,
})

-- Debug configurations: :DapNew / <leader>dc lists the project's main classes (from
-- java-debug), plus attaching to a JVM started with JDWP on port 5005 (e.g. bootRun --debug-jvm)
require("dap").configurations.java = {
  {
    type = "java",
    request = "attach",
    name = "JVM: attach (port 5005)",
    hostName = "127.0.0.1",
    port = 5005,
  },
}
