-- Brainrot Auto Steal Script
-- Creado para Steal a Brainrot
-- Funcionalidades: Auto-steal, ESP, Velocidad, Bypass, Interfaz moderna

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local random = Random.new()

--// Configuration
local DEBUG = false
local tpAmt
local void = CFrame.new(0, -3.4028234663852886e+38, 0)
local teleporting

--// Script Settings
local Settings = {
    AutoSteal = false,
    ESP = false,
    PlayerESP = false,
    BaseESP = false,
    Speed = false,
    SpeedValue = 50,
    Bypass = true,
    AutoRejoin = false
}

local function DebugInfo(mode, content, value)
    if not DEBUG then return end
    if mode == "warn" then
        warn("[BrainrotScript DEBUG]:", content, value or "")
    elseif mode == "print" then
        print("[BrainrotScript DEBUG]:", content, value or "")
    else
        warn("[BrainrotScript DEBUG]: Invalid debug type.")
    end
end

--// Player & Character setup
local backpack = player:WaitForChild("Backpack")
local char, humanoid, hrp

local function GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function SetupCharacter()
    char = GetCharacter()
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    backpack = player:WaitForChild("Backpack")
    DebugInfo("print", "Character setup completed for", player.Name)
end

SetupCharacter()

player.CharacterAdded:Connect(function()
    SetupCharacter()
end)

--// Calculate tpAmt from Latency
task.spawn(function()
    while true do
        local ping = player:GetNetworkPing() * 1000
        tpAmt = math.clamp(math.floor(ping * 0.8), 10, 150)
        if DEBUG then
            DebugInfo("print", "Ping: " .. math.floor(ping) .. "ms | tpAmt:", tpAmt)
        end
        RunService.Heartbeat:Wait()
    end
end)

local function TP(position)
    if not teleporting then
        teleporting = true
        if typeof(position) == "CFrame" then
            hrp.CFrame = position + Vector3.new(
                random:NextNumber(-0.0001, 0.0001),
                random:NextNumber(-0.0001, 0.0001),
                random:NextNumber(-0.0001, 0.0001)
            )
            RunService.Heartbeat:Wait()
            teleporting = false
        end
    else
        DebugInfo("warn", "You are already teleporting", "teleporting")
    end
end

--// ESP Functions
local ESPObjects = {}

local function CreateESP(object, color, text)
    if not Settings.ESP then return end
    
    local esp = Instance.new("BillboardGui")
    esp.Name = "ESP_" .. object.Name
    esp.Size = UDim2.new(0, 100, 0, 40)
    esp.StudsOffset = Vector3.new(0, 3, 0)
    esp.AlwaysOnTop = true
    esp.Adornee = object
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = esp
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or object.Name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = esp
    
    esp.Parent = object
    table.insert(ESPObjects, esp)
    
    return esp
end

local function RemoveESP()
    for _, esp in pairs(ESPObjects) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    ESPObjects = {}
end

local function UpdateESP()
    RemoveESP()
    
    if Settings.BaseESP then
        local plots = workspace:FindFirstChild("Plots")
        if plots then
            for _, plot in pairs(plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                if sign then
                    local yourBase = sign:FindFirstChild("YourBase")
                    if yourBase and not yourBase.Enabled then
                        CreateESP(plot, Color3.fromRGB(255, 0, 0), "Base Disponible")
                    end
                end
            end
        end
    end
    
    if Settings.PlayerESP then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                CreateESP(otherPlayer.Character.HumanoidRootPart, Color3.fromRGB(0, 255, 0), otherPlayer.Name)
            end
        end
    end
end

--// Auto Steal Function
local function AutoSteal()
    if not Settings.AutoSteal then return end
    
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    
    for _, plot in pairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            local yourBase = sign:FindFirstChild("YourBase")
            if yourBase and not yourBase.Enabled then
                local podiums = plot:FindFirstChild("AnimalPodiums")
                if podiums then
                    for _, brainrot in pairs(podiums:GetChildren()) do
                        if brainrot:IsA("Model") and brainrot:FindFirstChild("Base") and brainrot.Base:FindFirstChild("Spawn") then
                            local brainrotSpawn = brainrot.Base.Spawn
                            local target = brainrotSpawn.CFrame * CFrame.new(0, 2, 0)
                            
                            -- Teleport to brainrot
                            local i = 0
                            while i < (tpAmt or 70) do
                                TP(target)
                                i += 1
                            end
                            
                            -- Void teleport for bypass
                            if Settings.Bypass then
                                for _ = 1, 2 do
                                    TP(void)
                                end
                            end
                            
                            -- Return to target
                            i = 0
                            while i < (tpAmt / 16) do
                                TP(target)
                                i += 1
                            end
                            
                            task.wait(0.5)
                            break
                        end
                    end
                end
            end
        end
    end
end

--// Speed Function
local function UpdateSpeed()
    if Settings.Speed and humanoid then
        humanoid.WalkSpeed = Settings.SpeedValue
    elseif humanoid then
        humanoid.WalkSpeed = 16
    end
end

--// Auto Rejoin Function
local function AutoRejoin()
    if not Settings.AutoRejoin then return end
    
    local success, result = pcall(function()
        return game:GetService("TeleportService"):Teleport(game.PlaceId)
    end)
    
    if not success then
        warn("Auto rejoin failed:", result)
    end
end

--// GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotScript"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Blur = Instance.new("BlurEffect")
Blur.Name = "BrainrotBlur"
Blur.Size = 0
Blur.Parent = Lighting

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.Size = UDim2.new(0, 0, 0, 0)
Frame.ClipsDescendants = true
Frame.BackgroundTransparency = 1

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
})
Gradient.Rotation = 45
Gradient.Parent = Frame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.Parent = Frame
DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
DropShadow.BackgroundTransparency = 1
DropShadow.Position = UDim2.new(0.5, 0, 0.5, 8)
DropShadow.Size = UDim2.new(1, 24, 1, 24)
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.6
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(10, 10, 118, 118)
DropShadow.ZIndex = -1
DropShadow.Visible = false

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Frame
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.ZIndex = 2

local TitleBarGradient = Instance.new("UIGradient")
TitleBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
})
TitleBarGradient.Parent = TitleBar

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.Text = "BRAINROT SCRIPT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextTransparency = 1

local ButtonFrame = Instance.new("Frame")
ButtonFrame.Parent = TitleBar
ButtonFrame.BackgroundTransparency = 1
ButtonFrame.Size = UDim2.new(0, 80, 1, 0)
ButtonFrame.Position = UDim2.new(1, -80, 0, 0)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = ButtonFrame
MinimizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Position = UDim2.new(0.65, 0, 0.5, 0)
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 204, 0)
MinimizeButton.TextSize = 14
MinimizeButton.TextTransparency = 1

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = ButtonFrame
CloseButton.AnchorPoint = Vector2.new(0.5, 0.5)
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(0.85, 0, 0.5, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.TextSize = 14
CloseButton.TextTransparency = 1

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = Frame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 35)
Content.Size = UDim2.new(1, 0, 1, -35)

--// Toggle Buttons
local function CreateToggle(name, position, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name .. "Toggle"
    toggleFrame.Parent = Content
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Position = position
    toggleFrame.Size = UDim2.new(0.9, 0, 0, 35)
    toggleFrame.TextTransparency = 1

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleFrame

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Parent = toggleFrame
    toggleStroke.Color = Color3.fromRGB(60, 60, 70)
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 0.5

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Parent = toggleFrame
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 10, 0, 0)
    toggleLabel.Font = Enum.Font.GothamSemibold
    toggleLabel.Text = name
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.TextTransparency = 1

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Parent = toggleFrame
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    toggleButton.BorderSizePixel = 0
    toggleButton.Position = UDim2.new(0.85, 0, 0.5, -8)
    toggleButton.Size = UDim2.new(0, 16, 0, 16)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = ""
    toggleButton.TextTransparency = 1
    toggleButton.AutoButtonColor = false

    local toggleButtonCorner = Instance.new("UICorner")
    toggleButtonCorner.CornerRadius = UDim.new(1, 0)
    toggleButtonCorner.Parent = toggleButton

    local isToggled = false

    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        if isToggled then
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            }):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            }):Play()
        end
        callback(isToggled)
    end)

    return toggleFrame, toggleLabel, toggleButton
end

--// Create Toggles
local autoStealToggle, autoStealLabel, autoStealButton = CreateToggle("Auto Steal", UDim2.new(0.05, 0, 0.05, 0), function(enabled)
    Settings.AutoSteal = enabled
end)

local espToggle, espLabel, espButton = CreateToggle("ESP Bases", UDim2.new(0.05, 0, 0.15, 0), function(enabled)
    Settings.BaseESP = enabled
    UpdateESP()
end)

local playerEspToggle, playerEspLabel, playerEspButton = CreateToggle("ESP Jugadores", UDim2.new(0.05, 0, 0.25, 0), function(enabled)
    Settings.PlayerESP = enabled
    UpdateESP()
end)

local speedToggle, speedLabel, speedButton = CreateToggle("Velocidad", UDim2.new(0.05, 0, 0.35, 0), function(enabled)
    Settings.Speed = enabled
    UpdateSpeed()
end)

local bypassToggle, bypassLabel, bypassButton = CreateToggle("Bypass", UDim2.new(0.05, 0, 0.45, 0), function(enabled)
    Settings.Bypass = enabled
end)

local rejoinToggle, rejoinLabel, rejoinButton = CreateToggle("Auto Rejoin", UDim2.new(0.05, 0, 0.55, 0), function(enabled)
    Settings.AutoRejoin = enabled
end)

--// Speed Slider
local speedSliderFrame = Instance.new("Frame")
speedSliderFrame.Name = "SpeedSlider"
speedSliderFrame.Parent = Content
speedSliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
speedSliderFrame.BorderSizePixel = 0
speedSliderFrame.Position = UDim2.new(0.05, 0, 0.65, 0)
speedSliderFrame.Size = UDim2.new(0.9, 0, 0, 50)
speedSliderFrame.Visible = false

local speedSliderCorner = Instance.new("UICorner")
speedSliderCorner.CornerRadius = UDim.new(0, 8)
speedSliderCorner.Parent = speedSliderFrame

local speedSliderLabel = Instance.new("TextLabel")
speedSliderLabel.Name = "Label"
speedSliderLabel.Parent = speedSliderFrame
speedSliderLabel.BackgroundTransparency = 1
speedSliderLabel.Size = UDim2.new(1, 0, 0.4, 0)
speedSliderLabel.Position = UDim2.new(0, 10, 0, 0)
speedSliderLabel.Font = Enum.Font.GothamSemibold
speedSliderLabel.Text = "Velocidad: 50"
speedSliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedSliderLabel.TextSize = 12
speedSliderLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedSlider = Instance.new("TextButton")
speedSlider.Name = "Slider"
speedSlider.Parent = speedSliderFrame
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
speedSlider.BorderSizePixel = 0
speedSlider.Position = UDim2.new(0.05, 0, 0.5, 0)
speedSlider.Size = UDim2.new(0.9, 0, 0.3, 0)
speedSlider.Font = Enum.Font.GothamBold
speedSlider.Text = ""
speedSlider.AutoButtonColor = false

local speedSliderCorner2 = Instance.new("UICorner")
speedSliderCorner2.CornerRadius = UDim.new(0, 4)
speedSliderCorner2.Parent = speedSlider

local speedSliderFill = Instance.new("Frame")
speedSliderFill.Name = "Fill"
speedSliderFill.Parent = speedSlider
speedSliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
speedSliderFill.BorderSizePixel = 0
speedSliderFill.Size = UDim2.new(0.5, 0, 1, 0)

local speedSliderFillCorner = Instance.new("UICorner")
speedSliderFillCorner.CornerRadius = UDim.new(0, 4)
speedSliderFillCorner.Parent = speedSliderFill

--// Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = Content
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 12
StatusLabel.TextTransparency = 1
StatusLabel.Text = "Script cargado correctamente"
StatusLabel.TextWrapped = true

--// Animation
task.wait(0.1)
TweenService:Create(Blur, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = 15}):Play()
TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 350, 0, 400),
    BackgroundTransparency = 0
}):Play()
DropShadow.Visible = true
TweenService:Create(DropShadow, TweenInfo.new(0.6), {ImageTransparency = 0.6}):Play()

task.wait(0.3)
TweenService:Create(TitleLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
TweenService:Create(CloseButton, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
TweenService:Create(MinimizeButton, TweenInfo.new(0.4), {TextTransparency = 0}):Play()

task.wait(0.2)
local toggles = {autoStealToggle, espToggle, playerEspToggle, speedToggle, bypassToggle, rejoinToggle}
for i, toggle in pairs(toggles) do
    task.wait(0.1)
    TweenService:Create(toggle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(toggle:FindFirstChild("Label"), TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(toggle:FindFirstChild("Toggle"), TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
end

task.wait(0.2)
TweenService:Create(StatusLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()

--// Speed Slider Logic
speedToggle:FindFirstChild("Toggle").MouseButton1Click:Connect(function()
    task.wait(0.2)
    speedSliderFrame.Visible = Settings.Speed
end)

--// Minimize Logic
local isMinimized = false
local originalSize = UDim2.new(0, 350, 0, 400)
local minimizedSize = UDim2.new(0, 200, 0, 35)

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and minimizedSize or originalSize
    
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Size = targetSize
    }):Play()
    
    TweenService:Create(Content, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Visible = not isMinimized
    }):Play()
    
    MinimizeButton.Text = isMinimized and "□" or "—"
end)

--// Close Logic
CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 0}):Play()
    task.wait(0.4)
    ScreenGui:Destroy()
    Blur:Destroy()
end)

--// Toggle GUI Visibility
local isGuiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        isGuiVisible = not isGuiVisible
        if isGuiVisible then
            TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = isMinimized and minimizedSize or originalSize,
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 15}):Play()
            TweenService:Create(Content, TweenInfo.new(0.4), {
                Visible = not isMinimized
            }):Play()
        else
            TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 0}):Play()
        end
    end
end)

--// Dragging Logic
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local goal = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        Frame:TweenPosition(goal, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.05, true)
    end
end)

--// Main Loop
RunService.Heartbeat:Connect(function()
    if Settings.AutoSteal then
        AutoSteal()
    end
    
    if Settings.ESP then
        UpdateESP()
    end
    
    UpdateSpeed()
end)

--// Auto Rejoin Check
game.Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player and Settings.AutoRejoin then
        task.wait(1)
        AutoRejoin()
    end
end)

print("[BrainrotScript]: Script cargado exitosamente!")
print("[BrainrotScript]: Presiona RightShift para mostrar/ocultar la interfaz")
print("[BrainrotScript]: Código de acceso: moon") 
