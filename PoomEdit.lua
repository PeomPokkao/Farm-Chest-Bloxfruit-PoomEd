-- =========================
-- 🔥 UI
-- =========================
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("Poom Hub", Color3.fromRGB(44,120,224), Enum.KeyCode.RightControl)
local tab = win:Tab("Main")

-- =========================
-- 🔧 SERVICES
-- =========================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

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
	local b = getBeliValue()
	if b then lastBeli = b.Value end
end

-- =========================
-- 📦 CHEST
-- =========================
local function getChests()
	local t = {}
	for _,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower():find("chest") then
			local part = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
			if part then
				table.insert(t, part)
			end
		end
	end
	return t
end

local function getClosestChest()
	local char = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local closest, dist = nil, math.huge
	for _,c in pairs(getChests()) do
		local d = (hrp.Position - c.Position).Magnitude
		if d < dist then
			dist = d
			closest = c
		end
	end
	return closest
end

-- =========================
-- 🟢 AUTO FARM
-- =========================
local autoFarm = false

local function TweenTo(pos)
	local hrp = getChar():WaitForChild("HumanoidRootPart")
	local tween = TweenService:Create(
		hrp,
		TweenInfo.new((hrp.Position - pos).Magnitude / 120, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(pos)}
	)
	tween:Play()
	tween.Completed:Wait()
end

task.spawn(function()
	while task.wait(0.3) do
		if autoFarm then
			local chest = getClosestChest()
			if chest then
				updateBeli()
				TweenTo(chest.Position + Vector3.new(0,3,0))
				task.wait(1)

				local b = getBeliValue()
				if b then
					local diff = b.Value - lastBeli
					if diff > 0 then
						beliEarned += diff
						lib:Notification("Beli","+ "..diff.." ("..beliEarned..")","OK")
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

local function addESP(part)
	if part.Parent:FindFirstChild("ESP") then return end
	
	local h = Instance.new("Highlight")
	h.Name = "ESP"
	h.FillColor = Color3.fromRGB(255,255,0)
	h.FillTransparency = 0.4
	h.Parent = part.Parent
end

local function removeESP()
	for _,v in pairs(workspace:GetDescendants()) do
		if v.Name == "ESP" then
			v:Destroy()
		end
	end
end

-- =========================
-- 🌈 NEON
-- =========================
local neonEnabled = false
local neonPart

local function createNeon()
	if neonPart then return end

	local hrp = getChar():WaitForChild("HumanoidRootPart")

	neonPart = Instance.new("Part")
	neonPart.Size = Vector3.new(5,0.3,5)
	neonPart.Anchored = false
	neonPart.CanCollide = false
	neonPart.Material = Enum.Material.Neon
	neonPart.Parent = workspace

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = neonPart
	weld.Part1 = hrp
	weld.Parent = neonPart

	task.spawn(function()
		while neonEnabled and neonPart do
			neonPart.Color = Color3.fromHSV(tick()%5/5,1,1)
			task.wait(0.1)
		end
	end)
end

local function removeNeon()
	if neonPart then
		neonPart:Destroy()
		neonPart = nil
	end
end

-- =========================
-- 🔄 SERVER HOP
-- =========================
local function serverHop()
	local placeId = game.PlaceId
	local data = HttpService:JSONDecode(game:HttpGet(
		"https://games.roblox.com/v1/games/"..placeId.."/servers/Public?limit=100"
	))

	for _,v in pairs(data.data) do
		if v.playing < v.maxPlayers then
			TeleportService:TeleportToPlaceInstance(placeId, v.id, player)
			break
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
	else
		removeESP()
	end
end)

tab:Toggle("Neon Part", false, function(v)
	neonEnabled = v
	if v then createNeon() else removeNeon() end
end)

tab:Button("Check Beli Earned", function()
	lib:Notification("Beli","รวม: "..beliEarned,"OK")
end)

tab:Button("Hop Server", function()
	serverHop()
end)

-- =========================
-- 🔘 TOGGLE UI BUTTON
-- =========================
local uiVisible = true

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,120,0,40)
btn.Position = UDim2.new(0,20,0,200)
btn.Text = "Toggle UI"
btn.BackgroundColor3 = Color3.fromRGB(44,120,224)
btn.TextColor3 = Color3.new(1,1,1)
btn.Active = true
btn.Draggable = true
btn.Parent = game.CoreGui

btn.MouseButton1Click:Connect(function()
	uiVisible = not uiVisible
	
	for _,v in pairs(game.CoreGui:GetChildren()) do
		if v.Name:lower():find("poom") then
			v.Enabled = uiVisible
		end
	end
end)

-- กด Ctrl เปิด/ปิด UI ได้
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.RightControl then
		uiVisible = not uiVisible
		for _,v in pairs(game.CoreGui:GetChildren()) do
			if v.Name:lower():find("poom") then
				v.Enabled = uiVisible
			end
		end
	end
end)
