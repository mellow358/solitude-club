local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local function RandomName(len)
	len = len or 12
	local t = {}
	for i = 1, len do
		local idx = math.random(1, #CHARS)
		t[i] = string.sub(CHARS, idx, idx)
	end
	return table.concat(t)
end
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
	if gui:IsA("ScreenGui") then
		pcall(function() gui.OnTopOfCoreBlur = true end)
	end
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

local MAX_DISPLAY_ORDER = 2147483647

-- layers, highest draws last
local ORDER_WINDOW    = MAX_DISPLAY_ORDER - 40
local ORDER_PANEL     = MAX_DISPLAY_ORDER - 30
local ORDER_BROWSER   = MAX_DISPLAY_ORDER - 25
local ORDER_HOTKEYS   = MAX_DISPLAY_ORDER - 20
local ORDER_MOBILE    = MAX_DISPLAY_ORDER - 15
local ORDER_NOTIFY    = MAX_DISPLAY_ORDER - 10
local ORDER_KEYSYSTEM = MAX_DISPLAY_ORDER - 5
local ORDER_CURSOR    = MAX_DISPLAY_ORDER

local EASE      = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local EASE_FAST = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Registry of themed instances, keyed by instance.
-- Each entry maps a property name to a theme key, so a repaint is a plain
-- lookup instead of a colour comparison. Declaring a tag is explicit:
--   New("Frame", { ThemeTag = { BackgroundColor3 = "Section" } })
-- and a state change reassigns the tag instead of writing a raw colour:
--   Library:Tag(box, { BackgroundColor3 = state and "Accent" or "Field" })
local Painted = {}
local PaintedCount = 0
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

local function TagInstance(inst, props)
	local entry = Painted[inst]
	if not entry then
		entry = {}
		Painted[inst] = entry
		PaintedCount = PaintedCount + 1
	end
	for property, key in pairs(props) do
		if key == false then
			entry[property] = nil
		else
			entry[property] = key
			local color = Theme[key]
			if color ~= nil then
				pcall(function() inst[property] = color end)
			end
		end
	end
	return inst
end

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
Library.BaseUrl = "https://raw.githubusercontent.com/FacilityHUB/UI-Facility/refs/heads/main/"
Library.AddonPaths = {
	Icons = "addons/Icons.luau",
	SaveManager = "addons/SaveManager.luau",
	InterfaceManager = "addons/InterfaceManager.luau",
	ThemeManager = "addons/ThemeManager.luau",
}
Library.Addons = {}
Library.Painted = Painted
Library.PaintedCount = function() return PaintedCount end
-- "inline" : titre dans la carte (defaut)
-- "border" : titre pose sur la bordure, facon fieldset
Library.SectionTitleStyle = "inline"
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
		warn("Facility | callback error in '" .. tostring(label) .. "': " .. tostring(err))
		self:Error("callback error", tostring(label) .. " - " .. message, 7)
	end)
end

function Library:OnRepaint(callback)
	table.insert(self.RepaintHooks, callback)
	return callback
end
Library.ThemeAlpha = ThemeAlpha
Library.Version = "2026.09.11-layers"

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
			warn("Facility | unknown addon '" .. tostring(name) .. "'")
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
		warn("Facility | addon '" .. tostring(name) .. "' unavailable")
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

function Library:Tag(instance, props)
	if typeof(instance) ~= "Instance" then return instance end
	return TagInstance(instance, props)
end

function Library:Untag(instance)
	if Painted[instance] then
		Painted[instance] = nil
		PaintedCount = PaintedCount - 1
	end
end

function Library:Repaint()
	if PaintedCount == 0 then
		warn("Facility | repaint registry is empty, main.luau is probably outdated")
	end
	IndexTheme()

	local dead = {}
	for instance, entry in pairs(Painted) do
		local ok = pcall(function()
			-- an instance removed from the tree is dropped on the next pass
			if not instance.Parent and not instance:IsA("ScreenGui") then
				table.insert(dead, instance)
				return
			end
			for property, key in pairs(entry) do
				local color = Theme[key]
				if color ~= nil then
					instance[property] = color
					local alpha = tonumber(ThemeAlpha[key])
					local transparency = ALPHA_PROPS[property]
					if alpha and alpha < 1 and alpha > 0 and transparency
						and instance[transparency] < 1 then
						instance[transparency] = 1 - alpha
					end
				end
			end
		end)
		if not ok then table.insert(dead, instance) end
	end

	for _, instance in ipairs(dead) do
		Painted[instance] = nil
		PaintedCount = PaintedCount - 1
	end

	self:RefreshHotkeys()
	for i = #self.RepaintHooks, 1, -1 do
		local ok = pcall(self.RepaintHooks[i])
		if not ok then table.remove(self.RepaintHooks, i) end
	end
end

function Library:Register(flag, entry)
	if self.Registry[flag] then
		warn("Facility | duplicate flag '" .. tostring(flag) .. "', the previous element will no longer be saved")
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

local GLASS_ALPHA = {
	Window = 0.32,
	TopBar = 1,
	Section = 0.55,
	Group = 0.58,
	Field = 0.62,
	FieldHover = 0.62,
	PopupBg = 0.1,
}
local GlassSaved = setmetatable({}, { __mode = "k" })
Library.Glass = false
Library.GlassBlur = true
Library.GlassStrength = 1

local function ApplyGlass(inst)
	if GlassSaved[inst] ~= nil then return end
	local entry = Painted[inst]
	local key = entry and entry.BackgroundColor3
	local amount = key and GLASS_ALPHA[key]
	if not amount or not inst:IsA("GuiObject") then return end
	local base = inst.BackgroundTransparency
	if base >= 1 then return end
	GlassSaved[inst] = base
	if amount >= 1 then
		inst.BackgroundTransparency = 1
		return
	end
	amount = math.clamp(amount * (Library.GlassStrength or 1), 0, 0.95)
	inst.BackgroundTransparency = base + (1 - base) * amount
end

local function RemoveGlass()
	for inst, base in pairs(GlassSaved) do
		pcall(function() inst.BackgroundTransparency = base end)
	end
	table.clear(GlassSaved)
end

local function New(class, props, children)
	local inst = Instance.new(class)
	local parent = nil
	local tag = nil

	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		elseif k == "ThemeTag" then
			tag = v
		else
			inst[k] = v
			-- fallback for call sites that pass Theme.X directly
			if typeof(v) == "Color3" then
				local key = ThemeIndex[tostring(v)]
				if key then TagInstance(inst, { [k] = key }) end
			end
		end
	end

	-- an explicit tag always wins over the detected one
	if tag then TagInstance(inst, tag) end
	if Library.Glass then ApplyGlass(inst) end

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

function Elements:Image(opts)
	opts = opts or {}

	local height = opts.Height or 120
	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Field" },
	})
	Corner(holder, opts.Corner or 6)
	if opts.Border ~= false then Stroke(holder, Theme.Border) end

	local image = New("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = opts.Image or "",
		ScaleType = opts.ScaleType or Enum.ScaleType.Crop,
		Parent = holder,
	})

	local api = { Instance = holder, Image = image }

	function api:Set(asset)
		image.Image = tostring(asset or "")
		return self
	end

	-- a user id loads that player's headshot
	function api:SetUser(userId, thumbType, size)
		local id = tonumber(userId) or 0

		-- rbxthumb resolves without an API call and works instantly
		image.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", id)

		task.spawn(function()
			local ok, content = pcall(function()
				return Players:GetUserThumbnailAsync(
					id,
					thumbType or Enum.ThumbnailType.HeadShot,
					size or Enum.ThumbnailSize.Size150x150)
			end)
			if ok and content and content ~= "" then image.Image = content end
		end)
		return self
	end

	function api:SetHeight(value)
		holder.Size = UDim2.new(1, 0, 0, value)
		return self
	end

	if opts.UserId then api:SetUser(opts.UserId) end
	return api
end

function Elements:Table(opts)
	opts = opts or {}

	local columns = opts.Columns or { "column" }
	local count = math.max(#columns, 1)
	local maxRows = opts.MaxRows or 12
	local rowHeight = opts.RowHeight or 18

	local block = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self.Container,
	})
	List(block, 4)

	local function buildRow(parent, order)
		local row = New("Frame", {
			Size = UDim2.new(1, 0, 0, rowHeight),
			BackgroundTransparency = 1,
			LayoutOrder = order,
			Parent = parent,
		})
		local cells = {}
		for index = 1, count do
			local cell = Label(row, "", Theme.Text, Theme.TextSize - 1)
			cell.Position = UDim2.fromScale((index - 1) / count, 0)
			cell.Size = UDim2.new(1 / count, -6, 1, 0)
			cell.TextTruncate = Enum.TextTruncate.AtEnd
			if index > 1 and opts.AlignRight then
				cell.TextXAlignment = Enum.TextXAlignment.Right
			end
			cells[index] = cell
		end
		return row, cells
	end

	-- header
	local headerCells
	if opts.Header ~= false then
		local header
		header, headerCells = buildRow(block, 1)
		for index, cell in ipairs(headerCells) do
			cell.Text = tostring(columns[index] or "")
			cell.TextColor3 = Theme.TextDim
			TagInstance(cell, { TextColor3 = "TextDim" })
		end

		New("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Theme.BorderSoft,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			Parent = block,
			ThemeTag = { BackgroundColor3 = "BorderSoft" },
		})
	end

	local body = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = block,
	})
	List(body, 2)

	local empty = Label(block, opts.EmptyText or "no data", Theme.TextDim, Theme.TextSize - 1)
	empty.Size = UDim2.new(1, 0, 0, rowHeight)
	empty.LayoutOrder = 4

	local rows = {}
	for index = 1, maxRows do
		local row, cells = buildRow(body, index)
		row.Visible = false
		rows[index] = { Frame = row, Cells = cells }
	end

	local api = { Instance = block, Rows = rows }

	function api:SetRows(data)
		data = data or {}
		local shown = 0

		for index, row in ipairs(rows) do
			local entry = data[index]
			if entry then
				shown = shown + 1
				row.Frame.Visible = true
				for cellIndex, cell in ipairs(row.Cells) do
					local value = entry[cellIndex]
					cell.Text = value ~= nil and tostring(value) or ""
					local color = entry.Color or (entry.Colors and entry.Colors[cellIndex])
					if typeof(color) == "Color3" then
						cell.TextColor3 = color
					elseif entry.Style then
						cell.TextColor3 = StyleColor(entry.Style, Theme.Text)
					end
				end
			else
				row.Frame.Visible = false
			end
		end

		empty.Visible = shown == 0
		if headerCells then
			for _, cell in ipairs(headerCells) do
				cell.Visible = shown > 0 or opts.KeepHeader == true
			end
		end
		return shown
	end

	function api:Clear()
		return self:SetRows({})
	end

	api:SetRows(opts.Rows)
	return api
end

function Elements:Divider()
	local d = New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.BorderSoft,
		BorderSizePixel = 0,
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "BorderSoft" },
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
		ThemeTag = { BackgroundColor3 = "Group" },
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

local BADGE_COLORS = {
	BETA = Color3.fromRGB(255, 184, 76),
	HOT = Color3.fromRGB(255, 92, 92),
	FIXED = Color3.fromRGB(96, 214, 140),
	NEW = Color3.fromRGB(96, 205, 255),
}

local function MakeBadge(parent, spec)
	if spec == nil or spec == false or spec == "" then return nil end
	local text, color = spec, nil
	if type(spec) == "table" then text, color = spec.Text or spec.Title or "", spec.Color end
	text = string.upper(tostring(text))
	if text == "" then return nil end
	color = color or BADGE_COLORS[text]

	local badge = New("Frame", {
		Name = "Badge",
		Size = UDim2.fromOffset(0, 15),
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = color or Theme.Accent,
		BackgroundTransparency = 0.84,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = parent,
		ThemeTag = (not color) and { BackgroundColor3 = "Accent" } or nil,
	})
	Corner(badge, 4)
	local stroke = Stroke(badge, color or Theme.Accent, 1, 0.55)
	if not color then Library:Tag(stroke, { Color = "Accent" }) end
	Pad(badge, 0, 6, 0, 6)
	local label = Label(badge, text, color or Theme.Accent, 9, Enum.Font.GothamBold)
	label.Size = UDim2.fromScale(0, 1)
	label.AutomaticSize = Enum.AutomaticSize.X
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.ZIndex = 3
	if not color then Library:Tag(label, { TextColor3 = "Accent" }) end
	return badge
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
		ThemeTag = { BackgroundColor3 = "Field" },
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

	function state.SetBadge(spec)
		if state.Badge then state.Badge:Destroy() state.Badge = nil end
		if state.BadgeConn then state.BadgeConn:Disconnect() state.BadgeConn = nil end
		local badge = MakeBadge(btn, spec)
		if not badge then return end
		state.Badge = badge
		local function place()
			local width = math.min(text.TextBounds.X, btn.AbsoluteSize.X)
			badge.Position = UDim2.new(0.5, math.floor(width / 2) + 6, 0.5, 0)
		end
		state.BadgeConn = text:GetPropertyChangedSignal("TextBounds"):Connect(place)
		Track(state.BadgeConn)
		place()
	end
	if opts.Badge then state.SetBadge(opts.Badge) end

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
	function api:SetBadge(spec)
		state.SetBadge(spec)
		return self
	end
	function api:SetText(value)
		text.Text = tostring(value)
		return self
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
		ClipsDescendants = true,
		LayoutOrder = 2,
		Parent = block,
		ThemeTag = { BackgroundColor3 = "Field" },
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
		ThemeTag = { PlaceholderColor3 = "TextDim", TextColor3 = "TextBright" },
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
			ThemeTag = { BackgroundColor3 = "PopupBg", TextColor3 = "TextBright" },
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
		ThemeTag = { BackgroundColor3 = "Accent" },
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
		-- the tag follows the state, so the stroke keeps tracking the theme
		Library:Tag(boxStroke, { Color = state and "Accent" or "Border" })
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
			ThemeTag = { BackgroundColor3 = "Field" },
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
			ThemeTag = { ImageColor3 = "TextDim" },
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
		ThemeTag = { BackgroundColor3 = "Field" },
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

	local chips = multi and opts.Chips == true
	local chipHost
	if chips then
		chipHost = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Visible = false,
			Parent = block,
		})
		local chipList = List(chipHost, 5, Enum.FillDirection.Horizontal)
		chipList.Wraps = true
		chipList.VerticalAlignment = Enum.VerticalAlignment.Center
	end

	local panel = self.Window:CreateFloating(0, true, self.Float)
	local searchField = New("Frame", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = 1,
		Visible = false,
		ZIndex = panel.Frame.ZIndex,
		Parent = panel.Content,
		ThemeTag = { BackgroundColor3 = "Field" },
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
		ThemeTag = { PlaceholderColor3 = "TextDim", TextColor3 = "TextBright" },
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
		ThemeTag = { ScrollBarImageColor3 = "AccentDim" },
	})
	List(scroller, 2)

	local api = { Instance = block }
	local rows = {}

	local function display()
		if multi then
			if #selected == 0 then return opts.Empty or "none" end
			if chips then return #selected .. " selected" end
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

	local renderChips

	local function refresh()
		value.Text = display()
		if renderChips then renderChips() end
		for v, row in pairs(rows) do
			local picked = isPicked(v)
			Library:Tag(row.Text, { TextColor3 = picked and "AccentSoft" or "Text" })
			Tween(row.Text, { TextColor3 = picked and Theme.AccentSoft or Theme.Text }, EASE_FAST)
		end
		if flag then
			Library.Flags[flag] = selected
			Library:MarkDirty(flag)
		end
	end

	if chips then
		local chipFrames = {}
		renderChips = function()
			for _, frame in ipairs(chipFrames) do frame:Destroy() end
			table.clear(chipFrames)
			chipHost.Visible = #selected > 0
			for index, v in ipairs(selected) do
				local chip = New("Frame", {
					Size = UDim2.fromOffset(0, 22),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Theme.Accent,
					BackgroundTransparency = 0.84,
					BorderSizePixel = 0,
					LayoutOrder = index,
					Parent = chipHost,
					ThemeTag = { BackgroundColor3 = "Accent" },
				})
				Corner(chip, 11)
				local stroke = Stroke(chip, Theme.Accent, 1, 0.6)
				Library:Tag(stroke, { Color = "Accent" })
				Pad(chip, 0, 6, 0, 10)
				local chipList = List(chip, 6, Enum.FillDirection.Horizontal)
				chipList.VerticalAlignment = Enum.VerticalAlignment.Center

				local text = Label(chip, tostring(v), Theme.AccentSoft, 12)
				text.Size = UDim2.fromScale(0, 1)
				text.AutomaticSize = Enum.AutomaticSize.X
				text.LayoutOrder = 1
				Library:Tag(text, { TextColor3 = "AccentSoft" })

				local remove = New("TextButton", {
					Size = UDim2.fromOffset(14, 14),
					BackgroundTransparency = 1,
					AutoButtonColor = false,
					Text = "×",
					TextColor3 = Theme.AccentSoft,
					TextSize = 14,
					Font = Theme.FontMedium,
					LayoutOrder = 2,
					Parent = chip,
					ThemeTag = { TextColor3 = "AccentSoft" },
				})
				Track(remove.MouseEnter:Connect(function()
					Tween(remove, { TextColor3 = Theme.Danger }, EASE_FAST)
				end))
				Track(remove.MouseLeave:Connect(function()
					Tween(remove, { TextColor3 = Theme.AccentSoft }, EASE_FAST)
				end))
				Track(remove.Activated:Connect(function()
					if api.Enabled == false then return end
					for idx, x in ipairs(selected) do
						if x == v then table.remove(selected, idx) break end
					end
					refresh()
					Library:SafeCallback(opts.Text or "dropdown", opts.Callback, selected)
				end))
				table.insert(chipFrames, chip)
			end
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
				ThemeTag = { BackgroundColor3 = "FieldHover" },
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
		Library:Tag(bStroke, { Color = "Accent" })
		Tween(bStroke, { Color = Theme.Accent }, EASE_FAST)
		Tween(chev, { Rotation = 180 }, EASE_FAST)
	end
	panel.OnClose = function()
		Library:Tag(bStroke, { Color = "Border" })
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

	Library:OnRepaint(refresh)

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

function Elements:MultiSelect(opts)
	opts = opts or {}
	local copy = {}
	for key, v in pairs(opts) do copy[key] = v end
	copy.Multi = true
	if copy.Chips == nil then copy.Chips = true end
	if copy.Empty == nil then copy.Empty = copy.Placeholder or "select..." end
	return self:Dropdown(copy)
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

	local valueBox = New("TextBox", {
		Size = UDim2.fromOffset(0, 16),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.TextDim,
		TextSize = 12,
		Font = Theme.Font,
		PlaceholderColor3 = Theme.TextDim,
		ClearTextOnFocus = true,
		LayoutOrder = 2,
		Parent = head,
		ThemeTag = { TextColor3 = "TextDim", PlaceholderColor3 = "TextDim" },
	})

	local valueLabel = valueBox

	local track = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 4),
		Position = UDim2.new(0, 0, 0, 24),
		BackgroundColor3 = Theme.Track,
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		Parent = block,
		ThemeTag = { BackgroundColor3 = "Track" },
	})
	Corner(track, 2)
	local fill = New("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
		ThemeTag = { BackgroundColor3 = "Accent" },
	})
	Corner(fill, 2)
	local knob = New("Frame", {
		Size = UDim2.fromOffset(9, 9),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
		ThemeTag = { BackgroundColor3 = "Accent" },
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
		valueBox.Text = format(v)
	end

	Track(valueBox.Focused:Connect(function()
		valueBox.Text = tostring(math.floor(value * 10^decimals + 0.5) / 10^decimals)
		valueBox.TextColor3 = Theme.TextBright
	end))

	Track(valueBox.FocusLost:Connect(function(entered)
		valueBox.TextColor3 = Theme.TextDim
		if entered then
			local num = tonumber(valueBox.Text)
			if num then
				api:Set(num)
			else
				render(value, false)
			end
		else
			render(value, false)
		end
	end))

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

function Elements:RangeSlider(opts)
	opts = opts or {}
	local flag = FlagOf(opts)
	local min = opts.Min or 0
	local max = opts.Max or 100
	local decimals = opts.Decimals or 0
	local default = type(opts.Default) == "table" and opts.Default or {}
	local lo = math.clamp(default[1] or default.Min or opts.DefaultMin or min, min, max)
	local hi = math.clamp(default[2] or default.Max or opts.DefaultMax or max, min, max)
	if lo > hi then lo, hi = hi, lo end
	local defLo, defHi = lo, hi

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

	local name = Label(head, opts.Text or "range", (LabelColor(opts, Theme.Text)))
	name.Size = UDim2.fromOffset(0, 16)
	name.AutomaticSize = Enum.AutomaticSize.X

	local valueLabel = Label(head, "", Theme.TextDim, 12)
	valueLabel.Size = UDim2.fromOffset(0, 16)
	valueLabel.AutomaticSize = Enum.AutomaticSize.X
	valueLabel.LayoutOrder = 2
	Library:Tag(valueLabel, { TextColor3 = "TextDim" })

	local track = New("Frame", {
		Size = UDim2.new(1, 0, 0, 4),
		Position = UDim2.new(0, 0, 0, 24),
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
		Parent = block,
		ThemeTag = { BackgroundColor3 = "Track" },
	})
	Corner(track, 2)
	local fill = New("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
		ThemeTag = { BackgroundColor3 = "Accent" },
	})
	Corner(fill, 2)

	local function knob()
		local k = New("Frame", {
			Size = UDim2.fromOffset(9, 9),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = track,
			ThemeTag = { BackgroundColor3 = "Accent" },
		})
		Corner(k, 5)
		return k
	end
	local knobLo, knobHi = knob(), knob()

	local hit = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 15),
		Position = UDim2.new(0, 0, 0, 16),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = block,
	})

	local api = { Instance = block, Value = { lo, hi } }

	local function format(v)
		local text = decimals > 0 and string.format("%." .. decimals .. "f", v) or tostring(math.floor(v + 0.5))
		return text .. (opts.Suffix or "")
	end

	local function snap(v)
		v = math.clamp(v, min, max)
		if opts.Step then v = min + math.floor((v - min) / opts.Step + 0.5) * opts.Step end
		if decimals == 0 then return math.floor(v + 0.5) end
		local m = 10 ^ decimals
		return math.floor(v * m + 0.5) / m
	end

	local function render(animate)
		local span = (max - min) == 0 and 1 or (max - min)
		local a, b = (lo - min) / span, (hi - min) / span
		local info = animate and EASE_FAST or TweenInfo.new(0)
		Tween(fill, { Position = UDim2.fromScale(a, 0), Size = UDim2.fromScale(b - a, 1) }, info)
		Tween(knobLo, { Position = UDim2.new(a, 0, 0.5, 0) }, info)
		Tween(knobHi, { Position = UDim2.new(b, 0, 0.5, 0) }, info)
		valueLabel.Text = format(lo) .. " - " .. format(hi)
	end

	local function apply(a, b, silent)
		a, b = snap(tonumber(a) or min), snap(tonumber(b) or max)
		if a > b then a, b = b, a end
		local changed = a ~= lo or b ~= hi
		lo, hi = a, b
		api.Value = { lo, hi }
		if flag then
			Library.Flags[flag] = { lo, hi }
			if changed then Library:MarkDirty(flag) end
		end
		render(true)
		if changed and not silent then Library:SafeCallback(opts.Text or "range", opts.Callback, lo, hi) end
	end

	function api:Set(value, silent)
		if type(value) == "table" then apply(value[1] or value.Min, value[2] or value.Max, silent) end
		return self
	end
	function api:SetRange(a, b, silent) apply(a, b, silent) return self end
	function api:Get() return lo, hi end

	local dragging, moveConn, endConn

	local function valueAt(x)
		local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		return min + (max - min) * alpha
	end

	local function drag(x)
		local v = snap(valueAt(x))
		if dragging == "lo" then apply(math.min(v, hi), hi) else apply(lo, math.max(v, lo)) end
	end

	Track(hit.InputBegan:Connect(function(input)
		if api.Enabled == false then return end
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			apply(defLo, defHi)
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local v = valueAt(input.Position.X)
		if lo == hi then
			dragging = v < lo and "lo" or "hi"
		else
			dragging = math.abs(v - lo) <= math.abs(v - hi) and "lo" or "hi"
		end
		local active = dragging == "lo" and knobLo or knobHi
		Tween(active, { Size = UDim2.fromOffset(11, 11) }, EASE_FAST)
		drag(input.Position.X)
		moveConn = UserInputService.InputChanged:Connect(function(move)
			if move.UserInputType == Enum.UserInputType.MouseMovement
				or move.UserInputType == Enum.UserInputType.Touch then
				if dragging then drag(move.Position.X) end
			end
		end)
		endConn = UserInputService.InputEnded:Connect(function(ended)
			if ended.UserInputType == input.UserInputType then
				dragging = nil
				Tween(knobLo, { Size = UDim2.fromOffset(9, 9) }, EASE_FAST)
				Tween(knobHi, { Size = UDim2.fromOffset(9, 9) }, EASE_FAST)
				if moveConn then moveConn:Disconnect() moveConn = nil end
				if endConn then endConn:Disconnect() endConn = nil end
			end
		end)
	end))

	Disableable(api, { name, valueLabel }, opts)

	if flag then
		Library.Flags[flag] = { lo, hi }
		Library:Register(flag, {
			Type = "RangeSlider",
			Get = function() return { lo, hi } end,
			Set = function(v)
				if type(v) == "table" then apply(v[1] or v.Min, v[2] or v.Max) end
			end,
		})
	end
	render(false)
	return api
end

function BuildColorPicker(owner, swatch, opts)
	opts = opts or {}
	local flag = FlagOf(opts)
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
		ThemeTag = { BackgroundColor3 = false },
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
			ThemeTag = { BackgroundColor3 = "Track" },
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
		ClipsDescendants = true,
		LayoutOrder = 3,
		ZIndex = z,
		Parent = panel.Content,
		ThemeTag = { BackgroundColor3 = "Field" },
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
		ThemeTag = { TextColor3 = "TextBright" },
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
			Library.Flags[flag] = ToHex(color, alpha)
			Library:MarkDirty(flag)
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
		Library.Flags[flag] = ToHex(base, alpha)
		Library:Register(flag, {
			Type = "ColorPicker",
			Get = function() return ToHex(current(), alpha) end,
			Set = function(v) api:Set(v) end,
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
		ThemeTag = { BackgroundColor3 = "Field" },
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
		ClipsDescendants = true,
		Parent = row,
		ThemeTag = { BackgroundColor3 = "Field" },
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
		ThemeTag = { PlaceholderColor3 = "TextDim", TextColor3 = "TextBright" },
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

local SEARCHABLE = { "Toggle", "Slider", "RangeSlider", "Dropdown", "Input", "Button", "Keybind", "ColorPicker", "Paragraph", "Label" }

local function IndexEntry(container, text, instance)
	local window = container and container.Window
	local index = window and window.SearchIndex
	if not index or type(text) ~= "string" or text == "" or typeof(instance) ~= "Instance" then return end
	table.insert(index, { Title = text, Instance = instance, Section = container.Title })
end

for _, name in ipairs(SEARCHABLE) do
	local original = Elements[name]
	if original then
		Elements[name] = function(self, opts, ...)
			local api = original(self, opts, ...)
			local text
			if type(opts) == "string" then
				text = opts
			elseif type(opts) == "table" then
				text = opts.Text or opts.Title
			end
			if type(api) == "table" then pcall(IndexEntry, self, text, api.Instance) end
			return api
		end
	end
end

do
	local original = Elements.ButtonRow
	Elements.ButtonRow = function(self, list)
		local api = original(self, list)
		for i, opts in ipairs(list or {}) do
			if type(opts) == "table" and api.Buttons and api.Buttons[i] then
				pcall(IndexEntry, self, opts.Text, api.Buttons[i])
			end
		end
		return api
	end
end

local Section = setmetatable({}, { __index = Elements })
Section.__index = Section

local function CreateSection(window, parent, title, order)
	local borderTitle = Library.SectionTitleStyle == "border"

	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = parent,
		ThemeTag = { BackgroundColor3 = "Section" },
	})
	Corner(frame, 7)
	Stroke(frame, Theme.SectionBorder)

	-- the padded, laid out area, kept separate so an absolutely positioned
	-- title is not captured by the list layout
	local inner = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = frame,
	})
	Pad(inner, borderTitle and 18 or 12, 14, 14, 14)
	local frameList = List(inner, 0)

	local header, htitle, hchev

	if borderTitle then
		-- the title sits on the stroke, its own background hides the line
		header = New("TextButton", {
			Size = UDim2.fromOffset(0, 16),
			AutomaticSize = Enum.AutomaticSize.X,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromOffset(12, 0),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 3,
			Parent = frame,
		})
		Pad(header, 0, 6, 0, 6)

		-- a thin strip on the stroke line only, so the title reads as a
		-- notch in the border instead of a chip sitting on the card
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 3),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Theme.Window,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = header,
			ThemeTag = { BackgroundColor3 = "Window" },
		})

		local row = New("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			ZIndex = 3,
			Parent = header,
		})
		local rowList = List(row, 5, Enum.FillDirection.Horizontal)
		rowList.VerticalAlignment = Enum.VerticalAlignment.Center

		htitle = Label(row, title, Theme.TextBright, Theme.TextSize, Theme.FontMedium)
		htitle.Size = UDim2.new(0, 0, 1, 0)
		htitle.AutomaticSize = Enum.AutomaticSize.X
		htitle.ZIndex = 3

		hchev = Chevron(row, Theme.TextDim)
		hchev.LayoutOrder = 2
		hchev.ZIndex = 3
	else
		header = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			Parent = inner,
		})
		htitle = Label(header, title, Theme.TextBright, Theme.TextSize + 1, Theme.FontMedium)
		htitle.Size = UDim2.new(1, -16, 1, 0)
		hchev = Chevron(header, Theme.TextDim)
		hchev.AnchorPoint = Vector2.new(0, 0.5)
		hchev.Position = UDim2.new(0, htitle.TextBounds.X + 6, 0.5, 1)
		Track(htitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
			hchev.Position = UDim2.new(0, htitle.TextBounds.X + 6, 0.5, 1)
		end))
	end

	local body = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		LayoutOrder = 2,
		Parent = inner,
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
	self.Title = title

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
		List(frame, Library.SectionTitleStyle == "border" and 22 or 14)
		self.Columns[i] = setmetatable({ Window = self.Window, Frame = frame, Order = 0 }, Column)
	end

	self.CurrentBlock = block
	return block
end

function Tab:Column(index)
	self:Block()
	local slot = math.clamp(math.floor(tonumber(index) or 1), 1, #self.Columns)
	return self.Columns[slot]
end

function Tab:Full(title)
	self.Order = self.Order + 1
	local section = CreateSection(self.Window, self.Page, title, self.Order)
	self.CurrentBlock = nil
	return section
end

function Tab:Section(title, columnIndex)
	if columnIndex == "full" or columnIndex == "0" or tonumber(columnIndex) == 0 then
		return self:Full(title)
	end
	return self:Column(columnIndex):Section(title)
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
		ThemeTag = { BackgroundColor3 = "PopupBg" },
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
		ScrollBarImageTransparency = 0.3,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		Visible = false,
		Parent = self.Body,
		ThemeTag = { ScrollBarImageColor3 = "AccentDim" },
	})
	local pageList = List(page, Library.SectionTitleStyle == "border" and 22 or 14)
	pageList.SortOrder = Enum.SortOrder.LayoutOrder
	Pad(page, Library.SectionTitleStyle == "border" and 12 or 2, 8, 2, 8)

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
		ThemeTag = { BackgroundColor3 = "Field" },
	})
	if side then
		Corner(button, 5)
		New("Frame", {
			Size = UDim2.fromOffset(2, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Name = "ActiveBar",
			ZIndex = 2,
			Parent = button,
			ThemeTag = { BackgroundColor3 = "Accent" },
		})
		Corner(button:FindFirstChild("ActiveBar") or button, 2)
	end

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
	tab.Row = row
	if side and self.Collapsed then self:ApplyCollapsedTab(tab, true) end

	local activeBar = side and button:FindFirstChild("ActiveBar") or nil

	function tab:SetActive(active, animate)
		local info = animate and EASE_FAST or TweenInfo.new(0)
		local key = active and "Accent" or "TextDim"
		local color = Theme[key]

		-- retag so the active tab keeps its colour across theme changes
		Library:Tag(label, { TextColor3 = key })
		if icon then Library:Tag(icon, { ImageColor3 = key }) end
		if activeBar then Library:Tag(activeBar, { BackgroundColor3 = "Accent" }) end

		Tween(label, { TextColor3 = color }, info)
		if icon then Tween(icon, { ImageColor3 = color }, info) end
		if side then
			Tween(button, { BackgroundTransparency = active and 0.85 or 1 }, info)
			if activeBar then
				Tween(activeBar, { BackgroundTransparency = active and 0 or 1 }, info)
			end
		end
	end

	table.insert(self.Tabs, tab)

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
	self.TabDividers = self.TabDividers or {}

	local inset = opts.Inset or 12
	local line = New("Frame", {
		Size = UDim2.new(1, -inset * 2, 0, 1),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, inset, 0.5, 0),
		BackgroundColor3 = Theme.BorderSoft,
		BorderSizePixel = 0,
		Parent = holder,
		ThemeTag = { BackgroundColor3 = "BorderSoft" },
	})

	if opts.Text then
		holder.Size = UDim2.new(1, 0, 0, opts.Height or 24)
		line:Destroy()
		local label = Label(holder, opts.Text, Theme.TextDim, Theme.TextSize - 2)
		label.Position = UDim2.fromOffset(inset, 0)
		label.Size = UDim2.new(1, -inset * 2, 1, 0)
		label.TextYAlignment = Enum.TextYAlignment.Bottom
		label.Visible = not self.Collapsed
		local divider = { Instance = holder, Label = label }
		table.insert(self.TabDividers, divider)
		return divider
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
	if self.ClearSearch then self.ClearSearch() end
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
		ThemeTag = { TextColor3 = "Accent" },
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
		ThemeTag = { ImageColor3 = "TextDim" },
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
		ThemeTag = { BackgroundColor3 = false },
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
		ThemeTag = { BackgroundColor3 = "Window" },
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
			ThemeTag = { BackgroundColor3 = "TextDim" },
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
		ThemeTag = { BackgroundColor3 = "BorderSoft" },
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
		ThemeTag = { ScrollBarImageColor3 = "AccentDim" },
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
				blur.Name = "FacilityModalBlur"
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

function Window:ApplyCollapsedTab(tab, collapsed)
	if not tab.Row or not tab.Label then return end
	if collapsed then
		tab.Row.Position = UDim2.fromOffset(tab.Icon and 13 or 0, 0)
		tab.Row.Size = UDim2.new(1, tab.Icon and -13 or 0, 1, 0)
		if tab.Icon then
			tab.Label.Visible = false
		else
			tab.Label.Text = string.upper(string.sub(tab.Name or "?", 1, 1))
			tab.Label.Size = UDim2.fromScale(1, 1)
			tab.Label.TextXAlignment = Enum.TextXAlignment.Center
		end
	else
		tab.Row.Position = UDim2.fromOffset(10, 0)
		tab.Row.Size = UDim2.new(1, -20, 1, 0)
		tab.Label.Visible = true
		tab.Label.Text = tab.Name
		tab.Label.Size = UDim2.new(1, tab.Icon and -22 or 0, 1, 0)
		tab.Label.TextXAlignment = Enum.TextXAlignment.Left
	end
end

function Window:SetCollapsed(state)
	if self.TabStyle ~= "side" or not self.SetSidebarWidth then return false end
	state = state and true or false
	self.Collapsed = state
	self.SetSidebarWidth(state and self.CollapsedWidth or self.TabWidth, true)
	for _, tab in ipairs(self.Tabs) do self:ApplyCollapsedTab(tab, state) end
	for _, divider in ipairs(self.TabDividers or {}) do
		if divider.Label then divider.Label.Visible = not state end
	end
	if self.CollapseButton then self.CollapseButton.Rotate(state) end
	return state
end

function Window:ToggleCollapsed()
	return self:SetCollapsed(not self.Collapsed)
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

	-- load the saved theme before anything is drawn, so the key system,
	-- the main window and every later element share the same palette
	pcall(function()
		local folder = opts.ThemeFolder or opts.Folder or "Facility"
		local path = folder .. "/settings/theme.json"
		if not (isfile and isfile(path)) then return end

		local raw = readfile(path)
		if not raw then return end

		local ok, data = pcall(function()
			return game:GetService("HttpService"):JSONDecode(raw)
		end)
		if not ok or type(data) ~= "table" or type(data.Colors) ~= "table" then return end

		for key, hex in pairs(data.Colors) do
			if Theme[key] ~= nil then
				local color, alpha = FromHex(hex)
				if color then
					Theme[key] = color
					if alpha then ThemeAlpha[key] = alpha end
				end
			end
		end

		if type(data.Glass) == "boolean" then Library.Glass = data.Glass end
		if type(data.GlassBlur) == "boolean" then Library.GlassBlur = data.GlassBlur end
		if tonumber(data.GlassStrength) then Library.GlassStrength = tonumber(data.GlassStrength) end

		-- the value to key map must follow, otherwise every element built
		-- from here on is never recorded in the repaint registry
		IndexTheme()
	end)

	-- ---- Discord RPC ----
	if opts.Discord and opts.Discord.Enabled ~= false and opts.Discord.Invite then
		local inv = opts.Discord.Invite
		local remember = opts.Discord.RememberJoins ~= false
		local joined = false

		if remember then
			pcall(function()
				if isfile and isfile("facility_discord_" .. inv .. ".dat") then
					joined = true
				end
			end)
		end

		if not joined then
			pcall(function()
				local req = request or http_request or (http and http.request)
				if not req then return end
				req({
					Url = "http://127.0.0.1:6463/rpc?v=1",
					Method = "POST",
					Headers = {
						["Content-Type"] = "application/json",
						["Origin"] = "https://discord.com",
					},
					Body = game:GetService("HttpService"):JSONEncode({
						cmd = "INVITE_BROWSER",
						args = { code = inv },
						nonce = tick(),
					}),
				})
				if remember then
					pcall(function()
						if writefile then
							writefile("facility_discord_" .. inv .. ".dat", "1")
						end
					end)
				end
			end)
		end
	end

	-- ---- Key system ----
	if opts.KeySystem then
		local ks = opts.KeySettings or {}
		local title = ks.Title or "Key System"
		local subtitle = ks.Subtitle or "Enter your key to continue"
		local note = ks.Note or ""
		local fileName = (ks.FileName or "key") .. ".dat"
		local saveKey = ks.SaveKey ~= false
		local grabFromSite = ks.GrabKeyFromSite == true
		local keys = ks.Key or {}

		local keyValid = false

		-- check saved key
		if saveKey then
			pcall(function()
				if isfile and isfile(fileName) then
					local saved = readfile(fileName)
					if saved then saved = saved:gsub("%s+", "") end
					local validKeys = keys
					if grabFromSite and type(keys) == "table" then
						local fresh = {}
						for _, url in ipairs(keys) do
							pcall(function()
								local res = game:HttpGet(url)
								if res then
									for _, line in ipairs(string.split(res, "\n")) do
										table.insert(fresh, line:gsub("%s+", ""))
									end
								end
							end)
						end
						if #fresh > 0 then validKeys = fresh end
					end
					for _, k in ipairs(validKeys) do
						if saved == k:gsub("%s+", "") then
							keyValid = true
							break
						end
					end
				end
			end)
		end

		if not keyValid then
			local gui = New("ScreenGui", {
				Name = RandomName(),
				ResetOnSpawn = false,
				IgnoreGuiInset = true,
				AutoLocalize = false,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				DisplayOrder = ORDER_KEYSYSTEM,
			})
			ParentGui(gui)

			local card = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(520, 178),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Theme.Window,
				BorderSizePixel = 0,
				Active = true,
				Parent = gui,
				ThemeTag = { BackgroundColor3 = "Window" },
			})
			Corner(card, 9)
			Stroke(card, Theme.WindowBorder)

			-- shadow
			local shadowHolder = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(1, 35, 1.096, 35),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Parent = card,
			})
			New("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				ZIndex = 0,
				Image = "rbxassetid://5587865193",
				ImageColor3 = Color3.fromRGB(20, 20, 20),
				Size = UDim2.new(1.6, 0, 1.3, 0),
				Position = UDim2.fromScale(0.5, 0.5),
				ImageTransparency = 0.5,
				Parent = shadowHolder,
			})

			-- title / subtitle (no logo)
			local ksTitle = Label(card, title, Theme.TextBright, 14, Theme.FontMedium)
			ksTitle.Position = UDim2.fromOffset(24, 22)
			ksTitle.Size = UDim2.fromOffset(200, 16)

			local ksSub = Label(card, subtitle, Theme.TextDim, 12)
			ksSub.Position = UDim2.fromOffset(24, 40)
			ksSub.Size = UDim2.fromOffset(200, 13)

			-- right side: Get Key + description
			local announce = Label(card, "Get Key", Theme.TextBright, 14, Theme.FontMedium)
			announce.Position = UDim2.fromOffset(286, 22)
			announce.Size = UDim2.fromOffset(210, 16)

			local descr = New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(210, 60),
				Position = UDim2.fromOffset(286, 42),
				TextColor3 = Theme.TextDim,
				RichText = true,
				Text = note ~= "" and note or ('To obtain the key, simply click on <font color="rgb(232,161,168)">Get-Key</font>. This will copy the key link to your clipboard. For any help, don\'t hesitate to ask on our Discord by clicking on <font color="rgb(120,170,230)">Discord</font>.'),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				Font = Theme.Font,
				TextSize = 12,
				Parent = card,
				ThemeTag = { TextColor3 = "TextDim" },
			})

			-- vertical divider
			New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(262, 89),
				Size = UDim2.new(0, 1, 1, -44),
				BackgroundColor3 = Theme.BorderSoft,
				BorderSizePixel = 0,
				Parent = card,
				ThemeTag = { BackgroundColor3 = "BorderSoft" },
			})

			-- input
			local field = New("Frame", {
				Position = UDim2.fromOffset(24, 68),
				Size = UDim2.fromOffset(214, 32),
				BackgroundColor3 = Theme.Field,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Parent = card,
				ThemeTag = { BackgroundColor3 = "Field" },
			})
			Corner(field, 6)
			Stroke(field, Theme.Border)

			local box = New("TextBox", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -15, 0, 14),
				Position = UDim2.new(0.517, 0, 0.5, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				PlaceholderText = "Input script key here...",
				PlaceholderColor3 = Theme.TextDim,
				Font = Theme.Font,
				TextColor3 = Theme.Text,
				TextSize = Theme.TextSize,
				Text = "",
				ClearTextOnFocus = false,
				Parent = field,
				ThemeTag = { PlaceholderColor3 = "TextDim", TextColor3 = "Text" },
			})

			-- validate button
			local validateFrame = New("Frame", {
				Position = UDim2.fromOffset(61, 124),
				Size = UDim2.fromOffset(140, 30),
				BackgroundColor3 = Theme.Accent,
				BorderSizePixel = 0,
				Parent = card,
				ThemeTag = { BackgroundColor3 = "Accent" },
			})
			Corner(validateFrame, 6)

			local btn = New("TextButton", {
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = "Validate Key",
				TextColor3 = Color3.fromRGB(40, 32, 34),
				TextSize = Theme.TextSize,
				Font = Theme.FontMedium,
				Parent = validateFrame,
			})

			local errorLabel = Label(card, "", Theme.Danger, 11)
			errorLabel.Position = UDim2.fromOffset(24, 104)
			errorLabel.Size = UDim2.fromOffset(214, 14)
			errorLabel.Visible = false

			-- get key button
			if ks.GetKey then
				local gkFrame = New("Frame", {
					Position = UDim2.fromOffset(286, 124),
					Size = UDim2.fromOffset(100, 30),
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
					Parent = card,
					ThemeTag = { BackgroundColor3 = "Accent" },
				})
				Corner(gkFrame, 6)
				local gkBtn = New("TextButton", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					AutoButtonColor = false,
					Text = "Get-Key",
					TextColor3 = Color3.fromRGB(40, 32, 34),
					TextSize = Theme.TextSize,
					Font = Theme.FontMedium,
					Parent = gkFrame,
				})
				Track(gkBtn.Activated:Connect(function()
					pcall(function() if setclipboard then setclipboard(ks.GetKey) end end)
				end))
			end

			-- discord button
			if ks.Discord then
				local dcFrame = New("Frame", {
					Position = UDim2.fromOffset(396, 124),
					Size = UDim2.fromOffset(100, 30),
					BackgroundColor3 = Theme.Field,
					BorderSizePixel = 0,
					Parent = card,
					ThemeTag = { BackgroundColor3 = "Field" },
				})
				Corner(dcFrame, 6)
				Stroke(dcFrame, Theme.Border)
				local dcBtn = New("TextButton", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					AutoButtonColor = false,
					Text = "Discord",
					TextColor3 = Theme.TextBright,
					TextSize = Theme.TextSize,
					Font = Theme.FontMedium,
					Parent = dcFrame,
					ThemeTag = { TextColor3 = "TextBright" },
				})
				Track(dcBtn.Activated:Connect(function()
					pcall(function()
						if setclipboard then setclipboard("https://discord.gg/" .. ks.Discord) end
					end)
				end))
			end

			-- draggable
			do
				local dragging, dragStart, startPos = false, nil, nil
				local targetPosition = card.Position
				local activeInput = nil
				Track(card.InputBegan:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1
						and input.UserInputType ~= Enum.UserInputType.Touch then return end
					if dragging then return end
					dragging = true
					activeInput = input
					dragStart = input.Position
					startPos = card.Position
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
							activeInput = nil
						end
					end)
				end))
				Track(UserInputService.InputChanged:Connect(function(input)
					if not dragging then return end
					if input ~= activeInput and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
					if input.UserInputType ~= Enum.UserInputType.MouseMovement
						and input.UserInputType ~= Enum.UserInputType.Touch then return end
					local delta = input.Position - dragStart
					card.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end))
			end

						local done = false
			local function validate()
				if done then return end
				local input = box.Text:gsub("%s+", "")
				if input == "" then return end

				local validKeys = keys
				if grabFromSite then
					local fresh = {}
					for _, url in ipairs(keys) do
						pcall(function()
							local res = game:HttpGet(url)
							if res then
									for _, line in ipairs(string.split(res, "\n")) do
									table.insert(fresh, line:gsub("%s+", ""))
								end
							end
						end)
					end
					if #fresh > 0 then validKeys = fresh end
				end

				local ok = false
				for _, k in ipairs(validKeys) do
					if input == k:gsub("%s+", "") then ok = true break end
				end

				if ok then
					done = true
					if saveKey then
						pcall(function()
							if writefile then writefile(fileName, input) end
						end)
					end
					gui:Destroy()
				else
					errorLabel.Text = "invalid key, try again."
					errorLabel.Visible = true
				end
			end

			Track(btn.Activated:Connect(validate))
			Track(box.FocusLost:Connect(function(enter) if enter then validate() end end))

			repeat task.wait() until done
			gui:Destroy()
		end
	end


	local gui = New("ScreenGui", {
		Name = RandomName(),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
		IgnoreGuiInset = true,
		DisplayOrder = ORDER_WINDOW,
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
		ThemeTag = { BackgroundColor3 = "Window" },
	})
	Corner(main, 10)
	Stroke(main, Theme.WindowBorder)
	local scale = New("UIScale", { Parent = main })

	local topBar = New("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = Theme.TopBar,
		BorderSizePixel = 0,
		Parent = main,
		ThemeTag = { BackgroundColor3 = "TopBar" },
	})
	Corner(topBar, 10)
	New("Frame", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = Theme.TopBar,
		BorderSizePixel = 0,
		Parent = topBar,
		ThemeTag = { BackgroundColor3 = "TopBar" },
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

	local titleName = Label(title, opts.Title or "facility", Theme.TextBright, 14, Theme.FontMedium)
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
		ThemeTag = { BackgroundColor3 = "Border" },
	})

	if opts.SectionTitleStyle == "border" or opts.SectionTitle == "border" then
		Library.SectionTitleStyle = "border"
	elseif opts.SectionTitleStyle == "inline" or opts.SectionTitle == "inline" then
		Library.SectionTitleStyle = "inline"
	end

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
		ThemeTag = { BackgroundColor3 = "BorderSoft" },
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
			ThemeTag = { BackgroundColor3 = "BorderSoft" },
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
		SearchIndex = {},
		TabDividers = {},
		Shell = shell,
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

	local dragging, dragStart, startPos = false, nil, nil
	local activeInput = nil
	local targetPos = main.Position

	Track(topBar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		if dragging then return end
		dragging = true
		activeInput = input
		dragStart = input.Position
		startPos = main.Position
		targetPos = main.Position
		window:CloseFloating()
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				activeInput = nil
			end
		end)
	end))

	Track(UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		-- only the finger or cursor that started the drag may move the window
		if input ~= activeInput and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
			ThemeTag = { BackgroundColor3 = "Border" },
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

	if tabStyle == "side" then
		window.CollapsedWidth = opts.CollapsedWidth or 44
		local shellTop = 58
		local sideHeight = -(47 + footerHeight + 22)

		window.SetSidebarWidth = function(w, animate)
			local info = animate and EASE or TweenInfo.new(0)
			local left = 14 + w + 10
			Tween(tabBar, { Size = UDim2.new(0, w, 1, sideHeight) }, info)
			Tween(shell, {
				Position = UDim2.fromOffset(left, shellTop),
				Size = UDim2.new(1, -(14 + left), 1, sideHeight),
			}, info)
		end

		if opts.Collapsible ~= false then
			title.Position = UDim2.fromOffset(44, 0)

			local toggle = New("TextButton", {
				Size = UDim2.fromOffset(22, 22),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 14, 0.5, 0),
				BackgroundColor3 = Theme.Field,
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = "",
				Parent = topBar,
				ThemeTag = { BackgroundColor3 = "Field" },
			})
			Corner(toggle, 5)
			local bars = {}
			for i = 1, 3 do
				local bar = New("Frame", {
					Size = UDim2.fromOffset(i == 2 and 10 or 14, 2),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 4, 0.5, (i - 2) * 5),
					BackgroundColor3 = Theme.TextDim,
					BorderSizePixel = 0,
					Parent = toggle,
					ThemeTag = { BackgroundColor3 = "TextDim" },
				})
				Corner(bar, 1)
				bars[i] = bar
			end
			Track(toggle.MouseEnter:Connect(function()
				Tween(toggle, { BackgroundTransparency = 0.4 }, EASE_FAST)
				for _, bar in ipairs(bars) do Tween(bar, { BackgroundColor3 = Theme.Accent }, EASE_FAST) end
			end))
			Track(toggle.MouseLeave:Connect(function()
				Tween(toggle, { BackgroundTransparency = 1 }, EASE_FAST)
				for _, bar in ipairs(bars) do Tween(bar, { BackgroundColor3 = Theme.TextDim }, EASE_FAST) end
			end))
			Track(toggle.Activated:Connect(function()
				window:ToggleCollapsed()
			end))
			window.CollapseButton = {
				Instance = toggle,
				Rotate = function(collapsed)
					Tween(bars[2], { Size = UDim2.fromOffset(collapsed and 14 or 10, 2) }, EASE_FAST)
				end,
			}
		end

		if opts.Search ~= false then
			local searchWidth = opts.SearchWidth or 180
			local field = New("Frame", {
				Size = UDim2.fromOffset(searchWidth, 26),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				BackgroundColor3 = Theme.Field,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Parent = topBar,
				ThemeTag = { BackgroundColor3 = "Field" },
			})
			Corner(field, 5)
			local fieldStroke = Stroke(field, Theme.Border)
			local searchIcon = AttachIcon(field, "search", Theme.TextDim, 13)
			if searchIcon then
				searchIcon.AnchorPoint = Vector2.new(0, 0.5)
				searchIcon.Position = UDim2.new(0, 8, 0.5, 0)
				Library:Tag(searchIcon, { ImageColor3 = "TextDim" })
			end
			local textLeft = searchIcon and 27 or 9
			local box = New("TextBox", {
				Size = UDim2.new(1, -(textLeft + 24), 1, 0),
				Position = UDim2.fromOffset(textLeft, 0),
				BackgroundTransparency = 1,
				Text = "",
				PlaceholderText = opts.SearchPlaceholder or "search...",
				PlaceholderColor3 = Theme.TextDim,
				TextColor3 = Theme.TextBright,
				TextSize = 12,
				Font = Theme.Font,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
				ClipsDescendants = true,
				Parent = field,
				ThemeTag = { PlaceholderColor3 = "TextDim", TextColor3 = "TextBright" },
			})
			local clear = New("TextButton", {
				Size = UDim2.fromOffset(18, 18),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -4, 0.5, 0),
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = "×",
				TextColor3 = Theme.TextDim,
				TextSize = 15,
				Font = Theme.FontMedium,
				Visible = false,
				Parent = field,
				ThemeTag = { TextColor3 = "TextDim" },
			})

			local results = New("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Theme.PopupBg,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 60,
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = Theme.AccentDim,
				Parent = shell,
				ThemeTag = { BackgroundColor3 = "PopupBg", ScrollBarImageColor3 = "AccentDim" },
			})
			Corner(results, 8)
			List(results, 6)
			Pad(results, 12, 12, 12, 12)

			local rows, selected = {}, 0

			local function escape(text)
				return (string.gsub(string.gsub(string.gsub(text, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
			end

			local function highlight(text, query)
				local lower, out, pos = string.lower(text), {}, 1
				local hex = "#" .. Theme.Accent:ToHex()
				while true do
					local a, b = string.find(lower, query, pos, true)
					if not a then break end
					table.insert(out, escape(string.sub(text, pos, a - 1)))
					table.insert(out, '<font color="' .. hex .. '"><b>' .. escape(string.sub(text, a, b)) .. "</b></font>")
					pos = b + 1
				end
				table.insert(out, escape(string.sub(text, pos)))
				return table.concat(out)
			end

			local function tabOf(instance)
				for _, tab in ipairs(window.Tabs) do
					if instance:IsDescendantOf(tab.Page) then return tab end
				end
				return nil
			end

			local function flash(instance)
				local glow = New("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Theme.Accent,
					BackgroundTransparency = 0.7,
					BorderSizePixel = 0,
					ZIndex = 20,
					Parent = instance,
				})
				Corner(glow, 5)
				Tween(glow, { BackgroundTransparency = 1 }, TweenInfo.new(0.9, Enum.EasingStyle.Quad))
				task.delay(0.95, function() pcall(function() glow:Destroy() end) end)
			end

			local function go(entry)
				local tab = entry.Tab
				box:ReleaseFocus()
				box.Text = ""
				if not tab then return end
				window:SetTab(tab)
				task.delay(0.1, function()
					local page, instance = tab.Page, entry.Instance
					if not (page and instance.Parent) then return end
					local s = math.max(scale.Scale, 0.05)
					local y = (instance.AbsolutePosition.Y - page.AbsolutePosition.Y) / s + page.CanvasPosition.Y - 24
					page.CanvasPosition = Vector2.new(0, math.max(0, y))
					flash(instance)
				end)
			end

			local function pick(index)
				selected = index
				for i, row in ipairs(rows) do
					local on = i == index
					Tween(row.Button, { BackgroundColor3 = on and Theme.FieldHover or Theme.Field }, EASE_FAST)
					Tween(row.Bar, { BackgroundTransparency = on and 0 or 0.6 }, EASE_FAST)
				end
			end

			local function refresh()
				for _, child in ipairs(results:GetChildren()) do
					if child:IsA("GuiObject") then child:Destroy() end
				end
				rows, selected = {}, 0

				local raw = box.Text or ""
				local query = string.lower(string.match(raw, "^%s*(.-)%s*$"))
				clear.Visible = raw ~= ""
				results.Visible = query ~= ""
				if query == "" then return end
				window:CloseFloating()

				local count = 0
				for _, entry in ipairs(window.SearchIndex) do
					if entry.Instance.Parent and string.find(string.lower(entry.Title), query, 1, true) then
						local tab = tabOf(entry.Instance)
						if tab then
							count = count + 1
							local index = count
							local button = New("TextButton", {
								Size = UDim2.new(1, 0, 0, 40),
								BackgroundColor3 = Theme.Field,
								AutoButtonColor = false,
								Text = "",
								LayoutOrder = count,
								ZIndex = 61,
								Parent = results,
							})
							Corner(button, 5)
							Stroke(button, Theme.Border)
							local bar = New("Frame", {
								Size = UDim2.fromOffset(3, 22),
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 0, 0.5, 0),
								BackgroundColor3 = Theme.Accent,
								BackgroundTransparency = 0.6,
								BorderSizePixel = 0,
								ZIndex = 62,
								Parent = button,
							})
							Corner(bar, 2)
							local name = Label(button, highlight(entry.Title, query), Theme.TextBright)
							name.Position = UDim2.fromOffset(12, 4)
							name.Size = UDim2.new(1, -24, 0, 17)
							name.TextTruncate = Enum.TextTruncate.AtEnd
							name.ZIndex = 62
							local path = tab.Name .. (entry.Section and (" > " .. entry.Section) or "")
							local sub = Label(button, escape(path), Theme.TextDim, 11)
							sub.Position = UDim2.fromOffset(12, 21)
							sub.Size = UDim2.new(1, -24, 0, 14)
							sub.TextTruncate = Enum.TextTruncate.AtEnd
							sub.ZIndex = 62

							entry.Tab = tab
							rows[index] = { Button = button, Bar = bar, Entry = entry }
							Track(button.MouseEnter:Connect(function() pick(index) end))
							Track(button.Activated:Connect(function() go(entry) end))
							if count >= 50 then break end
						end
					end
				end

				if count == 0 then
					local empty = Label(results, 'no results for "' .. escape(raw) .. '"', Theme.TextDim)
					empty.Size = UDim2.new(1, 0, 0, 28)
					empty.ZIndex = 61
				else
					pick(1)
				end
			end

			Track(box:GetPropertyChangedSignal("Text"):Connect(refresh))
			Track(box.Focused:Connect(function()
				Tween(fieldStroke, { Color = Theme.Accent }, EASE_FAST)
			end))
			Track(box.FocusLost:Connect(function(enter, input)
				Tween(fieldStroke, { Color = Theme.Border }, EASE_FAST)
				if enter and rows[selected] then
					go(rows[selected].Entry)
				elseif input and input.KeyCode == Enum.KeyCode.Escape then
					box.Text = ""
				end
			end))
			Track(clear.Activated:Connect(function()
				box.Text = ""
				box:CaptureFocus()
			end))
			Track(UserInputService.InputBegan:Connect(function(input)
				if not box:IsFocused() or #rows == 0 then return end
				if input.KeyCode == Enum.KeyCode.Down then
					pick(math.min(#rows, selected + 1))
				elseif input.KeyCode == Enum.KeyCode.Up then
					pick(math.max(1, selected - 1))
				end
			end))

			window.SearchBox = box
			window.ClearSearch = function()
				if box.Text ~= "" then box.Text = "" end
			end
			window.FocusSearch = function() box:CaptureFocus() end
		end

		if opts.Collapsed then window:SetCollapsed(true) end
	end

	New("TextButton", {
		Name = RandomName(),
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
		Text = "",
		Modal = true,
		Selectable = false,
		Parent = main,
	})

	if opts.UnlockMouse == false then Library.UnlockMouse = false end

	if opts.Glass ~= nil then Library.Glass = opts.Glass and true or false end
	if opts.GlassBlur ~= nil then Library.GlassBlur = opts.GlassBlur and true or false end

	table.insert(Library.Windows, window)
	Library:BindMouseUnlock()
	if Library.Glass then Library:SetGlass(true) end
	return window
end

Library.UnlockMouse = true

function Library:MenuOpen()
	for _, w in ipairs(self.Windows) do
		if w.Visible and w.Main and w.Main.Visible and w.Gui and w.Gui.Enabled ~= false then return true end
	end
	return false
end

function Library:ReleaseMouse()
	local saved = self.MouseSaved
	if not saved then return end
	self.MouseSaved = nil
	pcall(function()
		if UserInputService.MouseIconEnabled ~= saved.Icon then UserInputService.MouseIconEnabled = saved.Icon end
	end)
end

function Library:BindMouseUnlock()
	if self.MouseBind then return end
	self.MouseBind = RandomName()

	pcall(function() RunService:BindToRenderStep(self.MouseBind, Enum.RenderPriority.Last.Value, function()
		if not (self.UnlockMouse and self:MenuOpen()) then
			self:ReleaseMouse()
			return
		end

		if not self.MouseSaved then
			self.MouseSaved = { Icon = UserInputService.MouseIconEnabled }
		end

		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
		if not self.CursorEnabled and not UserInputService.MouseIconEnabled then
			UserInputService.MouseIconEnabled = true
		end
	end) end)
end

local BLUR_DISTANCE = 0.001
local BlurState = {}

function Library:StopBlur()
	if BlurState.Conn then BlurState.Conn:Disconnect() BlurState.Conn = nil end
	local dof, part = BlurState.Dof, BlurState.Part
	BlurState.Dof, BlurState.Part, BlurState.Mesh = nil, nil, nil
	if part then pcall(function() part:Destroy() end) end
	if dof then
		pcall(function()
			TweenService:Create(dof, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { NearIntensity = 0 }):Play()
		end)
		task.delay(0.25, function() pcall(function() dof:Destroy() end) end)
	end
end

function Library:BlurStep()
	local camera = workspace.CurrentCamera
	local part, mesh = BlurState.Part, BlurState.Mesh
	if not (camera and part and mesh) then return end

	local main
	for _, w in ipairs(self.Windows) do
		if w.Visible and w.Main and w.Main.Parent and w.Main.Visible then main = w.Main break end
	end
	if not main then
		if part.Parent then part.Parent = nil end
		return
	end

	local position, size = main.AbsolutePosition, main.AbsoluteSize
	local inset = 0
	pcall(function()
		inset = GuiService:GetGuiInset().Y
		local bar = GuiService.TopbarInset
		if bar and bar.Height > inset then inset = bar.Height end
	end)
	position = position + Vector2.new(0, inset) + (self.GlassBlurOffset or Vector2.zero)

	local shrink = math.clamp(8 + camera.ViewportSize.Y / 2560 * 48, 8, 56)
	local x0, y0 = position.X + shrink, position.Y + shrink
	local x1, y1 = position.X + size.X - shrink, position.Y + size.Y - shrink
	if x1 <= x0 or y1 <= y0 then return end

	local function at(x, y)
		local ray = camera:ViewportPointToRay(x, y)
		return ray.Origin + ray.Direction * BLUR_DISTANCE
	end
	local topLeft, topRight, bottomRight = at(x0, y0), at(x1, y0), at(x1, y1)
	part.CFrame = CFrame.fromMatrix((topLeft + bottomRight) / 2, camera.CFrame.RightVector, camera.CFrame.UpVector)
	mesh.Scale = Vector3.new((topRight - topLeft).Magnitude, (topRight - bottomRight).Magnitude, 0)
	if part.Parent ~= camera then part.Parent = camera end
end

function Library:StartBlur()
	if BlurState.Conn then return end

	local dof = Instance.new("DepthOfFieldEffect")
	dof.Name = RandomName()
	dof.FarIntensity = 0
	dof.InFocusRadius = 0.1
	dof.FocusDistance = 0.05
	dof.NearIntensity = 0
	pcall(function() dof.Parent = Lighting end)

	local part = Instance.new("Part")
	part.Name = RandomName()
	part.Color = Color3.new(0, 0, 0)
	part.Material = Enum.Material.Glass
	part.Size = Vector3.new(1, 1, 0)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Locked = true
	part.CastShadow = false
	part.Transparency = 0.98

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Brick
	mesh.Offset = Vector3.new(0, 0, -0.000001)
	mesh.Parent = part

	BlurState.Dof, BlurState.Part, BlurState.Mesh = dof, part, mesh
	pcall(function()
		TweenService:Create(dof, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { NearIntensity = 1 }):Play()
	end)
	BlurState.Conn = RunService.RenderStepped:Connect(function()
		pcall(self.BlurStep, self)
	end)
end

function Library:UpdateBlur()
	if self.Glass and self.GlassBlur ~= false and #self.Windows > 0 then
		self:StartBlur()
	else
		self:StopBlur()
	end
end

function Library:SetGlass(state)
	state = state and true or false
	self.Glass = state
	RemoveGlass()
	if state then
		for inst in pairs(Painted) do pcall(ApplyGlass, inst) end
	end
	self:UpdateBlur()
	return state
end

function Library:SetGlassStrength(value)
	self.GlassStrength = math.clamp(tonumber(value) or 1, 0, 1.5)
	if self.Glass then
		RemoveGlass()
		for inst in pairs(Painted) do pcall(ApplyGlass, inst) end
	end
	return self.GlassStrength
end

function Library:SetGlassBlur(state)
	self.GlassBlur = state and true or false
	self:UpdateBlur()
	return self.GlassBlur
end

function Library:Watermark(opts)
	if type(opts) ~= "table" then opts = { Title = opts } end
	if self.WatermarkApi and not self.WatermarkApi.Dead then self.WatermarkApi:Destroy() end

	local gui = New("ScreenGui", {
		Name = RandomName(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
		DisplayOrder = ORDER_HOTKEYS - 1,
	})
	ParentGui(gui)

	local margin = opts.Margin or 16
	local root = New("Frame", {
		Size = UDim2.fromOffset(0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		Active = true,
		Visible = opts.Visible ~= false,
		Parent = gui,
		ThemeTag = { BackgroundColor3 = "Window" },
	})
	Corner(root, 7)
	Stroke(root, Theme.WindowBorder)
	Pad(root, 0, 12, 0, 12)
	local rootList = List(root, 10, Enum.FillDirection.Horizontal)
	rootList.VerticalAlignment = Enum.VerticalAlignment.Center

	local api = { Gui = gui, Frame = root, Visible = root.Visible, Items = {}, Dead = false }

	local function place(corner)
		corner = tostring(corner or "TopRight")
		local right = string.find(corner, "Right") ~= nil
		local bottom = string.find(corner, "Bottom") ~= nil
		root.AnchorPoint = Vector2.new(right and 1 or 0, bottom and 1 or 0)
		root.Position = UDim2.new(right and 1 or 0, right and -margin or margin, bottom and 1 or 0, bottom and -margin or margin)
	end
	if typeof(opts.Position) == "UDim2" then root.Position = opts.Position else place(opts.Position) end

	local icon = AttachIcon(root, opts.Icon, Theme.Accent, 15)
	if icon then
		icon.LayoutOrder = 0
		Library:Tag(icon, { ImageColor3 = "Accent" })
	end

	local title = New("Frame", {
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Visible = opts.Title ~= false,
		Parent = root,
	})
	List(title, 0, Enum.FillDirection.Horizontal).VerticalAlignment = Enum.VerticalAlignment.Center
	local titleName = Label(title, tostring(opts.Title or "facility"), Theme.TextBright, Theme.TextSize, Theme.FontMedium)
	titleName.Size = UDim2.fromScale(0, 1)
	titleName.AutomaticSize = Enum.AutomaticSize.X
	local titleSuffix = Label(title, tostring(opts.Suffix or ""), Theme.Accent, Theme.TextSize, Theme.FontMedium)
	titleSuffix.Size = UDim2.fromScale(0, 1)
	titleSuffix.AutomaticSize = Enum.AutomaticSize.X
	titleSuffix.LayoutOrder = 2
	titleSuffix.Visible = (opts.Suffix or "") ~= ""
	Library:Tag(titleName, { TextColor3 = "TextBright" })
	Library:Tag(titleSuffix, { TextColor3 = "Accent" })

	local order = 10

	function api:Add(name, value)
		order = order + 1
		local item = {}
		local getter

		local holder = New("Frame", {
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			LayoutOrder = order,
			Parent = root,
		})
		List(holder, 6, Enum.FillDirection.Horizontal).VerticalAlignment = Enum.VerticalAlignment.Center

		New("Frame", {
			Size = UDim2.fromOffset(1, 14),
			BackgroundColor3 = Theme.BorderSoft,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Parent = holder,
			ThemeTag = { BackgroundColor3 = "BorderSoft" },
		})
		local nameLabel = Label(holder, tostring(name or ""), Theme.TextDim, 12)
		nameLabel.Size = UDim2.fromScale(0, 1)
		nameLabel.AutomaticSize = Enum.AutomaticSize.X
		nameLabel.LayoutOrder = 2
		nameLabel.Visible = name ~= nil and name ~= ""
		Library:Tag(nameLabel, { TextColor3 = "TextDim" })

		local valueLabel = Label(holder, "", Theme.TextBright, 12, Theme.FontMedium)
		valueLabel.Size = UDim2.fromScale(0, 1)
		valueLabel.AutomaticSize = Enum.AutomaticSize.X
		valueLabel.LayoutOrder = 3
		Library:Tag(valueLabel, { TextColor3 = "TextBright" })

		local function show(v) valueLabel.Text = tostring(v == nil and "" or v) end

		function item.Refresh()
			if not getter then return end
			local ok, v = pcall(getter)
			if ok then show(v) end
		end
		function item:Set(v)
			if type(v) == "function" then
				getter = v
				item.Refresh()
			else
				getter = nil
				show(v)
			end
			return self
		end
		function item:SetName(n)
			nameLabel.Text = tostring(n or "")
			nameLabel.Visible = n ~= nil and n ~= ""
			return self
		end
		function item:SetVisible(v) holder.Visible = v and true or false return self end
		function item:Remove()
			for i, x in ipairs(api.Items) do
				if x == item then table.remove(api.Items, i) break end
			end
			holder:Destroy()
		end

		item:Set(value)
		table.insert(api.Items, item)
		return item
	end

	local fps, acc, frames = 60, 0, 0
	local fpsConn = RunService.RenderStepped:Connect(function(dt)
		acc = acc + dt
		frames = frames + 1
		if acc >= 0.5 then
			fps = math.floor(frames / acc + 0.5)
			acc, frames = 0, 0
		end
	end)

	local function ping()
		local ok, v = pcall(function()
			return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if ok and v then return math.floor(v + 0.5) .. " ms" end
		return "n/a"
	end

	function api:AddFPS() return self:Add("fps", function() return fps end) end
	function api:AddPing() return self:Add("ping", ping) end
	function api:AddTime() return self:Add(nil, function() return os.date("%H:%M:%S") end) end
	function api:AddPlayer()
		return self:Add(nil, function()
			local player = Players.LocalPlayer
			return player and player.DisplayName or ""
		end)
	end
	function api:AddFlag(name, flag)
		return self:Add(name, function()
			local v = Library.Flags[flag]
			if type(v) == "boolean" then return v and "on" or "off" end
			if type(v) == "table" then return table.concat(v, ", ") end
			return v
		end)
	end

	function api:SetTitle(text, suffix)
		titleName.Text = tostring(text or "")
		title.Visible = text ~= nil and text ~= false and text ~= ""
		if suffix ~= nil then
			titleSuffix.Text = tostring(suffix)
			titleSuffix.Visible = suffix ~= ""
		end
		return self
	end
	function api:SetPosition(corner)
		if typeof(corner) == "UDim2" then
			root.AnchorPoint = Vector2.zero
			root.Position = corner
		else
			place(corner)
		end
		return self
	end
	function api:SetVisible(v)
		self.Visible = v and true or false
		root.Visible = self.Visible
		return self
	end
	function api:Toggle() return self:SetVisible(not self.Visible) end
	function api:Destroy()
		if self.Dead then return end
		self.Dead = true
		pcall(function() fpsConn:Disconnect() end)
		pcall(function() gui:Destroy() end)
		if Library.WatermarkApi == self then Library.WatermarkApi = nil end
	end

	if opts.Draggable ~= false then
		local dragging, dragStart, startPos
		Track(root.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch then return end
			dragging = true
			dragStart = input.Position
			startPos = root.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end))
		Track(UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement
				and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local delta = input.Position - dragStart
			root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end))
	end

	local builtin = { FPS = api.AddFPS, Ping = api.AddPing, Time = api.AddTime, Player = api.AddPlayer }
	for _, entry in ipairs(opts.Items or { "FPS", "Ping" }) do
		if type(entry) == "string" and builtin[entry] then
			builtin[entry](api)
		elseif type(entry) == "table" then
			api:Add(entry.Name or entry.Title, entry.Value)
		end
	end

	local interval = opts.Interval or 0.5
	task.spawn(function()
		while not api.Dead do
			for _, item in ipairs(api.Items) do item.Refresh() end
			task.wait(interval)
		end
	end)

	self.WatermarkApi = api
	return api
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
			Name = RandomName(),
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
			DisplayOrder = ORDER_NOTIFY,
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
		ThemeTag = { BackgroundColor3 = "Section" },
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
		ThemeTag = { BackgroundColor3 = "Section" },
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

	card.Position = UDim2.new(1, 0, 0, 0)
	card.BackgroundTransparency = 0
	Tween(card, { Position = UDim2.fromOffset(0, 0) })
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
		Tween(card, { Position = UDim2.new(0, 20, 0, 0) })
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
		Name = RandomName(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
		DisplayOrder = opts.DisplayOrder or ORDER_PANEL,
	})
	ParentGui(gui)

	gui.Name = RandomName()
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
		ThemeTag = { BackgroundColor3 = "Section" },
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
			ThemeTag = { BackgroundColor3 = "BorderSoft" },
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
		-- must stay under the floats it closes, they sit at 118 and above
		ZIndex = 110,
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
		Name = RandomName(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
		DisplayOrder = ORDER_HOTKEYS,
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
		ThemeTag = { BackgroundColor3 = "Section" },
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
		ThemeTag = { BackgroundColor3 = "BorderSoft" },
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
		Name = RandomName(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		AutoLocalize = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = ORDER_CURSOR,
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

	local function follow()
		if not gui.Enabled then return end
		local position = UserInputService:GetMouseLocation()
		if not gui.IgnoreGuiInset then
			position = position - GuiService:GetGuiInset()
		end
		holder.Position = UDim2.fromOffset(position.X, position.Y)
	end

	Track(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			follow()
		end
	end))

	local bindName = "FacilityCursor_" .. RandomName(6)
	pcall(function()
		RunService:BindToRenderStep(bindName, Enum.RenderPriority.Last.Value, follow)
	end)
	self.CursorBind = bindName

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

function Library:ServerBrowser(opts)
	if self.ServerBrowserApi then return self.ServerBrowserApi end
	opts = opts or {}

	local HttpService = game:GetService("HttpService")
	local TeleportService = game:GetService("TeleportService")
	local player = Players.LocalPlayer
	local placeId = opts.PlaceId or game.PlaceId

	local gui = New("ScreenGui", {
		Name = RandomName(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		AutoLocalize = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = ORDER_BROWSER,
		Enabled = false,
	})
	ParentGui(gui)

	local main = New("Frame", {
		Size = UDim2.fromOffset(opts.Width or 340, opts.Height or 420),
		Position = opts.Position or UDim2.new(0.5, -170, 0.5, -210),
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		Active = true,
		Parent = gui,
		ThemeTag = { BackgroundColor3 = "Window" },
	})
	Corner(main, 10)
	Stroke(main, Theme.WindowBorder)

	local shadowHolder = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 35, 1.096, 35),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = main,
	})
	New("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 0,
		Image = "rbxassetid://5587865193",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		Size = UDim2.new(1.6, 0, 1.3, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		ImageTransparency = 0.5,
		Parent = shadowHolder,
	})

	-- header
	local topBar = New("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.TopBar,
		BorderSizePixel = 0,
		Parent = main,
		ThemeTag = { BackgroundColor3 = "TopBar" },
	})
	Corner(topBar, 10)
	New("Frame", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.fromOffset(0, 28),
		BackgroundColor3 = Theme.TopBar,
		BorderSizePixel = 0,
		Parent = topBar,
		ThemeTag = { BackgroundColor3 = "TopBar" },
	})
	New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.fromOffset(0, 39),
		BackgroundColor3 = Theme.BorderSoft,
		BorderSizePixel = 0,
		Parent = topBar,
		ThemeTag = { BackgroundColor3 = "BorderSoft" },
	})

	local heading = Label(topBar, opts.Title or "servers", Theme.TextBright, Theme.TextSize + 1, Theme.FontMedium)
	heading.Position = UDim2.fromOffset(14, 0)
	heading.Size = UDim2.new(1, -90, 1, 0)

	local statusLabel = Label(topBar, "", Theme.TextDim, 11)
	statusLabel.AnchorPoint = Vector2.new(1, 0.5)
	statusLabel.Position = UDim2.new(1, -66, 0.5, 0)
	statusLabel.Size = UDim2.fromOffset(120, 14)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Right

	local refreshBtn = New("TextButton", {
		Size = UDim2.fromOffset(22, 22),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -38, 0.5, 0),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = topBar,
	})
	local refreshIcon = AttachIcon(refreshBtn, "refresh-cw", Theme.TextDim, 15)
	if refreshIcon then
		refreshIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		refreshIcon.Position = UDim2.fromScale(0.5, 0.5)
	end

	local closeBtn = New("TextButton", {
		Size = UDim2.fromOffset(22, 22),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = topBar,
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
			Parent = closeBtn,
			ThemeTag = { BackgroundColor3 = "TextDim" },
		})
		Corner(bar, 1)
		closeBars[i] = bar
	end

	-- list
	local list = New("ScrollingFrame", {
		Size = UDim2.new(1, -20, 1, -54),
		Position = UDim2.fromOffset(10, 48),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.AccentDim,
		ScrollBarImageTransparency = 0.3,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		Parent = main,
		ThemeTag = { ScrollBarImageColor3 = "AccentDim" },
	})
	List(list, 6)
	Pad(list, 2, 8, 2, 2)

	local api = {
		Gui = gui,
		Frame = main,
		Open = false,
	}

	local loading = false

	local function clearRows()
		for _, child in ipairs(list:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end
	end

	local function addRow(server, index)
		local row = New("Frame", {
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = Theme.Section,
			BorderSizePixel = 0,
			LayoutOrder = index,
			Parent = list,
			ThemeTag = { BackgroundColor3 = "Section" },
		})
		Corner(row, 6)
		Stroke(row, Theme.SectionBorder)

		local players = Label(row, string.format("%d / %d players", server.playing or 0, server.maxPlayers or 0), Theme.TextBright)
		players.Position = UDim2.fromOffset(12, 6)
		players.Size = UDim2.new(1, -90, 0, 16)

		local ping = server.ping or 0
		local pingColor = Theme.TextCode
		if ping > 150 then
			pingColor = Theme.Danger
		elseif ping > 80 then
			pingColor = Theme.TextMarked
		end

		local meta = Label(row, string.format("%d ms  -  %d fps", math.floor(ping), math.floor(server.fps or 0)), pingColor, 11)
		meta.Position = UDim2.fromOffset(12, 23)
		meta.Size = UDim2.new(1, -90, 0, 14)

		local joinFrame = New("Frame", {
			Size = UDim2.fromOffset(62, 26),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Parent = row,
			ThemeTag = { BackgroundColor3 = "Accent" },
		})
		Corner(joinFrame, 6)

		local joinBtn = New("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "join",
			TextColor3 = Color3.fromRGB(40, 32, 34),
			TextSize = Theme.TextSize,
			Font = Theme.FontMedium,
			Parent = joinFrame,
		})

		Track(joinBtn.Activated:Connect(function()
			Library:Notify(opts.Title or "servers", "teleporting...", 3)

			-- Games that route teleports through their own server reject a
			-- direct client call, OnJoin lets the script use their module
			if opts.OnJoin then
				Library:SafeCallback("server browser", opts.OnJoin, server.id, placeId, server)
				return
			end

			-- TeleportAsync is server side only, the client must use the
			-- legacy call here
			local ok, err = pcall(function()
				TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
			end)

			if not ok then
				Library:Error(opts.Title or "servers", tostring(err), 6)
			end
		end))
	end

	local function refresh()
		if loading then return end
		loading = true
		statusLabel.Text = "loading..."
		clearRows()

		task.spawn(function()
			local ok, result = pcall(function()
				local url = "https://games.roblox.com/v1/games/" .. placeId
					.. "/servers/Public?sortOrder=Asc&limit=100"
				return HttpService:JSONDecode(game:HttpGet(url))
			end)

			if not ok or type(result) ~= "table" or type(result.data) ~= "table" then
				statusLabel.Text = "request failed"
				loading = false
				return
			end

			local servers = {}
			for _, srv in ipairs(result.data) do
				if not (placeId == game.PlaceId and srv.id == game.JobId) then
					table.insert(servers, srv)
				end
			end

			table.sort(servers, function(a, b)
				return (a.ping or 999) < (b.ping or 999)
			end)

			local shown = 0
			for _, srv in ipairs(servers) do
				shown = shown + 1
				addRow(srv, shown)
				if shown >= (opts.MaxRows or 40) then break end
			end

			statusLabel.Text = shown .. " servers"
			loading = false
		end)
	end

	Track(refreshBtn.Activated:Connect(refresh))
	Track(refreshBtn.MouseEnter:Connect(function()
		if refreshIcon then Tween(refreshIcon, { ImageColor3 = Theme.Accent }, EASE_FAST) end
	end))
	Track(refreshBtn.MouseLeave:Connect(function()
		if refreshIcon then Tween(refreshIcon, { ImageColor3 = Theme.TextDim }, EASE_FAST) end
	end))

	Track(closeBtn.Activated:Connect(function() api:SetVisible(false) end))
	Track(closeBtn.MouseEnter:Connect(function()
		for _, bar in ipairs(closeBars) do Tween(bar, { BackgroundColor3 = Theme.Danger }, EASE_FAST) end
	end))
	Track(closeBtn.MouseLeave:Connect(function()
		for _, bar in ipairs(closeBars) do Tween(bar, { BackgroundColor3 = Theme.TextDim }, EASE_FAST) end
	end))

	-- drag
	do
		local dragging, dragStart, startPos = false, nil, nil
		local targetPos = main.Position
		local activeInput = nil
		Track(topBar.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch then return end
			if dragging then return end
			dragging = true
			activeInput = input
			dragStart = input.Position
			startPos = main.Position
			targetPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					activeInput = nil
				end
			end)
		end))
		Track(UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input ~= activeInput and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement
				and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end))
	end

	function api:SetVisible(state)
		self.Open = state and true or false
		gui.Enabled = self.Open
		if self.Open and #list:GetChildren() <= 2 then
			refresh()
		end
	end

	function api:Toggle()
		self:SetVisible(not self.Open)
	end

	function api:Refresh()
		refresh()
	end

	self.ServerBrowserApi = api
	return api
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
		Name = RandomName(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
		DisplayOrder = ORDER_MOBILE,
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
		ThemeTag = { BackgroundColor3 = "Section" },
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
			ThemeTag = { BackgroundColor3 = "Accent" },
		})
		Corner(bar, 1)
	end

	local moved, origin, startPos, moveConn, endConn
	local pressing = false
	local lastToggle = 0

	Track(button.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		-- touch also emits a mouse event on mobile, ignore the duplicate
		if pressing then return end
		pressing = true

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
			if ended.UserInputType ~= Enum.UserInputType.MouseButton1
				and ended.UserInputType ~= Enum.UserInputType.Touch then return end
			if moveConn then moveConn:Disconnect() moveConn = nil end
			if endConn then endConn:Disconnect() endConn = nil end
			pressing = false
			Tween(button, { BackgroundColor3 = Theme.Section }, EASE_FAST)

			if not moved and (tick() - lastToggle) > 0.25 then
				lastToggle = tick()
				Library:ToggleUI()
			end
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
	if self.WatermarkApi then pcall(function() self.WatermarkApi:Destroy() end) end
	pcall(function() self:StopBlur() end)
	RemoveGlass()
	self.Glass = false
	if self.MouseBind then
		pcall(function() RunService:UnbindFromRenderStep(self.MouseBind) end)
		self.MouseBind = nil
	end
	self:ReleaseMouse()
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
	if self.CursorBind then
		pcall(function() RunService:UnbindFromRenderStep(self.CursorBind) end)
		self.CursorBind = nil
	end
	if self.CursorGui then self.CursorGui:Destroy() self.CursorGui = nil self.CursorHolder = nil end
	if self.ServerBrowserApi then pcall(function() self.ServerBrowserApi.Gui:Destroy() end) self.ServerBrowserApi = nil end
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
	FileSystem:MakeFolder(folder .. "/settings")
	return folder
end

Library.FileSystem = FileSystem

if getgenv then
	pcall(function() getgenv().Facility = Library end)
end
Library.SaveManager = Library:LoadAddon("SaveManager")
Library.InterfaceManager = Library:LoadAddon("InterfaceManager")
Library.ThemeManager = Library:LoadAddon("ThemeManager")

do
	local manager = Library.ThemeManager
	local extra = {
		{ "crimson", Color3.fromRGB(19, 19, 19), Color3.fromRGB(255, 24, 24) },
		{ "dark", Color3.fromRGB(24, 24, 26), Color3.fromRGB(96, 205, 255) },
		{ "onyx", Color3.fromRGB(10, 10, 10), Color3.fromRGB(235, 235, 235) },
		{ "emerald", Color3.fromRGB(14, 24, 19), Color3.fromRGB(52, 211, 153) },
		{ "toxic", Color3.fromRGB(12, 18, 10), Color3.fromRGB(166, 255, 0) },
		{ "noir", Color3.fromRGB(10, 8, 9), Color3.fromRGB(255, 92, 150) },
		{ "lagoon", Color3.fromRGB(8, 20, 30), Color3.fromRGB(34, 230, 222) },
	}
	if type(manager) == "table" and type(manager.Presets) == "table" and type(manager.Order) == "table" then
		for _, entry in ipairs(extra) do
			if not manager.Presets[entry[1]] then
				manager.Presets[entry[1]] = { Bg = entry[2], Accent = entry[3] }
				table.insert(manager.Order, entry[1])
			end
		end
	end
end

return Library
