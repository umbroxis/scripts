-- ╔══════════════════════════════════════════════════════════════╗
-- ║                    ARBIX TWEEN STEAL ULTRA V3.0             ║
-- ║              Versión mejorada por 1000 - Todo en Uno        ║
-- ╚══════════════════════════════════════════════════════════════╝

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local random = Random.new()

-- ═══════════════════════════════════════════════════════════════
--                    CONFIGURACIÓN ULTRA AVANZADA
-- ═══════════════════════════════════════════════════════════════

local CONFIG = {
    MOVEMENT = {
        BASE_ITERATIONS = 180,
        MAX_ITERATIONS = 350,
        MIN_ITERATIONS = 60,
        STEALTH_FACTOR = 0.92,
        JITTER_INTENSITY = 0.0003,
        CURVE_COMPLEXITY = 8,
        NATURAL_DELAY_MIN = 0.002,
        NATURAL_DELAY_MAX = 0.015,
        BEZIER_SMOOTHNESS = 0.95
    },
    
    ANTI_DETECTION = {
        RANDOMIZE_PATTERNS = true,
        USE_HEARTBEAT_SYNC = true,
        MIMIC_HUMAN_MOVEMENT = true,
        AVOID_PERFECT_PATHS = true,
        DYNAMIC_TIMING = true,
        MEMORY_FOOTPRINT_REDUCTION = true,
        ANTICHEAT_EVASION = true
    },
    
    TELEPORT = {
        VOID_POSITIONS = {
            CFrame.new(0, -3.4028234663852886e+38, 0),
            CFrame.new(999999, -3.5e40, 999999),
            CFrame.new(-999999, -3.2e40, -999999),
            CFrame.new(0, -1.8e40, 0),
            CFrame.new(500000, -4e40, -500000)
        },
        BURST_COUNT = 7,
        VERIFICATION_ATTEMPTS = 4,
        SAFETY_DISTANCE = 22,
        POSITION_VARIANCE = Vector3.new(2.5, 1.2, 2.5),
        TELEPORT_CHAOS_MODE = true
    },
    
    PERFORMANCE = {
        TRACK_STATS = true,
        AUTO_OPTIMIZE = true,
        ADAPTIVE_TIMING = true,
        PING_COMPENSATION = true
    },
    
    DEBUG = {
        ENABLED = false,
        VERBOSE_LOGGING = false,
        SHOW_GUI_STATUS = true
    }
}

-- ═══════════════════════════════════════════════════════════════
--                        VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════════

local char, humanoid, hrp
local isExecuting = false
local performanceData = {
    attempts = 0,
    successes = 0,
    avgTime = 0,
    lastExecutionTime = 0,
    bestTime = math.huge,
    worstTime = 0
}

-- ═══════════════════════════════════════════════════════════════
--                      FUNCIONES AUXILIARES ULTRA
-- ═══════════════════════════════════════════════════════════════

local function setupCharacter()
    char = player.Character or player.CharacterAdded:Wait()
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    return char and humanoid and hrp
end

setupCharacter()
player.CharacterAdded:Connect(setupCharacter)

local function UltraLog(level, message, data)
    if not CONFIG.DEBUG.ENABLED then return end
    local timestamp = os.date("%H:%M:%S")
    local logMsg = string.format("[%s][%s]: %s", timestamp, level, message)
    if data then logMsg = logMsg .. " | " .. tostring(data) end
    
    if level == "ERROR" or level == "WARN" then
        warn("🔴 " .. logMsg)
    else
        print("🟢 " .. logMsg)
    end
end

local function QuantumRandom(min, max, chaos)
    chaos = chaos or 1
    local seed = tick() * 1000 + math.random(1, 10000) * chaos
    math.randomseed(seed)
    
    local algorithms = {
        function() return math.random() * (max - min) + min end,
        function() return random:NextNumber(min, max) end,
        function() 
            local noise = math.sin(seed * 0.007) * math.cos(seed * 0.013)
            return ((max + min) / 2) + noise * (max - min) * 0.3
        end
    }
    
    local result = 0
    for _, algo in ipairs(algorithms) do
        result = result + algo()
    end
    
    return result / #algorithms
end

local function DetectAdvancedAntiCheat()
    local suspiciousElements = {
        services = {"AntiCheatService", "SecurityService", "ModeratorService"},
        keywords = {"anticheat", "detection", "ban", "kick", "exploit", "cheat"},
        networkPatterns = {"AC_", "SECURITY_", "MOD_"}
    }
    
    local threatLevel = 0
    
    -- Detectar servicios peligrosos
    for _, serviceName in ipairs(suspiciousElements.services) do
        if game:FindService(serviceName) then
            threatLevel = threatLevel + 2
            UltraLog("WARN", "Suspicious service detected", serviceName)
        end
    end
    
    -- Escanear scripts de forma segura
    local function safeScanContainer(container)
        pcall(function()
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    for _, keyword in ipairs(suspiciousElements.keywords) do
                        if string.find(string.lower(child.Name), keyword) then
                            threatLevel = threatLevel + 1
                        end
                    end
                end
            end
        end)
    end
    
    safeScanContainer(ReplicatedStorage)
    safeScanContainer(workspace)
    
    UltraLog("INFO", "Anti-cheat threat level", threatLevel)
    return threatLevel
end

local function CalculateUltraOptimalSettings()
    local ping = player:GetNetworkPing() * 1000
    local fps = workspace:GetRealPhysicsFPS()
    local playerCount = #Players:GetPlayers()
    
    -- Algoritmo avanzado de optimización
    local pingFactor = math.clamp(math.log(ping + 1) / math.log(101), 0.4, 2.5)
    local fpsFactor = math.clamp(fps / 60, 0.3, 2.0)
    local crowdFactor = math.clamp(1 - (playerCount / 50), 0.5, 1.2)
    
    local optimalIterations = math.floor(CONFIG.MOVEMENT.BASE_ITERATIONS * pingFactor * fpsFactor * crowdFactor)
    optimalIterations = math.clamp(optimalIterations, CONFIG.MOVEMENT.MIN_ITERATIONS, CONFIG.MOVEMENT.MAX_ITERATIONS)
    
    local optimalDelay = math.clamp(
        (ping * 0.0008) + (1 / fps) * 0.5,
        CONFIG.MOVEMENT.NATURAL_DELAY_MIN,
        CONFIG.MOVEMENT.NATURAL_DELAY_MAX
    )
    
    UltraLog("INFO", "Optimal settings calculated", string.format("Iter: %d, Delay: %.4f", optimalIterations, optimalDelay))
    
    return optimalIterations, optimalDelay, pingFactor
end

-- ═══════════════════════════════════════════════════════════════
--                   ALGORITMO DE MOVIMIENTO CUÁNTICO
-- ═══════════════════════════════════════════════════════════════

local function QuantumStealthMovement(startPos, targetPos, iterations, naturalDelay)
    if not hrp or not startPos or not targetPos then
        UltraLog("ERROR", "Invalid parameters for quantum movement")
        return false
    end
    
    local startTime = tick()
    local quantumPaths = {}
    
    -- Generar múltiples rutas cuánticas
    for i = 1, iterations do
        local progress = i / iterations
        
        -- Algoritmo Bézier cuántico con 4 puntos de control
        local p0 = startPos
        local p1 = startPos:Lerp(targetPos, 0.33) + Vector3.new(
            QuantumRandom(-5, 5, 2),
            QuantumRandom(-2, 2, 1.5),
            QuantumRandom(-5, 5, 2)
        )
        local p2 = startPos:Lerp(targetPos, 0.66) + Vector3.new(
            QuantumRandom(-3, 3, 1.8),
            QuantumRandom(-1, 1, 1.2),
            QuantumRandom(-3, 3, 1.8)
        )
        local p3 = targetPos
        
        -- Curva Bézier cúbica
        local t = progress
        local bezierPos = (1-t)^3 * p0 + 3*(1-t)^2*t * p1 + 3*(1-t)*t^2 * p2 + t^3 * p3
        
        -- Ruido cuántico multidimensional
        local quantumNoise = Vector3.new(
            math.sin(progress * math.pi * CONFIG.MOVEMENT.CURVE_COMPLEXITY) * CONFIG.MOVEMENT.JITTER_INTENSITY,
            math.cos(progress * math.pi * CONFIG.MOVEMENT.CURVE_COMPLEXITY * 1.7) * CONFIG.MOVEMENT.JITTER_INTENSITY,
            math.sin(progress * math.pi * CONFIG.MOVEMENT.CURVE_COMPLEXITY * 0.9) * CONFIG.MOVEMENT.JITTER_INTENSITY
        )
        
        -- Aplicar caos controlado
        local chaosVector = Vector3.new(
            QuantumRandom(-CONFIG.MOVEMENT.JITTER_INTENSITY, CONFIG.MOVEMENT.JITTER_INTENSITY, 3),
            QuantumRandom(-CONFIG.MOVEMENT.JITTER_INTENSITY, CONFIG.MOVEMENT.JITTER_INTENSITY, 2),
            QuantumRandom(-CONFIG.MOVEMENT.JITTER_INTENSITY, CONFIG.MOVEMENT.JITTER_INTENSITY, 3)
        )
        
        quantumPaths[i] = bezierPos + quantumNoise + chaosVector
    end
    
    -- Ejecutar movimiento cuántico
    for i, position in ipairs(quantumPaths) do
        if not hrp or not hrp.Parent then break end
        
        -- Rotación cuántica
        local currentRotation = hrp.CFrame - hrp.Position
        local quantumRotation = CFrame.Angles(
            QuantumRandom(-0.008, 0.008, 1.5),
            QuantumRandom(-0.008, 0.008, 1.5),
            QuantumRandom(-0.008, 0.008, 1.5)
        )
        
        hrp.CFrame = CFrame.new(position) * currentRotation * quantumRotation
        
        -- Timing cuántico adaptativo
        local quantumDelay = naturalDelay + QuantumRandom(-naturalDelay * 0.4, naturalDelay * 0.4, 2)
        
        if CONFIG.ANTI_DETECTION.USE_HEARTBEAT_SYNC and i % 3 == 0 then
            RunService.Heartbeat:Wait()
        else
            task.wait(quantumDelay)
        end
        
        -- Verificación de integridad cuántica
        if i % 15 == 0 then
            if not hrp.Parent or not char.Parent then
                UltraLog("WARN", "Character integrity lost during quantum movement")
                return false
            end
        end
    end
    
    local executionTime = tick() - startTime
    UltraLog("SUCCESS", "Quantum movement completed", string.format("Time: %.3fs", executionTime))
    return true
end

-- ═══════════════════════════════════════════════════════════════
--                    BUSCADOR INTELIGENTE DE OBJETIVOS
-- ═══════════════════════════════════════════════════════════════

local function FindQuantumDeliveryTarget()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        UltraLog("ERROR", "Plots folder not found in workspace")
        return nil
    end
    
    local validTargets = {}
    local currentTime = tick()
    
    for _, plot in pairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            local yourBase = sign:FindFirstChild("YourBase")
            if yourBase and yourBase.Enabled then
                local hitbox = plot:FindFirstChild("DeliveryHitbox")
                if hitbox then
                    local distance = (hitbox.Position - hrp.Position).Magnitude
                    local accessibility = 1 / (distance + 1)
                    local priority = accessibility * (1 + math.sin(currentTime + distance) * 0.1)
                    
                    table.insert(validTargets, {
                        hitbox = hitbox,
                        distance = distance,
                        priority = priority,
                        plot = plot
                    })
                end
            end
        end
    end
    
    if #validTargets == 0 then
        UltraLog("WARN", "No valid delivery targets found")
        return nil
    end
    
    -- Selección inteligente basada en prioridad
    table.sort(validTargets, function(a, b) return a.priority > b.priority end)
    local selectedTarget = validTargets[1]
    
    UltraLog("SUCCESS", "Optimal target selected", string.format("Distance: %.2f, Priority: %.3f", selectedTarget.distance, selectedTarget.priority))
    return selectedTarget.hitbox
end

-- ═══════════════════════════════════════════════════════════════
--                  SECUENCIA DE TELEPORT CUÁNTICO
-- ═══════════════════════════════════════════════════════════════

local function ExecuteQuantumTeleportSequence(targetCFrame)
    local voidPositions = CONFIG.TELEPORT.VOID_POSITIONS
    local success = false
    
    for attempt = 1, CONFIG.TELEPORT.VERIFICATION_ATTEMPTS do
        UltraLog("INFO", "Starting quantum teleport sequence", string.format("Attempt: %d", attempt))
        
        -- Aplicar variación cuántica
        local variance = CONFIG.TELEPORT.POSITION_VARIANCE
        local quantumVariation = Vector3.new(
            QuantumRandom(-variance.X, variance.X, 2),
            QuantumRandom(-variance.Y, variance.Y, 1.5),
            QuantumRandom(-variance.Z, variance.Z, 2)
        )
        
        local finalTarget = targetCFrame + quantumVariation
        
        -- Secuencia de teleports cuánticos con caos controlado
        for burst = 1, CONFIG.TELEPORT.BURST_COUNT do
            -- Teleport al void cuántico
            local randomVoidIndex = math.random(1, #voidPositions)
            local quantumVoid = voidPositions[randomVoidIndex]
            
            hrp.CFrame = quantumVoid
            task.wait(QuantumRandom(0.03, 0.12, 2))
            
            -- Teleport al objetivo con microvariación
            local microVariation = Vector3.new(
                QuantumRandom(-0.5, 0.5, 3),
                QuantumRandom(-0.2, 0.2, 2),
                QuantumRandom(-0.5, 0.5, 3)
            )
            
            hrp.CFrame = finalTarget + microVariation
            task.wait(QuantumRandom(0.02, 0.08, 2.5))
            
            -- Teleport intermedio aleatorio (técnica anti-detección)
            if burst % 2 == 0 then
                local intermedio = finalTarget + Vector3.new(
                    QuantumRandom(-10, 10, 1),
                    QuantumRandom(5, 15, 1),
                    QuantumRandom(-10, 10, 1)
                )
                hrp.CFrame = CFrame.new(intermedio.Position)
                task.wait(QuantumRandom(0.01, 0.05, 3))
                hrp.CFrame = finalTarget
            end
        end
        
        -- Verificación cuántica
        task.wait(0.6)
        local distance = (hrp.Position - finalTarget.Position).Magnitude
        local isSuccess = distance <= CONFIG.TELEPORT.SAFETY_DISTANCE
        
        if isSuccess then
            success = true
            UltraLog("SUCCESS", "Quantum teleport sequence successful", string.format("Final distance: %.2f", distance))
            break
        else
            UltraLog("WARN", "Quantum teleport attempt failed", string.format("Attempt %d failed, distance: %.2f", attempt, distance))
        end
        
        if attempt < CONFIG.TELEPORT.VERIFICATION_ATTEMPTS then
            task.wait(QuantumRandom(0.4, 1.2, 1.5))
        end
    end
    
    return success
end

-- ═══════════════════════════════════════════════════════════════
--                   FUNCIÓN PRINCIPAL TWEEN STEAL ULTRA
-- ═══════════════════════════════════════════════════════════════

local function TweenStealQuantumUltra()
    if isExecuting then
        print("⚠️ TweenSteal ya está ejecutándose...")
        return false
    end
    
    isExecuting = true
    local startTime = tick()
    performanceData.attempts = performanceData.attempts + 1
    
    print("🚀 Iniciando TweenSteal Quantum Ultra...")
    UltraLog("INFO", "Starting TweenSteal Quantum Ultra execution")
    
    -- Verificaciones cuánticas iniciales
    if not setupCharacter() then
        UltraLog("ERROR", "Character setup failed")
        print("❌ Error: Configuración de personaje falló")
        isExecuting = false
        return false
    end
    
    -- Análisis de amenazas
    local threatLevel = DetectAdvancedAntiCheat()
    if threatLevel > 4 then
        UltraLog("WARN", "High threat level detected, adjusting stealth parameters", threatLevel)
        CONFIG.MOVEMENT.BASE_ITERATIONS = CONFIG.MOVEMENT.BASE_ITERATIONS * 1.8
        CONFIG.MOVEMENT.NATURAL_DELAY_MAX = CONFIG.MOVEMENT.NATURAL_DELAY_MAX * 2.5
        CONFIG.TELEPORT.BURST_COUNT = math.max(3, CONFIG.TELEPORT.BURST_COUNT - 2)
        print("🛡️ Modo sigiloso ultra activado debido a detección de amenazas")
    end
    
    -- Buscar objetivo cuántico
    print("🎯 Buscando objetivo óptimo...")
    local targetHitbox = FindQuantumDeliveryTarget()
    if not targetHitbox then
        print("❌ Error: No se encontró objetivo válido")
        isExecuting = false
        return false
    end
    
    -- Calcular configuración óptima
    local iterations, naturalDelay, pingFactor = CalculateUltraOptimalSettings()
    print(string.format("⚙️ Configuración óptima: %d iteraciones, %.4f delay, ping factor: %.2f", iterations, naturalDelay, pingFactor))
    
    -- Preparar coordenadas cuánticas
    local startPosition = hrp.Position
    local targetPosition = targetHitbox.CFrame.Position + Vector3.new(0, -2.5, 0)
    
    -- FASE 1: Movimiento Cuántico Sigiloso
    print("🌀 FASE 1: Ejecutando movimiento cuántico sigiloso...")
    UltraLog("INFO", "Phase 1: Starting quantum stealth movement")
    
    local movementSuccess = QuantumStealthMovement(startPosition, targetPosition, iterations, naturalDelay)
    
    if not movementSuccess then
        UltraLog("ERROR", "Quantum stealth movement failed")
        print("❌ Error: Movimiento cuántico sigiloso falló")
        isExecuting = false
        return false
    end
    
    task.wait(QuantumRandom(0.3, 0.8, 1))
    
    -- FASE 2: Secuencia de Teleport Cuántico
    print("⚡ FASE 2: Ejecutando secuencia de teleport cuántico...")
    UltraLog("INFO", "Phase 2: Starting quantum teleport sequence")
    
    local teleportTarget = targetHitbox.CFrame * CFrame.new(0, -2.5, 0)
    local teleportSuccess = ExecuteQuantumTeleportSequence(teleportTarget)
    
    -- Verificación final cuántica
    task.wait(1.2)
    local finalDistance = (hrp.Position - teleportTarget.Position).Magnitude
    local finalSuccess = finalDistance <= CONFIG.TELEPORT.SAFETY_DISTANCE
    
    -- Calcular estadísticas cuánticas
    local executionTime = tick() - startTime
    performanceData.lastExecutionTime = executionTime
    
    if executionTime < performanceData.bestTime then
        performanceData.bestTime = executionTime
    end
    if executionTime > performanceData.worstTime then
        performanceData.worstTime = executionTime
    end
    
    if finalSuccess then
        performanceData.successes = performanceData.successes + 1
        performanceData.avgTime = (performanceData.avgTime * (performanceData.successes - 1) + executionTime) / performanceData.successes
        
        UltraLog("SUCCESS", "TweenSteal Quantum Ultra completed successfully", 
                string.format("Time: %.2fs, Distance: %.2f", executionTime, finalDistance))
        
        print(string.format("✅ ¡TweenSteal Quantum Ultra EXITOSO! (%.2fs, %.1fm)", executionTime, finalDistance))
        
        -- Mostrar estadísticas
        local successRate = (performanceData.successes / performanceData.attempts) * 100
        print(string.format("📊 Estadísticas: %d/%d éxitos (%.1f%%), Mejor: %.2fs, Promedio: %.2fs", 
            performanceData.successes, performanceData.attempts, successRate, performanceData.bestTime, performanceData.avgTime))
        
        isExecuting = false
        return true
    else
        UltraLog("ERROR", "TweenSteal Quantum Ultra failed", 
                string.format("Time: %.2fs, Distance: %.2f", executionTime, finalDistance))
        
        print(string.format("❌ TweenSteal Quantum Ultra falló: Muy lejos (%.1fm)", finalDistance))
        isExecuting = false
        return false
    end
end

-- ═══════════════════════════════════════════════════════════════
--                        CONTROLES Y ACTIVACIÓN
-- ═══════════════════════════════════════════════════════════════

local function showStats()
    local successRate = performanceData.attempts > 0 and (performanceData.successes / performanceData.attempts * 100) or 0
    print("═══════════════════════════════════════")
    print("📈 ESTADÍSTICAS TWEEN STEAL QUANTUM ULTRA")
    print("═══════════════════════════════════════")
    print(string.format("🎯 Intentos totales: %d", performanceData.attempts))
    print(string.format("✅ Éxitos: %d", performanceData.successes))
    print(string.format("📊 Tasa de éxito: %.1f%%", successRate))
    print(string.format("⚡ Mejor tiempo: %.2fs", performanceData.bestTime == math.huge and 0 or performanceData.bestTime))
    print(string.format("📈 Tiempo promedio: %.2fs", performanceData.avgTime))
    print(string.format("🕐 Último tiempo: %.2fs", performanceData.lastExecutionTime))
    print("═══════════════════════════════════════")
end

-- Configurar controles
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        TweenStealQuantumUltra()
    elseif input.KeyCode == Enum.KeyCode.G then
        showStats()
    elseif input.KeyCode == Enum.KeyCode.H then
        print("═══════════════════════════════════════")
        print("🎮 CONTROLES TWEEN STEAL QUANTUM ULTRA")
        print("═══════════════════════════════════════")
        print("T - Ejecutar TweenSteal Quantum Ultra")
        print("G - Mostrar estadísticas detalladas")
        print("H - Mostrar esta ayuda")
        print("═══════════════════════════════════════")
    end
end)

-- ═══════════════════════════════════════════════════════════════
--                           INTERFAZ GRÁFICA ULTRA
-- ═══════════════════════════════════════════════════════════════

local function createUltraGUI()
    -- Crear ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TweenStealQuantumUltraGUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 550, 0, 480)
    MainFrame.ClipsDescendants = true

    -- Esquinas redondeadas
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 20)
    UICorner.Parent = MainFrame

    -- Gradiente de fondo
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    UIGradient.Rotation = 45
    UIGradient.Parent = MainFrame

    -- Sombra
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = MainFrame
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.4
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = -1

    -- Barra de título
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.ZIndex = 2

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 20)
    TitleCorner.Parent = TitleBar

    -- Título
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.Text = "🚀 TWEEN STEAL QUANTUM ULTRA V3.0"
    TitleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Botón cerrar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.Position = UDim2.new(1, -40, 0, 10)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseButton

    -- Contenido principal
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 0, 0, 50)
    ContentFrame.Size = UDim2.new(1, 0, 1, -50)

    -- Botón principal EJECUTAR
    local ExecuteButton = Instance.new("TextButton")
    ExecuteButton.Name = "ExecuteButton"
    ExecuteButton.Parent = ContentFrame
    ExecuteButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    ExecuteButton.Position = UDim2.new(0.1, 0, 0.05, 0)
    ExecuteButton.Size = UDim2.new(0.8, 0, 0, 60)
    ExecuteButton.Font = Enum.Font.GothamBold
    ExecuteButton.Text = "🚀 EJECUTAR TWEEN STEAL QUANTUM ULTRA"
    ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExecuteButton.TextSize = 18
    ExecuteButton.AutoButtonColor = false

    local ExecuteCorner = Instance.new("UICorner")
    ExecuteCorner.CornerRadius = UDim.new(0, 15)
    ExecuteCorner.Parent = ExecuteButton

    local ExecuteStroke = Instance.new("UIStroke")
    ExecuteStroke.Parent = ExecuteButton
    ExecuteStroke.Color = Color3.fromRGB(100, 200, 255)
    ExecuteStroke.Thickness = 2

    -- Label de estado
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = ContentFrame
    StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    StatusLabel.Position = UDim2.new(0.1, 0, 0.22, 0)
    StatusLabel.Size = UDim2.new(0.8, 0, 0, 50)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "💤 Listo para ejecutar..."
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusLabel.TextSize = 16
    StatusLabel.TextWrapped = true

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = StatusLabel

    -- Frame de estadísticas
    local StatsFrame = Instance.new("Frame")
    StatsFrame.Name = "StatsFrame"
    StatsFrame.Parent = ContentFrame
    StatsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    StatsFrame.Position = UDim2.new(0.1, 0, 0.38, 0)
    StatsFrame.Size = UDim2.new(0.8, 0, 0, 120)

    local StatsCorner = Instance.new("UICorner")
    StatsCorner.CornerRadius = UDim.new(0, 10)
    StatsCorner.Parent = StatsFrame

    local StatsTitle = Instance.new("TextLabel")
    StatsTitle.Name = "StatsTitle"
    StatsTitle.Parent = StatsFrame
    StatsTitle.BackgroundTransparency = 1
    StatsTitle.Size = UDim2.new(1, 0, 0, 30)
    StatsTitle.Font = Enum.Font.GothamBold
    StatsTitle.Text = "📊 ESTADÍSTICAS"
    StatsTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    StatsTitle.TextSize = 16

    local AttemptsLabel = Instance.new("TextLabel")
    AttemptsLabel.Name = "AttemptsLabel"
    AttemptsLabel.Parent = StatsFrame
    AttemptsLabel.BackgroundTransparency = 1
    AttemptsLabel.Position = UDim2.new(0, 10, 0, 30)
    AttemptsLabel.Size = UDim2.new(0.5, -10, 0, 20)
    AttemptsLabel.Font = Enum.Font.Gotham
    AttemptsLabel.Text = "🎯 Intentos: 0"
    AttemptsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    AttemptsLabel.TextSize = 14
    AttemptsLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SuccessLabel = Instance.new("TextLabel")
    SuccessLabel.Name = "SuccessLabel"
    SuccessLabel.Parent = StatsFrame
    SuccessLabel.BackgroundTransparency = 1
    SuccessLabel.Position = UDim2.new(0.5, 0, 0, 30)
    SuccessLabel.Size = UDim2.new(0.5, -10, 0, 20)
    SuccessLabel.Font = Enum.Font.Gotham
    SuccessLabel.Text = "✅ Éxitos: 0"
    SuccessLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SuccessLabel.TextSize = 14
    SuccessLabel.TextXAlignment = Enum.TextXAlignment.Left

    local RateLabel = Instance.new("TextLabel")
    RateLabel.Name = "RateLabel"
    RateLabel.Parent = StatsFrame
    RateLabel.BackgroundTransparency = 1
    RateLabel.Position = UDim2.new(0, 10, 0, 50)
    RateLabel.Size = UDim2.new(0.5, -10, 0, 20)
    RateLabel.Font = Enum.Font.Gotham
    RateLabel.Text = "📈 Tasa: 0%"
    RateLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    RateLabel.TextSize = 14
    RateLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TimeLabel = Instance.new("TextLabel")
    TimeLabel.Name = "TimeLabel"
    TimeLabel.Parent = StatsFrame
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Position = UDim2.new(0.5, 0, 0, 50)
    TimeLabel.Size = UDim2.new(0.5, -10, 0, 20)
    TimeLabel.Font = Enum.Font.Gotham
    TimeLabel.Text = "⏱️ Último: 0s"
    TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TimeLabel.TextSize = 14
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local BestLabel = Instance.new("TextLabel")
    BestLabel.Name = "BestLabel"
    BestLabel.Parent = StatsFrame
    BestLabel.BackgroundTransparency = 1
    BestLabel.Position = UDim2.new(0, 10, 0, 70)
    BestLabel.Size = UDim2.new(0.5, -10, 0, 20)
    BestLabel.Font = Enum.Font.Gotham
    BestLabel.Text = "⚡ Mejor: 0s"
    BestLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    BestLabel.TextSize = 14
    BestLabel.TextXAlignment = Enum.TextXAlignment.Left

    local AvgLabel = Instance.new("TextLabel")
    AvgLabel.Name = "AvgLabel"
    AvgLabel.Parent = StatsFrame
    AvgLabel.BackgroundTransparency = 1
    AvgLabel.Position = UDim2.new(0.5, 0, 0, 70)
    AvgLabel.Size = UDim2.new(0.5, -10, 0, 20)
    AvgLabel.Font = Enum.Font.Gotham
    AvgLabel.Text = "📊 Promedio: 0s"
    AvgLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    AvgLabel.TextSize = 14
    AvgLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Botones de configuración
    local ConfigFrame = Instance.new("Frame")
    ConfigFrame.Name = "ConfigFrame"
    ConfigFrame.Parent = ContentFrame
    ConfigFrame.BackgroundTransparency = 1
    ConfigFrame.Position = UDim2.new(0.1, 0, 0.7, 0)
    ConfigFrame.Size = UDim2.new(0.8, 0, 0, 80)

    local StatsButton = Instance.new("TextButton")
    StatsButton.Name = "StatsButton"
    StatsButton.Parent = ConfigFrame
    StatsButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    StatsButton.Position = UDim2.new(0, 0, 0, 0)
    StatsButton.Size = UDim2.new(0.48, -5, 0, 35)
    StatsButton.Font = Enum.Font.Gotham
    StatsButton.Text = "📊 Actualizar Stats"
    StatsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatsButton.TextSize = 14

    local StatsButtonCorner = Instance.new("UICorner")
    StatsButtonCorner.CornerRadius = UDim.new(0, 8)
    StatsButtonCorner.Parent = StatsButton

    local HelpButton = Instance.new("TextButton")
    HelpButton.Name = "HelpButton"
    HelpButton.Parent = ConfigFrame
    HelpButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
    HelpButton.Position = UDim2.new(0.52, 5, 0, 0)
    HelpButton.Size = UDim2.new(0.48, -5, 0, 35)
    HelpButton.Font = Enum.Font.Gotham
    HelpButton.Text = "❓ Ayuda"
    HelpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HelpButton.TextSize = 14

    local HelpButtonCorner = Instance.new("UICorner")
    HelpButtonCorner.CornerRadius = UDim.new(0, 8)
    HelpButtonCorner.Parent = HelpButton

    local ControlsLabel = Instance.new("TextLabel")
    ControlsLabel.Name = "ControlsLabel"
    ControlsLabel.Parent = ConfigFrame
    ControlsLabel.BackgroundTransparency = 1
    ControlsLabel.Position = UDim2.new(0, 0, 0, 45)
    ControlsLabel.Size = UDim2.new(1, 0, 0, 30)
    ControlsLabel.Font = Enum.Font.Gotham
    ControlsLabel.Text = "🎮 Controles: T=Ejecutar | G=Stats | H=Ayuda"
    ControlsLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    ControlsLabel.TextSize = 12

    -- Función para actualizar estadísticas en la GUI
    local function updateStatsGUI()
        local successRate = performanceData.attempts > 0 and (performanceData.successes / performanceData.attempts * 100) or 0
        
        AttemptsLabel.Text = string.format("🎯 Intentos: %d", performanceData.attempts)
        SuccessLabel.Text = string.format("✅ Éxitos: %d", performanceData.successes)
        RateLabel.Text = string.format("📈 Tasa: %.1f%%", successRate)
        TimeLabel.Text = string.format("⏱️ Último: %.2fs", performanceData.lastExecutionTime)
        BestLabel.Text = string.format("⚡ Mejor: %.2fs", performanceData.bestTime == math.huge and 0 or performanceData.bestTime)
        AvgLabel.Text = string.format("📊 Promedio: %.2fs", performanceData.avgTime)
        
        -- Cambiar color basado en tasa de éxito
        if successRate >= 80 then
            RateLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        elseif successRate >= 50 then
            RateLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        else
            RateLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end

    -- Función para actualizar estado
    local function updateStatus(message, color)
        StatusLabel.Text = message
        StatusLabel.TextColor3 = color or Color3.fromRGB(150, 150, 150)
        
        -- Efecto de parpadeo
        TweenService:Create(StatusLabel, TweenInfo.new(0.2), {
            TextTransparency = 0.3
        }):Play()
        
        task.wait(0.2)
        
        TweenService:Create(StatusLabel, TweenInfo.new(0.2), {
            TextTransparency = 0
        }):Play()
    end

    -- Eventos de botones
    ExecuteButton.MouseButton1Click:Connect(function()
        if isExecuting then
            updateStatus("⚠️ Ya se está ejecutando...", Color3.fromRGB(255, 200, 100))
            return
        end
        
        updateStatus("🚀 Iniciando TweenSteal Quantum Ultra...", Color3.fromRGB(100, 200, 255))
        
        task.spawn(function()
            local success = TweenStealQuantumUltra()
            updateStatsGUI()
            
            if success then
                updateStatus("✅ ¡Ejecutado exitosamente!", Color3.fromRGB(100, 255, 100))
            else
                updateStatus("❌ Ejecución falló", Color3.fromRGB(255, 100, 100))
            end
        end)
    end)

    StatsButton.MouseButton1Click:Connect(function()
        updateStatsGUI()
        updateStatus("📊 Estadísticas actualizadas", Color3.fromRGB(100, 200, 255))
    end)

    HelpButton.MouseButton1Click:Connect(function()
        updateStatus("❓ Revisa la consola para ayuda", Color3.fromRGB(200, 100, 255))
        showStats()
    end)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Efectos hover para botones
    local function addHoverEffect(button, hoverColor, normalColor)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = hoverColor,
                Size = button.Size + UDim2.new(0, 0, 0, 2)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = normalColor,
                Size = button.Size - UDim2.new(0, 0, 0, 2)
            }):Play()
        end)
    end

    addHoverEffect(ExecuteButton, Color3.fromRGB(70, 170, 255), Color3.fromRGB(50, 150, 255))
    addHoverEffect(StatsButton, Color3.fromRGB(100, 140, 220), Color3.fromRGB(80, 120, 200))
    addHoverEffect(HelpButton, Color3.fromRGB(140, 100, 220), Color3.fromRGB(120, 80, 200))
    addHoverEffect(CloseButton, Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 80, 80))

    -- Hacer draggable
    local dragging = false
    local dragInput, dragStart, startPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
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
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Animación de entrada
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.BackgroundTransparency = 1
    
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 550, 0, 480),
        BackgroundTransparency = 0
    }):Play()

    -- Actualizar estadísticas iniciales
    updateStatsGUI()
    
    print("🎮 GUI de TweenSteal Quantum Ultra cargada exitosamente!")
    return ScreenGui, updateStatus, updateStatsGUI
end

-- ═══════════════════════════════════════════════════════════════
--                           INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════════

print("╔══════════════════════════════════════════════════════════════╗")
print("║              🚀 TWEEN STEAL QUANTUM ULTRA V3.0 🚀            ║")
print("║                      ¡CARGADO EXITOSAMENTE!                 ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  🎮 Controles:                                              ║")
print("║  • T - Ejecutar TweenSteal Quantum Ultra                    ║")
print("║  • G - Mostrar estadísticas                                 ║")
print("║  • H - Mostrar ayuda                                        ║")
print("║                                                              ║")
print("║  ⚡ Mejoras Ultra:                                           ║")
print("║  • Algoritmo cuántico de movimiento                         ║")
print("║  • Anti-detección avanzada                                  ║")
print("║  • Optimización automática                                  ║")
print("║  • Teleport en ráfagas múltiples                           ║")
print("║  • Sistema de estadísticas                                  ║")
print("║  • Interfaz gráfica completa                                ║")
print("╚══════════════════════════════════════════════════════════════╝")

-- Crear y mostrar la GUI
local gui, updateStatusGUI, updateStatsGUI = createUltraGUI()

-- Actualizar la función principal para usar la GUI
local originalTweenSteal = TweenStealQuantumUltra
TweenStealQuantumUltra = function()
    local result = originalTweenSteal()
    if updateStatsGUI then
        updateStatsGUI()
    end
    return result
end 
