-- p100 code :^
local SolitudeButton = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SolitudeButtonLibrary"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local buttons = {}
local offsetStep = 0

local function safeCall(func, ...)
	if not func then return end
	local ok, err = pcall(func, ...)
	if not ok then warn("[SolitudeButton Error]: " .. tostring(err)) end
end

local function MakeDraggable(Frame)
	local Dragging = false
	local DragInput, DragStart, StartPos

	local function Update(Input)
		if not DragStart then return end
		local Delta = Input.Position - DragStart
		Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
	end

	Frame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = Input.Position
			StartPos = Frame.Position

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	Frame.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Dragging and Input == DragInput then
			Update(Input)
		end
	end)
end

function SolitudeButton:Toggle(config)
	config = config or {}

	local Name = config.Name or ("Toggle" .. tostring(#buttons + 1))
	local Text = config.Text or Name
	local Callback = config.Callback
	local SizeMultiply = config.SizeMultiply or 1
	local AccentColor = config.AccentColor or Color3.fromRGB(189, 172, 255)
	local IconOn = config.IconOn or "rbxassetid://10735024209"
	local IconOff = config.IconOff or "rbxassetid://10734923214"

	local Frame = Instance.new("Frame")
	local IconImage = Instance.new("ImageLabel")
	local ButtonText = Instance.new("TextButton")
	local TextSizeConstraint = Instance.new("UITextSizeConstraint")

	Frame.Name = Name
	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.new(0, 0, 0)
	Frame.BackgroundTransparency = 0.3
	Frame.Position = config.Position or UDim2.new(1, -150, 0, offsetStep * 45)
	Frame.Size = UDim2.new(0, 120 * SizeMultiply, 0, 40 * SizeMultiply)
	Frame.Active = true
	Frame.Visible = config.Visible ~= false
	offsetStep = offsetStep + 1

	local UiStroke = Instance.new("UIStroke", Frame)
	UiStroke.Color = AccentColor
	UiStroke.Thickness = 1.2
	UiStroke.Transparency = 0

	IconImage.Parent = Frame
	IconImage.Name = "Icon"
	IconImage.BackgroundTransparency = 1
	IconImage.Size = UDim2.new(0, 28 * SizeMultiply, 0, 28 * SizeMultiply)
	IconImage.AnchorPoint = Vector2.new(0, 0.5)
	IconImage.Position = UDim2.new(0.05, 0, 0.5, 0)
	IconImage.ImageColor3 = AccentColor

	ButtonText.Parent = Frame
	ButtonText.Name = "Label"
	ButtonText.BackgroundTransparency = 1
	ButtonText.Size = UDim2.new(0, 80 * SizeMultiply, 0, 28 * SizeMultiply)
	ButtonText.AnchorPoint = Vector2.new(0.5, 0.5)
	ButtonText.Position = UDim2.new(0.65, 0, 0.5, 0)
	ButtonText.Font = Enum.Font.Arimo
	ButtonText.Text = Text
	ButtonText.TextColor3 = AccentColor
	ButtonText.TextScaled = true
	ButtonText.TextSize = 25
	ButtonText.TextStrokeTransparency = 1

	TextSizeConstraint.Parent = ButtonText
	TextSizeConstraint.MaxTextSize = 25

	local UiCorner = Instance.new("UICorner", Frame)
	UiCorner.CornerRadius = UDim.new(0, 8)

	MakeDraggable(Frame)

	local ButtonState = config.DefaultState or false
	IconImage.Image = ButtonState and IconOn or IconOff

	local ButtonData = {
		Frame = Frame,
		Icon = IconImage,
		Label = ButtonText,
		Text = Text,
		State = ButtonState,
		Callback = Callback,
		IconOn = IconOn,
		IconOff = IconOff,
		Scale = SizeMultiply,
	}

	ButtonText.MouseButton1Down:Connect(function()
		ButtonData.State = not ButtonData.State
		IconImage.Image = ButtonData.State and ButtonData.IconOn or ButtonData.IconOff
		safeCall(ButtonData.Callback, ButtonData.State)
	end)

	table.insert(buttons, Frame)

	local FlagName = {}
	FlagName.Frame = Frame
	FlagName.Data = ButtonData

	function FlagName:VisibleSet(isVisible)
		if type(isVisible) ~= "boolean" then
			error("SolitudeButton Error: VisibleSet expects a boolean, got " .. type(isVisible))
		end
		Frame.Visible = isVisible
	end

	function FlagName:TitleSet(newText)
		ButtonData.Text = newText
		ButtonText.Text = newText
	end

	function FlagName:PositionSet(xScale, xOffset, yScale, yOffset)
		Frame.Position = UDim2.new(xScale, xOffset, yScale, yOffset)
	end

	function FlagName:ValueSet(newState)
		ButtonData.State = newState
		IconImage.Image = newState and ButtonData.IconOn or ButtonData.IconOff
	end

	function FlagName:GetValue()
		return ButtonData.State
	end

	function FlagName:Destroy()
		Frame:Destroy()
		for i, btn in ipairs(buttons) do
			if btn == Frame then
				table.remove(buttons, i)
				break
			end
		end
		if getgenv().SolitudeButton and getgenv().SolitudeButton[Name] then
			getgenv().SolitudeButton[Name] = nil
		end
	end

	if not getgenv().SolitudeButton then
		getgenv().SolitudeButton = {}
	end
	getgenv().SolitudeButton[Name] = FlagName

	return FlagName
end

getgenv().SolitudeButton = SolitudeButton
