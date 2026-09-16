-- Solitude addon | ThemeManager
-- Presets de couleurs, edition par element, recoloration a chaud, themes custom.

return function(Library)
	local httpService = game:GetService("HttpService")
	local Theme = Library.Theme

	local ThemeManager = {}
	ThemeManager.Library = Library
	ThemeManager.Folder = "Solitude"
	ThemeManager.Flags = { "theme_preset", "theme_accent" }
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

	for _, entry in ipairs(ThemeManager.Keys) do
		table.insert(ThemeManager.Flags, "theme_color_" .. entry[3])
	end

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

	local function toHex(color)
		return string.format("%02x%02x%02x",
			math.floor(color.R * 255 + 0.5),
			math.floor(color.G * 255 + 0.5),
			math.floor(color.B * 255 + 0.5))
	end

	-- builds the full 23-key palette (as Color3s) from a two-tone preset -
	-- same math the old Apply() used, just precomputed once at load time
	local function buildPalette(preset)
		local bg = preset.Bg
		local step = preset.Light and -1 or 1
		local scheme = {}

		scheme.Window = bg
		scheme.TopBar = shade(bg, 5 * step)
		scheme.Section = shade(bg, 3 * step)
		scheme.Group = shade(bg, 8 * step)
		scheme.Field = shade(bg, 14 * step)
		scheme.FieldHover = shade(bg, 22 * step)
		scheme.PopupBg = shade(bg, 12 * step)
		scheme.Track = shade(bg, 32 * step)

		scheme.WindowBorder = shade(bg, 26 * step)
		scheme.SectionBorder = shade(bg, 20 * step)
		scheme.GroupBorder = shade(bg, 28 * step)
		scheme.Border = shade(bg, 34 * step)
		scheme.BorderSoft = shade(bg, 19 * step)
		scheme.PopupBorder = shade(bg, 36 * step)

		if preset.Light then
			scheme.Text = Color3.fromRGB(70, 70, 76)
			scheme.TextDim = Color3.fromRGB(122, 122, 130)
			scheme.TextBright = Color3.fromRGB(24, 24, 28)
			scheme.TextMarked = Color3.fromRGB(158, 132, 30)
			scheme.TextCode = Color3.fromRGB(38, 138, 60)
			scheme.Danger = Color3.fromRGB(196, 58, 58)
		else
			scheme.Text = Color3.fromRGB(174, 174, 178)
			scheme.TextDim = Color3.fromRGB(108, 108, 113)
			scheme.TextBright = Color3.fromRGB(228, 228, 232)
			scheme.TextMarked = Color3.fromRGB(198, 198, 122)
			scheme.TextCode = Color3.fromRGB(96, 200, 96)
			scheme.Danger = Color3.fromRGB(226, 102, 102)
		end

		scheme.Accent = preset.Accent
		scheme.AccentSoft = tint(preset.Accent, 0.78, 1.08)
		scheme.AccentDim = tint(preset.Accent, 0.72, 0.64)

		return scheme
	end

	local function toHexScheme(colorScheme)
		local out = {}
		for key, color in pairs(colorScheme) do
			out[key] = toHex(color)
		end
		return out
	end

	local presetOrder = {
		"solitude", "darker", "typewriter", "aqua",
		"amethyst", "rose", "contrast", "light",
	}

	local presetTones = {
		solitude   = { Bg = Color3.fromRGB(26, 26, 28),    Accent = Color3.fromRGB(158, 188, 242) },
		darker     = { Bg = Color3.fromRGB(16, 16, 16),    Accent = Color3.fromRGB(72, 138, 182) },
		typewriter = { Bg = Color3.fromRGB(34, 34, 34),    Accent = Color3.fromRGB(109, 180, 120) },
		aqua       = { Bg = Color3.fromRGB(14, 22, 22),    Accent = Color3.fromRGB(60, 165, 165) },
		amethyst   = { Bg = Color3.fromRGB(18, 4, 32),     Accent = Color3.fromRGB(177, 51, 255) },
		rose       = { Bg = Color3.fromRGB(30, 18, 22),    Accent = Color3.fromRGB(200, 120, 170) },
		contrast   = { Bg = Color3.fromRGB(0, 0, 0),       Accent = Color3.fromRGB(86, 156, 214) },
		light      = { Bg = Color3.fromRGB(238, 238, 240), Accent = Color3.fromRGB(0, 103, 192), Light = true },
	}

	-- { order, { key = "rrggbb", ... } } - precomputed once, mirrors the
	-- flat-dict shape ElisiumV3 uses for its BuiltInThemes
	ThemeManager.BuiltInThemes = {}
	for index, name in ipairs(presetOrder) do
		ThemeManager.BuiltInThemes[name] = { index, toHexScheme(buildPalette(presetTones[name])) }
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib or Library
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}

		-- build the entire tree if a path is like some-hub/phantom-forces
		-- makefolder builds the entire tree on Synapse X but not other exploits

		local parts = self.Folder:split("/")
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, "/", 1, idx)
		end

		table.insert(paths, self.Folder .. "/themes")

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return false end

		-- custom themes are just plain hex dicts, built-ins are { order, dict }
		local scheme = customThemeData or data[2]

		for key, hex in pairs(scheme) do
			if Theme[key] ~= nil then
				local color = Color3.fromHex(hex)
				self.Library:SetColor(key, color, 1)

				if self.Pickers and self.Pickers[key] then
					self.Pickers[key]:Set(color, 1, true)
				end
			end
		end

		self.Current = theme
		self:ThemeUpdate()
		return true
	end

	function ThemeManager:ThemeUpdate()
		-- recompute the accent-derived shades in case only Accent changed,
		-- then force a repaint - mirrors ElisiumV3's ThemeUpdate()
		local accent = Theme.Accent
		Theme.AccentSoft = tint(accent, 0.78, 1.08)
		Theme.AccentDim = tint(accent, 0.72, 0.64)

		if self.Pickers then
			if self.Pickers.AccentSoft then self.Pickers.AccentSoft:Set(Theme.AccentSoft, 1, true) end
			if self.Pickers.AccentDim then self.Pickers.AccentDim:Set(Theme.AccentDim, 1, true) end
		end

		self.Library:Repaint()
	end

	function ThemeManager:LoadDefault()
		local theme = "solitude"
		local defaultPath = self.Folder .. "/themes/default.txt"
		local content = isfile(defaultPath) and readfile(defaultPath)

		local isDefault = true
		if content and content ~= "" then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false
			end
		end

		if isDefault and self.PresetBox then
			self.PresetBox:Set(theme, true)
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. "/themes/default.txt", theme)
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. "/themes/" .. file .. ".json"
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(httpService.JSONDecode, httpService, data)

		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if type(file) ~= "string" or file:gsub(" ", "") == "" then
			self.Library:Notify({ Title = "theme error", Text = "invalid file name for theme (empty)", Duration = 3 })
			return false
		end

		local scheme = {}
		for _, entry in ipairs(self.Keys) do
			scheme[entry[1]] = toHex(Theme[entry[1]])
		end

		local success, encoded = pcall(httpService.JSONEncode, httpService, scheme)
		if not success then return false end

		writefile(self.Folder .. "/themes/" .. file .. ".json", encoded)
		return true
	end

	function ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. "/themes")

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

	function ThemeManager:DeleteCustomTheme(name)
		if not name then return false, "no theme file is selected" end

		local path = self.Folder .. "/themes/" .. name .. ".json"
		if not isfile(path) then return false, "invalid file" end

		local success = pcall(delfile, path)
		if not success then return false, "delete file error" end

		return true
	end

	function ThemeManager:Names()
		local names = {}
		for index, name in ipairs(presetOrder) do names[index] = name end
		return names
	end

	function ThemeManager:BuildThemeSection(tab, column)
		assert(self.Library, "Must set ThemeManager.Library first!")

		local section = tab:Section("theme", column or 2)

		local defaults = {}
		for _, entry in ipairs(self.Keys) do
			defaults[entry[1]] = Theme[entry[1]]
		end

		local pickers = {}

		local presetBox = section:Dropdown({
			Text = "preset",
			Flag = "theme_preset",
			Options = self:Names(),
			Default = self.Current,
			Search = false,
			Callback = function(name)
				self:ApplyTheme(name)
			end,
		})
		self.PresetBox = presetBox

		section:Divider()

		for _, entry in ipairs(self.Keys) do
			local key, label, flagSuffix = entry[1], entry[2], entry[3]
			pickers[key] = section:ColorPicker({
				Text = label,
				Flag = "theme_color_" .. flagSuffix,
				Default = Theme[key],
				DefaultAlpha = 1,
				Callback = function(color, alpha)
					self.Library:SetColor(key, color, alpha)
					if key == "Accent" then
						self:ThemeUpdate()
					end
				end,
			})
		end
		self.Pickers = pickers

		section:Divider()

		section:ButtonRow({
			{
				Text = "reset colors",
				Callback = function()
					for key, color in pairs(defaults) do
						Theme[key] = color
					end
					self.Current = "solitude"
					self.Library:Repaint()
					for key, picker in pairs(pickers) do
						picker:Set(Theme[key], 1, true)
					end
					presetBox:Set("solitude", true)
				end,
			},
			{
				Text = "set as default",
				Callback = function()
					self:SaveDefault(presetBox:Get())
					self.Library:Notify({ Title = "default theme set", Text = string.format("set default theme to %q", presetBox:Get()), Duration = 3 })
				end,
			},
		})

		section:Divider()
		section:Label("custom themes")

		local nameBox = section:Input({ Text = "custom theme name", Flag = false, Placeholder = "my theme" })
		local customList = section:Dropdown({
			Text = "custom themes",
			Flag = "theme_custom_selected",
			Options = self:ReloadCustomThemes(),
			AllowNull = true,
			Search = true,
		})

		section:ButtonRow({
			{
				Text = "save theme",
				Callback = function()
					local name = nameBox:Get()
					local ok = self:SaveCustomTheme(name)
					self.Library:Notify({
						Title = ok and "theme saved" or "theme error",
						Text = ok and string.format("saved %q", name) or "failed to save theme",
						Duration = 3,
					})
					if ok then
						customList:SetValues(self:ReloadCustomThemes())
						customList:Set(nil, true)
					end
				end,
			},
			{
				Text = "load theme",
				Callback = function()
					local name = customList:Get()
					local ok = self:ApplyTheme(name)
					self.Library:Notify({
						Title = ok and "theme loaded" or "theme error",
						Text = ok and string.format("loaded %q", name) or "failed to load theme",
						Duration = 3,
					})
				end,
			},
		})

		section:ButtonRow({
			{
				Text = "refresh list",
				Callback = function()
					customList:SetValues(self:ReloadCustomThemes())
					customList:Set(nil, true)
				end,
			},
			{
				Text = "set as default",
				Callback = function()
					local name = customList:Get()
					if name and name ~= "" then
						self:SaveDefault(name)
						self.Library:Notify({ Title = "default theme set", Text = string.format("set default theme to %q", name), Duration = 3 })
					end
				end,
			},
		})

		section:Button({
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
					customList:SetValues(self:ReloadCustomThemes())
					customList:Set(nil, true)
				end
			end,
		})

		self:LoadDefault()

		self.Section = section
		self.CustomList = customList
		return section
	end

	ThemeManager:BuildFolderTree()

	return ThemeManager
end
