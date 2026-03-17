--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// UI
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "NameHub"
ScreenGui.ResetOnSpawn = false

-- MAIN FRAME
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 300)
Main.Position = UDim2.new(0.5, -250, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true
Main.Draggable = true

-- 🔹 ปุ่มเปิด UI (P)
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0,50,0,50)
OpenButton.Position = UDim2.new(0,20,0.5,-25)
OpenButton.Text = "P"
OpenButton.Visible = false
OpenButton.BackgroundColor3 = Color3.fromRGB(50,150,250)
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.Active = true
OpenButton.Draggable = true

-- TOP BAR
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1,0,0,30)
TopBar.BackgroundColor3 = Color3.fromRGB(35,35,35)

-- TITLE
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0,150,1,0)
Title.Text = "Name Hub"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- INFO (PING + FPS)
local Info = Instance.new("TextLabel", TopBar)
Info.Size = UDim2.new(0,250,1,0)
Info.Position = UDim2.new(0,150,0,0)
Info.TextColor3 = Color3.new(1,1,1)
Info.BackgroundTransparency = 1
Info.Text = "Ping: ... | FPS: ..."

-- CLOSE BUTTON (แก้แล้ว)
local Close = Instance.new("TextButton", TopBar)
Close.Size = UDim2.new(0,30,1,0)
Close.Position = UDim2.new(1,-30,0,0)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(150,50,50)
Close.TextColor3 = Color3.new(1,1,1)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    OpenButton.Visible = true
end)

-- 🔹 เปิด UI กลับ
OpenButton.MouseButton1Click:Connect(function()
    Main.Visible = true
    OpenButton.Visible = false
end)

-- LEFT TAB PANEL
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(0,120,1,-30)
Tabs.Position = UDim2.new(0,0,0,30)
Tabs.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- CONTENT PANEL
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,-120,1,-30)
Content.Position = UDim2.new(0,120,0,30)
Content.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- LAYOUT
local TabLayout = Instance.new("UIListLayout", Tabs)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding = UDim.new(0,5)

-- TAB FUNCTION
local Pages = {}

local function CreateTab(name)
    local Button = Instance.new("TextButton", Tabs)
    Button.Size = UDim2.new(1,0,0,40)
    Button.Text = name
    Button.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Button.TextColor3 = Color3.new(1,1,1)

    local Page = Instance.new("Frame", Content)
    Page.Size = UDim2.new(1,0,1,0)
    Page.Visible = false
    Page.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0,5)

    Pages[name] = Page

    Button.MouseButton1Click:Connect(function()
        for _,v in pairs(Pages) do
            v.Visible = false
        end
        Page.Visible = true
    end)

    return Page
end

-- SECTION
local function CreateSection(parent, name)
    local Section = Instance.new("TextLabel", parent)
    Section.Size = UDim2.new(1,0,0,30)
    Section.Text = " "..name
    Section.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Section.TextColor3 = Color3.new(1,1,1)
    Section.TextXAlignment = Enum.TextXAlignment.Left
    return Section
end

-- BUTTON
local function CreateButton(parent, name, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1,0,0,30)
    Btn.Text = name
    Btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    Btn.TextColor3 = Color3.new(1,1,1)

    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

-- TOGGLE
local function CreateToggle(parent, name, callback)
    local state = false

    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1,0,0,30)
    Btn.Text = name.." : OFF"
    Btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    Btn.TextColor3 = Color3.new(1,1,1)

    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name.." : "..(state and "ON" or "OFF")
        pcall(callback, state)
    end)
end

-- DROPDOWN
local function CreateDropdown(parent, name, list, callback)
    local Drop = Instance.new("TextButton", parent)
    Drop.Size = UDim2.new(1,0,0,30)
    Drop.Text = name
    Drop.BackgroundColor3 = Color3.fromRGB(70,70,70)
    Drop.TextColor3 = Color3.new(1,1,1)

    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1,0,0,#list*25)
    Frame.Visible = false
    Frame.BackgroundColor3 = Color3.fromRGB(50,50,50)

    local Layout = Instance.new("UIListLayout", Frame)

    for _,v in pairs(list) do
        local Option = Instance.new("TextButton", Frame)
        Option.Size = UDim2.new(1,0,0,25)
        Option.Text = v
        Option.BackgroundColor3 = Color3.fromRGB(80,80,80)

        Option.MouseButton1Click:Connect(function()
            Drop.Text = name..": "..v
            Frame.Visible = false
            pcall(callback, v)
        end)
    end

    Drop.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
    end)
end

-- CREATE TABS
local Tab1 = CreateTab("Tab 1")
local Tab2 = CreateTab("Tab 2")

-- DEFAULT SHOW
Tab1.Visible = true

-- TAB 1 CONTENT
CreateSection(Tab1, "Main")
CreateButton(Tab1, "Button Test", function()
    print("Clicked!")
end)

CreateToggle(Tab1, "Auto Farm", function(v)
    print("Toggle:", v)
end)

CreateDropdown(Tab1, "Select Stats", {"Strength","Speed","Defense"}, function(v)
    print("Selected:", v)
end)

-- TAB 2 CONTENT
CreateSection(Tab2, "Teleport")
CreateButton(Tab2, "Go Spawn", function()
    print("Teleport Spawn")
end)

-- FPS + PING LOOP
RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())

    Info.Text = "Ping: "..ping.." | FPS: "..fps
end)
