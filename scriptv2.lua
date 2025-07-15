
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local key = "arbix hub"
local discordLink = "https://discord.gg/EXK4dQxJBv"
local scriptToLoad = [[
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

local function DebugInfo(mode, content, value)
    if not DEBUG then return end
    if mode == "warn" then
        warn("[ArbixTP DEBUG]:", content, value or "")
    elseif mode == "print" then
        print("[ArbixTP DEBUG]:", content, value or "")
    else
        warn("[ArbixTP DEBUG]: Invalid debug type.")
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

local function TweenSteal(statusLabel)
    statusLabel.Text = "Iniciando TweenSteal seguro..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

    local function isCharacterValid()
        return char and char.Parent and hrp and hrp.Parent and humanoid and humanoid.Parent
    end

    local function findDeliveryHitbox()
        for _, v in ipairs(workspace.Plots:GetDescendants()) do
            if v.Name == "DeliveryHitbox" and v.Parent:FindFirstChild("PlotSign") then
                if v.Parent.PlotSign:FindFirstChild("YourBase") and v.Parent.PlotSign.YourBase.Enabled then
                    return v
                end
            end
        end
        return nil
    end

    local function safeTeleport(targetCFrame)
        if not isCharacterValid() or not targetCFrame then return false end
        
        local iterations = math.clamp(tpAmt or 60, 40, 100)
        local safeVoid = CFrame.new(0, -1000, 0) -- Void más seguro
        
        -- Verificar posición inicial
        local startPos = hrp.Position
        
        -- Fase 1: Teleportes directos al objetivo
        for i = 1, iterations do
            if not isCharacterValid() then 
                DebugInfo("warn", "Character lost during teleport phase 1", nil)
                return false 
            end
            
            hrp.CFrame = targetCFrame * CFrame.new(
                random:NextNumber(-0.0001, 0.0001),
                random:NextNumber(-0.0001, 0.0001),
                random:NextNumber(-0.0001, 0.0001)
            )
            RunService.Heartbeat:Wait()
        end
        
        -- Verificar que seguimos en una posición válida
        if not isCharacterValid() then
            DebugInfo("warn", "Character lost after phase 1", nil)
            return false
        end
        
        -- Fase 2: Secuencia void controlada
        for i = 1, 2 do
            if not isCharacterValid() then break end
            
            -- Void seguro
            hrp.CFrame = safeVoid
            task.wait(0.03)
            
            -- Verificar antes de regresar
            if not isCharacterValid() then 
                DebugInfo("warn", "Character lost in void", nil)
                -- Intentar recuperar
                task.wait(0.1)
                if char and char.Parent then
                    hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = targetCFrame
                    end
                end
                break
            end
            
            hrp.CFrame = targetCFrame
            task.wait(0.03)
        end
        
        -- Verificación final
        if not isCharacterValid() then
            DebugInfo("warn", "Character lost during void sequence", nil)
            return false
        end
        
        -- Fase 3: Posicionamiento final suave
        for i = 1, 10 do
            if not isCharacterValid() then break end
            
            hrp.CFrame = targetCFrame * CFrame.new(
                random:NextNumber(-0.05, 0.05),
                0,
                random:NextNumber(-0.05, 0.05)
            )
            RunService.Heartbeat:Wait()
        end
        
        return isCharacterValid()
    end

    -- Verificar estado inicial
    if not isCharacterValid() then
        statusLabel.Text = "Error: Personaje no válido"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        task.wait(2)
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        return
    end

    -- Buscar delivery hitbox
    local delivery = findDeliveryHitbox()
    if not delivery then
        statusLabel.Text = "Error: No se encontró DeliveryHitbox"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        task.wait(2)
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        return
    end

    DebugInfo("print", "DeliveryHitbox found for safe TweenSteal", delivery)
    
    statusLabel.Text = "Ejecutando teleporte seguro..."
    TweenService:Create(statusLabel, TweenInfo.new(0.2), {TextTransparency = 0}):Play()

    -- Guardar posición inicial por seguridad
    local originalPosition = hrp.CFrame
    
    -- Calcular posición objetivo
    local targetPosition = delivery.CFrame * CFrame.new(0, -2, 0)
    
    -- Ejecutar teleporte seguro
    local success = safeTeleport(targetPosition)
    
    -- Verificar resultado
    task.wait(0.2)
    
    if not isCharacterValid() then
        statusLabel.Text = "Error: Personaje perdido, restaurando..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        TweenService:Create(statusLabel, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
        
        -- Intentar restaurar personaje
        task.wait(0.5)
        if char and char.Parent then
            hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = originalPosition
                statusLabel.Text = "Personaje restaurado, reintenta"
                statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                statusLabel.Text = "Error: No se pudo restaurar"
                statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
        end
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        task.wait(2)
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        return
    end
    
    local finalDistance = (hrp.Position - delivery.Position).Magnitude
    
    -- Ajuste de precisión si es necesario (sin void)
    if finalDistance > 15 and isCharacterValid() then
        statusLabel.Text = "Ajuste de precisión..."
        TweenService:Create(statusLabel, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
        
        for attempt = 1, 3 do
            if not isCharacterValid() then break end
            
            local preciseTarget = delivery.CFrame * CFrame.new(
                random:NextNumber(-1, 1),
                random:NextNumber(-2.5, -1.5),
                random:NextNumber(-1, 1)
            )
            
            -- Teleporte directo sin void
            for i = 1, 20 do
                if not isCharacterValid() then break end
                hrp.CFrame = preciseTarget
                RunService.Heartbeat:Wait()
            end
            
            finalDistance = (hrp.Position - delivery.Position).Magnitude
            if finalDistance <= 15 then break end
        end
    end

    -- Resultado final
    if isCharacterValid() then
        finalDistance = (hrp.Position - delivery.Position).Magnitude
        
        if finalDistance <= 20 then
            DebugInfo("print", "Safe TweenSteal succeeded", finalDistance)
            statusLabel.Text = "¡TweenSteal Exitoso! ✓"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            statusLabel.Text = "Parcialmente exitoso (dist: " .. math.floor(finalDistance) .. "m)"
            statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        end
    else
        statusLabel.Text = "Error: Personaje inestable"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
    
    TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    task.wait(2)
    TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArbixTPGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
DebugInfo("print", "ArbixTPGui created", ScreenGui.Name)

local Blur = Instance.new("BlurEffect")
Blur.Name = "ArbixTPBlur"
Blur.Size = 0
Blur.Parent = workspace
DebugInfo("print", "ArbixTPBlur created", Blur.Name)

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.Size = UDim2.new(0, 0, 0, 0)
Frame.ClipsDescendants = true
Frame.BackgroundTransparency = 1

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
})
Gradient.Rotation = 45
Gradient.Parent = Frame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
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
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.ZIndex = 2

local TitleBarGradient = Instance.new("UIGradient")
TitleBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
})
TitleBarGradient.Parent = TitleBar

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 16)
TitleBarCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.Text = "ARBIX TP"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20
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
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 204, 0)
MinimizeButton.TextSize = 16
MinimizeButton.TextTransparency = 1

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = ButtonFrame
CloseButton.AnchorPoint = Vector2.new(0.5, 0.5)
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(0.85, 0, 0.5, 0)
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.TextSize = 16
CloseButton.TextTransparency = 1

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = Frame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 40)
Content.Size = UDim2.new(1, 0, 1, -40)

local TweenStealButton = Instance.new("TextButton")
TweenStealButton.Name = "TweenStealButton"
TweenStealButton.Parent = Content
TweenStealButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
TweenStealButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TweenStealButton.Position = UDim2.new(0.1, 0, 0.25, 0)
TweenStealButton.Size = UDim2.new(0.8, 0, 0, 50)
TweenStealButton.Font = Enum.Font.GothamSemibold
TweenStealButton.Text = "TWEEN STEAL"
TweenStealButton.TextSize = 18
TweenStealButton.TextWrapped = true
TweenStealButton.TextTransparency = 1
TweenStealButton.AutoButtonColor = false

local UICorner_TweenSteal = Instance.new("UICorner")
UICorner_TweenSteal.CornerRadius = UDim.new(0, 12)
UICorner_TweenSteal.Parent = TweenStealButton

local TweenStealStroke = Instance.new("UIStroke")
TweenStealStroke.Parent = TweenStealButton
TweenStealStroke.Color = Color3.fromRGB(0, 80, 200)
TweenStealStroke.Thickness = 2
TweenStealStroke.Transparency = 0.5

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = Content
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(0.8, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.1, 0, 0.55, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 14
StatusLabel.TextTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextWrapped = true

local function createHoverEffect(button, stroke)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
            BackgroundColor3 = Color3.fromRGB(0, 140, 255),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
            Color = Color3.fromRGB(0, 100, 220),
            Thickness = 3,
            Transparency = 0.2
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
            BackgroundColor3 = Color3.fromRGB(0, 120, 255),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
            Color = Color3.fromRGB(0, 80, 200),
            Thickness = 2,
            Transparency = 0.5
        }):Play()
    end)
end

createHoverEffect(TweenStealButton, TweenStealStroke)

-- Initial animation
task.wait(0.1)
TweenService:Create(Blur, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = 15}):Play()
TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 450, 0, 200),
    BackgroundTransparency = 0,
    BackgroundColor3 = Color3.fromRGB(10, 10, 15)
}):Play()
DropShadow.Visible = true
TweenService:Create(DropShadow, TweenInfo.new(0.6), {ImageTransparency = 0.6}):Play()

task.wait(0.3)
TweenService:Create(TitleLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
TweenService:Create(CloseButton, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
TweenService:Create(MinimizeButton, TweenInfo.new(0.4), {TextTransparency = 0}):Play()

task.wait(0.2)
TweenService:Create(TweenStealButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
    TextTransparency = 0,
    BackgroundTransparency = 0
}):Play()
TweenService:Create(TweenStealStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()

TweenStealButton.MouseButton1Click:Connect(function()
    DebugInfo("print", "TweenSteal button clicked", "")
    TweenSteal(StatusLabel)
end)

local isMinimized = false
local originalSize = UDim2.new(0, 450, 0, 200)
local minimizedSize = UDim2.new(0, 200, 0, 40)

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and minimizedSize or originalSize
    local contentTransparency = isMinimized and 1 or 0
    
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Size = targetSize,
        BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    }):Play()
    
    TweenService:Create(Content, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Visible = not isMinimized
    }):Play()
    
    TweenService:Create(DropShadow, TweenInfo.new(0.4), {
        ImageTransparency = 0.6,
        Visible = true
    }):Play()
    
    TweenService:Create(TweenStealButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        TextTransparency = contentTransparency,
        BackgroundTransparency = contentTransparency
    }):Play()
    
    TweenService:Create(TweenStealStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Transparency = contentTransparency
    }):Play()
    
    TweenService:Create(StatusLabel, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        TextTransparency = contentTransparency
    }):Play()
    
    MinimizeButton.Text = isMinimized and "□" or "—"
    DebugInfo("print", "Minimize toggled", isMinimized and "Minimized" or "Restored")
end)

CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 0}):Play()
    task.wait(0.4)
    ScreenGui:Destroy()
    Blur:Destroy()
    DebugInfo("print", "ArbixTPGui closed", "")
end)

local isGuiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        isGuiVisible = not isGuiVisible
        if isGuiVisible then
            TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = isMinimized and minimizedSize or originalSize,
                BackgroundColor3 = Color3.fromRGB(10, 10, 15),
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 15}):Play()
            TweenService:Create(DropShadow, TweenInfo.new(0.4), {
                ImageTransparency = 0.6,
                Visible = true
            }):Play()
            TweenService:Create(Content, TweenInfo.new(0.4), {
                Visible = not isMinimized
            }):Play()
            if not isMinimized then
                TweenService:Create(TweenStealButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
                    TextTransparency = 0,
                    BackgroundTransparency = 0
                }):Play()
                TweenService:Create(TweenStealStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
                TweenService:Create(StatusLabel, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
            end
            DebugInfo("print", "ArbixTPGui shown", "")
        else
            TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 0}):Play()
            TweenService:Create(DropShadow, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
            DebugInfo("print", "ArbixTPGui hidden", "")
        end
    end
end)

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

DebugInfo("print", "ArbixTPGui initialization completed", "")
]]

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArbixHub"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Blur = Instance.new("BlurEffect")
Blur.Name = "ArbixBlur"
Blur.Size = 0
Blur.Parent = Lighting

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.Size = UDim2.new(0, 0, 0, 0)
Frame.ClipsDescendants = true
Frame.BackgroundTransparency = 1

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
})
Gradient.Rotation = 45
Gradient.Parent = Frame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
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
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.ZIndex = 2

local TitleBarGradient = Instance.new("UIGradient")
TitleBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
})
TitleBarGradient.Parent = TitleBar

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 16)
TitleBarCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.Text = "ARBIX HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20
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
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 204, 0)
MinimizeButton.TextSize = 16
MinimizeButton.TextTransparency = 1

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = ButtonFrame
CloseButton.AnchorPoint = Vector2.new(0.5, 0.5)
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(0.85, 0, 0.5, 0)
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.TextSize = 16
CloseButton.TextTransparency = 1

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = Frame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 40)
Content.Size = UDim2.new(1, 0, 1, -40)

local InputBox = Instance.new("TextBox")
InputBox.Name = "InputBox"
InputBox.Parent = Content
InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderText = "Enter access code"
InputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
InputBox.BorderSizePixel = 0
InputBox.Position = UDim2.new(0.1, 0, 0.15, 0)
InputBox.Size = UDim2.new(0.8, 0, 0, 50)
InputBox.Font = Enum.Font.Gotham
InputBox.Text = ""
InputBox.TextSize = 18
InputBox.TextWrapped = true
InputBox.TextTransparency = 1
InputBox.ClearTextOnFocus = false

local UICorner_Input = Instance.new("UICorner")
UICorner_Input.CornerRadius = UDim.new(0, 12)
UICorner_Input.Parent = InputBox

local InputStroke = Instance.new("UIStroke")
InputStroke.Parent = InputBox
InputStroke.Color = Color3.fromRGB(60, 60, 70)
InputStroke.Thickness = 2
InputStroke.Transparency = 1

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Parent = Content
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Size = UDim2.new(0.8, 0, 0, 50)
ButtonContainer.Position = UDim2.new(0.1, 0, 0.35, 0)

local SubmitButton = Instance.new("TextButton")
SubmitButton.Name = "SubmitButton"
SubmitButton.Parent = ButtonContainer
SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitButton.Position = UDim2.new(0, 0, 0, 0)
SubmitButton.Size = UDim2.new(0.48, -5, 1, 0)
SubmitButton.Font = Enum.Font.GothamSemibold
SubmitButton.Text = "SUBMIT CODE"
SubmitButton.TextSize = 18
SubmitButton.TextWrapped = true
SubmitButton.TextTransparency = 1
SubmitButton.AutoButtonColor = false

local UICorner_Submit = Instance.new("UICorner")
UICorner_Submit.CornerRadius = UDim.new(0, 12)
UICorner_Submit.Parent = SubmitButton

local SubmitStroke = Instance.new("UIStroke")
SubmitStroke.Parent = SubmitButton
SubmitStroke.Color = Color3.fromRGB(0, 80, 200)
SubmitStroke.Thickness = 2
SubmitStroke.Transparency = 0.5

local GetCodeButton = Instance.new("TextButton")
GetCodeButton.Name = "GetCodeButton"
GetCodeButton.Parent = ButtonContainer
GetCodeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
GetCodeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GetCodeButton.Position = UDim2.new(0.52, 5, 0, 0)
GetCodeButton.Size = UDim2.new(0.48, -5, 1, 0)
GetCodeButton.Font = Enum.Font.GothamSemibold
GetCodeButton.Text = "GET CODE"
GetCodeButton.TextSize = 18
GetCodeButton.TextWrapped = true
GetCodeButton.TextTransparency = 1
GetCodeButton.AutoButtonColor = false

local UICorner_GetCode = Instance.new("UICorner")
UICorner_GetCode.CornerRadius = UDim.new(0, 12)
UICorner_GetCode.Parent = GetCodeButton

local GetCodeStroke = Instance.new("UIStroke")
GetCodeStroke.Parent = GetCodeButton
GetCodeStroke.Color = Color3.fromRGB(0, 80, 200)
GetCodeStroke.Thickness = 2
GetCodeStroke.Transparency = 0.5

local NotificationFrame = Instance.new("Frame")
NotificationFrame.Parent = Content
NotificationFrame.BackgroundTransparency = 1
NotificationFrame.Size = UDim2.new(0.8, 0, 0, 30)
NotificationFrame.Position = UDim2.new(0.1, 0, 0.65, 0)
NotificationFrame.Visible = false

local NotificationLabel = Instance.new("TextLabel")
NotificationLabel.Parent = NotificationFrame
NotificationLabel.BackgroundTransparency = 1
NotificationLabel.Size = UDim2.new(1, 0, 1, 0)
NotificationLabel.Font = Enum.Font.Gotham
NotificationLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
NotificationLabel.TextSize = 14
NotificationLabel.TextTransparency = 1
NotificationLabel.Text = ""
NotificationLabel.TextWrapped = true

local LoadingCircle = Instance.new("Frame")
LoadingCircle.Name = "LoadingCircle"
LoadingCircle.Parent = Content
LoadingCircle.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingCircle.BackgroundTransparency = 1
LoadingCircle.Position = UDim2.new(0.5, 0, 0.35, 0)
LoadingCircle.Size = UDim2.new(0, 40, 0, 40)
LoadingCircle.Visible = false

local Circle1 = Instance.new("Frame")
Circle1.Name = "Circle1"
Circle1.Parent = LoadingCircle
Circle1.AnchorPoint = Vector2.new(0.5, 0.5)
Circle1.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
Circle1.Size = UDim2.new(0, 10, 0, 10)
Circle1.Position = UDim2.new(0.5, 0, 0, 0)
Circle1.BorderSizePixel = 0

local UICorner_Circle1 = Instance.new("UICorner")
UICorner_Circle1.CornerRadius = UDim.new(1, 0)
UICorner_Circle1.Parent = Circle1

local Circle2 = Instance.new("Frame")
Circle2.Name = "Circle2"
Circle2.Parent = LoadingCircle
Circle2.AnchorPoint = Vector2.new(0.5, 0.5)
Circle2.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
Circle2.Size = UDim2.new(0, 10, 0, 10)
Circle2.Position = UDim2.new(0.5, 0, 0, 0)
Circle2.BorderSizePixel = 0

local UICorner_Circle2 = Instance.new("UICorner")
UICorner_Circle2.CornerRadius = UDim.new(1, 0)
UICorner_Circle2.Parent = Circle2

local function createHoverEffect(button, stroke)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
            BackgroundColor3 = Color3.fromRGB(0, 140, 255),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
            Color = Color3.fromRGB(0, 100, 220),
            Thickness = 3,
            Transparency = 0.2
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
            BackgroundColor3 = Color3.fromRGB(0, 120, 255),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
            Color = Color3.fromRGB(0, 80, 200),
            Thickness = 2,
            Transparency = 0.5
        }):Play()
    end)
end

createHoverEffect(SubmitButton, SubmitStroke)
createHoverEffect(GetCodeButton, GetCodeStroke)

task.wait(0.1)
TweenService:Create(Blur, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = 15}):Play()
TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 450, 0, 320),
    BackgroundTransparency = 0
}):Play()
DropShadow.Visible = true
TweenService:Create(DropShadow, TweenInfo.new(0.6), {ImageTransparency = 0.6}):Play()

task.wait(0.3)
TweenService:Create(TitleLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
TweenService:Create(CloseButton, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
TweenService:Create(MinimizeButton, TweenInfo.new(0.4), {TextTransparency = 0}):Play()

task.wait(0.2)
TweenService:Create(InputBox, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
    TextTransparency = 0,
    PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
}):Play()
TweenService:Create(InputStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()

task.wait(0.2)
TweenService:Create(SubmitButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
TweenService:Create(SubmitStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
TweenService:Create(GetCodeButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
TweenService:Create(GetCodeStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()

GetCodeButton.MouseButton1Click:Connect(function()
    setclipboard(discordLink)
    NotificationFrame.Visible = true
    NotificationLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    NotificationLabel.Text = "Discord link copied to clipboard!"
    TweenService:Create(NotificationLabel, TweenInfo.new(0.3), {
        TextTransparency = 0
    }):Play()
    task.wait(2)
    TweenService:Create(NotificationLabel, TweenInfo.new(0.3), {
        TextTransparency = 1
    }):Play()
    task.wait(0.3)
    NotificationFrame.Visible = false
    NotificationLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
end)

local isMinimized = false
local originalSize = UDim2.new(0, 450, 0, 320)
local minimizedSize = UDim2.new(0, 200, 0, 40)

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and minimizedSize or originalSize
    local contentTransparency = isMinimized and 1 or 0
    
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Size = targetSize,
        BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    }):Play()
    
    TweenService:Create(Content, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Visible = not isMinimized
    }):Play()
    
    TweenService:Create(DropShadow, TweenInfo.new(0.4), {
        ImageTransparency = 0.6,
        Visible = true
    }):Play()
    
    TweenService:Create(InputBox, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        TextTransparency = contentTransparency,
        BackgroundTransparency = contentTransparency
    }):Play()
    
    TweenService:Create(InputStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Transparency = contentTransparency
    }):Play()
    
    TweenService:Create(SubmitButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        TextTransparency = contentTransparency,
        BackgroundTransparency = contentTransparency
    }):Play()
    
    TweenService:Create(SubmitStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Transparency = contentTransparency
    }):Play()
    
    TweenService:Create(GetCodeButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        TextTransparency = contentTransparency,
        BackgroundTransparency = contentTransparency
    }):Play()
    
    TweenService:Create(GetCodeStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Transparency = contentTransparency
    }):Play()
    
    MinimizeButton.Text = isMinimized and "□" or "—"
end)

SubmitButton.MouseButton1Click:Connect(function()
    local userInput = string.lower(InputBox.Text or "")
    
    if userInput == key then
        SubmitButton.Visible = false
        GetCodeButton.Visible = false
        LoadingCircle.Visible = true
        
        local angle = 0
        local connection
        connection = RunService.Heartbeat:Connect(function(delta)
            angle = (angle + delta * 10) % (2 * math.pi)
            Circle1.Position = UDim2.new(0.5 + math.cos(angle) * 0.4, 0, 0.5 + math.sin(angle) * 0.4, 0)
            Circle2.Position = UDim2.new(0.5 + math.cos(angle + math.pi) * 0.4, 0, 0.5 + math.sin(angle + math.pi) * 0.4, 0)
        end)
        
        task.wait(1.2)
        connection:Disconnect()
        
        TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 0}):Play()
        
        task.wait(0.4)
        ScreenGui:Destroy()
        Blur:Destroy()
        print("[ArbixHub]: ArbixBlur destroyed")
        local success, errorMsg = pcall(function()
            local func = loadstring(scriptToLoad)
            if not func then
                error("Failed to compile scriptToLoad")
            end
            func()
        end)
        if not success then
            warn("[ArbixHub ERROR]: Failed to execute scriptToLoad: " .. tostring(errorMsg))
        else
            print("[ArbixHub]: Successfully executed scriptToLoad")
        end
    else
        NotificationFrame.Visible = true
        NotificationLabel.Text = "Invalid code, please try again"
        
        TweenService:Create(NotificationLabel, TweenInfo.new(0.3), {
            TextTransparency = 0
        }):Play()
        
        local shakeTime = 0.4
        for i = 1, 3 do
            TweenService:Create(InputBox, TweenInfo.new(shakeTime/6), {Position = UDim2.new(0.1, -5, 0.15, 0)}):Play()
            task.wait(shakeTime/6)
            TweenService:Create(InputBox, TweenInfo.new(shakeTime/6), {Position = UDim2.new(0.1, 5, 0.15, 0)}):Play()
            task.wait(shakeTime/6)
        end
        TweenService:Create(InputBox, TweenInfo.new(shakeTime/6), {Position = UDim2.new(0.1, 0, 0.15, 0)}):Play()
        InputBox.Text = ""
        TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(255, 80, 80)}):Play()
        
        task.wait(2)
        TweenService:Create(NotificationLabel, TweenInfo.new(0.3), {
            TextTransparency = 1
        }):Play()
        TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(60, 60, 70)}):Play()
        task.wait(0.3)
        NotificationFrame.Visible = false
    end
end)

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

local isGuiVisible = true
UIS.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        isGuiVisible = not isGuiVisible
        if isGuiVisible then
            TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = isMinimized and minimizedSize or originalSize,
                BackgroundColor3 = Color3.fromRGB(10, 10, 15),
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 15}):Play()
            TweenService:Create(DropShadow, TweenInfo.new(0.4), {
                ImageTransparency = 0.6,
                Visible = true
            }):Play()
            TweenService:Create(Content, TweenInfo.new(0.4), {
                Visible = not isMinimized
            }):Play()
            if not isMinimized then
                TweenService:Create(InputBox, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
                    TextTransparency = 0,
                    BackgroundTransparency = 0
                }):Play()
                TweenService:Create(InputStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
                TweenService:Create(SubmitButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
                    TextTransparency = 0,
                    BackgroundTransparency = 0
                }):Play()
                TweenService:Create(SubmitStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
                TweenService:Create(GetCodeButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
                    TextTransparency = 0,
                    BackgroundTransparency = 0
                }):Play()
                TweenService:Create(GetCodeStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
            end
        else
            TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 0}):Play()
            TweenService:Create(DropShadow, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
        end
    end
end)

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

UIS.InputChanged:Connect(function(input)
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
