-- UI LIB
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("CHEST FARM HUB",Color3.fromRGB(44,120,224),Enum.KeyCode.RightControl)
local tab = win:Tab("Main")

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local FARM_SPEED = 300
local autoFarm = false
local espEnabled = false
local neonEnabled = false

-- =========================
-- AUTO FARM
-- =========================
local function TweenTo(pos)
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local dist = (hrp.Position - pos).Magnitude
	local tween = TweenService:Create(
		hrp,
		TweenInfo.new(dist / FARM_SPEED, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(pos)}
	)
	tween:Play()
	tween.Completed:Wait()
end

local function getChests()
	local chests = {}
	for _,v in pairs(workspace:GetDescendants()) do
		if string.find(v.Name:lower(),"chest") then
			table.insert(chests,v)
		end
	end
	return chests
end

task.spawn(function()
	while task.wait(0.1) do
		if autoFarm then
			for _,chest in pairs(getChests()) do
				if chest:IsA("BasePart") then
					TweenTo(chest.Position)
				elseif chest:IsA("Model") and chest.PrimaryPart then
					TweenTo(chest.PrimaryPart.Position)
				end
			end
		end
	end
end)

-- =========================
-- ESP (FIX เห็นไกล)
-- =========================
RunService.RenderStepped:Connect(function()
	if espEnabled then
		for _,v in pairs(workspace:GetDescendants()) do
			if string.find(v.Name:lower(),"chest") then
				
				if not v:FindFirstChild("ESP") then
					local h = Instance.new("Highlight")
					h.Name = "ESP"
					h.FillColor = Color3.fromRGB(255,255,0)
					h.FillTransparency = 0.3
					h.OutlineTransparency = 0
					h.Parent = v
				end
				
			end
		end
	end
end)

-- =========================
-- NEON (FIX ใช้ได้จริง)
-- =========================
local neonPart = nil

RunService.RenderStepped:Connect(function()
	if neonEnabled then
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			
			if not neonPart then
				neonPart = Instance.new("Part")
				neonPart.Size = Vector3.new(6,1,6)
				neonPart.Anchored = true
				neonPart.CanCollide = false
				neonPart.Material = Enum.Material.Neon
				neonPart.Color = Color3.fromRGB(0,255,255)
				neonPart.Parent = workspace
			end

			neonPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,-3,0)
		end
	else
		if neonPart then
			neonPart:Destroy()
			neonPart = nil
		end
	end
end)

-- =========================
-- BELI TRACK
-- =========================
local beliEarned = 0

local function hookBeli()
	local stats = LocalPlayer:WaitForChild("leaderstats",5)
	if not stats then return end

	for _,v in pairs(stats:GetChildren()) do
		if v:IsA("IntValue") or v:IsA("NumberValue") then
			if v.Name:lower():find("beli") or v.Name:lower():find("money") then
				
				local last = v.Value

				v:GetPropertyChangedSignal("Value"):Connect(function()
					local diff = v.Value - last
					if diff > 0 then
						beliEarned += diff
						lib:Notification("Beli Earned", "+"..diff.." | Total: "..beliEarned, "OK")
					end
					last = v.Value
				end)

			end
		end
	end
end

hookBeli()

-- =========================
-- SERVER HOP
-- =========================
tab:Button("Hop Server", function()
	game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

-- =========================
-- UI CONTROLS
-- =========================
tab:Toggle("Auto Farm Chest", false, function(v)
	autoFarm = v
end)

tab:Toggle("ESP Chest", false, function(v)
	espEnabled = v
end)

tab:Toggle("Neon Under Player", false, function(v)
	neonEnabled = v
end)

-- =========================
-- MOBILE UI BUTTON
-- =========================
local gui = Instance.new("ScreenGui", game.CoreGui)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,120,0,50)
btn.Position = UDim2.new(0,20,0.5,0)
btn.Text = "OPEN UI"
btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
btn.Parent = gui

local uiVisible = true

btn.MouseButton1Click:Connect(function()
	uiVisible = not uiVisible
	
	for _,v in pairs(game.CoreGui:GetChildren()) do
		if v:IsA("ScreenGui") and v ~= gui then
			v.Enabled = uiVisible
		end
	end
end)
