-- Solitude addon | SaveManager
-- Sauvegarde et chargement des configurations, au format JSON.

return function(Library)
	local httpService = game:GetService("HttpService")

	local SaveManager = {}
	SaveManager.Library = Library
	SaveManager.Folder = "Solitude"
	SaveManager.Ignore = {}
	SaveManager.Format = "json"

	function SaveManager:SetLibrary(lib)
		self.Library = lib or Library
	end

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list or {} do
			self.Ignore[key] = true
		end
	end

	function SaveManager:IgnoreThemeSettings()
		local library = self.Library
		if library.InterfaceManager then
			self:SetIgnoreIndexes(library.InterfaceManager.Flags)
		end
		if library.ThemeManager then
			self:SetIgnoreIndexes(library.ThemeManager.Flags)
		end
	end

	function SaveManager:BuildFolderTree()
		local paths = {}

		-- build the entire tree if a path is like some-hub/phantom-forces
		-- makefolder builds the entire tree on Synapse X but not other exploits

		local parts = self.Folder:split("/")
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, "/", 1, idx)
		end

		table.insert(paths, self.Folder .. "/settings")

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function SaveManager:Save(name)
		if type(name) ~= "string" or name:gsub("%s", "") == "" then
			return false, "no config file is selected"
		end

		local file = name
		if not file:match("%.%w+$") then file = file .. "." .. self.Format end

		local fullPath = self.Folder .. "/settings/" .. file

		local success, encoded = pcall(httpService.JSONEncode, httpService, self.Library:GetConfig(self.Ignore))
		if not success then
			return false, "failed to encode data"
		end

		writefile(fullPath, encoded)
		self.Library:ClearDirty()
		return true, file
	end

	function SaveManager:Load(file)
		if type(file) ~= "string" or file == "" then
			return false, "no config file is selected"
		end

		local path = self.Folder .. "/settings/" .. file
		if not isfile(path) then return false, "invalid file" end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(path))
		if not success then return false, "decode error" end

		self.Library:LoadConfig(decoded, self.Ignore)
		return true, file
	end

	function SaveManager:Delete(file)
		if type(file) ~= "string" or file == "" then
			return false, "no config file is selected"
		end

		local path = self.Folder .. "/settings/" .. file
		if not isfile(path) then return false, "invalid file" end

		local success = pcall(delfile, path)
		if not success then return false, "delete file error" end

		if self:GetAutoload() == file then self:ClearAutoload() end
		return true, file
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder .. "/settings")

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == ".json" then
				-- i hate this but it has to be done ...

				local pos = file:find(".json", 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= "/" and char ~= "\\" and char ~= "" do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == "/" or char == "\\" then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end

		return out
	end

	function SaveManager:AutoloadPath()
		return self.Folder .. "/settings/autoload.txt"
	end

	function SaveManager:GetAutoload()
		if not isfile(self:AutoloadPath()) then return nil end
		local name = readfile(self:AutoloadPath())
		if name == "" then return nil end
		return name
	end

	function SaveManager:SetAutoload(file)
		if type(file) ~= "string" or file == "" then return false end
		writefile(self:AutoloadPath(), file)
		return true
	end

	function SaveManager:ClearAutoload()
		if isfile(self:AutoloadPath()) then
			pcall(delfile, self:AutoloadPath())
		end
	end

	function SaveManager:LoadAutoloadConfig()
		local file = self:GetAutoload()
		if not file then return false end

		local success, err = self:Load(file)
		self.Library:Notify({
			Title = success and "config loaded" or "config error",
			Text = success and file or tostring(err),
			Duration = 3,
		})
		return success
	end

	function SaveManager:BuildConfigSection(tab, column)
		assert(self.Library, "Must set SaveManager.Library first!")

		local section = tab:Section("configs", column or 2)

		local nameBox = section:Input({ Text = "config name", Flag = false, Default = "default", Placeholder = "config name" })
		local listBox = section:Dropdown({ Text = "config list", Flag = false, Options = self:RefreshConfigList(), AllowNull = true, Empty = "none" })

		section:Divider()

		local autoloadLabel, dirtyLabel

		local function refreshList(select)
			listBox:SetOptions(self:RefreshConfigList())
			listBox:Set(select, true)
		end

		section:ButtonRow({
			{
				Text = "create config",
				Callback = function()
					local name = nameBox:Get()
					local success, result = self:Save(name)
					self.Library:Notify({
						Title = success and "config created" or "config error",
						Text = success and string.format("created %q", result) or tostring(result),
						Duration = 3,
					})
					if success then refreshList(result) end
				end,
			},
			{
				Text = "load config",
				Callback = function()
					local success, result = self:Load(listBox:Get())
					self.Library:Notify({
						Title = success and "config loaded" or "config error",
						Text = success and string.format("loaded %q", result) or tostring(result),
						Duration = 3,
					})
				end,
			},
		})

		section:ButtonRow({
			{
				Text = "overwrite config",
				Callback = function()
					local success, result = self:Save(listBox:Get())
					self.Library:Notify({
						Title = success and "config overwritten" or "config error",
						Text = success and string.format("overwrote %q", result) or tostring(result),
						Duration = 3,
					})
				end,
			},
			{
				Text = "refresh list",
				Callback = function() refreshList() end,
			},
		})

		section:ButtonRow({
			{
				Text = "delete config",
				Callback = function()
					local file = listBox:Get()
					if not file then
						return self.Library:Notify({ Title = "config error", Text = "no config file is selected", Duration = 3 })
					end

					local function remove()
						local success, result = self:Delete(file)
						if success then
							refreshList()
							autoloadLabel:Set("autoload: " .. (self:GetAutoload() or "none"))
						end
						self.Library:Notify({
							Title = success and "config deleted" or "config error",
							Text = success and string.format("deleted %q", result) or tostring(result),
							Duration = 3,
						})
					end

					local window = self.Library.Windows[1]
					if not window then return remove() end

					window:Confirm({
						Title = "delete config",
						Text = "Delete " .. file .. " permanently?",
						Confirm = "delete",
						Cancel = "cancel",
						OnConfirm = remove,
					})
				end,
			},
			{
				Text = "set as autoload",
				Callback = function()
					local file = listBox:Get()
					if not file then
						return self.Library:Notify({ Title = "config error", Text = "no config file is selected", Duration = 3 })
					end
					self:SetAutoload(file)
					autoloadLabel:Set("autoload: " .. file)
					self.Library:Notify({ Title = "autoload set", Text = string.format("%q will load automatically", file), Duration = 3 })
				end,
			},
		})

		section:Button({
			Text = "clear autoload",
			Callback = function()
				self:ClearAutoload()
				autoloadLabel:Set("autoload: none")
			end,
		})

		autoloadLabel = section:Label("autoload: " .. (self:GetAutoload() or "none"))
		dirtyLabel = section:Label("no unsaved changes")

		self.Library:CaptureDefaults()
		self.Library:ClearDirty()
		self.Library.OnDirty = function(state)
			dirtyLabel:Set(state and "unsaved changes" or "no unsaved changes")
			dirtyLabel:SetColor(state and self.Library.Theme.Accent or self.Library.Theme.TextDim)
		end

		self.Section = section
		return section
	end

	Library.DirtyIgnore = SaveManager.Ignore

	SaveManager:BuildFolderTree()

	return SaveManager
end
