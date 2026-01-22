local M = {}

---Check if a file exists
---@param filename string
---@return boolean
local function file_exists(filename)
	local f = io.open(filename, "r")
	if f then
		io.close(f)
		return true
	end
	return false
end

---Read all lines from a file
---@param filename string
---@return string[]
local function read_lines_from_file(filename)
	local f = io.open(filename, "r")
	if not f then
		error("file '" .. filename .. "' does not exist")
	end
	local lines = {}
	for line in f:lines() do
		table.insert(lines, line)
	end
	f:close()
	return lines
end

---Check if buffer is empty or contains only whitespace
---@param lines string[]
---@return boolean
local function empty_or_whitespace(lines)
	for _, line in ipairs(lines) do
		if line:match("%S") then
			return false
		end
	end
	return true
end

---Find the appropriate template file for a given file extension, prioritizing custom templates
---@param cfg HatchConfig
---@param file_extension string
---@return string|nil
local function get_template_file(cfg, file_extension)
	local custom_template_file = cfg.custom_directory .. "/template." .. file_extension
	if file_exists(custom_template_file) then
		return custom_template_file
	end

	local default_template_file = cfg.default_directory .. "/template." .. file_extension
	if file_exists(default_template_file) then
		return default_template_file
	end

	return nil
end

---Clone the template repository if it doesn't exist
---@param cfg HatchConfig
local function clone_templates(cfg)
	local template_directory = cfg.template_directory
	if vim.fn.isdirectory(template_directory) == 1 then
		vim.notify("Directory '" .. template_directory .. "' already exists, skipping clone.", vim.log.levels.WARN)
		return
	end

	vim.fn.jobstart("git clone " .. cfg.template_repository .. " " .. template_directory, {
		on_exit = function(_, code)
			if code == 0 then
				vim.notify("Cloned template repository into '" .. template_directory .. "'.", vim.log.levels.INFO)
			else
				vim.notify("Failed cloning template repository.", vim.log.levels.ERROR)
			end
		end,
		on_stderr = function(_, msg)
			vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO)
		end,
	})
end

---Insert template lines into a buffer (handling the cursor directive)
---@param buf number
---@param template_lines string[]
local function add_template_to_buf(buf, template_lines)
	local first_line = template_lines[1]

	-- Parse cursor directive (e.g., #cursor 2:4)
	local row, col = first_line:match("^#cursor%s+(%d+):(%d+)$")
	if row and col then
		row, col = tonumber(row), tonumber(col)
		table.remove(template_lines, 1) -- remove directive line
		vim.b.hatch_cursor = { row = row, col = col }
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, template_lines)
end

---Apply the cursor position from the cursor directive
local function apply_cursor()
	local pos = vim.b.hatch_cursor
	if not pos then
		return
	end
	vim.api.nvim_win_set_cursor(0, { pos.row, pos.col })
	vim.b.hatch_cursor = nil
end

---Check if a buffer can be hatched (namely, when it is empty)
---@param buf number
---@param cfg HatchConfig
---@return { hatchable: boolean, file_extension: string }
local function can_hatch(buf, cfg)
	local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	if not empty_or_whitespace(buf_lines) then
		return { hatchable = false, file_extension = "" }
	end

	local buf_file_name = vim.api.nvim_buf_get_name(buf)
	local file_extension = buf_file_name:match("^.+%.(.+)$") or ""
	local template_file = get_template_file(cfg, file_extension)
	return { hatchable = template_file ~= nil, file_extension = file_extension }
end

---@class HatchConfig
---@field template_repository string Repository URL for templates
---@field template_directory string Base directory for templates
---@field create_autocmd boolean Whether to create a autocmd in BufWritePre
---@field default_directory boolean Directory that houses default templates
---@field custom_directory boolean Directory that houses custom templates
---
---Setup Hatch plugin with configuration
---@param opts? table
---@field opts.template_repository? string
---@field opts.template_directory? string
---@field opts.create_autocmd? boolean
function M.setup(opts)
	opts = opts or {}

	M.cfg = {
		template_repository = opts.template_repository or "git@github.com:codevogel/hatch.nvim-templates.git",
		template_directory = opts.template_directory or (vim.fn.expand("$HOME") .. "/.config/hatch.nvim/templates"),
		create_autocmd = opts.create_autocmd or true,
	}
	M.cfg.default_directory = M.cfg.template_directory .. "/default"
	M.cfg.custom_directory = M.cfg.template_directory .. "/custom"

	local augroup = vim.api.nvim_create_augroup("HatchPlugin", { clear = true })

	vim.api.nvim_create_user_command("HatchCloneTemplates", function()
		clone_templates(M.cfg)
	end, {})

	vim.api.nvim_create_user_command("Hatch", function()
		M.hatch()
		apply_cursor()
	end, {})



	vim.api.nvim_create_user_command("HatchForce", function()
		M.force_hatch()
	end, {})

	if M.cfg.create_autocmd then
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			pattern = "*",
			callback = function()
				M.hatch()
			end,
		})
	end

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = augroup,
		pattern = "*",
		callback = apply_cursor,
	})
end

---Check if the current buffer can be hatched
---@param buf number
---@return boolean
function M.can_hatch(buf)
	return can_hatch(buf, M.cfg).hatchable
end

---Force apply template to a buffer by clearing it first
---Mind that if no appropriate template file exists, this just clears the buffer
---@param buf? number Buffer handle (optional; defaults to current buffer)
function M.force_hatch(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	-- Clear the buffer completely
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
	-- Apply template
	M.hatch()
	apply_cursor()
end

---Apply template to the current buffer, reports back whether template was applied
---@param buf? number Buffer handle (optional; defaults to current buffer)
---@return boolean
function M.hatch(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	local result = can_hatch(buf, M.cfg)
	if not result.hatchable then
		return false
	end

	local template_file = get_template_file(M.cfg, result.file_extension)
	if template_file == nil then
		return false
	end
	local template_lines = read_lines_from_file(template_file)
	add_template_to_buf(buf, template_lines)
	return true
end

return M
