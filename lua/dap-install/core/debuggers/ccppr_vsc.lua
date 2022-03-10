local M = {}

local dbg_path = require("dap-install.config.settings").options["installation_path"] .. "ccppr_vsc/"
local proxy = require("dap-install.config.settings").options["proxy"]

M.details = {
	dependencies = { "wget", "unzip", "make" },
}

M.dap_info = {
	name_adapter = "cpptools",
	name_configuration = { "c", "cpp", "rust" },
}

M.config = {
	adapters = {
		type = "executable",
		command = dbg_path .. "extension/debugAdapters/bin/OpenDebugAD7",
	},
	configurations = {
		{
			name = "Launch file",
			type = "cpptools",
			request = "launch",
			miDebuggerPath = dbg_path .. "gdb-10.2/gdb/gdb",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = true,
		},
		{
			name = "Attach to gdbserver :1234",
			type = "cppdbg",
			request = "launch",
			MIMode = "gdb",
			miDebuggerServerAddress = "localhost:1234",
			miDebuggerPath = dbg_path .. "gdb-10.2/gdb/gdb",
			cwd = "${workspaceFolder}",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
		},
	},
}

local install_string
if proxy == nil or proxy == "" then
	install_string = [[
        wget https://github.com/microsoft/vscode-cpptools/releases/download/1.8.1/cpptools-osx-arm64.vsix
		mv cpptools-osx-arm64.vsix cpptools-osx-arm64.zip
		unzip cpptools-osx-arm64.zip
		chmod +x extension/debugAdapters/bin/OpenDebugAD7
		cp extension/cppdbg.ad7Engine.json extension/debugAdapters/bin/nvim-dap.ad7Engine.json
		wget https://ftp.gnu.org/gnu/gdb/gdb-10.2.tar.xz && tar -xvf gdb-10.2.tar.xz
		cd gdb-10.2/
		./configure
		make
	]]
else
	install_string = string.format(
		[[
      wget -e https_proxy=%s $(curl -s https://api.github.com/repos/microsoft/vscode-cpptools/releases/latest -x %s| grep browser_ | cut -d\" -f 4 | grep linux.vsix)
      mv cpptools-linux.vsix cpptools-linux.zip
      unzip cpptools-linux.zip
      chmod +x extension/debugAdapters/bin/OpenDebugAD7
      cp extension/cppdbg.ad7Engine.json extension/debugAdapters/bin/nvim-dap.ad7Engine.json
      wget https://ftp.gnu.org/gnu/gdb/gdb-10.2.tar.xz && tar -xvf gdb-10.2.tar.xz
      cd gdb-10.2/
      ./configure
      make
    ]],
		proxy,
		proxy
	)
end

M.installer = {
	before = "",
	install = install_string,
	uninstall = "simple",
}

return M
