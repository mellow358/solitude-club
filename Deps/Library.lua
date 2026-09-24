-- 1

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local function GetPlayerGui()
	local player = Players.LocalPlayer
	if not player then
		Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		player = Players.LocalPlayer
	end
	if not player then return nil end
	return player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 10)
end

local function ParentGui(gui)
	local ok = pcall(function()
		if gethui then
			gui.Parent = gethui()
		elseif syn and syn.protect_gui then
			syn.protect_gui(gui)
			gui.Parent = game:GetService("CoreGui")
		else
			gui.Parent = game:GetService("CoreGui")
		end
	end)
	if ok and gui.Parent then return end
	local playerGui = GetPlayerGui()
	if playerGui then
		gui.Parent = playerGui
	else
		gui.Parent = game:GetService("CoreGui")
	end
end

local Theme = {
	Window        = Color3.fromRGB(26, 26, 28),
	WindowAlpha   = 0.012,
	WindowBorder  = Color3.fromRGB(52, 52, 56),
	TopBar        = Color3.fromRGB(31, 31, 34),
	Section       = Color3.fromRGB(29, 29, 32),
	SectionBorder = Color3.fromRGB(46, 46, 50),
	Group         = Color3.fromRGB(34, 34, 37),
	GroupBorder   = Color3.fromRGB(54, 54, 58),
	Field         = Color3.fromRGB(40, 40, 44),
	FieldHover    = Color3.fromRGB(48, 48, 52),
	Border        = Color3.fromRGB(60, 60, 65),
	BorderSoft    = Color3.fromRGB(45, 45, 49),
	PopupBg       = Color3.fromRGB(38, 38, 42),
	PopupBorder   = Color3.fromRGB(62, 62, 67),
	Track         = Color3.fromRGB(58, 58, 62),
	Text          = Color3.fromRGB(174, 174, 178),
	TextDim       = Color3.fromRGB(108, 108, 113),
	TextBright    = Color3.fromRGB(228, 228, 232),
	TextMarked    = Color3.fromRGB(198, 198, 122),
	TextCode      = Color3.fromRGB(96, 200, 96),
	Danger        = Color3.fromRGB(226, 102, 102),
	Accent        = Color3.fromRGB(158, 188, 242),
	AccentSoft    = Color3.fromRGB(179, 203, 255),
	AccentDim     = Color3.fromRGB(119, 132, 163),
	Font          = Enum.Font.Gotham,
	FontMedium    = Enum.Font.GothamMedium,
	TextSize      = 13,
	Radius        = 6,
	GearIcon      = "rbxassetid://6031280882",
}

local function AccentHex()
	return string.format("#%02X%02X%02X",
		math.floor(Theme.Accent.R * 255 + 0.5),
		math.floor(Theme.Accent.G * 255 + 0.5),
		math.floor(Theme.Accent.B * 255 + 0.5))
end

local EASE      = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local EASE_FAST = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Painted = {}
local ThemeAlpha = {}
local ALPHA_PROPS = {
	BackgroundColor3 = "BackgroundTransparency",
	ImageColor3 = "ImageTransparency",
	TextColor3 = "TextTransparency",
	Color = "Transparency",
}
local ThemeIndex = {}
local THEME_ORDER = {
	"Window", "WindowBorder", "TopBar", "Section", "SectionBorder",
	"Group", "GroupBorder", "Field", "FieldHover", "Border", "BorderSoft",
	"PopupBg", "PopupBorder", "Track", "Text", "TextDim", "TextBright",
	"TextMarked", "TextCode", "Danger", "Accent", "AccentSoft", "AccentDim",
}

local function IndexTheme()
	table.clear(ThemeIndex)
	for _, key in ipairs(THEME_ORDER) do
		local value = Theme[key]
		if typeof(value) == "Color3" and ThemeIndex[tostring(value)] == nil then
			ThemeIndex[tostring(value)] = key
		end
	end
end
IndexTheme()

local Library = {}
Library.Theme = Theme
Library.Flags = {}
Library.Windows = {}
Library.Connections = {}
Library.Open = true
Library.ToggleKey = Enum.KeyCode.RightShift
Library.ToggleInput = nil
Library.Binding = false
Library.Registry = {}
Library.Defaults = {}
Library.NotificationsEnabled = true
Library.NotificationLimit = 5
Library.Dirty = false
Library.BaseUrl = "https://raw.githubusercontent.com/mellow358/solitude-club/refs/heads/main/"
Library.AddonPaths = {
	Icons = "Deps/Icons.lua",
	SaveManager = "Deps/SaveManager.lua",
	InterfaceManager = "Deps/InterfaceManager.lua",
	ThemeManager = "Deps/ThemeManager.lua",
}
Library.Addons = {}
Library.Painted = Painted
Library.RepaintHooks = {}

function Library:SafeCallback(label, callback, ...)
	if not callback then return end
	local packed = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(callback, table.unpack(packed, 1, packed.n))
		if ok then return end
		local message = tostring(err)
		local _, cut = string.find(message, ":%d+: ")
		if cut then message = string.sub(message, cut + 1) end
		warn("solitude.club | callback error in '" .. tostring(label) .. "': " .. tostring(err))
		self:Error("callback error", tostring(label) .. " - " .. message, 7)
	end)
end

function Library:OnRepaint(callback)
	table.insert(self.RepaintHooks, callback)
	return callback
end
Library.ThemeAlpha = ThemeAlpha
Library.Version = "2026.09.05-cursor-2"

function Library:LoadAddon(name)
	if self.Addons[name] ~= nil then return self.Addons[name] end

	local module
	local ok, found = pcall(function()
		local root = script and script.Parent
		local folder = root and (root:FindFirstChild("addons") or root:FindFirstChild("Addons"))
		local file = folder and folder:FindFirstChild(name)
		return file and require(file) or nil
	end)
	if ok then module = found end

	if module == nil then
		local path = self.AddonPaths[name]
		if not path then
			warn("solitude.club | unknown addon '" .. tostring(name) .. "'")
			return nil
		end
		local fetched, source = pcall(function() return game:HttpGet(self.BaseUrl .. path) end)
		if fetched and type(source) == "string" and #source > 0 then
			local built, chunk = pcall(loadstring, source)
			if built and type(chunk) == "function" then
				local ran, value = pcall(chunk)
				if ran then module = value end
			end
		end
	end

	if module == nil then
		warn("solitude.club | addon '" .. tostring(name) .. "' unavailable")
		return nil
	end
	if type(module) == "function" then
		module = module(self)
	end
	self.Addons[name] = module
	return module
end

function Library:SetColor(key, color, alpha)
	if typeof(color) ~= "Color3" or Theme[key] == nil then return false end
	Theme[key] = color
	if alpha ~= nil then
		ThemeAlpha[key] = math.clamp(alpha, 0, 1)
	end
	self:Repaint()
	return true
end

function Library:Repaint()
	if #Painted == 0 then
		warn("solitude.club | repaint registry is empty, main.lua is probably outdated")
	end
	IndexTheme()
	for i = #Painted, 1, -1 do
		local entry = Painted[i]
		local ok = pcall(function()
			local instance, property, key = entry[1], entry[2], entry[3]
			instance[property] = Theme[key]

			local alpha = ThemeAlpha[key]
			local transparency = ALPHA_PROPS[property]
			if alpha and transparency and instance[transparency] < 1 then
				instance[transparency] = 1 - alpha
			end
		end)
		if not ok then table.remove(Painted, i) end
	end

	self:RefreshHotkeys()

	for i = #self.RepaintHooks, 1, -1 do
		local ok = pcall(self.RepaintHooks[i])
		if not ok then table.remove(self.RepaintHooks, i) end
	end
end

function Library:Register(flag, entry)
	if self.Registry[flag] then
		warn("solitude.club | duplicate flag '" .. tostring(flag) .. "', the previous element will no longer be saved")
	end
	self.Registry[flag] = entry
	self.Defaults[flag] = entry.Get()
end

function Library:MarkDirty(flag)
	if flag and self.DirtyIgnore and self.DirtyIgnore[flag] then return end
	if self.Dirty then return end
	self.Dirty = true
	if self.OnDirty then task.spawn(self.OnDirty, true) end
end

function Library:ClearDirty()
	self.Dirty = false
	if self.OnDirty then task.spawn(self.OnDirty, false) end
end

function Library:GetConfig(ignore)
	local data = {}
	for flag, entry in pairs(self.Registry) do
		if not (ignore and ignore[flag]) then
			local ok, value = pcall(entry.Get)
			if ok then data[flag] = value end
		end
	end
	return data
end

function Library:LoadConfig(data, ignore)
	for flag, value in pairs(data or {}) do
		local entry = self.Registry[flag]
		if entry and not (ignore and ignore[flag]) then
			pcall(entry.Set, value)
		end
	end
	self:ClearDirty()
end

function Library:CaptureDefaults()
	for flag, entry in pairs(self.Registry) do
		local ok, value = pcall(entry.Get)
		if ok then self.Defaults[flag] = value end
	end
end

function Library:ResetDefaults(ignore)
	self:LoadConfig(self.Defaults, ignore)
end

local function Track(conn)
	table.insert(Library.Connections, conn)
	return conn
end

local function New(class, props, children)
	local inst = Instance.new(class)
	local parent = nil
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			inst[k] = v
			if typeof(v) == "Color3" then
				local key = ThemeIndex[tostring(v)]
				if key then table.insert(Painted, { inst, k, key }) end
			end
		end
	end
	for _, child in ipairs(children or {}) do child.Parent = inst end
	if parent then inst.Parent = parent end
	return inst
end

local function Corner(parent, r)
	return New("UICorner", { CornerRadius = UDim.new(0, r or Theme.Radius), Parent = parent })
end

local function Stroke(parent, color, thickness, transparency)
	return New("UIStroke", {
		Color = color or Theme.Border,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function Pad(parent, t, r, b, l)
	return New("UIPadding", {
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or t or 0),
		PaddingBottom = UDim.new(0, b or t or 0),
		PaddingLeft = UDim.new(0, l or r or t or 0),
		Parent = parent,
	})
end

local function List(parent, padding, dir, sort)
	return New("UIListLayout", {
		FillDirection = dir or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, padding or 0),
		SortOrder = sort or Enum.SortOrder.LayoutOrder,
		Parent = parent,
	})
end

local function Label(parent, text, color, size, font)
	return New("TextLabel", {
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = color or Theme.Text,
		TextSize = size or Theme.TextSize,
		Font = font or Theme.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = true,
		Parent = parent,
	})
end

local function Tween(inst, goal, info)
	local t = TweenService:Create(inst, info or EASE, goal)
	t:Play()
	return t
end

local function Chevron(parent, color)
	local holder = New("Frame", {
		Name = "Chevron",
		Size = UDim2.fromOffset(10, 10),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	for i = 1, 2 do
		local bar = New("Frame", {
			Size = UDim2.fromOffset(7, 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, i == 1 and -2 or 2, 0.5, 0),
			Rotation = i == 1 and 45 or -45,
			BackgroundColor3 = color or Theme.TextDim,
			BorderSizePixel = 0,
			Parent = holder,
		})
		Corner(bar, 1)
	end
	return holder
end

local function KeyName(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then return "MB1" end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then return "MB2" end
	if input.UserInputType == Enum.UserInputType.MouseButton3 then return "MB3" end
	if input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode.Name end
	return nil
end

local function Hover(button, target, baseKey, hoverKey)
	Track(button.MouseEnter:Connect(function()
		Tween(target, { BackgroundColor3 = Theme[hoverKey] }, EASE_FAST)
	end))
	Track(button.MouseLeave:Connect(function()
		Tween(target, { BackgroundColor3 = Theme[baseKey] }, EASE_FAST)
	end))
end

local function BindDrag(target, callback)
	local moveConn, endConn
	Track(target.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		callback(input.Position)
		if moveConn then moveConn:Disconnect() end
		moveConn = UserInputService.InputChanged:Connect(function(move)
			if move.UserInputType == Enum.UserInputType.MouseMovement
				or move.UserInputType == Enum.UserInputType.Touch then
				callback(move.Position)
			end
		end)
		if endConn then endConn:Disconnect() end
		endConn = UserInputService.InputEnded:Connect(function(ended)
			if ended.UserInputType == input.UserInputType then
				if moveConn then moveConn:Disconnect() moveConn = nil end
				if endConn then endConn:Disconnect() endConn = nil end
			end
		end)
	end))
end

local function ToHex(color, alpha)
	return string.format("#%02X%02X%02X%02X",
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5),
		math.floor(math.clamp(alpha or 1, 0, 1) * 255 + 0.5))
end

local function FromHex(text)
	if typeof(text) == "Color3" then return text, 1 end
	if type(text) ~= "string" then return nil end
	local hex = string.gsub(string.gsub(text, "#", ""), "%s", "")
	if #hex ~= 6 and #hex ~= 8 then return nil end
	local r = tonumber(string.sub(hex, 1, 2), 16)
	local g = tonumber(string.sub(hex, 3, 4), 16)
	local b = tonumber(string.sub(hex, 5, 6), 16)
	if not r or not g or not b then return nil end
	local a = 255
	if #hex == 8 then a = tonumber(string.sub(hex, 7, 8), 16) or 255 end
	return Color3.fromRGB(r, g, b), a / 255
end

local HUE_SEQUENCE = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
})

local IconLib, IconTried

function Library:PreloadIcons()
	if IconTried then return IconLib end
	IconTried = true
	local loaded = self:LoadAddon("Icons")
	if type(loaded) == "table" then IconLib = loaded end
	return IconLib
end

local function ResolveIcon(icon)
	if not icon or icon == 0 or icon == "" then return nil end
	if type(icon) == "number" then
		return { Image = "rbxassetid://" .. icon }
	end
	if type(icon) ~= "string" then return nil end
	if string.find(icon, "rbxassetid://") == 1 or string.find(icon, "rbxasset://") == 1 then
		return { Image = icon }
	end
	local lib = Library:PreloadIcons()
	local set = lib and lib["48px"]
	local entry = set and set[string.lower(string.match(icon, "^%s*(.-)%s*$"))]
	if not entry or type(entry[1]) ~= "number" then return nil end
	return {
		Image = "rbxassetid://" .. entry[1],
		RectSize = Vector2.new(entry[2][1], entry[2][2]),
		RectOffset = Vector2.new(entry[3][1], entry[3][2]),
	}
end

local function StyleColor(style, fallback)
	if typeof(style) == "Color3" then return style end
	if type(style) ~= "string" then return fallback end
	style = string.lower(style)
	if style == "normal" or style == "text" then return Theme.Text end
	if style == "dim" or style == "muted" then return Theme.TextDim end
	if style == "bright" or style == "title" then return Theme.TextBright end
	if style == "warning" or style == "warn" or style == "yellow" then return Theme.TextMarked end
	if style == "danger" or style == "error" or style == "red" then return Theme.Danger end
	if style == "success" or style == "green" then return Theme.TextCode end
	if style == "accent" or style == "pink" then return Theme.Accent end
	return fallback
end

local function Disableable(api, parts, opts)
	api.Enabled = true

	function api:SetEnabled(state)
		state = state ~= false
		self.Enabled = state
		for _, inst in ipairs(parts) do
			pcall(function()
				if inst:IsA("UIStroke") then
					inst.Transparency = state and 0 or 0.7
				elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
					inst.ImageTransparency = state and 0 or 0.6
				else
					inst.TextTransparency = state and 0 or 0.6
					if inst:IsA("TextBox") then inst.TextEditable = state end
				end
			end)
		end
		return self
	end

	function api:SetDisabled(state)
		return self:SetEnabled(not state)
	end

	if opts and opts.Disabled then api:SetEnabled(false) end
	return api
end

local function LabelColor(opts, fallback)
	if typeof(opts.Color) == "Color3" then return opts.Color, true end
	local styled = StyleColor(opts.Style, nil)
	if styled then return styled, true end
	return fallback, false
end

local function FlagOf(opts)
	local flag = opts.Flag
	if flag == nil then flag = opts.Text end
	if flag == false then return nil end
	return flag
end

local BuildColorPicker, ColorSwatch

local Elements = {}
Elements.__index = Elements

local function NewContainer(window, frame, float)
	return setmetatable({ Window = window, Container = frame, Float = float }, Elements)
end

function Elements:Divider()
	local d = New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.BorderSoft,
		BorderSizePixel = 0,
		Parent = self.Container,
	})
	return d
end

local function AttachIcon(parent, icon, color, size)
	local resolved = ResolveIcon(icon)
	if not resolved then return nil end
	local image = New("ImageLabel", {
		Size = UDim2.fromOffset(size, size),
		Position = UDim2.fromOffset(0, 1),
		BackgroundTransparency = 1,
		Image = resolved.Image,
		ImageColor3 = color,
		Parent = parent,
	})
	if resolved.RectOffset then image.ImageRectOffset = resolved.RectOffset end
	if resolved.RectSize then image.ImageRectSize = resolved.RectSize end
	return image
end

function Elements:Label(text, opts)
	if typeof(opts) == "Color3" then opts = { Color = opts } end
	opts = opts or {}
	local color = opts.Color or StyleColor(opts.Style, Theme.TextDim)

	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self.Container,
	})

	local icon = AttachIcon(row, opts.Icon, color, 14)
	local inset = icon and 20 or 0

	local l = Label(row, tostring(text or ""), color, opts.TextSize, opts.Font)
	l.Position = UDim2.fromOffset(inset, 0)
	l.Size = UDim2.new(1, -inset, 0, 0)
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.TextWrapped = true
	l.TextYAlignment = Enum.TextYAlignment.Top

	local api = { Instance = row, Text = l, Icon = icon }

	local function syncVisibility()
		if opts.KeepSpace then return end
		row.Visible = l.Text ~= ""
	end

	function api:Set(value)
		l.Text = tostring(value or "")
		syncVisibility()
	end
	function api:SetColor(c)
		l.TextColor3 = c
		if icon then icon.ImageColor3 = c end
	end
	function api:SetStyle(style)
		api:SetColor(StyleColor(style, Theme.TextDim))
	end

	syncVisibility()
	return api
end

function Elements:Paragraph(opts)
	opts = opts or {}
	local accent = StyleColor(opts.Style, Theme.TextBright)
	local styled = type(opts.Style) == "string" and string.lower(opts.Style) ~= "normal"

	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Group,
		BorderSizePixel = 0,
		Parent = self.Container,
	})
	Corner(card, 5)
	local stroke = Stroke(card, styled and accent or Theme.GroupBorder, 1, styled and 0.55 or 0)
	Pad(card, 9, 11)

	local inner = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = card,
	})
	List(inner, 4)

	local head = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = inner,
	})
	local icon = AttachIcon(head, opts.Icon, accent, 15)
	local inset = icon and 21 or 0
	local title = Label(head, opts.Title or "", accent, Theme.TextSize, Theme.FontMedium)
	title.Position = UDim2.fromOffset(inset, 0)
	title.Size = UDim2.new(1, -inset, 0, 0)
	title.AutomaticSize = Enum.AutomaticSize.Y
	title.TextWrapped = true
	title.TextYAlignment = Enum.TextYAlignment.Top

	local body
	if opts.Content then
		body = Label(inner, opts.Content, opts.ContentColor or Theme.TextDim, opts.TextSize or 12)
		body.Size = UDim2.new(1, 0, 0, 0)
		body.AutomaticSize = Enum.AutomaticSize.Y
		body.TextWrapped = true
		body.TextYAlignment = Enum.TextYAlignment.Top
		body.LayoutOrder = 2
	end

	local api = { Instance = card, Title = title, Body = body, Icon = icon }
	function api:Set(newOpts)
		newOpts = newOpts or {}
		if newOpts.Title then title.Text = newOpts.Title end
		if newOpts.Content and body then body.Text = newOpts.Content end
		if newOpts.Style then
			local c = StyleColor(newOpts.Style, Theme.TextBright)
			title.TextColor3 = c
			if icon then icon.ImageColor3 = c end
			stroke.Color = c
		end
	end
	return api
end

local function MakeButton(parent, opts, size, order)
	local state = { Enabled = true }
	local btn = New("TextButton", {
		Size = size or UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = Theme.Field,
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = parent,
	})
	Corner(btn, 5)
	Stroke(btn, Theme.Border)
	local text = Label(btn, opts.Text or "button", (LabelColor(opts, Theme.TextBright)))
	text.Size = UDim2.fromScale(1, 1)
	text.TextXAlignment = Enum.TextXAlignment.Center
	text.TextTruncate = Enum.TextTruncate.AtEnd
	Hover(btn, btn, "Field", "FieldHover")
	Track(btn.Activated:Connect(function()
		if state.Enabled == false then return end
		Library:SafeCallback(opts.Text or "button", opts.Callback)
	end))
	return btn, state, text
end

function Elements:Button(opts)
	opts = opts or {}
	local btn, state, text = MakeButton(self.Container, opts)
	local api = Disableable({ Instance = btn }, { text })
	local baseSetEnabled = api.SetEnabled
	function api:SetEnabled(value)
		state.Enabled = value ~= false
		return baseSetEnabled(self, value)
	end
	if opts.Disabled then api:SetEnabled(false) end
	return api
end

function Elements:ButtonRow(list)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = self.Container,
	})
	List(row, 8, Enum.FillDirection.Horizontal)
	local n = math.max(#list, 1)
	local buttons = {}
	for i, opts in ipairs(list) do
		buttons[i] = MakeButton(row, opts, UDim2.new(1 / n, -(8 * (n - 1)) / n, 1, 0), i)
	end
	return { Instance = row, Buttons = buttons }
end

function Elements:Split(builders)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self.Container,
	})
	local list = List(row, 12, Enum.FillDirection.Horizontal)
	list.SortOrder = Enum.SortOrder.LayoutOrder

	local count = math.max(#builders, 1)
	local columns = {}
	for i = 1, count do
		local frame = New("Frame", {
			Size = UDim2.new(1 / count, -(12 * (count - 1)) / count, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = i,
			Parent = row,
		})
		List(frame, 9)
		columns[i] = NewContainer(self.Window, frame, self.Float)
		if type(builders[i]) == "function" then builders[i](columns[i]) end
	end

	return { Instance = row, Columns = columns }
end

function Elements:Input(opts)
	opts = opts or {}
	local flag = FlagOf(opts)
	local block = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self.Container,
	})
	List(block, 5)
	if opts.Text then
		local cap = Label(block, opts.Text, (LabelColor(opts, Theme.Text)))
		cap.Size = UDim2.new(1, 0, 0, 15)
	end
	local field = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		LayoutOrder = 2,
		Parent = block,
	})
	Corner(field, 5)
	local fStroke = Stroke(field, Theme.Border)
	local box = New("TextBox", {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = opts.Default or "",
		PlaceholderText = opts.Placeholder or "",
		PlaceholderColor3 = Theme.TextDim,
		TextColor3 = Theme.TextBright,
		TextSize = Theme.TextSize,
		Font = Theme.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = field,
	})

	local api = Disableable({ Instance = block, Box = box }, { box }, opts)
	function api:Get() return box.Text end
	function api:Set(value, silent)
		box.Text = tostring(value or "")
		if flag then Library.Flags[flag] = box.Text end
		if not silent then Library:SafeCallback(opts.Text or "input", opts.Callback, box.Text) end
	end

	Track(box.Focused:Connect(function()
		Tween(fStroke, { Color = Theme.Accent }, EASE_FAST)
	end))
	Track(box.FocusLost:Connect(function(enter)
		Tween(fStroke, { Color = Theme.Border }, EASE_FAST)
		if flag then
			Library.Flags[flag] = box.Text
			Library:MarkDirty(flag)
		end
		Library:SafeCallback(opts.Text or "input", opts.Callback, box.Text, enter)
	end))

	if flag then
		Library.Flags[flag] = box.Text
		Library:Register(flag, {
			Type = "Input",
			Get = function() return box.Text end,
			Set = function(v) api:Set(v) end,
		})
	end
	return api
end

local function MakeHint(owner, parent, text, order)
	local mark = Label(parent, "?", Theme.TextDim, 12)
	mark.Size = UDim2.fromOffset(10, 18)
	mark.TextXAlignment = Enum.TextXAlignment.Center
	mark.LayoutOrder = order or 2
	mark.Name = "Hint"

	local window = owner and owner.Window
	local tip

	local function hide()
		if tip then tip:Destroy() tip = nil end
	end

	Track(mark.MouseEnter:Connect(function()
		hide()
		local layer = window and window.Overlay or mark
		tip = New("TextLabel", {
			BackgroundColor3 = Theme.PopupBg,
			Text = text,
			TextColor3 = Theme.TextBright,
			TextSize = 12,
			Font = Theme.Font,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromOffset(210, 0),
			AnchorPoint = Vector2.new(0, 1),
			ZIndex = 340,
			BorderSizePixel = 0,
			Parent = layer,
		})
		Pad(tip, 6, 9)
		Corner(tip, 4)
		Stroke(tip, Theme.PopupBorder)

		if window then
			local scale = math.max(window.Scale.Scale, 0.05)
			local x = (mark.AbsolutePosition.X - window.Main.AbsolutePosition.X) / scale
			local y = (mark.AbsolutePosition.Y - window.Main.AbsolutePosition.Y) / scale
			local width = window.Main.AbsoluteSize.X / scale
			tip.Position = UDim2.fromOffset(math.clamp(x + 14, 8, math.max(width - 218, 8)), y - 4)
		else
			tip.Position = UDim2.new(0, 14, 0, -4)
		end
	end))
	Track(mark.MouseLeave:Connect(hide))
	return mark
end

function Elements:Toggle(opts)
	opts = opts or {}
	local flag = FlagOf(opts)
	local state = opts.Default == true

	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Parent = self.Container,
	})

	local hit = New("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = row,
	})

	local box = New("Frame", {
		Size = UDim2.fromOffset(13, 13),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = row,
	})
	Corner(box, 3)
	local boxStroke = Stroke(box, Theme.Border)

	local labelColor, customLabel = LabelColor(opts, Theme.Text)
	local text = Label(row, opts.Text or "toggle", labelColor)
	text.Position = UDim2.fromOffset(21, 0)
	text.Size = UDim2.new(1, -21, 1, 0)

	local left = New("Frame", {
		Size = UDim2.new(1, -21, 1, 0),
		Position = UDim2.fromOffset(21, 0),
		BackgroundTransparency = 1,
		Parent = row,
	})
	local leftList = List(left, 6, Enum.FillDirection.Horizontal)
	leftList.VerticalAlignment = Enum.VerticalAlignment.Center
	text.Parent = left
	text.Size = UDim2.fromOffset(0, 18)
	text.AutomaticSize = Enum.AutomaticSize.X
	text.Position = UDim2.fromOffset(0, 0)
	text.LayoutOrder = 1
	if opts.Hint then MakeHint(self, left, opts.Hint, 2) end

	local right = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = row,
	})
	local rightList = List(right, 8, Enum.FillDirection.Horizontal)
	rightList.VerticalAlignment = Enum.VerticalAlignment.Center
	rightList.HorizontalAlignment = Enum.HorizontalAlignment.Right

	local owner = self
	local function syncRow()
		local s = math.max(owner.Window.Scale.Scale, 0.05)
		local w = right.AbsoluteSize.X / s
		left.Size = UDim2.new(1, -(21 + (w > 0 and w + 10 or 0)), 1, 0)
	end
	Track(right:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncRow))
	syncRow()

	local pickerCount = 0
	local api = { Instance = row, State = state, Pickers = {} }

	local function render(animate)
		local info = animate and EASE_FAST or TweenInfo.new(0)
		Tween(box, { BackgroundTransparency = state and 0 or 1 }, info)
		Tween(boxStroke, { Color = state and Theme.Accent or Theme.Border }, info)
	end

	function api:Set(value, silent)
		state = value and true or false
		api.State = state
		if flag then
			Library.Flags[flag] = state
			Library:MarkDirty(flag)
		end
		render(true)
		Library:RefreshHotkeys()
		if not silent then Library:SafeCallback(opts.Text or "toggle", opts.Callback, state) end
	end

	Track(hit.Activated:Connect(function()
		if api.Enabled == false then return end
		api:Set(not state)
	end))
	Track(hit.MouseEnter:Connect(function()
		if customLabel then return end
		Tween(text, { TextColor3 = Theme.TextBright }, EASE_FAST)
	end))
	Track(hit.MouseLeave:Connect(function()
		if customLabel then return end
		Tween(text, { TextColor3 = Theme.Text }, EASE_FAST)
	end))

	function api:Keybind(bindOpts)
		bindOpts = bindOpts or {}
		local key = bindOpts.Default
		local pill = New("TextButton", {
			Size = UDim2.new(0, 0, 0, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.Field,
			AutoButtonColor = false,
			Text = "",
			BorderSizePixel = 0,
			LayoutOrder = 20,
			Parent = right,
		})
		Corner(pill, 4)
		Stroke(pill, Theme.Border)
		local pl = Label(pill, "", Theme.TextDim, 12)
		pl.Size = UDim2.new(0, 0, 1, 0)
		pl.AutomaticSize = Enum.AutomaticSize.X
		Pad(pill, 0, 8)

		local bindFlag = bindOpts.Flag
		local listening = false
		local function refresh()
			if listening then
				pl.Text = 'key: <font color="' .. AccentHex() .. '">...</font>'
			elseif key then
				pl.Text = 'key: <font color="' .. AccentHex() .. '">' .. key .. "</font>"
			else
				pl.Text = "key: NONE"
			end
			if bindFlag then
				Library.Flags[bindFlag] = key or ""
				Library:MarkDirty(bindFlag)
			end
			Library:RefreshHotkeys()
		end
		refresh()

		Library:RegisterHotkey(function()
			return {
				Label = opts.Text or "toggle",
				Key = key,
				Active = state,
				Visible = key ~= nil,
			}
		end)

		Library:OnRepaint(refresh)

		if bindFlag then
			Library:Register(bindFlag, {
				Type = "Keybind",
				Get = function() return key or "" end,
				Set = function(v)
					key = (v ~= "" and v) or nil
					listening = false
					refresh()
				end,
			})
		end

		Track(pill.Activated:Connect(function()
			listening = true
			Library.Binding = true
			refresh()
			Tween(pill, { BackgroundColor3 = Theme.FieldHover }, EASE_FAST)
		end))
		Track(pill.MouseButton2Click:Connect(function()
			key = nil
			listening = false
			Library.Binding = false
			refresh()
		end))
		Track(UserInputService.InputBegan:Connect(function(input, gpe)
			local name = KeyName(input)
			if listening then
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					listening = false
					Library.Binding = false
					Tween(pill, { BackgroundColor3 = Theme.Field }, EASE_FAST)
					refresh()
					return
				end
				if input.KeyCode == Enum.KeyCode.Escape then
					key = nil
				elseif name then
					key = name
				else
					return
				end
				listening = false
				Library.Binding = false
				refresh()
				Tween(pill, { BackgroundColor3 = Theme.Field }, EASE_FAST)
				return
			end
			if gpe or not key or name ~= key then return end
			if bindOpts.Mode == "hold" then return end
			api:Set(not state)
		end))
		if bindOpts.Mode == "hold" then
			Track(UserInputService.InputEnded:Connect(function(input)
				if key and KeyName(input) == key then api:Set(false) end
			end))
			Track(UserInputService.InputBegan:Connect(function(input, gpe)
				if not gpe and key and KeyName(input) == key then api:Set(true) end
			end))
		end
		return api
	end

	function api:ColorPicker(pickerOpts)
		pickerOpts = pickerOpts or {}
		pickerCount = pickerCount + 1
		local swatch = ColorSwatch(right, {
			Size = UDim2.fromOffset(24, 13),
			BackgroundColor3 = pickerOpts.Default or Color3.fromRGB(255, 255, 255),
			AutoButtonColor = false,
			Text = "",
			BorderSizePixel = 0,
			LayoutOrder = pickerCount,
			Parent = right,
		})
		local picker = BuildColorPicker(owner, swatch, pickerOpts)
		api.Pickers[pickerCount] = picker
		return api
	end

	function api:Gear(builder)
		local gear = New("ImageButton", {
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			Image = Theme.GearIcon,
			ImageColor3 = Theme.TextDim,
			LayoutOrder = 30,
			Parent = right,
		})
		local panel = owner.Window:CreateFloating(190, false, owner.Float)
		local content = NewContainer(owner.Window, panel.Content, panel)
		if builder then builder(content) end
		Track(gear.MouseEnter:Connect(function()
			Tween(gear, { ImageColor3 = Theme.TextBright }, EASE_FAST)
		end))
		Track(gear.MouseLeave:Connect(function()
			Tween(gear, { ImageColor3 = Theme.TextDim }, EASE_FAST)
		end))
		Track(gear.Activated:Connect(function()
			owner.Window:ToggleFloating(panel, gear)
		end))
		return api
	end

	Disableable(api, { text, boxStroke }, opts)
	Library:OnRepaint(function() render(false) end)

	if flag then
		Library.Flags[flag] = state
		Library:Register(flag, {
			Type = "Toggle",
			Get = function() return state end,
			Set = function(v) api:Set(v == true) end,
		})
	end
	render(false)
	if state then Library:SafeCallback(opts.Text or "toggle", opts.Callback, state) end
	return api
end

function Elements:Dropdown(opts)
	opts = opts or {}
	local flag = FlagOf(opts)
	local values = opts.Options or {}
	local multi = opts.Multi == true
	local selected = multi and (opts.Default or {}) or opts.Default or values[1]

	local block = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self.Container,
	})
	local blockList = List(block, 5)

	local caption
	if opts.Text then
		caption = Label(block, opts.Text, (LabelColor(opts, Theme.Text)))
		caption.Size = UDim2.new(1, 0, 0, 15)
	end

	local button = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = Theme.Field,
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		LayoutOrder = 2,
		Parent = block,
	})
	Corner(button, 5)
	local bStroke = Stroke(button, Theme.Border)
	local value = Label(button, "", Theme.TextBright)
	value.Position = UDim2.fromOffset(10, 0)
	value.Size = UDim2.new(1, -34, 1, 0)
	value.TextTruncate = Enum.TextTruncate.AtEnd
	local chev = Chevron(button, Theme.Text)
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, -10, 0.5, 0)

	local panel = self.Window:CreateFloating(0, true, self.Float)
	local searchField = New("Frame", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Visible = false,
		ZIndex = panel.Frame.ZIndex,
		Parent = panel.Content,
	})
	Corner(searchField, 4)
	Stroke(searchField, Theme.Border)
	local searchBox = New("TextBox", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "search",
		PlaceholderColor3 = Theme.TextDim,
		TextColor3 = Theme.TextBright,
		TextSize = 12,
		Font = Theme.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = panel.Frame.ZIndex,
		Parent = searchField,
	})
	local scroller = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 24),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.AccentDim,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 2,
		ZIndex = panel.Frame.ZIndex,
		Parent = panel.Content,
	})
	List(scroller, 2)

	local api = { Instance = block }
	local rows = {}

	local function display()
		if multi then
			if #selected == 0 then return opts.Empty or "none" end
			return table.concat(selected, ", ")
		end
		return tostring(selected or opts.Empty or "none")
	end

	local function isPicked(v)
		if multi then
			for _, x in ipairs(selected) do if x == v then return true end end
			return false
		end
		return selected == v
	end

	local function refresh()
		value.Text = display()
		for v, row in pairs(rows) do
			local picked = isPicked(v)
			Tween(row.Text, { TextColor3 = picked and Theme.AccentSoft or Theme.Text }, EASE_FAST)
		end
		if flag then
			Library.Flags[flag] = selected
			Library:MarkDirty(flag)
		end
	end

	local function applyFilter()
		local query = searchField.Visible and string.lower(searchBox.Text) or ""
		local shown = 0
		for _, v in ipairs(values) do
			local row = rows[v]
			if row then
				local visible = query == ""
					or string.find(string.lower(tostring(v)), query, 1, true) ~= nil
				row.Button.Visible = visible
				if visible then shown = shown + 1 end
			end
		end
		scroller.Size = UDim2.new(1, 0, 0, math.min(math.max(shown, 1) * 26 - 2, opts.MaxHeight or 154))
	end

	local function build()
		for _, row in pairs(rows) do row.Button:Destroy() end
		searchField.Visible = opts.Search == true or (opts.Search ~= false and #values > 8)
		rows = {}
		for i, v in ipairs(values) do
			local item = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundColor3 = Theme.FieldHover,
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = "",
				BorderSizePixel = 0,
				LayoutOrder = i,
				ZIndex = panel.Frame.ZIndex,
				Parent = scroller,
			})
			Corner(item, 4)
			local il = Label(item, tostring(v), Theme.Text)
			il.Position = UDim2.fromOffset(8, 0)
			il.Size = UDim2.new(1, -16, 1, 0)
			il.ZIndex = panel.Frame.ZIndex
			rows[v] = { Button = item, Text = il }

			Track(item.MouseEnter:Connect(function()
				Tween(item, { BackgroundTransparency = 0.4 }, EASE_FAST)
			end))
			Track(item.MouseLeave:Connect(function()
				Tween(item, { BackgroundTransparency = 1 }, EASE_FAST)
			end))
			Track(item.Activated:Connect(function()
				if multi then
					local found
					for idx, x in ipairs(selected) do if x == v then found = idx break end end
					if found then table.remove(selected, found) else table.insert(selected, v) end
				else
					selected = v
					self.Window:CloseFloating()
				end
				refresh()
				Library:SafeCallback(opts.Text or "dropdown", opts.Callback, selected)
			end))
		end
		applyFilter()
	end

	Track(searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilter))

	panel.OnOpen = function()
		searchBox.Text = ""
		applyFilter()
		Tween(bStroke, { Color = Theme.Accent }, EASE_FAST)
		Tween(chev, { Rotation = 180 }, EASE_FAST)
	end
	panel.OnClose = function()
		Tween(bStroke, { Color = Theme.Border }, EASE_FAST)
		Tween(chev, { Rotation = 0 }, EASE_FAST)
	end

	Track(button.Activated:Connect(function()
		if api.Enabled == false then return end
		self.Window:ToggleFloating(panel, button, true)
	end))
	Hover(button, button, "Field", "FieldHover")

	function api:Set(v, silent)
		selected = v
		refresh()
		if not silent then Library:SafeCallback(opts.Text or "dropdown", opts.Callback, selected) end
	end

	function api:Get()
		return selected
	end

	function api:SetOptions(newValues)
		values = newValues or {}
		build()
		if not multi and not isPicked(selected) then selected = values[1] end
		refresh()
	end

	build()
	refresh()
	Disableable(api, { value, caption }, opts)

	Library:OnRepaint(function()
		refresh()
		local open = false
		for _, panel_ in ipairs(self.Window.FloatStack) do
			if panel_ == panel then open = true break end
		end
		bStroke.Color = open and Theme.Accent or Theme.Border
		for _, bar in ipairs(chev:GetChildren()) do
			if bar:IsA("Frame") then bar.BackgroundColor3 = Theme.TextDim end
		end
	end)

	if flag then
		Library:Register(flag, {
			Type = multi and "MultiDropdown" or "Dropdown",
			Get = function()
				if not multi then return selected end
				local copy = {}
				for i, v in ipairs(selected) do copy[i] = v end
				return copy
			end,
			Set = function(v)
				if multi and type(v) ~= "table" then v = { v } end
				api:Set(v)
			end,
		})
	end
	return api
end

function Elements:Slider(opts)
	opts = opts or {}
	local flag = FlagOf(opts)
	local min = opts.Min or 0
	local max = opts.Max or 100
	local decimals = opts.Decimals or 0
	local value = math.clamp(opts.Default or min, min, max)

	local block = New("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Parent = self.Container,
	})

	local head = New("Frame", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Parent = block,
	})
	local headList = List(head, 8, Enum.FillDirection.Horizontal)
	headList.VerticalAlignment = Enum.VerticalAlignment.Center

	local name = Label(head, opts.Text or "slider", (LabelColor(opts, Theme.Text)))
	name.Size = UDim2.fromOffset(0, 16)
	name.AutomaticSize = Enum.AutomaticSize.X

	local valueLabel = Label(head, "", Theme.TextDim, 12)
	valueLabel.Size = UDim2.fromOffset(0, 16)
	valueLabel.AutomaticSize = Enum.AutomaticSize.X
	valueLabel.LayoutOrder = 2

	local track = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 4),
		Position = UDim2.new(0, 0, 0, 24),
		BackgroundColor3 = Theme.Track,
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		Parent = block,
	})
	Corner(track, 2)
	local fill = New("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
	})
	Corner(fill, 2)
	local knob = New("Frame", {
		Size = UDim2.fromOffset(9, 9),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
	})
	Corner(knob, 5)

	local hit = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 15),
		Position = UDim2.new(0, 0, 0, 16),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = block,
	})

	local api = { Instance = block, Value = value }

	local function format(v)
		if opts.ZeroText and v == min then return opts.ZeroText end
		local s = decimals > 0 and string.format("%." .. decimals .. "f", v) or tostring(math.floor(v + 0.5))
		return s .. (opts.Suffix or "")
	end

	local function render(v, animate)
		local alpha = (max - min) == 0 and 0 or (v - min) / (max - min)
		local info = animate and EASE_FAST or TweenInfo.new(0)
		Tween(fill, { Size = UDim2.fromScale(alpha, 1) }, info)
		Tween(knob, { Position = UDim2.new(alpha, 0, 0.5, 0) }, info)
		valueLabel.Text = format(v)
	end

	function api:Set(v, silent)
		v = math.clamp(v, min, max)
		if opts.Step then v = min + math.floor((v - min) / opts.Step + 0.5) * opts.Step end
		if decimals == 0 then v = math.floor(v + 0.5) end
		value = v
		api.Value = v
		if flag then
			Library.Flags[flag] = v
			Library:MarkDirty(flag)
		end
		render(v, true)
		if not silent then Library:SafeCallback(opts.Text or "slider", opts.Callback, v) end
	end

	local dragging, moveConn, endConn

	local function fromX(x)
		local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		api:Set(min + (max - min) * alpha)
	end

	Track(hit.InputBegan:Connect(function(input)
		if api.Enabled == false then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging = true
		Tween(knob, { Size = UDim2.fromOffset(11, 11) }, EASE_FAST)
		fromX(input.Position.X)
		moveConn = UserInputService.InputChanged:Connect(function(move)
			if move.UserInputType == Enum.UserInputType.MouseMovement
				or move.UserInputType == Enum.UserInputType.Touch then
				if dragging then fromX(move.Position.X) end
			end
		end)
		endConn = UserInputService.InputEnded:Connect(function(ended)
			if ended.UserInputType == input.UserInputType then
				dragging = false
				Tween(knob, { Size = UDim2.fromOffset(9, 9) }, EASE_FAST)
				if moveConn then moveConn:Disconnect() moveConn = nil end
				if endConn then endConn:Disconnect() endConn = nil end
			end
		end)
	end))

	Disableable(api, { name, valueLabel }, opts)

	if flag then
		Library.Flags[flag] = value
		Library:Register(flag, {
			Type = "Slider",
			Get = function() return value end,
			Set = function(v) api:Set(tonumber(v) or min) end,
		})
	end
	render(value, false)
	return api
end

function BuildColorPicker(owner, swatch, opts)
	opts = opts or {}
	local flag = FlagOf(opts)
	local alphaFlag = opts.AlphaFlag
	local useAlpha = opts.Alpha ~= false
	local base = opts.Default or Color3.fromRGB(255, 255, 255)
	local alpha = opts.DefaultAlpha or 1
	local hue, sat, val = base:ToHSV()

	local panel = owner.Window:CreateFloating(198, false, owner.Float)
	local z = panel.Frame.ZIndex

	local area = New("Frame", {
		Size = UDim2.new(1, 0, 0, 106),
		BackgroundTransparency = 1,
		ZIndex = z,
		Parent = panel.Content,
	})

	local sv = New("TextButton", {
		Size = UDim2.new(1, -22, 1, 0),
		BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		ZIndex = z,
		Parent = area,
	})
	Corner(sv, 4)
	local light = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = z,
		Parent = sv,
	})
	Corner(light, 4)
	New("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = light,
	})
	local shade = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = z,
		Parent = sv,
	})
	Corner(shade, 4)
	New("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = shade,
	})
	local svCursor = New("Frame", {
		Size = UDim2.fromOffset(10, 10),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = z + 1,
		Parent = sv,
	})
	Corner(svCursor, 5)
	Stroke(svCursor, Color3.fromRGB(255, 255, 255), 2)

	local hueBar = New("TextButton", {
		Size = UDim2.new(0, 14, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		ZIndex = z,
		Parent = area,
	})
	Corner(hueBar, 4)
	New("UIGradient", { Rotation = 90, Color = HUE_SEQUENCE, Parent = hueBar })
	local hueCursor = New("Frame", {
		Size = UDim2.new(1, 4, 0, 3),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = z + 1,
		Parent = hueBar,
	})
	Corner(hueCursor, 2)

	local alphaBar, alphaCursor, alphaGradient
	if useAlpha then
		local track = New("Frame", {
			Size = UDim2.new(1, 0, 0, 10),
			BackgroundColor3 = Theme.Track,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			ZIndex = z,
			Parent = panel.Content,
		})
		Corner(track, 3)
		alphaBar = New("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = base,
			AutoButtonColor = false,
			Text = "",
			BorderSizePixel = 0,
			ZIndex = z,
			Parent = track,
		})
		Corner(alphaBar, 3)
		alphaGradient = New("UIGradient", {
			Color = ColorSequence.new(base),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			}),
			Parent = alphaBar,
		})
		alphaCursor = New("Frame", {
			Size = UDim2.new(0, 3, 1, 4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = z + 1,
			Parent = alphaBar,
		})
		Corner(alphaCursor, 2)
	end

	local hexField = New("Frame", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		LayoutOrder = 3,
		ZIndex = z,
		Parent = panel.Content,
	})
	Corner(hexField, 4)
	local hexStroke = Stroke(hexField, Theme.Border)
	local hexBox = New("TextBox", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		BackgroundTransparency = 1,
		Text = ToHex(base, alpha),
		TextColor3 = Theme.TextBright,
		TextSize = 12,
		Font = Theme.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = z,
		Parent = hexField,
	})

	local api = { Instance = swatch, Swatch = swatch, Color = base, Alpha = alpha }
	local editing = false

	local function current()
		return Color3.fromHSV(hue, sat, val)
	end

	local function render()
		local color = current()
		api.Color = color
		api.Alpha = alpha
		sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		svCursor.Position = UDim2.fromScale(sat, 1 - val)
		hueCursor.Position = UDim2.new(0.5, 0, hue, 0)
		swatch.BackgroundColor3 = color
		swatch.BackgroundTransparency = useAlpha and (1 - alpha) * 0.75 or 0
		if alphaGradient then
			alphaGradient.Color = ColorSequence.new(color)
			alphaCursor.Position = UDim2.new(alpha, 0, 0.5, 0)
		end
		if not editing then hexBox.Text = ToHex(color, alpha) end
		if flag then
			Library.Flags[flag] = color
			Library:MarkDirty(flag)
		end
		if alphaFlag then
			Library.Flags[alphaFlag] = alpha
			Library:MarkDirty(alphaFlag)
		end
	end

	local function fire()
		Library:SafeCallback(opts.Text or "color picker", opts.Callback, current(), alpha)
	end

	function api:Set(color, newAlpha, silent)
		local parsed, parsedAlpha = FromHex(color)
		if parsed then
			color = parsed
			newAlpha = newAlpha or parsedAlpha
		end
		if typeof(color) == "Color3" then
			hue, sat, val = color:ToHSV()
		end
		if newAlpha then alpha = math.clamp(newAlpha, 0, 1) end
		render()
		if not silent then fire() end
	end

	function api:Get()
		return current(), alpha
	end

	BindDrag(sv, function(position)
		sat = math.clamp((position.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
		val = 1 - math.clamp((position.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
		render()
		fire()
	end)

	BindDrag(hueBar, function(position)
		hue = math.clamp((position.Y - hueBar.AbsolutePosition.Y) / math.max(hueBar.AbsoluteSize.Y, 1), 0, 1)
		render()
		fire()
	end)

	if alphaBar then
		BindDrag(alphaBar, function(position)
			alpha = math.clamp((position.X - alphaBar.AbsolutePosition.X) / math.max(alphaBar.AbsoluteSize.X, 1), 0, 1)
			render()
			fire()
		end)
	end

	Track(hexBox.Focused:Connect(function()
		editing = true
		Tween(hexStroke, { Color = Theme.Accent }, EASE_FAST)
	end))
	Track(hexBox.FocusLost:Connect(function()
		editing = false
		Tween(hexStroke, { Color = Theme.Border }, EASE_FAST)
		local parsed, parsedAlpha = FromHex(hexBox.Text)
		if parsed then
			api:Set(parsed, parsedAlpha)
		else
			render()
		end
	end))

	Track(swatch.Activated:Connect(function()
		if api.Enabled == false then return end
		owner.Window:ToggleFloating(panel, swatch)
	end))

	Disableable(api, {}, opts)
	Library:OnRepaint(render)

	if flag then
		Library.Flags[flag] = base
		Library:Register(flag, {
			Type = "ColorPicker",
			Get = function() return ToHex(current(), alpha) end,
			Set = function(v) api:Set(v) end,
		})
	end

	if alphaFlag then
		Library.Flags[alphaFlag] = alpha
		Library:Register(alphaFlag, {
			Type = "ColorPickerAlpha",
			Get = function() return alpha end,
			Set = function(v)
				if typeof(v) == "number" then
					api:Set(current(), v)
				end
			end,
		})
	end

	render()
	return api
end

function ColorSwatch(parent, props)
	local swatch = New("TextButton", props)
	Corner(swatch, 3)
	Stroke(swatch, Theme.Border)
	return swatch
end

function Elements:ColorPicker(opts)
	opts = opts or {}
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Parent = self.Container,
	})
	local name = Label(row, opts.Text or "color", (LabelColor(opts, Theme.Text)))
	name.Size = UDim2.new(1, -36, 1, 0)

	local swatch = ColorSwatch(row, {
		Size = UDim2.fromOffset(28, 14),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = opts.Default or Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		Parent = row,
	})

	local api = BuildColorPicker(self, swatch, opts)
	api.Instance = row
	return api
end

function Elements:Keybind(opts)
	opts = opts or {}
	local flag = FlagOf(opts)
	local key = opts.Default
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Parent = self.Container,
	})
	local name = Label(row, opts.Text or "keybind", (LabelColor(opts, Theme.Text)))
	name.Size = UDim2.new(1, -80, 1, 0)

	local pill = New("TextButton", {
		Size = UDim2.new(0, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Theme.Field,
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		Parent = row,
	})
	Corner(pill, 4)
	Stroke(pill, Theme.Border)
	Pad(pill, 0, 8)
	local pl = Label(pill, "", Theme.TextDim, 12)
	pl.Size = UDim2.new(0, 0, 1, 0)
	pl.AutomaticSize = Enum.AutomaticSize.X

	local api
	local listening = false
	local held = false
	local active = opts.Default == true
	local mode = string.lower(opts.Mode or "press")
	local isToggle = mode == "toggle"

	local function refresh()
		if listening then
			pl.Text = 'key: <font color="' .. AccentHex() .. '">...</font>'
		elseif key then
			pl.Text = 'key: <font color="' .. AccentHex() .. '">' .. key .. "</font>"
		else
			pl.Text = "key: NONE"
		end
	end
	refresh()

	local function apply()
		if flag then
			Library.Flags[flag] = key or ""
			Library:MarkDirty(flag)
		end
		Library:RefreshHotkeys()
		Library:SafeCallback(opts.Text or "keybind", opts.OnChanged, key)
	end

	Track(pill.Activated:Connect(function()
		if api and api.Enabled == false then return end
		listening = true
		Library.Binding = true
		refresh()
		Tween(pill, { BackgroundColor3 = Theme.FieldHover }, EASE_FAST)
	end))
	Track(pill.MouseButton2Click:Connect(function()
		key = nil
		listening = false
		Library.Binding = false
		refresh()
		apply()
	end))
	Track(UserInputService.InputBegan:Connect(function(input, gpe)
		local n = KeyName(input)
		if listening then
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				listening = false
				Library.Binding = false
				refresh()
				Tween(pill, { BackgroundColor3 = Theme.Field }, EASE_FAST)
				return
			end
			if input.KeyCode == Enum.KeyCode.Escape then
				key = nil
			elseif n then
				key = n
			else
				return
			end
			listening = false
			Library.Binding = false
			refresh()
			Tween(pill, { BackgroundColor3 = Theme.Field }, EASE_FAST)
			apply()
			return
		end
		if gpe or not key or n ~= key then return end
		if api and api.Enabled == false then return end
		if isToggle then
			active = not active
			if api then api.Active = active end
			Library:RefreshHotkeys()
			Library:SafeCallback(opts.Text or "keybind", opts.Callback, active)
		else
			held = true
			Library:RefreshHotkeys()
			Library:SafeCallback(opts.Text or "keybind", opts.Callback, true)
		end
	end))
	Track(UserInputService.InputEnded:Connect(function(input)
		if isToggle or not held then return end
		if key and KeyName(input) == key then
			held = false
			Library:RefreshHotkeys()
			Library:SafeCallback(opts.Text or "keybind", opts.Callback, false)
		end
	end))

	api = {
		Instance = row,
		Active = active,
		Get = function() return key or "" end,
		Set = function(_, k)
			key = (k ~= "" and k) or nil
			refresh()
			apply()
		end,
	}

	Disableable(api, { name, pl }, opts)

	Library:RegisterHotkey(function()
		return {
			Label = opts.Text or "keybind",
			Key = key,
			Active = isToggle and active or held,
			Visible = key ~= nil and (isToggle or held),
		}
	end)

	Library:OnRepaint(refresh)

	if flag then
		Library.Flags[flag] = key or ""
		Library:Register(flag, {
			Type = "Keybind",
			Get = function() return key or "" end,
			Set = function(v) api:Set(v) end,
		})
	end
	if key then apply() end
	return api
end

function Elements:Search(opts)
	opts = opts or {}
	local flag = opts.Flag or nil
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = self.Container,
	})
	local field = New("Frame", {
		Size = UDim2.new(1, -56, 1, 0),
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		Parent = row,
	})
	Corner(field, 5)
	local fStroke = Stroke(field, Theme.Border)
	local box = New("TextBox", {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = opts.Default or "",
		PlaceholderText = opts.Placeholder or "",
		PlaceholderColor3 = Theme.TextDim,
		TextColor3 = Theme.TextBright,
		TextSize = Theme.TextSize,
		Font = Theme.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = field,
	})
	local side = Label(row, opts.Label or "search", Theme.TextDim)
	side.AnchorPoint = Vector2.new(1, 0.5)
	side.Position = UDim2.new(1, 0, 0.5, 0)
	side.Size = UDim2.fromOffset(48, 18)
	side.TextXAlignment = Enum.TextXAlignment.Right

	Track(box.Focused:Connect(function()
		Tween(fStroke, { Color = Theme.Accent }, EASE_FAST)
	end))
	Track(box.FocusLost:Connect(function(enter)
		Tween(fStroke, { Color = Theme.Border }, EASE_FAST)
		Library:SafeCallback(opts.Text or "input", opts.Callback, box.Text, enter)
	end))
	if opts.Live then
		Track(box:GetPropertyChangedSignal("Text"):Connect(function()
			Library:SafeCallback(opts.Text or "search", opts.Callback, box.Text, false)
		end))
	end

	local api = Disableable({
		Instance = row,
		Box = box,
		Get = function() return box.Text end,
		Set = function(_, v) box.Text = tostring(v or "") end,
	}, { box, side }, opts)
	if flag then
		Library.Flags[flag] = box.Text
		Library:Register(flag, {
			Type = "Input",
			Get = function() return box.Text end,
			Set = function(v)
				box.Text = tostring(v or "")
				Library:SafeCallback(opts.Text or "search", opts.Callback, box.Text, false)
			end,
		})
	end
	return api
end

local Section = setmetatable({}, { __index = Elements })
Section.__index = Section

local function CreateSection(window, parent, title, order)
	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = parent,
	})
	Corner(frame, 7)
	Stroke(frame, Theme.SectionBorder)
	Pad(frame, 12, 14, 14, 14)
	local frameList = List(frame, 0)

	local header = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = frame,
	})
	local htitle = Label(header, title, Theme.TextBright, Theme.TextSize + 1, Theme.FontMedium)
	htitle.Size = UDim2.new(1, -16, 1, 0)
	local hchev = Chevron(header, Theme.TextDim)
	hchev.AnchorPoint = Vector2.new(0, 0.5)
	hchev.Position = UDim2.new(0, htitle.TextBounds.X + 6, 0.5, 1)
	Track(htitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		hchev.Position = UDim2.new(0, htitle.TextBounds.X + 6, 0.5, 1)
	end))

	local body = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		LayoutOrder = 2,
		Parent = frame,
	})
	local content = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = body,
	})
	List(content, 9)
	Pad(content, 6, 0, 0, 0)

	local self = setmetatable(NewContainer(window, content), Section)
	self.Frame = frame
	self.Open = true

	Track(header.Activated:Connect(function()
		self.Open = not self.Open
		body.ClipsDescendants = true
		if self.Open then
			body.Visible = true
			body.Size = UDim2.new(1, 0, 0, 0)
			local target = content.AbsoluteSize.Y / window.Scale.Scale
			Tween(body, { Size = UDim2.new(1, 0, 0, target) }).Completed:Once(function()
				if self.Open then
					body.AutomaticSize = Enum.AutomaticSize.Y
					body.ClipsDescendants = false
				end
			end)
			Tween(hchev, { Rotation = 0 }, EASE_FAST)
		else
			local current = body.AbsoluteSize.Y / window.Scale.Scale
			body.AutomaticSize = Enum.AutomaticSize.None
			body.Size = UDim2.new(1, 0, 0, current)
			Tween(body, { Size = UDim2.new(1, 0, 0, 0) }).Completed:Once(function()
				if not self.Open then body.Visible = false end
			end)
			Tween(hchev, { Rotation = 180 }, EASE_FAST)
		end
		window:CloseFloating()
	end))
	Track(header.MouseEnter:Connect(function()
		Tween(htitle, { TextColor3 = Theme.AccentSoft }, EASE_FAST)
	end))
	Track(header.MouseLeave:Connect(function()
		Tween(htitle, { TextColor3 = Theme.TextBright }, EASE_FAST)
	end))

	return self
end

local Column = {}
Column.__index = Column

function Column:Section(title)
	self.Order = self.Order + 1
	return CreateSection(self.Window, self.Frame, title, self.Order)
end

local Tab = {}
Tab.__index = Tab

function Tab:Block()
	if self.CurrentBlock then return self.CurrentBlock end

	self.Order = self.Order + 1
	local block = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = self.Order,
		Parent = self.Page,
	})
	local list = List(block, 14, Enum.FillDirection.Horizontal)
	list.SortOrder = Enum.SortOrder.LayoutOrder

	self.Columns = {}
	for i = 1, 2 do
		local frame = New("Frame", {
			Size = UDim2.new(0.5, -7, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = i,
			Parent = block,
		})
		List(frame, 14)
		self.Columns[i] = setmetatable({ Window = self.Window, Frame = frame, Order = 0 }, Column)
	end

	self.CurrentBlock = block
	return block
end

function Tab:Column(index)
	self:Block()
	return self.Columns[index or 1]
end

function Tab:Full(title)
	self.Order = self.Order + 1
	local section = CreateSection(self.Window, self.Page, title, self.Order)
	self.CurrentBlock = nil
	return section
end

function Tab:Section(title, columnIndex)
	if columnIndex == "full" or columnIndex == 0 then
		return self:Full(title)
	end
	return self:Column(columnIndex or 1):Section(title)
end

local Window = {}
Window.__index = Window

function Window:CreateFloating(width, matchAnchor, parent)
	local depth = parent and (parent.Depth + 1) or 1
	local z = 118 + depth * 4
	local frame = New("Frame", {
		Size = UDim2.fromOffset(width > 0 and width or 160, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.PopupBg,
		BorderSizePixel = 0,
		Visible = false,
		Active = true,
		ZIndex = z,
		Parent = self.Overlay,
	})
	Corner(frame, 5)
	Stroke(frame, matchAnchor and Theme.Accent or Theme.PopupBorder)
	Pad(frame, 6)
	local content = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = z,
		Parent = frame,
	})
	List(content, 6)
	return { Frame = frame, Content = content, MatchAnchor = matchAnchor, Parent = parent, Depth = depth }
end

function Window:CloseFloatingFrom(depth)
	local stack = self.FloatStack
	while #stack > 0 and stack[#stack].Depth >= depth do
		local panel = table.remove(stack)
		panel.Frame.Visible = false
		if panel.OnClose then panel.OnClose() end
	end
	self.Blocker.Visible = #stack > 0
end

function Window:CloseFloating()
	self:CloseFloatingFrom(1)
end

function Window:ToggleFloating(panel, anchor, matchWidth)
	for _, open in ipairs(self.FloatStack) do
		if open == panel then
			self:CloseFloatingFrom(panel.Depth)
			return
		end
	end
	self:CloseFloatingFrom(panel.Depth)

	local scale = self.Scale.Scale
	local originX = (anchor.AbsolutePosition.X - self.Main.AbsolutePosition.X) / scale
	local originY = (anchor.AbsolutePosition.Y - self.Main.AbsolutePosition.Y) / scale
	local height = anchor.AbsoluteSize.Y / scale

	if matchWidth then
		panel.Frame.Size = UDim2.fromOffset(anchor.AbsoluteSize.X / scale, 0)
	end
	panel.Frame.Position = UDim2.fromOffset(originX, originY + height + 4)
	panel.Frame.Visible = true
	table.insert(self.FloatStack, panel)
	self.Blocker.Visible = true
	if panel.OnOpen then panel.OnOpen() end

	local target = panel.Frame.Position
	panel.Frame.Position = target - UDim2.fromOffset(0, 4)
	Tween(panel.Frame, { Position = target }, EASE_FAST)
end

function Window:Tab(name, icon)
	local opts = type(name) == "table" and name or { Title = name, Icon = icon }
	local title = opts.Title or opts.Text or "tab"

	local page = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.AccentDim,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		Visible = false,
		Parent = self.Body,
	})
	local pageList = List(page, 14)
	pageList.SortOrder = Enum.SortOrder.LayoutOrder
	Pad(page, 2, 8, 2, 8)

	local tab = setmetatable({
		Window = self,
		Page = page,
		Columns = {},
		Name = title,
		Order = 0,
	}, Tab)

	local side = self.TabStyle == "side"

	local button = New("TextButton", {
		Size = side and UDim2.new(1, 0, 0, 30) or UDim2.new(0, 0, 1, 0),
		AutomaticSize = (not side) and Enum.AutomaticSize.X or Enum.AutomaticSize.None,
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = self:NextTabOrder(),
		Parent = self.TabBar,
	})
	if side then Corner(button, 5) end

	local row = New("Frame", {
		Size = side and UDim2.new(1, -20, 1, 0) or UDim2.new(0, 0, 1, 0),
		Position = side and UDim2.fromOffset(10, 0) or UDim2.fromOffset(0, 0),
		AutomaticSize = (not side) and Enum.AutomaticSize.X or Enum.AutomaticSize.None,
		BackgroundTransparency = 1,
		Parent = button,
	})
	local rowList = List(row, 7, Enum.FillDirection.Horizontal)
	rowList.VerticalAlignment = Enum.VerticalAlignment.Center

	local icon = AttachIcon(row, opts.Icon, Theme.TextDim, 15)
	if icon then
		icon.Position = UDim2.fromOffset(0, 0)
		icon.LayoutOrder = 1
	end

	local label = Label(row, title, Theme.TextDim, Theme.TextSize + 1)
	label.Size = side and UDim2.new(1, icon and -22 or 0, 1, 0) or UDim2.new(0, 0, 1, 0)
	label.AutomaticSize = (not side) and Enum.AutomaticSize.X or Enum.AutomaticSize.None
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.LayoutOrder = 2

	tab.Button = button
	tab.Label = label
	tab.Icon = icon

	function tab:SetActive(active, animate)
		local info = animate and EASE_FAST or TweenInfo.new(0)
		local color = active and Theme.Accent or Theme.TextDim
		Tween(label, { TextColor3 = color }, info)
		if icon then Tween(icon, { ImageColor3 = color }, info) end
		if side then
			Tween(button, { BackgroundTransparency = active and 0 or 1 }, info)
		end
	end

	table.insert(self.Tabs, tab)

	Library:OnRepaint(function()
		tab:SetActive(self.ActiveTab == tab, false)
	end)

	Track(button.Activated:Connect(function()
		self:SetTab(tab)
	end))
	Track(button.MouseEnter:Connect(function()
		if self.ActiveTab == tab then return end
		Tween(label, { TextColor3 = Theme.Text }, EASE_FAST)
		if icon then Tween(icon, { ImageColor3 = Theme.Text }, EASE_FAST) end
		if side then Tween(button, { BackgroundTransparency = 0.55 }, EASE_FAST) end
	end))
	Track(button.MouseLeave:Connect(function()
		if self.ActiveTab == tab then return end
		Tween(label, { TextColor3 = Theme.TextDim }, EASE_FAST)
		if icon then Tween(icon, { ImageColor3 = Theme.TextDim }, EASE_FAST) end
		if side then Tween(button, { BackgroundTransparency = 1 }, EASE_FAST) end
	end))
	Track(page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:CloseFloating()
	end))

	if not self.ActiveTab then self:SetTab(tab) end
	return tab
end

function Window:NextTabOrder()
	self.TabOrder = (self.TabOrder or 0) + 1
	return self.TabOrder
end

function Window:TabDivider(opts)
	if self.TabStyle ~= "side" then return nil end
	opts = opts or {}

	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, opts.Height or 11),
		BackgroundTransparency = 1,
		LayoutOrder = self:NextTabOrder(),
		Parent = self.TabBar,
	})

	local inset = opts.Inset or 12
	local line = New("Frame", {
		Size = UDim2.new(1, -inset * 2, 0, 1),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, inset, 0.5, 0),
		BackgroundColor3 = Theme.BorderSoft,
		BorderSizePixel = 0,
		Parent = holder,
	})

	if opts.Text then
		holder.Size = UDim2.new(1, 0, 0, opts.Height or 24)
		line:Destroy()
		local label = Label(holder, opts.Text, Theme.TextDim, Theme.TextSize - 2)
		label.Position = UDim2.fromOffset(inset, 0)
		label.Size = UDim2.new(1, -inset * 2, 1, 0)
		label.TextYAlignment = Enum.TextYAlignment.Bottom
		return { Instance = holder, Label = label }
	end

	return { Instance = holder, Line = line }
end

function Window:SetTab(tab)
	if type(tab) == "string" then
		for _, t in ipairs(self.Tabs) do
			if t.Name == tab then tab = t break end
		end
	end
	if self.ActiveTab == tab then return end
	self:CloseFloating()
	if self.ActiveTab then
		self.ActiveTab.Page.Visible = false
		self.ActiveTab:SetActive(false, true)
	end
	self.ActiveTab = tab
	tab.Page.Visible = true
	tab.Page.Position = UDim2.fromOffset(0, 6)
	Tween(tab.Page, { Position = UDim2.fromOffset(0, 0) })
	tab:SetActive(true, true)
end

function Window:Action(text, callback)
	local btn = New("TextButton", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = text,
		TextColor3 = Theme.Accent,
		TextSize = Theme.TextSize,
		Font = Theme.FontMedium,
		Parent = self.Footer,
	})
	Track(btn.MouseEnter:Connect(function()
		Tween(btn, { TextColor3 = Theme.AccentSoft }, EASE_FAST)
	end))
	Track(btn.MouseLeave:Connect(function()
		Tween(btn, { TextColor3 = Theme.Accent }, EASE_FAST)
	end))
	Track(btn.Activated:Connect(function()
		Library:SafeCallback("action", callback)
	end))
	return btn
end

function Window:SetUserScale(value)
	self.UserScale = math.clamp(tonumber(value) or 1, 0.6, 1.4)
	if self.Refit then self.Refit() end
	return self.UserScale
end

function Window:SetOpacity(alpha)
	self.Opacity = math.clamp(tonumber(alpha) or 1, 0.2, 1)
	self.Main.BackgroundTransparency = 1 - self.Opacity
	return self.Opacity
end

function Window:SetSize(width, height)
	self.Width = math.max(width, self.MinWidth)
	self.Height = math.max(height, self.MinHeight)
	self.Main.Size = UDim2.fromOffset(self.Width, self.Height)
	if self.Refit then self.Refit() end
end

function Window:IconAction(icon, callback, order)
	if not self.FooterLeft then return nil end

	local button = New("ImageButton", {
		Size = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		ImageColor3 = Theme.TextDim,
		LayoutOrder = order or 1,
		Parent = self.FooterLeft,
	})

	local resolved = ResolveIcon(icon)
	if resolved then
		button.Image = resolved.Image
		if resolved.RectOffset then button.ImageRectOffset = resolved.RectOffset end
		if resolved.RectSize then button.ImageRectSize = resolved.RectSize end
	end

	Track(button.MouseEnter:Connect(function()
		Tween(button, { ImageColor3 = Theme.Accent }, EASE_FAST)
	end))
	Track(button.MouseLeave:Connect(function()
		Tween(button, { ImageColor3 = Theme.TextDim }, EASE_FAST)
	end))
	Track(button.Activated:Connect(function()
		Library:SafeCallback("action", callback)
	end))

	return button
end

function Window:Modal(opts)
	opts = opts or {}
	local window = self

	local root = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 200,
		Parent = self.Main,
	})

	local scrim = New("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 200,
		Parent = root,
	})
	Corner(scrim, 10)

	local card = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = (opts.Height and opts.Height > 1)
			and UDim2.fromOffset(opts.Width or 340, opts.Height)
			or UDim2.new(0, opts.Width or 340, opts.Height or 0.78, 0),
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 210,
		Parent = root,
	})
	Corner(card, 10)
	Stroke(card, Theme.WindowBorder)
	local cardScale = New("UIScale", { Parent = card })

	local header = New("Frame", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		ZIndex = 210,
		Parent = card,
	})
	local heading = Label(header, opts.Title or "panel", Theme.TextBright, 14, Theme.FontMedium)
	heading.Position = UDim2.fromOffset(14, 0)
	heading.Size = UDim2.new(1, -48, 1, 0)
	heading.ZIndex = 210

	local close = New("TextButton", {
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 210,
		Parent = header,
	})
	local closeBars = {}
	for i = 1, 2 do
		local bar = New("Frame", {
			Size = UDim2.fromOffset(13, 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = i == 1 and 45 or -45,
			BackgroundColor3 = Theme.TextDim,
			BorderSizePixel = 0,
			ZIndex = 210,
			Parent = close,
		})
		Corner(bar, 1)
		closeBars[i] = bar
	end

	New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 38),
		BackgroundColor3 = Theme.BorderSoft,
		BorderSizePixel = 0,
		ZIndex = 210,
		Parent = card,
	})

	local scroller = New("ScrollingFrame", {
		Size = UDim2.new(1, -16, 1, -50),
		Position = UDim2.fromOffset(8, 45),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.AccentDim,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		ZIndex = 210,
		Parent = card,
	})
	List(scroller, 9)
	Pad(scroller, 4, 10, 8, 6)

	local api = {
		Root = root,
		Frame = card,
		Scroller = scroller,
		Content = NewContainer(self, scroller),
		Open = false,
	}

	local function setBlur(state)
		if state then
			if api.Blur then return end
			pcall(function()
				local blur = Instance.new("BlurEffect")
				blur.Name = "SolitudeModalBlur"
				blur.Size = 0
				blur.Parent = Lighting
				api.Blur = blur
				Tween(blur, { Size = opts.Blur or 16 })
			end)
		elseif api.Blur then
			local blur = api.Blur
			api.Blur = nil
			pcall(function()
				Tween(blur, { Size = 0 }).Completed:Once(function()
					blur:Destroy()
				end)
			end)
		end
	end

	function api:SetOpen(state)
		if state == self.Open then return end
		self.Open = state
		if state then
			window:CloseFloating()
			root.Visible = true
			scrim.BackgroundTransparency = 1
			cardScale.Scale = 0.96
			Tween(scrim, { BackgroundTransparency = opts.Dim or 0.25 })
			Tween(cardScale, { Scale = 1 })
			setBlur(true)
		else
			window:CloseFloating()
			Tween(scrim, { BackgroundTransparency = 1 })
			Tween(cardScale, { Scale = 0.96 }).Completed:Once(function()
				if not api.Open then root.Visible = false end
			end)
			setBlur(false)
			if api.OnClose then task.spawn(api.OnClose) end
		end
	end

	function api:Toggle()
		self:SetOpen(not self.Open)
	end

	Track(scrim.Activated:Connect(function() api:SetOpen(false) end))
	Track(close.Activated:Connect(function() api:SetOpen(false) end))
	Track(close.MouseEnter:Connect(function()
		for _, bar in ipairs(closeBars) do Tween(bar, { BackgroundColor3 = Theme.Danger }, EASE_FAST) end
	end))
	Track(close.MouseLeave:Connect(function()
		for _, bar in ipairs(closeBars) do Tween(bar, { BackgroundColor3 = Theme.TextDim }, EASE_FAST) end
	end))
	Track(UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and api.Open and input.KeyCode == Enum.KeyCode.Escape then
			api:SetOpen(false)
		end
	end))

	self.Modals = self.Modals or {}
	table.insert(self.Modals, api)
	return api
end

function Window:Confirm(opts)
	opts = opts or {}

	local modal = self:Modal({
		Title = opts.Title or "confirm",
		Width = opts.Width or 280,
		Height = opts.Height or 150,
		Dim = opts.Dim or 0.45,
		Blur = opts.Blur or 10,
	})

	local content = modal.Content
	content:Label(opts.Text or "are you sure?", { Style = "text" })

	modal.Scroller.Size = UDim2.new(1, -16, 1, -95)

	local answered = false
	local function answer(callback)
		answered = true
		modal:SetOpen(false)
		Library:SafeCallback("action", callback)
	end

	local footer = New("Frame", {
		Size = UDim2.new(1, -24, 0, 30),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, -12),
		BackgroundTransparency = 1,
		ZIndex = modal.Frame.ZIndex,
		Parent = modal.Frame,
	})
	local footerContainer = NewContainer(self, footer)
	footerContainer:ButtonRow({
		{
			Text = opts.Confirm or "save",
			Callback = function() answer(opts.OnConfirm) end,
		},
		{
			Text = opts.Cancel or "discard",
			Callback = function() answer(opts.OnCancel) end,
		},
	})

	modal.OnClose = function()
		if not answered and opts.OnDismiss then task.spawn(opts.OnDismiss) end
		answered = false
	end

	modal:SetOpen(true)
	return modal
end

function Window:SetVisible(state)
	self.Visible = state
	if state then
		self.Main.Visible = true
		self.Scale.Scale = self.BaseScale * 0.97
		Tween(self.Scale, { Scale = self.BaseScale }, EASE_FAST)
	else
		self:CloseFloating()
		for _, modal in ipairs(self.Modals or {}) do modal:SetOpen(false) end
		Tween(self.Scale, { Scale = self.BaseScale * 0.97 }, EASE_FAST).Completed:Once(function()
			if not self.Visible then self.Main.Visible = false end
		end)
	end
end

function Library:Window(opts)
	opts = opts or {}
	local width = opts.Width or 620
	local height = opts.Height or 560

	local gui = New("ScreenGui", {
		Name = opts.Name or "Solitude",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
	})
	ParentGui(gui)

	local main = New("Frame", {
		Size = UDim2.fromOffset(width, height),
		Position = opts.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Window,
		BackgroundTransparency = Theme.WindowAlpha,
		BorderSizePixel = 0,
		Parent = gui,
	})
	Corner(main, 10)
	Stroke(main, Theme.WindowBorder)
	local scale = New("UIScale", { Parent = main })

	local topBar = New("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = Theme.TopBar,
		BorderSizePixel = 0,
		Parent = main,
	})
	Corner(topBar, 10)
	New("Frame", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = Theme.TopBar,
		BorderSizePixel = 0,
		Parent = topBar,
	})
	local title = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		Position = UDim2.fromOffset(16, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = topBar,
	})
	local titleList = List(title, 0, Enum.FillDirection.Horizontal)
	titleList.VerticalAlignment = Enum.VerticalAlignment.Center

	local titleName = Label(title, opts.Title or "Solitude", Theme.TextBright, 14, Theme.FontMedium)
	titleName.Size = UDim2.new(0, 0, 1, 0)
	titleName.AutomaticSize = Enum.AutomaticSize.X

	local titleSuffix = Label(title, opts.Suffix or ".app", Theme.Accent, 14, Theme.FontMedium)
	titleSuffix.Size = UDim2.new(0, 0, 1, 0)
	titleSuffix.AutomaticSize = Enum.AutomaticSize.X
	titleSuffix.LayoutOrder = 2

	local titleDivider = New("Frame", {
		Size = UDim2.fromOffset(1, 14),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		Parent = topBar,
	})

	local tabStyle = (opts.TabStyle == "side" or opts.CategoryMod == 2) and "side" or "top"
	local tabWidth = opts.TabWidth or 140
	local footerHeight = opts.Footer == false and 0 or 40

	local tabBar
	local layoutTabs

	if tabStyle == "side" then
		titleDivider.Visible = false

		tabBar = New("ScrollingFrame", {
			Size = UDim2.new(0, tabWidth, 1, -(47 + footerHeight + 22)),
			Position = UDim2.fromOffset(14, 58),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 0,
			ElasticBehavior = Enum.ElasticBehavior.Never,
			Parent = main,
		})
		List(tabBar, 4)

		layoutTabs = function() end
	else
		tabBar = New("ScrollingFrame", {
			Size = UDim2.new(1, -180, 1, 0),
			Position = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			ScrollingDirection = Enum.ScrollingDirection.X,
			ScrollBarThickness = 0,
			ElasticBehavior = Enum.ElasticBehavior.Never,
			Parent = topBar,
		})
		local tabList = List(tabBar, 18, Enum.FillDirection.Horizontal)
		tabList.VerticalAlignment = Enum.VerticalAlignment.Center

		layoutTabs = function()
			local s = math.max(scale.Scale, 0.05)
			local width = title.AbsoluteSize.X / s
			titleDivider.Position = UDim2.new(0, 16 + width + 12, 0.5, 0)
			local x = 16 + width + 25
			tabBar.Position = UDim2.fromOffset(x, 0)
			tabBar.Size = UDim2.new(1, -(x + 14), 1, 0)
		end
	end
	Track(title:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutTabs))
	Track(main:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutTabs))
	layoutTabs()

	New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 46),
		BackgroundColor3 = Theme.BorderSoft,
		BorderSizePixel = 0,
		Parent = main,
	})

	local shellLeft = tabStyle == "side" and (14 + tabWidth + 10) or 14
	local shell = New("Frame", {
		Size = UDim2.new(1, -(14 + shellLeft), 1, -(47 + footerHeight + 22)),
		Position = UDim2.fromOffset(shellLeft, 58),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = main,
	})
	Corner(shell, 8)
	Stroke(shell, Theme.SectionBorder)

	local body = New("Frame", {
		Size = UDim2.new(1, -24, 1, -24),
		Position = UDim2.fromOffset(12, 12),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = shell,
	})

	local footer, footerLine, footerLeft
	if footerHeight > 0 then
		footerLine = New("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -footerHeight),
			BackgroundColor3 = Theme.BorderSoft,
			BorderSizePixel = 0,
			Parent = main,
		})
		footer = New("Frame", {
			Size = UDim2.new(1, -46, 0, footerHeight - 1),
			Position = UDim2.new(0, 16, 1, -(footerHeight - 1)),
			BackgroundTransparency = 1,
			Parent = main,
		})
		local fList = List(footer, 16, Enum.FillDirection.Horizontal)
		fList.HorizontalAlignment = Enum.HorizontalAlignment.Right
		fList.VerticalAlignment = Enum.VerticalAlignment.Center

		footerLeft = New("Frame", {
			Size = UDim2.new(0, 0, 0, footerHeight - 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Position = UDim2.new(0, 16, 1, -(footerHeight - 1)),
			BackgroundTransparency = 1,
			Parent = main,
		})
		local lList = List(footerLeft, 10, Enum.FillDirection.Horizontal)
		lList.VerticalAlignment = Enum.VerticalAlignment.Center
	end

	local overlay = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 300,
		Parent = main,
	})
	local blocker = New("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Visible = false,
		ZIndex = 110,
		Parent = overlay,
	})

	local window = setmetatable({
		Gui = gui,
		Main = main,
		TopBar = topBar,
		TabBar = tabBar,
		Body = body,
		Footer = footer,
		FooterLeft = footerLeft,
		Overlay = overlay,
		Blocker = blocker,
		Scale = scale,
		TabStyle = tabStyle,
		TabWidth = tabWidth,
		BaseScale = 1,
		FloatStack = {},
		UserScale = 1,
		Opacity = 1 - Theme.WindowAlpha,
		Width = width,
		Height = height,
		MinWidth = opts.MinWidth or 460,
		MinHeight = opts.MinHeight or 320,
		Tabs = {},
		Visible = true,
	}, Window)

	Track(blocker.Activated:Connect(function()
		window:CloseFloating()
	end))

	local function fit()
		local vp = gui.AbsoluteSize
		if vp.X <= 0 then return end
		local s = math.clamp(math.min((vp.X - 24) / window.Width, (vp.Y - 24) / window.Height), 0.55, 1)
			* (window.UserScale or 1)
		window.BaseScale = s
		if window.Visible then scale.Scale = s end
	end
	window.Refit = fit
	Track(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit))
	fit()

	local dragging, dragStart, startPos, moveConn, endConn
	Track(topBar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		window:CloseFloating()
		moveConn = UserInputService.InputChanged:Connect(function(move)
			if not dragging then return end
			if move.UserInputType == Enum.UserInputType.MouseMovement
				or move.UserInputType == Enum.UserInputType.Touch then
				local delta = move.Position - dragStart
				main.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
		endConn = UserInputService.InputEnded:Connect(function(ended)
			if ended.UserInputType == input.UserInputType then
				dragging = false
				if moveConn then moveConn:Disconnect() moveConn = nil end
				if endConn then endConn:Disconnect() endConn = nil end
			end
		end)
	end))

	local grip = New("TextButton", {
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ClipsDescendants = true,
		ZIndex = 130,
		Parent = main,
	})
	local gripBars = {}
	for i, d in ipairs({ 3, 7, 11 }) do
		local bar = New("Frame", {
			Size = UDim2.fromOffset(d * 2, 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(16 - d, 16 - d),
			Rotation = -45,
			BackgroundColor3 = Theme.Border,
			BorderSizePixel = 0,
			ZIndex = 130,
			Parent = grip,
		})
		Corner(bar, 1)
		gripBars[i] = bar
	end
	Track(grip.MouseEnter:Connect(function()
		for _, bar in ipairs(gripBars) do Tween(bar, { BackgroundColor3 = Theme.Accent }, EASE_FAST) end
	end))
	Track(grip.MouseLeave:Connect(function()
		if window.Resizing then return end
		for _, bar in ipairs(gripBars) do Tween(bar, { BackgroundColor3 = Theme.Border }, EASE_FAST) end
	end))

	local resizeMove, resizeEnd
	Track(grip.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		window.Resizing = true
		window:CloseFloating()
		local origin = input.Position
		local startW, startH = window.Width, window.Height
		local startPos = main.Position
		resizeMove = UserInputService.InputChanged:Connect(function(move)
			if not window.Resizing then return end
			if move.UserInputType ~= Enum.UserInputType.MouseMovement
				and move.UserInputType ~= Enum.UserInputType.Touch then return end
			local s = math.max(scale.Scale, 0.05)
			local vp = gui.AbsoluteSize
			local delta = move.Position - origin
			local w = math.clamp(startW + delta.X / s, window.MinWidth, math.max(window.MinWidth, vp.X - 24))
			local h = math.clamp(startH + delta.Y / s, window.MinHeight, math.max(window.MinHeight, vp.Y - 24))
			window:SetSize(w, h)
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + (w - startW) * 0.5,
				startPos.Y.Scale, startPos.Y.Offset + (h - startH) * 0.5)
		end)
		resizeEnd = UserInputService.InputEnded:Connect(function(ended)
			if ended.UserInputType ~= input.UserInputType then return end
			window.Resizing = false
			for _, bar in ipairs(gripBars) do Tween(bar, { BackgroundColor3 = Theme.Border }, EASE_FAST) end
			if resizeMove then resizeMove:Disconnect() resizeMove = nil end
			if resizeEnd then resizeEnd:Disconnect() resizeEnd = nil end
		end)
	end))

	if opts.Cursor then
		Library:SetCursor(true, type(opts.Cursor) == "table" and opts.Cursor or nil)
	end

	if opts.MobileButton == true or (opts.MobileButton ~= false and UserInputService.TouchEnabled) then
		Library:CreateMobileButton(opts.MobileButtonOptions)
	end

	table.insert(Library.Windows, window)
	return window
end

function Library:Notify(opts, text, duration)
	if self.NotificationsEnabled == false then return end
	if type(opts) == "string" then
		opts = { Title = opts, Text = text, Duration = duration }
	end
	opts = opts or {}
	opts.Text = opts.Text or opts.Content or opts.Description
	local styled = opts.Color ~= nil or (type(opts.Style) == "string" and string.lower(opts.Style) ~= "normal")
	local accent = opts.Color or StyleColor(opts.Style, Theme.Accent)
	local iconName = opts.Icon
	if iconName == nil and type(opts.Style) == "string" then
		local key = string.lower(opts.Style)
		if key == "warning" or key == "warn" or key == "yellow" then
			iconName = "alert-triangle"
		elseif key == "danger" or key == "error" or key == "red" then
			iconName = "x-circle"
		elseif key == "success" or key == "green" then
			iconName = "check-circle"
		end
	end
	if not self.NotifyGui then
		local gui = New("ScreenGui", {
			Name = "SolitudeNotifications",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
			DisplayOrder = 1000,
		})
		ParentGui(gui)
		local holder = New("Frame", {
			Size = UDim2.fromOffset(260, 400),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18),
			BackgroundTransparency = 1,
			Parent = gui,
		})
		local l = List(holder, 8)
		l.VerticalAlignment = Enum.VerticalAlignment.Bottom
		l.HorizontalAlignment = Enum.HorizontalAlignment.Right
		self.NotifyGui = gui
		self.NotifyHolder = holder
	end

	local limit = self.NotificationLimit or 5
	local live = {}
	for _, child in ipairs(self.NotifyHolder:GetChildren()) do
		if child:IsA("Frame") then table.insert(live, child) end
	end
	for index = 1, #live - (limit - 1) do
		pcall(function() live[index]:Destroy() end)
	end

	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Section,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = self.NotifyHolder,
	})
	Corner(card, 6)
	local cStroke = Stroke(card, Theme.SectionBorder, 1, 1)
	local bar = New("Frame", {
		Size = UDim2.new(0, 12, 1, 0),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = card,
	})
	Corner(bar, 6)
	local barCover = New("Frame", {
		Size = UDim2.new(0, 9, 1, 0),
		Position = UDim2.fromOffset(3, 0),
		BackgroundColor3 = Theme.Section,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = card,
	})
	local inner = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = card,
	})
	Pad(inner, 10, 12, 10, 14)
	List(inner, 3)

	local headRow = New("Frame", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Parent = inner,
	})
	local icon = AttachIcon(headRow, iconName, accent, 14)
	if icon then icon.ImageTransparency = 1 end
	local inset = icon and 19 or 0
	local head = Label(headRow, opts.Title or "notice", styled and accent or Theme.TextBright, 13, Theme.FontMedium)
	head.Position = UDim2.fromOffset(inset, 0)
	head.Size = UDim2.new(1, -inset, 1, 0)
	head.TextTransparency = 1
	local text
	if opts.Text then
		text = Label(inner, opts.Text, Theme.Text, 12)
		text.Size = UDim2.new(1, 0, 0, 0)
		text.AutomaticSize = Enum.AutomaticSize.Y
		text.TextWrapped = true
		text.LayoutOrder = 2
		text.TextTransparency = 1
	end

	card.Position = UDim2.fromOffset(20, 0)
	Tween(card, { BackgroundTransparency = 0, Position = UDim2.fromOffset(0, 0) })
	Tween(cStroke, { Transparency = 0 })
	Tween(bar, { BackgroundTransparency = 0 })
	Tween(barCover, { BackgroundTransparency = 0 })
	Tween(head, { TextTransparency = 0 })
	if icon then Tween(icon, { ImageTransparency = 0 }) end
	if text then Tween(text, { TextTransparency = 0 }) end

	task.delay(opts.Duration or 3.5, function()
		if not card.Parent then return end
		Tween(card, { BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 0) })
		Tween(cStroke, { Transparency = 1 })
		Tween(bar, { BackgroundTransparency = 1 })
		Tween(barCover, { BackgroundTransparency = 1 })
		Tween(head, { TextTransparency = 1 })
		if icon then Tween(icon, { ImageTransparency = 1 }) end
		if text then Tween(text, { TextTransparency = 1 }) end
		task.wait(0.22)
		card:Destroy()
	end)
end

local MOUSE_KEYS = {
	MB1 = Enum.UserInputType.MouseButton1,
	MB2 = Enum.UserInputType.MouseButton2,
	MB3 = Enum.UserInputType.MouseButton3,
}

function Library:SetToggleKey(key)
	self.ToggleKey = nil
	self.ToggleInput = nil
	if typeof(key) == "EnumItem" then
		if key.EnumType == Enum.UserInputType then
			self.ToggleInput = key
		else
			self.ToggleKey = key
		end
	elseif type(key) == "string" then
		if MOUSE_KEYS[key] then
			self.ToggleInput = MOUSE_KEYS[key]
		else
			local ok, code = pcall(function() return Enum.KeyCode[key] end)
			self.ToggleKey = ok and code or nil
		end
	end
	return self.ToggleKey or self.ToggleInput
end

Library.Panels = {}

function Library:Panel(opts)
	opts = opts or {}

	local gui = New("ScreenGui", {
		Name = opts.Name or "SolitudePanel",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
		DisplayOrder = opts.DisplayOrder or 997,
	})
	ParentGui(gui)

	local root = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	local rootScale = New("UIScale", { Parent = root })

	local frame = New("Frame", {
		Size = opts.Height
			and UDim2.fromOffset(opts.Width or 180, opts.Height)
			or UDim2.new(0, opts.Width or 180, 0, 0),
		AutomaticSize = (not opts.Height) and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
		Position = opts.Position or UDim2.fromOffset(18, 90),
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		Active = true,
		Parent = root,
	})
	Corner(frame, 8)
	Stroke(frame, Theme.SectionBorder)

	local stack = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = frame,
	})
	List(stack, 0)

	local headerChevron, headerTitle, headerButton
	if opts.Title then
		local header = New("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			Parent = stack,
		})
		Pad(header, 0, 11, 0, 11)

		local icon = AttachIcon(header, opts.Icon, Theme.TextBright, 14)
		if icon then
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.Position = UDim2.new(0, 0, 0.5, 0)
		end
		local inset = icon and 20 or 0
		headerTitle = Label(header, opts.Title, Theme.TextBright, Theme.TextSize, Theme.FontMedium)
		headerTitle.Position = UDim2.fromOffset(inset, 0)
		headerTitle.Size = UDim2.new(1, -inset - 16, 1, 0)

		headerChevron = Chevron(header, Theme.TextDim)
		headerChevron.AnchorPoint = Vector2.new(1, 0.5)
		headerChevron.Position = UDim2.new(1, 0, 0.5, 0)

		headerButton = New("TextButton", {
			Size = UDim2.fromOffset(26, 26),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 6, 0.5, 0),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 2,
			Parent = header,
		})

		New("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Theme.BorderSoft,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			Parent = stack,
		})
	end

	local body = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		LayoutOrder = 3,
		Parent = stack,
	})
	Pad(body, opts.Title and 9 or 11, 11, 11, 11)
	List(body, 8)

	local overlay = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 300,
		Parent = root,
	})
	local blocker = New("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Visible = false,
		ZIndex = 310,
		Parent = overlay,
	})

	-- Window methods are reused so dropdowns, colour pickers and gear popups
	-- open inside the panel instead of the main window overlay.
	local api = setmetatable({
		Gui = gui,
		Frame = frame,
		Main = root,
		Scale = rootScale,
		Overlay = overlay,
		Blocker = blocker,
		FloatStack = {},
		Modals = {},
	}, { __index = Window })

	api.Content = NewContainer(api, body)
	api.Open = true

	function api:SetOpen(state)
		state = state ~= false
		if state == self.Open then return end
		self.Open = state
		self:CloseFloating()

		if state then
			body.Visible = true
			body.Size = UDim2.new(1, 0, 0, 0)
			local target = body.AbsoluteSize.Y
			body.AutomaticSize = Enum.AutomaticSize.Y
			target = body.AbsoluteSize.Y
			body.AutomaticSize = Enum.AutomaticSize.None
			body.Size = UDim2.new(1, 0, 0, 0)
			Tween(body, { Size = UDim2.new(1, 0, 0, target) }).Completed:Once(function()
				if self.Open then body.AutomaticSize = Enum.AutomaticSize.Y end
			end)
		else
			local current = body.AbsoluteSize.Y
			body.AutomaticSize = Enum.AutomaticSize.None
			body.Size = UDim2.new(1, 0, 0, current)
			Tween(body, { Size = UDim2.new(1, 0, 0, 0) }).Completed:Once(function()
				if not self.Open then body.Visible = false end
			end)
		end

		if headerChevron then
			Tween(headerChevron, { Rotation = state and 0 or 180 }, EASE_FAST)
		end
		return self
	end

	function api:Toggle()
		return self:SetOpen(not self.Open)
	end

	if headerButton then
		Track(headerButton.Activated:Connect(function()
			api:Toggle()
		end))
		Track(headerButton.MouseEnter:Connect(function()
			for _, bar in ipairs(headerChevron:GetChildren()) do
				if bar:IsA("Frame") then
					Tween(bar, { BackgroundColor3 = Theme.AccentSoft }, EASE_FAST)
				end
			end
		end))
		Track(headerButton.MouseLeave:Connect(function()
			for _, bar in ipairs(headerChevron:GetChildren()) do
				if bar:IsA("Frame") then
					Tween(bar, { BackgroundColor3 = Theme.TextDim }, EASE_FAST)
				end
			end
		end))
	end

	Track(blocker.Activated:Connect(function()
		api:CloseFloating()
	end))

	function api:SetVisible(state)
		if not state then self:CloseFloating() end
		gui.Enabled = state and true or false
	end

	function api:SetPosition(position)
		frame.Position = position
	end

	function api:Destroy()
		self:CloseFloating()
		gui:Destroy()
		for index, panel in ipairs(Library.Panels) do
			if panel == api then table.remove(Library.Panels, index) break end
		end
	end

	if opts.Draggable ~= false then
		local origin, startPos, moveConn, endConn
		Track(frame.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch then return end
			origin = input.Position
			startPos = frame.Position
			moveConn = UserInputService.InputChanged:Connect(function(move)
				if move.UserInputType ~= Enum.UserInputType.MouseMovement
					and move.UserInputType ~= Enum.UserInputType.Touch then return end
				local delta = move.Position - origin
				frame.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end)
			endConn = UserInputService.InputEnded:Connect(function(ended)
				if ended.UserInputType ~= input.UserInputType then return end
				if moveConn then moveConn:Disconnect() moveConn = nil end
				if endConn then endConn:Disconnect() endConn = nil end
			end)
		end))
	end

	if opts.Visible == false then api:SetVisible(false) end
	if opts.Collapsed then api:SetOpen(false) end

	table.insert(self.Panels, api)
	return api
end

Library.HotkeyEntries = {}
Library.HotkeysEnabled = false

function Library:RegisterHotkey(getter)
	table.insert(self.HotkeyEntries, getter)
	self:RefreshHotkeys()
	return getter
end

function Library:CreateHotkeyPanel(opts)
	if self.HotkeyGui then return self.HotkeyPanel end
	opts = opts or {}

	local gui = New("ScreenGui", {
		Name = "SolitudeHotkeys",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
		DisplayOrder = 998,
		Enabled = false,
	})
	ParentGui(gui)

	local panel = New("Frame", {
		Size = UDim2.fromOffset(opts.Width or 180, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = opts.Position or UDim2.fromOffset(18, 90),
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		Active = true,
		Parent = gui,
	})
	Corner(panel, 8)
	Stroke(panel, Theme.SectionBorder)
	local inner = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = panel,
	})
	List(inner, 0)

	local header = New("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Parent = inner,
	})
	Pad(header, 0, 11, 0, 11)
	local icon = AttachIcon(header, opts.Icon or "keyboard", Theme.TextBright, 14)
	local inset = icon and 20 or 0
	if icon then
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.Position = UDim2.new(0, 0, 0.5, 0)
	end
	local title = Label(header, opts.Title or "hotkeys", Theme.TextBright, Theme.TextSize, Theme.FontMedium)
	title.Position = UDim2.fromOffset(inset, 0)
	title.Size = UDim2.new(1, -inset, 1, 0)

	New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.BorderSoft,
		BorderSizePixel = 0,
		LayoutOrder = 2,
		Parent = inner,
	})

	local body = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = inner,
	})
	Pad(body, 8, 11, 9, 11)

	local rows = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = body,
	})
	List(rows, 4)

	local origin, startPos, moveConn, endConn
	Track(panel.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		origin = input.Position
		startPos = panel.Position
		moveConn = UserInputService.InputChanged:Connect(function(move)
			if move.UserInputType ~= Enum.UserInputType.MouseMovement
				and move.UserInputType ~= Enum.UserInputType.Touch then return end
			local delta = move.Position - origin
			panel.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end)
		endConn = UserInputService.InputEnded:Connect(function(ended)
			if ended.UserInputType ~= input.UserInputType then return end
			if moveConn then moveConn:Disconnect() moveConn = nil end
			if endConn then endConn:Disconnect() endConn = nil end
		end)
	end))

	self.HotkeyGui = gui
	self.HotkeyPanel = panel
	self.HotkeyRows = rows
	return panel
end

function Library:RefreshHotkeys()
	if not self.HotkeyGui or not self.HotkeysEnabled then return end

	local rows = self.HotkeyRows
	for _, child in ipairs(rows:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local shown = 0
	for index = #self.HotkeyEntries, 1, -1 do
		local ok, data = pcall(self.HotkeyEntries[index])
		if not ok then
			table.remove(self.HotkeyEntries, index)
		elseif type(data) == "table" and data.Visible and data.Key and data.Key ~= "" then
			shown = shown + 1
			local color = data.Active and Theme.Accent or Theme.TextDim

			local row = New("Frame", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				LayoutOrder = shown,
				Parent = rows,
			})

			local label = Label(row, data.Label or "action", color, Theme.TextSize - 1)
			label.Size = UDim2.new(1, -52, 1, 0)
			label.TextTruncate = Enum.TextTruncate.AtEnd

			local key = Label(row, data.Key, color, Theme.TextSize - 1)
			key.AnchorPoint = Vector2.new(1, 0)
			key.Position = UDim2.fromScale(1, 0)
			key.Size = UDim2.fromOffset(50, 16)
			key.TextXAlignment = Enum.TextXAlignment.Right
		end
	end

	self.HotkeyPanel.Visible = shown > 0
end

function Library:SetHotkeysVisible(state)
	self.HotkeysEnabled = state and true or false
	if self.HotkeysEnabled then self:CreateHotkeyPanel() end
	if self.HotkeyGui then self.HotkeyGui.Enabled = self.HotkeysEnabled end
	self:RefreshHotkeys()
	return self.HotkeysEnabled
end

Library.CursorEnabled = false

function Library:CreateCursor(opts)
	if self.CursorGui then return self.CursorGui end
	opts = opts or {}

	local length = opts.Length or 9
	local thickness = opts.Thickness or 2
	local gap = opts.Gap or 4

	local gui = New("ScreenGui", {
		Name = "SolitudeCursor",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		AutoLocalize = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 1002,
		Enabled = false,
	})
	ParentGui(gui)

	local holder = New("Frame", {
		Size = UDim2.fromOffset(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = gui,
	})

	local function bar(anchor, position, size)
		local piece = New("Frame", {
			Size = size,
			AnchorPoint = anchor,
			Position = position,
			BackgroundColor3 = opts.Color or Theme.Accent,
			BorderSizePixel = 0,
			Parent = holder,
		})
		Corner(piece, 1)
		return piece
	end

	bar(Vector2.new(1, 0.5), UDim2.new(0.5, -gap, 0.5, 0), UDim2.fromOffset(length, thickness))
	bar(Vector2.new(0, 0.5), UDim2.new(0.5, gap, 0.5, 0), UDim2.fromOffset(length, thickness))
	bar(Vector2.new(0.5, 1), UDim2.new(0.5, 0, 0.5, -gap), UDim2.fromOffset(thickness, length))
	bar(Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0.5, gap), UDim2.fromOffset(thickness, length))

	if opts.Dot ~= false then
		bar(Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(thickness, thickness))
	end

	Track(RunService.RenderStepped:Connect(function()
		if not gui.Enabled then return end
		local position = UserInputService:GetMouseLocation()
		if not gui.IgnoreGuiInset then
			position = position - GuiService:GetGuiInset()
		end
		holder.Position = UDim2.fromOffset(position.X, position.Y)
	end))

	self.CursorGui = gui
	self.CursorHolder = holder
	return gui
end

function Library:RefreshCursor()
	if not self.CursorGui then return end
	self.CursorGui.Enabled = self.CursorEnabled and self.Open
end

function Library:SetCursor(state, opts)
	self.CursorEnabled = state and true or false
	if self.CursorEnabled then self:CreateCursor(opts) end
	self:RefreshCursor()
	return self.CursorEnabled
end

function Library:ToggleUI(state)
	if state == nil then state = not self.Open end
	self.Open = state
	for _, window in ipairs(self.Windows) do
		window:SetVisible(state)
	end
	self:RefreshCursor()
	return self.Open
end

function Library:CreateMobileButton(opts)
	if self.MobileGui then return self.MobileButton end
	opts = opts or {}

	local gui = New("ScreenGui", {
		Name = "SolitudeToggle",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
		DisplayOrder = 1001,
	})
	ParentGui(gui)

	local button = New("TextButton", {
		Size = UDim2.fromOffset(opts.Size or 44, opts.Size or 44),
		Position = opts.Position or UDim2.new(0, 18, 0.5, -22),
		BackgroundColor3 = Theme.Section,
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		Parent = gui,
	})
	Corner(button, 12)
	Stroke(button, Theme.Border)
	for i = 1, 3 do
		local bar = New("Frame", {
			Size = UDim2.fromOffset(18, 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, (i - 2) * 6),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Parent = button,
		})
		Corner(bar, 1)
	end

	local moved, origin, startPos, moveConn, endConn
	Track(button.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		moved = false
		origin = input.Position
		startPos = button.Position
		Tween(button, { BackgroundColor3 = Theme.FieldHover }, EASE_FAST)
		moveConn = UserInputService.InputChanged:Connect(function(move)
			if move.UserInputType ~= Enum.UserInputType.MouseMovement
				and move.UserInputType ~= Enum.UserInputType.Touch then return end
			local delta = move.Position - origin
			if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then moved = true end
			button.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end)
		endConn = UserInputService.InputEnded:Connect(function(ended)
			if ended.UserInputType ~= input.UserInputType then return end
			if moveConn then moveConn:Disconnect() moveConn = nil end
			if endConn then endConn:Disconnect() endConn = nil end
			Tween(button, { BackgroundColor3 = Theme.Section }, EASE_FAST)
			if not moved then Library:ToggleUI() end
		end)
	end))

	self.MobileGui = gui
	self.MobileButton = button
	return button
end

function Library:SetMobileButtonVisible(state)
	if not self.MobileGui then
		if not state then return end
		self:CreateMobileButton()
	end
	self.MobileGui.Enabled = state and true or false
end

Track(UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or Library.Binding then return end
	local hit = (Library.ToggleKey ~= nil and input.KeyCode == Library.ToggleKey)
		or (Library.ToggleInput ~= nil and input.UserInputType == Library.ToggleInput)
	if hit then
		Library:ToggleUI()
	end
end))

function Library:Destroy()
	for _, conn in ipairs(self.Connections) do
		pcall(function() conn:Disconnect() end)
	end
	table.clear(self.Connections)
	for _, w in ipairs(self.Windows) do
		w.Gui:Destroy()
	end
	table.clear(self.Windows)
	if self.NotifyGui then self.NotifyGui:Destroy() self.NotifyGui = nil end
	if self.MobileGui then self.MobileGui:Destroy() self.MobileGui = nil self.MobileButton = nil end
	if self.CursorGui then self.CursorGui:Destroy() self.CursorGui = nil self.CursorHolder = nil end
	if self.HotkeyGui then self.HotkeyGui:Destroy() self.HotkeyGui = nil self.HotkeyPanel = nil end
	for index = #self.Panels, 1, -1 do
		pcall(function() self.Panels[index].Gui:Destroy() end)
		self.Panels[index] = nil
	end
	table.clear(self.HotkeyEntries)
	table.clear(self.Registry)
	table.clear(self.Flags)
end

local HttpService = game:GetService("HttpService")

local FileSystem = {}
FileSystem.Memory = {}
FileSystem.Native = typeof(writefile) == "function" and typeof(readfile) == "function"

function FileSystem:MakeFolder(path)
	if not self.Native then return end
	if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
		local ok, exists = pcall(isfolder, path)
		if ok and not exists then pcall(makefolder, path) end
	end
end

function FileSystem:Write(path, text)
	if self.Native and pcall(writefile, path, text) then
		self.Memory[path] = nil
		return true
	end
	self.Memory[path] = text
	return true
end

function FileSystem:Read(path)
	if self.Native and typeof(isfile) == "function" then
		local ok, exists = pcall(isfile, path)
		if ok and exists then
			local read, data = pcall(readfile, path)
			if read then return data end
		end
	end
	return self.Memory[path]
end

function FileSystem:Delete(path)
	if self.Native and typeof(delfile) == "function" then pcall(delfile, path) end
	self.Memory[path] = nil
end

function FileSystem:List(folder)
	local names, seen = {}, {}
	if self.Native and typeof(listfiles) == "function" then
		local ok, files = pcall(listfiles, folder)
		if ok and files then
			for _, full in ipairs(files) do
				local name = string.match(full, "[^/\\]+$")
				if name and not seen[name] then
					seen[name] = true
					table.insert(names, name)
				end
			end
		end
	end
	for path in pairs(self.Memory) do
		if string.sub(path, 1, #folder + 1) == folder .. "/" then
			local name = string.match(path, "[^/\\]+$")
			if name and not seen[name] then
				seen[name] = true
				table.insert(names, name)
			end
		end
	end
	table.sort(names)
	return names
end

function Library:BuildFolders(folder)
	local path = ""
	for _, part in ipairs(string.split(folder, "/")) do
		path = path == "" and part or (path .. "/" .. part)
		FileSystem:MakeFolder(path)
	end
	FileSystem:MakeFolder(folder .. "/configs")
	return folder
end

Library.FileSystem = FileSystem

if getgenv then
	pcall(function() getgenv().Solitude = Library end)
end
Library.SaveManager = Library:LoadAddon("SaveManager")
Library.InterfaceManager = Library:LoadAddon("InterfaceManager")
Library.ThemeManager = Library:LoadAddon("ThemeManager")

return Library