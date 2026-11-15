if getgenv().Arcane and getgenv().Arcane.Unload then
	getgenv().Arcane:Unload()
end

local arcane = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local cloneref_ = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local Y = GuiService:GetGuiInset().Y
local v12 = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

gethui = gethui or function()
	return cloneref_
end

local lib

pcall(function()
	lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/icons.lua"))()
end)

local function v14(p1)
	if type(p1) == "number" then
		return "rbxassetid://" .. p1
	end

	if type(p1) == "string" then
		if string.match(p1, "^rbxassetid://") then
			return p1
		end

		if string.match(p1, "^%d+$") then
			return "rbxassetid://" .. p1
		end

		local v15 = string.lower(p1)

		if type(lib) == "function" then
			local ok, result = pcall(lib, v15)

			if ok and type(result) == "table" then
				local id = result.id or result.Id or result[1]
				local imageRectSize = result.imageRectSize or result.ImageRectSize or result[2]
				local imageRectOffset = result.imageRectOffset or result.imageRectPosition or result.ImageRectOffset or result[3]

				if id then
					return "rbxassetid://" .. tostring(id), imageRectOffset, imageRectSize
				end
			end
		elseif type(lib) == "table" then
			for _, v in {
				lib["48px"],
				lib["256px"],
				lib
			}, nil, nil do
				if type(v) == "table" then
					local v23 = v[v15]

					if type(v23) ~= "table" then
						continue
					end

					if v23[1] then
						return "rbxassetid://" .. tostring(v23[1]), v23[3], v23[2]
					end
				end
			end
		end
	end

	return "rbxassetid://0"
end
local function v24(p2)
	if typeof(p2) == "Vector2" then
		return p2
	end

	if type(p2) == "table" then
		return Vector2.new(p2[1] or p2.X or 0, p2[2] or p2.Y or 0)
	end

	return Vector2.new(0, 0)
end
local function v25(p3, p4)
	if not p4 then
		return
	end

	local v26, v27, v28 = v14(p4)

	p3.Image = v26
	p3.ImageRectOffset = v24(v27)
	p3.ImageRectSize = v24(v28)
end

local t1 = {
	Dark = {
		Background = Color3.fromRGB(16, 16, 18),
		Topbar = Color3.fromRGB(22, 22, 26),
		Section = Color3.fromRGB(21, 20, 25),
		Element = Color3.fromRGB(27, 26, 33),
		Accent = Color3.fromRGB(254, 0, 67),
		Text = Color3.fromRGB(255, 255, 255),
		DimText = Color3.fromRGB(120, 120, 130),
		Border = Color3.fromRGB(30, 29, 34),
		Selected = Color3.fromRGB(29, 28, 37),
		ToggleOff = Color3.fromRGB(35, 25, 38)
	},
	Light = {
		Background = Color3.fromRGB(228, 228, 233),
		Topbar = Color3.fromRGB(235, 235, 240),
		Section = Color3.fromRGB(245, 245, 249),
		Element = Color3.fromRGB(230, 230, 236),
		Accent = Color3.fromRGB(254, 0, 67),
		Text = Color3.fromRGB(24, 24, 30),
		DimText = Color3.fromRGB(140, 140, 150),
		Border = Color3.fromRGB(205, 205, 214),
		Selected = Color3.fromRGB(216, 216, 224),
		ToggleOff = Color3.fromRGB(210, 202, 206)
	},
	Ocean = {
		Background = Color3.fromRGB(14, 17, 22),
		Topbar = Color3.fromRGB(20, 24, 31),
		Section = Color3.fromRGB(18, 22, 28),
		Element = Color3.fromRGB(24, 29, 37),
		Accent = Color3.fromRGB(0, 170, 255),
		Text = Color3.fromRGB(235, 240, 245),
		DimText = Color3.fromRGB(90, 100, 115),
		Border = Color3.fromRGB(28, 33, 42),
		Selected = Color3.fromRGB(28, 35, 48),
		ToggleOff = Color3.fromRGB(26, 34, 46)
	},
	Crimson = {
		Background = Color3.fromRGB(18, 14, 15),
		Topbar = Color3.fromRGB(26, 20, 21),
		Section = Color3.fromRGB(23, 18, 19),
		Element = Color3.fromRGB(32, 24, 26),
		Accent = Color3.fromRGB(230, 40, 70),
		Text = Color3.fromRGB(245, 235, 237),
		DimText = Color3.fromRGB(120, 95, 100),
		Border = Color3.fromRGB(38, 28, 31),
		Selected = Color3.fromRGB(42, 28, 31),
		ToggleOff = Color3.fromRGB(40, 26, 30)
	},
	Emerald = {
		Background = Color3.fromRGB(14, 19, 16),
		Topbar = Color3.fromRGB(20, 27, 23),
		Section = Color3.fromRGB(18, 24, 20),
		Element = Color3.fromRGB(24, 33, 28),
		Accent = Color3.fromRGB(0, 200, 130),
		Text = Color3.fromRGB(235, 245, 240),
		DimText = Color3.fromRGB(95, 115, 105),
		Border = Color3.fromRGB(28, 38, 32),
		Selected = Color3.fromRGB(28, 44, 36),
		ToggleOff = Color3.fromRGB(26, 40, 32)
	},
	Amethyst = {
		Background = Color3.fromRGB(17, 14, 22),
		Topbar = Color3.fromRGB(24, 20, 31),
		Section = Color3.fromRGB(21, 18, 28),
		Element = Color3.fromRGB(30, 25, 39),
		Accent = Color3.fromRGB(170, 90, 255),
		Text = Color3.fromRGB(240, 236, 248),
		DimText = Color3.fromRGB(110, 100, 125),
		Border = Color3.fromRGB(35, 28, 46),
		Selected = Color3.fromRGB(40, 32, 54),
		ToggleOff = Color3.fromRGB(36, 28, 48)
	}
}

local function v30()
	local Theme = arcane.Theme

	Theme.Inline = Theme.Topbar
	Theme.AccentDark = Theme.Accent
	Theme.Divider = Theme.Border
	Theme.DimIcon = Theme.DimText:Lerp(Theme.Background, 0.45)
	Theme.SliderBack = Theme.Element
	Theme.DropdownBack = Theme.Element
	Theme.DropdownSelected = Theme.Element:Lerp(Theme.Text, 0.045)
	Theme.ToggleOn = Theme.Accent:Lerp(Theme.Section, 0.72)
	Theme.ToggleOffCircle = Theme.ToggleOff:Lerp(Theme.DimText, 0.5)
	Theme.SliderKnob = Theme.Text:Lerp(Color3.fromRGB(255, 255, 255), 0.8)
end

arcane.__index = arcane
arcane.Theme = table.clone(t1.Dark)
v30()
arcane.CurrentTheme = "Dark"
arcane.PreviousTheme = "Dark"
arcane.Flags = {}
arcane.Threads = {}
arcane.Connections = {}
arcane.ThemingStuff = {}
arcane.ThemeMap = {}
arcane.OpenFrames = {}
arcane.Windows = {}
arcane.MenuKeybind = tostring(Enum.KeyCode.RightControl)
arcane.SetFlags = {}
arcane.Directory = "Arcane"
arcane.ConfigFolder = "Arcane/Configs"
arcane.ThemeKeys = {
	"Background",
	"Topbar",
	"Section",
	"Element",
	"Accent",
	"Text",
	"DimText",
	"Border"
}
arcane.ThemeList = {
	"Dark",
	"Light",
	"Ocean",
	"Crimson",
	"Emerald",
	"Amethyst"
}
arcane.Language = "ENG"
arcane.LanguageCodes = {
	RUS = "ru",
	SPA = "es",
	BRA = "pt",
	PHL = "tl",
	FRA = "fr",
	GER = "de",
	TUR = "tr"
}
arcane.Translations = {}
arcane.TranslationCache = {}
arcane.TextRegistry = {}
arcane.LanguageHooks = {}
arcane.SwapTokens = setmetatable({}, {
	__mode = "k"
})
arcane.SwapText = function(p5, p6, p7, p8)
	pcall(function()
		if p6.Text == p7 then
			return
		end

		if not p6:IsDescendantOf(arcane.Holder.Instance) then
			arcane.SwapTokens[p6] = (arcane.SwapTokens[p6] or 0) + 1
			p6.Text = p7

			return
		end

		local v32 = arcane.RestingValues[p6]

		if v32 and v32.TextTransparency ~= nil then
			arcane.SwapTokens[p6] = (arcane.SwapTokens[p6] or 0) + 1
			p6.Text = p7

			return
		end

		arcane.SwapTokens[p6] = (arcane.SwapTokens[p6] or 0) + 1

		local v33 = arcane.SwapTokens[p6]

		arcane:Tween({
			TextTransparency = 1
		}, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p6)
		task.delay(0.13, function()
			pcall(function()
				if arcane.SwapTokens[p6] ~= v33 then
					return
				end

				p6.Text = p7

				local v34 = arcane.RestingValues[p6]

				if v34 and v34.TextTransparency ~= nil then
					return
				end

				arcane:Tween({
					TextTransparency = p8 or 0
				}, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p6)
			end)
		end)
	end)
end
arcane.DisplayName = function(p9, p10)
	local v35 = arcane.LanguageCodes[arcane.Language]

	if v35 then
		return arcane.Translations[p10] or arcane.TranslationCache[v35 .. "\1" .. p10] or p10
	end

	return p10
end
arcane.TranslateEntry = function(p11, p12)
	local English = p12.English
	local v37 = arcane.LanguageCodes[arcane.Language]

	if not v37 then
		return
	end

	local v38 = arcane.Translations[English]

	if v38 then
		arcane:SwapText(p12.Label, v38, p12.Transparency)

		return
	end

	local v39 = v37 .. "\1" .. English
	local v40 = arcane.TranslationCache[v39]

	if not v40 then
		task.spawn(function()
			local ok, result = pcall(function()
				local v43 = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=" .. v37 .. "&dt=t&q=" .. HttpService:UrlEncode(English)

				return HttpService:JSONDecode(game:HttpGet(v43))[1][1][1]
			end)

			if ok then
				if type(result) == "string" and result ~= "" then
					arcane.TranslationCache[v39] = result

					if arcane.LanguageCodes[arcane.Language] == v37 then
						arcane:SwapText(p12.Label, result, p12.Transparency)
					end
				end
			end
		end)

		return
	end

	arcane:SwapText(p12.Label, v40, p12.Transparency)
end
arcane.RegisterText = function(p13, p14, p15)
	local t2 = {
		Label = p14,
		English = p15,
		Transparency = p14.TextTransparency
	}

	table.insert(arcane.TextRegistry, t2)

	if arcane.LanguageCodes[arcane.Language] then
		arcane:TranslateEntry(t2)
	end

	return t2
end
arcane.SetLanguage = function(p16, p17)
	arcane.Language = p17
	arcane.LanguageToken = (arcane.LanguageToken or 0) + 1

	local LanguageToken = arcane.LanguageToken
	local v46 = arcane.LanguageCodes[p17]

	local function v47()
		for _, v in arcane.LanguageHooks, nil, nil do
			pcall(v)
		end
	end

	if v46 then
		task.spawn(function()
			local n1 = 0
			local n2 = 0
			local t3 = {}

			for _, v in arcane.TextRegistry, nil, nil do
				local v55 = v46 .. "\1" .. v.English

				if not arcane.Translations[v.English] and not arcane.TranslationCache[v55] and not t3[v55] then
					t3[v55] = true
					n1 += 1

					local English = v.English

					task.spawn(function()
						local ok, result = pcall(function()
							local v59 = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=" .. v46 .. "&dt=t&q=" .. HttpService:UrlEncode(English)

							return HttpService:JSONDecode(game:HttpGet(v59))[1][1][1]
						end)

						if ok and type(result) == "string" and result ~= "" then
							arcane.TranslationCache[v55] = result
						end

						n2 += 1
					end)
				end
			end

			local v60 = os.clock() + 8

			while n2 < n1 and os.clock() < v60 do
				task.wait(0.05)
			end

			if arcane.LanguageToken ~= LanguageToken then
				return
			end

			for _, v in arcane.TextRegistry, nil, nil do
				arcane:SwapText(v.Label, arcane.Translations[v.English] or arcane.TranslationCache[v46 .. "\1" .. v.English] or v.English, v.Transparency)
			end

			v47()
		end)

		return
	end

	for _, v in arcane.TextRegistry, nil, nil do
		arcane:SwapText(v.Label, v.English, v.Transparency)
	end

	v47()
end
arcane.Animation = {
	Time = 0.25,
	Style = Enum.EasingStyle.Quart,
	Direction = Enum.EasingDirection.Out
}
arcane.Create = function(p18, p19, p20)
	local t4 = {
		Class = p19,
		Properties = p20,
		Instance = Instance.new(p19)
	}

	for k, v in p20, nil, nil do
		if k == "FontFace" then
			t4.Instance.FontFace = arcane.Font
		elseif k == "Name" then
			t4.Instance.Name = "\0"
		else
			t4.Instance[k] = v
		end
	end

	return setmetatable(t4, arcane)
end
arcane.Thread = function(p21, p22)
	local thread = coroutine.create(p22)

	coroutine.resume(thread)
	table.insert(arcane.Threads, thread)

	return thread
end
arcane.Connect = function(p23, p24, p25)
	local connection

	if type(p24) ~= "string" then
		connection = p24:Connect(p25)
		table.insert(arcane.Connections, connection)

		return connection
	end

	if not p23.Instance then
		connection = p24:Connect(p25)
	elseif v12 and (p24 == "MouseButton1Down" or p24 == "MouseButton1Click") then
		if not p23.Instance:IsA("GuiButton") then
			connection = p23.Instance[p24]:Connect(p25)
			table.insert(arcane.Connections, connection)

			return connection
		end

		local n3 = 0

		local function v71(p26)
			local now = os.clock()

			if now - n3 < 0.25 then
				return
			end

			n3 = now
			p25(p26)
		end

		arcane.TouchButtons = arcane.TouchButtons or {}
		table.insert(arcane.TouchButtons, {
			Instance = p23.Instance,
			Fire = v71
		})
		connection = p23.Instance.Activated:Connect(function(inputObject)
			v71(inputObject)
		end)
	else
		connection = p23.Instance[p24]:Connect(p25)
	end

	table.insert(arcane.Connections, connection)

	return connection
end
arcane.SafeCall = function(p27, p28, ...)
	if type(p28) ~= "function" then
		return
	end

	local ok, result = pcall(p28, ...)

	if not ok then
		warn(result)
	end

	return ok, result
end
arcane.Round = function(p29, p30, p31)
	local v75 = 1 / (p31 or 1)

	return math.floor(p30 * v75) / v75
end
arcane.GetScreenScale = function()
	return arcane.UIScale and arcane.UIScale.Instance and arcane.UIScale.Instance.Scale or 1
end

if isfolder and not isfolder(arcane.Directory) then
	makefolder(arcane.Directory)
end

if isfolder and not isfolder(arcane.ConfigFolder) then
	makefolder(arcane.ConfigFolder)
end

arcane.GetConfig = function()
	local t5 = {}

	for k, v in arcane.Flags, nil, nil do
		if typeof(v) == "Color3" then
			t5[k] = {
				__color = v:ToHex()
			}
		else
			t5[k] = v
		end
	end

	local t6 = {}

	for k, v in arcane.Theme, nil, nil do
		if typeof(v) == "Color3" then
			t6[k] = v:ToHex()
		end
	end

	t5.__theme = t6

	return HttpService:JSONEncode(t5)
end
arcane.LoadConfig = function(p32, p33)
	local data = HttpService:JSONDecode(p33)

	for k, v in data, nil, nil do
		local v85 = arcane.SetFlags[k]

		if v85 then
			if type(v) == "table" and v.__color then
				v85(Color3.fromHex(v.__color), v.__alpha)
			else
				v85(v)
			end
		end
	end

	if type(data.__theme) == "table" then
		for k, v in data.__theme, nil, nil do
			local ok, result = pcall(Color3.fromHex, v)

			if ok then
				arcane.Theme[k] = result
			end
		end

		arcane:ApplyTheme()
	elseif type(data.__theme) == "string" then
		arcane:SetTheme(data.__theme)
	end
end
arcane.GetConfigsList = function(p34, p35)
	local t7 = {}

	for _, v in listfiles(arcane.ConfigFolder) do
		if v:sub(-5) == ".json" then
			local match = v:match("([^/\\]+)%.json$")

			if match then
				table.insert(t7, match)
			end
		end
	end

	if p35 then
		p35:Refresh(t7)
	end

	return t7
end
arcane.Tween = function(p36, p37, p38, p39)
	local tween = TweenService:Create(p39 or p36.Instance, p38 or TweenInfo.new(arcane.Animation.Time, arcane.Animation.Style, arcane.Animation.Direction), p37)

	tween:Play()

	return tween
end
arcane.GetTweenProperty = function(p40, p41)
	local Instance_ = p41 or p40.Instance

	if Instance_:IsA("Frame") then
		return { "BackgroundTransparency" }
	end

	if Instance_:IsA("TextLabel") or Instance_:IsA("TextButton") then
		return {
			"TextTransparency",
			"BackgroundTransparency"
		}
	end

	if Instance_:IsA("ImageLabel") or Instance_:IsA("ImageButton") then
		return {
			"BackgroundTransparency",
			"ImageTransparency"
		}
	end

	if Instance_:IsA("ScrollingFrame") then
		return {
			"BackgroundTransparency",
			"ScrollBarImageTransparency"
		}
	end

	if Instance_:IsA("TextBox") then
		return {
			"TextTransparency",
			"BackgroundTransparency"
		}
	end

	if Instance_:IsA("UIStroke") then
		return { "Transparency" }
	end
end
arcane.RestingValues = setmetatable({}, {
	__mode = "k"
})
arcane.FadeTokens = setmetatable({}, {
	__mode = "k"
})
arcane.CaptureResting = function(p42, p43, p44)
	local v96 = arcane.RestingValues[p43]

	if not v96 then
		v96 = {}
		arcane.RestingValues[p43] = v96
	end

	if v96[p44] == nil then
		v96[p44] = p43[p44]
	end

	return v96[p44]
end
arcane.ReleaseResting = function(p45, p46, p47)
	local v97 = arcane.RestingValues[p46]

	if not v97 then
		return nil
	end

	local v98 = v97[p47]

	v97[p47] = nil

	return v98
end
arcane.Fade = function(p48, p49, p50, p51)
	local Instance_ = p51 or p48.Instance
	local v100 = arcane:CaptureResting(Instance_, p49)

	if not p50 then
		return arcane:Tween({
			[p49] = 1
		}, nil, Instance_)
	end

	Instance_[p49] = 1

	return arcane:Tween({
		[p49] = v100
	}, nil, Instance_)
end
arcane.FadeDescendants = function(p52, p53, p54)
	local Instance_ = p52.Instance

	arcane.FadeTokens[Instance_] = (arcane.FadeTokens[Instance_] or 0) + 1

	local v102 = arcane.FadeTokens[Instance_]

	if p53 then
		Instance_.Visible = true
	end

	local descendants = Instance_:GetDescendants()

	table.insert(descendants, Instance_)

	for _, v in descendants, nil, nil do
		local tweenProperty = arcane:GetTweenProperty(v)

		if tweenProperty then
			for _, v2 in tweenProperty, nil, nil do
				arcane:Fade(v2, p53, v)
			end
		end
	end

	task.delay(arcane.Animation.Time + 0.03, function()
		if arcane.FadeTokens[Instance_] == v102 then
			Instance_.Visible = p53

			for _, v in descendants, nil, nil do
				local tweenProperty = arcane:GetTweenProperty(v)

				if tweenProperty then
					for _, v2 in tweenProperty, nil, nil do
						local v114 = arcane:ReleaseResting(v, v2)

						if v114 ~= nil then
							v[v2] = v114
						end
					end
				end
			end
		end

		if p54 then
			p54()
		end
	end)
end
arcane.ResetFade = function(p55)
	local Instance_ = p55.Instance

	arcane.FadeTokens[Instance_] = (arcane.FadeTokens[Instance_] or 0) + 1

	local descendants = Instance_:GetDescendants()

	table.insert(descendants, Instance_)

	for _, v in descendants, nil, nil do
		local tweenProperty = arcane:GetTweenProperty(v)

		if tweenProperty then
			for _, v2 in tweenProperty, nil, nil do
				local v122 = arcane:ReleaseResting(v, v2)

				if v122 ~= nil then
					v[v2] = v122
				end
			end
		end
	end
end
arcane.AddToTheme = function(p56, p57)
	local Instance_ = p56.Instance
	local t8 = {
		Item = Instance_,
		Properties = p57
	}

	for k, v in p57, nil, nil do
		if type(v) == "string" then
			Instance_[k] = arcane.Theme[v]
		else
			Instance_[k] = v()
		end
	end

	table.insert(arcane.ThemingStuff, t8)
	arcane.ThemeMap[Instance_] = t8

	return p56
end
arcane.ChangeItemTheme = function(p58, p59)
	local Instance_ = p58.Instance

	if not arcane.ThemeMap[Instance_] then
		return
	end

	arcane.ThemeMap[Instance_].Properties = p59
end
arcane.SetTheme = function(p60, p61)
	local v128 = t1[p61]

	if not v128 then
		return
	end

	arcane.CurrentTheme = p61

	if p61 ~= "Light" then
		arcane.PreviousTheme = p61
	end

	for k, v in v128, nil, nil do
		arcane.Theme[k] = v
	end

	v30()

	for _, v in arcane.ThemingStuff, nil, nil do
		for k, v2 in v.Properties, nil, nil do
			if type(v2) == "string" then
				arcane:Tween({
					[k] = arcane.Theme[v2]
				}, nil, v.Item)
			elseif type(v2) == "function" then
				arcane:Tween({
					[k] = v2()
				}, nil, v.Item)
			end
		end
	end
end
arcane.ApplyTheme = function()
	for _, v in arcane.ThemingStuff, nil, nil do
		for k, v2 in v.Properties, nil, nil do
			if type(v2) == "string" then
				arcane:Tween({
					[k] = arcane.Theme[v2]
				}, nil, v.Item)
			elseif type(v2) == "function" then
				arcane:Tween({
					[k] = v2()
				}, nil, v.Item)
			end
		end
	end
end
arcane.ThemeDirty = false
arcane.ApplyThemeInstant = function()
	for _, v in arcane.ThemingStuff, nil, nil do
		for k, v2 in v.Properties, nil, nil do
			if type(v2) == "string" then
				v.Item[k] = arcane.Theme[v2]
			elseif type(v2) == "function" then
				v.Item[k] = v2()
			end
		end
	end
end
arcane.ChangeTheme = function(p62, p63, p64)
	arcane.Theme[p63] = p64
	v30()
	arcane.ThemeDirty = true
end
arcane:Connect(RunService.Heartbeat, function()
	if arcane.ThemeDirty then
		arcane.ThemeDirty = false
		arcane:ApplyThemeInstant()
	end
end)
arcane.OnHover = function(p65, p66, p67)
	local Instance_ = p65.Instance

	arcane:Connect(Instance_.MouseEnter, p66)
	arcane:Connect(Instance_.MouseLeave, p67)
end
arcane.RaisePopup = function(p68, p69, p70, p71)
	arcane.TouchShields = arcane.TouchShields or {}

	if p70 then
		arcane.TouchShields[p69] = p71 or 60
	else
		arcane.TouchShields[p69] = nil
	end

	local descendants = p69:GetDescendants()

	table.insert(descendants, p69)

	for _, v in descendants, nil, nil do
		if v:IsA("GuiObject") then
			v.ZIndex = p70 and (p71 or 60) or 1
		end
	end
end
arcane.MakeDraggable = function(p72, p73)
	local Instance_ = p72.Instance
	local v148 = p73 or Instance_

	v148.Active = true

	local u149 = false
	local Position
	local vector2

	local function v152(p74)
		local screenScale = arcane:GetScreenScale()
		local v154 = (p74.Position - Position) / screenScale
		local v155 = vector2.Y + v154.Y
		local v156 = Instance_.Parent.AbsoluteSize / screenScale
		local v157 = Instance_.AbsoluteSize / screenScale
		local AnchorPoint = Instance_.AnchorPoint
		local v159 = math.clamp(vector2.X + v154.X, v157.X * AnchorPoint.X, v156.X - v157.X * (1 - AnchorPoint.X))
		local v160 = math.clamp(v155, v157.Y * AnchorPoint.Y, v156.Y - v157.Y * (1 - AnchorPoint.Y))

		p72:Tween({
			Position = UDim2.new(0, v159, 0, v160)
		}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
	end

	local connection

	arcane:Connect(v148.InputBegan, function(p75)
		if p75.UserInputType == Enum.UserInputType.MouseButton1 or p75.UserInputType == Enum.UserInputType.Touch then
			u149 = true
			Position = p75.Position

			local v162 = Instance_.Parent.AbsoluteSize / arcane:GetScreenScale()

			vector2 = Vector2.new(Instance_.Position.X.Scale * v162.X + Instance_.Position.X.Offset, Instance_.Position.Y.Scale * v162.Y + Instance_.Position.Y.Offset)

			if connection then
				return
			end

			connection = p75.Changed:Connect(function()
				if p75.UserInputState == Enum.UserInputState.End then
					u149 = false
					connection:Disconnect()
					connection = nil
				end
			end)
		end
	end)
	arcane:Connect(UserInputService.InputChanged, function(p76)
		if (p76.UserInputType == Enum.UserInputType.MouseMovement or p76.UserInputType == Enum.UserInputType.Touch) and u149 then
			v152(p76)
		end
	end)
end
arcane.IsMouseOverFrame = function(p77)
	local Instance_ = p77.Instance
	local vector2 = Vector2.new(mouse.X, mouse.Y)

	return vector2.X >= Instance_.AbsolutePosition.X and vector2.X <= Instance_.AbsolutePosition.X + Instance_.AbsoluteSize.X and vector2.Y >= Instance_.AbsolutePosition.Y and vector2.Y <= Instance_.AbsolutePosition.Y + Instance_.AbsoluteSize.Y
end
arcane.Unload = function()
	for _, v in arcane.Connections, nil, nil do
		v:Disconnect()
	end

	for _, v in arcane.Threads, nil, nil do
		pcall(coroutine.close, v)
	end

	if arcane.Holder then
		arcane.Holder.Instance:Destroy()
	end

	if arcane.UnusedHolder then
		arcane.UnusedHolder.Instance:Destroy()
	end

	getgenv().Arcane = nil
end

local t9 = {
	New = function(p78, p79, p80, p81, p82)
		if not isfile(p79 .. ".ttf") then
			writefile(p79 .. ".ttf", game:HttpGet(p82.Url))
		end

		local t10 = {
			name = p79,
			faces = { {
				name = "Regular",
				weight = p80,
				style = p81,
				assetId = getcustomasset(p79 .. ".ttf")
			} }
		}

		if not isfile(p79 .. ".font") then
			writefile(p79 .. ".font", HttpService:JSONEncode(t10))
		end

		return Font.new(getcustomasset(p79 .. ".font"))
	end
}
local ok, result = pcall(function()
	return t9:New("ArcaneInter", 600, "Normal", {
		Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/InterSemibold.ttf"
	})
end)

arcane.Font = ok and result or Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
arcane.Holder = arcane:Create("ScreenGui", {
	Parent = gethui(),
	Name = "\0",
	ZIndexBehavior = Enum.ZIndexBehavior.Global,
	ResetOnSpawn = false,
	IgnoreGuiInset = true
})
arcane.UnusedHolder = arcane:Create("ScreenGui", {
	Parent = gethui(),
	Name = "\0",
	Enabled = false,
	ResetOnSpawn = false
})

local tween = arcane:Create("Frame", {
	Parent = arcane.Holder.Instance,
	Name = "\0",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.new(0, 1, 0, 1),
	BorderSizePixel = 0
})

task.defer(function()
	Y = -tween.Instance.AbsolutePosition.Y
	tween.Instance:Destroy()
end)
arcane.NotifHolder = arcane:Create("Frame", {
	Parent = arcane.Holder.Instance,
	Name = "\0",
	AnchorPoint = Vector2.new(1, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, 0, 0, Y),
	Size = UDim2.new(0, 0, 1, 0),
	BorderSizePixel = 0,
	AutomaticSize = Enum.AutomaticSize.X
})
arcane:Create("UIPadding", {
	Parent = arcane.NotifHolder.Instance,
	PaddingTop = UDim.new(0, 15),
	PaddingRight = UDim.new(0, 15)
})
arcane:Create("UIListLayout", {
	Parent = arcane.NotifHolder.Instance,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 10)
})
arcane.UIScale = arcane:Create("UIScale", {
	Parent = arcane.Holder.Instance,
	Scale = 1
})

local Position

arcane:Connect(UserInputService.InputBegan, function(p83)
	if p83.UserInputType == Enum.UserInputType.Touch then
		Position = p83.Position
	end
end)
arcane:Connect(UserInputService.InputEnded, function(p84)
	if not v12 then
		return
	end

	if p84.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	if not Position then
		return
	end

	if not arcane.TouchButtons then
		return
	end

	local v175 = p84.Position - Position

	if math.abs(v175.X) > 12 or math.abs(v175.Y) > 12 then
		return
	end

	local Position2 = p84.Position

	local function v177(p85)
		local AbsolutePosition = p85.AbsolutePosition
		local AbsoluteSize = p85.AbsoluteSize

		return Position2.X >= AbsolutePosition.X and Position2.X <= AbsolutePosition.X + AbsoluteSize.X and Position2.Y >= AbsolutePosition.Y and Position2.Y <= AbsolutePosition.Y + AbsoluteSize.Y
	end
	local function v180(p86)
		if not p86:IsDescendantOf(arcane.Holder.Instance) then
			return false
		end

		local Parent = p86

		while true do
			if not Parent or Parent == arcane.Holder.Instance then
				return true
			end

			if not Parent:IsA("GuiObject") or Parent.Visible then
				Parent = Parent.Parent

				continue
			end

			break
		end

		return false
	end

	local n4 = 0

	if arcane.TouchShields then
		for k, v in arcane.TouchShields, nil, nil do
			if k:IsDescendantOf(arcane.Holder.Instance) and v177(k) then
				n4 = math.max(n4, v)
			end
		end
	end

	local v185

	for _, v in arcane.TouchButtons, nil, nil do
		local Instance_ = v.Instance

		if Instance_ and v180(Instance_) and v177(Instance_) and n4 <= Instance_.ZIndex then
			if v185 then
				if not (v185.Instance.ZIndex < Instance_.ZIndex) and (Instance_.ZIndex ~= v185.Instance.ZIndex or not (Instance_.AbsoluteSize.X * Instance_.AbsoluteSize.Y < v185.Instance.AbsoluteSize.X * v185.Instance.AbsoluteSize.Y)) then
					continue
				end
			end

			v185 = v
		end
	end

	if v185 then
		v185.Fire(p84)
	end
end)

local function v189()
	local scale = 1

	if v12 and workspace.CurrentCamera then
		local ViewportSize = workspace.CurrentCamera.ViewportSize

		scale = math.clamp(math.min(ViewportSize.X * 0.8 / 560, ViewportSize.Y * 0.8 / 555), 0.35, 1)
	end

	arcane.UIScale.Instance.Scale = scale

	for _, v in arcane.Windows, nil, nil do
		if v.Center then
			v:Center()
		end
	end
end

v189()
arcane:Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
	task.wait()
	v189()
end)
arcane.KeybindList = {
	Items = {}
}

local KeybindList = arcane.KeybindList

KeybindList.Items.Holder = arcane:Create("Frame", {
	Parent = arcane.Holder.Instance,
	Name = "\0",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 15, 0.5, 0),
	Size = UDim2.new(0, 220, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	Visible = false,
	BorderSizePixel = 0,
	BackgroundColor3 = arcane.Theme.Section
}):AddToTheme({
	BackgroundColor3 = "Section"
})
arcane:Create("UICorner", {
	Parent = KeybindList.Items.Holder.Instance,
	CornerRadius = UDim.new(0, 10)
})
arcane:Create("UIStroke", {
	Parent = KeybindList.Items.Holder.Instance,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	Color = arcane.Theme.Border,
	Transparency = 0.4
}):AddToTheme({
	Color = "Border"
})
arcane:Create("UIPadding", {
	Parent = KeybindList.Items.Holder.Instance,
	PaddingBottom = UDim.new(0, 10)
})
KeybindList.Items.Title = arcane:Create("TextLabel", {
	Parent = KeybindList.Items.Holder.Instance,
	Name = "\0",
	FontFace = arcane.Font,
	TextColor3 = arcane.Theme.Text,
	Text = "Keybinds",
	TextSize = 14,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 12, 0, 8),
	Size = UDim2.new(1, -24, 0, 18),
	TextXAlignment = Enum.TextXAlignment.Center,
	BorderSizePixel = 0
}):AddToTheme({
	TextColor3 = "Text"
})
KeybindList.Items.Liner = arcane:Create("Frame", {
	Parent = KeybindList.Items.Holder.Instance,
	Name = "\0",
	Position = UDim2.new(0, 12, 0, 30),
	Size = UDim2.new(1, -24, 0, 2),
	BorderSizePixel = 0,
	BackgroundColor3 = arcane.Theme.Accent
}):AddToTheme({
	BackgroundColor3 = "Accent"
})
KeybindList.Items.Content = arcane:Create("Frame", {
	Parent = KeybindList.Items.Holder.Instance,
	Name = "\0",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 12, 0, 38),
	Size = UDim2.new(1, -24, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BorderSizePixel = 0
})
arcane:Create("UIListLayout", {
	Parent = KeybindList.Items.Content.Instance,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder
})
KeybindList.Items.Holder:MakeDraggable()
task.defer(function()
	local AbsolutePosition = KeybindList.Items.Holder.Instance.AbsolutePosition

	KeybindList.Items.Holder.Instance.AnchorPoint = Vector2.new(0, 0)
	KeybindList.Items.Holder.Instance.Position = UDim2.fromOffset(AbsolutePosition.X, AbsolutePosition.Y + Y)
end)
KeybindList.Add = function(p87, p88)
	local tween2 = arcane:Create("Frame", {
		Parent = KeybindList.Items.Content.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		BorderSizePixel = 0
	})
	local v197 = arcane:Create("TextLabel", {
		Parent = tween2.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = p88,
		TextSize = 13,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -110, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	local v198 = arcane:Create("TextLabel", {
		Parent = tween2.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = "[...]",
		TextSize = 13,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -52, 0, 0),
		Size = UDim2.new(0, 52, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	local v199 = arcane:Create("TextLabel", {
		Parent = tween2.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = "Off",
		TextSize = 13,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 48, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})

	arcane:RegisterText(v197.Instance, p88)

	local t11 = {
		Mode = "Toggle",
		Active = false
	}

	local function v201()
		if t11.Active then
			v199.Instance.Text = t11.Mode == "Hold" and "Holding" or "Toggled"
			v197:ChangeItemTheme({
				TextColor3 = "Text"
			})
			v198:ChangeItemTheme({
				TextColor3 = "Accent"
			})
			v199:ChangeItemTheme({
				TextColor3 = "Text"
			})
			v197:Tween({
				TextColor3 = arcane.Theme.Text
			})
			v198:Tween({
				TextColor3 = arcane.Theme.Accent
			})
			v199:Tween({
				TextColor3 = arcane.Theme.Text
			})
		else
			v199.Instance.Text = "Off"
			v197:ChangeItemTheme({
				TextColor3 = "DimText"
			})
			v198:ChangeItemTheme({
				TextColor3 = "DimText"
			})
			v199:ChangeItemTheme({
				TextColor3 = "DimText"
			})
			v197:Tween({
				TextColor3 = arcane.Theme.DimText
			})
			v198:Tween({
				TextColor3 = arcane.Theme.DimText
			})
			v199:Tween({
				TextColor3 = arcane.Theme.DimText
			})
		end
	end

	t11.SetKey = function(p89, p90)
		v198.Instance.Text = "[" .. tostring(p90) .. "]"
	end
	t11.SetMode = function(p91, p92)
		t11.Mode = p92
		v201()
	end
	t11.SetActive = function(p93, p94)
		t11.Active = p94
		v201()
	end
	t11.Remove = function()
		tween2.Instance:Destroy()
	end

	return t11
end
KeybindList.SetVisibility = function(p95, p96)
	KeybindList.Items.Holder:FadeDescendants(p96)
end
arcane.Notification = function(p97, p98)
	local v202 = p98 or {}
	local Name = v202.Name or v202.name or "Notification"
	local Description = v202.Description or v202.description or ""
	local Duration = v202.Duration or v202.duration or 5
	local Icon = v202.Icon or v202.icon
	local Color = v202.Color or v202.color or arcane.Theme.Accent
	local t12 = {
		Notification = arcane:Create("Frame", {
			Parent = arcane.NotifHolder.Instance,
			Name = "\0",
			Size = UDim2.new(0, 0, 0, 73),
			ClipsDescendants = true,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Section
		}):AddToTheme({
			BackgroundColor3 = "Section"
		})
	}

	arcane:Create("UICorner", {
		Parent = t12.Notification.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	t12.Stroke = arcane:Create("UIStroke", {
		Parent = t12.Notification.Instance,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = arcane.Theme.Border,
		Transparency = 0.4
	}):AddToTheme({
		Color = "Border"
	})

	local n5 = 12

	if Icon then
		t12.Icon = arcane:Create("ImageLabel", {
			Parent = t12.Notification.Instance,
			Name = "\0",
			ImageColor3 = Color,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 13),
			Size = UDim2.new(0, 18, 0, 18),
			BorderSizePixel = 0
		})
		v25(t12.Icon.Instance, Icon)
		n5 = 38
	end

	t12.Title = arcane:Create("TextLabel", {
		Parent = t12.Notification.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, n5, 0, 12),
		Size = UDim2.new(0, 260 - n5 - 12, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	t12.Description = arcane:Create("TextLabel", {
		Parent = t12.Notification.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		TextTransparency = 0.35,
		Text = Description,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 36),
		Size = UDim2.new(0, 150, 0, 15),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	t12.Duration = arcane:Create("TextLabel", {
		Parent = t12.Notification.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = Duration .. "s",
		TextSize = 13,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 36),
		Size = UDim2.new(0, 60, 0, 15),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	t12.Liner = arcane:Create("Frame", {
		Parent = t12.Notification.Instance,
		Name = "\0",
		Position = UDim2.new(0, 12, 0, 59),
		Size = UDim2.new(1, -24, 0, 4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color
	})
	arcane:Create("UICorner", {
		Parent = t12.Liner.Instance,
		CornerRadius = UDim.new(1, 0)
	})

	local t13 = {}

	for _, v in t12, nil, nil do
		local Instance_ = v.Instance

		if Instance_:IsA("ImageLabel") then
			table.insert(t13, {
				Object = v,
				Property = "ImageTransparency",
				Original = Instance_.ImageTransparency
			})
		elseif Instance_:IsA("TextLabel") then
			table.insert(t13, {
				Object = v,
				Property = "TextTransparency",
				Original = Instance_.TextTransparency
			})
		elseif Instance_:IsA("Frame") then
			table.insert(t13, {
				Object = v,
				Property = "BackgroundTransparency",
				Original = Instance_.BackgroundTransparency
			})
		elseif Instance_:IsA("UIStroke") then
			table.insert(t13, {
				Object = v,
				Property = "Transparency",
				Original = Instance_.Transparency
			})
		end
	end

	for _, v in t13, nil, nil do
		v.Object.Instance[v.Property] = 1
	end

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local u217 = true

	arcane:Thread(function()
		t12.Notification:Tween({
			Size = UDim2.new(0, 260, 0, 73)
		}, tweenInfo)

		for _, v in t13, nil, nil do
			v.Object:Tween({
				[v.Property] = v.Original
			}, tweenInfo)
		end

		t12.Liner:Tween({
			Size = UDim2.new(0, 0, 0, 4)
		}, TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out))
		task.spawn(function()
			local v220 = Duration

			while u217 and v220 > 0 do
				task.wait(0.1)
				v220 = math.max(v220 - 0.1, 0)

				if t12.Duration.Instance.Parent then
					t12.Duration.Instance.Text = arcane:Round(v220, 0.1) .. "s"
				end
			end
		end)
		task.delay(Duration + 0.1, function()
			u217 = false

			for _, v in t13, nil, nil do
				v.Object:Tween({
					[v.Property] = 1
				}, tweenInfo)
			end

			t12.Notification:Tween({
				Size = UDim2.new(0, 0, 0, 0)
			}, tweenInfo)
			task.wait(0.5)
			t12.Notification.Instance:Destroy()
		end)
	end)
end
arcane.Tooltip = function(p99, p100)
	local Instance_ = p99.Instance

	if not Instance_ or p100 == nil or p100 == "" then
		return
	end

	local t14 = {
		Tooltip = arcane:Create("Frame", {
			Parent = arcane.Holder.Instance,
			Name = "\0",
			ClipsDescendants = true,
			Size = UDim2.new(0, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 999,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = arcane.Theme.Section
		}):AddToTheme({
			BackgroundColor3 = "Section"
		})
	}

	arcane:Create("UICorner", {
		Parent = t14.Tooltip.Instance,
		CornerRadius = UDim.new(0, 8)
	})
	arcane:Create("UIPadding", {
		Parent = t14.Tooltip.Instance,
		PaddingRight = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12)
	})
	t14.Text = arcane:Create("TextLabel", {
		Parent = t14.Tooltip.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = p100,
		TextSize = 13,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 4, 0.5, 0),
		ZIndex = 999,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X
	}):AddToTheme({
		TextColor3 = "Text"
	})
	t14.Liner = arcane:Create("Frame", {
		Parent = t14.Tooltip.Instance,
		Name = "\0",
		Position = UDim2.new(0, -12, 0, 0),
		Size = UDim2.new(0, 4, 1, 0),
		ZIndex = 999,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Accent
	}):AddToTheme({
		BackgroundColor3 = "Accent"
	})

	local function v225(p101)
		for _, v in t14, nil, nil do
			if v.Instance:IsA("Frame") then
				v:Tween({
					BackgroundTransparency = p101 and 0 or 1
				})
			elseif v.Instance:IsA("TextLabel") then
				v:Tween({
					TextTransparency = p101 and 0 or 1
				})
			end
		end
	end

	v225(false)

	if not v12 then
		local connection

		p99:OnHover(function()
			local mouseLocation = UserInputService:GetMouseLocation()

			t14.Tooltip.Instance.Position = UDim2.new(0, mouseLocation.X + 18, 0, mouseLocation.Y + 12)
			v225(true)
			connection = RunService.RenderStepped:Connect(function()
				mouseLocation = UserInputService:GetMouseLocation()
				t14.Tooltip.Instance.Position = UDim2.new(0, mouseLocation.X + 18, 0, mouseLocation.Y + 12)
			end)
		end, function()
			v225(false)

			if connection then
				connection:Disconnect()
				connection = nil
			end
		end)

		return
	end

	if not Instance_:IsA("GuiButton") then
		return
	end

	local u230 = false

	p99:Connect("MouseButton1Click", function()
		u230 = not u230

		if u230 then
			local screenScale = arcane:GetScreenScale()

			t14.Tooltip.Instance.Position = UDim2.fromOffset(Instance_.AbsolutePosition.X / screenScale, (Instance_.AbsolutePosition.Y + Instance_.AbsoluteSize.Y + Y + 6) / screenScale)
			v225(true)
		else
			v225(false)
		end
	end)
end
arcane.Window = function(p102, p103)
	local v232 = p103 or {}
local t15 = {
    Name = v232.Name or v232.name or "ARCANE",
    Title = v232.Title or v232.title or v232.Name or v232.name or "ARCANE",
    Suffix = v232.Suffix or v232.suffix or "",
    User = v232.User or v232.user or LocalPlayer.Name,
    Logo = v232.Logo or v232.logo or "72939878637463",
    IsOpen = true,
    Pages = {},
    Items = {}
}
	local screenScale = arcane:GetScreenScale()
	local ViewportSize = workspace.CurrentCamera.ViewportSize
	local items = {
		MainFrame = arcane:Create("Frame", {
			Parent = arcane.Holder.Instance,
			Name = "\0",
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromOffset(ViewportSize.X / (2 * screenScale) - 280, ViewportSize.Y / (2 * screenScale) - 278),
			Size = UDim2.new(0, 560, 0, 570),
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Background
		}):AddToTheme({
			BackgroundColor3 = "Background"
		})
	}

	arcane:Create("UICorner", {
		Parent = items.MainFrame.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	items.TopBar = arcane:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Name = "\0",
		Size = UDim2.new(1, 0, 0, 37),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Topbar
	}):AddToTheme({
		BackgroundColor3 = "Topbar"
	})
	arcane:Create("UICorner", {
		Parent = items.TopBar.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	arcane:Create("Frame", {
		Parent = items.TopBar.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 10),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Topbar
	}):AddToTheme({
		BackgroundColor3 = "Topbar"
	})
	items.MainFrame:MakeDraggable(v12 and items.TopBar.Instance or nil)
	items.Logo = arcane:Create("ImageLabel", {
		Parent = items.TopBar.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 10),
		Size = UDim2.new(0, 27, 0, 20),
		BorderSizePixel = 0
	})
	v25(items.Logo.Instance, t15.Logo)
	items.HubName = arcane:Create("TextLabel", {
    Parent = items.TopBar.Instance,
    Name = "\0",
    FontFace = arcane.Font,
    TextColor3 = arcane.Theme.Text,
    Text = t15.Title,
    TextSize = 16,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 46, 0, 0),
    Size = UDim2.new(0, 100, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    BorderSizePixel = 0
}):AddToTheme({
    TextColor3 = "Text"
})

items.HubSuffix = arcane:Create("TextLabel", {
    Parent = items.TopBar.Instance,
    Name = "\0",
    FontFace = arcane.Font,
    TextColor3 = arcane.Theme.Accent,
    Text = t15.Suffix,
    TextSize = 16,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 46, 0, 0),
    Size = UDim2.new(0, 100, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    BorderSizePixel = 0
}):AddToTheme({
    TextColor3 = "Accent"
})

task.defer(function()
    local titleWidth = items.HubName.Instance.TextBounds.X + 4
    items.HubSuffix.Instance.Position = UDim2.new(0, 46 + titleWidth, 0, 0)
end)

arcane:Connect(items.HubName.Instance:GetPropertyChangedSignal("TextBounds"), function()
    local titleWidth = items.HubName.Instance.TextBounds.X + 4
    items.HubSuffix.Instance.Position = UDim2.new(0, 46 + titleWidth, 0, 0)
end)
	items.User = arcane:Create("TextLabel", {
		Parent = items.TopBar.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t15.User,
		TextSize = 14,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.new(0, 157, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	items.Line = arcane:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Name = "\0",
		Position = UDim2.new(0, 0, 0, 36),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Divider
	}):AddToTheme({
		BackgroundColor3 = "Divider"
	})
	items.ThemeHolder = arcane:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -15, 0, 53),
		Size = UDim2.new(0, 108, 0, 46),
		ZIndex = 3,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Topbar
	}):AddToTheme({
		BackgroundColor3 = "Topbar"
	})
	arcane:Create("UICorner", {
		Parent = items.ThemeHolder.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	arcane:Create("UIListLayout", {
		Parent = items.ThemeHolder.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local t16 = {}

	local function v238(p104, p105)
		local v239 = arcane:Create("TextButton", {
			Parent = items.ThemeHolder.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 46, 0, 38),
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Selected
		}):AddToTheme({
			BackgroundColor3 = "Selected"
		})

		arcane:Create("UICorner", {
			Parent = v239.Instance,
			CornerRadius = UDim.new(0, 8)
		})

		local v240 = arcane:Create("ImageLabel", {
			Parent = v239.Instance,
			Name = "\0",
			ImageColor3 = arcane.Theme.DimIcon,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			ImageColor3 = "DimIcon"
		})

		v25(v240.Instance, p104)

		local t17 = {
			Button = v239,
			Icon = v240,
			Theme = p105,
			Set = function(p106, p107)
				if p107 then
					v239:ChangeItemTheme({
						BackgroundColor3 = "Selected"
					})
					v240:ChangeItemTheme({
						ImageColor3 = "Accent"
					})
					v239:Tween({
						BackgroundTransparency = 0,
						BackgroundColor3 = arcane.Theme.Selected
					})
					v240:Tween({
						ImageColor3 = arcane.Theme.Accent
					})
				else
					v240:ChangeItemTheme({
						ImageColor3 = "DimIcon"
					})
					v239:Tween({
						BackgroundTransparency = 1
					})
					v240:Tween({
						ImageColor3 = arcane.Theme.DimIcon
					})
				end
			end
		}

		v239:Connect("MouseButton1Down", function()
			if p105 == "Light" then
				arcane:SetTheme("Light")
			else
				arcane:SetTheme(arcane.PreviousTheme or "Dark")
			end

			local v242 = arcane.CurrentTheme == "Light"

			for _, v in t16, nil, nil do
				v:Set(v.Theme == "Light" == v242)
			end
		end)
		table.insert(t16, t17)

		return t17
	end

	v238("moon", "Dark"):Set(true)
	v238("sun", "Light"):Set(false)
	items.CornerHolder = arcane:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -15, 1, -62),
		Size = UDim2.new(0, 0, 0, 46),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ZIndex = 3,
		BorderSizePixel = 0
	})
	arcane:Create("UIListLayout", {
		Parent = items.CornerHolder.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local function v245(p108)
		local v246 = arcane:Create("Frame", {
			Parent = items.CornerHolder.Instance,
			Name = "\0",
			Size = UDim2.new(0, 0, 0, 46),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = p108,
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Topbar
		}):AddToTheme({
			BackgroundColor3 = "Topbar"
		})

		arcane:Create("UICorner", {
			Parent = v246.Instance,
			CornerRadius = UDim.new(0, 10)
		})
		arcane:Create("UIPadding", {
			Parent = v246.Instance,
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4)
		})
		arcane:Create("UIListLayout", {
			Parent = v246.Instance,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		return v246
	end

	items.SettingsHolder = v245(1)
	items.LanguageHolder = v245(2)
	items.UISettingsButton = arcane:Create("TextButton", {
		Parent = items.SettingsHolder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 46, 0, 38),
		ZIndex = 3,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Selected
	}):AddToTheme({
		BackgroundColor3 = "Selected"
	})
	arcane:Create("UICorner", {
		Parent = items.UISettingsButton.Instance,
		CornerRadius = UDim.new(0, 8)
	})
	items.UISettingsIcon = arcane:Create("ImageLabel", {
		Parent = items.UISettingsButton.Instance,
		Name = "\0",
		ImageColor3 = arcane.Theme.DimIcon,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1,
		ZIndex = 3,
		BorderSizePixel = 0
	}):AddToTheme({
		ImageColor3 = "DimIcon"
	})
	v25(items.UISettingsIcon.Instance, "10734950309")

	local t18 = {}

	local function v248(p109)
		local v249 = arcane:Create("TextButton", {
			Parent = items.LanguageHolder.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 46, 0, 38),
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Selected
		}):AddToTheme({
			BackgroundColor3 = "Selected"
		})

		arcane:Create("UICorner", {
			Parent = v249.Instance,
			CornerRadius = UDim.new(0, 8)
		})

		local v250 = arcane:Create("TextLabel", {
			Parent = v249.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.DimText,
			Text = p109,
			TextSize = 13,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "DimText"
		})
		local t19 = {
			Button = v249,
			Label = v250,
			Language = p109,
			Set = function(p110, p111)
				if p111 then
					v250:ChangeItemTheme({
						TextColor3 = "Accent"
					})
					v249:Tween({
						BackgroundTransparency = 0
					})
					v250:Tween({
						TextColor3 = arcane.Theme.Accent
					})
				else
					v250:ChangeItemTheme({
						TextColor3 = "DimText"
					})
					v249:Tween({
						BackgroundTransparency = 1
					})
					v250:Tween({
						TextColor3 = arcane.Theme.DimText
					})
				end
			end
		}

		v249:Connect("MouseButton1Down", function()
			for _, v in t18, nil, nil do
				v:Set(v.Language == p109)
			end

			local UIPanelState = t15.UIPanelState

			if UIPanelState and (UIPanelState.IsOpen or UIPanelState.Debounce) then
				task.delay(arcane.Animation.Time + 0.1, function()
					arcane:SetLanguage(p109)
				end)
			else
				arcane:SetLanguage(p109)
			end
		end)
		table.insert(t18, t19)

		return t19
	end

	v248("ENG"):Set(true)
	v248("RUS"):Set(false)
	items.UIPanel = arcane:Create("Frame", {
		Parent = arcane.UnusedHolder.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(1, 1),
		Visible = false,
		Size = UDim2.new(0, 230, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 60,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Section
	}):AddToTheme({
		BackgroundColor3 = "Section"
	})
	arcane:Create("UICorner", {
		Parent = items.UIPanel.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	arcane:Create("UIStroke", {
		Parent = items.UIPanel.Instance,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = arcane.Theme.Border,
		Transparency = 0.4
	}):AddToTheme({
		Color = "Border"
	})
	arcane:Create("UIPadding", {
		Parent = items.UIPanel.Instance,
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6)
	})
	items.UIPanelContent = arcane:Create("Frame", {
		Parent = items.UIPanel.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0
	})
	arcane:Create("UIListLayout", {
		Parent = items.UIPanelContent.Instance,
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local t20 = {
		Items = {
			Content = items.UIPanelContent
		},
		LastDivider = nil
	}
	local isPopup = {
		IsOpen = false,
		Debounce = false
	}

	isPopup.IsPopup = isPopup
	t20.IsPopup = isPopup
	t15.UIPanelState = isPopup
	task.defer(function()
		arcane.Dropdown(t20, {
			Name = "Language",
			Items = {
				"ENG",
				"RUS",
				"SPA",
				"BRA",
				"PHL",
				"FRA",
				"GER",
				"TUR"
			},
			Default = "ENG",
			Callback = function(p112)
				if type(p112) ~= "string" or p112 == arcane.Language then
					return
				end

				arcane:SetLanguage(p112)

				for _, v in t18, nil, nil do
					v:Set(v.Language == p112)
				end
			end
		})
		arcane.Toggle(t20, {
			Name = "Hide Username",
			Callback = function(p113)
				local Instance_ = items.User.Instance
				local v260 = p113

				Instance_.Text = v260 and "Username" or t15.User
			end
		})
		arcane.Toggle(t20, {
			Name = "Keybind List",
			Callback = function(p114)
				arcane.KeybindList:SetVisibility(p114)
			end
		})
		arcane.Toggle(t20, {
			Name = "Show Watermark",
			Default = true,
			Callback = function(p115)
				if t15.Items.Watermark then
					t15.Items.Watermark.Holder:FadeDescendants(p115)
				end
			end
		})
	end)
	isPopup.SetOpen = function(p116, p117)
		if isPopup.Debounce then
			return
		end

		isPopup.IsOpen = p117
		isPopup.Debounce = true

		local screenScale2 = arcane:GetScreenScale()
		local Instance_ = items.UISettingsButton.Instance
		local v263 = (Instance_.AbsolutePosition.X + Instance_.AbsoluteSize.X) / screenScale2
		local v264 = (Instance_.AbsolutePosition.Y - 8 + Y) / screenScale2

		if p117 then
			items.UISettingsButton:Tween({
				BackgroundTransparency = 0
			})
			items.UISettingsIcon:ChangeItemTheme({
				ImageColor3 = "Accent"
			})
			items.UISettingsIcon:Tween({
				ImageColor3 = arcane.Theme.Accent
			})
			items.UIPanel.Instance.Parent = arcane.Holder.Instance
			items.UIPanel.Instance.Position = UDim2.fromOffset(v263, v264 + 10)
			items.UIPanel.Instance.Visible = true
			arcane:RaisePopup(items.UIPanel.Instance, true)
			items.UIPanel:Tween({
				Position = UDim2.fromOffset(v263, v264)
			})

			for _, v in arcane.OpenFrames, nil, nil do
				if v ~= isPopup then
					v:SetOpen(false)
				end
			end

			arcane.OpenFrames[isPopup] = isPopup
			items.UIPanel:FadeDescendants(true, function()
				isPopup.Debounce = false
			end)
		else
			items.UISettingsButton:Tween({
				BackgroundTransparency = 1
			})
			items.UISettingsIcon:ChangeItemTheme({
				ImageColor3 = "DimIcon"
			})
			items.UISettingsIcon:Tween({
				ImageColor3 = arcane.Theme.DimIcon
			})
			arcane.OpenFrames[isPopup] = nil

			for _, v in arcane.OpenFrames, nil, nil do
				if v.Host == isPopup then
					v:SetOpen(false)
				end
			end

			items.UIPanel:Tween({
				Position = UDim2.fromOffset(v263, v264 + 10)
			})
			items.UIPanel:FadeDescendants(false, function()
				isPopup.Debounce = false
				items.UIPanel.Instance.Parent = arcane.UnusedHolder.Instance
				arcane:RaisePopup(items.UIPanel.Instance, false)
			end)
		end
	end
	items.UISettingsButton:Connect("MouseButton1Down", function()
		isPopup:SetOpen(not isPopup.IsOpen)
	end)
	arcane:Connect(UserInputService.InputBegan, function(p118)
		if (p118.UserInputType == Enum.UserInputType.MouseButton1 or p118.UserInputType == Enum.UserInputType.Touch) and isPopup.IsOpen then
			if not items.UIPanel:IsMouseOverFrame() then
				if not items.UISettingsButton:IsMouseOverFrame() then
					for _, v in arcane.OpenFrames, nil, nil do
						if v == isPopup then
							continue
						end

						return
					end

					isPopup:SetOpen(false)
				end
			end
		end
	end)
	items.PagesHolder = arcane:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Name = "\0",
		Position = UDim2.new(0, 15, 1, -62),
		Size = UDim2.new(0, 0, 0, 46),
		ZIndex = 3,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = arcane.Theme.Topbar
	}):AddToTheme({
		BackgroundColor3 = "Topbar"
	})
	arcane:Create("UICorner", {
		Parent = items.PagesHolder.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	arcane:Create("UIPadding", {
		Parent = items.PagesHolder.Instance,
		PaddingRight = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4)
	})
	arcane:Create("UIListLayout", {
		Parent = items.PagesHolder.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	t15.Items = items
	arcane:Connect(UserInputService.InputBegan, function(p119, p120)
		if p120 then
			return
		end

		if tostring(p119.KeyCode) == arcane.MenuKeybind then
			t15:SetOpen(not t15.IsOpen)
		end
	end)
	t15.SetOpen = function(p121, p122)
		t15.IsOpen = p122

		if not p122 then
			for _, v in arcane.OpenFrames, nil, nil do
				if v.SetOpen then
					v:SetOpen(false)
				end
			end
		end

		items.MainFrame:FadeDescendants(p122)

		if items.MobileText then
			items.MobileText.Instance.Text = p122 and "Close" or "Open"
		end
	end
	t15.Center = function()
		local screenScale2 = arcane:GetScreenScale()
		local ViewportSize2 = workspace.CurrentCamera.ViewportSize

		items.MainFrame.Instance.Position = UDim2.fromOffset(ViewportSize2.X / (2 * screenScale2) - 280, ViewportSize2.Y / (2 * screenScale2) - 278)
	end
	t15.Watermark = function(p123, p124)
		local v275 = p124 or {}
		local Title = v275.Title or v275.title or t15.Name
		local Icon = v275.Icon or v275.icon or t15.Logo
		local watermark = {
			Holder = arcane:Create("Frame", {
				Parent = arcane.Holder.Instance,
				Name = "\0",
				Active = true,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -16, 0, 16),
				Size = UDim2.new(0, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				BorderSizePixel = 0
			})
		}

		arcane:Create("UIListLayout", {
			Parent = watermark.Holder.Instance,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5)
		})

		local function v279(p125)
			local v280 = arcane:Create("Frame", {
				Parent = watermark.Holder.Instance,
				Name = "\0",
				Size = UDim2.new(0, 0, 0, 34),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = p125,
				BorderSizePixel = 0,
				BackgroundColor3 = arcane.Theme.Section
			}):AddToTheme({
				BackgroundColor3 = "Section"
			})

			arcane:Create("UICorner", {
				Parent = v280.Instance,
				CornerRadius = UDim.new(0, 10)
			})
			arcane:Create("UIStroke", {
				Parent = v280.Instance,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = arcane.Theme.Border,
				Transparency = 0.4
			}):AddToTheme({
				Color = "Border"
			})
			arcane:Create("UIPadding", {
				Parent = v280.Instance,
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14)
			})
			arcane:Create("UIListLayout", {
				Parent = v280.Instance,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8)
			})

			return v280
		end

		watermark.TitlePill = v279(1)
		watermark.Icon = arcane:Create("ImageLabel", {
			Parent = watermark.TitlePill.Instance,
			Name = "\0",
			ImageColor3 = arcane.Theme.Accent,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 27, 0, 20),
			LayoutOrder = 1,
			BorderSizePixel = 0
		}):AddToTheme({
			ImageColor3 = "Accent"
		})
		v25(watermark.Icon.Instance, Icon)
		watermark.Title = arcane:Create("TextLabel", {
			Parent = watermark.TitlePill.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = Title,
			TextSize = 15,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 2,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text"
		})
		watermark.FpsPill = v279(2)
		watermark.Fps = arcane:Create("TextLabel", {
			Parent = watermark.FpsPill.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = "0 FPS",
			TextSize = 15,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Center,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text"
		})
		watermark.PingPill = v279(3)
		watermark.Ping = arcane:Create("TextLabel", {
			Parent = watermark.PingPill.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = "0 ping",
			TextSize = 15,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Center,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text"
		})
		watermark.Holder:MakeDraggable()

		local Stats = game:GetService("Stats")
		local n6 = 0
		local n7 = 0

		arcane:Connect(RunService.RenderStepped, function(p126)
			n6 += 1
			n7 += p126

			if n7 >= 0.5 then
				watermark.Fps.Instance.Text = math.floor(n6 / n7) .. " FPS"
				n6 = 0
				n7 = 0

				local ok2, result2 = pcall(function()
					return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
				end)

				watermark.Ping.Instance.Text = (ok2 and result2 or 0) .. " ping"
			end
		end)

		local function v286()
			arcane.NotifHolder.Instance.Position = UDim2.new(1, 0, 0, watermark.Holder.Instance.Position.Y.Offset + watermark.Holder.Instance.AbsoluteSize.Y / arcane:GetScreenScale())
		end

		arcane:Connect(watermark.Holder.Instance:GetPropertyChangedSignal("AbsoluteSize"), v286)
		task.defer(v286)
		t15.Items.Watermark = watermark

		return watermark
	end
	table.insert(arcane.Windows, t15)

	if v12 then
		items.MobileToggle = arcane:Create("TextButton", {
			Parent = arcane.Holder.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 10),
			Size = UDim2.new(0, 0, 0, 40),
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = 60,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Topbar
		}):AddToTheme({
			BackgroundColor3 = "Topbar"
		})
		arcane:Create("UICorner", {
			Parent = items.MobileToggle.Instance,
			CornerRadius = UDim.new(0, 10)
		})
		arcane:Create("UIStroke", {
			Parent = items.MobileToggle.Instance,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = arcane.Theme.Border,
			Transparency = 0.4
		}):AddToTheme({
			Color = "Border"
		})
		arcane:Create("UIPadding", {
			Parent = items.MobileToggle.Instance,
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 14)
		})
		v25(arcane:Create("ImageLabel", {
			Parent = items.MobileToggle.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 22, 0, 22),
			ZIndex = 60,
			BorderSizePixel = 0
		}).Instance, t15.Logo)
		items.MobileText = arcane:Create("TextLabel", {
			Parent = items.MobileToggle.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = "Close",
			TextSize = 15,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 30, 0.5, 0),
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 60,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text"
		})
		items.MobileToggle:Connect("MouseButton1Down", function()
			t15:SetOpen(not t15.IsOpen)
		end)
	end

	return setmetatable(t15, arcane)
end

local function v287(p127, p128, p129)
	local t21 = {
		Button = arcane:Create("TextButton", {
			Parent = p127,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 42, 0, 38),
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Selected
		}):AddToTheme({
			BackgroundColor3 = "Selected"
		})
	}

	arcane:Create("UICorner", {
		Parent = t21.Button.Instance,
		CornerRadius = UDim.new(0, 8)
	})
	t21.Icon = arcane:Create("ImageLabel", {
		Parent = t21.Button.Instance,
		Name = "\0",
		ImageColor3 = arcane.Theme.DimIcon,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.new(0, 18, 0, 18),
		ZIndex = 3,
		BorderSizePixel = 0
	}):AddToTheme({
		ImageColor3 = "DimIcon"
	})
	v25(t21.Icon.Instance, p129)
	t21.Text = arcane:Create("TextLabel", {
		Parent = t21.Button.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = p128,
		TextSize = 14,
		Visible = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 38, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 3,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	arcane:RegisterText(t21.Text.Instance, p128)
	t21.Width = function()
		return t21.Text.Instance.TextBounds.X + (v12 and 64 or 50)
	end
	arcane:Connect(t21.Text.Instance:GetPropertyChangedSignal("TextBounds"), function()
		if t21.IsActive and t21.IsActive() then
			t21.Button:Tween({
				Size = UDim2.new(0, t21.Width(), 0, 38)
			})
		end
	end)

	return t21
end

arcane.Page = function(p130, p131)
	local v289 = p131 or {}
	local t22 = {
		Name = v289.Name or v289.name or "Page",
		Icon = v289.Icon or v289.icon or "swords",
		Window = p130,
		SubPages = {},
		Active = false,
		Debounce = false,
		Items = {}
	}
	local v292 = v287(t22.Window.Items.PagesHolder.Instance, t22.Name, t22.Icon)
	local items = {
		Tab = v292.Button,
		Icon = v292.Icon,
		Text = v292.Text
	}

	v292.IsActive = function()
		return t22.Active
	end
	items.Content = arcane:Create("Frame", {
		Parent = arcane.UnusedHolder.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		BorderSizePixel = 0
	})
	items.SubPagesHolder = arcane:Create("Frame", {
		Parent = items.Content.Instance,
		Name = "\0",
		Position = UDim2.new(0, 15, 0, 53),
		Size = UDim2.new(0, 0, 0, 46),
		ZIndex = 2,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = arcane.Theme.Topbar
	}):AddToTheme({
		BackgroundColor3 = "Topbar"
	})
	arcane:Create("UICorner", {
		Parent = items.SubPagesHolder.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	arcane:Create("UIPadding", {
		Parent = items.SubPagesHolder.Instance,
		PaddingRight = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4)
	})
	arcane:Create("UIListLayout", {
		Parent = items.SubPagesHolder.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	items.Columns = arcane:Create("Frame", {
		Parent = items.Content.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 112),
		Size = UDim2.new(1, -30, 1, -186),
		BorderSizePixel = 0
	})
	t22.Items = items
	items.Tab:OnHover(function()
		if t22.Active then
			return
		end

		items.Icon:Tween({
			ImageColor3 = arcane.Theme.Text
		})
	end, function()
		if t22.Active then
			return
		end

		items.Icon:Tween({
			ImageColor3 = arcane.Theme.DimIcon
		})
	end)
	t22.Switch = function(p132, p133)
		t22.Active = p133
		items.Content.Instance.Parent = p133 and t22.Window.Items.MainFrame.Instance or arcane.UnusedHolder.Instance
		items.Content:ResetFade()
		items.Content.Instance.Visible = p133

		if p133 then
			items.Text.Instance.Visible = true
			items.Tab:ChangeItemTheme({
				BackgroundColor3 = "Selected"
			})
			items.Icon:ChangeItemTheme({
				ImageColor3 = "Accent"
			})
			items.Tab:Tween({
				BackgroundTransparency = 0,
				Size = UDim2.new(0, v292.Width(), 0, 38)
			})
			task.delay(0.1, function()
				if t22.Active then
					items.Tab:Tween({
						Size = UDim2.new(0, v292.Width(), 0, 38)
					})
				end
			end)
			items.Icon:Tween({
				ImageColor3 = arcane.Theme.Accent
			})
			items.Content.Instance.Position = UDim2.new(0, 0, 0, 14)
			items.Content:Tween({
				Position = UDim2.new(0, 0, 0, 0)
			})
			items.SubPagesHolder:FadeDescendants(true)

			for _, v in t22.SubPages, nil, nil do
				if v.Active then
					for _, v2 in v.Sections, nil, nil do
						if v2.Appear then
							v2:Appear()
						end
					end
				end
			end
		else
			items.Text.Instance.Visible = false
			items.Icon:ChangeItemTheme({
				ImageColor3 = "DimIcon"
			})
			items.Tab:Tween({
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 42, 0, 38)
			})
			items.Icon:Tween({
				ImageColor3 = arcane.Theme.DimIcon
			})
		end
	end
	items.Tab:Connect("MouseButton1Down", function()
		for _, v in arcane.OpenFrames, nil, nil do
			v:SetOpen(false)
		end

		for _, v in t22.Window.Pages, nil, nil do
			v:Switch(v == t22)
		end
	end)

	if #t22.Window.Pages == 0 then
		t22:Switch(true)
	end

	table.insert(t22.Window.Pages, t22)

	return setmetatable(t22, arcane)
end
arcane.SubPage = function(p134, p135)
	local v301 = p135 or {}
	local t23 = {
		Name = v301.Name or v301.name or "SubPage"
	}
	local Icon = v301.Icon or v301.icon

	t23.Icon = Icon or "house"
	t23.Window = p134.Window
	t23.Page = p134
	t23.OneColumn = v301.OneColumn or v301.onecolumn or false
	t23.Active = false
	t23.Debounce = false
	t23.ColumnsData = {}
	t23.Sections = {}
	t23.Items = {}

	local v305 = v287(t23.Page.Items.SubPagesHolder.Instance, t23.Name, t23.Icon)
	local items = {
		Tab = v305.Button,
		Icon = v305.Icon,
		Text = v305.Text
	}

	v305.IsActive = function()
		return t23.Active
	end

	if #t23.Page.SubPages == 0 then
		items.Icon.Instance.Position = UDim2.new(0, 8, 0.5, 0)
		items.Text.Instance.Position = UDim2.new(0, 34, 0, 0)
	end

	items.Content = arcane:Create("Frame", {
		Parent = arcane.UnusedHolder.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		BorderSizePixel = 0
	})
	items.Left = arcane:Create("ScrollingFrame", {
		Parent = items.Content.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		Selectable = false,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0.5, -8, 1, 0),
		ZIndex = 2,
		BorderSizePixel = 0
	})
	arcane:Create("UIListLayout", {
		Parent = items.Left.Instance,
		Padding = UDim.new(0, 14),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	items.Right = arcane:Create("ScrollingFrame", {
		Parent = items.Content.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		Selectable = false,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.5, -8, 1, 0),
		ZIndex = 2,
		BorderSizePixel = 0
	})
	arcane:Create("UIListLayout", {
		Parent = items.Right.Instance,
		Padding = UDim.new(0, 14),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	if t23.OneColumn then
		items.Left.Instance.Size = UDim2.new(1, 0, 1, 0)
		items.Right.Instance.Visible = false
		t23.ColumnsData[1] = items.Left
		t23.ColumnsData[2] = items.Left
	else
		t23.ColumnsData[1] = items.Left
		t23.ColumnsData[2] = items.Right
	end

	t23.Items = items
	items.Tab:OnHover(function()
		if t23.Active then
			return
		end

		items.Icon:Tween({
			ImageColor3 = arcane.Theme.Text
		})
	end, function()
		if t23.Active then
			return
		end

		items.Icon:Tween({
			ImageColor3 = arcane.Theme.DimIcon
		})
	end)
	t23.Switch = function(p136, p137)
		t23.Active = p137

		local Instance_ = items.Content.Instance
		local v307 = p137

		Instance_.Parent = v307 and t23.Page.Items.Columns.Instance or arcane.UnusedHolder.Instance
		items.Content:ResetFade()
		items.Content.Instance.Visible = p137

		if p137 then
			items.Text.Instance.Visible = true
			items.Tab:ChangeItemTheme({
				BackgroundColor3 = "Selected"
			})
			items.Icon:ChangeItemTheme({
				ImageColor3 = "Accent"
			})
			items.Tab:Tween({
				BackgroundTransparency = 0,
				Size = UDim2.new(0, v305.Width(), 0, 38)
			})
			task.delay(0.1, function()
				if t23.Active then
					items.Tab:Tween({
						Size = UDim2.new(0, v305.Width(), 0, 38)
					})
				end
			end)
			items.Icon:Tween({
				ImageColor3 = arcane.Theme.Accent
			})
			items.Content.Instance.Position = UDim2.new(0, 0, 0, 14)
			items.Content:Tween({
				Position = UDim2.new(0, 0, 0, 0)
			})

			for _, v in t23.Sections, nil, nil do
				if v.Appear then
					v:Appear()
				end
			end
		else
			items.Text.Instance.Visible = false
			items.Icon:ChangeItemTheme({
				ImageColor3 = "DimIcon"
			})
			items.Tab:Tween({
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 42, 0, 38)
			})
			items.Icon:Tween({
				ImageColor3 = arcane.Theme.DimIcon
			})
		end
	end
	items.Tab:Connect("MouseButton1Down", function()
		for _, v in arcane.OpenFrames, nil, nil do
			v:SetOpen(false)
		end

		for _, v in t23.Page.SubPages, nil, nil do
			v:Switch(v == t23)
		end
	end)

	if #t23.Page.SubPages == 0 then
		t23:Switch(true)
	end

	table.insert(t23.Page.SubPages, t23)

	return setmetatable(t23, arcane)
end
arcane.Section = function(p138, p139)
	local v314 = p139 or {}
	local t24 = {
		Name = v314.Name or v314.name or "Section",
		Side = v314.Side or v314.side or 1,
		LastDivider = nil,
		Items = {}
	}
	local items = {
		Section = arcane:Create("Frame", {
			Parent = p138.ColumnsData[t24.Side].Instance,
			Name = "\0",
			Size = UDim2.new(1, 0, 0, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = arcane.Theme.Section
		}):AddToTheme({
			BackgroundColor3 = "Section"
		})
	}

	arcane:Create("UICorner", {
		Parent = items.Section.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	items.Stroke = arcane:Create("UIStroke", {
		Parent = items.Section.Instance,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = arcane.Theme.Border,
		Transparency = 0.5
	}):AddToTheme({
		Color = "Border"
	})
	items.Content = arcane:Create("Frame", {
		Parent = items.Section.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y
	})
	arcane:Create("UIListLayout", {
		Parent = items.Content.Instance,
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	t24.Items = items
	t24.AppearToken = 0
	t24.Appear = function()
		t24.AppearToken += 1

		local AppearToken = t24.AppearToken
		local Instance_ = items.Section.Instance
		local Instance_2 = items.Content.Instance
		local t25 = { {
			Obj = Instance_,
			Prop = "BackgroundTransparency",
			Orig = arcane:CaptureResting(Instance_, "BackgroundTransparency")
		} }

		if items.Stroke then
			table.insert(t25, {
				Obj = items.Stroke.Instance,
				Prop = "Transparency",
				Orig = arcane:CaptureResting(items.Stroke.Instance, "Transparency")
			})
		end

		local t26 = {}

		for _, v in Instance_2:GetDescendants() do
			local tweenProperty = arcane:GetTweenProperty(v)

			if tweenProperty then
				if type(tweenProperty) ~= "table" then
					tweenProperty = { tweenProperty }
				end

				for _, v2 in tweenProperty, nil, nil do
					table.insert(t26, {
						Obj = v,
						Prop = v2,
						Orig = arcane:CaptureResting(v, v2)
					})
				end
			end
		end

		local function v327()
			for _, v in t25, nil, nil do
				v.Obj[v.Prop] = v.Orig
				arcane:ReleaseResting(v.Obj, v.Prop)
			end

			for _, v in t26, nil, nil do
				v.Obj[v.Prop] = v.Orig
				arcane:ReleaseResting(v.Obj, v.Prop)
			end
		end

		for _, v in t25, nil, nil do
			v.Obj[v.Prop] = 1
		end

		for _, v in t26, nil, nil do
			v.Obj[v.Prop] = 1
		end

		task.defer(function()
			RunService.Heartbeat:Wait()

			if t24.AppearToken ~= AppearToken then
				return
			end

			local v336 = Instance_.AbsoluteSize.Y / arcane:GetScreenScale()

			if v336 < 1 then
				v327()

				return
			end

			Instance_.AutomaticSize = Enum.AutomaticSize.None
			Instance_.ClipsDescendants = true
			Instance_.Size = UDim2.new(1, 0, 0, 28)

			for _, v in t25, nil, nil do
				arcane:Tween({
					[v.Prop] = v.Orig
				}, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v.Obj)
			end

			task.wait(0.16)

			if t24.AppearToken ~= AppearToken then
				return
			end

			arcane:Tween({
				Size = UDim2.new(1, 0, 0, v336)
			}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Instance_)

			for _, v in t26, nil, nil do
				arcane:Tween({
					[v.Prop] = v.Orig
				}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), v.Obj)
			end

			task.wait(0.32)

			if t24.AppearToken ~= AppearToken then
				return
			end

			Instance_.AutomaticSize = Enum.AutomaticSize.Y
			Instance_.ClipsDescendants = false
			v327()
		end)
	end

	if p138.Sections then
		table.insert(p138.Sections, t24)
	end

	return setmetatable(t24, arcane)
end

local function v341(p140, p141)
	if p140.LastDivider then
		p140.LastDivider.Instance.Visible = true
	end

	local v342 = arcane:Create("Frame", {
		Parent = p141,
		Name = "\0",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, -24, 0, 1),
		Visible = false,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Divider
	}):AddToTheme({
		BackgroundColor3 = "Divider"
	})

	p140.LastDivider = v342

	return v342
end
local function v343(p142, p143, p144)
	if not p143 or p143 == "" then
		return
	end

	local v344 = arcane:Create("TextButton", {
		Parent = p142.Instance.Parent,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		TextTransparency = 0.25,
		Text = "[ ? ]",
		TextSize = 12,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 28, p142.Instance.Size.Y.Scale, p142.Instance.Size.Y.Offset),
		ZIndex = 4,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	local v345 = v12 and 16 or 8

	local function v346()
		if p144 then
			v344.Instance.AnchorPoint = Vector2.new(0, 0.5)
			v344.Instance.Position = UDim2.new(0.5, p142.Instance.TextBounds.X / 2 + v345, 0.5, 0)
		else
			v344.Instance.Position = UDim2.new(0, p142.Instance.Position.X.Offset + p142.Instance.TextBounds.X + v345, p142.Instance.Position.Y.Scale, p142.Instance.Position.Y.Offset)
		end
	end

	v346()
	arcane:Connect(p142.Instance:GetPropertyChangedSignal("TextBounds"), v346)
	v344:Tooltip(p143)
end

arcane.Toggle = function(p145, p146)
	local v347 = p146 or {}
	local t27 = {
		Name = v347.Name or v347.name or "Toggle",
		Default = v347.Default or v347.default or false
	}
	local Callback = v347.Callback or v347.callback

	t27.Callback = Callback or function()
	end
	t27.Tooltip = v347.Tooltip or v347.tooltip
	t27.Flag = v347.Flag or v347.flag
	t27.Host = p145.IsPopup
	t27.Value = false
	t27.ListEntry = nil
	t27.Items = {}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p145.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 35),
			BorderSizePixel = 0
		})
	}

	items.Button = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 2,
		BorderSizePixel = 0
	})
	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = t27.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	arcane:RegisterText(items.Name.Instance, t27.Name)
	v343(items.Name, t27.Tooltip)
	items.SubElements = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -48, 0.5, 0),
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 3,
		BorderSizePixel = 0
	})
	arcane:Create("UIListLayout", {
		Parent = items.SubElements.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	items.Background = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 14),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.ToggleOff
	}):AddToTheme({
		BackgroundColor3 = "ToggleOff"
	})
	arcane:Create("UICorner", {
		Parent = items.Background.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	items.Circle = arcane:Create("Frame", {
		Parent = items.Background.Instance,
		Name = "\0",
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(0, 8, 0, 8),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.ToggleOffCircle
	}):AddToTheme({
		BackgroundColor3 = "ToggleOffCircle"
	})
	arcane:Create("UICorner", {
		Parent = items.Circle.Instance,
		CornerRadius = UDim.new(1, 0)
	})
	v341(p145, items.Holder.Instance)
	t27.Items = items

	local function set(p147, p148)
		t27.Value = p148

		if t27.Flag then
			arcane.Flags[t27.Flag] = p148
		end

		if p148 then
			items.Background:ChangeItemTheme({
				BackgroundColor3 = "ToggleOn"
			})
			items.Circle:ChangeItemTheme({
				BackgroundColor3 = "AccentDark"
			})
			items.Background:Tween({
				BackgroundColor3 = arcane.Theme.ToggleOn
			})
			items.Circle:Tween({
				BackgroundColor3 = arcane.Theme.AccentDark,
				Position = UDim2.new(0, 17, 0, 3)
			})
		else
			items.Background:ChangeItemTheme({
				BackgroundColor3 = "ToggleOff"
			})
			items.Circle:ChangeItemTheme({
				BackgroundColor3 = "ToggleOffCircle"
			})
			items.Background:Tween({
				BackgroundColor3 = arcane.Theme.ToggleOff
			})
			items.Circle:Tween({
				BackgroundColor3 = arcane.Theme.ToggleOffCircle,
				Position = UDim2.new(0, 3, 0, 3)
			})
		end

		if t27.ListEntry then
			t27.ListEntry:SetActive(p148)
		end

		arcane:SafeCall(t27.Callback, p148)
	end

	t27.Set = set
	t27.Get = function()
		return t27.Value
	end
	t27.Keybind = function(p149, p150)
		local v352 = p150 or {}
		local t28 = {
			Key = v352.Default or v352.default,
			Mode = v352.Mode or v352.mode or "Toggle",
			Flag = v352.Flag or v352.flag,
			Host = t27.Host,
			IsOpen = false,
			Debounce = false,
			Picking = false
		}
		local v354 = arcane:Create("ImageButton", {
			Parent = items.SubElements.Instance,
			Name = "\0",
			AutoButtonColor = false,
			ImageColor3 = arcane.Theme.DimText,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16),
			LayoutOrder = 2,
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			ImageColor3 = "DimText"
		})

		v25(v354.Instance, "10734950309")

		local v355 = arcane:Create("Frame", {
			Parent = arcane.UnusedHolder.Instance,
			Name = "\0",
			Visible = false,
			Size = UDim2.new(0, 200, 0, 92),
			ZIndex = 60,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Section
		}):AddToTheme({
			BackgroundColor3 = "Section"
		})

		arcane:Create("UICorner", {
			Parent = v355.Instance,
			CornerRadius = UDim.new(0, 8)
		})
		arcane:Create("UIStroke", {
			Parent = v355.Instance,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = arcane.Theme.Border,
			Transparency = 0.4
		}):AddToTheme({
			Color = "Border"
		})

		local v356 = arcane:Create("TextButton", {
			Parent = v355.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = "None",
			TextSize = 14,
			AutoButtonColor = false,
			Position = UDim2.new(0, 10, 0, 10),
			Size = UDim2.new(1, -20, 0, 28),
			ZIndex = 61,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Element
		}):AddToTheme({
			BackgroundColor3 = "Element",
			TextColor3 = "Text"
		})

		arcane:Create("UICorner", {
			Parent = v356.Instance,
			CornerRadius = UDim.new(0, 6)
		})

		local tween2 = arcane:Create("Frame", {
			Parent = v355.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 46),
			Size = UDim2.new(1, -20, 0, 28),
			ZIndex = 61,
			BorderSizePixel = 0
		})

		arcane:Create("UIListLayout", {
			Parent = tween2.Instance,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		local function v358(p151)
			local v359 = arcane:Create("TextButton", {
				Parent = tween2.Instance,
				Name = "\0",
				FontFace = arcane.Font,
				TextColor3 = arcane.Theme.DimText,
				Text = p151,
				TextSize = 13,
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, -5, 1, 0),
				ZIndex = 61,
				BorderSizePixel = 0,
				BackgroundColor3 = arcane.Theme.Selected
			}):AddToTheme({
				BackgroundColor3 = "Selected",
				TextColor3 = "DimText"
			})

			arcane:Create("UICorner", {
				Parent = v359.Instance,
				CornerRadius = UDim.new(0, 6)
			})

			return v359
		end

		local Toggle = v358("Toggle")
		local Hold = v358("Hold")

		t27.ListEntry = arcane.KeybindList:Add(t27.Name)

		local function v362(p152)
			if p152 then
				return tostring(p152):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
			end

			return "None"
		end
		local function v363()
			if t28.Flag then
				arcane.Flags[t28.Flag] = {
					Key = t28.Key and tostring(t28.Key) or "None",
					Mode = t28.Mode
				}
			end
		end

		t28.SetMode = function(p153, p154)
			t28.Mode = p154

			local v364 = p154 == "Toggle" and Toggle or Hold
			local v365 = p154 == "Toggle" and Hold

			v365 = v365 or Toggle
			v364:ChangeItemTheme({
				BackgroundColor3 = "Selected",
				TextColor3 = "Accent"
			})
			v364:Tween({
				BackgroundTransparency = 0,
				TextColor3 = arcane.Theme.Accent,
				Size = UDim2.new(0.6, -5, 1, 0)
			})
			v365:ChangeItemTheme({
				BackgroundColor3 = "Selected",
				TextColor3 = "DimText"
			})
			v365:Tween({
				BackgroundTransparency = 1,
				TextColor3 = arcane.Theme.DimText,
				Size = UDim2.new(0.4, -5, 1, 0)
			})

			if t27.ListEntry then
				t27.ListEntry:SetMode(p154)
			end

			v363()
		end
		t28.Set = function(p155, p156)
			t28.Key = p156
			v356.Instance.Text = v362(p156)
			t27.ListEntry:SetKey(v362(p156))
			t28.Picking = false
			v363()
		end
		t28.Get = function()
			return t28.Key, t28.Mode
		end

		local function v366(p157)
			local screenScale = arcane:GetScreenScale()
			local Instance_ = v354.Instance

			return UDim2.fromOffset(Instance_.AbsolutePosition.X / screenScale, (Instance_.AbsolutePosition.Y + Instance_.AbsoluteSize.Y + Y + (p157 or 0)) / screenScale)
		end
		local function setOpen(p158, p159)
			if t28.Debounce then
				return
			end

			t28.IsOpen = p159
			t28.Debounce = true

			if p159 then
				v355.Instance.Parent = arcane.Holder.Instance
				v355.Instance.Position = v366(-8)
				v355.Instance.Visible = true
				arcane:RaisePopup(v355.Instance, true, 70)
				v355:Tween({
					Position = v366(2)
				})

				for _, v in arcane.OpenFrames, nil, nil do
					if not (v == t28 or v == t28.Host or v.IsPopup) then
						v:SetOpen(false)
					end
				end

				arcane.OpenFrames[t28] = t28
				v355:FadeDescendants(true, function()
					t28.Debounce = false
				end)
			else
				arcane.OpenFrames[t28] = nil

				local Position2 = v355.Instance.Position

				v355:Tween({
					Position = UDim2.new(Position2.X.Scale, Position2.X.Offset, Position2.Y.Scale, Position2.Y.Offset - 10)
				})
				v355:FadeDescendants(false, function()
					t28.Debounce = false
					v355.Instance.Parent = arcane.UnusedHolder.Instance
					arcane:RaisePopup(v355.Instance, false)
				end)
			end
		end

		t28.SetOpen = setOpen
		v356:Connect("MouseButton1Click", function()
			if t28.Picking then
				return
			end

			t28.Picking = true
			v356.Instance.Text = ". . ."
			task.wait()

			local connection

			connection = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					return
				end

				connection:Disconnect()

				if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
					t28:Set(nil)
				elseif input.UserInputType == Enum.UserInputType.Keyboard then
					t28:Set(input.KeyCode)
				else
					t28:Set(input.UserInputType)
				end
			end)
		end)
		Toggle:Connect("MouseButton1Down", function()
			t28:SetMode("Toggle")
		end)
		Hold:Connect("MouseButton1Down", function()
			t28:SetMode("Hold")
		end)
		v354:Connect("MouseButton1Down", function()
			t28:SetOpen(not t28.IsOpen)
		end)
		arcane:Connect(UserInputService.InputBegan, function(p160, p161)
			if (p160.UserInputType == Enum.UserInputType.MouseButton1 or p160.UserInputType == Enum.UserInputType.Touch) and t28.IsOpen and not v355:IsMouseOverFrame() and not v354:IsMouseOverFrame() then
				t28:SetOpen(false)
			end

			if not p161 and not t28.Picking then
				if t28.Key then
					if p160.KeyCode == t28.Key or p160.UserInputType == t28.Key then
						if t28.Mode == "Hold" then
							t27:Set(true)
						else
							t27:Set(not t27.Value)
						end
					end

					return
				end
			end
		end)
		arcane:Connect(UserInputService.InputEnded, function(p162)
			if t28.Mode == "Hold" then
				if t28.Key then
					if p162.KeyCode == t28.Key or p162.UserInputType == t28.Key then
						t27:Set(false)
					end

					return
				end
			end
		end)

		if t28.Flag then
			arcane.SetFlags[t28.Flag] = function(p163)
				if type(p163) ~= "table" then
					return
				end

				if p163.Mode then
					t28:SetMode(p163.Mode)
				end

				local Key = p163.Key

				if type(Key) == "string" then
					if Key == "None" then
						t28:Set(nil)
					else
						local v375 = Key:gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
						local ok2, result2 = pcall(function()
							return Enum.KeyCode[v375]
						end)

						if ok2 and result2 then
							t28:Set(result2)
						else
							local ok3, result3 = pcall(function()
								return Enum.UserInputType[v375]
							end)

							if ok3 and result3 then
								t28:Set(result3)
							end
						end
					end
				end
			end
		end

		t28:SetMode(t28.Mode)
		t28:Set(t28.Key)
		t27.ListEntry:SetActive(t27.Value)

		return t28
	end
	t27.Settings = function(p164, p165)
		local v380 = p165 or {}
		local isPopup = {
			IsOpen = false,
			Debounce = false,
			LastDivider = nil,
			Items = {}
		}

		isPopup.IsPopup = isPopup

		local v382 = arcane:Create("TextButton", {
			Parent = items.SubElements.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.DimText,
			Text = "···",
			TextSize = 17,
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 20, 1, 0),
			LayoutOrder = 1,
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "DimText"
		})
		local v383 = arcane:Create("Frame", {
			Parent = arcane.UnusedHolder.Instance,
			Name = "\0",
			Visible = false,
			Size = UDim2.new(0, 240, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 60,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Section
		}):AddToTheme({
			BackgroundColor3 = "Section"
		})

		arcane:Create("UICorner", {
			Parent = v383.Instance,
			CornerRadius = UDim.new(0, 10)
		})
		arcane:Create("UIStroke", {
			Parent = v383.Instance,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = arcane.Theme.Border,
			Transparency = 0.4
		}):AddToTheme({
			Color = "Border"
		})
		arcane:Create("UIPadding", {
			Parent = v383.Instance,
			PaddingBottom = UDim.new(0, 8)
		})
		arcane:RegisterText(arcane:Create("TextLabel", {
			Parent = v383.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = t27.Name,
			TextSize = 14,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 8),
			Size = UDim2.new(1, 0, 0, 18),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 60,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text"
		}).Instance, t27.Name)
		arcane:Create("UICorner", {
			Parent = arcane:Create("Frame", {
				Parent = v383.Instance,
				Name = "\0",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 30),
				Size = UDim2.new(1, -24, 0, 2),
				ZIndex = 60,
				BorderSizePixel = 0,
				BackgroundColor3 = arcane.Theme.Accent
			}):AddToTheme({
				BackgroundColor3 = "Accent"
			}).Instance,
			CornerRadius = UDim.new(1, 0)
		})

		local tween2 = arcane:Create("Frame", {
			Parent = v383.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 38),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0
		})

		arcane:Create("UIListLayout", {
			Parent = tween2.Instance,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		isPopup.Items.Window = v383
		isPopup.Items.Content = tween2

		local function v385(p166)
			local screenScale = arcane:GetScreenScale()
			local Instance_ = v382.Instance

			return UDim2.fromOffset(Instance_.AbsolutePosition.X / screenScale, (Instance_.AbsolutePosition.Y + Instance_.AbsoluteSize.Y + Y + (p166 or 0)) / screenScale)
		end

		isPopup.SetOpen = function(p167, p168)
			if isPopup.Debounce then
				return
			end

			isPopup.IsOpen = p168
			isPopup.Debounce = true

			if p168 then
				v383.Instance.Parent = arcane.Holder.Instance
				v383.Instance.Position = v385(-8)
				v383.Instance.Visible = true
				arcane:RaisePopup(v383.Instance, true)
				v383:Tween({
					Position = v385(2)
				})

				for _, v in arcane.OpenFrames, nil, nil do
					if v ~= isPopup then
						v:SetOpen(false)
					end
				end

				arcane.OpenFrames[isPopup] = isPopup
				v383:FadeDescendants(true, function()
					isPopup.Debounce = false
				end)
			else
				arcane.OpenFrames[isPopup] = nil

				for _, v in arcane.OpenFrames, nil, nil do
					if v.Host == isPopup then
						v:SetOpen(false)
					end
				end

				local Position2 = v383.Instance.Position

				v383:Tween({
					Position = UDim2.new(Position2.X.Scale, Position2.X.Offset, Position2.Y.Scale, Position2.Y.Offset - 10)
				})
				v383:FadeDescendants(false, function()
					isPopup.Debounce = false
					v383.Instance.Parent = arcane.UnusedHolder.Instance
					arcane:RaisePopup(v383.Instance, false)
				end)
			end
		end
		v382:Connect("MouseButton1Down", function()
			isPopup:SetOpen(not isPopup.IsOpen)
		end)
		arcane:Connect(UserInputService.InputBegan, function(p169)
			if p169.UserInputType == Enum.UserInputType.MouseButton1 or p169.UserInputType == Enum.UserInputType.Touch then
				if isPopup.IsOpen and not v383:IsMouseOverFrame() then
					for _, v in arcane.OpenFrames, nil, nil do
						if v == isPopup then
							continue
						end

						return
					end

					isPopup:SetOpen(false)
				end
			end
		end)

		return setmetatable(isPopup, arcane)
	end
	items.Button:Connect("MouseButton1Down", function()
		t27:Set(not t27.Value)
	end)
	t27:Set(t27.Default)

	if t27.Flag then
		arcane.SetFlags[t27.Flag] = function(p170)
			t27:Set(p170)
		end
	end

	return setmetatable(t27, arcane)
end
arcane.Slider = function(p171, p172)
	local v395 = p172 or {}
	local t29 = {
		Name = v395.Name or v395.name or "Slider",
		Min = v395.Min or v395.min or 0,
		Max = v395.Max or v395.max or 100,
		Default = v395.Default or v395.default or 0
	}
	local Decimals = v395.Decimals or v395.decimals

	t29.Decimals = Decimals or 1
	t29.Suffix = v395.Suffix or v395.suffix or ""
	t29.Callback = v395.Callback or v395.callback or function()
	end
	t29.Tooltip = v395.Tooltip or v395.tooltip
	t29.Flag = v395.Flag or v395.flag
	t29.Value = 0
	t29.Sliding = false
	t29.Items = {}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p171.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 48),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t29.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 4),
		Size = UDim2.new(0.6, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t29.Name)
	v343(items.Name, t29.Tooltip)
	items.Value = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = "",
		TextSize = 14,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 4),
		Size = UDim2.new(0.4, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	items.Track = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Position = UDim2.new(0, 14, 0, 32),
		Size = UDim2.new(1, -28, 0, 5),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.SliderBack
	}):AddToTheme({
		BackgroundColor3 = "SliderBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Track.Instance,
		CornerRadius = UDim.new(0, 2)
	})
	items.Fill = arcane:Create("Frame", {
		Parent = items.Track.Instance,
		Name = "\0",
		BackgroundColor3 = arcane.Theme.Accent,
		Size = UDim2.new(0, 0, 1, 0),
		BorderSizePixel = 0
	}):AddToTheme({
		BackgroundColor3 = "Accent"
	})
	arcane:Create("UICorner", {
		Parent = items.Fill.Instance,
		CornerRadius = UDim.new(0, 2)
	})
	arcane:Create("UIGradient", {
		Parent = items.Fill.Instance,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
		})
	})
	items.Drag = arcane:Create("Frame", {
		Parent = items.Fill.Instance,
		Name = "\0",
		BackgroundColor3 = arcane.Theme.SliderKnob,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 7, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 8),
		BorderSizePixel = 0
	}):AddToTheme({
		BackgroundColor3 = "SliderKnob"
	})
	arcane:Create("UICorner", {
		Parent = items.Drag.Instance,
		CornerRadius = UDim.new(0, 3)
	})
	items.Input = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 26),
		Size = UDim2.new(1, -28, 0, 18),
		ZIndex = 3,
		BorderSizePixel = 0
	})
	v341(p171, items.Holder.Instance)
	t29.Items = items
	t29.Set = function(p173, p174)
		t29.Value = arcane:Round(math.clamp(p174, t29.Min, t29.Max), t29.Decimals)

		if t29.Flag then
			arcane.Flags[t29.Flag] = t29.Value
		end

		items.Fill:Tween({
			Size = UDim2.new((t29.Value - t29.Min) / (t29.Max - t29.Min), 0, 1, 0)
		}, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		items.Value.Instance.Text = tostring(t29.Value) .. t29.Suffix
		arcane:SafeCall(t29.Callback, t29.Value)
	end
	t29.Get = function()
		return t29.Value
	end

	local function v399(p175)
		return t29.Min + (t29.Max - t29.Min) * math.clamp((p175.Position.X - items.Track.Instance.AbsolutePosition.X) / items.Track.Instance.AbsoluteSize.X, 0, 1)
	end

	local connection

	items.Input:Connect("InputBegan", function(p176)
		if p176.UserInputType == Enum.UserInputType.MouseButton1 or p176.UserInputType == Enum.UserInputType.Touch then
			t29.Sliding = true
			items.Drag:Tween({
				Size = UDim2.new(0, 18, 0, 12)
			}, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
			t29:Set(v399(p176))

			if connection then
				return
			end

			connection = p176.Changed:Connect(function()
				if p176.UserInputState == Enum.UserInputState.End then
					t29.Sliding = false
					items.Drag:Tween({
						Size = UDim2.new(0, 14, 0, 8)
					}, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
					connection:Disconnect()
					connection = nil
				end
			end)
		end
	end)
	arcane:Connect(UserInputService.InputChanged, function(p177)
		if (p177.UserInputType == Enum.UserInputType.MouseMovement or p177.UserInputType == Enum.UserInputType.Touch) and t29.Sliding then
			t29:Set(v399(p177))
		end
	end)
	t29:Set(t29.Default)

	if t29.Flag then
		arcane.SetFlags[t29.Flag] = function(p178)
			t29:Set(p178)
		end
	end

	return setmetatable(t29, arcane)
end
arcane.RangeSlider = function(p179, p180)
	local v401 = p180 or {}
	local t30 = {
		Name = v401.Name or v401.name or "Slider",
		Min = v401.Min or v401.min or 0,
		Max = v401.Max or v401.max or 100,
		Default = v401.Default or v401.default,
		Decimals = v401.Decimals or v401.decimals or 1,
		Suffix = v401.Suffix or v401.suffix or ""
	}
	local Callback = v401.Callback or v401.callback

	t30.Callback = Callback or function()
	end
	t30.Tooltip = v401.Tooltip or v401.tooltip
	t30.Flag = v401.Flag or v401.flag
	t30.Value = {
		0,
		0
	}
	t30.SlidingHandle = nil
	t30.Items = {}
	t30.Default = t30.Default or {
		t30.Min,
		t30.Max
	}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p179.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 48),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t30.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 4),
		Size = UDim2.new(0.6, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t30.Name)
	v343(items.Name, t30.Tooltip)
	items.Value = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = "",
		TextSize = 14,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 4),
		Size = UDim2.new(0.4, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	items.Track = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Position = UDim2.new(0, 14, 0, 32),
		Size = UDim2.new(1, -28, 0, 5),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.SliderBack
	}):AddToTheme({
		BackgroundColor3 = "SliderBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Track.Instance,
		CornerRadius = UDim.new(0, 2)
	})
	items.Fill = arcane:Create("Frame", {
		Parent = items.Track.Instance,
		Name = "\0",
		BackgroundColor3 = arcane.Theme.Accent,
		Size = UDim2.new(0, 0, 1, 0),
		BorderSizePixel = 0
	}):AddToTheme({
		BackgroundColor3 = "Accent"
	})
	arcane:Create("UICorner", {
		Parent = items.Fill.Instance,
		CornerRadius = UDim.new(0, 2)
	})
	arcane:Create("UIGradient", {
		Parent = items.Fill.Instance,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
		})
	})
	items.MinDrag = arcane:Create("Frame", {
		Parent = items.Track.Instance,
		Name = "\0",
		BackgroundColor3 = arcane.Theme.SliderKnob,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 8),
		ZIndex = 3,
		BorderSizePixel = 0
	}):AddToTheme({
		BackgroundColor3 = "SliderKnob"
	})
	arcane:Create("UICorner", {
		Parent = items.MinDrag.Instance,
		CornerRadius = UDim.new(0, 3)
	})
	items.MaxDrag = arcane:Create("Frame", {
		Parent = items.Track.Instance,
		Name = "\0",
		BackgroundColor3 = arcane.Theme.SliderKnob,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 8),
		ZIndex = 3,
		BorderSizePixel = 0
	}):AddToTheme({
		BackgroundColor3 = "SliderKnob"
	})
	arcane:Create("UICorner", {
		Parent = items.MaxDrag.Instance,
		CornerRadius = UDim.new(0, 3)
	})
	items.Input = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 26),
		Size = UDim2.new(1, -28, 0, 18),
		ZIndex = 4,
		BorderSizePixel = 0
	})
	v341(p179, items.Holder.Instance)
	t30.Items = items
	t30.Set = function(p181, p182, p183)
		if type(p182) == "table" then
			p183 = p182[2]
			p182 = p182[1]
		end

		local v405 = arcane:Round(math.clamp(p182 or t30.Min, t30.Min, t30.Max), t30.Decimals)
		local v406 = arcane:Round(math.clamp(p183 or t30.Max, t30.Min, t30.Max), t30.Decimals)

		if v406 < v405 then
			local v407 = v405

			v405 = v406
			v406 = v407
		end

		t30.Value = {
			v405,
			v406
		}

		if t30.Flag then
			arcane.Flags[t30.Flag] = t30.Value
		end

		local v408 = (v405 - t30.Min) / (t30.Max - t30.Min)
		local v409 = (v406 - t30.Min) / (t30.Max - t30.Min)
		local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		items.Fill:Tween({
			Position = UDim2.new(v408, 0, 0, 0),
			Size = UDim2.new(v409 - v408, 0, 1, 0)
		}, tweenInfo)
		items.MinDrag:Tween({
			Position = UDim2.new(v408, 0, 0.5, 0)
		}, tweenInfo)
		items.MaxDrag:Tween({
			Position = UDim2.new(v409, 0, 0.5, 0)
		}, tweenInfo)
		items.Value.Instance.Text = tostring(v405) .. t30.Suffix .. ", " .. tostring(v406) .. t30.Suffix
		arcane:SafeCall(t30.Callback, t30.Value)
	end
	t30.Get = function()
		return t30.Value
	end

	local function v411(p184)
		local v412 = t30.Min + (t30.Max - t30.Min) * math.clamp((p184.Position.X - items.Track.Instance.AbsolutePosition.X) / items.Track.Instance.AbsoluteSize.X, 0, 1)

		if t30.SlidingHandle == "Min" then
			t30:Set(math.min(v412, t30.Value[2]), t30.Value[2])
		else
			t30:Set(t30.Value[1], math.max(v412, t30.Value[1]))
		end
	end

	local connection

	items.Input:Connect("InputBegan", function(p185)
		if p185.UserInputType == Enum.UserInputType.MouseButton1 or p185.UserInputType == Enum.UserInputType.Touch then
			local v414 = math.clamp((p185.Position.X - items.Track.Instance.AbsolutePosition.X) / items.Track.Instance.AbsoluteSize.X, 0, 1)
			local v415 = (t30.Value[2] - t30.Min) / (t30.Max - t30.Min)

			t30.SlidingHandle = math.abs(v414 - (t30.Value[1] - t30.Min) / (t30.Max - t30.Min)) <= math.abs(v414 - v415) and "Min" or "Max"
			;(t30.SlidingHandle == "Min" and items.MinDrag or items.MaxDrag):Tween({
				Size = UDim2.new(0, 18, 0, 12)
			}, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
			v411(p185)

			if connection then
				return
			end

			connection = p185.Changed:Connect(function()
				if p185.UserInputState == Enum.UserInputState.End then
					items.MinDrag:Tween({
						Size = UDim2.new(0, 14, 0, 8)
					}, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
					items.MaxDrag:Tween({
						Size = UDim2.new(0, 14, 0, 8)
					}, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
					t30.SlidingHandle = nil
					connection:Disconnect()
					connection = nil
				end
			end)
		end
	end)
	arcane:Connect(UserInputService.InputChanged, function(p186)
		if (p186.UserInputType == Enum.UserInputType.MouseMovement or p186.UserInputType == Enum.UserInputType.Touch) and t30.SlidingHandle then
			v411(p186)
		end
	end)
	t30:Set(t30.Default[1], t30.Default[2])

	if t30.Flag then
		arcane.SetFlags[t30.Flag] = function(p187)
			t30:Set(p187)
		end
	end

	return setmetatable(t30, arcane)
end
arcane.Dropdown = function(p188, p189)
	local v416 = p189 or {}
	local t31 = {
		Name = v416.Name or v416.name or "Dropdown",
		Options = v416.Items or v416.items or {},
		Default = v416.Default or v416.default,
		Multi = v416.Multi or v416.multi or false,
		Callback = v416.Callback or v416.callback or function()
		end,
		Tooltip = v416.Tooltip or v416.tooltip,
		Flag = v416.Flag or v416.flag,
		SearchBarEnabled = v416.SearchBarEnabled or v416.searchBarEnabled or false,
		Value = nil,
		Host = p188.IsPopup,
		IsOpen = false,
		Debounce = false
	}

	t31.OptionData = {}
	t31.Order = {}
	t31.Items = {}

	if t31.Multi then
		t31.Value = {}
	end

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p188.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 60),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t31.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 2),
		Size = UDim2.new(1, -24, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t31.Name)
	v343(items.Name, t31.Tooltip)
	items.Back = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		Position = UDim2.new(0, 12, 0, 28),
		Size = UDim2.new(1, -24, 0, 25),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Back.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	items.Selected = arcane:Create("TextLabel", {
		Parent = items.Back.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = "-",
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -34, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	items.Arrow = arcane:Create("ImageLabel", {
		Parent = items.Back.Instance,
		Name = "\0",
		ImageColor3 = arcane.Theme.DimText,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		BorderSizePixel = 0
	}):AddToTheme({
		ImageColor3 = "DimText"
	})
	v25(items.Arrow.Instance, "127296511745226")
	items.Opened = arcane:Create("Frame", {
		Parent = arcane.UnusedHolder.Instance,
		Name = "\0",
		Visible = false,
		ClipsDescendants = true,
		Size = UDim2.new(0, 218, 0, 0),
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Opened.Instance,
		CornerRadius = UDim.new(0, 4)
	})

	local v419 = t31.SearchBarEnabled and 30 or 0

	if t31.SearchBarEnabled then
		items.SearchBack = arcane:Create("Frame", {
			Parent = items.Opened.Instance,
			Name = "\0",
			Position = UDim2.new(0, 6, 0, 6),
			Size = UDim2.new(1, -12, 0, 22),
			ZIndex = 51,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.DropdownSelected
		}):AddToTheme({
			BackgroundColor3 = "DropdownSelected"
		})
		arcane:Create("UICorner", {
			Parent = items.SearchBack.Instance,
			CornerRadius = UDim.new(0, 4)
		})
		items.SearchInput = arcane:Create("TextBox", {
			Parent = items.SearchBack.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			PlaceholderColor3 = arcane.Theme.DimText,
			PlaceholderText = "Search...",
			Text = "",
			TextSize = 14,
			ClearTextOnFocus = false,
			CursorPosition = -1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
			Size = UDim2.new(1, -16, 1, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 51,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text",
			PlaceholderColor3 = "DimText"
		})
	end

	items.Scroll = arcane:Create("ScrollingFrame", {
		Parent = items.Opened.Instance,
		Name = "\0",
		ClipsDescendants = true,
		ScrollBarImageTransparency = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = arcane.Theme.Accent,
		Selectable = false,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, v419),
		Size = UDim2.new(1, 0, 1, -v419),
		ZIndex = 50,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}):AddToTheme({
		ScrollBarImageColor3 = "Accent"
	})
	arcane:Create("UIPadding", {
		Parent = items.Scroll.Instance,
		PaddingRight = UDim.new(0, 6)
	})
	arcane:Create("UIListLayout", {
		Parent = items.Scroll.Instance,
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	if t31.SearchBarEnabled then
		arcane:Connect(items.SearchInput.Instance:GetPropertyChangedSignal("Text"), function()
			local v420 = string.lower(items.SearchInput.Instance.Text)
			local n8 = 0

			for _, v in t31.Order, nil, nil do
				local visible = v420 == "" or string.find(string.lower(v.Name), v420, 1, true) ~= nil

				v.Row.Instance.Visible = visible

				if visible then
					n8 += 1
				end
			end

			t31:RefreshCorners()

			if t31.IsOpen then
				local Size = items.Opened.Instance.Size

				items.Opened:Tween({
					Size = UDim2.new(Size.X.Scale, Size.X.Offset, 0, 30 + math.min(n8 * 25, 125))
				}, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
			end
		end)
	end

	v341(p188, items.Holder.Instance)
	t31.Items = items
	items.Back:OnHover(function()
		items.Back:Tween({
			BackgroundColor3 = arcane.Theme.DropdownSelected
		})
	end, function()
		items.Back:Tween({
			BackgroundColor3 = arcane.Theme.DropdownBack
		})
	end)

	local function v426(p190)
		local Value

		if not t31.Multi then
			Value = t31.Value and arcane:DisplayName(t31.Value) or "-"
		elseif #t31.Value > 0 then
			local t32 = {}

			for _, v in t31.Value, nil, nil do
				table.insert(t32, arcane:DisplayName(v))
			end

			Value = table.concat(t32, ", ")
		else
			Value = "-"
		end

		if p190 then
			arcane:SwapText(items.Selected.Instance, Value, 0)
		else
			items.Selected.Instance.Text = Value
		end
	end

	table.insert(arcane.LanguageHooks, function()
		v426(true)
	end)
	t31.AddOption = function(p191, p192)
		local v431 = arcane:Create("Frame", {
			Parent = items.Scroll.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 25),
			ZIndex = 50,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.DropdownSelected
		}):AddToTheme({
			BackgroundColor3 = "DropdownSelected"
		})
		local tween2 = arcane:Create("TextButton", {
			Parent = v431.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 51,
			BorderSizePixel = 0
		})
		local v433 = arcane:Create("TextLabel", {
			Parent = v431.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.DimText,
			Text = p192,
			TextSize = 15,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 0),
			Size = UDim2.new(1, -10, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 51,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "DimText"
		})
		local v434 = arcane:RegisterText(v433.Instance, p192)
		local v435 = arcane:Create("ImageLabel", {
			Parent = v431.Instance,
			Name = "\0",
			ImageColor3 = arcane.Theme.Accent,
			ImageTransparency = 1,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 7),
			Size = UDim2.new(0, 12, 0, 12),
			ZIndex = 51,
			BorderSizePixel = 0
		}):AddToTheme({
			ImageColor3 = "Accent"
		})

		v25(v435.Instance, "10709790644")

		local t33

		t33 = {
			Name = p192,
			Selected = false,
			Row = v431,
			Text = v433,
			Check = v435,
			TextEntry = v434,
			Toggle = function(p193, p194)
				t33.Selected = p194

				if p194 then
					v433:ChangeItemTheme({
						TextColor3 = "Text"
					})
					v431:Tween({
						BackgroundTransparency = 0
					})
					v433:Tween({
						TextColor3 = arcane.Theme.Text,
						Position = UDim2.new(0, 30, 0, 0)
					})
					v435:Tween({
						ImageTransparency = 0
					})
				else
					v433:ChangeItemTheme({
						TextColor3 = "DimText"
					})
					v431:Tween({
						BackgroundTransparency = 1
					})
					v433:Tween({
						TextColor3 = arcane.Theme.DimText,
						Position = UDim2.new(0, 10, 0, 0)
					})
					v435:Tween({
						ImageTransparency = 1
					})
				end
			end
		}
		tween2:Connect("MouseButton1Down", function()
			if t31.Multi then
				local v437 = table.find(t31.Value, p192)

				if v437 then
					table.remove(t31.Value, v437)
					t33:Toggle(false)
				else
					table.insert(t31.Value, p192)
					t33:Toggle(true)
				end
			else
				t31.Value = p192

				for _, v in t31.OptionData, nil, nil do
					v:Toggle(v == t33)
				end
			end

			if t31.Flag then
				arcane.Flags[t31.Flag] = t31.Value
			end

			v426()
			arcane:SafeCall(t31.Callback, t31.Value)
		end)
		t33:Toggle(false)
		t31.OptionData[p192] = t33
		table.insert(t31.Order, t33)
		t31:RefreshCorners()

		return t33
	end
	t31.RefreshCorners = function()
		local t34 = {}

		for _, v in t31.Order, nil, nil do
			if v.Row.Instance.Visible then
				table.insert(t34, v)
			end
		end

		for _, v in t31.Order, nil, nil do
			local v445 = t34[1] == v or t34[#t34] == v

			if not v445 or v.Corner then
				if not v445 and v.Corner then
					v.Corner.Instance:Destroy()
					v.Corner = nil
				end
			else
				v.Corner = arcane:Create("UICorner", {
					Parent = v.Row.Instance,
					CornerRadius = UDim.new(0, 4)
				})
			end
		end
	end
	t31.Set = function(p195, p196)
		if t31.Multi then
			if type(p196) ~= "table" then
				return
			end

			t31.Value = p196

			for _, v in t31.OptionData, nil, nil do
				v:Toggle(table.find(p196, v.Name) ~= nil)
			end
		else
			if not t31.OptionData[p196] then
				return
			end

			t31.Value = p196

			for _, v in t31.OptionData, nil, nil do
				v:Toggle(v.Name == p196)
			end
		end

		if t31.Flag then
			arcane.Flags[t31.Flag] = t31.Value
		end

		v426()
		arcane:SafeCall(t31.Callback, t31.Value)
	end
	t31.Get = function()
		return t31.Value
	end
	t31.SetValue = function(p197, p198, p199)
		if p198 ~= nil and p199 ~= nil then
			if p198 ~= p199 then
				local v450 = t31.OptionData[p198]

				if not v450 then
					return
				end

				if t31.OptionData[p199] then
					return
				end

				v450.Name = p199
				v450.Text.Instance.Text = p199

				if v450.TextEntry then
					v450.TextEntry.English = p199
					v450.TextEntry.Transparency = v450.Text.Instance.TextTransparency

					if arcane.LanguageCodes[arcane.Language] then
						arcane:TranslateEntry(v450.TextEntry)
					end
				end

				t31.OptionData[p198] = nil
				t31.OptionData[p199] = v450

				local v451 = table.find(t31.Options, p198)

				if v451 then
					t31.Options[v451] = p199
				end

				local v452 = false

				if t31.Multi then
					local v453 = table.find(t31.Value, p198)

					if v453 then
						t31.Value[v453] = p199
						v452 = true
					end
				elseif t31.Value == p198 then
					t31.Value = p199
					v452 = true
				end

				if v452 and t31.Flag then
					arcane.Flags[t31.Flag] = t31.Value
				end

				v426()

				if v452 then
					arcane:SafeCall(t31.Callback, t31.Value)
				end

				return
			end
		end
	end
	t31.RemoveOption = function(p200, p201)
		local v454 = t31.OptionData[p201]

		if v454 then
			local v455 = table.find(t31.Order, v454)

			if v455 then
				table.remove(t31.Order, v455)
			end

			v454.Row.Instance:Destroy()
			t31.OptionData[p201] = nil
			t31:RefreshCorners()
		end
	end
	t31.Refresh = function(p202, p203)
		for k in t31.OptionData, nil, nil do
			t31:RemoveOption(k)
		end

		t31.Options = p203

		for _, v in p203, nil, nil do
			t31:AddOption(v)
		end

		v426()
	end

	local function v459()
		local screenScale = arcane:GetScreenScale()

		return UDim2.new(0, items.Back.Instance.AbsoluteSize.X / screenScale, 0, (t31.SearchBarEnabled and 30 or 0) + math.min(#t31.Options * 25, 125))
	end
	local function v461(p204)
		local screenScale = arcane:GetScreenScale()
		local v463 = items.Back.Instance.AbsolutePosition.X / screenScale
		local v464 = items.Back.Instance.AbsolutePosition.Y + items.Back.Instance.AbsoluteSize.Y + Y

		return UDim2.fromOffset(v463, (v464 + (p204 or 0)) / screenScale)
	end

	t31.SetOpen = function(p205, p206)
		if t31.Debounce then
			return
		end

		t31.IsOpen = p206
		t31.Debounce = true
		items.Arrow:Tween({
			Rotation = p206 and 180 or 0
		})

		if p206 then
			items.Opened.Instance.Parent = arcane.Holder.Instance
			items.Opened.Instance.Size = v459()
			items.Opened.Instance.Position = v461(-8)
			items.Opened.Instance.Visible = true
			arcane:RaisePopup(items.Opened.Instance, true, 70)
			items.Opened:Tween({
				Position = v461(2)
			})

			for _, v in arcane.OpenFrames, nil, nil do
				if not (v == t31 or v == t31.Host or v.IsPopup) then
					v:SetOpen(false)
				end
			end

			arcane.OpenFrames[t31] = t31
			items.Opened:FadeDescendants(true, function()
				t31.Debounce = false
			end)
		else
			arcane.OpenFrames[t31] = nil

			local Position2 = items.Opened.Instance.Position

			items.Opened:Tween({
				Position = UDim2.new(Position2.X.Scale, Position2.X.Offset, Position2.Y.Scale, Position2.Y.Offset - 10)
			})
			items.Opened:FadeDescendants(false, function()
				t31.Debounce = false
				items.Opened.Instance.Parent = arcane.UnusedHolder.Instance
				arcane:RaisePopup(items.Opened.Instance, false)
			end)
		end
	end
	items.Back:Connect("MouseButton1Down", function()
		t31:SetOpen(not t31.IsOpen)
	end)
	arcane:Connect(UserInputService.InputBegan, function(p207)
		if p207.UserInputType == Enum.UserInputType.MouseButton1 or p207.UserInputType == Enum.UserInputType.Touch then
			if t31.IsOpen then
				if not items.Opened:IsMouseOverFrame() then
					if not items.Back:IsMouseOverFrame() then
						t31:SetOpen(false)
					end
				end
			end
		end
	end)

	for _, v in t31.Options, nil, nil do
		t31:AddOption(v)
	end

	if t31.Default then
		t31:Set(t31.Default)
	end

	if t31.Flag then
		arcane.SetFlags[t31.Flag] = function(p208)
			t31:Set(p208)
		end
	end

	return setmetatable(t31, arcane)
end
arcane.Button = function(p209, p210)
	local v470 = p210 or {}
	local Name = v470.Name or v470.name
	local t35 = {
		Name = Name or "Button",
		Callback = v470.Callback or v470.callback or function()
		end,
		Tooltip = v470.Tooltip or v470.tooltip,
		Items = {}
	}
	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p209.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 46),
			BorderSizePixel = 0
		})
	}

	items.Button = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 9),
		Size = UDim2.new(1, -24, 0, 28),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Button.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	items.Text = arcane:Create("TextLabel", {
		Parent = items.Button.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = t35.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	arcane:RegisterText(items.Text.Instance, t35.Name)
	v343(items.Text, t35.Tooltip, true)
	v341(p209, items.Holder.Instance)
	t35.Items = items
	items.Button:OnHover(function()
		items.Button:Tween({
			BackgroundColor3 = arcane.Theme.DropdownSelected
		})
	end, function()
		items.Button:Tween({
			BackgroundColor3 = arcane.Theme.DropdownBack
		})
	end)
	t35.Press = function()
		items.Button:Tween({
			BackgroundColor3 = arcane.Theme.Accent
		})
		task.wait(0.12)
		items.Button:Tween({
			BackgroundColor3 = arcane.Theme.DropdownBack
		})
		arcane:SafeCall(t35.Callback)
	end
	t35.SetText = function(p211, p212)
		items.Text.Instance.Text = tostring(p212)
	end
	items.Button:Connect("MouseButton1Down", function()
		t35:Press()
	end)

	return setmetatable(t35, arcane)
end
arcane.Textbox = function(p213, p214)
	local v474 = p214 or {}
	local t36 = {
		Name = v474.Name or v474.name or "Textbox",
		Default = v474.Default or v474.default or ""
	}
	local Placeholder = v474.Placeholder or v474.placeholder

	t36.Placeholder = Placeholder or "..."
	t36.Callback = v474.Callback or v474.callback or function()
	end
	t36.Finished = v474.Finished or v474.finished or false
	t36.Tooltip = v474.Tooltip or v474.tooltip
	t36.Flag = v474.Flag or v474.flag
	t36.Value = ""
	t36.Items = {}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p213.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 60),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t36.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 2),
		Size = UDim2.new(1, -24, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t36.Name)
	v343(items.Name, t36.Tooltip)
	items.Back = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Position = UDim2.new(0, 12, 0, 28),
		Size = UDim2.new(1, -24, 0, 25),
		ClipsDescendants = true,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Back.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	items.Input = arcane:Create("TextBox", {
		Parent = items.Back.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		PlaceholderColor3 = arcane.Theme.DimText,
		PlaceholderText = t36.Placeholder,
		Text = "",
		TextSize = 14,
		ClearTextOnFocus = false,
		CursorPosition = -1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text",
		PlaceholderColor3 = "DimText"
	})

	if v12 then
		arcane:Create("TextButton", {
			Parent = items.Back.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 5,
			BorderSizePixel = 0
		}):Connect("MouseButton1Down", function()
			items.Input.Instance:CaptureFocus()
		end)
	end

	v341(p213, items.Holder.Instance)
	t36.Items = items
	t36.Set = function(p215, p216)
		t36.Value = tostring(p216)
		items.Input.Instance.Text = t36.Value

		if t36.Flag then
			arcane.Flags[t36.Flag] = t36.Value
		end

		arcane:SafeCall(t36.Callback, t36.Value)
	end
	t36.Get = function()
		return t36.Value
	end

	if t36.Finished then
		items.Input:Connect("FocusLost", function(p217)
			if p217 then
				t36:Set(items.Input.Instance.Text)
			end
		end)
	else
		arcane:Connect(items.Input.Instance:GetPropertyChangedSignal("Text"), function()
			t36:Set(items.Input.Instance.Text)
		end)
	end

	if t36.Default ~= "" then
		t36:Set(t36.Default)
	end

	if t36.Flag then
		arcane.SetFlags[t36.Flag] = function(p218)
			t36:Set(p218)
		end
	end

	return setmetatable(t36, arcane)
end
arcane.List = function(p219, p220)
	local v478 = p220 or {}
	local t37 = {
		Name = v478.Name or v478.name or "List"
	}
	local Empty = v478.Empty or v478.empty

	t37.Empty = Empty or "It's still empty here"
	t37.Callback = v478.Callback or v478.callback or function()
	end
	t37.Tooltip = v478.Tooltip or v478.tooltip
	t37.Value = nil
	t37.OptionData = {}
	t37.Order = {}
	t37.Items = {}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p219.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 178),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t37.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 2),
		Size = UDim2.new(1, -24, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t37.Name)
	v343(items.Name, t37.Tooltip)
	items.Box = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Position = UDim2.new(0, 12, 0, 26),
		Size = UDim2.new(1, -24, 0, 138),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Box.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	items.Empty = arcane:Create("TextLabel", {
		Parent = items.Box.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t37.Empty,
		TextSize = 14,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	items.Scroll = arcane:Create("ScrollingFrame", {
		Parent = items.Box.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0,
		ScrollBarImageColor3 = arcane.Theme.Accent,
		Selectable = false,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 2,
		BorderSizePixel = 0
	}):AddToTheme({
		ScrollBarImageColor3 = "Accent"
	})
	arcane:Create("UIPadding", {
		Parent = items.Scroll.Instance,
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4)
	})
	arcane:Create("UIListLayout", {
		Parent = items.Scroll.Instance,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	v341(p219, items.Holder.Instance)
	t37.Items = items

	local function v482()
		items.Empty.Instance.Visible = #t37.Order == 0
	end

	t37.AddOption = function(p221, p222, p223)
		-- p222 = option name (string)
		-- p223 = icon table { Image, Color, Size, Position } (optional)

		local v483 = arcane:Create("Frame", {
			Parent = items.Scroll.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 28),
			ZIndex = 2,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.DropdownSelected
		}):AddToTheme({
			BackgroundColor3 = "DropdownSelected"
		})
		local tween2 = arcane:Create("TextButton", {
			Parent = v483.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 3,
			BorderSizePixel = 0
		})
		local v485 = arcane:Create("Frame", {
			Parent = v483.Instance,
			Name = "\0",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 6, 0.5, 0),
			Size = UDim2.new(0, 3, 0, 14),
			BackgroundTransparency = 1,
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Accent
		}):AddToTheme({
			BackgroundColor3 = "Accent"
		})

		arcane:Create("UICorner", {
			Parent = v485.Instance,
			CornerRadius = UDim.new(1, 0)
		})

		local v486 = arcane:Create("TextLabel", {
			Parent = v483.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.DimText,
			Text = p222,
			TextSize = 14,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -20, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "DimText"
		})

		arcane:RegisterText(v486.Instance, p222)

		-- ================================================================
		-- ICON SUPPORT: inject ImageLabel and shift text accordingly
		-- ================================================================
		local iconImage = nil
		local iconOffsetX = 12          -- default text X (no icon)
		local iconOriginalColor = nil

		if p223 and p223.Image then
			local iconPos  = p223.Position or UDim2.new(0, 6, 0.5, 0)
			local iconSize = p223.Size     or UDim2.new(0, 14, 0, 14)

			iconImage = arcane:Create("ImageLabel", {
				Parent = v483.Instance,
				Name = "\0",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = iconPos,
				Size = iconSize,
				Image = p223.Image,
				ImageColor3 = p223.Color or arcane.Theme.DimText,
				ZIndex = 3
			})

			iconOriginalColor = p223.Color or arcane.Theme.DimText

			-- Shift text label to the right of the icon
			iconOffsetX = iconPos.X.Offset + iconSize.X.Offset + 8
			v486.Instance.Position = UDim2.new(0, iconOffsetX, 0, 0)
			v486.Instance.Size     = UDim2.new(1, -iconOffsetX - 8, 1, 0)
		end

		local t38

		t38 = {
			Name = p222,
			Selected = false,
			Row = v483,
			Text = v486,
			Line = v485,
			Icon = iconImage,   -- expose so callers can tweak it
			Toggle = function(p223_, p224)
				-- NOTE: keep original signature names intact; p223_ shadows outer param name
				t38.Selected = p224

				if p224 then
					v486:ChangeItemTheme({
						TextColor3 = "Text"
					})
					v483:Tween({
						BackgroundTransparency = 0
					})
					v486:Tween({
						TextColor3 = arcane.Theme.Text,
						Position = UDim2.new(0, iconImage and iconOffsetX or 24, 0, 0)
					})
					v485:Tween({
						BackgroundTransparency = 0,
						Position = UDim2.new(0, 12, 0.5, 0)
					})

					if iconImage then
						iconImage.ImageColor3 = arcane.Theme.Accent
						iconImage.Position   = UDim2.new(0, 6, 0.5, 0)
					end
				else
					v486:ChangeItemTheme({
						TextColor3 = "DimText"
					})
					v483:Tween({
						BackgroundTransparency = 1
					})
					v486:Tween({
						TextColor3 = arcane.Theme.DimText,
						Position = UDim2.new(0, iconImage and iconOffsetX or 12, 0, 0)
					})
					v485:Tween({
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 6, 0.5, 0)
					})

					if iconImage then
						iconImage.ImageColor3 = iconOriginalColor
						iconImage.Position   = UDim2.new(0, 6, 0.5, 0)
					end
				end
			end
		}
		tween2:Connect("MouseButton1Down", function()
			if t38.Selected then
				t37.Value = nil
				t38:Toggle(false)
			else
				t37.Value = p222

				for _, v in t37.Order, nil, nil do
					v:Toggle(v == t38)
				end
			end

			arcane:SafeCall(t37.Callback, t37.Value)
		end)
		t38:Toggle(false)
		t37.OptionData[p222] = t38
		table.insert(t37.Order, t38)
		v482()

		return t38
	end
	t37.RemoveOption = function(p225, p226)
		local v490 = t37.OptionData[p226]

		if v490 then
			local v491 = table.find(t37.Order, v490)

			if v491 then
				table.remove(t37.Order, v491)
			end

			v490.Row.Instance:Destroy()
			t37.OptionData[p226] = nil

			if t37.Value == p226 then
				t37.Value = nil
			end

			v482()
		end
	end
	t37.Refresh = function(p227, p228)
		for k in t37.OptionData, nil, nil do
			t37:RemoveOption(k)
		end

		for _, v in p228, nil, nil do
			-- support both plain strings and { name, iconTable } entries
			if type(v) == "table" then
				t37:AddOption(v[1], v[2])
			else
				t37:AddOption(v)
			end
		end

		v482()
	end
	t37.Set = function(p229, p230)
		if not t37.OptionData[p230] then
			return
		end

		t37.Value = p230

		for _, v in t37.Order, nil, nil do
			v:Toggle(v.Name == p230)
		end

		arcane:SafeCall(t37.Callback, t37.Value)
	end
	t37.Get = function()
		return t37.Value
	end

	local Items = v478.Items or v478.items or {}

	for _, v in Items, nil, nil do
		-- support both plain strings and { name, iconTable } entries
		if type(v) == "table" then
			t37:AddOption(v[1], v[2])
		else
			t37:AddOption(v)
		end
	end

	v482()

	return setmetatable(t37, arcane)
end
arcane.Selector = function(p231, p232)
	local v500 = p232 or {}
	local t39 = {
		Name = v500.Name or v500.name or "Selector"
	}
	local Items = v500.Items or v500.items

	t39.Options = Items or {}
	t39.Default = v500.Default or v500.default
	t39.Multi = v500.Multi or v500.multi or false
	t39.Callback = v500.Callback or v500.callback or function()
	end
	t39.Tooltip = v500.Tooltip or v500.tooltip
	t39.Flag = v500.Flag or v500.flag
	t39.Value = nil
	t39.OptionData = {}
	t39.Order = {}
	t39.Items = {}

	if t39.Multi then
		t39.Value = {}
	end

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p231.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0
		})
	}

	arcane:Create("UIPadding", {
		Parent = items.Holder.Instance,
		PaddingBottom = UDim.new(0, 8)
	})
	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t39.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 2),
		Size = UDim2.new(1, -24, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t39.Name)
	v343(items.Name, t39.Tooltip)
	items.Box = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Position = UDim2.new(0, 12, 0, 26),
		Size = UDim2.new(1, -24, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Box.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	arcane:Create("UIPadding", {
		Parent = items.Box.Instance,
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6)
	})
	arcane:Create("UIListLayout", {
		Parent = items.Box.Instance,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	v341(p231, items.Holder.Instance).Instance.Position = UDim2.new(0.5, 0, 1, 10)
	t39.Items = items

	local function v504()
		if t39.Flag then
			arcane.Flags[t39.Flag] = t39.Value
		end

		arcane:SafeCall(t39.Callback, t39.Value)
	end

	t39.AddOption = function(p233, p234)
		local v505 = arcane:Create("Frame", {
			Parent = items.Box.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.DropdownSelected
		}):AddToTheme({
			BackgroundColor3 = "DropdownSelected"
		})

		arcane:Create("UICorner", {
			Parent = v505.Instance,
			CornerRadius = UDim.new(0, 6)
		})

		local tween2 = arcane:Create("TextButton", {
			Parent = v505.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 3,
			BorderSizePixel = 0
		})
		local v507 = arcane:Create("ImageLabel", {
			Parent = v505.Instance,
			Name = "\0",
			ImageColor3 = arcane.Theme.Accent,
			ImageTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0.5, 0),
			Size = UDim2.new(0, 14, 0, 14),
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			ImageColor3 = "Accent"
		})

		v25(v507.Instance, "10709790644")

		local v508 = arcane:Create("TextLabel", {
			Parent = v505.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.DimText,
			Text = p234,
			TextSize = 14,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -20, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "DimText"
		})

		arcane:RegisterText(v508.Instance, p234)

		local t40

		t40 = {
			Name = p234,
			Selected = false,
			Row = v505,
			Text = v508,
			Check = v507,
			Toggle = function(p235, p236)
				t40.Selected = p236

				if p236 then
					v508:ChangeItemTheme({
						TextColor3 = "Text"
					})
					v505:Tween({
						BackgroundTransparency = 0
					})
					v508:Tween({
						TextColor3 = arcane.Theme.Text,
						Position = UDim2.new(0, 34, 0, 0)
					})
					v507:Tween({
						ImageTransparency = 0
					})
				else
					v508:ChangeItemTheme({
						TextColor3 = "DimText"
					})
					v505:Tween({
						BackgroundTransparency = 1
					})
					v508:Tween({
						TextColor3 = arcane.Theme.DimText,
						Position = UDim2.new(0, 12, 0, 0)
					})
					v507:Tween({
						ImageTransparency = 1
					})
				end
			end
		}
		tween2:Connect("MouseButton1Down", function()
			if t39.Multi then
				local v510 = table.find(t39.Value, p234)

				if v510 then
					table.remove(t39.Value, v510)
					t40:Toggle(false)
				else
					table.insert(t39.Value, p234)
					t40:Toggle(true)
				end
			else
				t39.Value = p234

				for _, v in t39.OptionData, nil, nil do
					v:Toggle(v == t40)
				end
			end

			v504()
		end)
		t40:Toggle(false)
		t39.OptionData[p234] = t40
		table.insert(t39.Order, t40)

		return t40
	end
	t39.Set = function(p237, p238)
		if t39.Multi then
			if type(p238) ~= "table" then
				return
			end

			t39.Value = p238

			for _, v in t39.OptionData, nil, nil do
				v:Toggle(table.find(p238, v.Name) ~= nil)
			end
		else
			if not t39.OptionData[p238] then
				return
			end

			t39.Value = p238

			for _, v in t39.OptionData, nil, nil do
				v:Toggle(v.Name == p238)
			end
		end

		v504()
	end
	t39.Get = function()
		return t39.Value
	end
	t39.RemoveOption = function(p239, p240)
		local v517 = t39.OptionData[p240]

		if v517 then
			local v518 = table.find(t39.Order, v517)

			if v518 then
				table.remove(t39.Order, v518)
			end

			v517.Row.Instance:Destroy()
			t39.OptionData[p240] = nil
		end
	end
	t39.Refresh = function(p241, p242)
		for k in t39.OptionData, nil, nil do
			t39:RemoveOption(k)
		end

		t39.Options = p242

		for _, v in p242, nil, nil do
			t39:AddOption(v)
		end
	end

	for _, v in t39.Options, nil, nil do
		t39:AddOption(v)
	end

	if t39.Default then
		t39:Set(t39.Default)
	end

	if t39.Flag then
		arcane.SetFlags[t39.Flag] = function(p243)
			t39:Set(p243)
		end
	end

	return setmetatable(t39, arcane)
end
arcane.Colorpicker = function(p244, p245)
	local v524 = p245 or {}
	local t41 = {
		Name = v524.Name or v524.name or "Colorpicker"
	}

	t41.Default = v524.Default or v524.default or Color3.fromRGB(254, 0, 67)
	t41.Callback = v524.Callback or v524.callback or function()
	end
	t41.Tooltip = v524.Tooltip or v524.tooltip
	t41.Flag = v524.Flag or v524.flag
	t41.Hue = 0
	t41.Saturation = 0
	t41.Value = 0
	t41.Transparency = v524.Transparency or v524.transparency or 0
	t41.Color = Color3.fromRGB(255, 255, 255)
	t41.Host = p244.IsPopup
	t41.IsOpen = false
	t41.Debounce = false
	t41.Items = {}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p244.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 35),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = t41.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	arcane:RegisterText(items.Name.Instance, t41.Name)
	v343(items.Name, t41.Tooltip)
	items.Swatch = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 34, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = t41.Default
	})
	arcane:Create("UICorner", {
		Parent = items.Swatch.Instance,
		CornerRadius = UDim.new(0, 5)
	})
	arcane:Create("UIStroke", {
		Parent = items.Swatch.Instance,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = arcane.Theme.Border,
		Transparency = 0.3
	}):AddToTheme({
		Color = "Border"
	})
	v341(p244, items.Holder.Instance)
	items.Window = arcane:Create("Frame", {
		Parent = arcane.UnusedHolder.Instance,
		Name = "\0",
		Visible = false,
		Size = UDim2.new(0, 210, 0, 210),
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Section
	}):AddToTheme({
		BackgroundColor3 = "Section"
	})
	arcane:Create("UICorner", {
		Parent = items.Window.Instance,
		CornerRadius = UDim.new(0, 8)
	})
	arcane:Create("UIStroke", {
		Parent = items.Window.Instance,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = arcane.Theme.Border,
		Transparency = 0.4
	}):AddToTheme({
		Color = "Border"
	})
	items.Window:MakeDraggable()
	items.Palette = arcane:Create("ImageButton", {
		Parent = items.Window.Instance,
		Name = "\0",
		AutoButtonColor = false,
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(1, -24, 0, 108),
		ZIndex = 51,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	})
	arcane:Create("UICorner", {
		Parent = items.Palette.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	items.Sat = arcane:Create("Frame", {
		Parent = items.Palette.Instance,
		Name = "\0",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 51,
		BorderSizePixel = 0
	})
	arcane:Create("UIGradient", {
		Parent = items.Sat.Instance,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
	})
	arcane:Create("UICorner", {
		Parent = items.Sat.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	items.Val = arcane:Create("Frame", {
		Parent = items.Palette.Instance,
		Name = "\0",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 51,
		BorderSizePixel = 0
	})
	arcane:Create("UIGradient", {
		Parent = items.Val.Instance,
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0)
		})
	})
	arcane:Create("UICorner", {
		Parent = items.Val.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	items.PaletteDrag = arcane:Create("Frame", {
		Parent = items.Palette.Instance,
		Name = "\0",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 10, 0, 10),
		ZIndex = 52,
		BorderSizePixel = 0
	})
	arcane:Create("UICorner", {
		Parent = items.PaletteDrag.Instance,
		CornerRadius = UDim.new(1, 0)
	})
	arcane:Create("UIStroke", {
		Parent = items.PaletteDrag.Instance,
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1.5
	})
	items.Hue = arcane:Create("ImageButton", {
		Parent = items.Window.Instance,
		Name = "\0",
		AutoButtonColor = false,
		Position = UDim2.new(0, 12, 0, 128),
		Size = UDim2.new(1, -54, 0, 14),
		ZIndex = 51,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	})
	arcane:Create("UICorner", {
		Parent = items.Hue.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	arcane:Create("UIGradient", {
		Parent = items.Hue.Instance,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		})
	})
	items.HueDrag = arcane:Create("Frame", {
		Parent = items.Hue.Instance,
		Name = "\0",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 5, 1, 8),
		ZIndex = 52,
		BorderSizePixel = 0
	})
	arcane:Create("UICorner", {
		Parent = items.HueDrag.Instance,
		CornerRadius = UDim.new(0, 3)
	})
	arcane:Create("UIStroke", {
		Parent = items.HueDrag.Instance,
		Color = arcane.Theme.Section,
		Thickness = 1.5
	}):AddToTheme({
		Color = "Section"
	})
	items.Alpha = arcane:Create("ImageButton", {
		Parent = items.Window.Instance,
		Name = "\0",
		AutoButtonColor = false,
		Position = UDim2.new(0, 12, 0, 148),
		Size = UDim2.new(1, -54, 0, 14),
		ZIndex = 51,
		BorderSizePixel = 0,
		BackgroundColor3 = t41.Default
	})
	arcane:Create("UICorner", {
		Parent = items.Alpha.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	arcane:Create("UIGradient", {
		Parent = items.Alpha.Instance,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
	})
	items.AlphaDrag = arcane:Create("Frame", {
		Parent = items.Alpha.Instance,
		Name = "\0",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 5, 1, 8),
		ZIndex = 52,
		BorderSizePixel = 0
	})
	arcane:Create("UICorner", {
		Parent = items.AlphaDrag.Instance,
		CornerRadius = UDim.new(0, 3)
	})
	arcane:Create("UIStroke", {
		Parent = items.AlphaDrag.Instance,
		Color = arcane.Theme.Section,
		Thickness = 1.5
	}):AddToTheme({
		Color = "Section"
	})
	items.Copy = arcane:Create("TextButton", {
		Parent = items.Window.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0, 148),
		Size = UDim2.new(0, 28, 0, 40),
		ZIndex = 51,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Copy.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	items.CopyIcon = arcane:Create("ImageLabel", {
		Parent = items.Copy.Instance,
		Name = "\0",
		ImageColor3 = arcane.Theme.DimText,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1,
		ZIndex = 51,
		BorderSizePixel = 0
	}):AddToTheme({
		ImageColor3 = "DimText"
	})
	v25(items.CopyIcon.Instance, "10709812159")
	items.Hex = arcane:Create("TextBox", {
		Parent = items.Window.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		PlaceholderColor3 = arcane.Theme.DimText,
		PlaceholderText = "#ffffff",
		Text = "#ffffff",
		TextSize = 14,
		ClearTextOnFocus = false,
		CursorPosition = -1,
		Position = UDim2.new(0, 12, 0, 172),
		Size = UDim2.new(1, -44, 0, 26),
		ZIndex = 51,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		TextColor3 = "Text",
		PlaceholderColor3 = "DimText",
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Hex.Instance,
		CornerRadius = UDim.new(0, 5)
	})
	arcane:Create("UIPadding", {
		Parent = items.Hex.Instance,
		PaddingLeft = UDim.new(0, 8)
	})
	items.Paste = arcane:Create("ImageButton", {
		Parent = items.Window.Instance,
		Name = "\0",
		AutoButtonColor = false,
		ImageColor3 = arcane.Theme.Accent,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -12, 0, 185),
		Size = UDim2.new(0, 18, 0, 18),
		ZIndex = 51,
		BorderSizePixel = 0
	}):AddToTheme({
		ImageColor3 = "Accent"
	})
	v25(items.Paste.Instance, "10709798443")
	t41.Items = items
	t41.Update = function()
		t41.Color = Color3.fromHSV(t41.Hue, t41.Saturation, t41.Value)
		items.Swatch:Tween({
			BackgroundColor3 = t41.Color,
			BackgroundTransparency = t41.Transparency
		})
		items.Palette:Tween({
			BackgroundColor3 = Color3.fromHSV(t41.Hue, 1, 1)
		})
		items.Alpha:Tween({
			BackgroundColor3 = t41.Color
		})

		if not items.Hex.Instance:IsFocused() then
			items.Hex.Instance.Text = "#" .. t41.Color:ToHex()
		end

		if t41.Flag then
			arcane.Flags[t41.Flag] = {
				__color = t41.Color:ToHex(),
				__alpha = t41.Transparency
			}
		end

		arcane:SafeCall(t41.Callback, t41.Color, t41.Transparency)
	end
	t41.Set = function(p246, p247, p248)
		if type(p247) == "table" then
			p247 = Color3.fromRGB(p247[1], p247[2], p247[3])
		end

		if type(p247) == "string" then
			p247 = Color3.fromHex(p247)
		end

		local v527, v528, v529 = p247:ToHSV()

		t41.Hue = v527
		t41.Saturation = v528
		t41.Value = v529
		t41.Transparency = p248 or t41.Transparency or 0
		items.PaletteDrag.Instance.Position = UDim2.new(t41.Saturation, 0, 1 - t41.Value, 0)
		items.HueDrag.Instance.Position = UDim2.new(t41.Hue, 0, 0.5, 0)
		items.AlphaDrag.Instance.Position = UDim2.new(t41.Transparency, 0, 0.5, 0)
		t41:Update()
	end
	t41.Get = function()
		return t41.Color, t41.Transparency
	end

	local u530 = false
	local u531 = false
	local u532 = false
	local connection
	local connection2
	local connection3

	local function v536(p249)
		if not u530 or not p249 then
			return
		end

		local saturation = math.clamp((p249.Position.X - items.Palette.Instance.AbsolutePosition.X) / items.Palette.Instance.AbsoluteSize.X, 0, 1)
		local v538 = math.clamp((p249.Position.Y - items.Palette.Instance.AbsolutePosition.Y) / items.Palette.Instance.AbsoluteSize.Y, 0, 1)

		t41.Saturation = saturation
		t41.Value = 1 - v538
		items.PaletteDrag:Tween({
			Position = UDim2.new(saturation, 0, v538, 0)
		}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		t41:Update()
	end
	local function v539(p250)
		if not u531 or not p250 then
			return
		end

		local hue = math.clamp((p250.Position.X - items.Hue.Instance.AbsolutePosition.X) / items.Hue.Instance.AbsoluteSize.X, 0, 1)

		t41.Hue = hue
		items.HueDrag:Tween({
			Position = UDim2.new(hue, 0, 0.5, 0)
		}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		t41:Update()
	end
	local function v541(p251)
		if not u532 or not p251 then
			return
		end

		local transparency = math.clamp((p251.Position.X - items.Alpha.Instance.AbsolutePosition.X) / items.Alpha.Instance.AbsoluteSize.X, 0, 1)

		t41.Transparency = transparency
		items.AlphaDrag:Tween({
			Position = UDim2.new(transparency, 0, 0.5, 0)
		}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		t41:Update()
	end

	items.Palette:Connect("InputBegan", function(p252)
		if p252.UserInputType == Enum.UserInputType.MouseButton1 or p252.UserInputType == Enum.UserInputType.Touch then
			u530 = true
			v536(p252)

			if connection then
				return
			end

			connection = p252.Changed:Connect(function()
				if p252.UserInputState == Enum.UserInputState.End then
					u530 = false
					connection:Disconnect()
					connection = nil
				end
			end)
		end
	end)
	items.Hue:Connect("InputBegan", function(p253)
		if p253.UserInputType == Enum.UserInputType.MouseButton1 or p253.UserInputType == Enum.UserInputType.Touch then
			u531 = true
			v539(p253)

			if connection2 then
				return
			end

			connection2 = p253.Changed:Connect(function()
				if p253.UserInputState == Enum.UserInputState.End then
					u531 = false
					connection2:Disconnect()
					connection2 = nil
				end
			end)
		end
	end)
	items.Alpha:Connect("InputBegan", function(p254)
		if p254.UserInputType == Enum.UserInputType.MouseButton1 or p254.UserInputType == Enum.UserInputType.Touch then
			u532 = true
			v541(p254)

			if connection3 then
				return
			end

			connection3 = p254.Changed:Connect(function()
				if p254.UserInputState == Enum.UserInputState.End then
					u532 = false
					connection3:Disconnect()
					connection3 = nil
				end
			end)
		end
	end)
	arcane:Connect(UserInputService.InputChanged, function(p255)
		if p255.UserInputType == Enum.UserInputType.MouseMovement or p255.UserInputType == Enum.UserInputType.Touch then
			if u530 then
				v536(p255)
			end

			if u531 then
				v539(p255)
			end

			if u532 then
				v541(p255)
			end
		end
	end)
	items.Hex:Connect("FocusLost", function()
		local v543 = string.gsub(items.Hex.Instance.Text, "#", "")
		local ok2, result2 = pcall(function()
			return Color3.fromHex(v543)
		end)

		if ok2 and result2 then
			t41:Set(result2, t41.Transparency)
		else
			items.Hex.Instance.Text = "#" .. t41.Color:ToHex()
		end
	end)
	items.Copy:Connect("MouseButton1Down", function()
		local v546 = "#" .. t41.Color:ToHex()
		local setclipboard_ = setclipboard or toclipboard

		if setclipboard_ then
			setclipboard_(v546)
		end

		arcane:Notification({
			Name = "Copied to clipboard",
			Description = v546,
			Duration = 2,
			Icon = "10709812159",
			Color = t41.Color
		})
	end)
	items.Paste:Connect("MouseButton1Down", function()
		local getclipboard_ = getclipboard or readclipboard

		if getclipboard_ then
			local v549 = getclipboard_()

			if type(v549) == "string" and v549 ~= "" then
				local ok2, result2 = pcall(function()
					local v552 = string.gsub(v549, "#", "")

					return Color3.fromHex(v552)
				end)

				if ok2 and result2 then
					t41:Set(result2, t41.Transparency)
				end
			end
		end
	end)

	local function v553(p256)
		local screenScale = arcane:GetScreenScale()

		return UDim2.fromOffset(items.Swatch.Instance.AbsolutePosition.X / screenScale, (items.Swatch.Instance.AbsolutePosition.Y + items.Swatch.Instance.AbsoluteSize.Y + Y + (p256 or 0)) / screenScale)
	end

	t41.SetOpen = function(p257, p258)
		if t41.Debounce then
			return
		end

		t41.IsOpen = p258
		t41.Debounce = true

		if p258 then
			items.Window.Instance.Parent = arcane.Holder.Instance
			items.Window.Instance.Position = v553(-8)
			items.Window.Instance.Visible = true
			arcane:RaisePopup(items.Window.Instance, true, 70)
			items.Window:Tween({
				Position = v553(2)
			})

			for _, v in arcane.OpenFrames, nil, nil do
				if v ~= t41 and v ~= t41.Host and not v.IsPopup then
					v:SetOpen(false)
				end
			end

			arcane.OpenFrames[t41] = t41
			items.Window:FadeDescendants(true, function()
				t41.Debounce = false
			end)
		else
			arcane.OpenFrames[t41] = nil

			local Position2 = items.Window.Instance.Position

			items.Window:Tween({
				Position = UDim2.new(Position2.X.Scale, Position2.X.Offset, Position2.Y.Scale, Position2.Y.Offset - 10)
			})
			items.Window:FadeDescendants(false, function()
				t41.Debounce = false
				items.Window.Instance.Parent = arcane.UnusedHolder.Instance
				arcane:RaisePopup(items.Window.Instance, false)
			end)
		end
	end
	items.Swatch:Connect("MouseButton1Down", function()
		t41:SetOpen(not t41.IsOpen)
	end)
	arcane:Connect(UserInputService.InputBegan, function(p259)
		if (p259.UserInputType == Enum.UserInputType.MouseButton1 or p259.UserInputType == Enum.UserInputType.Touch) and t41.IsOpen then
			if not items.Window:IsMouseOverFrame() then
				if not items.Swatch:IsMouseOverFrame() then
					t41:SetOpen(false)
				end
			end
		end
	end)
	t41:Set(t41.Default, t41.Transparency)

	if t41.Flag then
		arcane.SetFlags[t41.Flag] = function(p260, p261)
			t41:Set(p260, p261)
		end
	end

	return setmetatable(t41, arcane)
end
arcane.Config = function(p262)
	local v558 = arcane.Directory .. "/autoload.txt"
	local s1 = ""
	local s2 = ""
	local v561 = p262:Section({
		Name = "Config List",
		Side = 1
	})
	local v562 = p262:Section({
		Name = "Configs",
		Side = 2
	})
	local v563 = p262:Section({
		Name = "Themes",
		Side = 1
	})
	local v564 = v561:List({
		Name = "Config List",
		Empty = "It's still empty here",
		Items = arcane:GetConfigsList(),
		Callback = function(p263)
			s1 = p263 or ""
		end
	})

	v562:Textbox({
		Name = "Config Name",
		Placeholder = "my config",
		Callback = function(p264)
			s2 = p264
		end
	})
	v562:Button({
		Name = "Create",
		Callback = function()
			if s2 ~= "" then
				writefile(arcane.ConfigFolder .. "/" .. s2 .. ".json", arcane:GetConfig())
				arcane:GetConfigsList(v564)
				arcane:Notification({
					Name = "Config",
					Description = "Created " .. s2,
					Duration = 3,
					Icon = "check",
					Color = Color3.fromRGB(52, 255, 164)
				})
			end
		end
	})
	v562:Button({
		Name = "Save",
		Callback = function()
			if s1 ~= "" then
				writefile(arcane.ConfigFolder .. "/" .. s1 .. ".json", arcane:GetConfig())
				arcane:Notification({
					Name = "Config",
					Description = "Saved " .. s1,
					Duration = 3,
					Icon = "check",
					Color = Color3.fromRGB(52, 255, 164)
				})
			end
		end
	})
	v562:Button({
		Name = "Load",
		Callback = function()
			if s1 ~= "" and isfile(arcane.ConfigFolder .. "/" .. s1 .. ".json") then
				arcane:LoadConfig(readfile(arcane.ConfigFolder .. "/" .. s1 .. ".json"))
				arcane:Notification({
					Name = "Config",
					Description = "Loaded " .. s1,
					Duration = 3,
					Icon = "check",
					Color = Color3.fromRGB(52, 255, 164)
				})
			end
		end
	})
	v562:Button({
		Name = "Delete",
		Callback = function()
			if s1 ~= "" and isfile(arcane.ConfigFolder .. "/" .. s1 .. ".json") then
				delfile(arcane.ConfigFolder .. "/" .. s1 .. ".json")
				arcane:GetConfigsList(v564)
			end
		end
	})
	v562:Button({
		Name = "Refresh",
		Callback = function()
			arcane:GetConfigsList(v564)
		end
	})
	v562:Toggle({
		Name = "Auto Load",
		Default = isfile and isfile(v558) or false,
		Callback = function(p265)
			if not p265 or s1 == "" then
				if not p265 and isfile(v558) then
					delfile(v558)
				end
			else
				writefile(v558, s1)
			end
		end
	})
	arcane.Theming(v563)

	if isfile and isfile(v558) then
		local v565 = readfile(v558)

		if isfile(arcane.ConfigFolder .. "/" .. v565 .. ".json") then
			task.defer(function()
				arcane:LoadConfig(readfile(arcane.ConfigFolder .. "/" .. v565 .. ".json"))
				v564:Set(v565)
			end)
		end
	end

	return v564
end
arcane.Theming = function(p266)
	local t42 = {}

	p266:Dropdown({
		Name = "Preset Theme",
		Items = arcane.ThemeList,
		Default = arcane.CurrentTheme,
		Callback = function(p267)
			arcane:SetTheme(p267)

			for k, v in t42, nil, nil do
				v:Set(arcane.Theme[k])
			end
		end
	})

	for _, v in arcane.ThemeKeys, nil, nil do
		t42[v] = p266:Colorpicker({
			Name = v,
			Default = arcane.Theme[v],
			Flag = "Theme" .. v,
			Callback = function(p268)
				arcane:ChangeTheme(v, p268)
			end
		})
	end
end
getgenv().Arcane = arcane

return arcane