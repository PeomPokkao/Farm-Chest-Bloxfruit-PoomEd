-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer

-- CONFIG
local ConfigFile = "PoomHub_Config.json"
local Config = {}

pcall(function()
    if readfile and isfile and isfile(ConfigFile) then
        Config = HttpService:JSONDecode(readfile(ConfigFile))
    end
end)

local function Save()
    if writefile then
        writefile(ConfigFile, HttpService:JSONEncode(Config))
    end
end

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- MAIN
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0.4,0,0.5,0)
Main.Position = UDim2.new(0.3,0,0.25,0)
Main.BackgroundColor3 = Color3.fromRGB(15,15,15)

-- GRADIENT
local UIGradient = Instance.new("UIGradient", Main)
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(140,0,255))
}

-- GLOW
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(0,255,255)
Stroke.Thickness = 2

-- ANIMATION
Main.Size = UDim2.new(0,0,0,0)
TweenService:Create(Main,TweenInfo.new(0.4,Enum.EasingStyle.Back),{
    Size = UDim2.new(0.4,0,0.5,0)
}):Play()

-- HEADER
local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1,0,0,30)
Top.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(0.4,0,1,0)
Title.Text = "Poom Hub"
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)

-- FPS / PING LABEL
local StatsLabel = Instance.new("TextLabel", Top)
StatsLabel.Size = UDim2.new(0.4,0,1,0)
StatsLabel.Position = UDim2.new(0.4,0,0,0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextScaled = true
StatsLabel.TextColor3 = Color3.fromRGB(0,255,255)

-- CLOSE
local Close = Instance.new("TextButton", Top)
Close.Size = UDim2.new(0,30,1,0)
Close.Position = UDim2.new(1,-30,0,0)
Close.Text = "X"

-- OPEN BUTTON
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0.08,0,0.08,0)
OpenButton.Position = UDim2.new(0.1,0,0.3,0)
OpenButton.Text = "P"
OpenButton.Visible = false

-- SAVE POS
if Config["P_Pos"] then
    OpenButton.Position = UDim2.new(
        Config["P_Pos"].X.Scale,
        Config["P_Pos"].X.Offset,
        Config["P_Pos"].Y.Scale,
        Config["P_Pos"].Y.Offset
    )
end

OpenButton:GetPropertyChangedSignal("Position"):Connect(function()
    Config["P_Pos"] = {
        X = {Scale = OpenButton.Position.X.Scale, Offset = OpenButton.Position.X.Offset},
        Y = {Scale = OpenButton.Position.Y.Scale, Offset = OpenButton.Position.Y.Offset}
    }
    Save()
end)

-- OPEN/CLOSE
Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    Main.Visible = true
    OpenButton.Visible = false
end)

-- FPS + PING SYSTEM
local frames = 0
local last = tick()

RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - last >= 1 then
        local fps = frames
        frames = 0
        last = tick()

        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())

        StatsLabel.Text = "Ping: "..ping.."ms | FPS: "..fps
    end
end)

-- TABS
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(0.25,0,1,-30)
Tabs.Position = UDim2.new(0,0,0,30)
Tabs.BackgroundTransparency = 1

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(0.75,0,1,-30)
Content.Position = UDim2.new(0.25,0,0,30)
Content.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Tabs)
local Pages = {}

local function CreateTab(name)
    local Button = Instance.new("TextButton", Tabs)
    Button.Size = UDim2.new(1,0,0,40)
    Button.Text = name
    Button.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local Page = Instance.new("Frame", Content)
    Page.Size = UDim2.new(1,0,1,0)
    Page.Visible = false
    Page.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", Page)
    Pages[name] = Page

    Button.MouseButton1Click:Connect(function()
        for _,v in pairs(Pages) do v.Visible = false end
        Page.Visible = true

        Config["LastTab"] = name
        Save()
    end)

    return Page
end

-- TOGGLE
local function CreateToggle(parent,name,callback)
    local state = Config[name] or false

    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1,0,0,40)

    local function Update()
        Btn.Text = name.." : "..(state and "ON" or "OFF")
    end
    Update()

    task.spawn(function()
        callback(state)
    end)

    Btn.MouseButton1Click:Connect(function()
        state = not state
        Update()

        Config[name] = state
        Save()

        callback(state)
    end)
end

-- DROPDOWN
local function CreateDropdown(parent,name,list,callback)
    local selected = Config[name] or list[1]

    local Drop = Instance.new("TextButton", parent)
    Drop.Size = UDim2.new(1,0,0,40)
    Drop.Text = name..": "..selected

    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1,0,0,#list*30)
    Frame.Visible = false

    local Layout = Instance.new("UIListLayout", Frame)

    task.spawn(function()
        callback(selected)
    end)

    for _,v in pairs(list) do
        local Opt = Instance.new("TextButton", Frame)
        Opt.Size = UDim2.new(1,0,0,30)
        Opt.Text = v

        Opt.MouseButton1Click:Connect(function()
            selected = v
            Drop.Text = name..": "..v
            Frame.Visible = false

            Config[name] = v
            Save()

            callback(v)
        end)
    end

    Drop.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
    end)
end

-- CREATE
local Tab1 = CreateTab("Main")
local Tab2 = CreateTab("Other")

CreateToggle(Tab1,"Auto Farm",function(v)
    print("Auto Farm:",v)
end)

CreateDropdown(Tab1,"Select Weapon",{"Sword","Gun","Magic"},function(v)
    print("Selected:",v)
end)

-- LOAD TAB
task.delay(0.2,function()
    if Config["LastTab"] and Pages[Config["LastTab"]] then
        for _,v in pairs(Pages) do v.Visible = false end
        Pages[Config["LastTab"]].Visible = true
    end
end)
