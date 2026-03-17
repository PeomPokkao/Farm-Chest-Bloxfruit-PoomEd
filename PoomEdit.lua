-- SERVICES
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- CONFIG
local name = "PoomHub"
local ownerid = "MUynMTtUSV"

-- CHECK KEY
local function CheckKey(key)
    local url = "https://keyauth.win/api/1.2/?type=license&key="..key.."&name="..name.."&ownerid="..ownerid
    
    local response = game:HttpGet(url)
    local data = HttpService:JSONDecode(response)

    return data.success
end

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,320,0,180)
Main.Position = UDim2.new(0.5,-160,0.5,-90)
Main.BackgroundColor3 = Color3.fromRGB(15,15,15)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "Poom Edit"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

-- Box
local Box = Instance.new("TextBox", Main)
Box.Size = UDim2.new(0.8,0,0,35)
Box.Position = UDim2.new(0.1,0,0.35,0)
Box.PlaceholderText = "Enter Key..."
Box.Text = ""
Box.BackgroundColor3 = Color3.fromRGB(25,25,25)
Box.TextColor3 = Color3.new(1,1,1)
Box.TextScaled = true

-- GetKey
local GetKey = Instance.new("TextButton", Main)
GetKey.Size = UDim2.new(0.4,-5,0,35)
GetKey.Position = UDim2.new(0.05,0,0.7,0)
GetKey.Text = "Get Key"

-- 🔗 ใส่ลิ้งเว็บมึงตรงนี้
local KeyLink = "https://peompokkao.github.io/Farm-Chest-Bloxfruit-PoomEd"

GetKey.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(KeyLink)
    end
    game:HttpGet(KeyLink)
end)

-- Submit
local Submit = Instance.new("TextButton", Main)
Submit.Size = UDim2.new(0.4,-5,0,35)
Submit.Position = UDim2.new(0.55,0,0.7,0)
Submit.Text = "Submit"

-- Status
local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1,0,0,20)
Status.Position = UDim2.new(0,0,1,-20)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.new(1,1,1)
Status.TextScaled = true

-- Submit Function
Submit.MouseButton1Click:Connect(function()
    local key = Box.Text
    Status.Text = "Checking..."

    local ok = false
    pcall(function()
        ok = CheckKey(key)
    end)

    if ok then
        Status.Text = "✔ Correct Key"
        wait(0.5)
        Main:Destroy()

        -- โหลด HUB มึง
        loadstring(game:HttpGet("https://raw.githubusercontent.com/PeomPokkao/Farm-Chest-Bloxfruit-PoomEd/refs/heads/main/PoomEdit.lua"))()
    else
        Status.Text = "❌ Invalid Key"
    end
end)

-- Animation
Main.Size = UDim2.new(0,0,0,0)
TweenService:Create(Main,TweenInfo.new(0.4,Enum.EasingStyle.Back),{
    Size = UDim2.new(0,320,0,180)
}):Play()
