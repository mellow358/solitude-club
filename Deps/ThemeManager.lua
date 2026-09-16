-- Solitude addon | ThemeManager
-- Presets de couleurs, edition par element, recoloration a chaud, themes custom.

return function(Library)
	local HttpService = game:GetService("HttpService")
	local Theme = Library.Theme

	-- // Safety wrappers for filesystem globals (some executors return errors instead of booleans) \\ --
	local isfolder, isfile, listfiles, delfile, writefile, readfile, makefolder =
		isfolder, isfile, listfiles, delfile, writefile, readfile, makefolder

	if typeof(copyfunction) == "function" and isfolder and isfile and listfiles then
		local isfolder_copy, isfile_copy, listfiles_copy =
			copyfunction(isfolder), copyfunction(isfile), copyfunction(listfiles)

		local ok, result = pcall(function()
			return isfolder_copy("solitude_probe_" .. tostring(math.random(1000000, 9999999)))
		end)

		if not ok or typeof(result) ~= "boolean" then
			isfolder = function(folder)
				local success, data = pcall(isfolder_copy, folder)
				return (success and data) or false
			end
			isfile = function(file)
				local success, data = pcall(isfile_copy, file)
				return (success and data) or false
			end
			listfiles = function(folder)
				local success, data = pcall(listfiles_copy, folder)
				return (success and data) or {}
			end
		end
	end

	local ThemeManager = {}
	ThemeManager.Library = Library
	ThemeManager.Folder = "Solitude"
	ThemeManager.Flags = { "theme_preset", "theme_accent" }
	ThemeManager.AutoSave = false
	ThemeManager.Current = "solitude"

	-- { Theme key, label, flag suffix }
	ThemeManager.Keys = {
		{ "Accent", "accent", "accent" },
		{ "AccentSoft", "accent hover", "accent_soft" },
		{ "AccentDim", "accent dim", "accent_dim" },
		{ "Window", "window bg", "window" },
		{ "WindowBorder", "window border", "window_border" },
		{ "TopBar", "topbar bg", "topbar" },
		{ "Section", "card bg", "section" },
		{ "SectionBorder", "card border", "section_border" },
		{ "Group", "group bg", "group" },
		{ "GroupBorder", "group border", "group_border" },
		{ "Field", "control bg", "field" },
		{ "FieldHover", "control hover", "field_hover" },
		{ "Border", "control border", "border" },
		{ "BorderSoft", "divider", "border_soft" },
		{ "PopupBg", "popup bg", "popup_bg" },
		{ "PopupBorder", "popup border", "popup_border" },
		{ "Track", "slider track", "track" },
		{ "Text", "text", "text" },
		{ "TextDim", "text dim", "text_dim" },
		{ "TextBright", "text bright", "text_bright" },
		{ "TextMarked", "text warning", "text_marked" },
		{ "TextCode", "text success", "text_code" },
		{ "Danger", "text danger", "danger" },
	}

	-- Build the full flag list once (theme_preset, theme_accent, theme_color_<key>...)
	for _, entry in ipairs(ThemeManager.Keys) do
		table.insert(ThemeManager.Flags, "theme_color_" .. entry[3])
	end

	ThemeManager.Order = {
		"solitude", "darker", "typewriter", "aqua",
		"amethyst", "rose", "contrast", "light",
	}

	ThemeManager.Presets = {
		solitude   = { Bg = Color3.fromRGB(26, 26, 28),    Accent = Color3.fromRGB(158, 188, 242) },
		darker     = { Bg = Color3.fromRGB(16, 16, 16),    Accent = Color3.fromRGB(72, 138, 182) },
		typewriter = { Bg = Color3.fromRGB(34, 34, 34),    Accent = Color3.fromRGB(109, 180, 120) },
		aqua       = { Bg = Color3.fromRGB(14, 22, 22),    Accent = Color3.fromRGB(60, 165, 165) },
		amethyst   = { Bg = Color3.fromRGB(18, 4, 32),     Accent = Color3.fromRGB(177, 51, 255) },
		rose       = { Bg = Color3.fromRGB(30, 18, 22),    Accent = Color3.fromRGB(200, 120, 170) },
		contrast   = { Bg = Color3.fromRGB(0, 0, 0),       Accent = Color3.fromRGB(86, 156, 214) },
		light      = { Bg = Color3.fromRGB(238, 238, 240), Accent = Color3.fromRGB(0, 103, 192), Light = true },
	}

	local function shade(color, amount)
		return Color3.fromRGB(
			math.clamp(color.R * 255 + amount, 0, 255),
			math.clamp(color.G * 255 + amount, 0, 255),
			math.clamp(color.B * 255 + amount, 0, 255))
	end

	local function tint(color, saturation, value)
		local h, s, v = color:ToHSV()
		return Color3.fromHSV(h, math.clamp(s * saturation, 0, 1), math.clamp(v * value, 0, 1))
	end

	local function toHex(color, alpha)
		return string.format("#%02X%02X%02X%02X",
			math.floor(color.R * 255 + 0.5),
			math.floor(color.G * 255 + 0.5),
			math.floor(color.B * 255 + 0.5),
			math.floor(math.clamp(alpha or 1, 0, 1) * 255 + 0.5))
	end

	local function fromHex(text)
		if typeof(text) == "Color3" then return text, 1 end
		if type(text) ~= "string" then return nil end
		local hex = string.gsub(string.gsub(text, "#", ""), "%s", "")
		if #hex < 6 then return nil end
		local r = tonumber(string.sub(hex, 1, 2), 16)
		local g = tonumber(string.sub(hex, 3, 4), 16)
		local b = tonumber(string.sub(hex, 5, 6), 16)
		if not r or not g or not b then return nil end
		local a = 255
		if #hex >= 8 then a = tonumber(string.sub(hex, 7, 8), 16) or 255 end
		return Color3.fromRGB(r, g, b), a / 255
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib or Library
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self.Library:BuildFolders(folder)
		self:EnsureCustomFolder()
	end

	function ThemeManager:Path()
		return self.Folder .. "/settings/theme.json"
	end

	function ThemeManager:CustomFolderPath()
		return self.Folder .. "/settings/customthemes"
	end

	function ThemeManager:CustomPath(name)
		return self:CustomFolderPath() .. "/" .. name .. ".json"
	end

	function ThemeManager:EnsureCustomFolder()
		-- Prefer the library's own filesystem abstraction if it exposes folder creation,
		-- fall back to raw executor globals so this still works standalone.
		local fs = self.Library.FileSystem
		if fs and fs.BuildFolders then
			pcall(function() fs:BuildFolders(self:CustomFolderPath()) end)
		elseif makefolder and isfolder then
			if not isfolder(self:CustomFolderPath()) then
				pcall(makefolder, self:CustomFolderPath())
			end
		end
	end

	function ThemeManager:Names()
		local names = {}
		for index, name in ipairs(self.Order) do names[index] = name end
		return names
	end

	function ThemeManager:SetAccent(color)
		color = fromHex(color)
		if not color then return false end
		Theme.Accent = color
		Theme.AccentSoft = tint(color, 0.78, 1.08)
		Theme.AccentDim = tint(color, 0.72, 0.64)
		self.Library:Repaint()
		if self.AutoSave then self:Save() end
		return true
	end

	function ThemeManager:Apply(name)
		local preset = self.Presets[name]
		if not preset then return false end

		if not self.Suppress then
			local bg = preset.Bg
			local step = preset.Light and -1 or 1

			Theme.Window = bg
			Theme.TopBar = shade(bg, 5 * step)
			Theme.Section = shade(bg, 3 * step)
			Theme.Group = shade(bg, 8 * step)
			Theme.Field = shade(bg, 14 * step)
			Theme.FieldHover = shade(bg, 22 * step)
			Theme.PopupBg = shade(bg, 12 * step)
			Theme.Track = shade(bg, 32 * step)

			Theme.WindowBorder = shade(bg, 26 * step)
			Theme.SectionBorder = shade(bg, 20 * step)
			Theme.GroupBorder = shade(bg, 28 * step)
			Theme.Border = shade(bg, 34 * step)
			Theme.BorderSoft = shade(bg, 19 * step)
			Theme.PopupBorder = shade(bg, 36 * step)

			if preset.Light then
				Theme.Text = Color3.fromRGB(70, 70, 76)
				Theme.TextDim = Color3.fromRGB(122, 122, 130)
				Theme.TextBright = Color3.fromRGB(24, 24, 28)
				Theme.TextMarked = Color3.fromRGB(158, 132, 30)
				Theme.TextCode = Color3.fromRGB(38, 138, 60)
				Theme.Danger = Color3.fromRGB(196, 58, 58)
			else
				Theme.Text = Color3.fromRGB(174, 174, 178)
				Theme.TextDim = Color3.fromRGB(108, 108, 113)
				Theme.TextBright = Color3.fromRGB(228, 228, 232)
				Theme.TextMarked = Color3.fromRGB(198, 198, 122)
				Theme.TextCode = Color3.fromRGB(96, 200, 96)
				Theme.Danger = Color3.fromRGB(226, 102, 102)
			end

			self:SetAccent(preset.Accent)
		end

		self.Current = name
		return true
	end

	-- // Session save/load (used by AutoSave, "save theme" button) \\ --

	function ThemeManager:Save()
		local alphas = self.Library.ThemeAlpha or {}
		local colors = {}
		for _, entry in ipairs(self.Keys) do
			colors[entry[1]] = toHex(Theme[entry[1]], alphas[entry[1]])
		end
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode({
				Preset = self.Current,
				Colors = colors,
			})
		end)
		if ok then self.Library.FileSystem:Write(self:Path(), encoded) end
		return ok
	end

	function ThemeManager:Load()
		local raw = self.Library.FileSystem:Read(self:Path())
		if not raw then return false end
		local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if not ok or type(data) ~= "table" then return false end

		if data.Preset then self:Apply(data.Preset) end
		for key, hex in pairs(data.Colors or {}) do
			local color, alpha = fromHex(hex)
			if color and Theme[key] ~= nil then
				self.Library:SetColor(key, color, alpha)
			end
		end
		return true
	end

	-- // Custom named themes (create / load / overwrite / delete / list) \\ --

	function ThemeManager:ListCustomThemes()
		self:EnsureCustomFolder()

		local fs = self.Library.FileSystem
		local files

		if fs and fs.List then
			local ok, result = pcall(function() return fs:List(self:CustomFolderPath()) end)
			files = (ok and result) or {}
		elseif listfiles then
			local ok, result = pcall(listfiles, self:CustomFolderPath())
			files = (ok and result) or {}
		else
			files = {}
		end

		local names = {}
		for _, file in ipairs(files) do
			local name = file:match("([^/\\]+)%.json$")
			if name then table.insert(names, name) end
		end
		table.sort(names)
		return names
	end

	function ThemeManager:SaveCustomTheme(name)
		if not name or name:gsub("%s", "") == "" then
			self.Library:Notify({ Title = "theme error", Text = "custom theme name is empty", Duration = 3 })
			return false
		end

		self:EnsureCustomFolder()

		local alphas = self.Library.ThemeAlpha or {}
		local colors = {}
		for _, entry in ipairs(self.Keys) do
			colors[entry[1]] = toHex(Theme[entry[1]], alphas[entry[1]])
		end

		local ok, encoded = pcall(function()
			return HttpService:JSONEncode({
				Name = name,
				BasedOn = self.Current,
				Colors = colors,
			})
		end)
		if not ok then return false end

		local fs = self.Library.FileSystem
		local writeOk
		if fs and fs.Write then
			writeOk = select(1, pcall(function() fs:Write(self:CustomPath(name), encoded) end))
		elseif writefile then
			writeOk = select(1, pcall(writefile, self:CustomPath(name), encoded))
		else
			writeOk = false
		end

		return writeOk
	end

	function ThemeManager:GetCustomTheme(name)
		if not name then return nil end

		local fs = self.Library.FileSystem
		local raw

		if fs and fs.Read then
			local ok, result = pcall(function() return fs:Read(self:CustomPath(name)) end)
			raw = ok and result or nil
		elseif isfile and readfile then
			if isfile(self:CustomPath(name)) then
				local ok, result = pcall(readfile, self:CustomPath(name))
				raw = ok and result or nil
			end
		end

		if not raw then return nil end

		local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if not ok or type(data) ~= "table" then return nil end
		return data
	end

	function ThemeManager:LoadCustomTheme(name)
		local data = self:GetCustomTheme(name)
		if not data then return false end

		-- Start from the base preset it was created on (or current preset) so any
		-- keys the custom file doesn't override still land somewhere sane.
		if data.BasedOn and self.Presets[data.BasedOn] then
			self:Apply(data.BasedOn)
		end

		for key, hex in pairs(data.Colors or {}) do
			local color, alpha = fromHex(hex)
			if color and Theme[key] ~= nil then
				self.Library:SetColor(key, color, alpha)
				if key == "Accent" then self:SetAccent(color) end
			end
		end

		self.Current = name
		self.Library:Repaint()
		return true
	end

	function ThemeManager:DeleteCustomTheme(name)
		if not name then return false, "no theme selected" end

		local path = self:CustomPath(name)
		local fs = self.Library.FileSystem

		if fs and fs.Delete then
			local ok = pcall(function() fs:Delete(path) end)
			if not ok then return false, "delete file error" end
			return true
		elseif isfile and delfile then
			if not isfile(path) then return false, "invalid file" end
			local ok = pcall(delfile, path)
			if not ok then return false, "delete file error" end
			return true
		end

		return false, "no filesystem access"
	end

	-- // UI \\ --

	function ThemeManager:BuildThemeSection(tab, column)
		local section = tab:Section("theme", column or 2)

		local alphas = self.Library.ThemeAlpha or {}
		local defaults = {}
		for _, entry in ipairs(self.Keys) do
			defaults[entry[1]] = Theme[entry[1]]
		end

		local pickers = {}
		local presetBox

		local function syncPickers()
			for key, picker in pairs(pickers) do
				picker:Set(Theme[key], alphas[key] or 1, true)
			end
		end

		presetBox = section:Dropdown({
			Text = "preset",
			Flag = "theme_preset",
			Options = self:Names(),
			Default = self.Current,
			Search = false,
			Callback = function(name)
				if self:Apply(name) then
					syncPickers()
					if self.AutoSave then self:Save() end
				end
			end,
		})

		section:Divider()

		for _, entry in ipairs(self.Keys) do
			local key, label, flagSuffix = entry[1], entry[2], entry[3]
			pickers[key] = section:ColorPicker({
				Text = label,
				Flag = "theme_color_" .. flagSuffix,
				Default = Theme[key],
				DefaultAlpha = alphas[key] or 1,
				Callback = function(color, alpha)
					self.Library:SetColor(key, color, alpha)
					if key == "Accent" then
						self:SetAccent(color)
						syncPickers()
					end
					if self.AutoSave then self:Save() end
				end,
			})
		end

		section:Divider()

		section:ButtonRow({
			{
				Text = "reset colors",
				Callback = function()
					for key, color in pairs(defaults) do
						Theme[key] = color
						alphas[key] = 1
					end
					self.Current = "solitude"
					self.Library:Repaint()
					syncPickers()
					if presetBox then presetBox:Set("solitude", true) end
					if self.AutoSave then self:Save() end
				end,
			},
			{
				Text = "save theme",
				Callback = function()
					local ok = self:Save()
					self.Library:Notify({
						Title = ok and "theme saved" or "theme error",
						Text = ok and "colours saved" or "failed to save",
						Duration = 3,
					})
				end,
			},
		})

		-- // Custom themes \\ --

		section:Divider()
		section:Label("custom themes")

		local customList
		local customNameInput = section:Input({
			Text = "theme name",
			Flag = false,
			Placeholder = "my theme",
			ClearOnFocus = false,
		})

		section:Button({
			Text = "create theme",
			Callback = function()
				local name = customNameInput:Get()
				local ok = self:SaveCustomTheme(name)
				self.Library:Notify({
					Title = ok and "theme created" or "theme error",
					Text = ok and string.format("saved %q", name) or "failed to save theme",
					Duration = 3,
				})
				if ok and customList then
					customList:SetOptions(self:ListCustomThemes())
					customList:Set(name, true)
				end
			end,
		})

		section:Divider()

		customList = section:Dropdown({
			Text = "custom themes",
			Flag = "theme_custom_selected",
			Options = self:ListCustomThemes(),
			AllowNull = true,
			Search = true,
		})

		section:ButtonRow({
			{
				Text = "load theme",
				Callback = function()
					local name = customList:Get()
					if not name or name == "" then return end
					local ok = self:LoadCustomTheme(name)
					syncPickers()
					if presetBox then presetBox:Set(name, true) end
					self.Library:Notify({
						Title = ok and "theme loaded" or "theme error",
						Text = ok and string.format("loaded %q", name) or "failed to load theme",
						Duration = 3,
					})
				end,
			},
			{
				Text = "overwrite theme",
				Callback = function()
					local name = customList:Get()
					if not name or name == "" then return end
					local ok = self:SaveCustomTheme(name)
					self.Library:Notify({
						Title = ok and "theme overwritten" or "theme error",
						Text = ok and string.format("overwrote %q", name) or "failed to overwrite theme",
						Duration = 3,
					})
				end,
			},
		})

		section:ButtonRow({
			{
				Text = "delete theme",
				Callback = function()
					local name = customList:Get()
					local ok, err = self:DeleteCustomTheme(name)
					self.Library:Notify({
						Title = ok and "theme deleted" or "theme error",
						Text = ok and string.format("deleted %q", name) or tostring(err),
						Duration = 3,
					})
					if ok then
						customList:SetOptions(self:ListCustomThemes())
						customList:Set(nil, true)
					end
				end,
			},
			{
				Text = "refresh list",
				Callback = function()
					customList:SetOptions(self:ListCustomThemes())
				end,
			},
		})

		self.Section = section
		self.Pickers = pickers
		self.CustomList = customList
		return section
	end

	return ThemeManager
end