-- GUI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 350, 0, 700) -- Increased height for new button
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -350)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Active = true
mainFrame.Draggable = true

-- Corner for frame
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Border
local border = Instance.new("UIStroke", mainFrame)
border.Color = Color3.fromRGB(0, 170, 255)
border.Thickness = 2

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 60)
title.Text = "Z E N T I R O G"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 24

-- Scrolling frame for buttons
local scrollingFrame = Instance.new("ScrollingFrame", mainFrame)
scrollingFrame.Size = UDim2.new(1, -20, 1, -80)
scrollingFrame.Position = UDim2.new(0, 10, 0, 70)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 0
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 650)
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Layout
local layout = Instance.new("UIListLayout", scrollingFrame)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

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

-- NOCLIP FEATURE
local noclipEnabled = false
local noclipConnection = nil
local noclipDebounce = false

-- INFINITE JUMP FEATURE
local infJumpEnabled = false
local infJumpConnection = nil
local infJumpDebounce = false

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

-- Aimbot activation button choice
local aimbotActivationButton = Enum.UserInputType.MouseButton2

-- Team check for aimbot
local aimbotTeamCheck = true

-- ESP mode selection
local espModes = {"All Players", "Other Teams Only", "Same Team Only"}
local espMode = "All Players"

-- Store ESP instances
local espInstances = {}

-- Create Drawing for FOV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = aimbotFOV
fovCircle.Thickness = 2
fovCircle.NumSides = 60
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Transparency = 0.5
fovCircle.Filled = false

-- Function to update circle position
local function updateCirclePosition()
    fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
end

mouse.Move:Connect(updateCirclePosition)
mouse.Idle:Connect(updateCirclePosition)

-- NOCLIP FUNCTIONS
local function enableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    
    noclipConnection = runService.Stepped:Connect(function()
        if localPlayer.Character then
            for _, child in pairs(localPlayer.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true then
                    child.CanCollide = false
                end
            end
        end
    end)
    
    noclipEnabled = true
    print("🔓 Noclip Enabled (Left CTRL)")
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    noclipEnabled = false
    print("🔒 Noclip Disabled")
end

-- INFINITE JUMP FUNCTIONS
local function enableInfiniteJump()
    if infJumpConnection then
        infJumpConnection:Disconnect()
    end
    
    infJumpDebounce = false
    infJumpConnection = userInputService.JumpRequest:Connect(function()
        if not infJumpDebounce and localPlayer.Character then
            local humanoid = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                infJumpDebounce = true
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait()
                infJumpDebounce = false
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
    infJumpDebounce = false
end

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
    elseif espMode == "Other Teams Only" then
        return isEnemy(player)
    elseif espMode == "Same Team Only" then
        return not isEnemy(player)
    end
    
    return false
end

-- Function to create toggle button
local function createToggleButton(text, initialState, callback)
    local buttonFrame = Instance.new("Frame", scrollingFrame)
    buttonFrame.Size = UDim2.new(1, 0, 0, 45)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 1
    
    local button = Instance.new("TextButton", buttonFrame)
    button.Size = UDim2.new(1, 0, 0, 45)
    button.BackgroundColor3 = initialState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 35)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    
    Instance.new("UICorner", button)
    
    button.MouseButton1Click:Connect(function()
        initialState = not initialState
        button.BackgroundColor3 = initialState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 35)
        callback(initialState)
    end)
    
    return button
end

-- Function to create execution button (for loading external scripts)
local function createExecuteButton(text, url, callback)
    local buttonFrame = Instance.new("Frame", scrollingFrame)
    buttonFrame.Size = UDim2.new(1, 0, 0, 45)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 8
    
    local button = Instance.new("TextButton", buttonFrame)
    button.Size = UDim2.new(1, 0, 0, 45)
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 0) -- Green color
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    
    Instance.new("UICorner", button)
    
    button.MouseButton1Click:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
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
                button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                button.Text = "✅ LOADED!"
                task.wait(1)
                button.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
                button.Text = text
                if callback then callback(true) end
            else
                button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
                button.Text = "❌ ERROR"
                task.wait(1.5)
                button.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
                button.Text = text
                print("Error loading script:", loadResult)
            end
        else
            button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
            button.Text = "❌ FAILED"
            task.wait(1.5)
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
            button.Text = text
            print("Failed to fetch script from URL")
        end
    end)
    
    return button
end

-- Function to create dropdown/option selector
local function createOptionSelector(label, options, defaultIndex, callback)
    local frame = Instance.new("Frame", scrollingFrame)
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 3
    
    local labelText = Instance.new("TextLabel", frame)
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local optionButton = Instance.new("TextButton", frame)
    optionButton.Size = UDim2.new(0.45, 0, 1, 0)
    optionButton.Position = UDim2.new(0.55, 0, 0, 0)
    optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    optionButton.Text = options[defaultIndex]
    optionButton.TextColor3 = Color3.fromRGB(150, 150, 255)
    optionButton.Font = Enum.Font.GothamBold
    
    Instance.new("UICorner", optionButton)
    
    local currentIndex = defaultIndex
    
    optionButton.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        optionButton.Text = options[currentIndex]
        callback(options[currentIndex])
    end)
    
    return frame
end

-- Function to create keybind button
local function createKeybindButton(label, defaultKey, callback)
    local keyFrame = Instance.new("Frame", scrollingFrame)
    keyFrame.Size = UDim2.new(1, 0, 0, 45)
    keyFrame.BackgroundTransparency = 1
    keyFrame.LayoutOrder = 2
    
    local labelText = Instance.new("TextLabel", keyFrame)
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyButton = Instance.new("TextButton", keyFrame)
    keyButton.Size = UDim2.new(0.45, 0, 1, 0)
    keyButton.Position = UDim2.new(0.55, 0, 0, 0)
    keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    keyButton.Text = defaultKey.Name
    keyButton.TextColor3 = Color3.fromRGB(150, 150, 255)
    keyButton.Font = Enum.Font.GothamBold
    
    Instance.new("UICorner", keyButton)
    
    local connection
    
    keyButton.MouseButton1Click:Connect(function()
        if isWaitingForKey then return end
        
        isWaitingForKey = true
        keyButton.Text = "Press any key..."
        keyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        
        if connection then
            connection:Disconnect()
        end
        
        connection = userInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyButton.Text = input.KeyCode.Name
                keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
    buttonFrame.Size = UDim2.new(1, 0, 0, 45)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 5
    
    local label = Instance.new("TextLabel", buttonFrame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = "🔴 Show FOV Circle"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleButton = Instance.new("TextButton", buttonFrame)
    toggleButton.Size = UDim2.new(0.45, 0, 1, 0)
    toggleButton.Position = UDim2.new(0.55, 0, 0, 0)
    toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 35)
    toggleButton.Text = initialState and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    
    Instance.new("UICorner", toggleButton)
    
    toggleButton.MouseButton1Click:Connect(function()
        initialState = not initialState
        toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 35)
        toggleButton.Text = initialState and "ON" or "OFF"
        callback(initialState)
    end)
    
    return toggleButton
end

-- Function to create activation button selector
local function createActivationSelector(initialState, callback)
    local buttonFrame = Instance.new("Frame", scrollingFrame)
    buttonFrame.Size = UDim2.new(1, 0, 0, 45)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 6
    
    local label = Instance.new("TextLabel", buttonFrame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = "🖱️ Aim Button"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local rightClickBtn = Instance.new("TextButton", buttonFrame)
    rightClickBtn.Size = UDim2.new(0.22, 0, 1, 0)
    rightClickBtn.Position = UDim2.new(0.55, 0, 0, 0)
    rightClickBtn.BackgroundColor3 = initialState == Enum.UserInputType.MouseButton2 and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 35)
    rightClickBtn.Text = "Right"
    rightClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightClickBtn.Font = Enum.Font.GothamBold
    
    Instance.new("UICorner", rightClickBtn)
    
    local leftClickBtn = Instance.new("TextButton", buttonFrame)
    leftClickBtn.Size = UDim2.new(0.22, 0, 1, 0)
    leftClickBtn.Position = UDim2.new(0.78, 0, 0, 0)
    leftClickBtn.BackgroundColor3 = initialState == Enum.UserInputType.MouseButton1 and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 35)
    leftClickBtn.Text = "Left"
    leftClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftClickBtn.Font = Enum.Font.GothamBold
    
    Instance.new("UICorner", leftClickBtn)
    
    rightClickBtn.MouseButton1Click:Connect(function()
        rightClickBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        leftClickBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        callback(Enum.UserInputType.MouseButton2)
    end)
    
    leftClickBtn.MouseButton1Click:Connect(function()
        leftClickBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        rightClickBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        callback(Enum.UserInputType.MouseButton1)
    end)
    
    return buttonFrame
end

-- Function to create team check toggle
local function createTeamCheckToggle(initialState, callback)
    local buttonFrame = Instance.new("Frame", scrollingFrame)
    buttonFrame.Size = UDim2.new(1, 0, 0, 45)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 4
    
    local label = Instance.new("TextLabel", buttonFrame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = "⚔️ Team Check"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleButton = Instance.new("TextButton", buttonFrame)
    toggleButton.Size = UDim2.new(0.45, 0, 1, 0)
    toggleButton.Position = UDim2.new(0.55, 0, 0, 0)
    toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 35)
    toggleButton.Text = initialState and "ON (Enemies Only)" or "OFF (All)"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextScaled = true
    toggleButton.TextWrapped = true
    
    Instance.new("UICorner", toggleButton)
    
    toggleButton.MouseButton1Click:Connect(function()
        initialState = not initialState
        toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 35)
        toggleButton.Text = initialState and "ON (Enemies Only)" or "OFF (All)"
        callback(initialState)
    end)
    
    return toggleButton
end

-- Function to create slider
local function createSlider(label, minValue, maxValue, defaultValue, callback, valueSuffix)
    local sliderFrame = Instance.new("Frame", scrollingFrame)
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.LayoutOrder = 7
    
    local labelText = Instance.new("TextLabel", sliderFrame)
    labelText.Size = UDim2.new(1, 0, 0, 20)
    labelText.Text = label .. ": " .. defaultValue .. (valueSuffix or "")
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 14
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame", sliderFrame)
    sliderBg.Size = UDim2.new(1, 0, 0, 20)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 4)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 4)
    
    local sliderButton = Instance.new("TextButton", sliderBg)
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -10, 0, 0)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.ZIndex = 2
    
    Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(1, 0)
    
    local valueDisplay = Instance.new("TextLabel", sliderFrame)
    valueDisplay.Size = UDim2.new(1, 0, 0, 20)
    valueDisplay.Position = UDim2.new(0, 0, 0, 45)
    valueDisplay.Text = "Value: " .. defaultValue .. (valueSuffix or "")
    valueDisplay.TextColor3 = Color3.fromRGB(150, 150, 255)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Font = Enum.Font.Gotham
    valueDisplay.TextSize = 12
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
            sliderButton.Position = UDim2.new(percent, -10, 0, 0)
            valueDisplay.Text = "Value: " .. newValue .. (valueSuffix or "")
            labelText.Text = label .. ": " .. newValue .. (valueSuffix or "")
            
            callback(newValue)
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
        targetGlow.FillColor = Color3.fromRGB(255, 255, 0)
        targetGlow.FillTransparency = 0.7
        targetGlow.OutlineColor = Color3.fromRGB(255, 255, 0)
        targetGlow.OutlineTransparency = 0
        targetGlow.Enabled = false
        
        tweenService:Create(targetGlow, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            FillTransparency = 0.3
        }):Play()
    end
    
    return targetGlow
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
        highlight.OutlineColor = player.TeamColor ~= BrickColor.new("White") and player.TeamColor.Color or Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
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
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
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
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.TextStrokeTransparency = 0.3
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.Text = ""
        
        espInstances[player] = billboard
    end
    
    return billboard
end

-- FIXED: ESP function that NEVER removes outlines
local function updateESP()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer then
            local billboard = espInstances[player]
            local highlight = player.Character and player.Character:FindFirstChild("ESP_Highlight")
            local targetGlow = player.Character and player.Character:FindFirstChild("TargetGlow")
            
            -- ALWAYS create and maintain the outline regardless of ESP state
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                
                if humanoid.Health > 0 then
                    -- ALWAYS create the outline if it doesn't exist
                    if not highlight then
                        highlight = createPlayerOutline(player)
                    end
                    
                    -- ALWAYS update the outline color
                    if highlight then
                        highlight.OutlineColor = player.TeamColor ~= BrickColor.new("White") and player.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                    end
                    
                    -- Handle billboard (text) based on ESP settings
                    if espEnabled and shouldShowESP(player) then
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
                                
                                if player.TeamColor ~= BrickColor.new("White") then
                                    textLabel.TextColor3 = player.TeamColor.Color
                                else
                                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                                    textLabel.TextColor3 = Color3.new(1 - healthPercent, healthPercent, 0)
                                end
                                
                                billboard.Enabled = true
                            end
                        end
                    else
                        -- Disable billboard but KEEP outline
                        if billboard then
                            billboard.Enabled = false
                        end
                    end
                else
                    -- Player is dead - disable billboard but KEEP outline
                    if billboard then
                        billboard.Enabled = false
                    end
                    -- Outline stays (will be visible when they respawn)
                end
            end
            
            -- Target glow is handled separately by aimbot - don't touch it
        end
    end
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
    
    local head = player.Character:FindFirstChild("Head")
    if head then
        local distance = (head.Position - camera.CFrame.Position).Magnitude
        if distance > aimbotMaxDistance then return false end
    end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
    if not rootPart then return false end
    
    return true
end

-- Check if target is on screen
local function isOnScreen(position)
    local screenPoint = camera:WorldToViewportPoint(position)
    return screenPoint.Z > 0
end

-- Get target part function
local function getTargetPart(character)
    local head = character:FindFirstChild("Head")
    if head then return head end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    return rootPart
end

-- Calculate angle between two vectors
local function calculateAngle(vector1, vector2)
    return math.acos(math.clamp(vector1:Dot(vector2) / (vector1.Magnitude * vector2.Magnitude), -1, 1))
end

-- Enhanced aimbot with full camera movement
local function applyAimbot(targetPart)
    if not targetPart then return end
    
    local character = localPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not rootPart then return end
    
    local targetPosition = targetPart.Position
    local currentPosition = camera.CFrame.Position
    
    local newCFrame = CFrame.new(currentPosition, targetPosition)
    camera.CFrame = newCFrame
    
    local characterCFrame = CFrame.new(rootPart.Position, Vector3.new(targetPosition.X, rootPart.Position.Y, targetPosition.Z))
    rootPart.CFrame = characterCFrame
end

-- Create UI elements
local aimbotToggle = createToggleButton("🎯 AIMBOT (ON/OFF)", aimbotEnabled, function(state)
    aimbotEnabled = state
    fovCircle.Visible = state and fovCircleEnabled
    if not state then
        if currentTarget and currentTarget.Character then
            local targetGlow = currentTarget.Character:FindFirstChild("TargetGlow")
            if targetGlow then
                targetGlow.Enabled = false
            end
        end
        currentTarget = nil
    end
end)

createKeybindButton("Aimbot Key (X)", aimbotKey, function(key)
    aimbotKey = key
end)

-- INFINITE JUMP TOGGLE
local infJumpToggle = createToggleButton("🦘 INFINITE JUMP", infJumpEnabled, function(state)
    if state then
        enableInfiniteJump()
    else
        disableInfiniteJump()
    end
end)

-- NOCLIP TOGGLE (Left CTRL)
local noclipToggle = createToggleButton("🚷 NOCLIP (Left CTRL)", noclipEnabled, function(state)
    if state then
        enableNoclip()
    else
        disableNoclip()
    end
end)

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
local fovSlider = createSlider("Aimbot FOV", minFOV, maxFOV, aimbotFOV, function(value)
    aimbotFOV = value
    fovCircle.Radius = value
end, "px")

-- Distance Slider
local distanceSlider = createSlider("Max Distance", minDistance, maxDistance, aimbotMaxDistance, function(value)
    aimbotMaxDistance = value
end, " studs")

local espToggle = createToggleButton("👁️ ESP ALWAYS ACTIVE", espEnabled, function(state)
    espEnabled = state
    updateESP()
end)

-- NEW: Airdrop + NPC Script button
local airdropButton = createExecuteButton("📦 AIRDROP + NPC SCRIPT", "https://raw.githubusercontent.com/zentir0g/ignore/refs/heads/main/jjjjssdsd.lua", function(success)
    if success then
        print("✅ Airdrop + NPC Script loaded successfully!")
    end
end)

-- Main loop
runService.RenderStepped:Connect(function()
    -- Update ESP every frame
    updateESP()
    
    -- Update circle visibility
    fovCircle.Visible = aimbotEnabled and fovCircleEnabled and not isWaitingForKey
    
    -- Check if aiming with selected button
    isAiming = userInputService:IsMouseButtonPressed(aimbotActivationButton)
    
    -- Enhanced aimbot logic
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
        
        -- Update target glow
        if newTarget ~= currentTarget then
            if currentTarget and currentTarget.Character then
                local oldGlow = currentTarget.Character:FindFirstChild("TargetGlow")
                if oldGlow then
                    oldGlow.Enabled = false
                end
            end
            
            if newTarget and newTarget.Character then
                local newGlow = newTarget.Character:FindFirstChild("TargetGlow")
                if not newGlow then
                    newGlow = createTargetGlow(newTarget)
                end
                if newGlow then
                    newGlow.Enabled = true
                end
            end
            
            currentTarget = newTarget
        end
        
        if closestTargetPart then
            applyAimbot(closestTargetPart)
        end
    elseif not isAiming then
        if currentTarget then
            if currentTarget.Character then
                local targetGlow = currentTarget.Character:FindFirstChild("TargetGlow")
                if targetGlow then
                    targetGlow.Enabled = false
                end
            end
            currentTarget = nil
        end
    end
end)

-- Input handling (Left CTRL for noclip toggle)
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if not isWaitingForKey then
        if input.KeyCode == aimbotKey then
            aimbotEnabled = not aimbotEnabled
            aimbotToggle.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 35)
            fovCircle.Visible = aimbotEnabled and fovCircleEnabled
            if not aimbotEnabled then
                if currentTarget and currentTarget.Character then
                    local targetGlow = currentTarget.Character:FindFirstChild("TargetGlow")
                    if targetGlow then
                        targetGlow.Enabled = false
                    end
                end
                currentTarget = nil
            end
            
        elseif input.KeyCode == Enum.KeyCode.LeftControl then
            -- Toggle noclip with Left CTRL
            noclipEnabled = not noclipEnabled
            if noclipEnabled then
                enableNoclip()
            else
                disableNoclip()
            end
            -- Update button color
            noclipToggle.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 35)
            
        elseif input.KeyCode == Enum.KeyCode.Insert then
            showMenu = not showMenu
            mainFrame.Visible = showMenu
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

print("===================================")
print("ZENTIROG LOADED SUCCESSFULLY!")
print("===================================")
print("INSERT key - Show/Hide Menu")
print("X key - Toggle Aimbot")
print("Left CTRL - Toggle Noclip")
print("")
print("✅ NEW BUTTON: Airdrop + NPC Script (Green)")
print("✅ NOCLIP: Left CTRL key to toggle")
print("✅ FIXED: Outlines NEVER disappear!")
print("===================================")
