local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local markPosition = nil
local isStealActive = false
local isMinimized = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealBrainRotGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 275)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -137.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Size = UDim2.new(1, 0, 0, 40)
titleFrame.Position = UDim2.new(0, 0, 0, 0)
titleFrame.BackgroundTransparency = 1
titleFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🧠 Steal A Brainrot"
titleLabel.TextColor3 = Color3.fromRGB(255, 100, 150)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleFrame

local titleGlow = Instance.new("UIStroke")
titleGlow.Color = Color3.fromRGB(255, 100, 150)
titleGlow.Thickness = 1
titleGlow.Transparency = 0.3
titleGlow.Parent = titleLabel

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextScaled = true
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = titleFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 15)
minCorner.Parent = minimizeButton

local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, -20, 1, -60)
buttonContainer.Position = UDim2.new(0, 10, 0, 50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local function createButton(name, text, position, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 45)
    button.Position = position
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = buttonContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = color
    buttonStroke.Thickness = 1
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = button
    
    local hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)
    })
    local normalTween = TweenService:Create(button, TweenInfo.new(0.2), {
        BackgroundColor3 = color
    })
    
    button.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        normalTween:Play()
    end)
    
    return button
end

local stealButton = createButton("StealButton", "🔥 STEAL", UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 60, 60))
local goDownButton = createButton("GoDownButton", "⬇️ GO DOWN", UDim2.new(0, 0, 0, 55), Color3.fromRGB(60, 150, 255))
local markButton = createButton("MarkButton", "📍 MARK", UDim2.new(0, 0, 0, 110), Color3.fromRGB(60, 255, 60))
local serverHopButton = createButton("ServerHopButton", "🔄 SERVER HOP", UDim2.new(0, 0, 0, 165), Color3.fromRGB(255, 165, 0))

local function steal()
    if not markPosition or isStealActive then return end
    
    isStealActive = true
    stealButton.Text = "🔥 STEALING..."
    
    local currentPos = rootPart.Position
    local targetPos = markPosition
    local distance = (targetPos - currentPos).Magnitude
    
    local steps = math.ceil(distance / 0.85)
    local stepSize = (targetPos - currentPos) / steps
    
    local currentStep = 0
    local stepConnection
    stepConnection = game:GetService("RunService").Heartbeat:Connect(function()
        currentStep = currentStep + 1
        if currentStep <= steps then
            local nextPos = currentPos + (stepSize * currentStep)
            rootPart.CFrame = CFrame.new(nextPos)
            wait(0.10)
        else
            stepConnection:Disconnect()
            wait(0.1)
            rootPart.CFrame = CFrame.new(markPosition + Vector3.new(0, 200, 0))
            stealButton.Text = "🔥 STEAL"
            isStealActive = false
        end
    end)
end

local function goDown()
    local currentPosition = rootPart.Position
    rootPart.CFrame = CFrame.new(currentPosition - Vector3.new(0, 200, 0))
end

local function mark()
    markPosition = rootPart.Position
    
    local existingMark = workspace:FindFirstChild("PlayerMark")
    if existingMark then
        existingMark:Destroy()
    end
    
    local markPart = Instance.new("Part")
    markPart.Name = "PlayerMark"
    markPart.Size = Vector3.new(4, 1, 4)
    markPart.Position = markPosition
    markPart.Material = Enum.Material.Neon
    markPart.BrickColor = BrickColor.new("Bright green")
    markPart.CanCollide = false
    markPart.Anchored = true
    markPart.Shape = Enum.PartType.Cylinder
    markPart.Parent = workspace
    
    local pulseTween = TweenService:Create(markPart, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Transparency = 0.5
    })
    pulseTween:Play()
end

local function serverHop()
    serverHopButton.Text = "🔄 HOPPING..."
    
    local success, result = pcall(function()
        local placeId = game.PlaceId
        
        local servers = game:GetService("HttpService"):JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
        )
        
        if servers and servers.data and #servers.data > 0 then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                    return true
                end
            end
        end
        
        TeleportService:Teleport(placeId, player)
        return true
    end)
    
    if not success then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end
    
    spawn(function()
        wait(5)
        if serverHopButton then
            serverHopButton.Text = "🔄 SERVER HOP"
        end
    end)
end

local function toggleMinimize()
    if isMinimized then
        local expandTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 280, 0, 275)
        })
        expandTween:Play()
        minimizeButton.Text = "−"
        buttonContainer.Visible = true
        isMinimized = false
    else
        local minimizeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 280, 0, 40)
        })
        minimizeTween:Play()
        minimizeButton.Text = "+"
        buttonContainer.Visible = false
        isMinimized = true
    end
end

stealButton.MouseButton1Click:Connect(steal)
goDownButton.MouseButton1Click:Connect(goDown)
markButton.MouseButton1Click:Connect(mark)
serverHopButton.MouseButton1Click:Connect(serverHop)
minimizeButton.MouseButton1Click:Connect(toggleMinimize)

local dragging = false
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    mainFrame.Position = newPosition
end

titleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            updateInput(input)
        end
    end
end)

mainFrame.Size = UDim2.new(0, 0, 0, 0)
local appearTween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 280, 0, 275)
})
appearTween:Play()

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    rootPart = character:WaitForChild("HumanoidRootPart")
end)
