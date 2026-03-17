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
-- 💰 BELI FROM CHEST ONLY
-- =========================
local beliEarned = 0
local lastBeli = 0

local function getBeliValue()
	local ls = player:FindFirstChild("leaderstats")
	if ls then
		for _,v in pairs(ls:GetChildren()) do
			if (v:IsA("IntValue") or v:IsA("NumberValue")) then
				if string.find(v.Name:lower(),"beli") or string.find(v.Name:lower(),"money") then
					return v
				end
			end
		end
	end
	return nil
end

local function updateBeli()
	local beli = getBeliValue()
	if beli then
		lastBeli = beli.Value
	end
end

-- =========================
-- 🔥 FIRST OF DARKNESS SYSTEM
-- =========================
local fodCount = 0
local fodEnabled = false
local connections = {}
local textboxRef

local function updateTextbox()
	if textboxRef then
		textboxRef:Set("First Of Darkness : "..fodCount)
	end
end

local function scanFOD()
	fodCount = 0
	
	local function scan(container)
		for _,v in pairs(container:GetChildren()) do
			if v.Name == "First of Darkness" then
				fodCount += 1
			end
		end
	end

	local backpack = player:FindFirstChild("Backpack")
	local char = getChar()

	if backpack then scan(backpack) end
	if char then scan(char) end

	updateTextbox()
end

local function startFOD()
	fodEnabled = true
	local backpack = player:WaitForChild("Backpack")

	scanFOD()

	table.insert(connections,
		backpack.ChildAdded:Connect(function(item)
			if fodEnabled and item.Name == "First of Darkness" then
				fodCount += 1
				updateTextbox()

				OrionLib:MakeNotification({
					Name = "First Of Darkness",
					Content = "ได้รับ +1 (รวม: "..fodCount..")",
					Image = "rbxassetid://4483345998",
					Time = 3
				})
			end
		end)
	)
end

local function stopFOD()
	fodEnabled = false
	for _,c in pairs(connections) do
		pcall(function() c:Disconnect() end)
	end
	connections = {}
end

-- =========================
-- 🟢 AUTO FARM (TWEEN)
-- =========================
local autoFarm = false

local function TweenTo(pos)
	local char = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local dist = (hrp.Position - pos).Magnitude
	local speed = 120

	local tween = TweenService:Create(
		hrp,
		TweenInfo.new(dist / speed, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(pos)}
	)

	tween:Play()
	tween.Completed:Wait()
end

local function getChests()
	local chests = {}
	for _,v in pairs(workspace:GetDescendants()) do
		if v.Name == "Chest" and v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
			table.insert(chests, v)
		end
	end
	return chests
end

local function getClosestChest()
	local char = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local closest, dist = nil, math.huge

	for _,chest in pairs(getChests()) do
		local d = (hrp.Position - chest.HumanoidRootPart.Position).Magnitude
		if d < dist then
			dist = d
			closest = chest
		end
	end

	return closest
end

task.spawn(function()
	while true do
		task.wait(0.2)
		if autoFarm then
			local chest = getClosestChest()
			if chest then
				
				-- 💰 จำเงินก่อนเก็บ
				updateBeli()

				TweenTo(chest.HumanoidRootPart.Position)
				task.wait(1)

				-- 💰 เช็คเงินหลังเก็บ
				local beli = getBeliValue()
				if beli then
					local diff = beli.Value - lastBeli
					if diff > 0 then
						beliEarned += diff

						OrionLib:MakeNotification({
							Name = "Beli From Chest",
							Content = "+ "..diff.." (รวม: "..beliEarned..")",
							Image = "rbxassetid://4483345998",
							Time = 2
						})
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

local function addESP(obj)
	if obj:FindFirstChild("ESP") then return end
	
	local h = Instance.new("Highlight")
	h.Name = "ESP"
	h.FillColor = Color3.fromRGB(255,255,0)
	h.FillTransparency = 0.3
	h.OutlineColor = Color3.new(0,0,0)
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
-- 🌈 NEON PART
-- =========================
local neonEnabled = false
local neonPart

local function createNeon()
	if neonPart then return end

	local char = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")

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

	neonPart.CFrame = hrp.CFrame * CFrame.new(0,-3,0)

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
-- 🎮 UI CONNECT
-- =========================

Tab1:AddToggle({
	Name = "Auto Farm Chest",
	Default = false,
	Callback = function(Value)
		autoFarm = Value
	end    
})

Tab1:AddToggle({
	Name = "Esp Chest",
	Default = false,
	Callback = function(Value)
		espEnabled = Value
		
		if Value then
			for _,v in pairs(getChests()) do
				addESP(v)
			end
			
			workspace.DescendantAdded:Connect(function(v)
				if espEnabled and v.Name == "Chest" then
					addESP(v)
				end
			end)
		else
			removeESP()
		end
	end    
})

Tab1:AddToggle({
	Name = "Part Neon",
	Default = false,
	Callback = function(Value)
		neonEnabled = Value
		
		if Value then
			createNeon()
		else
			removeNeon()
		end
	end    
})

Tab1:AddToggle({
	Name = "Track First Of Darkness",
	Default = false,
	Callback = function(Value)
		if Value then
			startFOD()
		else
			stopFOD()
		end
	end    
})

textboxRef = Tab1:AddTextbox({
	Name = "First Of Darkness",
	Default = "First Of Darkness : 0",
	TextDisappear = false,
	Callback = function(Value)
	end	  
})

Tab1:AddButton({
	Name = "Check First Of Darkness",
	Callback = function()
		scanFOD()

		OrionLib:MakeNotification({
			Name = "First Of Darkness",
			Content = "First Of Darkness : "..fodCount,
			Image = "rbxassetid://4483345998",
			Time = 4
		})
	end    
})

-- 💰 ปุ่มดูเงินรวม
Tab1:AddButton({
	Name = "Check Beli Earned",
	Callback = function()
		OrionLib:MakeNotification({
			Name = "Beli Total",
			Content = "เงินจากกล่อง: "..beliEarned,
			Image = "rbxassetid://4483345998",
			Time = 4
		})
	end    
})
