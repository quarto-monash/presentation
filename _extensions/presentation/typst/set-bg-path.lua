-- Resolve the background images path relative to this filter file,
-- so it works both in the template repo and when installed elsewhere.
-- Only sets bg-path if the user has not already specified it.
function Meta(meta)
  if not meta["bg-path"] then
    -- PANDOC_SCRIPT_FILE is the path to this file (absolute or relative).
    -- Strip the trailing /typst/set-bg-path.lua to get the extension root,
    -- then keep only the _extensions/... suffix so the path is relative to
    -- the project directory (which is where Typst resolves paths from).
    local ext_dir = PANDOC_SCRIPT_FILE:match("^(.*)/typst/set%-bg%-path%.lua$")
    local rel_dir = ext_dir and ext_dir:match("(_extensions/.+)$")
    if rel_dir then
      -- assign a RawInline for typst so underscores are not escaped
      meta["bg-path"] = pandoc.MetaInlines{ pandoc.RawInline("typst", rel_dir .. "/_images/background/") }
    end
  end
  return meta
end
