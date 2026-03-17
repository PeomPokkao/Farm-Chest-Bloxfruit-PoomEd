-- =========================
-- 🔥 LOAD UI (VAPE)
-- =========================
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

local win = lib:Window("Poom Hub", Color3.fromRGB(44,120,224), Enum.KeyCode.RightControl)
local tab = win:Tab("Main")

-- =========================
-- 🔧 SERVICES
-- =========================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

-- =========================
-- 💰 BELI
-- =========================
local beliEarned = 0
local lastBeli = 0

local function getBeliValue()
	local ls = player:FindFirstChild("leaderstats")
	if ls then
		for _,v in pairs(ls:GetChildren()) do
			if v:IsA("IntValue") or v:IsA("NumberValue") then
				if string.find(v.Name:lower(),"beli") or string.find(v.Name:lower(),"money") then
					return v
				end
			end
		end
	end
end

local function updateBeli()
	local beli = getBeliValue()
	if beli then lastBeli = beli.Value end
end

-- =========================
-- 🔥 FOD
-- =========================
local fodCount = 0

local function scanFOD()
	fodCount = 0
	
	local function scan(c)
		for _,v in pairs(c:GetChildren()) do
			if v.Name == "First of Darkness" then
				fodCount += 1
			end
		end
	end

	local bp = player:FindFirstChild("Backpack")
	local char = getChar()

	if bp then scan(bp) end
	if char then scan(char) end

	lib:Notification("FOD", "ทั้งหมด: "..fodCount, "OK")
end

-- =========================
-- 🟢 AUTO FARM
-- =========================
local autoFarm = false

local function TweenTo(pos)
	local char = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local dist = (hrp.Position - pos).Magnitude
	local tween = TweenService:Create(
		hrp,
		TweenInfo.new(dist / 120, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(pos)}
	)

	tween:Play()
	tween.Completed:Wait()
end

local function getChests()
	local t = {}
	for _,v in pairs(workspace:GetDescendants()) do
		if v.Name == "Chest" and v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
			table.insert(t,v)
		end
	end
	return t
end

local function getClosestChest()
	local char = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local closest, dist = nil, math.huge
	for _,c in pairs(getChests()) do
		local d = (hrp.Position - c.HumanoidRootPart.Position).Magnitude
		if d < dist then
			dist = d
			closest = c
		end
	end
	return closest
end

task.spawn(function()
	while task.wait(0.2) do
		if autoFarm then
			local chest = getClosestChest()
			if chest then
				updateBeli()
				TweenTo(chest.HumanoidRootPart.Position)
				task.wait(1)

				local beli = getBeliValue()
				if beli then
					local diff = beli.Value - lastBeli
					if diff > 0 then
						beliEarned += diff
						lib:Notification("Beli", "+ "..diff.." (รวม "..beliEarned..")", "OK")
					end
				end
			end
		end
	end
end)

-- =========================
-- 🔵 ESP
-- =========================
local espEnabled = false
local espConnection

local function addESP(obj)
	if obj:FindFirstChild("ESP") then return end
	local h = Instance.new("Highlight")
	h.Name = "ESP"
	h.FillColor = Color3.fromRGB(255,255,0)
	h.FillTransparency = 0.3
	h.Parent = obj
end

local function removeESP()
	for _,v in pairs(workspace:GetDescendants()) do
		if v.Name == "Chest" and v:FindFirstChild("ESP") then
			v.ESP:Destroy()
		end
	end
end

-- =========================
-- 🎮 UI
-- =========================
tab:Toggle("Auto Farm Chest", false, function(v)
	autoFarm = v
end)

tab:Toggle("ESP Chest", false, function(v)
	espEnabled = v
	
	if v then
		for _,c in pairs(getChests()) do
			addESP(c)
		end
		
		espConnection = workspace.DescendantAdded:Connect(function(obj)
			if espEnabled and obj.Name == "Chest" then
				addESP(obj)
			end
		end)
	else
		if espConnection then espConnection:Disconnect() end
		removeESP()
	end
end)

tab:Button("Check First Of Darkness", function()
	scanFOD()
end)

tab:Button("Check Beli Earned", function()
	lib:Notification("Beli", "รวม: "..beliEarned, "OK")
end)
