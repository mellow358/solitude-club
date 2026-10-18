local Players         = game:GetService("Players")
local UserInputService= game:GetService("UserInputService")
local Workspace       = game:GetService("Workspace")

local Player   = Players.LocalPlayer
local placeId  = game.PlaceId

local Accent = Color3.fromRGB(158, 188, 242)
local Colors = {
    Background  = Color3.fromRGB(17, 17, 17),
    Outer       = Color3.fromRGB(58, 58, 58),
    Inner       = Color3.fromRGB(38, 38, 38),
    Field       = Color3.fromRGB(33, 33, 33),
    FieldBorder = Color3.fromRGB(12, 12, 12),
    Button      = Color3.fromRGB(27, 27, 27),
    ButtonBorder= Color3.fromRGB(42, 42, 42),
    ButtonHover = Color3.fromRGB(36, 36, 36),
    ButtonDown  = Color3.fromRGB(22, 22, 22),
    Title       = Color3.fromRGB(215, 215, 215),
    Text        = Color3.fromRGB(175, 175, 175),
}
local RegularFont = Enum.Font.Gotham
local BoldFont    = Enum.Font.GothamBold

local DAHOOD_BLOCKED     = {2788229376, 16033173781, 7213786345}
local PRISONLIFE_BLOCKED = {155615604, 135564683255158}
local MM2_ALLOWED        = {142823291}

local function GetGuiContainer()
    local ok, r = pcall(gethui);           if ok and r then return r end
    local ok2, r2 = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and r2 then return r2 end
    local p = game:GetService("Players").LocalPlayer
    if p then return p:FindFirstChild("PlayerGui") or p:WaitForChild("PlayerGui",10) or p.PlayerGui end
    return nil
end

local function Create(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local function AddStroke(parent, color, thick)
    return Create("UIStroke", {
        Color=color, Thickness=thick or 1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function CreateButton(parent, text, x, y, w, h, onClick)
    local b = Create("TextButton", {
        BackgroundColor3=Colors.Button, BorderSizePixel=0, AutoButtonColor=false,
        Position=UDim2.fromOffset(x,y), Size=UDim2.fromOffset(w,h),
        Text=text, Font=BoldFont, TextSize=11, TextColor3=Colors.Title,
    }, parent)
    AddStroke(b, Colors.ButtonBorder)
    b.MouseEnter:Connect(function()       b.BackgroundColor3=Colors.ButtonHover end)
    b.MouseLeave:Connect(function()       b.BackgroundColor3=Colors.Button end)
    b.MouseButton1Down:Connect(function() b.BackgroundColor3=Colors.ButtonDown end)
    b.MouseButton1Up:Connect(function()   b.BackgroundColor3=Colors.ButtonHover end)
    b.MouseButton1Click:Connect(onClick)
    return b
end

local function LaunchLoader()
    local UIS2          = game:GetService("UserInputService")
    local DesignWidth   = 347
    local DesignHeight  = 267
    local ScreenFill    = 0.92
    local GameRowHeight = 38

    local Games = {
        {
            Name = "da hood copies",
            Description = "uses reformation.gg old loader",
            Icon = "rbxassetid://89122179205544",
            Load = function()
                for _, id in ipairs(DAHOOD_BLOCKED) do
                    if placeId == id then
                        Player:Kick("[solitude.club] This script does not support the official Da Hood game.")
                        return
                    end
                end
                for _, id in ipairs(PRISONLIFE_BLOCKED) do
                    if placeId == id then Player:Kick("[solitude.club] Wrong loader folks.") return end
                end
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua", true))()
                loadstring(game:HttpGet("https://api.polsec.net/loader/55646c593e9f5876/7191705ceb5d4cc9"))()
            end,
        },
        {
            Name = "murder mystery 2",
            Description = "released 2026/10/18",
            Icon = "rbxassetid://97753192751504",
            Load = function()
                local allowed = false
                for _, id in ipairs(MM2_ALLOWED) do
                    if placeId == id then allowed = true break end
                end
                if not allowed then Player:Kick("[solitude.club] Wrong loader folks.") return end
                loadstring(game:HttpGet("https://api.polsec.net/loader/55646c593e9f5876/072e23aa769247f0"))()
            end,
        },
        {
            Name = "prison life",
            Description = "released 2026/10/14",
            Icon = "rbxassetid://109100556780679",
            Load = function()
                local allowed = false
                for _, id in ipairs(PRISONLIFE_BLOCKED) do
                    if placeId == id then allowed = true break end
                end
                if not allowed then Player:Kick("[solitude.club] Wrong loader folks.") return end
                loadstring(game:HttpGet("https://api.polsec.net/loader/55646c593e9f5876/3f5c0927aad40780"))()
            end,
        },
        {
            Name = "rivals",
            Description = "release estimated time: unknown",
            Icon = "rbxassetid://80523481507824",
            Load = function() Player:Kick("[solitude.club] Coming soon.") end,
        },
        {
            Name = "universal",
            Description = "released 2026/10/01",
            Icon = "rbxassetid://126591499864857",
            Load = function()
                for _, id in ipairs(PRISONLIFE_BLOCKED) do
                    if placeId == id then Player:Kick("[solitude.club] Wrong loader folks.") return end
                end
                for _, id in ipairs(DAHOOD_BLOCKED) do
                    if placeId == id then Player:Kick("[solitude.club] Wrong loader folks.") return end
                end
                loadstring(game:HttpGet("https://api.polsec.net/loader/55646c593e9f5876/69c53274fcb3f6b0"))()
            end,
        },
    }

    local Gui2 = Create("ScreenGui", {
        Name="LoaderUI", ResetOnSpawn=false, IgnoreGuiInset=true,
    }, GetGuiContainer())

    local Win2 = Create("Frame", {
        BackgroundColor3=Colors.Background, BorderSizePixel=0,
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.fromOffset(DesignWidth,DesignHeight),
    }, Gui2)
    AddStroke(Win2, Colors.Outer, 2)

    local WS2 = Create("UIScale", {}, Win2)
    local function US2()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        WS2.Scale = math.min(1, vp.X*ScreenFill/DesignWidth, vp.Y*ScreenFill/DesignHeight)
    end
    US2()
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(US2)
    end

    AddStroke(Create("Frame",{
        BackgroundTransparency=1, Position=UDim2.fromOffset(4,4),
        Size=UDim2.new(1,-8,1,-8),
    }, Win2), Colors.Inner)

    Create("Frame",{
        BackgroundColor3=Accent, BorderSizePixel=0,
        Position=UDim2.fromOffset(6,5), Size=UDim2.new(1,-12,0,2),
    }, Win2)

    local GBox = Create("Frame",{
        BackgroundColor3=Colors.Field, BorderSizePixel=0,
        Position=UDim2.fromOffset(17,23), Size=UDim2.fromOffset(183,83),
    }, Win2)
    AddStroke(GBox, Color3.fromRGB(44,44,44))

    local GList = Create("ScrollingFrame",{
        BackgroundTransparency=1, BorderSizePixel=0, Active=true,
        Size=UDim2.new(1,0,1,-1), CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ScrollBarThickness=2, ScrollBarImageColor3=Colors.Outer,
    }, GBox)
    Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,0)}, GList)

    local SelGame = Games[1]
    local RFns = {}
    for idx, G in ipairs(Games) do
        local Row = Create("TextButton",{
            BackgroundColor3=Colors.Field, BackgroundTransparency=1,
            BorderSizePixel=0, AutoButtonColor=false, Text="",
            LayoutOrder=idx, Size=UDim2.new(1,0,0,GameRowHeight),
        }, GList)
        Create("ImageLabel",{
            BackgroundTransparency=1, Image=G.Icon, ImageColor3=Color3.new(1,1,1),
            Position=UDim2.new(0,8,0.5,-10), Size=UDim2.fromOffset(21,21),
            ScaleType=Enum.ScaleType.Fit,
        }, Row)
        local TL = Create("TextLabel",{
            BackgroundTransparency=1, Text=G.Name, Font=RegularFont, TextSize=11,
            TextColor3=Colors.Text, TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=Enum.TextYAlignment.Center,
            Position=UDim2.fromOffset(36,4), Size=UDim2.fromOffset(140,15),
        }, Row)
        Create("TextLabel",{
            BackgroundTransparency=1, Text=G.Description, Font=RegularFont, TextSize=9,
            TextColor3=Colors.Text, TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=Enum.TextYAlignment.Top, TextWrapped=true,
            Position=UDim2.fromOffset(36,19), Size=UDim2.fromOffset(140,16),
        }, Row)
        local function RF()
            local s = SelGame == G
            Row.BackgroundTransparency = s and 0 or 1
            TL.Font = s and BoldFont or RegularFont
            TL.TextColor3 = s and Accent or Colors.Text
        end
        table.insert(RFns, RF)
        Row.MouseButton1Click:Connect(function()
            if SelGame == G then return end
            SelGame = G
            for _, f in ipairs(RFns) do f() end
        end)
        RF()
    end

    local OB = Create("Frame",{
        BackgroundTransparency=1, Position=UDim2.fromOffset(211,23),
        Size=UDim2.fromOffset(120,83),
    }, Win2)
    AddStroke(OB, Color3.fromRGB(44,44,44))

    local OT = Create("TextLabel",{
        BackgroundColor3=Colors.Background, BorderSizePixel=0,
        Position=UDim2.fromOffset(5,-6), Size=UDim2.fromOffset(0,12),
        AutomaticSize=Enum.AutomaticSize.X, Text="options",
        Font=BoldFont, TextSize=10, TextColor3=Colors.Title,
    }, OB)
    Create("UIPadding",{PaddingLeft=UDim.new(0,3), PaddingRight=UDim.new(0,3)}, OT)

    CreateButton(OB, "load", 15, 17, 91, 22, function()
        local g = SelGame
        Gui2:Destroy()
        g.Load()
    end)
    CreateButton(OB, "exit", 15, 44, 91, 22, function() Gui2:Destroy() end)

    local SB = Create("Frame",{
        BackgroundTransparency=1, Position=UDim2.fromOffset(17,117),
        Size=UDim2.fromOffset(313,132),
    }, Win2)
    AddStroke(SB, Color3.fromRGB(44,44,44))

    local ST = Create("TextLabel",{
        BackgroundColor3=Colors.Background, BorderSizePixel=0,
        Position=UDim2.fromOffset(5,-6), Size=UDim2.fromOffset(0,12),
        AutomaticSize=Enum.AutomaticSize.X, Text="status",
        Font=BoldFont, TextSize=10, TextColor3=Colors.Title,
    }, SB)
    Create("UIPadding",{PaddingLeft=UDim.new(0,3), PaddingRight=UDim.new(0,3)}, ST)

    local SF2 = Create("Frame",{
        BackgroundColor3=Colors.Field, BorderSizePixel=0,
        Position=UDim2.fromOffset(13,15), Size=UDim2.fromOffset(288,105),
    }, SB)
    AddStroke(SF2, Colors.FieldBorder)

    local LH2 = 19
    local SelStat2, SRFns = nil, {}
    local function MST(i, txt)
        local r = Create("TextButton",{
            BackgroundColor3=Colors.Field, BackgroundTransparency=1,
            BorderSizePixel=0, AutoButtonColor=false,
            Position=UDim2.fromOffset(1, 1+(i-1)*LH2),
            Size=UDim2.fromOffset(286,LH2),
            Text=txt, Font=RegularFont, TextSize=11,
            TextColor3=Colors.Text, TextXAlignment=Enum.TextXAlignment.Left,
        }, SF2)
        Create("UIPadding",{PaddingLeft=UDim.new(0,4)}, r)
        local function rf()
            local s = SelStat2 == r
            r.BackgroundTransparency = s and 0 or 1
            r.Font = s and BoldFont or RegularFont
            r.TextColor3 = s and Accent or Colors.Text
        end
        table.insert(SRFns, rf)
        r.MouseButton1Click:Connect(function()
            SelStat2 = (SelStat2 == r) and nil or r
            for _, f in ipairs(SRFns) do f() end
        end)
        return r
    end

    MST(1, "connected")
    MST(2, string.format("welcome back, %s (@%s)", Player.DisplayName, Player.Name))
    MST(3, "build date: sep 23 2026")
    local TL2 = MST(4, "time session: 00m 00s")
    Create("TextLabel",{
        BackgroundTransparency=1, Text="waiting for user",
        Font=BoldFont, TextSize=11, TextColor3=Accent,
        TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center,
        Position=UDim2.fromOffset(5, 1+(5-1)*LH2), Size=UDim2.fromOffset(278,LH2),
    }, SF2)

    local t0 = os.clock()
    task.spawn(function()
        while Gui2.Parent do
            local e = math.floor(os.clock()-t0)
            TL2.Text = string.format("time session: %02dm %02ds", e//60, e%60)
            task.wait(1)
        end
    end)

    local d2, ds2, sp2 = false, nil, nil
    Win2.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
           or i.UserInputType==Enum.UserInputType.Touch then
            d2 = true; ds2 = i.Position; sp2 = Win2.Position
        end
    end)
    UIS2.InputChanged:Connect(function(i)
        if d2 and (i.UserInputType==Enum.UserInputType.MouseMovement
           or i.UserInputType==Enum.UserInputType.Touch) then
            local dv = i.Position - ds2
            Win2.Position = UDim2.new(sp2.X.Scale, sp2.X.Offset+dv.X,
                                      sp2.Y.Scale, sp2.Y.Offset+dv.Y)
        end
    end)
    UIS2.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
           or i.UserInputType==Enum.UserInputType.Touch then d2 = false end
    end)
end

LaunchLoader()
