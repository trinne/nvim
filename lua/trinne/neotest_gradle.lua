-- A small neotest adapter for Kotlin tests in Gradle projects: JUnit 5, kotlin.test and
-- Kotest (run per spec class). Tests run through Gradle (`test --tests <filter>`), so the
-- project's own build setup, test dependencies and JVM settings are used, and results come
-- from Gradle's JUnit XML reports.
--
-- Debugging (neotest strategy "dap"): Gradle starts the test JVM with --debug-jvm, which
-- waits on port 5005, and kotlin-debug-adapter attaches to it.
local lib = require("neotest.lib")
local nio = require("nio")

local adapter = { name = "neotest-gradle-kotlin" }

local build_files = { "build.gradle.kts", "build.gradle" }
local root_files = { "settings.gradle.kts", "settings.gradle" }

adapter.root = function(dir)
  return lib.files.match_root_pattern(unpack(root_files))(dir)
    or lib.files.match_root_pattern(unpack(build_files))(dir)
end

function adapter.filter_dir(name)
  return name ~= "build" and name ~= ".gradle" and name ~= "node_modules" and name ~= ".git"
end

function adapter.is_test_file(path)
  return path ~= nil
    and path:match("%.kt$") ~= nil
    and path:match("/src/[^/]*[Tt]est[^/]*/") ~= nil
    and (path:match("Tests?%.kt$") or path:match("Spec%.kt$") or path:match("IT%.kt$")) ~= nil
end

local query = [[
  (class_declaration (type_identifier) @namespace.name) @namespace.definition
  (object_declaration (type_identifier) @namespace.name) @namespace.definition
  (function_declaration
    (modifiers (annotation (user_type (type_identifier) @_annotation)))
    (simple_identifier) @test.name
    (#any-of? @_annotation "Test" "ParameterizedTest" "RepeatedTest" "TestFactory" "TestTemplate")
  ) @test.definition
  ; Kotest: test("name") { }, it("name") { }, ... inside a spec class
  (call_expression
    (simple_identifier) @kotest
    (#any-of? @kotest "test" "it" "should" "expect" "scenario" "feature" "xtest" "xit")
    (call_suffix
      (value_arguments (value_argument (string_literal (string_content) @test.name)))
      (annotated_lambda))
  ) @test.definition
]]

-- Runs in neotest's parser subprocess, so it is referenced by name below
function adapter._build_position(path, source, captured)
  local kind = captured["test.name"] and "test" or "namespace"
  local definition = captured[kind .. ".definition"]
  return {
    type = kind,
    path = path,
    name = vim.treesitter.get_node_text(captured[kind .. ".name"], source),
    range = { definition:range() },
    kotest = captured.kotest ~= nil, -- run per spec class; names are matched as written
  }
end

function adapter.discover_positions(path)
  return lib.treesitter.parse_positions(path, query, {
    nested_namespaces = true,
    require_namespaces = true,
    build_position = 'require("trinne.neotest_gradle")._build_position',
  })
end

--- `package a.b` of a Kotlin file, or nil
local function package_of(path)
  for _, line in ipairs(lib.files.read_lines(path)) do
    local pkg = line:match("^%s*package%s+([%w_.]+)")
    if pkg then
      return pkg
    end
  end
end

local function unquote(name)
  return (name:gsub("^`(.*)`$", "%1"))
end

--- JVM class name (a.b.Outer$Inner) and method name of a position, from its id
--- (path::Outer::Inner::method). Method is nil for namespaces.
local function jvm_names(position)
  local parts = vim.split(position.id, "::", { plain = true })
  table.remove(parts, 1) -- the file path
  local method
  if position.type == "test" then
    method = unquote(table.remove(parts))
  end
  if #parts == 0 then
    return nil, nil
  end
  local pkg = package_of(position.path)
  local class = table.concat(vim.tbl_map(unquote, parts), "$")
  return (pkg and pkg .. "." or "") .. class, method
end

--- Gradle project path (":", ":app", ":libs:core") of the module that contains `path`
local function module_of(root, path)
  local dir = lib.files.match_root_pattern(unpack(build_files))(path) or root
  if dir == root then
    return dir, ":"
  end
  return dir, ":" .. dir:sub(#root + 2):gsub("/", ":")
end

-- Called from neotest's async context, where Vimscript functions are not allowed: use libuv.
local function gradle_cmd(root)
  local wrapper = root .. "/gradlew"
  return vim.uv.fs_access(wrapper, "X") and wrapper or "gradle"
end

local function report_files(dir)
  local files = {}
  if vim.uv.fs_stat(dir) then
    for name, kind in vim.fs.dir(dir) do
      if kind == "file" and name:match("^TEST%-.*%.xml$") then
        files[#files + 1] = dir .. "/" .. name
      end
    end
  end
  return files
end

local debug_port = 5005

function adapter.build_spec(args)
  local position = args.tree:data()
  local root = adapter.root(position.path)
  local module_dir, project = module_of(root, position.path)
  local task = (project == ":" and "" or project) .. ":test"

  local filters = {}
  if position.type == "test" or position.type == "namespace" then
    local class, method = jvm_names(position)
    filters = { (method and not position.kotest) and (class .. "." .. method) or class }
  else -- file or dir: every top-level class in it
    for _, node in args.tree:iter_nodes() do
      local data = node:data()
      if data.type == "namespace" and not data.id:match("::.*::") then
        filters[#filters + 1] = (jvm_names(data))
      end
    end
  end

  local command = { gradle_cmd(root), task, "--rerun", "--continue" }
  for _, f in ipairs(filters) do
    vim.list_extend(command, { "--tests", f })
  end

  local context = { results_dir = module_dir .. "/build/test-results/test" }
  -- Old reports would be mistaken for this run's results
  for _, file in ipairs(report_files(context.results_dir)) do
    os.remove(file)
  end

  if args.strategy ~= "dap" then
    return { command = command, cwd = root, context = context }
  end

  -- Debug: start Gradle ourselves, wait until the test JVM listens, then let neotest attach.
  table.insert(command, "--debug-jvm")
  local listening = nio.control.event()
  local output = {}
  context.job = vim.system(command, {
    cwd = root,
    stdout = function(_, data)
      if data then
        output[#output + 1] = data
        if data:find("Listening for transport dt_socket") then
          vim.schedule(listening.set)
        end
      end
    end,
  }, function()
    context.finished = true
    vim.schedule(listening.set) -- also when the build failed before the JVM started
  end)
  listening.wait()
  context.output = output
  return {
    command = { "true" },
    cwd = root,
    context = context,
    strategy = {
      type = "kotlin",
      request = "attach",
      name = "Debug Kotlin test",
      projectRoot = root,
      hostName = "localhost",
      port = debug_port,
      timeout = 30000,
    },
  }
end

local function xml_unescape(s)
  return (s:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&quot;", '"'):gsub("&apos;", "'"):gsub("&amp;", "&"))
end

--- testcases from the JUnit XML reports: list of { class, name, failure?, skipped }
local function read_reports(dir)
  local out = {}
  for _, file in ipairs(report_files(dir)) do
    local xml = table.concat(lib.files.read_lines(file), "\n")
    local pos = 1
    while true do
      local s, e, attrs, self_closing = xml:find("<testcase(.-)(/?)>", pos)
      if not s then
        break
      end
      local body = ""
      pos = e + 1
      if self_closing == "" then
        local close = xml:find("</testcase>", pos, true) or #xml
        body = xml:sub(pos, close - 1)
        pos = close
      end
      local name, class = attrs:match(' name="(.-)"'), attrs:match('classname="(.-)"')
      if name and class then
        local failure = body:match('<failure[^>]-message="(.-)"') or body:match('<error[^>]-message="(.-)"')
        if not failure and (body:find("<failure") or body:find("<error")) then
          failure = "failed"
        end
        out[#out + 1] = {
          class = xml_unescape(class),
          name = (xml_unescape(name):gsub("%(.*%)$", "")), -- JUnit appends "()" to method names
          failure = failure and xml_unescape(failure),
          skipped = body:find("<skipped") ~= nil,
        }
      end
    end
  end
  return out
end

function adapter.results(spec, result, tree)
  -- Debug run: the session has ended. Give Gradle time to finish the tests and write the
  -- reports; if the session was terminated the test JVM may linger, so stop it.
  if spec.context.job then
    for _ = 1, 600 do
      if spec.context.finished then
        break
      end
      nio.sleep(100)
    end
    if not spec.context.finished then
      spec.context.job:kill("sigterm")
    end
  end
  local cases = read_reports(spec.context.results_dir)
  local results = {}

  for _, node in tree:iter_nodes() do
    local pos = node:data()
    if pos.type == "test" or pos.type == "namespace" then
      local class, method = jvm_names(pos)
      local status, errors, found = "passed", {}, false
      for _, c in ipairs(cases) do
        local match
        if method and pos.kotest then -- nested Kotest containers prefix the name
          match = c.class == class and (c.name == method or vim.endswith(c.name, method))
        elseif method then
          match = c.class == class and c.name == method
        else -- a class (or Kotest spec): all its tests, including nested classes
          match = c.class == class or vim.startswith(c.class, class .. "$")
        end
        if match then
          found = true
          if c.failure then
            status = "failed"
            errors[#errors + 1] = { message = c.failure }
          elseif c.skipped and status == "passed" and method then
            status = "skipped"
          end
        end
      end
      if found then
        results[pos.id] = { status = status, errors = errors, output = result.output }
      end
    end
  end

  -- Nothing ran (compilation error, bad filter): fail the requested position with Gradle's output
  if vim.tbl_isempty(results) then
    results[tree:data().id] = { status = "failed", output = result.output }
  end
  return results
end

return setmetatable(adapter, {
  __call = function()
    return adapter
  end,
})
