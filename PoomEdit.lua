-- UI LIB
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("CHEST FARM HUB",Color3.fromRGB(44,120,224))
local tab = win:Tab("Main")

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- 🔥 เพิ่มระยะโหลด
pcall(function()
	LocalPlayer.MaximumSimulationRadius = math.huge
	sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
end)

-- SETTINGS
local FARM_SPEED = 300
local autoFarm = false
local espEnabled = false

-- =========================
-- 🔥 TWEEN (นิ่ง + ทะลุ + ไม่ลอย)
-- =========================
local function TweenTo(pos)
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	for _,v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end

	local target = Vector3.new(pos.X, hrp.Position.Y, pos.Z)

	local dist = (hrp.Position - target).Magnitude
	local tween = TweenService:Create(
		hrp,
		TweenInfo.new(dist / FARM_SPEED, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(target)}
	)
	tween:Play()
	tween.Completed:Wait()
end

-- =========================
-- 🔥 หา "กล่องใกล้สุด"
-- =========================
local function getNearestChest()
	local char = LocalPlayer.Character
	if not char then return nil end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local nearest = nil
	local shortest = math.huge

	for _,v in pairs(workspace:GetDescendants()) do
		if string.find(v.Name:lower(),"chest") then
			
			local pos = nil
			
			if v:IsA("BasePart") then
				pos = v.Position
			elseif v:IsA("Model") and v.PrimaryPart then
				pos = v.PrimaryPart.Position
			end

			if pos then
				local dist = (hrp.Position - pos).Magnitude
				if dist < shortest then
					shortest = dist
					nearest = pos
				end
			end
			
		end
	end

	return nearest
end

-- =========================
-- 🔥 AUTO FARM (ฉลาดขึ้น)
-- =========================
task.spawn(function()
	while task.wait(0.1) do
		if autoFarm then
			local target = getNearestChest()
			if target then
				TweenTo(target)
			end
		end
	end
end)

-- =========================
-- 🔥 ESP FULL MAP (ดีที่สุดที่ทำได้)
-- =========================
local espCache = {}

task.spawn(function()
	while task.wait(0.3) do
		if espEnabled then
			for _,v in pairs(workspace:GetDescendants()) do
				if string.find(v.Name:lower(),"chest") then
					
					if not espCache[v] then
						espCache[v] = true
						
						task.spawn(function()
							pcall(function()
								local h = Instance.new("Highlight")
								h.Name = "ESP"
								h.FillColor = Color3.fromRGB(255,255,0)
								h.FillTransparency = 0.3
								h.OutlineTransparency = 0
								h.Parent = v
							end)
						end)
					end
					
				end
			end
		end
	end
end)

-- =========================
-- 💰 BELI TRACK (FIX แล้ว)
-- =========================
local beliEarned = 0

task.spawn(function()
	local stats = LocalPlayer:WaitForChild("leaderstats",10)
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
end)

-- =========================
-- 🌍 SERVER HOP
-- =========================
tab:Button("Hop Server", function()
	game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

-- =========================
-- UI CONTROL
-- =========================
tab:Toggle("Auto Farm Chest", false, function(v)
	autoFarm = v
end)

tab:Toggle("ESP Chest", false, function(v)
	espEnabled = v
end)

-- =========================
-- 📱 ปุ่มเปิด/ปิด UI (มือถือใช้ได้)
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "ToggleUI"
gui.Parent = game.CoreGui

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
		if v.Name == "CHEST FARM HUB" then
			v.Enabled = uiVisible
		end
	end
end)
