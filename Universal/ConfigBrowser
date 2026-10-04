local Loader = {}

function Loader:Create(enabled)
	local ConfigBrowser = Instance.new("ScreenGui")
	local Main = Instance.new("Frame")
	local Configs = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local Title = Instance.new("TextLabel")
	local Search = Instance.new("TextBox")


	ConfigBrowser.Name = "ConfigBrowser"
	ConfigBrowser.Parent = game.CoreGui
	ConfigBrowser.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ConfigBrowser.Enabled = enabled

	Main.Name = "Main"
	Main.Parent = ConfigBrowser
	Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.358593762, 0, 0.191933244, 0)
	Main.Size = UDim2.new(0, 361, 0, 443)
	Main.BackgroundTransparency = 0.3
	Main.Active = true
	Main.Draggable = true

	Configs.Name = "Configs"
	Configs.Parent = Main
	Configs.Active = true
	Configs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Configs.BackgroundTransparency = 1.000
	Configs.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Configs.BorderSizePixel = 0
	Configs.Position = UDim2.new(0, 0, 0.106629007, 0)
	Configs.Size = UDim2.new(0, 361, 0, 395)
	Configs.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	Configs.CanvasSize = UDim2.new(0, 0, 1, 0)
	Configs.ScrollBarThickness = 1
	Configs.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	Configs.AutomaticCanvasSize = Enum.AutomaticSize.XY

	UIListLayout.Parent = Configs
	UIListLayout.SortOrder = Enum.SortOrder.Name
	UIListLayout.Padding = UDim.new(0, 2)

	Title.Name = "Title"
	Title.Parent = Main
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Title.BorderSizePixel = 0
	Title.Size = UDim2.new(0, 361, 0, 27)
	Title.Font = Enum.Font.Code
	Title.Text = "Config Browser"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 14.000
	Title.TextStrokeTransparency = 0.000

	Search.Name = "Search"
	Search.Parent = Main
	Search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Search.BackgroundTransparency = 1.000
	Search.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Search.BorderSizePixel = 0
	Search.Position = UDim2.new(0, 0, 0.0614823103, 0)
	Search.Size = UDim2.new(0, 361, 0, 20)
	Search.ClearTextOnFocus = false
	Search.Font = Enum.Font.Code
	Search.PlaceholderText = "Search..."
	Search.Text = ""
	Search.TextColor3 = Color3.fromRGB(255, 255, 255)
	Search.TextSize = 14.000
	Search.TextStrokeTransparency = 0.000
	
	local Window = {}

	function Window:Button(info)
		local name = info.Name
		local creator = info.Creator
		local desc = info.Description
		local callback = info.Callback 
		local save_callback = info.SaveCallback

		local Config = Instance.new("Frame")
		local Config_Name = Instance.new("TextLabel")
		local LoadButton = Instance.new("TextButton")

		Config.Name = name
		Config.Parent = Configs
		Config.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Config.BackgroundTransparency = 1.000
		Config.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Config.BorderSizePixel = 0
		Config.Size = UDim2.new(0, 361, 0, 27)

		Config_Name.Name = "Config_Name"
		Config_Name.Parent = Config
		Config_Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Config_Name.BackgroundTransparency = 1.000
		Config_Name.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Config_Name.BorderSizePixel = 0
		Config_Name.Position = UDim2.new(0.0246007182, 0, 0, 0)
		Config_Name.Size = UDim2.new(0, 300, 0, 27)
		Config_Name.Font = Enum.Font.Code
		Config_Name.Text = name
		Config_Name.TextColor3 = Color3.fromRGB(255, 255, 255)
		Config_Name.TextSize = 14.000
		Config_Name.TextStrokeTransparency = 0.000
		Config_Name.TextXAlignment = Enum.TextXAlignment.Left

		LoadButton.Name = "LoadButton"
		LoadButton.Parent = Config
		LoadButton.BackgroundColor3 = Color3.fromRGB(0, 85, 127)
		LoadButton.BackgroundTransparency = 0.700
		LoadButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LoadButton.BorderSizePixel = 0
		LoadButton.Position = UDim2.new(0.85781312, 0, 0, 0)
		LoadButton.Size = UDim2.new(0, 43, 0, 27)
		LoadButton.Font = Enum.Font.Code
		LoadButton.Text = "Load"
		LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		LoadButton.TextSize = 14.000
		LoadButton.TextStrokeTransparency = 0.000

		LoadButton.MouseButton1Click:Connect(function()
			local Confirm = Instance.new("Frame")
			local ConfigTitle = Instance.new("TextLabel")
			local ConfigDesc = Instance.new("TextLabel")
			local ConfigCreator = Instance.new("TextLabel")
			local LoadButton2 = Instance.new("TextButton")
			local CancelButton = Instance.new("TextButton")
			local SaveConfig = Instance.new("ImageButton")

			Confirm.Name = "Confirm"
			Confirm.Parent = Main
			Confirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			Confirm.BackgroundTransparency = 0.1
			Confirm.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Confirm.BorderSizePixel = 0
			Confirm.Position = UDim2.new(0.132964164, 0, 0.320541769, 0)
			Confirm.Size = UDim2.new(0, 264, 0, 157)

			ConfigTitle.Name = "ConfigTitle"
			ConfigTitle.Parent = Confirm
			ConfigTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ConfigTitle.BackgroundTransparency = 1.000
			ConfigTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ConfigTitle.BorderSizePixel = 0
			ConfigTitle.Position = UDim2.new(0, 0, 5.83138444e-07, 0)
			ConfigTitle.Size = UDim2.new(0, 264, 0, 37)
			ConfigTitle.Font = Enum.Font.Code
			ConfigTitle.Text = name
			ConfigTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
			ConfigTitle.TextSize = 18.000
			ConfigTitle.TextStrokeTransparency = 0.000

			ConfigDesc.Name = "ConfigDesc"
			ConfigDesc.Parent = Confirm
			ConfigDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ConfigDesc.BackgroundTransparency = 1.000
			ConfigDesc.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ConfigDesc.BorderSizePixel = 0
			ConfigDesc.Position = UDim2.new(0.0234157685, 0, 0.235669374, 0)
			ConfigDesc.Size = UDim2.new(0, 251, 0, 70)
			ConfigDesc.Font = Enum.Font.Code
			ConfigDesc.Text = desc
			ConfigDesc.TextColor3 = Color3.fromRGB(255, 255, 255)
			ConfigDesc.TextSize = 14.000
			ConfigDesc.TextStrokeTransparency = 0.000
			ConfigDesc.TextWrapped = true
			ConfigDesc.TextXAlignment = Enum.TextXAlignment.Left
			ConfigDesc.TextYAlignment = Enum.TextYAlignment.Top

			ConfigCreator.Name = "ConfigCreator"
			ConfigCreator.Parent = Confirm
			ConfigCreator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ConfigCreator.BackgroundTransparency = 1.000
			ConfigCreator.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ConfigCreator.BorderSizePixel = 0
			ConfigCreator.Position = UDim2.new(0.0234157685, 0, 0.681529224, 0)
			ConfigCreator.Size = UDim2.new(0, 251, 0, 21)
			ConfigCreator.Font = Enum.Font.Code
			ConfigCreator.Text = "Creator: "..creator
			ConfigCreator.TextColor3 = Color3.fromRGB(255, 255, 255)
			ConfigCreator.TextSize = 14.000
			ConfigCreator.TextStrokeTransparency = 0.000
			ConfigCreator.TextXAlignment = Enum.TextXAlignment.Left

			LoadButton2.Name = "LoadButton"
			LoadButton2.Parent = Confirm
			LoadButton2.BackgroundColor3 = Color3.fromRGB(0, 85, 127)
			LoadButton2.BackgroundTransparency = 0.700
			LoadButton2.BorderColor3 = Color3.fromRGB(0, 0, 0)
			LoadButton2.BorderSizePixel = 0
			LoadButton2.Position = UDim2.new(0.0206918418, 0, 0.815286636, 0)
			LoadButton2.Size = UDim2.new(0, 123, 0, 20)
			LoadButton2.Font = Enum.Font.Code
			LoadButton2.Text = "Load"
			LoadButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
			LoadButton2.TextSize = 14.000
			LoadButton2.TextStrokeTransparency = 0.000

			CancelButton.Name = "CancelButton"
			CancelButton.Parent = Confirm
			CancelButton.BackgroundColor3 = Color3.fromRGB(170, 39, 34)
			CancelButton.BackgroundTransparency = 0.700
			CancelButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
			CancelButton.BorderSizePixel = 0
			CancelButton.Position = UDim2.new(0.505540311, 0, 0.815286636, 0)
			CancelButton.Size = UDim2.new(0, 123, 0, 20)
			CancelButton.Font = Enum.Font.Code
			CancelButton.Text = "Cancel"
			CancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			CancelButton.TextSize = 14.000
			CancelButton.TextStrokeTransparency = 0.000

			SaveConfig.Name = "SaveConfig"
			SaveConfig.Parent = Confirm
			SaveConfig.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SaveConfig.BackgroundTransparency = 1.000
			SaveConfig.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SaveConfig.BorderSizePixel = 0
			SaveConfig.Position = UDim2.new(0.918269515, 0, 0.700600982, 0)
			SaveConfig.Size = UDim2.new(0, 14, 0, 14)
			SaveConfig.Image = "rbxassetid://10723344088"

			SaveConfig.MouseButton1Click:Connect(function()
				task.spawn(save_callback)
			end)

			CancelButton.MouseButton1Click:Connect(function()
				Confirm:Destroy()
			end)

			LoadButton2.MouseButton1Click:Connect(function()
				task.spawn(callback)
				Confirm:Destroy()
			end)
		end)
	end

	function Window:ToggleBrowser(Value)
		ConfigBrowser.Enabled = Value
	end

	Search.Changed:Connect(function()
		local search = string.lower(Search.Text)
		for i, v in	 pairs(Configs:GetChildren()) do
			if v:IsA("Frame") then
				if search ~= "" then
					local item = string.lower(v.Name)
					if string.find(item, search) then
						v.Visible = true
					else
						v.Visible = false
					end
				else
					v.Visible = true
				end
			end
		end
	end)

	return Window
end

return Loader
