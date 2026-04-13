-- MAIN UI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 420, 0, 600)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.Active = true
mainFrame.Draggable = true

-- Corner for frame
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

-- Border
local border = Instance.new("UIStroke", mainFrame)
border.Color = Color3.fromRGB(0, 150, 255)
border.Thickness = 1

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "ZENTIROG HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 22

-- Scrolling frame for buttons
local scrollingFrame = Instance.new("ScrollingFrame", mainFrame)
scrollingFrame.Size = UDim2.new(1, -20, 1, -70)
scrollingFrame.Position = UDim2.new(0, 10, 0, 60)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Layout
local layout = Instance.new("UIListLayout", scrollingFrame)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- GOLDEN ESP UI (Separate Window)
local goldenGui = Instance.new("ScreenGui", game.CoreGui)
local goldenFrame = Instance.new("Frame", goldenGui)
goldenFrame.Size = UDim2.new(0, 380, 0, 550)
goldenFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
goldenFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
goldenFrame.Active = true
goldenFrame.Draggable = true
goldenFrame.Visible = true

-- Corner for golden frame
local goldenCorner = Instance.new("UICorner", goldenFrame)
goldenCorner.CornerRadius = UDim.new(0, 10)

-- Border for golden frame
local goldenBorder = Instance.new("UIStroke", goldenFrame)
goldenBorder.Color = Color3.fromRGB(255, 215, 0)
goldenBorder.Thickness = 2

-- Golden title
local goldenTitle = Instance.new("TextLabel", goldenFrame)
goldenTitle.Size = UDim2.new(1, 0, 0, 50)
goldenTitle.Text = "🌟 GOLDEN ESP MANAGER 🌟"
goldenTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
goldenTitle.BackgroundTransparency = 1
goldenTitle.Font = Enum.Font.GothamBold
goldenTitle.TextSize = 18

-- Golden players list container (with UIListLayout for proper stacking)
local goldenListFrame = Instance.new("ScrollingFrame", goldenFrame)
goldenListFrame.Size = UDim2.new(1, -20, 0.65, -70)
goldenListFrame.Position = UDim2.new(0, 10, 0, 60)
goldenListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
goldenListFrame.BackgroundTransparency = 0.5
goldenListFrame.ScrollBarThickness = 6
goldenListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local listCorner = Instance.new("UICorner", goldenListFrame)
listCorner.CornerRadius = UDim.new(0, 8)

-- Create a UIListLayout to automatically stack items vertically
local listLayout = Instance.new("UIListLayout", goldenListFrame)
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Input area for adding players
local inputFrame = Instance.new("Frame", goldenFrame)
inputFrame.Size = UDim2.new(1, -20, 0, 50)
inputFrame.Position = UDim2.new(0, 10, 0.72, 0)
inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)

local inputCorner = Instance.new("UICorner", inputFrame)
inputCorner.CornerRadius = UDim.new(0, 6)

local nameInput = Instance.new("TextBox", inputFrame)
nameInput.Size = UDim2.new(0.65, -5, 1, 0)
nameInput.Position = UDim2.new(0, 5, 0, 0)
nameInput.PlaceholderText = "Enter player name..."
nameInput.Text = ""
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
nameInput.Font = Enum.Font.Gotham
nameInput.TextSize = 12

local inputCorner2 = Instance.new("UICorner", nameInput)
inputCorner2.CornerRadius = UDim.new(0, 4)

local addButton = Instance.new("TextButton", inputFrame)
addButton.Size = UDim2.new(0.3, -5, 1, 0)
addButton.Position = UDim2.new(0.7, 0, 0, 0)
addButton.Text = "➕ ADD"
addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addButton.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
addButton.Font = Enum.Font.GothamSemibold
addButton.TextSize = 12

local addCorner = Instance.new("UICorner", addButton)
addCorner.CornerRadius = UDim.new(0, 4)

-- Stats label
local statsLabel = Instance.new("TextLabel", goldenFrame)
statsLabel.Size = UDim2.new(1, -20, 0, 30)
statsLabel.Position = UDim2.new(0, 10, 0.86, 0)
statsLabel.Text = "Golden players will have GOLD ESP with stars ✨"
statsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statsLabel.BackgroundTransparency = 1
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextSize = 11

-- Services
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()
local tweenService = game:GetService("TweenService")

-- Settings
local showMenu = true
local espEnabled = false
local aimbotEnabled = false
local aimbotKey = Enum.KeyCode.X
local isWaitingForKey = false

-- NOCLIP FEATURE (COMPLETELY FIXED)
local noclipEnabled = false
local noclipConnection = nil
local noclipDebounce = false
local noclipButtonRef = nil -- Store reference to noclip button

local function updateNoclip()
    if noclipEnabled then
        if noclipConnection then return end
        
        noclipConnection = runService.Stepped:Connect(function()
            if localPlayer and localPlayer.Character then
                local character = localPlayer.Character
                pcall(function()
                    for _, child in pairs(character:GetDescendants()) do
                        if child:IsA("BasePart") and child.CanCollide == true then
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
        
        if localPlayer and localPlayer.Character then
            pcall(function()
                for _, child in pairs(localPlayer.Character:GetDescendants()) do
                    if child:IsA("BasePart") then
                        child.CanCollide = true
                    end
                end
            end)
        end
    end
end

local function toggleNoclip()
    if noclipDebounce then return end
    noclipDebounce = true
    
    noclipEnabled = not noclipEnabled
    updateNoclip()
    
    -- Update UI button color
    if noclipButtonRef then
        noclipButtonRef.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(45, 45, 50)
    end
    
    task.wait(0.1)
    noclipDebounce = false
end

-- INFINITE JUMP FEATURE
local infJumpEnabled = false
local infJumpConnection = nil
local infJumpButtonRef = nil

local function enableInfiniteJump()
    if infJumpConnection then
        infJumpConnection:Disconnect()
    end
    
    infJumpConnection = userInputService.JumpRequest:Connect(function()
        if infJumpEnabled then
            local character = localPlayer.Character
            if character then
                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                if humanoid and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
    
    infJumpEnabled = true
end

local function disableInfiniteJump()
    if infJumpConnection then
        infJumpConnection:Disconnect()
        infJumpConnection = nil
    end
    infJumpEnabled = false
end

local function toggleInfiniteJump()
    if infJumpEnabled then
        disableInfiniteJump()
    else
        enableInfiniteJump()
    end
    
    -- Update UI button color
    if infJumpButtonRef then
        infJumpButtonRef.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(45, 45, 50)
    end
end

-- GOLDEN ESP LIST
local goldenESPList = {} -- Stores player names only

-- ESP DISTANCE VOLUME
local espDistanceVolume = 0 -- 0 = all map, >0 = distance limit
local minDistanceVolume = 0
local maxDistanceVolume = 5000

-- AIMBOT FEATURES
local fovCircleEnabled = true
local aimbotFOV = 150
local aimbotMaxDistance = 1000
local minFOV = 50
local maxFOV = 500
local minDistance = 100
local maxDistance = 5000
local currentTarget = nil
local isAiming = false
local aimbotButtonRef = nil
local espButtonRef = nil

-- Aimbot activation button choice
local aimbotActivationButton = Enum.UserInputType.MouseButton2

-- Team check for aimbot
local aimbotTeamCheck = true

-- ESP mode selection
local espModes = {"All Players", "Enemies Only", "Teammates Only"}
local espMode = "All Players"

-- Store ESP instances
local espInstances = {}

-- Create Drawing for FOV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = aimbotFOV
fovCircle.Thickness = 2
fovCircle.NumSides = 60
fovCircle.Color = Color3.fromRGB(0, 200, 255)
fovCircle.Transparency = 0.6
fovCircle.Filled = false

-- Function to update circle position
local function updateCirclePosition()
    fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
end

mouse.Move:Connect(updateCirclePosition)
mouse.Idle:Connect(updateCirclePosition)

-- Team check function
local function isEnemy(player)
    if player == localPlayer then return false end
    
    local myTeam = (localPlayer.Team and localPlayer.Team.Name) or ""
    local theirTeam = (player.Team and player.Team.Name) or ""
    
    if myTeam == "" or myTeam == "Neutral" then
        return true
    end
    
    return myTeam ~= theirTeam
end

-- Function to check if player should be shown in ESP based on mode
local function shouldShowESP(player)
    if player == localPlayer then return false end
    
    if espMode == "All Players" then
        return true
    elseif espMode == "Enemies Only" then
        return isEnemy(player)
    elseif espMode == "Teammates Only" then
        return not isEnemy(player)
    end
    
    return false
end

-- Function to check if player is in golden list
local function isPlayerGolden(player)
    for _, goldenName in pairs(goldenESPList) do
        if player.Name:lower() == goldenName:lower() or (player.DisplayName and player.DisplayName:lower() == goldenName:lower()) then
            return true
        end
    end
    return false
end

-- Function to get ESP color for a player
local function getESPColor(player)
    -- First check if player should be shown based on ESP mode
    if not shouldShowESP(player) then
        return nil
    end
    
    -- Check if player is golden
    if isPlayerGolden(player) then
        return Color3.fromRGB(255, 215, 0) -- Gold color
    end
    
    -- Return team color or default
    if player.TeamColor and player.TeamColor ~= BrickColor.new("White") then
        return player.TeamColor.Color
    end
    
    -- Default white
    return Color3.fromRGB(255, 255, 255)
end

-- Function to check distance limit
local function isWithinDistance(player)
    if espDistanceVolume == 0 then
        return true
    end
    
    if player.Character and player.Character:FindFirstChild("Head") then
        local distance = (player.Character.Head.Position - camera.CFrame.Position).Magnitude
        return distance <= espDistanceVolume
    end
    
    return false
end

-- ESP functions
local function createPlayerOutline(player)
    if not player.Character then return end
    
    local character = player.Character
    local highlight = character:FindFirstChild("ESP_Highlight")
    
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Parent = character
        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
        highlight.Enabled = true
    end
    
    return highlight
end

local function createESP(player)
    if not player.Character or not player.Character:FindFirstChild("Head") then 
        if espInstances[player] then
            local old = espInstances[player]
            if old and old.Parent then
                old:Destroy()
            end
            espInstances[player] = nil
        end
        return nil 
    end
    
    local head = player.Character.Head
    local billboard = head:FindFirstChild("ESP_Billboard")
    
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"
        billboard.Parent = head
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = head
        billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        billboard.Enabled = espEnabled
        billboard.ClipsDescendants = false
        billboard.ResetOnSpawn = false
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "ESP_Text"
        textLabel.Parent = billboard
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.GothamSemibold
        textLabel.TextSize = 11
        textLabel.TextStrokeTransparency = 0.4
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.Text = ""
        
        espInstances[player] = billboard
    end
    
    return billboard
end

-- ESP update function
local function updateESP()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer then
            local billboard = espInstances[player]
            local highlight = player.Character and player.Character:FindFirstChild("ESP_Highlight")
            
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                
                if humanoid.Health > 0 then
                    local shouldShow = espEnabled and shouldShowESP(player)
                    local withinDistance = isWithinDistance(player)
                    
                    if shouldShow and withinDistance then
                        -- Get the color for this player (golden or team color)
                        local espColor = getESPColor(player)
                        
                        if espColor then
                            -- Create/update outline
                            if not highlight then
                                highlight = createPlayerOutline(player)
                            end
                            
                            if highlight then
                                highlight.OutlineColor = espColor
                                highlight.Enabled = true
                            end
                            
                            -- Create/update billboard
                            billboard = createESP(player)
                            
                            if billboard then
                                local textLabel = billboard:FindFirstChild("ESP_Text")
                                if textLabel then
                                    local head = player.Character.Head
                                    local distance = math.floor((head.Position - camera.CFrame.Position).Magnitude)
                                    local health = math.floor(humanoid.Health)
                                    local maxHealth = math.floor(humanoid.MaxHealth)
                                    local displayName = player.DisplayName or player.Name
                                    
                                    textLabel.Text = displayName .. " | " .. health .. "/" .. maxHealth .. " HP | " .. distance .. "m"
                                    textLabel.TextColor3 = espColor
                                    
                                    -- Add star for golden players
                                    if espColor == Color3.fromRGB(255, 215, 0) then
                                        textLabel.Text = "🌟 " .. textLabel.Text .. " 🌟"
                                    end
                                    
                                    billboard.Enabled = true
                                end
                            end
                        end
                    else
                        -- Remove ESP if not needed
                        if highlight then
                            highlight:Destroy()
                        end
                        if billboard then
                            billboard:Destroy()
                            espInstances[player] = nil
                        end
                    end
                else
                    -- Player is dead, remove ESP
                    if highlight then
                        highlight:Destroy()
                    end
                    if billboard then
                        billboard:Destroy()
                        espInstances[player] = nil
                    end
                end
            else
                if highlight then
                    highlight:Destroy()
                end
                if billboard then
                    billboard:Destroy()
                    espInstances[player] = nil
                end
            end
        end
    end
end

-- Function to update stats label
local function updateStatsLabel()
    local count = #goldenESPList
    if count == 0 then
        statsLabel.Text = "No golden players yet ✨ Add your first player above!"
    elseif count == 1 then
        statsLabel.Text = "✨ 1 golden player | Gold ESP with stars ✨"
    else
        statsLabel.Text = "✨ " .. count .. " golden players | All have gold ESP with stars ✨"
    end
end

-- Function to refresh the golden list UI
local function refreshGoldenListUI()
    -- Clear existing items
    for _, child in pairs(goldenListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if #goldenESPList == 0 then
        -- Show empty state
        local emptyFrame = Instance.new("Frame", goldenListFrame)
        emptyFrame.Size = UDim2.new(1, -10, 0, 80)
        emptyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        emptyFrame.BackgroundTransparency = 0.3
        
        local emptyCorner = Instance.new("UICorner", emptyFrame)
        emptyCorner.CornerRadius = UDim.new(0, 8)
        
        local emptyLabel = Instance.new("TextLabel", emptyFrame)
        emptyLabel.Size = UDim2.new(1, 0, 1, 0)
        emptyLabel.Text = "✨ No golden players yet ✨\n\nAdd players above to make their ESP golden!"
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 12
        emptyLabel.TextWrapped = true
        
        updateStatsLabel()
        
        -- Update canvas size
        goldenListFrame.CanvasSize = UDim2.new(0, 0, 0, 90)
        return
    end
    
    -- Add each golden player as a list item (they will stack automatically due to UIListLayout)
    for i, playerName in pairs(goldenESPList) do
        local itemFrame = Instance.new("Frame", goldenListFrame)
        itemFrame.Size = UDim2.new(1, -10, 0, 50)
        itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        
        local itemCorner = Instance.new("UICorner", itemFrame)
        itemCorner.CornerRadius = UDim.new(0, 6)
        
        -- Player name with star
        local nameLabel = Instance.new("TextLabel", itemFrame)
        nameLabel.Size = UDim2.new(0.65, -5, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.Text = "🌟 " .. playerName
        nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        
        -- Remove button
        local removeButton = Instance.new("TextButton", itemFrame)
        removeButton.Size = UDim2.new(0.28, -5, 0.7, 0)
        removeButton.Position = UDim2.new(0.72, 0, 0.15, 0)
        removeButton.Text = "✖ REMOVE"
        removeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        removeButton.Font = Enum.Font.GothamSemibold
        removeButton.TextSize = 11
        
        local removeCorner = Instance.new("UICorner", removeButton)
        removeCorner.CornerRadius = UDim.new(0, 4)
        
        local index = i
        removeButton.MouseButton1Click:Connect(function()
            table.remove(goldenESPList, index)
            refreshGoldenListUI()
            updateESP()
        end)
    end
    
    -- Update stats label
    updateStatsLabel()
    
    -- Update canvas size (UIListLayout handles positioning, we just need enough canvas height)
    local totalHeight = #goldenESPList * 56
    goldenListFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

-- Add button click handler
addButton.MouseButton1Click:Connect(function()
    local playerName = nameInput.Text
    if playerName and playerName ~= "" then
        -- Check if already in list
        local found = false
        for _, name in pairs(goldenESPList) do
            if name:lower() == playerName:lower() then
                found = true
                break
            end
        end
        
        if not found then
            table.insert(goldenESPList, playerName)
            refreshGoldenListUI()
            updateESP()
            nameInput.Text = ""
            addButton.Text = "✓ ADDED"
            addButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            task.wait(0.5)
            addButton.Text = "➕ ADD"
            addButton.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
        else
            addButton.Text = "⚠ ALREADY EXISTS"
            addButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
            task.wait(1)
            addButton.Text = "➕ ADD"
            addButton.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
        end
    else
        addButton.Text = "⚠ ENTER A NAME"
        addButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        task.wait(1)
        addButton.Text = "➕ ADD"
        addButton.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    end
end)

-- Function to create normal sized button (FIXED - returns button for color control)
local function createNormalButton(text, initialState, callback)
    local buttonFrame = Instance.new("Frame", scrollingFrame)
    buttonFrame.Size = UDim2.new(1, 0, 0, 35)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 1
    
    local button = Instance.new("TextButton", buttonFrame)
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = initialState and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(45, 45, 50)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    
    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    button.MouseButton1Click:Connect(function()
        local newState = not initialState
        initialState = newState
        button.BackgroundColor3 = newState and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(45, 45, 50)
        callback(newState)
    end)
    
    return button
end

-- Function to create execution button
local function createExecuteButton(text, url, callback)
    local buttonFrame = Instance.new("Frame", scrollingFrame)
    buttonFrame.Size = UDim2.new(1, 0, 0, 35)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 11
    
    local button = Instance.new("TextButton", buttonFrame)
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(0, 110, 60)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    
    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    button.MouseButton1Click:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(0, 80, 45)
        button.Text = "LOADING..."
        task.wait(0.1)
        
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success and result then
            local loadSuccess, loadResult = pcall(function()
                loadstring(result)()
            end)
            
            if loadSuccess then
                button.BackgroundColor3 = Color3.fromRGB(0, 140, 80)
                button.Text = "✓ LOADED!"
                task.wait(1)
                button.BackgroundColor3 = Color3.fromRGB(0, 110, 60)
                button.Text = text
                if callback then callback(true) end
            else
                button.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
                button.Text = "✗ ERROR"
                task.wait(1.5)
                button.BackgroundColor3 = Color3.fromRGB(0, 110, 60)
                button.Text = text
            end
        else
            button.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
            button.Text = "✗ FAILED"
            task.wait(1.5)
            button.BackgroundColor3 = Color3.fromRGB(0, 110, 60)
            button.Text = text
        end
    end)
    
    return button
end

-- Function to create dropdown/option selector
local function createOptionSelector(label, options, defaultIndex, callback)
    local frame = Instance.new("Frame", scrollingFrame)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 3
    
    local labelText = Instance.new("TextLabel", frame)
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local optionButton = Instance.new("TextButton", frame)
    optionButton.Size = UDim2.new(0.45, 0, 0.9, 0)
    optionButton.Position = UDim2.new(0.55, 0, 0.05, 0)
    optionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    optionButton.Text = options[defaultIndex]
    optionButton.TextColor3 = Color3.fromRGB(0, 170, 255)
    optionButton.Font = Enum.Font.GothamSemibold
    optionButton.TextSize = 12
    
    local btnCorner = Instance.new("UICorner", optionButton)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    local currentIndex = defaultIndex
    
    optionButton.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        optionButton.Text = options[currentIndex]
        callback(options[currentIndex])
        updateESP()
    end)
    
    return frame
end

-- Function to create keybind button
local function createKeybindButton(label, defaultKey, callback)
    local keyFrame = Instance.new("Frame", scrollingFrame)
    keyFrame.Size = UDim2.new(1, 0, 0, 40)
    keyFrame.BackgroundTransparency = 1
    keyFrame.LayoutOrder = 2
    
    local labelText = Instance.new("TextLabel", keyFrame)
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyButton = Instance.new("TextButton", keyFrame)
    keyButton.Size = UDim2.new(0.45, 0, 0.9, 0)
    keyButton.Position = UDim2.new(0.55, 0, 0.05, 0)
    keyButton.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    keyButton.Text = defaultKey.Name
    keyButton.TextColor3 = Color3.fromRGB(0, 170, 255)
    keyButton.Font = Enum.Font.GothamSemibold
    keyButton.TextSize = 12
    
    local btnCorner = Instance.new("UICorner", keyButton)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    local connection
    
    keyButton.MouseButton1Click:Connect(function()
        if isWaitingForKey then return end
        
        isWaitingForKey = true
        keyButton.Text = "..."
        keyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        
        if connection then
            connection:Disconnect()
        end
        
        connection = userInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyButton.Text = input.KeyCode.Name
                keyButton.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
                callback(input.KeyCode)
                
                isWaitingForKey = false
                connection:Disconnect()
            end
        end)
    end)
    
    return keyButton
end

-- Function to create toggle for FOV circle
local function createFOVCircleToggle(initialState, callback)
    local buttonFrame = Instance.new("Frame", scrollingFrame)
    buttonFrame.Size = UDim2.new(1, 0, 0, 35)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 6
    
    local label = Instance.new("TextLabel", buttonFrame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = "FOV Circle"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleButton = Instance.new("TextButton", buttonFrame)
    toggleButton.Size = UDim2.new(0.45, 0, 0.9, 0)
    toggleButton.Position = UDim2.new(0.55, 0, 0.05, 0)
    toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(45, 45, 50)
    toggleButton.Text = initialState and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamSemibold
    toggleButton.TextSize = 12
    
    local btnCorner = Instance.new("UICorner", toggleButton)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    toggleButton.MouseButton1Click:Connect(function()
        initialState = not initialState
        toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(45, 45, 50)
        toggleButton.Text = initialState and "ON" or "OFF"
        callback(initialState)
    end)
    
    return toggleButton
end

-- Function to create activation button selector
local function createActivationSelector(initialState, callback)
    local buttonFrame = Instance.new("Frame", scrollingFrame)
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 7
    
    local label = Instance.new("TextLabel", buttonFrame)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = "Aim Button"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local rightClickBtn = Instance.new("TextButton", buttonFrame)
    rightClickBtn.Size = UDim2.new(0.25, 0, 0.9, 0)
    rightClickBtn.Position = UDim2.new(0.55, 0, 0.05, 0)
    rightClickBtn.BackgroundColor3 = initialState == Enum.UserInputType.MouseButton2 and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(55, 55, 60)
    rightClickBtn.Text = "Right"
    rightClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightClickBtn.Font = Enum.Font.GothamSemibold
    rightClickBtn.TextSize = 12
    
    local btnCorner1 = Instance.new("UICorner", rightClickBtn)
    btnCorner1.CornerRadius = UDim.new(0, 5)
    
    local leftClickBtn = Instance.new("TextButton", buttonFrame)
    leftClickBtn.Size = UDim2.new(0.25, 0, 0.9, 0)
    leftClickBtn.Position = UDim2.new(0.82, 0, 0.05, 0)
    leftClickBtn.BackgroundColor3 = initialState == Enum.UserInputType.MouseButton1 and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(55, 55, 60)
    leftClickBtn.Text = "Left"
    leftClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftClickBtn.Font = Enum.Font.GothamSemibold
    leftClickBtn.TextSize = 12
    
    local btnCorner2 = Instance.new("UICorner", leftClickBtn)
    btnCorner2.CornerRadius = UDim.new(0, 5)
    
    rightClickBtn.MouseButton1Click:Connect(function()
        rightClickBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
        leftClickBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
        callback(Enum.UserInputType.MouseButton2)
    end)
    
    leftClickBtn.MouseButton1Click:Connect(function()
        leftClickBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
        rightClickBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
        callback(Enum.UserInputType.MouseButton1)
    end)
    
    return buttonFrame
end

-- Function to create team check toggle
local function createTeamCheckToggle(initialState, callback)
    local buttonFrame = Instance.new("Frame", scrollingFrame)
    buttonFrame.Size = UDim2.new(1, 0, 0, 35)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 5
    
    local label = Instance.new("TextLabel", buttonFrame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = "Team Check"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleButton = Instance.new("TextButton", buttonFrame)
    toggleButton.Size = UDim2.new(0.45, 0, 0.9, 0)
    toggleButton.Position = UDim2.new(0.55, 0, 0.05, 0)
    toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(45, 45, 50)
    toggleButton.Text = initialState and "Enemies" or "All"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamSemibold
    toggleButton.TextSize = 12
    
    local btnCorner = Instance.new("UICorner", toggleButton)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    toggleButton.MouseButton1Click:Connect(function()
        initialState = not initialState
        toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(45, 45, 50)
        toggleButton.Text = initialState and "Enemies" or "All"
        callback(initialState)
        updateESP()
    end)
    
    return toggleButton
end

-- Function to create slider
local function createSlider(label, minValue, maxValue, defaultValue, callback, valueSuffix)
    local sliderFrame = Instance.new("Frame", scrollingFrame)
    sliderFrame.Size = UDim2.new(1, 0, 0, 55)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.LayoutOrder = 8
    
    local labelText = Instance.new("TextLabel", sliderFrame)
    labelText.Size = UDim2.new(1, 0, 0, 20)
    labelText.Text = label .. ": " .. defaultValue .. (valueSuffix or "")
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame", sliderFrame)
    sliderBg.Size = UDim2.new(1, 0, 0, 20)
    sliderBg.Position = UDim2.new(0, 0, 0, 22)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    
    local bgCorner = Instance.new("UICorner", sliderBg)
    bgCorner.CornerRadius = UDim.new(0, 3)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    
    local fillCorner = Instance.new("UICorner", sliderFill)
    fillCorner.CornerRadius = UDim.new(0, 3)
    
    local sliderButton = Instance.new("TextButton", sliderBg)
    sliderButton.Size = UDim2.new(0, 18, 0, 18)
    sliderButton.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -9, 0, 1)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.ZIndex = 2
    
    local btnCorner = Instance.new("UICorner", sliderButton)
    btnCorner.CornerRadius = UDim.new(1, 0)
    
    local valueDisplay = Instance.new("TextLabel", sliderFrame)
    valueDisplay.Size = UDim2.new(1, 0, 0, 18)
    valueDisplay.Position = UDim2.new(0, 0, 0, 44)
    valueDisplay.Text = defaultValue .. (valueSuffix or "")
    valueDisplay.TextColor3 = Color3.fromRGB(0, 170, 255)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Font = Enum.Font.Gotham
    valueDisplay.TextSize = 11
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Center
    
    local dragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = userInputService:GetMouseLocation()
            local sliderPos = sliderBg.AbsolutePosition
            local sliderSize = sliderBg.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize)
            local percent = relativeX / sliderSize
            local newValue = math.floor(minValue + (percent * (maxValue - minValue)))
            newValue = math.clamp(newValue, minValue, maxValue)
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -9, 0, 1)
            valueDisplay.Text = newValue .. (valueSuffix or "")
            labelText.Text = label .. ": " .. newValue .. (valueSuffix or "")
            
            callback(newValue)
        end
    end)
    
    return sliderFrame
end

-- Function to create distance volume slider
local function createDistanceVolumeSlider()
    local sliderFrame = Instance.new("Frame", scrollingFrame)
    sliderFrame.Size = UDim2.new(1, 0, 0, 55)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.LayoutOrder = 9
    
    local labelText = Instance.new("TextLabel", sliderFrame)
    labelText.Size = UDim2.new(1, 0, 0, 20)
    local distanceText = espDistanceVolume == 0 and "All Map" or espDistanceVolume .. " studs"
    labelText.Text = "ESP Distance: " .. distanceText
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame", sliderFrame)
    sliderBg.Size = UDim2.new(1, 0, 0, 20)
    sliderBg.Position = UDim2.new(0, 0, 0, 22)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    
    local bgCorner = Instance.new("UICorner", sliderBg)
    bgCorner.CornerRadius = UDim.new(0, 3)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    local percent = espDistanceVolume == 0 and 1 or espDistanceVolume / maxDistanceVolume
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    
    local fillCorner = Instance.new("UICorner", sliderFill)
    fillCorner.CornerRadius = UDim.new(0, 3)
    
    local sliderButton = Instance.new("TextButton", sliderBg)
    sliderButton.Size = UDim2.new(0, 18, 0, 18)
    sliderButton.Position = UDim2.new(percent, -9, 0, 1)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.ZIndex = 2
    
    local btnCorner = Instance.new("UICorner", sliderButton)
    btnCorner.CornerRadius = UDim.new(1, 0)
    
    local valueDisplay = Instance.new("TextLabel", sliderFrame)
    valueDisplay.Size = UDim2.new(1, 0, 0, 18)
    valueDisplay.Position = UDim2.new(0, 0, 0, 44)
    valueDisplay.Text = espDistanceVolume == 0 and "∞ (All Map)" or espDistanceVolume .. " studs"
    valueDisplay.TextColor3 = Color3.fromRGB(0, 170, 255)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Font = Enum.Font.Gotham
    valueDisplay.TextSize = 11
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Center
    
    local dragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = userInputService:GetMouseLocation()
            local sliderPos = sliderBg.AbsolutePosition
            local sliderSize = sliderBg.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize)
            local percent = relativeX / sliderSize
            local newValue = math.floor(minDistanceVolume + (percent * (maxDistanceVolume - minDistanceVolume)))
            newValue = math.clamp(newValue, minDistanceVolume, maxDistanceVolume)
            
            if newValue == 0 then
                espDistanceVolume = 0
                valueDisplay.Text = "∞ (All Map)"
                labelText.Text = "ESP Distance: All Map"
            else
                espDistanceVolume = newValue
                valueDisplay.Text = espDistanceVolume .. " studs"
                labelText.Text = "ESP Distance: " .. espDistanceVolume .. " studs"
            end
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -9, 0, 1)
            
            updateESP()
        end
    end)
    
    return sliderFrame
end

-- Yellow glow for targeted player
local function createTargetGlow(player)
    if not player.Character then return end
    
    local character = player.Character
    local targetGlow = character:FindFirstChild("TargetGlow")
    
    if not targetGlow then
        targetGlow = Instance.new("Highlight")
        targetGlow.Name = "TargetGlow"
        targetGlow.Parent = character
        targetGlow.Adornee = character
        targetGlow.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        targetGlow.FillColor = Color3.fromRGB(255, 100, 0)
        targetGlow.FillTransparency = 0.5
        targetGlow.OutlineColor = Color3.fromRGB(255, 150, 0)
        targetGlow.OutlineTransparency = 0
        targetGlow.Enabled = true
        
        tweenService:Create(targetGlow, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            FillTransparency = 0.3
        }):Play()
    end
    
    return targetGlow
end

-- Target validation function with team check
local function isValidTarget(player)
    if player == localPlayer then return false end
    if not player.Character then return false end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    if aimbotTeamCheck and not isEnemy(player) then
        return false
    end
    
    local upperTorso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
    if upperTorso then
        local distance = (upperTorso.Position - camera.CFrame.Position).Magnitude
        if distance > aimbotMaxDistance then return false end
    end
    
    return true
end

-- Check if target is on screen
local function isOnScreen(position)
    local screenPoint = camera:WorldToViewportPoint(position)
    return screenPoint.Z > 0
end

-- Get target part (Upper Torso only)
local function getTargetPart(character)
    local upperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    return upperTorso
end

-- Calculate angle between two vectors
local function calculateAngle(vector1, vector2)
    return math.acos(math.clamp(vector1:Dot(vector2) / (vector1.Magnitude * vector2.Magnitude), -1, 1))
end

-- Enhanced aimbot with upper torso targeting
local function applyAimbot(targetPart)
    if not targetPart then return end
    
    local character = localPlayer.Character
    if not character then return end
    
    local targetPosition = targetPart.Position
    local currentPosition = camera.CFrame.Position
    
    local newCFrame = CFrame.new(currentPosition, targetPosition)
    camera.CFrame = newCFrame
end

-- Create UI elements for main window
local aimbotButton = createNormalButton("AIMBOT (Upper Torso)", aimbotEnabled, function(state)
    aimbotEnabled = state
    fovCircle.Visible = state and fovCircleEnabled
    if not state then
        if currentTarget and currentTarget.Character then
            local targetGlow = currentTarget.Character:FindFirstChild("TargetGlow")
            if targetGlow then
                targetGlow:Destroy()
            end
        end
        currentTarget = nil
    end
end)
aimbotButtonRef = aimbotButton

createKeybindButton("Aimbot Key", aimbotKey, function(key)
    aimbotKey = key
end)

-- INFINITE JUMP TOGGLE
local infJumpButton = createNormalButton("INFINITE JUMP (Left Alt)", infJumpEnabled, function(state)
    if state then
        enableInfiniteJump()
    else
        disableInfiniteJump()
    end
end)
infJumpButtonRef = infJumpButton

-- NOCLIP TOGGLE (FIXED)
local noclipButton = createNormalButton("NOCLIP (Left Ctrl)", noclipEnabled, function(state)
    toggleNoclip()
end)
noclipButtonRef = noclipButton

-- ESP Mode selector
createOptionSelector("ESP Mode", espModes, 1, function(mode)
    espMode = mode
    updateESP()
end)

-- Team Check toggle for aimbot
local teamCheckToggle = createTeamCheckToggle(aimbotTeamCheck, function(state)
    aimbotTeamCheck = state
end)

-- FOV Circle Toggle
local fovCircleToggle = createFOVCircleToggle(fovCircleEnabled, function(state)
    fovCircleEnabled = state
    fovCircle.Visible = aimbotEnabled and state
end)

-- Activation Button selector
createActivationSelector(aimbotActivationButton, function(button)
    aimbotActivationButton = button
end)

-- FOV Slider
local fovSlider = createSlider("FOV", minFOV, maxFOV, aimbotFOV, function(value)
    aimbotFOV = value
    fovCircle.Radius = value
end, "px")

-- Distance Slider (for aimbot)
local distanceSlider = createSlider("Aimbot Distance", minDistance, maxDistance, aimbotMaxDistance, function(value)
    aimbotMaxDistance = value
end, "s")

-- ESP Distance Volume Slider
local espDistanceSlider = createDistanceVolumeSlider()

local espButton = createNormalButton("ESP", espEnabled, function(state)
    espEnabled = state
    updateESP()
end)
espButtonRef = espButton

-- Airdrop + NPC Script button
local airdropButton = createExecuteButton("📦 Airdrop + NPC Script", "https://raw.githubusercontent.com/zentir0g/ignore/refs/heads/main/jjjjssdsd.lua", function(success)
    if success then
        print("✅ Airdrop + NPC Script loaded!")
    end
end)

-- Main loop
runService.RenderStepped:Connect(function()
    updateESP()
    
    fovCircle.Visible = aimbotEnabled and fovCircleEnabled and not isWaitingForKey
    
    isAiming = userInputService:IsMouseButtonPressed(aimbotActivationButton)
    
    if not isWaitingForKey and aimbotEnabled and isAiming then
        local closestTarget = nil
        local closestTargetPart = nil
        local closestValue = math.huge
        local screenCenter = Vector2.new(mouse.X, mouse.Y)
        local cameraDirection = camera.CFrame.LookVector
        local newTarget = nil
        
        for _, player in pairs(players:GetPlayers()) do
            if isValidTarget(player) then
                local targetPart = getTargetPart(player.Character)
                if targetPart then
                    local targetPosition = targetPart.Position
                    
                    if isOnScreen(targetPosition) then
                        if fovCircleEnabled then
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPosition)
                            
                            if onScreen then
                                local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                
                                if distanceFromCenter < aimbotFOV then
                                    if distanceFromCenter < closestValue then
                                        closestValue = distanceFromCenter
                                        closestTarget = player
                                        closestTargetPart = targetPart
                                        newTarget = player
                                    end
                                end
                            end
                        else
                            local directionToTarget = (targetPosition - camera.CFrame.Position).Unit
                            local angle = calculateAngle(cameraDirection, directionToTarget)
                            local angleDegrees = math.deg(angle)
                            
                            if angleDegrees < 90 and angleDegrees < closestValue then
                                closestValue = angleDegrees
                                closestTarget = player
                                closestTargetPart = targetPart
                                newTarget = player
                            end
                        end
                    end
                end
            end
        end
        
        if newTarget ~= currentTarget then
            if currentTarget and currentTarget.Character then
                local oldGlow = currentTarget.Character:FindFirstChild("TargetGlow")
                if oldGlow then
                    oldGlow:Destroy()
                end
            end
            
            if newTarget and newTarget.Character then
                local newGlow = createTargetGlow(newTarget)
                if newGlow then
                    newGlow.Enabled = true
                end
            end
            
            currentTarget = newTarget
        end
        
        if closestTargetPart then
            applyAimbot(closestTargetPart)
        end
    elseif not isAiming and currentTarget then
        if currentTarget and currentTarget.Character then
            local targetGlow = currentTarget.Character:FindFirstChild("TargetGlow")
            if targetGlow then
                targetGlow:Destroy()
            end
        end
        currentTarget = nil
    end
end)

-- Input handling for both windows
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if not isWaitingForKey then
        if input.KeyCode == aimbotKey then
            aimbotEnabled = not aimbotEnabled
            if aimbotButtonRef then
                aimbotButtonRef.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 130, 220) or Color3.fromRGB(45, 45, 50)
            end
            fovCircle.Visible = aimbotEnabled and fovCircleEnabled
            if not aimbotEnabled then
                if currentTarget and currentTarget.Character then
                    local targetGlow = currentTarget.Character:FindFirstChild("TargetGlow")
                    if targetGlow then
                        targetGlow:Destroy()
                    end
                end
                currentTarget = nil
            end
            
        elseif input.KeyCode == Enum.KeyCode.LeftControl then
            toggleNoclip()
            
        elseif input.KeyCode == Enum.KeyCode.LeftAlt then
            toggleInfiniteJump()
            
        elseif input.KeyCode == Enum.KeyCode.Insert then
            showMenu = not showMenu
            mainFrame.Visible = showMenu
            goldenFrame.Visible = showMenu
        end
    end
end)

-- Clean up
players.PlayerRemoving:Connect(function(player)
    if espInstances[player] then
        local billboard = espInstances[player]
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
        espInstances[player] = nil
    end
    
    if player.Character then
        local espHighlight = player.Character:FindFirstChild("ESP_Highlight")
        if espHighlight then
            espHighlight:Destroy()
        end
        
        local targetGlow = player.Character:FindFirstChild("TargetGlow")
        if targetGlow then
            targetGlow:Destroy()
        end
    end
    
    if currentTarget == player then
        currentTarget = nil
    end
end)

-- Character added handling
localPlayer.CharacterAdded:Connect(function()
    if infJumpEnabled then
        task.wait(0.5)
        enableInfiniteJump()
    end
    -- Reset noclip state on character respawn
    if noclipEnabled then
        task.wait(0.5)
        updateNoclip()
    end
end)

players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        updateESP()
    end)
end)

-- Initial update
task.wait(1)
updateESP()
refreshGoldenListUI()

print("===================================")
print("ZENTIROG HUB LOADED!")
print("===================================")
