local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Mouse = LocalPlayer:GetMouse()
local WS = Workspace
local RS = RunService
local UIS = UserInputService

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScreenGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Name = "Frame"
Frame.Position = UDim2.new(0.216699, 0, 0.152778, 0)
Frame.Size = UDim2.new(0, 772, 0, 453)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.ZIndex = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.Name = "UICorner"
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local ImageLabel = Instance.new("ImageLabel")
ImageLabel.Name = "ImageLabel"
ImageLabel.Size = UDim2.new(0, 773, 0, 450)
ImageLabel.BackgroundTransparency = 1
ImageLabel.BorderSizePixel = 0
ImageLabel.Image = "rbxassetid://136450056883088"
ImageLabel.Transparency = 1
ImageLabel.Parent = Frame

local Frame2 = Instance.new("Frame")
Frame2.Name = "Frame"
Frame2.Position = UDim2.new(0.0170344, 0, 0.0243633, 0)
Frame2.Size = UDim2.new(0, 745, 0, 427)
Frame2.BackgroundColor3 = Color3.new(0, 0, 0)
Frame2.BackgroundTransparency = 0.6
Frame2.BorderSizePixel = 0
Frame2.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.Name = "UICorner"
UICorner2.CornerRadius = UDim.new(0, 10)
UICorner2.Parent = Frame2

local Frame3 = Instance.new("Frame")
Frame3.Name = "Frame"
Frame3.Size = UDim2.new(0, 198, 1, 0)  -- теперь высота = 100% от Frame
Frame3.Position = UDim2.new(0, 0, 0, 0)  -- прижат к левому краю
Frame3.BackgroundColor3 = Color3.new(0, 0, 0)
Frame3.BackgroundTransparency = 1
Frame3.BorderSizePixel = 0
Frame3.Parent = Frame

local UICorner3 = Instance.new("UICorner")
UICorner3.Name = "UICorner"
UICorner3.CornerRadius = UDim.new(0, 10)
UICorner3.Parent = Frame3

-- ===== ПУЛЬСИРУЮЩАЯ ЛИНИЯ =====
local PulseFrame = Instance.new("Frame")
PulseFrame.Parent = Frame3
PulseFrame.Size = UDim2.new(0.8, 0, 0, 50)
PulseFrame.Position = UDim2.new(0.5, 0, 0.08, 0)
PulseFrame.AnchorPoint = Vector2.new(0.5, 0.5)
PulseFrame.BackgroundTransparency = 1
PulseFrame.ClipsDescendants = true

local SHAPE = {
    Vector2.new(0.00, 0.50),
    Vector2.new(0.10, 0.50),
    Vector2.new(0.20, 0.50),
    Vector2.new(0.30, 0.50),
    Vector2.new(0.37, 0.50),
    Vector2.new(0.42, 0.15),
    Vector2.new(0.45, 0.50),
    Vector2.new(0.48, 0.90),
    Vector2.new(0.51, 0.50),
    Vector2.new(0.57, 0.50),
    Vector2.new(0.63, 0.50),
    Vector2.new(0.70, 0.50),
    Vector2.new(0.78, 0.50),
    Vector2.new(0.86, 0.50),
    Vector2.new(0.95, 0.50),
    Vector2.new(1.00, 0.50),
}

local CYCLE = 2.8
local TRAIL_FRACTION = 0.3
local points = {}
local numPoints = 50
local spacing = 5

task.wait(0.1)
spacing = (PulseFrame.AbsoluteSize.X - 10) / numPoints

local function GetY(x)
    for j = 1, #SHAPE - 1 do
        local p0 = SHAPE[j]
        local p1 = SHAPE[j + 1]
        if x >= p0.X and x <= p1.X then
            local f = (x - p0.X) / (p1.X - p0.X)
            return p0.Y + (p1.Y - p0.Y) * f
        end
    end
    return 0.5
end

for i = 1, numPoints do
    local point = Instance.new("Frame")
    point.Parent = PulseFrame
    point.Size = UDim2.new(0, 2.5, 0, 0)
    point.Position = UDim2.new(0, 5 + (i-1) * spacing, 0.5, 0)
    point.AnchorPoint = Vector2.new(0.5, 0.5)
    point.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    point.BackgroundTransparency = 1
    local corner = Instance.new("UICorner")
    corner.Parent = point
    corner.CornerRadius = UDim.new(1, 0)
    table.insert(points, point)
end

local startTime = os.clock()

local function AnimatePulse()
    while PulseFrame and PulseFrame.Parent do
        local elapsed = os.clock() - startTime
        local cycleTime = CYCLE * 2
        local t = elapsed % cycleTime
        local progress = t / cycleTime
        local headX
        if progress <= 0.5 then
            headX = progress * 2
        else
            headX = 2 - progress * 2
        end
        for i, point in ipairs(points) do
            local x = i / #points
            local y = GetY(x)
            local dist = math.abs(x - headX)
            if dist < TRAIL_FRACTION then
                local alpha = 1 - dist / TRAIL_FRACTION
                point.BackgroundTransparency = 1 - alpha * 0.7
                point.Size = UDim2.new(0, 2.5, 0, math.abs(y - 0.5) * 35 + 2)
                point.Position = UDim2.new(0, 5 + (i-1) * spacing, 0.5, -(y - 0.5) * 35)
                point.BackgroundColor3 = Color3.fromRGB(255, math.floor(50 * (1 - alpha)), math.floor(20 * (1 - alpha)))
            else
                point.BackgroundTransparency = 1
            end
        end
        task.wait(0.016)
    end
end

task.spawn(AnimatePulse)

-- ===== ТАБЫ =====
local TabNames = {"Main", "Visuals", "Auras", "World", "Info"}
local Tabs = {}
local CurrentTab = 1

local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Parent = Frame2 -- Меняем родителя на Frame2 (основной контейнер справа)
TabScroll.Size = UDim2.new(0.25, 0, 0.65, 0) -- Ширина 25% от Frame2
TabScroll.Position = UDim2.new(0.02, 0, 0.2, 0) -- Чуть-чуть слева в Frame2
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness = 0
TabScroll.Active = true
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScroll.ZIndex = 5

local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabScroll
-- ... (остальной код без изменений)

local TabContainer = Instance.new("Frame")
TabContainer.Parent = Frame2 -- Меняем родителя на Frame2
TabContainer.Size = UDim2.new(0.73, 0, 0.9, 0) -- Занимает 73% ширины Frame2 (остальное под TabScroll)
TabContainer.Position = UDim2.new(0.26, 0, 0.10, 0) -- Сдвигаем вправо от TabScroll
TabContainer.BackgroundTransparency = 1
TabContainer.ClipsDescendants = true
TabContainer.ZIndex = 5

-- ===== КНОПКА ВЫХОДА =====
local UnloadButton = Instance.new("TextButton")
UnloadButton.Name = "UnloadButton"
UnloadButton.Position = UDim2.new(0.94, 0, 0.01, 13)
UnloadButton.Size = UDim2.new(0, 30, 0, 30)
UnloadButton.Text = "x"
UnloadButton.TextColor3 = Color3.new(1, 1, 1)
UnloadButton.TextSize = 20
UnloadButton.TextScaled = true
UnloadButton.BackgroundColor3 = Color3.new(1, 0, 0)
UnloadButton.BackgroundTransparency = 1
UnloadButton.BorderSizePixel = 0
UnloadButton.Parent = Frame
UnloadButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local UnloadCorner = Instance.new("UICorner")
UnloadCorner.Name = "UnloadCorner"
UnloadCorner.CornerRadius = UDim.new(0, 5)
UnloadCorner.Parent = UnloadButton

local dragging = false
local dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        -- Frame3 перемещается автоматически, потому что он внутри Frame
    end
end)

-- ===== КОНФИГ =====
local Config = {
    SpeedEnabled = false, SpeedValue = 16,
    TpEnabled = false, TpHeight = 10,
    SpinEnabled = false, SpinSpeed = 15, SpinMode = "Spin",
    SkipMapEnabled = false, SkipMapPos = Vector3.new(0, 5000, 0), SkipMapPlatform = nil, SkipMapConnection = nil,
    TpWalkEnabled = false, TpWalkValue = 1,
    SuperBounceEnabled = false, SuperBounceHeight = 190,
    SuperJumpEnabled = false, SuperJumpPower = 250,
    DefibAura = false, DefibRange = 20, DefibConnection = nil,
    BuildOffsetEnabled = false, BuildOffsetX = 0, BuildOffsetY = 0, BuildOffsetZ = 0,
    AutoWhistleEnabled = false, WhistleConnection = nil,
    GodModeEnabled = false, GodModeConnection = nil,
    SelfReviveEnabled = false, ReviveConnection = nil,
    GravityEnabled = false, GravityValue = 196.2,
    JumpPadEnabled = false, JumpPadValue = 360,
    MagicAura = false, MagicAuraCount = 3, MagicAuraRadius = 3, MagicAuraSpeed = 2,
    WingsAura = false, WingsColor = Color3.fromRGB(255, 150, 200), WingsSize = 3, WingsCount = 10, WingsOffsetX = 0, WingsOffsetY = 0, WingsOffsetZ = 0,
    BHopEnabled = false, IsHoldingJump = false,
    RainEnabled = false, RainSpeed = 30, RainDensity = 50, RainColor = Color3.fromRGB(255, 150, 200), RainCircleSize = 2, RainCircleTransparency = 0.3,
    TeleportCoords = "",
}

local Flags = {}
local AllItems = {}

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====
function isPlayerDowned(player)
    if not player or not player.Character then return false end
    local char = player.Character
    if char:GetAttribute("Downed") == true then return true end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
    return false
end

function teleportToCFrame(cframeOffset)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cframeOffset
    end
end

function teleportToRandomSpawn(offset)
    local spawnsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Parts") and workspace.Map.Parts:FindFirstChild("Spawns")
    if not spawnsFolder then
        spawnsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Map") and workspace.Game.Map:FindFirstChild("Parts") and workspace.Game.Map.Parts:FindFirstChild("Spawns")
    end
    if spawnsFolder then
        local spawns = spawnsFolder:GetChildren()
        if #spawns > 0 then
            local target = spawns[math.random(1, #spawns)]
            teleportToCFrame(target.CFrame + offset)
        end
    end
end

function teleportToRandomPlayer(offset)
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, player)
        end
    end
    if #players > 0 then
        local target = players[math.random(1, #players)]
        teleportToCFrame(target.Character.HumanoidRootPart.CFrame + offset)
    end
end

function teleportToRandomDowned(offset)
    local downed = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isPlayerDowned(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(downed, player.Character)
        end
    end
    if #downed > 0 then
        local target = downed[math.random(1, #downed)]
        local hrp = target:FindFirstChild("HumanoidRootPart")
        if hrp then
            teleportToCFrame(hrp.CFrame + offset)
        end
    end
end

function teleportToRandomTicket(offset)
    local ticketsFolder = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
    if ticketsFolder then
        local tickets = ticketsFolder:GetChildren()
        if #tickets > 0 then
            local target = tickets[math.random(1, #tickets)]
            local part = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart")
            if part then
                teleportToCFrame(part.CFrame + offset)
            end
        end
    end
end

function teleportToSecurityPart(offset)
    local securityPart = workspace:FindFirstChild("SecurityPart")
    if not securityPart then
        securityPart = Instance.new("Part")
        securityPart.Name = "SecurityPart"
        securityPart.Size = Vector3.new(10, 1, 10)
        securityPart.Position = Vector3.new(50000, 50000, 50000)
        securityPart.Anchored = true
        securityPart.CanCollide = true
        securityPart.Parent = workspace
    end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(securityPart.Position + offset)
    end
end

-- ===== ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ UI =====
local function CreateTab(name)
    local tabIndex = #Tabs + 1
    
    local Button = Instance.new("TextButton")
    Button.Parent = TabScroll
    Button.Size = UDim2.new(0.9, 0, 0, 32)
    Button.BackgroundColor3 = Color3.new(0, 0, 0)
    Button.BackgroundTransparency = 1
    Button.Text = "  " .. name
    Button.TextColor3 = Color3.fromRGB(150, 150, 150)
    Button.TextSize = 13
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Font = Enum.Font.GothamMedium
    Button.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = Button
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    local Content = Instance.new("Frame")
    Content.Parent = TabContainer
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.BackgroundTransparency = 1
    Content.Visible = (tabIndex == 1)
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Parent = Content
    Scroll.Size = UDim2.new(1, -5, 1, -5)
    Scroll.Position = UDim2.new(0.5, 0, 0.5, 0)
    Scroll.AnchorPoint = Vector2.new(0.5, 0.5)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 0
    Scroll.Active = true
    Scroll.ClipsDescendants = true
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Scroll
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 2)
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 5)
    end)
    
    local function ShowTab()
        for i, tab in ipairs(Tabs) do
            tab.Content.Visible = (i == tabIndex)
            if i == tabIndex then
                tab.Button.TextColor3 = Color3.fromRGB(255, 0, 0)
                tab.Button.BackgroundTransparency = 0.9
            else
                tab.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
                tab.Button.BackgroundTransparency = 1
            end
        end
        CurrentTab = tabIndex
    end
    
    Button.MouseButton1Click:Connect(ShowTab)
    
    local tabData = {
        Button = Button,
        Content = Content,
        Scroll = Scroll,
        Layout = Layout,
        Show = ShowTab
    }
    table.insert(Tabs, tabData)
    
    if tabIndex == 1 then
        ShowTab()
    end
    
    function tabData:AddSection(config)
        config = config or {}
        local sectionName = config.Name or "SECTION"
        
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Parent = Scroll
        SectionFrame.Size = UDim2.new(1, -5, 0, 0)
        SectionFrame.BackgroundTransparency = 1
        SectionFrame.ClipsDescendants = true
        
        -- СЕРЫЙ ТЕКСТ РАЗДЕЛА
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Parent = SectionFrame
        SectionLabel.Size = UDim2.new(1, 0, 0, 20)
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Text = sectionName
        SectionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        SectionLabel.TextSize = 11
        SectionLabel.Font = Enum.Font.GothamMedium
        SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        SectionLabel.TextTransparency = 0.3
        
        table.insert(AllItems, {Root = SectionLabel, Name = sectionName})
        
        local SectionHandler = Instance.new("Frame")
        SectionHandler.Parent = SectionFrame
        SectionHandler.Size = UDim2.new(1, 0, 1, -22)
        SectionHandler.Position = UDim2.new(0, 0, 0, 22)
        SectionHandler.BackgroundTransparency = 1
        SectionHandler.ClipsDescendants = true
        
        local SectionLayout = Instance.new("UIListLayout")
        SectionLayout.Parent = SectionHandler
        SectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SectionLayout.Padding = UDim.new(0, 1)
        
        SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if SectionLayout.AbsoluteContentSize.Y <= 1 then
                SectionFrame.Size = UDim2.new(1, -5, 0, 22)
            else
                SectionFrame.Size = UDim2.new(1, -5, 0, SectionLayout.AbsoluteContentSize.Y + 22)
            end
        end)
        
        local sectionData = {
            Root = SectionHandler,
            Layout = SectionLayout,
            Frame = SectionFrame,
            Label = SectionLabel
        }
        
        function sectionData:AddToggle(config)
            config = config or {}
            local defaultValue = config.Default or false
            local callback = config.Callback or function() end
            local flag = config.Flag or nil
            local name = config.Name or "Toggle"
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Parent = SectionHandler
            ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.LayoutOrder = 1
            
            local Row = Instance.new("Frame")
            Row.Parent = ToggleFrame
            Row.Size = UDim2.new(1, 0, 1, 0)
            Row.BackgroundTransparency = 1
            
            -- БЕЛЫЙ ТЕКСТ ФУНКЦИИ
            local Label = Instance.new("TextLabel")
            Label.Parent = Row
            Label.Size = UDim2.new(0, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.TextTransparency = 0.2
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local textSize = TextService:GetTextSize(Label.Text, 12, Enum.Font.GothamMedium, Vector2.new(999, 999))
            Label.Size = UDim2.new(0, textSize.X + 5, 1, 0)
            
            table.insert(AllItems, {Root = Label, Name = name})
            
            -- КРАСНЫЙ ТУГЛ (выключен - серый, включен - красный)
            local ToggleBtn = Instance.new("Frame")
            ToggleBtn.Parent = Row
            ToggleBtn.Size = UDim2.new(0, 28, 0, 16)
            ToggleBtn.Position = UDim2.new(0, textSize.X + 15, 0.5, -8)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
            ToggleBtn.BorderSizePixel = 0
            ToggleBtn.ClipsDescendants = true
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.Parent = ToggleBtn
            ToggleCorner.CornerRadius = UDim.new(1, 0)
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Parent = ToggleBtn
            ToggleCircle.Size = UDim2.new(0, 12, 0, 12)
            ToggleCircle.Position = UDim2.new(0.7, 0, 0.5, 0)
            ToggleCircle.AnchorPoint = Vector2.new(0.5, 0.5)
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            ToggleCircle.BackgroundTransparency = 0.5
            ToggleCircle.BorderSizePixel = 0
            
            local ToggleCircleCorner = Instance.new("UICorner")
            ToggleCircleCorner.Parent = ToggleCircle
            ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
            
            local ToggleState = defaultValue
            
            local function UpdateToggle()
                if ToggleState then
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.175), {
                        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                        BackgroundTransparency = 0
                    }):Play()
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.175), {
                        Position = UDim2.new(0.7, 0, 0.5, 0),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                else
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.175), {
                        BackgroundColor3 = Color3.fromRGB(120, 120, 120),
                        BackgroundTransparency = 0
                    }):Play()
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.175), {
                        Position = UDim2.new(0.3, 0, 0.5, 0),
                        BackgroundTransparency = 0.5,
                        BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    }):Play()
                end
            end
            
            UpdateToggle()
            
            local Input = Instance.new("ImageButton")
            Input.Parent = ToggleBtn
            Input.Size = UDim2.new(1, 0, 1, 0)
            Input.BackgroundTransparency = 1
            Input.ImageTransparency = 1
            
            Input.MouseButton1Click:Connect(function()
                ToggleState = not ToggleState
                UpdateToggle()
                callback(ToggleState)
            end)
            
            local toggleLib = {
                GetValue = function() return ToggleState end,
                SetValue = function(v)
                    ToggleState = v
                    UpdateToggle()
                    callback(v)
                end,
                Root = ToggleFrame,
                Button = ToggleBtn,
                Circle = ToggleCircle
            }
            
            if flag then
                Flags[flag] = toggleLib
            end
            
            return toggleLib
        end
        
        function sectionData:AddSlider(config)
            config = config or {}
            local defaultValue = config.Default or 50
            local min = config.Min or 0
            local max = config.Max or 100
            local rounding = config.Rounding or 0
            local suffix = config.Type or ""
            local callback = config.Callback or function() end
            local flag = config.Flag or nil
            local name = config.Name or "Slider"
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Parent = SectionHandler
            SliderFrame.Size = UDim2.new(1, 0, 0, 32)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.LayoutOrder = 2
            
            local HeaderRow = Instance.new("Frame")
            HeaderRow.Parent = SliderFrame
            HeaderRow.Size = UDim2.new(1, 0, 0, 18)
            HeaderRow.BackgroundTransparency = 1
            
            local Label = Instance.new("TextLabel")
            Label.Parent = HeaderRow
            Label.Size = UDim2.new(1, -65, 0, 15)
            Label.Position = UDim2.new(0, 10, 0.5, -7.5)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.TextTransparency = 0.2
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            table.insert(AllItems, {Root = Label, Name = name})
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = HeaderRow
            ValueLabel.Size = UDim2.new(0, 55, 0, 15)
            ValueLabel.Position = UDim2.new(1, -5, 0.5, -7.5)
            ValueLabel.AnchorPoint = Vector2.new(1, 0.5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(defaultValue) .. suffix
            ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ValueLabel.TextSize = 11
            ValueLabel.TextTransparency = 0.2
            ValueLabel.Font = Enum.Font.GothamMedium
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Parent = SliderFrame
            SliderBar.Size = UDim2.new(1, -10, 0, 5)
            SliderBar.Position = UDim2.new(0, 5, 0, 24)
            SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SliderBar.BorderSizePixel = 0
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.Parent = SliderBar
            SliderCorner.CornerRadius = UDim.new(1, 0)
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Parent = SliderBar
            SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            SliderFill.BorderSizePixel = 0
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.Parent = SliderFill
            FillCorner.CornerRadius = UDim.new(1, 0)
            
            local SliderValue = defaultValue
            
            local function GetPercent()
                return (SliderValue - min) / (max - min)
            end
            
            local function UpdateSlider()
                SliderFill.Size = UDim2.new(GetPercent(), 0, 1, 0)
                ValueLabel.Text = tostring(SliderValue) .. suffix
            end
            
            UpdateSlider()
            
            local isDragging = false
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    local pos = Mouse.X - SliderBar.AbsolutePosition.X
                    local percent = math.clamp(pos / SliderBar.AbsoluteSize.X, 0, 1)
                    SliderValue = min + (max - min) * percent
                    SliderValue = tonumber(string.format("%." .. rounding .. "f", SliderValue))
                    UpdateSlider()
                    callback(SliderValue)
                end
            end)
            
            SliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)
            
            UIS.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = Mouse.X - SliderBar.AbsolutePosition.X
                    local percent = math.clamp(pos / SliderBar.AbsoluteSize.X, 0, 1)
                    SliderValue = min + (max - min) * percent
                    SliderValue = tonumber(string.format("%." .. rounding .. "f", SliderValue))
                    UpdateSlider()
                    callback(SliderValue)
                end
            end)
            
            local sliderLib = {
                GetValue = function() return SliderValue end,
                SetValue = function(v)
                    SliderValue = math.clamp(v, min, max)
                    SliderValue = tonumber(string.format("%." .. rounding .. "f", SliderValue))
                    UpdateSlider()
                    callback(v)
                end,
                Root = SliderFrame
            }
            
            if flag then
                Flags[flag] = sliderLib
            end
            
            return sliderLib
        end
        
        function sectionData:AddButton(config)
            config = config or {}
            local callback = config.Callback or function() end
            local name = config.Name or "Button"
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Parent = SectionHandler
            ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
            ButtonFrame.BackgroundTransparency = 1
            ButtonFrame.LayoutOrder = 3
            
            local Label = Instance.new("TextLabel")
            Label.Parent = ButtonFrame
            Label.Size = UDim2.new(1, 0, 0, 15)
            Label.Position = UDim2.new(0, 10, 0.5, -7.5)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.TextTransparency = 0.15
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            table.insert(AllItems, {Root = Label, Name = name})
            
            local Line = Instance.new("Frame")
            Line.Parent = ButtonFrame
            Line.Size = UDim2.new(1, -20, 0, 1)
            Line.Position = UDim2.new(0.5, 0, 1, 0)
            Line.AnchorPoint = Vector2.new(0.5, 1)
            Line.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            Line.BackgroundTransparency = 0.5
            
            local Input = Instance.new("ImageButton")
            Input.Parent = ButtonFrame
            Input.Size = UDim2.new(1, 0, 1, 0)
            Input.BackgroundTransparency = 1
            Input.ImageTransparency = 1
            
            Input.MouseButton1Click:Connect(callback)
            
            Input.MouseEnter:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.35
                }):Play()
            end)
            
            Input.MouseLeave:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1
                }):Play()
            end)
            
            return {
                Root = ButtonFrame,
                SetText = function(t) Label.Text = t end
            }
        end
        
        function sectionData:AddLabel(config)
            config = config or {}
            local name = config.Name or "Label"
            
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Parent = SectionHandler
            LabelFrame.Size = UDim2.new(1, 0, 0, 24)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.LayoutOrder = 4
            
            local Label = Instance.new("TextLabel")
            Label.Parent = LabelFrame
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.TextSize = 11
            Label.TextTransparency = 0.3
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            table.insert(AllItems, {Root = Label, Name = name})
            
            return {
                Root = LabelFrame,
                SetText = function(t) Label.Text = t end
            }
        end
        
        function sectionData:AddTextInput(config)
            config = config or {}
            local defaultValue = config.Default or ""
            local placeholder = config.Placeholder or "Enter text..."
            local callback = config.Callback or function() end
            local flag = config.Flag or nil
            local size = config.Size or 120
            local name = config.Name or "Text"
            
            local TextFrame = Instance.new("Frame")
            TextFrame.Parent = SectionHandler
            TextFrame.Size = UDim2.new(1, 0, 0, 28)
            TextFrame.BackgroundTransparency = 1
            TextFrame.LayoutOrder = 5
            
            local Label = Instance.new("TextLabel")
            Label.Parent = TextFrame
            Label.Size = UDim2.new(0, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.TextTransparency = 0.2
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local textSize = TextService:GetTextSize(Label.Text, 12, Enum.Font.GothamMedium, Vector2.new(999, 999))
            Label.Size = UDim2.new(0, textSize.X + 5, 1, 0)
            
            local Input = Instance.new("TextBox")
            Input.Parent = TextFrame
            Input.Size = UDim2.new(0, size, 1, -4)
            Input.Position = UDim2.new(0, textSize.X + 15, 0.5, 0)
            Input.AnchorPoint = Vector2.new(0, 0.5)
            Input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Input.BorderSizePixel = 0
            Input.Text = tostring(defaultValue)
            Input.TextColor3 = Color3.fromRGB(255, 255, 255)
            Input.TextSize = 11
            Input.TextTransparency = 0.2
            Input.Font = Enum.Font.GothamMedium
            Input.TextXAlignment = Enum.TextXAlignment.Left
            Input.PlaceholderText = placeholder
            Input.ClearTextOnFocus = false
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.Parent = Input
            InputCorner.CornerRadius = UDim.new(0, 3)
            
            Input:GetPropertyChangedSignal("Text"):Connect(function()
                callback(Input.Text)
            end)
            
            table.insert(AllItems, {Root = Label, Name = name})
            
            local textLib = {
                GetValue = function() return Input.Text end,
                SetValue = function(v) Input.Text = tostring(v) end,
                Root = TextFrame
            }
            
            if flag then
                Flags[flag] = textLib
            end
            
            return textLib
        end
        
        function sectionData:AddCycleButton(config)
            config = config or {}
            local options = config.Options or {}
            local default = config.Default or options[1] or "Spin"
            local callback = config.Callback or function() end
            local flag = config.Flag or nil
            local name = config.Name or "Mode"
            
            local CycleFrame = Instance.new("Frame")
            CycleFrame.Parent = SectionHandler
            CycleFrame.Size = UDim2.new(1, 0, 0, 44)
            CycleFrame.BackgroundTransparency = 1
            CycleFrame.LayoutOrder = 6
            
            local Label = Instance.new("TextLabel")
            Label.Parent = CycleFrame
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.TextTransparency = 0.2
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            table.insert(AllItems, {Root = Label, Name = name})
            
            local CurrentIndex = 1
            for i, v in ipairs(options) do
                if v == default then
                    CurrentIndex = i
                    break
                end
            end
            
            local ModeValue = default
            
            local Btn = Instance.new("TextButton")
            Btn.Parent = CycleFrame
            Btn.Size = UDim2.new(0, 80, 0, 22)
            Btn.Position = UDim2.new(0, 10, 0, 20)
            Btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            Btn.Text = default
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 11
            Btn.Font = Enum.Font.GothamMedium
            Btn.BorderSizePixel = 0
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.Parent = Btn
            BtnCorner.CornerRadius = UDim.new(0, 3)
            
            Btn.MouseButton1Click:Connect(function()
                CurrentIndex = CurrentIndex % #options + 1
                ModeValue = options[CurrentIndex]
                Btn.Text = ModeValue
                callback(ModeValue)
            end)
            
            local modeLib = {
                GetValue = function() return ModeValue end,
                SetValue = function(v)
                    for i, opt in ipairs(options) do
                        if opt == v then
                            CurrentIndex = i
                            ModeValue = v
                            Btn.Text = v
                            callback(v)
                            break
                        end
                    end
                end,
                Root = CycleFrame
            }
            
            if flag then
                Flags[flag] = modeLib
            end
            
            return modeLib
        end
        
        function sectionData:AddShaderPreset(config)
            config = config or {}
            local name = config.Name or "Preset"
            local shaderData = config.ShaderData or {}
            
            local PresetFrame = Instance.new("Frame")
            PresetFrame.Parent = SectionHandler
            PresetFrame.Size = UDim2.new(1, 0, 0, 28)
            PresetFrame.BackgroundTransparency = 1
            PresetFrame.LayoutOrder = 7
            
            local Label = Instance.new("TextLabel")
            Label.Parent = PresetFrame
            Label.Size = UDim2.new(1, 0, 0, 15)
            Label.Position = UDim2.new(0, 10, 0.5, -7.5)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.TextTransparency = 0.15
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            table.insert(AllItems, {Root = Label, Name = name})
            
            local Line = Instance.new("Frame")
            Line.Parent = PresetFrame
            Line.Size = UDim2.new(1, -20, 0, 1)
            Line.Position = UDim2.new(0.5, 0, 1, 0)
            Line.AnchorPoint = Vector2.new(0.5, 1)
            Line.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            Line.BackgroundTransparency = 0.5
            
            local Input = Instance.new("ImageButton")
            Input.Parent = PresetFrame
            Input.Size = UDim2.new(1, 0, 1, 0)
            Input.BackgroundTransparency = 1
            Input.ImageTransparency = 1
            
            Input.MouseButton1Click:Connect(function()
                if shaderData and type(shaderData) == "table" then
                    local shaderLighting = shaderData.Lighting or {}
                    local shaderEffects = shaderData.Effects or {}
                    
                    for key, value in pairs(shaderLighting) do
                        if Lighting[key] ~= nil then
                            Lighting[key] = value
                        end
                    end
                    
                    for key, value in pairs(shaderEffects) do
                        local effect = Lighting:FindFirstChildOfClass(key)
                        if effect then
                            for prop, val in pairs(value) do
                                if effect[prop] ~= nil then
                                    effect[prop] = val
                                end
                            end
                        end
                    end
                end
            end)
            
            Input.MouseEnter:Connect(function()
                TweenService:Create(PresetFrame, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.35
                }):Play()
            end)
            
            Input.MouseLeave:Connect(function()
                TweenService:Create(PresetFrame, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1
                }):Play()
            end)
            
            return {
                Root = PresetFrame,
                SetText = function(t) Label.Text = t end
            }
        end
        
        return sectionData
    end
    return tabData
end

-- ===== СОЗДАНИЕ ВКЛАДОК И ФУНКЦИЙ =====
local MainTab = CreateTab("Main")

local BHopSection = MainTab:AddSection({Name = "BUNNY HOP"})
BHopSection:AddToggle({Name = "Auto BunnyHop", Default = false, Callback = function(v) Config.BHopEnabled = v end, Flag = "BHopEnabled"})

local MovementSection = MainTab:AddSection({Name = "MOVEMENT"})
MovementSection:AddToggle({Name = "CFrame Speed", Default = false, Callback = function(v) Config.SpeedEnabled = v end, Flag = "SpeedEnabled"})
MovementSection:AddSlider({Name = "Speed Value", Default = 16, Min = 1, Max = 300, Type = "", Callback = function(v) Config.SpeedValue = v end, Flag = "SpeedValue"})
MovementSection:AddToggle({Name = "CTRL + Click TP", Default = false, Callback = function(v) Config.TpEnabled = v end, Flag = "TpEnabled"})
MovementSection:AddSlider({Name = "TP Height", Default = 10, Min = 1, Max = 1000, Type = "", Callback = function(v) Config.TpHeight = v end, Flag = "TpHeight"})
MovementSection:AddToggle({Name = "Skip Map", Default = false, Callback = function(v)
    Config.SkipMapEnabled = v
    if v then
        Config.SkipMapPos = Vector3.new(0, 5000, 0)
        local platform = Instance.new("Part")
        platform.Name = "SkipMapPlatform"
        platform.Size = Vector3.new(50, 2, 50)
        platform.Position = Config.SkipMapPos - Vector3.new(0, 4, 0)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 0.9
        platform.Color = Color3.fromRGB(0, 0, 0)
        platform.Material = Enum.Material.SmoothPlastic
        platform.Parent = WS
        Config.SkipMapPlatform = platform
        Config.SkipMapConnection = RS.Heartbeat:Connect(function()
            if not Config.SkipMapEnabled then
                Config.SkipMapConnection:Disconnect()
                Config.SkipMapConnection = nil
                return
            end
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if (hrp.Position - Config.SkipMapPos).Magnitude > 50 then
                        hrp.CFrame = CFrame.new(Config.SkipMapPos)
                    end
                end
            end
        end)
    else
        if Config.SkipMapConnection then
            Config.SkipMapConnection:Disconnect()
            Config.SkipMapConnection = nil
        end
        if Config.SkipMapPlatform then
            Config.SkipMapPlatform:Destroy()
            Config.SkipMapPlatform = nil
        end
    end
end, Flag = "SkipMapEnabled"})
MovementSection:AddToggle({Name = "TP Walk", Default = false, Callback = function(v) Config.TpWalkEnabled = v end, Flag = "TpWalkEnabled"})
MovementSection:AddSlider({Name = "TP Walk Speed", Default = 1, Min = 1, Max = 200, Type = "", Callback = function(v) Config.TpWalkValue = v end, Flag = "TpWalkValue"})
MovementSection:AddToggle({Name = "Super Bounce", Default = false, Callback = function(v) Config.SuperBounceEnabled = v end, Flag = "SuperBounceEnabled"})
MovementSection:AddTextInput({Name = "Bounce Height", Default = "190", Placeholder = "190", Size = 80, Callback = function(v) local num = tonumber(v) if num then Config.SuperBounceHeight = num end end})
MovementSection:AddButton({Name = "Bounce!", Callback = function()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoid and rootPart then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        rootPart.Velocity = Vector3.new(rootPart.Velocity.X, Config.SuperBounceHeight, rootPart.Velocity.Z)
    end
end})
MovementSection:AddToggle({Name = "Super Jump", Default = false, Callback = function(v) Config.SuperJumpEnabled = v end, Flag = "SuperJumpEnabled"})
MovementSection:AddSlider({Name = "Super Jump Power", Default = 250, Min = 1, Max = 1000, Type = "", Callback = function(v) Config.SuperJumpPower = v end, Flag = "SuperJumpPower"})

local SpinSection = MainTab:AddSection({Name = "SPIN BOT"})
SpinSection:AddToggle({Name = "Spin Bot", Default = false, Callback = function(v) Config.SpinEnabled = v end, Flag = "SpinEnabled"})
SpinSection:AddCycleButton({Name = "Spin Mode", Options = {"Spin", "Jitter", "Slide", "Random", "Down", "Up", "Left", "Right"}, Default = "Spin", Callback = function(v) Config.SpinMode = v end, Flag = "SpinMode"})
SpinSection:AddSlider({Name = "Spin Speed", Default = 15, Min = 1, Max = 50, Type = "", Callback = function(v) Config.SpinSpeed = v end, Flag = "SpinSpeed"})

local CombatSection = MainTab:AddSection({Name = "COMBAT"})
CombatSection:AddToggle({Name = "Defibrillator Aura", Default = false, Callback = function(state)
    Config.DefibAura = state
    if state then
        if Config.DefibConnection then Config.DefibConnection:Disconnect() end
        local defibEquipped = false
        Config.DefibConnection = RS.RenderStepped:Connect(function()
            if not Config.DefibAura then
                Config.DefibConnection:Disconnect()
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and isPlayerDowned(player) then
                    local targetChar = player.Character
                    if targetChar then
                        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                        if targetHRP then
                            local dist = (hrp.Position - targetHRP.Position).Magnitude
                            if dist <= Config.DefibRange then
                                local tag = targetChar:GetAttribute("Tag")
                                if tag then
                                    if not defibEquipped then
                                        ReplicatedStorage.Events.UpdateCharacterDataRegistry:FireServer({buffer.fromstring("\008\000"), buffer.fromstring("\003")})
                                        defibEquipped = true
                                    end
                                    ReplicatedStorage.Events.ToolAction:FireServer(buffer.fromstring("\001\001\001\001"), tag)
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if Config.DefibConnection then
            Config.DefibConnection:Disconnect()
            Config.DefibConnection = nil
        end
    end
end, Flag = "DefibAura"})
CombatSection:AddTextInput({Name = "Aura Range", Default = "20", Placeholder = "20 or inf", Size = 80, Callback = function(v) if v == "inf" then Config.DefibRange = math.huge else local num = tonumber(v) if num then Config.DefibRange = num end end end})
CombatSection:AddButton({Name = "Infinite Range", Callback = function()
    local function setInfiniteRange(data)
        if type(data) ~= "table" then return end
        for key, value in pairs(data) do
            if (key == "Range" or key == "LungeRange" or key == "HearingRange") and type(value) == "number" then
                data[key] = math.huge
            elseif key == "DamageDistanceInterval" and type(value) == "table" and #value >= 2 then
                value[2] = math.huge
            elseif type(value) == "table" then
                setInfiniteRange(value)
            end
        end
    end
    for _, tool in ipairs(ReplicatedStorage.Tools:GetChildren()) do
        if tool:IsA("ModuleScript") then
            local success, toolData = pcall(require, tool)
            if success and type(toolData) == "table" and toolData.Tasks then
                for _, task in ipairs(toolData.Tasks) do
                    for _, func in ipairs(task.Functions or {}) do
                        for _, activation in ipairs(func.Activations or {}) do
                            for _, method in ipairs(activation.Methods or {}) do
                                if method.Info then setInfiniteRange(method.Info) end
                            end
                        end
                    end
                    for _, autoFunc in ipairs(task.AutomaticFunctions or {}) do
                        for _, method in ipairs(autoFunc.Methods or {}) do
                            if method.Info then setInfiniteRange(method.Info) end
                        end
                    end
                end
            end
        end
    end
end})
CombatSection:AddButton({Name = "Portal Bypass", Callback = function()
    local methodModule = getrenv().require(ReplicatedStorage.Objects.Game.Tool.Tasks.Types.Portal)
    methodModule.IsPortalPossible = function(...) return true end
end})
CombatSection:AddToggle({Name = "Build Offset", Default = false, Callback = function(state)
    Config.BuildOffsetEnabled = state
    if state then
        local buildModule = getrenv().require(ReplicatedStorage.Objects.Game.Tool.Tasks.Types.Build)
        local oldGetClientPosition = buildModule.GetClientPosition
        buildModule.GetClientPosition = function(self, ...)
            local valid, cframe = oldGetClientPosition(self, ...)
            if cframe then
                cframe = cframe * CFrame.new(Config.BuildOffsetX or 0, Config.BuildOffsetY or 0, Config.BuildOffsetZ or 0)
            end
            return valid, cframe
        end
    end
end})
CombatSection:AddTextInput({Name = "Offset X", Default = "0", Placeholder = "0", Size = 60, Callback = function(v) local num = tonumber(v) or 0 Config.BuildOffsetX = num end})
CombatSection:AddTextInput({Name = "Offset Y", Default = "0", Placeholder = "0", Size = 60, Callback = function(v) local num = tonumber(v) or 0 Config.BuildOffsetY = num end})
CombatSection:AddTextInput({Name = "Offset Z", Default = "0", Placeholder = "0", Size = 60, Callback = function(v) local num = tonumber(v) or 0 Config.BuildOffsetZ = num end})
CombatSection:AddButton({Name = "No Weapon Spread", Callback = function()
    for _, tool in ipairs(ReplicatedStorage.Tools:GetChildren()) do
        if tool:IsA("ModuleScript") then
            local success, module = pcall(require, tool)
            if success and module and module.Tasks then
                for _, task in ipairs(module.Tasks) do
                    if task.MethodReferences and task.MethodReferences.Projectile and task.MethodReferences.Projectile.Info and task.MethodReferences.Projectile.Info.SpreadInfo then
                        task.MethodReferences.Projectile.Info.SpreadInfo.MaxSpread = 0
                        task.MethodReferences.Projectile.Info.SpreadInfo.MinSpread = 0
                    end
                end
            end
        end
    end
end})
CombatSection:AddButton({Name = "No Tool Delay", Callback = function()
    local function setFastShoot(data)
        if type(data) ~= "table" then return end
        for key, value in pairs(data) do
            if key == "Cooldown" and type(value) == "number" then
                data[key] = 1/65536
            elseif type(value) == "table" then
                setFastShoot(value)
            end
        end
    end
    for _, tool in ipairs(ReplicatedStorage.Tools:GetChildren()) do
        if tool:IsA("ModuleScript") then
            local success, toolData = pcall(require, tool)
            if success and type(toolData) == "table" and toolData.Tasks then
                for _, task in ipairs(toolData.Tasks) do
                    for _, func in ipairs(task.Functions or {}) do
                        for _, activation in ipairs(func.Activations or {}) do
                            for _, method in ipairs(activation.Methods or {}) do
                                if method.Info then setFastShoot(method.Info) end
                            end
                        end
                    end
                    for _, autoFunc in ipairs(task.AutomaticFunctions or {}) do
                        for _, method in ipairs(autoFunc.Methods or {}) do
                            if method.Info then setFastShoot(method.Info) end
                        end
                    end
                end
            end
        end
    end
end})
CombatSection:AddToggle({Name = "Auto Whistle", Default = false, Callback = function(state)
    Config.AutoWhistleEnabled = state
    if state then
        if Config.WhistleConnection then Config.WhistleConnection:Disconnect() end
        local lastWhistle = 0
        Config.WhistleConnection = RS.Heartbeat:Connect(function()
            if not Config.AutoWhistleEnabled then
                Config.WhistleConnection:Disconnect()
                return
            end
            local now = tick()
            if now - lastWhistle >= 1 then
                lastWhistle = now
                pcall(function()
                    ReplicatedStorage:WaitForChild("Services"):WaitForChild("Client"):WaitForChild("KeybindService"):WaitForChild("SendKeybindEvent"):Fire({Key = "Whistle", Down = true})
                end)
            end
        end)
    else
        if Config.WhistleConnection then
            Config.WhistleConnection:Disconnect()
            Config.WhistleConnection = nil
        end
    end
end, Flag = "AutoWhistleEnabled"})
CombatSection:AddToggle({Name = "God Mode", Default = false, Callback = function(state)
    Config.GodModeEnabled = state
    if state then
        if Config.GodModeConnection then Config.GodModeConnection:Disconnect() end
        local timer = 0
        Config.GodModeConnection = RS.Heartbeat:Connect(function(dt)
            if not Config.GodModeEnabled then
                Config.GodModeConnection:Disconnect()
                return
            end
            timer = timer + dt
            if timer >= 2 then
                timer = 0
                local char = LocalPlayer.Character
                if char then
                    local tag = char:GetAttribute("Tag")
                    if tag then
                        ReplicatedStorage.Events.Interact:FireServer("Revive", tag)
                        ReplicatedStorage.Events.Interact:FireServer("Revive", tag, true)
                    end
                end
            end
        end)
    else
        if Config.GodModeConnection then
            Config.GodModeConnection:Disconnect()
            Config.GodModeConnection = nil
        end
    end
end, Flag = "GodModeEnabled"})
CombatSection:AddToggle({Name = "Self Revive", Default = false, Callback = function(state)
    Config.SelfReviveEnabled = state
    if state then
        if Config.ReviveConnection then Config.ReviveConnection:Disconnect() end
        local hasRevived = false
        local deathPos = nil
        local waitingForRespawn = false
        local function onCharacterAdded(character)
            if waitingForRespawn and deathPos then
                task.wait(0.1)
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(deathPos + Vector3.new(0, 3, 0))
                    deathPos = nil
                    waitingForRespawn = false
                end
            end
        end
        local characterAddedConn
        characterAddedConn = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
        Config.ReviveConnection = RS.Heartbeat:Connect(function()
            if not Config.SelfReviveEnabled then
                Config.ReviveConnection:Disconnect()
                if characterAddedConn then characterAddedConn:Disconnect() end
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and not waitingForRespawn then
                deathPos = hrp.Position
            end
            local charData = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Asset"):WaitForChild("CharacterService")):GetCharacterFromPlayer(LocalPlayer)
            if charData and charData.DataRegistry:Get("Downed") then
                if not hasRevived then
                    hasRevived = true
                    waitingForRespawn = true
                    pcall(function()
                        ReplicatedStorage.Events.SetPlayerMode:FireServer(true)
                    end)
                    task.delay(10, function()
                        hasRevived = false
                        waitingForRespawn = false
                    end)
                end
            end
        end)
    else
        if Config.ReviveConnection then
            Config.ReviveConnection:Disconnect()
            Config.ReviveConnection = nil
        end
    end
end, Flag = "SelfReviveEnabled"})

local UtilitySection = MainTab:AddSection({Name = "UTILITY"})
UtilitySection:AddToggle({Name = "Custom Gravity", Default = false, Callback = function(state)
    Config.GravityEnabled = state
    if state then
        WS.Gravity = Config.GravityValue
    else
        WS.Gravity = 196.2
    end
end, Flag = "GravityEnabled"})
UtilitySection:AddTextInput({Name = "Gravity Value", Default = "196.2", Placeholder = "196.2", Size = 80, Callback = function(v)
    local num = tonumber(v)
    if num then
        Config.GravityValue = num
        if Config.GravityEnabled then
            WS.Gravity = num
        end
    end
end})
UtilitySection:AddToggle({Name = "Jump Pad Boost", Default = false, Callback = function(state)
    Config.JumpPadEnabled = state
    if state then
        local jumpPadModule = require(ReplicatedStorage.Items.BaseItems.Loadout.Deployables.JumpPad.Modules.Client)
        local originalUse = jumpPadModule.Use
        jumpPadModule.Use = function(p1, p2)
            if p2 == nil or p2 ~= LocalPlayer.Character then
                return originalUse(p1, p2)
            end
            p1.Model.AnimationController:LoadAnimation(p1.Model.Animations.Use):Play(0.1)
            p1.Model.BoundingBox.Launch:Play()
            LocalPlayer.Character.HumanoidRootPart:ApplyImpulse(Vector3.new(0, Config.JumpPadValue or 360, 0))
            return
        end
    end
end, Flag = "JumpPadEnabled"})
UtilitySection:AddTextInput({Name = "Jump Power", Default = "360", Placeholder = "360", Size = 80, Callback = function(v) local num = tonumber(v) if num then Config.JumpPadValue = num end end})

local TeleportSection = MainTab:AddSection({Name = "MINI TELEPORT"})
TeleportSection:AddButton({Name = "Teleport to Spawn", Callback = function() teleportToRandomSpawn(Vector3.new(0, 3, 0)) end})
TeleportSection:AddButton({Name = "Teleport to Random Player", Callback = function() teleportToRandomPlayer(Vector3.new(0, 3, 0)) end})
TeleportSection:AddButton({Name = "Teleport to Downed Player", Callback = function() teleportToRandomDowned(Vector3.new(0, 3, 0)) end})
TeleportSection:AddButton({Name = "Teleport to Ticket", Callback = function() teleportToRandomTicket(Vector3.new(0, 3, 0)) end})
TeleportSection:AddButton({Name = "Teleport to Security Part", Callback = function() teleportToSecurityPart(Vector3.new(0, 3, 0)) end})
TeleportSection:AddTextInput({Name = "Coordinates X Y Z", Default = "", Placeholder = "0 0 0", Size = 120, Callback = function(v) Config.TeleportCoords = v end})
TeleportSection:AddButton({Name = "Teleport to Coordinates", Callback = function()
    if not Config.TeleportCoords then return end
    local x, y, z = Config.TeleportCoords:match("([%d.-]+)%s+([%d.-]+)%s+([%d.-]+)")
    if x and y and z then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0)
        end
    end
end})

-- ===== VISUALS TAB =====
local VisualsTab = CreateTab("Visuals")

local ShadersSection = VisualsTab:AddSection({Name = "SHADERS"})
ShadersSection:AddShaderPreset({Name = "Default", ShaderData = {Lighting = {Brightness = 1, Ambient = Color3.fromRGB(128, 128, 128), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(128, 128, 128)}}})
ShadersSection:AddShaderPreset({Name = "Morning", ShaderData = {Lighting = {Brightness = 0.8, Ambient = Color3.fromRGB(255, 200, 150), ClockTime = 6, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(200, 180, 160)}}})
ShadersSection:AddShaderPreset({Name = "Midday", ShaderData = {Lighting = {Brightness = 1.2, Ambient = Color3.fromRGB(200, 220, 255), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(200, 220, 255)}}})
ShadersSection:AddShaderPreset({Name = "Afternoon", ShaderData = {Lighting = {Brightness = 0.9, Ambient = Color3.fromRGB(255, 180, 100), ClockTime = 16, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(200, 160, 120)}}})
ShadersSection:AddShaderPreset({Name = "Evening", ShaderData = {Lighting = {Brightness = 0.6, Ambient = Color3.fromRGB(255, 150, 80), ClockTime = 19, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(180, 130, 100)}}})
ShadersSection:AddShaderPreset({Name = "Night", ShaderData = {Lighting = {Brightness = 0.1, Ambient = Color3.fromRGB(30, 30, 50), ClockTime = 23, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(20, 20, 40)}}})
ShadersSection:AddShaderPreset({Name = "Midnight", ShaderData = {Lighting = {Brightness = 0.05, Ambient = Color3.fromRGB(10, 10, 20), ClockTime = 0, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(5, 5, 15)}}})
ShadersSection:AddShaderPreset({Name = "Pink", ShaderData = {Lighting = {Brightness = 1, Ambient = Color3.fromRGB(255, 150, 200), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(255, 150, 200)}, Effects = {ColorCorrectionEffect = {Brightness = 0.2, Contrast = 0.3, Saturation = 0.5, TintColor = Color3.fromRGB(255, 150, 200)}}}})
ShadersSection:AddShaderPreset({Name = "Red", ShaderData = {Lighting = {Brightness = 1, Ambient = Color3.fromRGB(255, 50, 50), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(200, 80, 80)}, Effects = {ColorCorrectionEffect = {Brightness = 0.1, Contrast = 0.5, Saturation = 0.8, TintColor = Color3.fromRGB(255, 50, 50)}}}})
ShadersSection:AddShaderPreset({Name = "Green", ShaderData = {Lighting = {Brightness = 1, Ambient = Color3.fromRGB(50, 255, 50), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(80, 200, 80)}, Effects = {ColorCorrectionEffect = {Brightness = 0.1, Contrast = 0.5, Saturation = 0.8, TintColor = Color3.fromRGB(50, 255, 50)}}}})
ShadersSection:AddShaderPreset({Name = "Blue", ShaderData = {Lighting = {Brightness = 1, Ambient = Color3.fromRGB(50, 100, 255), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(80, 130, 255)}, Effects = {ColorCorrectionEffect = {Brightness = 0.1, Contrast = 0.5, Saturation = 0.8, TintColor = Color3.fromRGB(50, 100, 255)}}}})
ShadersSection:AddShaderPreset({Name = "Yellow", ShaderData = {Lighting = {Brightness = 1, Ambient = Color3.fromRGB(255, 200, 50), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(255, 220, 100)}, Effects = {ColorCorrectionEffect = {Brightness = 0.2, Contrast = 0.3, Saturation = 0.6, TintColor = Color3.fromRGB(255, 200, 50)}}}})
ShadersSection:AddShaderPreset({Name = "Purple", ShaderData = {Lighting = {Brightness = 1, Ambient = Color3.fromRGB(150, 50, 255), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(180, 100, 255)}, Effects = {ColorCorrectionEffect = {Brightness = 0.1, Contrast = 0.5, Saturation = 0.8, TintColor = Color3.fromRGB(150, 50, 255)}}}})
ShadersSection:AddShaderPreset({Name = "White", ShaderData = {Lighting = {Brightness = 2, Ambient = Color3.fromRGB(255, 255, 255), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(255, 255, 255)}, Effects = {ColorCorrectionEffect = {Brightness = 0.5, Contrast = 0, Saturation = 0, TintColor = Color3.fromRGB(255, 255, 255)}}}})
ShadersSection:AddShaderPreset({Name = "Black", ShaderData = {Lighting = {Brightness = 0, Ambient = Color3.fromRGB(0, 0, 0), ClockTime = 0, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(0, 0, 0)}, Effects = {ColorCorrectionEffect = {Brightness = -1, Contrast = 0, Saturation = 0, TintColor = Color3.fromRGB(0, 0, 0)}}}})
ShadersSection:AddShaderPreset({Name = "Gray", ShaderData = {Lighting = {Brightness = 0.5, Ambient = Color3.fromRGB(128, 128, 128), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(128, 128, 128)}, Effects = {ColorCorrectionEffect = {Brightness = 0, Contrast = 0, Saturation = -1, TintColor = Color3.fromRGB(128, 128, 128)}}}})
ShadersSection:AddShaderPreset({Name = "Rain", ShaderData = {Lighting = {Brightness = 0.5, Ambient = Color3.fromRGB(100, 100, 120), ClockTime = 12, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(80, 80, 100)}, Effects = {ColorCorrectionEffect = {Brightness = -0.1, Contrast = 0.2, Saturation = -0.3, TintColor = Color3.fromRGB(180, 180, 200)}}}})
ShadersSection:AddShaderPreset({Name = "Snow", ShaderData = {Lighting = {Brightness = 1.2, Ambient = Color3.fromRGB(220, 230, 255), ClockTime = 10, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(200, 220, 255)}, Effects = {ColorCorrectionEffect = {Brightness = 0.2, Contrast = 0.3, Saturation = -0.2, TintColor = Color3.fromRGB(200, 220, 255)}}}})
ShadersSection:AddShaderPreset({Name = "Fog", ShaderData = {Lighting = {Brightness = 0.6, Ambient = Color3.fromRGB(180, 180, 190), ClockTime = 8, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(160, 160, 170), FogEnd = 100, FogStart = 0, FogColor = Color3.fromRGB(180, 180, 190)}}})
ShadersSection:AddShaderPreset({Name = "Sunny", ShaderData = {Lighting = {Brightness = 1.5, Ambient = Color3.fromRGB(255, 240, 200), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(255, 240, 200)}}})
ShadersSection:AddShaderPreset({Name = "Cloudy", ShaderData = {Lighting = {Brightness = 0.6, Ambient = Color3.fromRGB(180, 180, 200), ClockTime = 12, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(160, 160, 180)}}})
ShadersSection:AddShaderPreset({Name = "Storm", ShaderData = {Lighting = {Brightness = 0.3, Ambient = Color3.fromRGB(60, 60, 80), ClockTime = 14, GeographicLatitude = 45, OutdoorAmbient = Color3.fromRGB(40, 40, 60)}, Effects = {ColorCorrectionEffect = {Brightness = -0.3, Contrast = 0.5, Saturation = -0.2, TintColor = Color3.fromRGB(80, 80, 100)}}}})

-- ===== AURAS TAB =====
local AuraTab = CreateTab("Auras")

local MagicAuraSection = AuraTab:AddSection({Name = "BALL AURA"})
MagicAuraSection:AddToggle({Name = "Magic Aura", Default = false, Callback = function(v) Config.MagicAura = v end, Flag = "MagicAura"})
MagicAuraSection:AddSlider({Name = "Aura Count", Default = 3, Min = 1, Max = 6, Type = "", Callback = function(v) Config.MagicAuraCount = v end, Flag = "MagicAuraCount"})
MagicAuraSection:AddSlider({Name = "Aura Radius", Default = 3, Min = 1, Max = 8, Type = "", Callback = function(v) Config.MagicAuraRadius = v end, Flag = "MagicAuraRadius"})
MagicAuraSection:AddSlider({Name = "Orbit Speed", Default = 2, Min = 0.5, Max = 6, Type = "", Callback = function(v) Config.MagicAuraSpeed = v end, Flag = "MagicAuraSpeed"})

local DJAuraSection = AuraTab:AddSection({Name = "DJ AURA"})
DJAuraSection:AddToggle({Name = "DJ Aura", Default = false, Callback = function(v) Config.WingsAura = v end, Flag = "WingsAura"})
DJAuraSection:AddSlider({Name = "Wings Count", Default = 10, Min = 2, Max = 20, Type = "", Callback = function(v) Config.WingsCount = v end, Flag = "WingsCount"})
DJAuraSection:AddSlider({Name = "Wings Size", Default = 3, Min = 0.5, Max = 8, Type = "", Callback = function(v) Config.WingsSize = v end, Flag = "WingsSize"})
DJAuraSection:AddSlider({Name = "Offset X", Default = 0, Min = -5, Max = 5, Type = "", Callback = function(v) Config.WingsOffsetX = v end, Flag = "WingsOffsetX"})
DJAuraSection:AddSlider({Name = "Offset Y", Default = 0, Min = -5, Max = 5, Type = "", Callback = function(v) Config.WingsOffsetY = v end, Flag = "WingsOffsetY"})
DJAuraSection:AddSlider({Name = "Offset Z", Default = 0, Min = -5, Max = 5, Type = "", Callback = function(v) Config.WingsOffsetZ = v end, Flag = "WingsOffsetZ"})

-- ===== WORLD TAB =====
local WorldTab = CreateTab("World")

local RainSection = WorldTab:AddSection({Name = "RAIN SYSTEM"})
RainSection:AddToggle({Name = "Rain Enabled", Default = false, Callback = function(v)
    Config.RainEnabled = v
    if v then
        local rainFolder = Instance.new("Folder")
        rainFolder.Name = "RainSystem"
        rainFolder.Parent = WS
        local dropCount = Config.RainDensity or 50
        for i = 1, dropCount do
            local drop = Instance.new("Part")
            drop.Name = "RainDrop"
            drop.Size = Vector3.new(0.1, 0.1, 0.1)
            drop.Shape = Enum.PartType.Block
            drop.Material = Enum.Material.SmoothPlastic
            drop.Color = Color3.fromRGB(150, 150, 150)
            drop.Transparency = 0.5
            drop.Anchored = true
            drop.CanCollide = false
            drop.Parent = rainFolder
            local x = math.random(-200, 200)
            local y = math.random(100, 300)
            local z = math.random(-200, 200)
            drop.Position = Vector3.new(x, y, z)
            local speed = Config.RainSpeed or 30
            task.spawn(function()
                while drop and drop.Parent and Config.RainEnabled do
                    local newY = drop.Position.Y - (speed * 0.05)
                    if newY < -10 then
                        drop.Position = Vector3.new(math.random(-200, 200), math.random(100, 300), math.random(-200, 200))
                    else
                        drop.Position = Vector3.new(drop.Position.X, newY, drop.Position.Z)
                    end
                    local ray = WS:Raycast(drop.Position + Vector3.new(0, -1, 0), Vector3.new(0, -2, 0))
                    if ray and ray.Instance then
                        local circle = Instance.new("Part")
                        circle.Name = "RainCircle"
                        circle.Size = Vector3.new(Config.RainCircleSize or 2, 0.1, Config.RainCircleSize or 2)
                        circle.Shape = Enum.PartType.Cylinder
                        circle.Material = Enum.Material.Neon
                        circle.Color = Config.RainColor or Color3.fromRGB(255, 150, 200)
                        circle.Transparency = Config.RainCircleTransparency or 0.3
                        circle.Anchored = true
                        circle.CanCollide = false
                        circle.Position = Vector3.new(drop.Position.X, ray.Instance.Position.Y + 0.1, drop.Position.Z)
                        circle.Parent = WS
                        circle.CFrame = CFrame.new(circle.Position)
                        TweenService:Create(circle, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1)}):Play()
                        task.delay(0.5, function()
                            circle:Destroy()
                        end)
                        drop.Position = Vector3.new(math.random(-200, 200), math.random(100, 300), math.random(-200, 200))
                    end
                    task.wait(0.05)
                end
            end)
        end
    else
        local rainFolder = WS:FindFirstChild("RainSystem")
        if rainFolder then
            rainFolder:Destroy()
        end
        for _, v in ipairs(WS:GetDescendants()) do
            if v.Name == "RainCircle" then
                v:Destroy()
            end
        end
    end
end, Flag = "RainEnabled"})
RainSection:AddSlider({Name = "Rain Speed", Default = 30, Min = 10, Max = 100, Type = "", Callback = function(v) Config.RainSpeed = v end, Flag = "RainSpeed"})
RainSection:AddSlider({Name = "Rain Density", Default = 50, Min = 10, Max = 200, Type = "", Callback = function(v) Config.RainDensity = v end, Flag = "RainDensity"})
RainSection:AddSlider({Name = "Circle Size", Default = 2, Min = 0.5, Max = 5, Type = "", Callback = function(v) Config.RainCircleSize = v end, Flag = "RainCircleSize"})
RainSection:AddSlider({Name = "Circle Transparency", Default = 0.3, Min = 0, Max = 1, Type = "", Callback = function(v) Config.RainCircleTransparency = v end, Flag = "RainCircleTransparency"})

-- ===== INFO TAB =====
local InfoTab = CreateTab("Info")
local InfoSection = InfoTab:AddSection({Name = "INFORMATION"})
InfoSection:AddLabel({Name = "Telegram: @burmaldashell"})
InfoSection:AddLabel({Name = "Discord: popka_akulb_70132"})

-- ===== ИНИЦИАЛИЗАЦИЯ ФУНКЦИЙ =====
-- Bunny Hop
local bHopConnection = nil
local function setupBHop(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if bHopConnection then
        bHopConnection:Disconnect()
        bHopConnection = nil
    end
    bHopConnection = humanoid.StateChanged:Connect(function(_, newState)
        if not Config.BHopEnabled then return end
        if newState == Enum.HumanoidStateType.Landed and Config.IsHoldingJump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

if LocalPlayer.Character then
    setupBHop(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(character)
    setupBHop(character)
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Touch then
        Config.IsHoldingJump = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Touch then
        Config.IsHoldingJump = false
    end
end)

-- Speed
RS.Heartbeat:Connect(function()
    if Config.SpeedEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                hrp.CFrame = hrp.CFrame + humanoid.MoveDirection * (Config.SpeedValue / 50)
            end
        end
    end
end)

-- TP Walk
RS.Heartbeat:Connect(function()
    if Config.TpWalkEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        moveDir.X * 10 * Config.TpWalkValue,
                        hrp.AssemblyLinearVelocity.Y,
                        moveDir.Z * 10 * Config.TpWalkValue
                    )
                end
            end
        end
    end
end)

-- Super Jump
RS.Heartbeat:Connect(function()
    if Config.SuperJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                    rootPart.Velocity = Vector3.new(rootPart.Velocity.X, Config.SuperJumpPower, rootPart.Velocity.Z)
                end
            end
        end
    end
end)

-- Spin Bot
local spinAngle = 0
local spinRandom = 0
RS.Heartbeat:Connect(function()
    if not Config.SpinEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    spinAngle = spinAngle + Config.SpinSpeed
    local xAngle = 0
    local yAngle = 0
    local mode = Config.SpinMode
    if mode == "Spin" then
        yAngle = math.rad(spinAngle)
    elseif mode == "Jitter" then
        yAngle = math.rad(math.sin(spinAngle * 0.1) * 30)
        xAngle = math.rad(math.cos(spinAngle * 0.1) * 15)
    elseif mode == "Slide" then
        local direction = math.sin(spinAngle * 0.05) > 0 and 1 or -1
        yAngle = math.rad(direction * 8)
    elseif mode == "Random" then
        if spinAngle % 10 == 0 then spinRandom = math.random(-180, 180) end
        yAngle = math.rad(spinRandom)
    elseif mode == "Down" then
        xAngle = math.rad(90)
    elseif mode == "Up" then
        xAngle = math.rad(-90)
    elseif mode == "Left" then
        yAngle = math.rad(-90)
    elseif mode == "Right" then
        yAngle = math.rad(90)
    end
    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(xAngle, yAngle, 0)
end)

-- CTRL + Click TP
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Config.TpEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        local myChar = LocalPlayer.Character
        if myChar then
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                myRoot.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, Config.TpHeight, 0))
            end
        end
    end
end)

-- Magic Aura
local auraParts = {}
RS.RenderStepped:Connect(function()
    if not Config.MagicAura then
        for _, s in ipairs(auraParts) do s:Destroy() end
        auraParts = {}
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local count = Config.MagicAuraCount or 3
    while #auraParts < count do
        local sphere = Instance.new("Part")
        sphere.Name = "AuraSphere"
        sphere.Anchored = true
        sphere.CanCollide = false
        sphere.Material = Enum.Material.Neon
        sphere.Shape = Enum.PartType.Ball
        sphere.Size = Vector3.new(0.6, 0.6, 0.6)
        sphere.Transparency = 0.3
        sphere.Parent = WS
        table.insert(auraParts, sphere)
    end
    while #auraParts > count do
        auraParts[#auraParts]:Destroy()
        table.remove(auraParts, #auraParts)
    end
    local t = tick()
    local radius = Config.MagicAuraRadius or 3
    local speed = Config.MagicAuraSpeed or 2
    local colors = {
        Color3.fromRGB(255, 150, 200),
        Color3.fromRGB(255, 200, 220),
        Color3.fromRGB(255, 220, 180),
        Color3.fromRGB(255, 200, 200),
        Color3.fromRGB(255, 150, 200),
        Color3.fromRGB(200, 150, 255),
    }
    for i, sphere in ipairs(auraParts) do
        local angleOffset = (i - 1) * (math.pi * 2 / count)
        local angle = t * speed + angleOffset
        local ox = math.cos(angle) * radius
        local oz = math.sin(angle) * radius
        local heightOsc = math.sin(t * 2 + angleOffset) * 1
        sphere.CFrame = CFrame.new(hrp.Position + Vector3.new(ox, heightOsc, oz))
        sphere.Color = colors[(i - 1) % #colors + 1]
        sphere.Transparency = 0.3
    end
end)

-- DJ Wings Aura
local wingParts = {}
RS.RenderStepped:Connect(function()
    if not Config.WingsAura then
        for _, s in ipairs(wingParts) do s:Destroy() end
        wingParts = {}
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local count = Config.WingsCount or 10
    local size = Config.WingsSize or 3
    local offsetX = Config.WingsOffsetX or 0
    local offsetY = Config.WingsOffsetY or 0
    local offsetZ = Config.WingsOffsetZ or 0
    while #wingParts < count do
        local wing = Instance.new("Part")
        wing.Name = "WingPart"
        wing.Anchored = true
        wing.CanCollide = false
        wing.Material = Enum.Material.Neon
        wing.Shape = Enum.PartType.Block
        wing.Size = Vector3.new(0.3, 0.05, 0.8)
        wing.Transparency = 0.2
        wing.Color = Color3.fromRGB(255, 150, 200)
        wing.Parent = WS
        table.insert(wingParts, wing)
    end
    while #wingParts > count do
        wingParts[#wingParts]:Destroy()
        table.remove(wingParts, #wingParts)
    end
    local charCFrame = hrp.CFrame
    local pos = charCFrame.Position
    local right = charCFrame.RightVector
    local up = charCFrame.UpVector
    local look = charCFrame.LookVector
    for i, wing in ipairs(wingParts) do
        local t = tick()
        local angle = t * 1.5 + i * 0.5
        local left = i < count / 2
        local side = left and -1 or 1
        local index = left and i or i - math.floor(count / 2)
        local dist = 1.5 + index * 0.4
        local x = pos.X + side * right.X * dist * size + look.X * offsetZ + right.X * offsetX + up.X * offsetY
        local y = pos.Y + 1.5 + up.Y * offsetY + math.sin(angle + i) * 0.5 + right.Y * offsetX + look.Y * offsetZ
        local z = pos.Z + side * right.Z * dist * size + look.Z * offsetZ + right.Z * offsetX + up.Z * offsetY
        wing.Position = Vector3.new(x, y, z)
        wing.CFrame = CFrame.new(wing.Position, pos + Vector3.new(0, 1.5, 0))
        wing.Size = Vector3.new(0.3, 0.05, 0.8 + math.sin(angle + i) * 0.2)
        wing.Transparency = 0.2 + math.sin(angle + i) * 0.1
        wing.Color = Color3.fromRGB(255, 150, 200)
    end
end)

-- Toggle GUI with Z key
UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Z and not gameProcessed then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)
