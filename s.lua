-- ZENTIROG RIVALS SCRIPT
-- Red Transparent UI (Aimbot/ESP) + Golden Side UI (Movement)
-- Hold N to constantly stick to enemy's back + Camera aims at selected body part

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
task.wait(0.5)

-- ================================
-- GOLDEN MENU (SAFE PLAYERS)
-- ================================

local goldenPlayers = {}
local currentStickEnemy = nil

-- Stick Aim Target (can be changed via UI)
local stickAimTarget = "Head" -- Options: Head, UpperTorso, Torso, HumanoidRootPart

local function isGoldenPlayer(player)
    if not player then return false end
    for _, goldenName in pairs(goldenPlayers) do
        if player.Name:lower() == goldenName:lower() or (player.DisplayName and player.DisplayName:lower() == goldenName:lower()) then
            return true
        end
    end
    return false
end

local function getClosestNonGoldenEnemy()
    local closest = nil
    local closestDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and not isGoldenPlayer(player) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local dist = (myHRP.Position - targetHRP.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest, closestDist
end

-- Function to get the target body part for aiming
local function getStickTargetPart(character)
    if not character then return nil end
    
    if stickAimTarget == "Head" then
        return character:FindFirstChild("Head")
    elseif stickAimTarget == "UpperTorso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    elseif stickAimTarget == "Torso" then
        return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    elseif stickAimTarget == "HumanoidRootPart" then
        return character:FindFirstChild("HumanoidRootPart")
    end
    
    -- Default to Head if not found
    return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

-- ================================
-- ENEMY STICK SYSTEM (WITH CAMERA AIM)
-- ================================

local isSticking = false
local stickConnection = nil
local stickDistance = 4.5

local function stickToEnemy()
    if not currentStickEnemy or not currentStickEnemy.Character or isGoldenPlayer(currentStickEnemy) then
        local newEnemy, _ = getClosestNonGoldenEnemy()
        if newEnemy then
            currentStickEnemy = newEnemy
        else
            return
        end
    end
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    local enemyChar = currentStickEnemy.Character
    if not enemyChar then 
        currentStickEnemy = nil
        return 
    end
    local enemyHRP = enemyChar:FindFirstChild("HumanoidRootPart")
    if not enemyHRP then return end
    
    local humanoid = enemyChar:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        currentStickEnemy = nil
        local newEnemy, _ = getClosestNonGoldenEnemy()
        if newEnemy then
            currentStickEnemy = newEnemy
        end
        return
    end
    
    -- Get the target body part for aiming (based on user selection)
    local targetPart = getStickTargetPart(enemyChar)
    if not targetPart then
        targetPart = enemyHRP
    end
    
    -- Calculate position behind enemy
    local enemyDirection = enemyHRP.CFrame.LookVector
    local behindPos = enemyHRP.Position - enemyDirection * stickDistance
    
    -- Teleport character to stick to enemy
    myHRP.CFrame = CFrame.new(behindPos, enemyHRP.Position)
    
    -- Make character face enemy
    myHRP.CFrame = CFrame.new(myHRP.Position, enemyHRP.Position)
    
    -- FORCE CAMERA TO LOOK AT SELECTED BODY PART
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
end

local function startSticking()
    if isSticking then return end
    
    local enemy, _ = getClosestNonGoldenEnemy()
    if not enemy then return end
    
    currentStickEnemy = enemy
    isSticking = true
    
    stickConnection = RunService.RenderStepped:Connect(function()
        pcall(stickToEnemy)
    end)
end

local function stopSticking()
    if not isSticking then return end
    isSticking = false
    if stickConnection then
        stickConnection:Disconnect()
        stickConnection = nil
    end
    currentStickEnemy = nil
end

-- ================================
-- KEYBIND SYSTEM
-- ================================

local keybinds = {
    aimbotToggle = "X",
    menuToggle = "Insert",
    noclip = "LeftControl",
    fly = "F",
    infiniteJump = "LeftAlt",
    stick = "N"
}

local function getKeyCodeFromName(name)
    for _, key in pairs(Enum.KeyCode:GetEnumItems()) do
        if key.Name == name then return key end
    end
    return Enum.KeyCode.X
end

local function createKeybindFromString(str)
    return getKeyCodeFromName(str)
end

local aimbotToggleKey = createKeybindFromString(keybinds.aimbotToggle)
local menuToggleKey = createKeybindFromString(keybinds.menuToggle)
local noclipKey = createKeybindFromString(keybinds.noclip)
local flyKey = createKeybindFromString(keybinds.fly)
local infJumpKey = createKeybindFromString(keybinds.infiniteJump)
local stickKey = createKeybindFromString(keybinds.stick)

-- Aimbot hold key selection
local aimbotHoldMouseButton = "RightClick"

local function isAimbotHoldPressed()
    if aimbotHoldMouseButton == "LeftClick" then
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    else
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end
end

-- ================================
-- CORE FUNCTIONS
-- ================================

local config = {
    aimbot = { enabled = false },
    legitAim = {
        fovRadius = 150, showFov = true, smoothness = 3, targetPart = "Head"
    },
    menu = { menuKey = menuToggleKey },
    esp = { enabled = false, maxDistance = 500, chamsEnabled = true, boxEnabled = true, healthBarEnabled = true }
}

local lockedTarget = nil
local currentTargetPart = nil
local isAiming = false
local accumulatedX, accumulatedY = 0, 0
local espMap = {}

-- ================================
-- MOVEMENT FEATURES
-- ================================

local noclipEnabled = false
local noclipConnection = nil

local function updateNoclip()
    if noclipEnabled then
        if noclipConnection then return end
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer and LocalPlayer.Character then
                pcall(function()
                    for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
                        if child:IsA("BasePart") and child.CanCollide then
                            child.CanCollide = false
                        end
                    end
                end)
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if LocalPlayer and LocalPlayer.Character then
            pcall(function()
                for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
                    if child:IsA("BasePart") then
                        child.CanCollide = true
                    end
                end
            end)
        end
    end
end

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    updateNoclip()
    return noclipEnabled
end

-- FLY
local flyEnabled = false
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flySpeed = 75

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    
    flyEnabled = true
    pcall(function() humanoid.PlatformStand = true end)
    
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Name = "FlyVelocity"
    flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.Name = "FlyGyro"
    flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyGyro.P = 9000
    flyBodyGyro.D = 500
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
end

local function stopFly()
    flyEnabled = false
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then pcall(function() humanoid.PlatformStand = false end) end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            if flyBodyGyro then flyBodyGyro:Destroy() end
        end
    end
    flyBodyVelocity = nil
    flyBodyGyro = nil
end

local function toggleFly()
    if flyEnabled then stopFly() else startFly() end
    return flyEnabled
end

local function updateFly()
    if not flyEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not flyBodyVelocity then startFly(); return end
    
    local direction = Vector3.new(0, 0, 0)
    
    if UIS:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
    
    if direction.Magnitude > 0 then direction = direction.Unit * flySpeed end
    flyBodyVelocity.Velocity = direction
    if flyBodyGyro then flyBodyGyro.CFrame = Camera.CFrame end
end

RunService.Heartbeat:Connect(function() pcall(updateFly) end)

-- INFINITE JUMP
local infJumpEnabled = false
local infJumpConnection = nil

local function enableInfiniteJump()
    if infJumpConnection then infJumpConnection:Disconnect() end
    infJumpConnection = UIS.JumpRequest:Connect(function()
        if infJumpEnabled then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildWhichIsA("Humanoid")
                if humanoid and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
    infJumpEnabled = true
end

local function disableInfiniteJump()
    if infJumpConnection then infJumpConnection:Disconnect(); infJumpConnection = nil end
    infJumpEnabled = false
end

local function toggleInfiniteJump()
    if infJumpEnabled then disableInfiniteJump() else enableInfiniteJump() end
    return infJumpEnabled
end

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flyEnabled then startFly() end
    if noclipEnabled then updateNoclip() end
    if infJumpEnabled then enableInfiniteJump() end
    if isSticking then stopSticking() end
end)

-- ================================
-- AIMBOT FUNCTIONS
-- ================================

local function findBodyPart(c, n)
    if not c then return nil end
    if n == "Head" then return c:FindFirstChild("Head")
    elseif n == "UpperTorso" then return c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
    elseif n == "Torso" then return c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    elseif n == "HumanoidRootPart" then return c:FindFirstChild("HumanoidRootPart") end
    return c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
end

local function getDistance(p1, p2) if not p1 or not p2 then return math.huge end return (p1.Position - p2.Position).Magnitude end

local function isTargetValid(p)
    if not p or not p.Character or isGoldenPlayer(p) then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    local mc = LocalPlayer.Character
    if mc then
        local mh = mc:FindFirstChild("HumanoidRootPart")
        local th = p.Character:FindFirstChild("HumanoidRootPart")
        if mh and th and getDistance(mh, th) / 3.5 > config.esp.maxDistance then return false end
    end
    return true
end

local function findTargetInFOV(fovRadius, targetPart)
    local mc = LocalPlayer.Character
    if not mc then return nil end
    local mh = mc:FindFirstChild("HumanoidRootPart")
    if not mh then return nil end
    local mp = UIS:GetMouseLocation()
    local closest, minDist = nil, fovRadius + 1
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character and not isGoldenPlayer(pl) then
            local ch = pl.Character
            local h = ch:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                local tp = findBodyPart(ch, targetPart)
                if tp and getDistance(mh, tp) <= config.esp.maxDistance * 3.5 then
                    local s, sp, on = pcall(function() return Camera:WorldToViewportPoint(tp.Position) end)
                    if s and on then
                        local d = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                        if d <= fovRadius and d < minDist then minDist = d; closest = pl end
                    end
                end
            end
        end
    end
    return closest
end

local function executeLegitAim()
    if not config.aimbot.enabled then return end
    local should = isAimbotHoldPressed()
    if not should then lockedTarget = nil; currentTargetPart = nil; isAiming = false; accumulatedX, accumulatedY = 0, 0; return end
    isAiming = true
    if not lockedTarget or not isTargetValid(lockedTarget) then
        lockedTarget = findTargetInFOV(config.legitAim.fovRadius, config.legitAim.targetPart)
        accumulatedX, accumulatedY = 0, 0
    end
    if lockedTarget and isTargetValid(lockedTarget) then
        currentTargetPart = findBodyPart(lockedTarget.Character, config.legitAim.targetPart)
        if currentTargetPart and mousemoverel then
            local sp, on = Camera:WorldToViewportPoint(currentTargetPart.Position)
            if on then
                local mp = UIS:GetMouseLocation()
                local dx, dy = sp.X - mp.X, sp.Y - mp.Y
                local d = math.sqrt(dx * dx + dy * dy)
                if d < 1 then return end
                local spd = math.clamp(d / (config.legitAim.smoothness * 1.5), 0.5, d * 0.8)
                local mx, my = (dx / d) * spd, (dy / d) * spd
                accumulatedX, accumulatedY = accumulatedX + mx, accumulatedY + my
                local fx, fy = math.floor(accumulatedX), math.floor(accumulatedY)
                if fx ~= 0 or fy ~= 0 then mousemoverel(fx, fy); accumulatedX, accumulatedY = accumulatedX - fx, accumulatedY - fy end
            end
        end
    else lockedTarget, currentTargetPart = nil, nil end
end

RunService.RenderStepped:Connect(function() pcall(executeLegitAim) end)

-- ================================
-- ESP FUNCTIONS
-- ================================

local function cleanupPlayer(p)
    local uid = p.UserId
    local e = espMap[uid]
    if not e then return end
    if e.highlight then pcall(function() if e.highlight.Parent then e.highlight:Destroy() end end) end
    if e.box then pcall(function() e.box:Remove() end) end
    if e.boxOutline then pcall(function() e.boxOutline:Remove() end) end
    if e.healthBarBg then pcall(function() e.healthBarBg:Remove() end) end
    if e.healthBar then pcall(function() e.healthBar:Remove() end) end
    if e.healthBarOutline then pcall(function() e.healthBarOutline:Remove() end) end
    if e.nameTag then pcall(function() e.nameTag:Remove() end) end
    if e.conn then pcall(function() e.conn:Disconnect() end) end
    espMap[uid] = nil
end

local function getBoxBounds(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local rootPos = hrp.Position
    local topPos = rootPos + Vector3.new(0, 3.5, 0)
    local bottomPos = rootPos - Vector3.new(0, 2.5, 0)
    local ts, ton = Camera:WorldToViewportPoint(topPos)
    local bs, bon = Camera:WorldToViewportPoint(bottomPos)
    if not ton and not bon then return nil end
    if ts.Z < 0 or bs.Z < 0 then return nil end
    local h = math.abs(bs.Y - ts.Y)
    local w = h * 0.6
    local cx = (ts.X + bs.X) / 2
    return { x = cx - w / 2, y = ts.Y, width = w, height = h, centerX = cx, centerY = (ts.Y + bs.Y) / 2 }
end

local function createEspFor(player)
    if player == LocalPlayer or not player.Character then return end
    local h = player.Character:FindFirstChildOfClass("Humanoid")
    if not h then return end
    local uid = player.UserId
    if espMap[uid] then cleanupPlayer(player) end
    
    local isGolden = isGoldenPlayer(player)
    local fillCol = isGolden and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 80, 80)
    local outlineCol = isGolden and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(200, 0, 0)
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "Vertuos_ESP"
    highlight.FillColor = fillCol
    highlight.OutlineColor = outlineCol
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Enabled = config.esp.chamsEnabled
    highlight.Parent = player.Character
    
    local boxOutline = Drawing.new("Square")
    boxOutline.Color = Color3.fromRGB(0, 0, 0)
    boxOutline.Filled = false
    boxOutline.Thickness = 3
    boxOutline.Visible = false
    boxOutline.ZIndex = 9
    
    local box = Drawing.new("Square")
    box.Color = fillCol
    box.Filled = false
    box.Thickness = 1
    box.Visible = false
    box.ZIndex = 10
    
    local healthBarOutline = Drawing.new("Square")
    healthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    healthBarOutline.Filled = true
    healthBarOutline.Visible = false
    healthBarOutline.ZIndex = 10
    
    local healthBarBg = Drawing.new("Square")
    healthBarBg.Color = Color3.fromRGB(30, 30, 30)
    healthBarBg.Filled = true
    healthBarBg.Visible = false
    healthBarBg.ZIndex = 11
    
    local healthBar = Drawing.new("Square")
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Filled = true
    healthBar.Visible = false
    healthBar.ZIndex = 12
    
    local nameTag = Drawing.new("Text")
    nameTag.Size = 12
    nameTag.Font = 2
    nameTag.Color = isGolden and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameTag.Center = true
    nameTag.Visible = false
    nameTag.ZIndex = 13
    nameTag.Text = (isGolden and "🌟 " or "") .. (player.DisplayName or player.Name)
    
    espMap[uid] = { highlight = highlight, humanoid = h, box = box, boxOutline = boxOutline, healthBarBg = healthBarBg, healthBar = healthBar, healthBarOutline = healthBarOutline, nameTag = nameTag, isGolden = isGolden }
    
    local conn = player.Character.AncestryChanged:Connect(function(_, parent) if not parent then cleanupPlayer(player) end end)
    espMap[uid].conn = conn
end

local function updateEspFor(player)
    if not config.esp.enabled or player == LocalPlayer then return end
    local uid = player.UserId
    local entry = espMap[uid]
    if not entry or not entry.highlight or not entry.highlight.Parent then createEspFor(player); entry = espMap[uid]; if not entry then return end end
    
    local isGolden = isGoldenPlayer(player)
    local fillCol = isGolden and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 80, 80)
    local outlineCol = isGolden and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(200, 0, 0)
    
    local highlight = entry.highlight
    local h = player.Character:FindFirstChildOfClass("Humanoid")
    if not h then return end
    entry.humanoid = h
    
    local box, boxOutline, healthBarBg, healthBar, healthBarOutline, nameTag = entry.box, entry.boxOutline, entry.healthBarBg, entry.healthBar, entry.healthBarOutline, entry.nameTag
    
    local mc = LocalPlayer.Character
    local should = true
    local dead = h.Health <= 0
    if mc then
        local mh = mc:FindFirstChild("HumanoidRootPart")
        local th = player.Character:FindFirstChild("HumanoidRootPart")
        if mh and th and getDistance(mh, th) / 3.5 > config.esp.maxDistance then should = false end
    end
    if dead then should = false end
    
    local isTarget = (lockedTarget == player) and (not dead) and isAiming
    local targetFill = isTarget and Color3.fromRGB(255, 200, 100) or fillCol
    local targetOutline = isTarget and Color3.fromRGB(255, 150, 0) or outlineCol
    
    pcall(function()
        highlight.Enabled = config.esp.chamsEnabled and should
        highlight.FillColor = targetFill
        highlight.OutlineColor = targetOutline
    end)
    
    local bounds = should and getBoxBounds(player.Character) or nil
    if bounds and (config.esp.boxEnabled or config.esp.healthBarEnabled) then
        if config.esp.boxEnabled then
            box.Position = Vector2.new(bounds.x, bounds.y)
            box.Size = Vector2.new(bounds.width, bounds.height)
            box.Color = targetFill
            box.Visible = true
            boxOutline.Position = Vector2.new(bounds.x, bounds.y)
            boxOutline.Size = Vector2.new(bounds.width, bounds.height)
            boxOutline.Visible = true
        else box.Visible, boxOutline.Visible = false, false end
        
        if config.esp.healthBarEnabled then
            local hp = h.Health
            local mh = h.MaxHealth
            local pct = math.clamp(hp / mh, 0, 1)
            local bw = 4
            local bx = bounds.x - bw - 3
            local by = bounds.y
            local bh = bounds.height
            local hh = bh * pct
            
            healthBarOutline.Position = Vector2.new(bx - 1, by - 1)
            healthBarOutline.Size = Vector2.new(bw + 2, bh + 2)
            healthBarOutline.Visible = true
            healthBarBg.Position = Vector2.new(bx, by)
            healthBarBg.Size = Vector2.new(bw, bh)
            healthBarBg.Visible = true
            healthBar.Position = Vector2.new(bx, by + (bh - hh))
            healthBar.Size = Vector2.new(bw, math.max(hh, 1))
            healthBar.Visible = true
            if pct > 0.6 then healthBar.Color = Color3.fromRGB(0, 255, 0)
            elseif pct > 0.3 then healthBar.Color = Color3.fromRGB(255, 255, 0)
            else healthBar.Color = Color3.fromRGB(255, 0, 0) end
        else healthBarOutline.Visible, healthBarBg.Visible, healthBar.Visible = false, false, false end
        
        nameTag.Position = Vector2.new(bounds.centerX, bounds.y - 15)
        nameTag.Text = (isGolden and "🌟 " or "") .. (player.DisplayName or player.Name)
        nameTag.Color = isGolden and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
        nameTag.Visible = config.esp.boxEnabled
    else box.Visible, boxOutline.Visible, healthBarOutline.Visible, healthBarBg.Visible, healthBar.Visible, nameTag.Visible = false, false, false, false, false, false end
end

local function setEspActive(on)
    config.esp.enabled = on
    if not on then for _, p in ipairs(Players:GetPlayers()) do cleanupPlayer(p) end; return end
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then createEspFor(p) end end
end

RunService.RenderStepped:Connect(function()
    if config.esp.enabled then for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then pcall(updateEspFor, p) end end end
end)

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function(c) task.wait(0.5); if config.esp.enabled and c.Parent then createEspFor(p) end end) end)
Players.PlayerRemoving:Connect(function(p) cleanupPlayer(p) end)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then p.CharacterAdded:Connect(function(c) task.wait(0.5); if config.esp.enabled and c.Parent then createEspFor(p) end end) end end

-- ================================
-- SNOW EFFECT SYSTEM
-- ================================

local function createSnowEffect(parentFrame)
    local snowContainer = Instance.new("Frame", parentFrame)
    snowContainer.Size = UDim2.new(1, 0, 1, 0)
    snowContainer.BackgroundTransparency = 1
    snowContainer.ZIndex = 999
    
    for i = 1, 100 do
        local snowflake = Instance.new("Frame", snowContainer)
        snowflake.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        snowflake.Position = UDim2.new(math.random() * 0.95, 0, math.random() * 0.95, 0)
        snowflake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        snowflake.BackgroundTransparency = 0.4 + math.random() * 0.5
        snowflake.BorderSizePixel = 0
        local corner = Instance.new("UICorner", snowflake)
        corner.CornerRadius = UDim.new(1, 0)
        task.spawn(function()
            while snowContainer and snowContainer.Parent do
                pcall(function()
                    local ny = snowflake.Position.Y.Scale + (0.5 + math.random() * 1.5) / 500
                    local nx = snowflake.Position.X.Scale + (math.random() - 0.5) / 400
                    if ny > 1 then
                        snowflake.Position = UDim2.new(math.random() * 0.95, 0, 0, 0)
                    else
                        snowflake.Position = UDim2.new(math.clamp(nx, 0, 0.95), 0, ny, 0)
                    end
                end)
                task.wait(0.04)
            end
        end)
    end
    return snowContainer
end

-- ================================
-- UI CREATION
-- ================================

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ZentirogHub"

-- MAIN RED UI
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 380, 0, 550)
mainFrame.Position = UDim2.new(0.02, 0, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
mainFrame.BackgroundTransparency = 0.7
mainFrame.Active = true
mainFrame.Draggable = true

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

local border = Instance.new("UIStroke", mainFrame)
border.Color = Color3.fromRGB(255, 50, 50)
border.Thickness = 2

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 45)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "ZENTIROG RIVALS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local subtitle = Instance.new("TextLabel", mainFrame)
subtitle.Size = UDim2.new(1, 0, 0, 20)
subtitle.Position = UDim2.new(0, 0, 0, 32)
subtitle.Text = "AIMBOT | ESP | RED EDITION"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10

local scrollingFrame = Instance.new("ScrollingFrame", mainFrame)
scrollingFrame.Size = UDim2.new(1, -20, 1, -70)
scrollingFrame.Position = UDim2.new(0, 10, 0, 55)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scrollingFrame)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Transparency = 0.5
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Radius = config.legitAim.fovRadius

local function updateFovPosition() fovCircle.Position = UIS:GetMouseLocation() end
RunService.RenderStepped:Connect(updateFovPosition)

-- BUTTON CREATION FUNCTIONS
local function createRedButton(text, initialState, callback)
    local btn = Instance.new("TextButton", scrollingFrame)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = initialState and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(100, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        local ns = not initialState
        initialState = ns
        btn.BackgroundColor3 = ns and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(100, 0, 0)
        callback(ns)
    end)
    return btn
end

local function createRedSlider(label, minVal, maxVal, defVal, callback, suffix)
    local frame = Instance.new("Frame", scrollingFrame)
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.Text = label .. ": " .. defVal .. (suffix or "")
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(1, 0, 0, 18)
    bg.Position = UDim2.new(0, 0, 0, 22)
    bg.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    bg.BackgroundTransparency = 0.5
    local bgCorner = Instance.new("UICorner", bg)
    bgCorner.CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((defVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 3)
    
    local knob = Instance.new("TextButton", bg)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((defVal - minVal) / (maxVal - minVal), -7, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
    knob.Text = ""
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)
    
    local valDisp = Instance.new("TextLabel", frame)
    valDisp.Size = UDim2.new(1, 0, 0, 16)
    valDisp.Position = UDim2.new(0, 0, 0, 42)
    valDisp.Text = defVal .. (suffix or "")
    valDisp.TextColor3 = Color3.fromRGB(255, 150, 150)
    valDisp.BackgroundTransparency = 1
    valDisp.Font = Enum.Font.Gotham
    valDisp.TextSize = 10
    valDisp.TextXAlignment = Enum.TextXAlignment.Center
    
    local dragging = false
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local mp = UIS:GetMouseLocation()
            local pos = bg.AbsolutePosition
            local sz = bg.AbsoluteSize.X
            local rel = math.clamp(mp.X - pos.X, 0, sz)
            local pct = rel / sz
            local val = math.floor(minVal + (pct * (maxVal - minVal)))
            val = math.clamp(val, minVal, maxVal)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -7, 0, 2)
            valDisp.Text = val .. (suffix or "")
            lbl.Text = label .. ": " .. val .. (suffix or "")
            callback(val)
        end
    end)
    return frame
end

local function createRedDropdown(label, options, defIndex, callback)
    local frame = Instance.new("Frame", scrollingFrame)
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.45, 0, 0.85, 0)
    btn.Position = UDim2.new(0.55, 0, 0.07, 0)
    btn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = options[defIndex]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    local idx = defIndex
    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        btn.Text = options[idx]
        callback(options[idx])
    end)
    return frame
end

local function createKeybindButton(label, currentKey, callback)
    local frame = Instance.new("Frame", scrollingFrame)
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.45, 0, 0.85, 0)
    btn.Position = UDim2.new(0.55, 0, 0.07, 0)
    btn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = currentKey
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    local waiting = false
    local conn
    btn.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        btn.Text = "..."
        btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        if conn then conn:Disconnect() end
        conn = UIS.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode then
                local keyName = inp.KeyCode.Name
                btn.Text = keyName
                btn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
                callback(keyName)
                waiting = false
                conn:Disconnect()
            end
        end)
    end)
    return frame
end

local function createMouseSelectionButton(label, currentSelection, callback)
    local frame = Instance.new("Frame", scrollingFrame)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local leftBtn = Instance.new("TextButton", frame)
    leftBtn.Size = UDim2.new(0.27, 0, 0.85, 0)
    leftBtn.Position = UDim2.new(0.42, 0, 0.07, 0)
    leftBtn.BackgroundColor3 = (currentSelection == "LeftClick") and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(100, 0, 0)
    leftBtn.BackgroundTransparency = 0.3
    leftBtn.Text = "🖱️ LEFT CLICK"
    leftBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftBtn.Font = Enum.Font.GothamSemibold
    leftBtn.TextSize = 10
    local leftCorner = Instance.new("UICorner", leftBtn)
    leftCorner.CornerRadius = UDim.new(0, 5)
    
    local rightBtn = Instance.new("TextButton", frame)
    rightBtn.Size = UDim2.new(0.27, 0, 0.85, 0)
    rightBtn.Position = UDim2.new(0.71, 0, 0.07, 0)
    rightBtn.BackgroundColor3 = (currentSelection == "RightClick") and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(100, 0, 0)
    rightBtn.BackgroundTransparency = 0.3
    rightBtn.Text = "🖱️ RIGHT CLICK"
    rightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightBtn.Font = Enum.Font.GothamSemibold
    rightBtn.TextSize = 10
    local rightCorner = Instance.new("UICorner", rightBtn)
    rightCorner.CornerRadius = UDim.new(0, 5)
    
    leftBtn.MouseButton1Click:Connect(function()
        leftBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        rightBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        callback("LeftClick")
    end)
    
    rightBtn.MouseButton1Click:Connect(function()
        rightBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        leftBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        callback("RightClick")
    end)
    
    return frame
end

-- CREATE UI ELEMENTS
local aimBtn = createRedButton("🎯 AIMBOT", false, function(s) 
    config.aimbot.enabled = s
    fovCircle.Visible = s and config.legitAim.showFov
    if not s then lockedTarget, currentTargetPart, isAiming = nil, nil, false end
end)

createMouseSelectionButton("Aimbot Hold Key", aimbotHoldMouseButton, function(selection)
    aimbotHoldMouseButton = selection
end)

createKeybindButton("Aimbot Toggle Key", keybinds.aimbotToggle, function(k) keybinds.aimbotToggle = k; aimbotToggleKey = createKeybindFromString(k); end)
createKeybindButton("Menu Key", keybinds.menuToggle, function(k) keybinds.menuToggle = k; config.menu.menuKey = createKeybindFromString(k); end)

createRedSlider("FOV Radius", 50, 400, 150, function(v) config.legitAim.fovRadius = v; fovCircle.Radius = v end, "px")
createRedSlider("Smoothness", 1, 10, 3, function(v) config.legitAim.smoothness = v end, "")
createRedDropdown("Target Part", {"Head", "UpperTorso", "Torso", "HumanoidRootPart"}, 1, function(v) config.legitAim.targetPart = v end)

local espBtn = createRedButton("👁️ ESP", false, function(s) setEspActive(s) end)
createRedSlider("ESP Max Distance", 50, 2000, 500, function(v) config.esp.maxDistance = v end, "m")

createRedDropdown("ESP Style", {"Chams + Box", "Chams Only", "Box Only"}, 1, function(v)
    if v == "Chams + Box" then config.esp.chamsEnabled, config.esp.boxEnabled = true, true
    elseif v == "Chams Only" then config.esp.chamsEnabled, config.esp.boxEnabled = true, false
    else config.esp.chamsEnabled, config.esp.boxEnabled = false, true end
end)

local healthBtn = createRedButton("❤️ Health Bar", true, function(s) config.esp.healthBarEnabled = s end)
local fovToggle = createRedButton("🔘 Show FOV Circle", true, function(s) config.legitAim.showFov = s; fovCircle.Visible = config.aimbot.enabled and s end)

-- ================================
-- GOLDEN SIDE UI (MOVEMENT + GOLDEN MENU)
-- ================================

local goldenFrame = Instance.new("Frame", gui)
goldenFrame.Size = UDim2.new(0, 260, 0, 600)
goldenFrame.Position = UDim2.new(0.02, 390, 0.5, -300)
goldenFrame.BackgroundColor3 = Color3.fromRGB(80, 60, 0)
goldenFrame.BackgroundTransparency = 0.65
goldenFrame.Active = true
goldenFrame.Draggable = true

local goldenCorner = Instance.new("UICorner", goldenFrame)
goldenCorner.CornerRadius = UDim.new(0, 12)

local goldenBorder = Instance.new("UIStroke", goldenFrame)
goldenBorder.Color = Color3.fromRGB(255, 200, 0)
goldenBorder.Thickness = 2

local goldenTitle = Instance.new("TextLabel", goldenFrame)
goldenTitle.Size = UDim2.new(1, 0, 0, 40)
goldenTitle.Text = "🌟 GOLDEN MENU 🌟"
goldenTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
goldenTitle.BackgroundTransparency = 1
goldenTitle.Font = Enum.Font.GothamBold
goldenTitle.TextSize = 14

local goldenSub = Instance.new("TextLabel", goldenFrame)
goldenSub.Size = UDim2.new(1, 0, 0, 18)
goldenSub.Position = UDim2.new(0, 0, 0, 35)
goldenSub.Text = "Safe Players (No Aimbot/Stick)"
goldenSub.TextColor3 = Color3.fromRGB(200, 180, 100)
goldenSub.BackgroundTransparency = 1
goldenSub.Font = Enum.Font.Gotham
goldenSub.TextSize = 9

local goldenScroll = Instance.new("ScrollingFrame", goldenFrame)
goldenScroll.Size = UDim2.new(1, -20, 1, -70)
goldenScroll.Position = UDim2.new(0, 10, 0, 55)
goldenScroll.BackgroundTransparency = 1
goldenScroll.ScrollBarThickness = 3
goldenScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 0)
goldenScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
goldenScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local goldenLayout = Instance.new("UIListLayout", goldenScroll)
goldenLayout.Padding = UDim.new(0, 6)
goldenLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Golden button creation
local function createGoldenButton(text, initialState, callback)
    local btn = Instance.new("TextButton", goldenScroll)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = initialState and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(80, 60, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        local ns = not initialState
        initialState = ns
        btn.BackgroundColor3 = ns and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(80, 60, 0)
        callback(ns)
    end)
    return btn
end

-- Movement keybinds
local noclipBtn = createGoldenButton("🛡️ NOCLIP", false, function(s) toggleNoclip() end)
createKeybindButton("Noclip Key", keybinds.noclip, function(k) keybinds.noclip = k; noclipKey = createKeybindFromString(k); end)

local flyBtn = createGoldenButton("✈️ FLY", false, function(s) toggleFly() end)
createKeybindButton("Fly Key", keybinds.fly, function(k) keybinds.fly = k; flyKey = createKeybindFromString(k); end)

local infJumpBtn = createGoldenButton("🦘 INFINITE JUMP", false, function(s) toggleInfiniteJump() end)
createKeybindButton("Inf Jump Key", keybinds.infiniteJump, function(k) keybinds.infiniteJump = k; infJumpKey = createKeybindFromString(k); end)

createKeybindButton("Stick to Enemy Key", keybinds.stick, function(k) keybinds.stick = k; stickKey = createKeybindFromString(k); end)

-- Stick Aim Target Dropdown
local stickAimOptions = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"}
local stickAimDropdown = createRedDropdown("Stick Aim Target", stickAimOptions, 1, function(selection)
    stickAimTarget = selection
end)
stickAimDropdown.Parent = goldenScroll

-- Stick distance slider
local distanceFrame = Instance.new("Frame", goldenScroll)
distanceFrame.Size = UDim2.new(1, 0, 0, 55)
distanceFrame.BackgroundTransparency = 1

local distanceLbl = Instance.new("TextLabel", distanceFrame)
distanceLbl.Size = UDim2.new(1, 0, 0, 18)
distanceLbl.Text = "Stick Distance: 4.5 s"
distanceLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceLbl.BackgroundTransparency = 1
distanceLbl.Font = Enum.Font.Gotham
distanceLbl.TextSize = 11
distanceLbl.TextXAlignment = Enum.TextXAlignment.Left

local bg = Instance.new("Frame", distanceFrame)
bg.Size = UDim2.new(1, 0, 0, 18)
bg.Position = UDim2.new(0, 0, 0, 22)
bg.BackgroundColor3 = Color3.fromRGB(60, 45, 0)
bg.BackgroundTransparency = 0.5
local bgCorner = Instance.new("UICorner", bg)
bgCorner.CornerRadius = UDim.new(0, 3)

local fill = Instance.new("Frame", bg)
fill.Size = UDim2.new(0.3, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
local fillCorner = Instance.new("UICorner", fill)
fillCorner.CornerRadius = UDim.new(0, 3)

local knob = Instance.new("TextButton", bg)
knob.Size = UDim2.new(0, 14, 0, 14)
knob.Position = UDim2.new(0.3, -7, 0, 2)
knob.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
knob.Text = ""
local knobCorner = Instance.new("UICorner", knob)
knobCorner.CornerRadius = UDim.new(1, 0)

local valDisp = Instance.new("TextLabel", distanceFrame)
valDisp.Size = UDim2.new(1, 0, 0, 16)
valDisp.Position = UDim2.new(0, 0, 0, 42)
valDisp.Text = "4.5 s"
valDisp.TextColor3 = Color3.fromRGB(255, 200, 100)
valDisp.BackgroundTransparency = 1
valDisp.Font = Enum.Font.Gotham
valDisp.TextSize = 10
valDisp.TextXAlignment = Enum.TextXAlignment.Center

local dragging = false
local minDist = 3
local maxDist = 8

local function updateSliderValue(val)
    local pct = (val - minDist) / (maxDist - minDist)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    knob.Position = UDim2.new(pct, -7, 0, 2)
    valDisp.Text = string.format("%.1f", val) .. " s"
    distanceLbl.Text = "Stick Distance: " .. string.format("%.1f", val) .. " s"
    stickDistance = val
end

updateSliderValue(4.5)

knob.MouseButton1Down:Connect(function() dragging = true end)
UIS.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local mp = UIS:GetMouseLocation()
        local pos = bg.AbsolutePosition
        local sz = bg.AbsoluteSize.X
        local rel = math.clamp(mp.X - pos.X, 0, sz)
        local pct = rel / sz
        local val = minDist + (pct * (maxDist - minDist))
        val = math.clamp(val, minDist, maxDist)
        updateSliderValue(val)
    end
end)

-- Server Players List
local serverListFrame = Instance.new("Frame", goldenScroll)
serverListFrame.Size = UDim2.new(1, 0, 0, 180)
serverListFrame.BackgroundColor3 = Color3.fromRGB(60, 45, 0)
serverListFrame.BackgroundTransparency = 0.3

local serverListCorner = Instance.new("UICorner", serverListFrame)
serverListCorner.CornerRadius = UDim.new(0, 6)

local serverListTitle = Instance.new("TextLabel", serverListFrame)
serverListTitle.Size = UDim2.new(1, 0, 0, 25)
serverListTitle.Text = "👥 SERVER PLAYERS (Click to Add Golden)"
serverListTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
serverListTitle.BackgroundTransparency = 1
serverListTitle.Font = Enum.Font.GothamBold
serverListTitle.TextSize = 10

local serverScroller = Instance.new("ScrollingFrame", serverListFrame)
serverScroller.Size = UDim2.new(1, -10, 1, -35)
serverScroller.Position = UDim2.new(0, 5, 0, 30)
serverScroller.BackgroundTransparency = 1
serverScroller.ScrollBarThickness = 3
serverScroller.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 0)
serverScroller.CanvasSize = UDim2.new(0, 0, 0, 0)

local serverListLayout = Instance.new("UIListLayout", serverScroller)
serverListLayout.Padding = UDim.new(0, 4)
serverListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshServerPlayersList()
    for _, child in pairs(serverScroller:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local playersList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playersList, player)
        end
    end
    
    if #playersList == 0 then
        local emptyLabel = Instance.new("TextLabel", serverScroller)
        emptyLabel.Size = UDim2.new(1, 0, 0, 30)
        emptyLabel.Text = "No other players in server"
        emptyLabel.TextColor3 = Color3.fromRGB(150, 130, 80)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 10
        serverScroller.CanvasSize = UDim2.new(0, 0, 0, 35)
        return
    end
    
    local totalHeight = #playersList * 32
    serverScroller.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    
    for _, player in pairs(playersList) do
        local isGolden = isGoldenPlayer(player)
        
        local itemFrame = Instance.new("Frame", serverScroller)
        itemFrame.Size = UDim2.new(1, 0, 0, 28)
        itemFrame.BackgroundColor3 = isGolden and Color3.fromRGB(100, 80, 20) or Color3.fromRGB(60, 45, 0)
        itemFrame.BackgroundTransparency = 0.3
        
        local itemCorner = Instance.new("UICorner", itemFrame)
        itemCorner.CornerRadius = UDim.new(0, 4)
        
        local nameLabel = Instance.new("TextLabel", itemFrame)
        nameLabel.Size = UDim2.new(0.65, -5, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.Text = (isGolden and "🌟 " or "👤 ") .. (player.DisplayName or player.Name)
        nameLabel.TextColor3 = isGolden and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local addRemoveBtn = Instance.new("TextButton", itemFrame)
        addRemoveBtn.Size = UDim2.new(0.3, -5, 0.8, 0)
        addRemoveBtn.Position = UDim2.new(0.7, 0, 0.1, 0)
        addRemoveBtn.Text = isGolden and "✖ REMOVE" or "➕ ADD GOLDEN"
        addRemoveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        addRemoveBtn.BackgroundColor3 = isGolden and Color3.fromRGB(150, 40, 40) or Color3.fromRGB(0, 130, 0)
        addRemoveBtn.Font = Enum.Font.GothamSemibold
        addRemoveBtn.TextSize = 9
        local btnCorner = Instance.new("UICorner", addRemoveBtn)
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        addRemoveBtn.MouseButton1Click:Connect(function()
            if isGolden then
                for i, name in pairs(goldenPlayers) do
                    if name:lower() == player.Name:lower() then
                        table.remove(goldenPlayers, i)
                        break
                    end
                end
            else
                local found = false
                for _, name in pairs(goldenPlayers) do
                    if name:lower() == player.Name:lower() then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(goldenPlayers, player.Name)
                end
            end
            refreshServerPlayersList()
            refreshGoldenListUI()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then createEspFor(p) end
            end
        end)
    end
end

-- Golden Players List
local goldenListFrame = Instance.new("Frame", goldenScroll)
goldenListFrame.Size = UDim2.new(1, 0, 0, 150)
goldenListFrame.BackgroundColor3 = Color3.fromRGB(60, 45, 0)
goldenListFrame.BackgroundTransparency = 0.5

local goldenListCorner = Instance.new("UICorner", goldenListFrame)
goldenListCorner.CornerRadius = UDim.new(0, 6)

local goldenListTitle = Instance.new("TextLabel", goldenListFrame)
goldenListTitle.Size = UDim2.new(1, 0, 0, 25)
goldenListTitle.Text = "⭐ GOLDEN PLAYERS ⭐"
goldenListTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
goldenListTitle.BackgroundTransparency = 1
goldenListTitle.Font = Enum.Font.GothamBold
goldenListTitle.TextSize = 11

local goldenListScroller = Instance.new("ScrollingFrame", goldenListFrame)
goldenListScroller.Size = UDim2.new(1, -10, 1, -35)
goldenListScroller.Position = UDim2.new(0, 5, 0, 30)
goldenListScroller.BackgroundTransparency = 1
goldenListScroller.ScrollBarThickness = 3
goldenListScroller.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 0)
goldenListScroller.CanvasSize = UDim2.new(0, 0, 0, 0)

local goldenListLayout = Instance.new("UIListLayout", goldenListScroller)
goldenListLayout.Padding = UDim.new(0, 4)
goldenListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshGoldenListUI()
    for _, child in pairs(goldenListScroller:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if #goldenPlayers == 0 then
        local emptyLabel = Instance.new("TextLabel", goldenListScroller)
        emptyLabel.Size = UDim2.new(1, 0, 0, 30)
        emptyLabel.Text = "No golden players yet"
        emptyLabel.TextColor3 = Color3.fromRGB(150, 130, 80)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 10
        goldenListScroller.CanvasSize = UDim2.new(0, 0, 0, 35)
        return
    end
    
    local totalHeight = #goldenPlayers * 32
    goldenListScroller.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    
    for i, playerName in pairs(goldenPlayers) do
        local itemFrame = Instance.new("Frame", goldenListScroller)
        itemFrame.Size = UDim2.new(1, 0, 0, 28)
        itemFrame.BackgroundColor3 = Color3.fromRGB(80, 60, 0)
        itemFrame.BackgroundTransparency = 0.3
        
        local itemCorner = Instance.new("UICorner", itemFrame)
        itemCorner.CornerRadius = UDim.new(0, 4)
        
        local nameLabel = Instance.new("TextLabel", itemFrame)
        nameLabel.Size = UDim2.new(0.7, -5, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.Text = "🌟 " .. playerName
        nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local removeBtn = Instance.new("TextButton", itemFrame)
        removeBtn.Size = UDim2.new(0.25, -5, 0.8, 0)
        removeBtn.Position = UDim2.new(0.75, 0, 0.1, 0)
        removeBtn.Text = "✖"
        removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        removeBtn.Font = Enum.Font.GothamBold
        removeBtn.TextSize = 12
        local removeCorner = Instance.new("UICorner", removeBtn)
        removeCorner.CornerRadius = UDim.new(0, 4)
        
        local index = i
        removeBtn.MouseButton1Click:Connect(function()
            table.remove(goldenPlayers, index)
            refreshGoldenListUI()
            refreshServerPlayersList()
            for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createEspFor(p) end end
        end)
    end
end

-- Username input for adding golden player
local addByNameFrame = Instance.new("Frame", goldenScroll)
addByNameFrame.Size = UDim2.new(1, 0, 0, 45)
addByNameFrame.BackgroundColor3 = Color3.fromRGB(60, 45, 0)
addByNameFrame.BackgroundTransparency = 0.3

local addByNameCorner = Instance.new("UICorner", addByNameFrame)
addByNameCorner.CornerRadius = UDim.new(0, 6)

local nameInput = Instance.new("TextBox", addByNameFrame)
nameInput.Size = UDim2.new(0.65, -5, 0.8, 0)
nameInput.Position = UDim2.new(0, 5, 0.1, 0)
nameInput.PlaceholderText = "Enter username..."
nameInput.Text = ""
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.BackgroundColor3 = Color3.fromRGB(40, 30, 10)
nameInput.Font = Enum.Font.Gotham
nameInput.TextSize = 11
local inputCorner = Instance.new("UICorner", nameInput)
inputCorner.CornerRadius = UDim.new(0, 4)

local addNameBtn = Instance.new("TextButton", addByNameFrame)
addNameBtn.Size = UDim2.new(0.3, -5, 0.8, 0)
addNameBtn.Position = UDim2.new(0.68, 0, 0.1, 0)
addNameBtn.Text = "➕ ADD"
addNameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addNameBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
addNameBtn.Font = Enum.Font.GothamSemibold
addNameBtn.TextSize = 11
local addNameCorner = Instance.new("UICorner", addNameBtn)
addNameCorner.CornerRadius = UDim.new(0, 4)

addNameBtn.MouseButton1Click:Connect(function()
    local name = nameInput.Text
    if name ~= "" then
        local found = false
        for _, n in pairs(goldenPlayers) do
            if n:lower() == name:lower() then found = true break end
        end
        if not found then
            table.insert(goldenPlayers, name)
            refreshGoldenListUI()
            refreshServerPlayersList()
            nameInput.Text = ""
            for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createEspFor(p) end end
        end
    end
end)

-- Fly info
local flyInfo = Instance.new("TextLabel", goldenScroll)
flyInfo.Size = UDim2.new(1, 0, 0, 35)
flyInfo.Text = "💡 Fly Controls:\nWASD + Space (Up) / Shift (Down)"
flyInfo.TextColor3 = Color3.fromRGB(200, 180, 100)
flyInfo.BackgroundTransparency = 1
flyInfo.Font = Enum.Font.Gotham
flyInfo.TextSize = 9
flyInfo.TextWrapped = true

-- Stick info
local stickInfo = Instance.new("TextLabel", goldenScroll)
stickInfo.Size = UDim2.new(1, 0, 0, 35)
stickInfo.Text = "🔪 HOLD STICK KEY to stick to enemy's back!\n   Camera aims at selected body part!"
stickInfo.TextColor3 = Color3.fromRGB(255, 100, 100)
stickInfo.BackgroundTransparency = 1
stickInfo.Font = Enum.Font.GothamBold
stickInfo.TextSize = 10
stickInfo.TextWrapped = true

-- Refresh players list every 2 seconds
task.spawn(function()
    while true do
        task.wait(2)
        pcall(refreshServerPlayersList)
    end
end)

-- Initialize
refreshGoldenListUI()
refreshServerPlayersList()

-- Snow effects
createSnowEffect(mainFrame)
createSnowEffect(goldenFrame)

-- ================================
-- INPUT HANDLING
-- ================================

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    
    if inp.KeyCode == aimbotToggleKey then
        config.aimbot.enabled = not config.aimbot.enabled
        aimBtn.BackgroundColor3 = config.aimbot.enabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(100, 0, 0)
        fovCircle.Visible = config.aimbot.enabled and config.legitAim.showFov
        if not config.aimbot.enabled then lockedTarget, currentTargetPart, isAiming = nil, nil, false end
    end
    
    if inp.KeyCode == noclipKey then toggleNoclip() end
    if inp.KeyCode == flyKey then toggleFly() end
    if inp.KeyCode == infJumpKey then toggleInfiniteJump() end
    if inp.KeyCode == stickKey then startSticking() end
    if inp.KeyCode == config.menu.menuKey then
        mainFrame.Visible = not mainFrame.Visible
        goldenFrame.Visible = not goldenFrame.Visible
    end
end)

UIS.InputEnded:Connect(function(inp, gp)
    if inp.KeyCode == stickKey then stopSticking() end
end)

-- Update FOV circle visibility
RunService.RenderStepped:Connect(function()
    fovCircle.Visible = config.aimbot.enabled and config.legitAim.showFov
end)

print("===================================")
print("ZENTIROG RIVALS SCRIPT LOADED!")
print("RED UI (Aimbot/ESP) + GOLDEN UI (Movement + Safe Players)")
print("===================================")
print("FEATURES:")
print("- Aimbot: Left Click or Right Click selection")
print("- Customizable Keybinds (Click buttons to change)")
print("- Golden Menu: Click players to add/remove from safe list")
print("- HOLD STICK KEY to stick to enemy's back")
print("- STICK AIM TARGET: Choose where to aim (Head, UpperTorso, Torso, RootPart)")
print("- Fly works independently (no auto noclip)")
print("===================================")
