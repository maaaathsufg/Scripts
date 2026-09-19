-- ======================================================
-- AstraL Lite v4 | MM2 | WindUI
-- Main / Combat / Players / Player / Binds
-- ======================================================

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local UserInputService   = game:GetService("UserInputService")
local LocalPlayer        = Players.LocalPlayer

-- ==================== LOAD WINDUI ====================
local WindUI
do
    local urls = {
        "https://github.com/Footagesus/WindUI/releases/download/1.6.62/main.lua",
        "https://github.com/Footagesus/WindUI/releases/download/1.6.55/main.lua",
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    }
    for _, url in ipairs(urls) do
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if ok and result then WindUI = result; break end
    end
    if not WindUI then error("[AstraL] Failed to load WindUI") end
end

-- ==================== SAFE WRAPPERS ====================
local function SafeCall(name, fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then warn("[AstraL] " .. name .. ": " .. tostring(res)); return nil end
    return res
end
local function SafeToggle(tab, cfg)
    if type(cfg.Value) ~= "boolean" then cfg.Value = false end
    return SafeCall("Toggle:"..tostring(cfg.Title), function() return tab:Toggle(cfg) end)
end
local function SafeButton(tab, cfg)
    return SafeCall("Button:"..tostring(cfg.Title), function() return tab:Button(cfg) end)
end
local function SafeSlider(tab, cfg)
    if type(cfg.Value) ~= "table" then cfg.Value = {Min=0,Max=1,Default=0} end
    return SafeCall("Slider:"..tostring(cfg.Title), function() return tab:Slider(cfg) end)
end
local function SafeInput(tab, cfg)
    if type(cfg.Placeholder) ~= "string" then cfg.Placeholder = "" end
    return SafeCall("Input:"..tostring(cfg.Title), function() return tab:Input(cfg) end)
end
local function SafeParagraph(tab, cfg)
    return SafeCall("Paragraph:"..tostring(cfg.Title), function() return tab:Paragraph(cfg) end)
end
local function SafeSection(tab, cfg)
    return SafeCall("Section:"..tostring(cfg.Title), function() return tab:Section(cfg) end)
end
local function SafeKeybind(tab, cfg)
    if type(cfg.Value) ~= "string" then cfg.Value = "None" end
    return SafeCall("Keybind:"..tostring(cfg.Title), function() return tab:Keybind(cfg) end)
end

-- ==================== STATE ====================
local State = {
    ESP = false,
    GunESP = false,
    AGG = false,
    Invis = false,
    KillAll = false,
    AntiFling = false,
    Noclip = false,
    InfiniteJump = false,
    KeepWS = false,
    KeepJP = false,
    WalkSpeed = 16,
    JumpPower = 50,
}

local Binds = {
    KillAll = "None",
    Noclip = "None",
    Invis = "None",
    ESP = "None",
    Wallshot = "None",
    AntiFling = "None",
}

local Char, Hum, Root, Backpack
local function refreshChar()
    Char     = LocalPlayer.Character
    Hum      = Char and Char:FindFirstChildOfClass("Humanoid")
    Root     = Char and ((Hum and Hum.RootPart) or Char:FindFirstChild("HumanoidRootPart"))
    Backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack")
end
refreshChar()
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.3); refreshChar() end)

-- ==================== ROLES ====================
local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff  = Color3.fromRGB(0, 120, 255),
    Hero     = Color3.fromRGB(255, 220, 0),
    Innocent = Color3.fromRGB(0, 255, 80),
    Default  = Color3.fromRGB(200, 200, 200),
}
local ROLE_PRIORITY = { Murderer = 1, Sheriff = 2, Hero = 3, Innocent = 4, Default = 5 }
local function roleColor(r) return ROLE_COLORS[r] or ROLE_COLORS.Default end

local RoleNameOf = {}

local function updateRoles()
    local gpd = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not gpd then return end
    local ok, data = pcall(function() return gpd:InvokeServer() end)
    if not ok or type(data) ~= "table" then return end
    for name, d in pairs(data) do
        if type(d) == "table" and not d.Dead then
            RoleNameOf[name] = d.Role
        else
            RoleNameOf[name] = nil
        end
    end
end

task.spawn(function() while task.wait(1) do pcall(updateRoles) end end)

-- ==================== WINDOW ====================
local Window = WindUI:CreateWindow({
    Title = "AstraL Lite v4 | MM2",
    Author = "by @burmaldashell (edit)",
    Icon = "sword",
    Folder = "AstraL",
    Size = UDim2.fromOffset(600, 480),
    Theme = "Red",
    Transparent = true,
    Resizable = true,
    SideBarWidth = 200,
    ToggleKey = Enum.KeyCode.RightShift,
    OpenButton = {
        Title = "AstraL",
        Enabled = true,
        OnlyMobile = false,
        Draggable = true,
        OnlyIcon = false,
        Scale = 1,
        StrokeThickness = 2.5,
        Color = ColorSequence.new(Color3.new(0, 0, 0)),
    },
})

local MainTab    = Window:Tab({ Title = "Main",    Desc = "ESP / Grab / Invis / KillAll", Icon = "eye" })
local CombatTab  = Window:Tab({ Title = "Combat",  Desc = "Magic Bullet", Icon = "crosshair" })
local PlayersTab = Window:Tab({ Title = "Players", Desc = "TP / Fling", Icon = "users" })
local PlayerTab  = Window:Tab({ Title = "Player",  Desc = "Movement", Icon = "user" })
local BindsTab   = Window:Tab({ Title = "Binds",   Desc = "Keybinds", Icon = "keyboard" })

-- ================================================================
--                            MAIN TAB
-- ================================================================
SafeSection(MainTab, { Title = "Visuals" })

-- --------- Player ESP ---------
local espCache = {}
local function buildESP(P)
    local c = P.Character
    local head = c and c:FindFirstChild("Head")
    if not head then return nil end

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.4
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = c

    local bb = Instance.new("BillboardGui")
    bb.Name = "RoleESP"
    bb.Size = UDim2.new(0, 200, 0, 30)
    bb.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 1
    bb.MaxDistance = 500
    bb.Adornee = head
    bb.Parent = head

    local label = Instance.new("TextLabel")
    label.Name = "RoleLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 16
    label.Text = P.DisplayName
    label.Parent = bb

    return { HL = hl, BB = bb, Label = label, Char = c }
end

local function clearESP()
    for _, e in pairs(espCache) do
        pcall(function() e.HL:Destroy() end)
        pcall(function() e.BB:Destroy() end)
    end
    espCache = {}
end

local function tickESP()
    if not State.ESP then return end
    for _, P in ipairs(Players:GetPlayers()) do
        if P ~= LocalPlayer and P.Character then
            local e = espCache[P]
            if not e or e.Char ~= P.Character then
                if e then
                    pcall(function() e.HL:Destroy() end)
                    pcall(function() e.BB:Destroy() end)
                end
                espCache[P] = buildESP(P)
                e = espCache[P]
            end
            if e then
                local role = RoleNameOf[P.Name] or "Default"
                local col = roleColor(role)
                pcall(function()
                    e.HL.FillColor = col
                    e.HL.OutlineColor = Color3.new(1,1,1)
                    e.Label.Text = P.DisplayName
                    e.Label.TextColor3 = col
                end)
            end
        end
    end
end

local ESPToggle = SafeToggle(MainTab, {
    Title = "ESP Player (Name)",
    Desc = "Highlight + name above head",
    Icon = "eye",
    Value = State.ESP,
    Callback = function(v)
        State.ESP = v
        if not v then clearESP() end
    end,
})

-- --------- Gun ESP ---------
local gunHL, gunBB
local function clearGunESP()
    if gunHL then pcall(function() gunHL:Destroy() end); gunHL = nil end
    if gunBB then pcall(function() gunBB:Destroy() end); gunBB = nil end
end
local function tickGunESP()
    if not State.GunESP then return end
    local gun = workspace:FindFirstChild("GunDrop", true)
    if not gun then clearGunESP(); return end
    if not gunHL or gunHL.Parent ~= gun then
        clearGunESP()
        gunHL = Instance.new("Highlight")
        gunHL.FillColor = Color3.new(1, 1, 0)
        gunHL.OutlineColor = Color3.new(1, 1, 1)
        gunHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        gunHL.FillTransparency = 0.4
        gunHL.OutlineTransparency = 0.5
        gunHL.Parent = gun
        gunBB = Instance.new("BillboardGui")
        gunBB.Adornee = gun
        gunBB.Size = UDim2.new(0, 200, 0, 30)
        gunBB.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
        gunBB.AlwaysOnTop = true
        gunBB.Parent = gun
        local text = Instance.new("TextLabel", gunBB)
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextStrokeTransparency = 0
        text.TextColor3 = Color3.fromRGB(255, 255, 0)
        text.Font = Enum.Font.FredokaOne
        text.TextSize = 16
        text.Text = "Gun Drop"
    end
end

SafeToggle(MainTab, {
    Title = "ESP Gun",
    Desc = "Highlight dropped gun",
    Icon = "crosshair",
    Value = State.GunESP,
    Callback = function(v) State.GunESP = v; if not v then clearGunESP() end end,
})

SafeSection(MainTab, { Title = "Gun Grab" })

SafeButton(MainTab, {
    Title = "Grab Gun",
    Desc = "Touch interest (no teleport)",
    Icon = "zap",
    Callback = function()
        if not (Char and Root) then return end
        local gun = workspace:FindFirstChild("GunDrop", true)
        if not gun then return end
        if firetouchinterest then
            firetouchinterest(Root, gun, 0)
            firetouchinterest(Root, gun, 1)
        else
            gun.CFrame = Root.CFrame
        end
    end,
})

SafeToggle(MainTab, {
    Title = "Auto Grab Gun",
    Desc = "Loop every 0.1s",
    Icon = "zap",
    Value = State.AGG,
    Callback = function(v)
        State.AGG = v
        if v then
            task.spawn(function()
                while State.AGG do
                    if Char and Root then
                        local gun = workspace:FindFirstChild("GunDrop", true)
                        if gun then
                            if firetouchinterest then
                                firetouchinterest(Root, gun, 0)
                                firetouchinterest(Root, gun, 1)
                            else
                                gun.CFrame = Root.CFrame
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

SafeButton(MainTab, {
    Title = "Steal Gun (Sheriff & Hero)",
    Desc = "Move tool to your Backpack",
    Icon = "zap",
    Callback = function()
        if not (Char and Hum and Backpack) then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if p.Character and p.Character:FindFirstChild("Gun") then
                    p.Character.Gun.Parent = Char
                    local g = Char:FindFirstChild("Gun")
                    if g then Hum:EquipTool(g); Hum:UnequipTools() end
                elseif p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun") then
                    p.Backpack.Gun.Parent = Backpack
                    local g = Backpack:FindFirstChild("Gun")
                    if g then Hum:EquipTool(g); Hum:UnequipTools() end
                end
            end
        end
    end,
})

SafeSection(MainTab, { Title = "Utility" })

-- --------- Invisibility (Transparency 0.4) ---------
local InvisState = { parts = {}, orig = {}, active = false, conn = nil, hum = nil, hrp = nil }

local function invisCollect()
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    InvisState.hum = c:WaitForChild("Humanoid")
    InvisState.hrp = c:WaitForChild("HumanoidRootPart")
    InvisState.parts = {}
    InvisState.orig = {}
    for _, part in pairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(InvisState.parts, part)
            InvisState.orig[part] = part.Transparency
        end
    end
end

local function invisApply()
    for _, part in pairs(InvisState.parts) do
        if part and part.Parent then
            if InvisState.active then
                part.Transparency = 0.4
                part.LocalTransparencyModifier = 0.4
            else
                part.Transparency = InvisState.orig[part] or 0
                part.LocalTransparencyModifier = 0
            end
        end
    end
end

local function invisStartLoop()
    if InvisState.conn then InvisState.conn:Disconnect() end
    InvisState.conn = RunService.Heartbeat:Connect(function()
        if not InvisState.active then return end
        if not InvisState.hrp or not InvisState.hrp.Parent then return end
        if not InvisState.hum or not InvisState.hum.Parent then return end
        local cf = InvisState.hrp.CFrame
        local off = InvisState.hum.CameraOffset
        InvisState.hrp.CFrame = cf * CFrame.new(0, -200000, 0)
        InvisState.hum.CameraOffset = Vector3.new(0, 200000, 0)
        RunService.RenderStepped:Wait()
        InvisState.hrp.CFrame = cf
        InvisState.hum.CameraOffset = off
    end)
end

local function invisSet(v)
    InvisState.active = v
    State.Invis = v
    if not InvisState.hum or not InvisState.hrp or not InvisState.hrp.Parent then
        pcall(invisCollect)
    end
    invisApply()
    if v then invisStartLoop()
    elseif InvisState.conn then InvisState.conn:Disconnect(); InvisState.conn = nil end
end

invisCollect()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    pcall(invisCollect)
    if State.Invis then invisApply(); invisStartLoop() end
end)

local InvisToggle = SafeToggle(MainTab, {
    Title = "Invisibility",
    Desc = "Transparency 0.4 + camera offset",
    Icon = "ghost",
    Value = State.Invis,
    Callback = function(v) invisSet(v) end,
})

-- --------- Kill All ---------
local anchoredPlayers = {}
local function unanchorAll()
    for p in pairs(anchoredPlayers) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            pcall(function() hrp.Anchored = false; hrp.CanCollide = true end)
        end
    end
    anchoredPlayers = {}
end
local function disableCol(c)
    for _, part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
    end
end
local function stabFire(knife)
    if not knife then return end
    local stab = knife:FindFirstChild("Stab")
    if not stab then return end
    if stab:IsA("RemoteFunction") then
        for _ = 1, 5 do
            for _ = 1, 3 do pcall(function() stab:InvokeServer("Down") end) end
            task.wait(0.05)
        end
    elseif stab:IsA("RemoteEvent") then
        for _ = 1, 5 do
            for _ = 1, 3 do pcall(function() stab:FireServer("Down") end) end
            task.wait(0.05)
        end
    end
end
local function killAllStep()
    if not Char then return end
    local hrp = Char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local knife = Char:FindFirstChild("Knife")
    if not knife then
        local bp = Backpack or LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, t in pairs(bp:GetChildren()) do
                if t:IsA("Tool") and string.find(string.lower(t.Name), "knife") then
                    local h = Char:FindFirstChildOfClass("Humanoid")
                    if h then pcall(function() h:EquipTool(t) end) end
                    knife = t
                    break
                end
            end
        end
        if not knife then return end
    end
    local any = false
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local t = p.Character.HumanoidRootPart
            any = true
            pcall(function()
                t.Anchored = true
                t.CanCollide = false
                t.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 2
            end)
            anchoredPlayers[p] = p
            disableCol(p.Character)
        end
    end
    if any then stabFire(Char:FindFirstChild("Knife")) end
end

local KillAllToggle = SafeToggle(MainTab, {
    Title = "Kill All",
    Desc = "Auto-equip knife + stab remote",
    Icon = "skull",
    Value = State.KillAll,
    Callback = function(v)
        State.KillAll = v
        if v then
            task.spawn(function()
                while State.KillAll do
                    pcall(killAllStep)
                    task.wait(0.1)
                end
                unanchorAll()
            end)
        else
            unanchorAll()
        end
    end,
})

-- --------- Anti-Fling ---------
local AntiFlingState = {
    Active = false,
    Heartbeat = nil,
    MyHRPConn = nil,
    MyHRP = nil,
    CharConn = nil,
}

local function AntiFlingTick()
    local myChar = LocalPlayer.Character
    for _, v in ipairs(workspace:GetDescendants()) do
        if v and v:IsA("BasePart")
           and v.Name == "HumanoidRootPart"
           and v.Anchored == false
           and (not myChar or not v:IsDescendantOf(myChar))
        then
            pcall(function()
                v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                v.Velocity = Vector3.new(0, 0, 0)
                v.RotVelocity = Vector3.new(0, 0, 0)
                v.CanCollide = false
            end)
        end
    end
end

local function ProtectMyHRP()
    if AntiFlingState.MyHRPConn then
        pcall(function() AntiFlingState.MyHRPConn:Disconnect() end)
        AntiFlingState.MyHRPConn = nil
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    AntiFlingState.MyHRP = hrp

    AntiFlingState.MyHRPConn = RunService.Heartbeat:Connect(function()
        if not AntiFlingState.Active then return end
        local h = AntiFlingState.MyHRP
        if not h or not h.Parent then return end
        if h.Velocity.Magnitude > 500 or h.RotVelocity.Magnitude > 500 then
            pcall(function()
                h.Velocity = Vector3.new(0, 0, 0)
                h.RotVelocity = Vector3.new(0, 0, 0)
            end)
        end
    end)
end

local function SetAntiFling(state)
    AntiFlingState.Active = state
    State.AntiFling = state
    if state then
        if AntiFlingState.Heartbeat then
            pcall(function() AntiFlingState.Heartbeat:Disconnect() end)
            AntiFlingState.Heartbeat = nil
        end
        AntiFlingState.Heartbeat = RunService.Heartbeat:Connect(function()
            if not AntiFlingState.Active then return end
            pcall(AntiFlingTick)
        end)
        ProtectMyHRP()
        if AntiFlingState.CharConn then
            pcall(function() AntiFlingState.CharConn:Disconnect() end)
            AntiFlingState.CharConn = nil
        end
        AntiFlingState.CharConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if AntiFlingState.Active then ProtectMyHRP() end
        end)
        pcall(function() WindUI:Notify({ Title="Anti-Fling", Content="Enabled", Icon="shield", Duration=2 }) end)
    else
        if AntiFlingState.Heartbeat then
            pcall(function() AntiFlingState.Heartbeat:Disconnect() end)
            AntiFlingState.Heartbeat = nil
        end
        if AntiFlingState.MyHRPConn then
            pcall(function() AntiFlingState.MyHRPConn:Disconnect() end)
            AntiFlingState.MyHRPConn = nil
        end
        if AntiFlingState.CharConn then
            pcall(function() AntiFlingState.CharConn:Disconnect() end)
            AntiFlingState.CharConn = nil
        end
        pcall(function() WindUI:Notify({ Title="Anti-Fling", Content="Disabled", Icon="x", Duration=2 }) end)
    end
end

local AntiFlingToggle = SafeToggle(MainTab, {
    Title = "Anti-Fling",
    Desc = "Block fling from other players",
    Icon = "shield",
    Value = State.AntiFling,
    Callback = function(v) SetAntiFling(v) end,
})

-- ================================================================
--                          COMBAT TAB
-- ================================================================
SafeSection(CombatTab, { Title = "Magic Bullet" })
SafeParagraph(CombatTab, {
    Title = "Info",
    Desc = "Hook __namecall. Click player card to set target. Default: Murderer.",
    Icon = "info",
})

_G.MagicBullet = {
    Enabled  = false,
    Selected = nil,
    Target   = nil,
}

local function getMurdererHRP()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local extras  = remotes and remotes:FindFirstChild("Extras")
    local remote  = extras and extras:FindFirstChild("GetPlayerData")
    if not remote then return nil end
    local ok, data = pcall(function() return remote:InvokeServer() end)
    if not ok or type(data) ~= "table" then return nil end
    for name, plrData in pairs(data) do
        if type(plrData) == "table" and plrData.Role == "Murderer" then
            local murd = Players:FindFirstChild(name)
            if not murd then return nil end
            local char = murd.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            return hrp
        end
    end
    return nil
end

local function getSelectedHRP()
    local sel = _G.MagicBullet.Selected
    if sel and sel.Character then
        return sel.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function getGunShootRemote()
    local ch = LocalPlayer.Character
    if ch then
        local g = ch:FindFirstChild("Gun")
        if g then
            local s = g:FindFirstChild("Shoot", true)
            if s then return s end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        local g = bp:FindFirstChild("Gun")
        if g then
            local s = g:FindFirstChild("Shoot", true)
            if s then return s end
        end
    end
    return nil
end

local mbRemote = nil
RunService.RenderStepped:Connect(function()
    mbRemote = getGunShootRemote()
    if _G.MagicBullet.Selected then
        _G.MagicBullet.Target = getSelectedHRP()
    else
        _G.MagicBullet.Target = getMurdererHRP()
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if _G.MagicBullet.Enabled
        and mbRemote
        and self == mbRemote
        and method == "FireServer"
        and _G.MagicBullet.Target
    then
        local args = { ... }
        local hrp = _G.MagicBullet.Target
        args[1] = hrp.CFrame + Vector3.new(0, 3, 0)
        args[2] = hrp.CFrame
        return oldNamecall(self, table.unpack(args))
    end
    return oldNamecall(self, ...)
end)

local MagicBulletToggle = SafeToggle(CombatTab, {
    Title = "Magic Bullet",
    Desc = "Shoot -> bullet flies to target",
    Icon = "crosshair",
    Value = false,
    Callback = function(v)
        _G.MagicBullet.Enabled = v
    end,
})

SafeButton(CombatTab, {
    Title = "Reset Target (Murderer)",
    Desc = "Auto target murderer",
    Icon = "refresh-cw",
    Callback = function()
        _G.MagicBullet.Selected = nil
    end,
})

-- ==================== TARGET PICKER (внутри Combat) ====================
SafeSection(CombatTab, { Title = "Target" })

local PickerAnchor = SafeParagraph(CombatTab, {
    Title = "Pick Target",
    Desc = "Click a card to set target",
    Icon = "user",
})

local PickerParent = nil
pcall(function()
    if PickerAnchor then
        if PickerAnchor.UIElements and PickerAnchor.UIElements[1] then
            PickerParent = PickerAnchor.UIElements[1]
        elseif PickerAnchor.Frame then
            PickerParent = PickerAnchor.Frame
        elseif PickerAnchor.UIElement then
            PickerParent = PickerAnchor.UIElement
        end
    end
end)

local pickerFrame = nil
local pickerCards = {}

if PickerParent then
    for _, child in ipairs(PickerParent:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("ImageLabel") then
            child.Visible = false
        end
    end

    pickerFrame = Instance.new("ScrollingFrame")
    pickerFrame.Name = "PickerContainer"
    pickerFrame.BackgroundTransparency = 1
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Size = UDim2.new(1, -4, 0, 200)
    pickerFrame.Position = UDim2.new(0, 2, 0, 0)
    pickerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    pickerFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pickerFrame.ScrollBarThickness = 4
    pickerFrame.Parent = PickerParent

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 68, 0, 88)
    grid.CellPadding = UDim2.new(0, 6, 0, 6)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    grid.Parent = pickerFrame

    pcall(function()
        PickerParent.AutomaticSize = Enum.AutomaticSize.Y
        PickerParent.Size = UDim2.new(1, 0, 0, 210)
    end)
end

local function makeCard(parent, P)
    local role = RoleNameOf[P.Name] or "Default"
    local col  = roleColor(role)

    local btn = Instance.new("TextButton")
    btn.Name = P.Name
    btn.Size = UDim2.new(0, 68, 0, 88)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = P.UserId or 0

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = col
    stroke.Transparency = 0.1
    stroke.Parent = btn

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 44, 0, 44)
    avatar.Position = UDim2.new(0.5, -22, 0, 6)
    avatar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. P.UserId .. "&w=150&h=150"
    avatar.Parent = btn
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Thickness = 2
    avatarStroke.Color = col
    avatarStroke.Parent = avatar

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -4, 0, 16)
    name.Position = UDim2.new(0, 2, 1, -22)
    name.BackgroundTransparency = 1
    name.Text = P.DisplayName
    name.TextScaled = true
    name.TextColor3 = Color3.fromRGB(240, 240, 240)
    name.Font = Enum.Font.GothamBold
    name.Parent = btn

    local roleTag = Instance.new("TextLabel")
    roleTag.Size = UDim2.new(1, -4, 0, 12)
    roleTag.Position = UDim2.new(0, 2, 1, -14)
    roleTag.BackgroundTransparency = 1
    roleTag.Text = role
    roleTag.TextScaled = true
    roleTag.TextColor3 = col
    roleTag.Font = Enum.Font.Gotham
    roleTag.Parent = btn

    local sel = Instance.new("Frame")
    sel.Size = UDim2.new(1, 0, 1, 0)
    sel.BackgroundTransparency = 1
    sel.Visible = false
    sel.ZIndex = 5
    sel.Parent = btn
    Instance.new("UICorner", sel).CornerRadius = UDim.new(0, 8)
    local selStroke = Instance.new("UIStroke")
    selStroke.Thickness = 3
    selStroke.Color = Color3.fromRGB(255, 255, 255)
    selStroke.Parent = sel

    btn.MouseButton1Click:Connect(function()
        _G.MagicBullet.Selected = P
        for _, c in pairs(pickerCards) do
            if c.Indicator then c.Indicator.Visible = false end
        end
        sel.Visible = true
        pcall(function()
            WindUI:Notify({
                Title = "Magic Bullet",
                Content = "Target: " .. P.DisplayName .. " (" .. role .. ")",
                Icon = "check",
                Duration = 2,
            })
        end)
    end)

    pickerCards[P.Name] = {
        Button = btn,
        Indicator = sel,
        Stroke = stroke,
        AvatarStroke = avatarStroke,
        Label = name,
        RoleTag = roleTag,
        UserId = P.UserId,
    }

    if _G.MagicBullet.Selected and _G.MagicBullet.Selected.UserId == P.UserId then
        sel.Visible = true
    end

    return btn
end

local function refreshCard(P)
    local card = pickerCards[P.Name]
    if not card then return end
    local role = RoleNameOf[P.Name] or "Default"
    local col  = roleColor(role)
    pcall(function()
        card.Stroke.Color = col
        card.AvatarStroke.Color = col
        card.Label.Text = P.DisplayName
        card.RoleTag.Text = role
        card.RoleTag.TextColor3 = col
    end)
    card.Indicator.Visible = (_G.MagicBullet.Selected and _G.MagicBullet.Selected.UserId == P.UserId) and true or false
end

local function rebuildPicker()
    if not pickerFrame then return end
    for _, child in ipairs(pickerFrame:GetChildren()) do
        if not child:IsA("UIGridLayout") then child:Destroy() end
    end
    pickerCards = {}
    for _, P in ipairs(Players:GetPlayers()) do
        if P ~= LocalPlayer then
            makeCard(pickerFrame, P)
        end
    end
end

if pickerFrame then
    rebuildPicker()
    Players.PlayerAdded:Connect(function(P)
        task.wait(0.5)
        if P ~= LocalPlayer and pickerFrame then makeCard(pickerFrame, P) end
    end)
    Players.PlayerRemoving:Connect(function(P)
        local card = pickerCards[P.Name]
        if card and card.Button then card.Button:Destroy(); pickerCards[P.Name] = nil end
        if _G.MagicBullet.Selected == P then _G.MagicBullet.Selected = nil end
    end)
    task.spawn(function()
        while task.wait(0.5) do
            for _, P in ipairs(Players:GetPlayers()) do
                if P ~= LocalPlayer then refreshCard(P) end
            end
        end
    end)
end

-- ================================================================
--                          PLAYERS TAB
-- ================================================================
SafeSection(PlayersTab, { Title = "Live Roles" })

local PlayerCards = {}

local function TeleportToPlayer(T)
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local tc = T.Character
    local tr = tc and (tc:FindFirstChild("HumanoidRootPart") or tc:FindFirstChild("Head"))
    if not tr then return end
    local dist = (myRoot.Position - tr.Position).Magnitude
    local steps = math.ceil(dist / 30) + 1
    local target = CFrame.new(tr.Position) * CFrame.new(0, 3, 0)
    for i = 1, steps do
        myRoot.CFrame = myRoot.CFrame:Lerp(target, i / steps)
        pcall(function() myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
        task.wait()
    end
end

local FlingLock = false
local function SkidFling(Target)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = hum and hum.RootPart
    local tc = Target.Character
    if not tc or not char or not hum or not root then return end
    local th = tc:FindFirstChildOfClass("Humanoid")
    local tr = th and th.RootPart
    local thead = tc:FindFirstChild("Head")
    if not (th and tr) then return end
    if th.Sit then return end
    local OldPos = root.CFrame
    workspace.FallenPartsDestroyHeight = 0/0
    local BV = Instance.new("BodyVelocity")
    BV.Parent = root
    BV.Velocity = Vector3.new(0,0,0)
    BV.MaxForce = Vector3.new(9e9,9e9,9e9)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    workspace.CurrentCamera.CameraSubject = thead or th
    local Time = tick()
    local Angle = 0
    repeat
        Angle = Angle + 100
        local pos = tr.Position
        root.CFrame = CFrame.new(pos) * CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(Angle), 0, 0)
        root.Velocity = Vector3.new(9e7, 9e8, 9e7)
        root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        task.wait()
    until tick() - Time > 2 or not Target.Parent or not char.Parent
    BV:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = hum
    repeat
        root.CFrame = OldPos * CFrame.new(0, 0.5, 0)
        hum:ChangeState("GettingUp")
        for _, p in pairs(char:GetChildren()) do
            if p:IsA("BasePart") then p.Velocity, p.RotVelocity = Vector3.new(), Vector3.new() end
        end
        task.wait()
    until (root.Position - OldPos.p).Magnitude < 25
end

local function SafeFling(T)
    if FlingLock then return end
    FlingLock = true
    task.spawn(function()
        pcall(SkidFling, T)
        task.wait(0.1)
        FlingLock = false
    end)
end

local function CreatePlayerEntry(P)
    local Role = RoleNameOf[P.Name] or "Default"
    local H = SafeParagraph(PlayersTab, {
        Title = P.DisplayName .. " [" .. Role .. "]",
        Desc = "@" .. P.Name,
        Icon = "user",
    })
    if H then
        task.defer(function()
            pcall(function()
                for _, d in ipairs(H:GetDescendants()) do
                    if d:IsA("TextLabel") then
                        d.TextColor3 = roleColor(Role)
                        d.RichText = true
                    end
                end
            end)
        end)
    end
    local Tp = SafeButton(PlayersTab, {
        Title = "TP -> " .. P.DisplayName,
        Desc = "@" .. P.Name .. " - " .. Role,
        Icon = "map-pin",
        Callback = function() task.spawn(function() pcall(TeleportToPlayer, P) end) end,
    })
    local Fl = SafeButton(PlayersTab, {
        Title = "FLING -> " .. P.DisplayName,
        Desc = Role,
        Icon = "skull",
        Callback = function() SafeFling(P) end,
    })
    PlayerCards[P.Name] = { Header = H, TpBtn = Tp, FlBtn = Fl, Role = Role }
end

local function DestroyPlayerEntry(P)
    local C = PlayerCards[P.Name]
    if C then
        if C.Header then pcall(function() C.Header:Destroy() end) end
        if C.TpBtn then pcall(function() C.TpBtn:Destroy() end) end
        if C.FlBtn then pcall(function() C.FlBtn:Destroy() end) end
        PlayerCards[P.Name] = nil
    end
end

local function SortPlayers()
    local L = {}
    for _, P in ipairs(Players:GetPlayers()) do
        if P ~= LocalPlayer then
            local R = RoleNameOf[P.Name] or "Default"
            table.insert(L, { Player = P, Role = R, Priority = ROLE_PRIORITY[R] or 99 })
        end
    end
    table.sort(L, function(a,b)
        if a.Priority ~= b.Priority then return a.Priority < b.Priority end
        return a.Player.Name:lower() < b.Player.Name:lower()
    end)
    return L
end

local LastHash = ""
local function RebuildPlayerList()
    local L = SortPlayers()
    local H = ""
    for _, i in ipairs(L) do H = H .. i.Player.Name .. ":" .. (RoleNameOf[i.Player.Name] or "Default") .. "|" end
    if H == LastHash then
        for _, i in ipairs(L) do
            local C = PlayerCards[i.Player.Name]
            if C then
                local Col = roleColor(i.Role)
                if C.Header then
                    pcall(function() C.Header:SetTitle(i.Player.DisplayName .. " [" .. i.Role .. "]") end)
                    pcall(function() C.Header:SetDesc("@" .. i.Player.Name) end)
                end
                if C.TpBtn then pcall(function() C.TpBtn:SetDesc("@" .. i.Player.Name .. " - " .. i.Role) end) end
                if C.FlBtn then pcall(function() C.FlBtn:SetDesc(i.Role) end) end
                if C.Header then
                    task.defer(function()
                        pcall(function()
                            for _, d in ipairs(C.Header:GetDescendants()) do
                                if d:IsA("TextLabel") then d.TextColor3 = Col; d.RichText = true end
                            end
                        end)
                    end)
                end
            end
        end
        return
    end
    LastHash = H
    for n in pairs(PlayerCards) do
        local P = Players:FindFirstChild(n)
        if P then DestroyPlayerEntry(P) end
    end
    for _, i in ipairs(L) do CreatePlayerEntry(i.Player) end
end

RebuildPlayerList()
Players.PlayerAdded:Connect(function(P) if P ~= LocalPlayer then task.wait(1); RebuildPlayerList() end end)
Players.PlayerRemoving:Connect(function(P) DestroyPlayerEntry(P); RebuildPlayerList() end)
task.spawn(function() while true do task.wait(0.5); pcall(updateRoles); pcall(RebuildPlayerList) end end)

-- ================================================================
--                          PLAYER TAB
-- ================================================================
SafeSection(PlayerTab, { Title = "Movement" })

local NoclipToggle = SafeToggle(PlayerTab, {
    Title = "Noclip",
    Desc = "Walk through walls",
    Icon = "ghost",
    Value = State.Noclip,
    Callback = function(v)
        State.Noclip = v
        if not v and Char then
            for _, c in pairs(Char:GetChildren()) do
                if c:IsA("BasePart") then c.CanCollide = true end
            end
        end
    end,
})

RunService.Stepped:Connect(function()
    if State.Noclip and Char then
        for _, c in pairs(Char:GetChildren()) do
            if c:IsA("BasePart") then c.CanCollide = false end
        end
    end
end)

SafeToggle(PlayerTab, {
    Title = "Infinite Jump",
    Desc = "Multi jump",
    Icon = "arrow-up",
    Value = State.InfiniteJump,
    Callback = function(v) State.InfiniteJump = v end,
})

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and Char then
        local hum = Char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
    end
end)

SafeSection(PlayerTab, { Title = "WalkSpeed" })
SafeSlider(PlayerTab, {
    Title = "WalkSpeed",
    Desc = "16 - 350",
    Value = { Min = 16, Max = 350, Default = State.WalkSpeed },
    Step = 1,
    Callback = function(v)
        if type(v) ~= "number" then return end
        State.WalkSpeed = v
        if Char then
            local hum = Char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end,
})
SafeInput(PlayerTab, {
    Title = "WalkSpeed (textbox)",
    Placeholder = tostring(State.WalkSpeed),
    Callback = function(text)
        local n = tonumber(text) or 16
        State.WalkSpeed = n
        if Char then
            local hum = Char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = n end
        end
    end,
})
SafeToggle(PlayerTab, {
    Title = "Keep WalkSpeed",
    Desc = "Lock current value",
    Icon = "lock",
    Value = State.KeepWS,
    Callback = function(v)
        State.KeepWS = v
        if v then
            task.spawn(function()
                while State.KeepWS do
                    if Char then
                        local hum = Char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.WalkSpeed ~= State.WalkSpeed then
                            hum.WalkSpeed = State.WalkSpeed
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

SafeSection(PlayerTab, { Title = "JumpPower" })
SafeSlider(PlayerTab, {
    Title = "JumpPower",
    Desc = "50 - 500",
    Value = { Min = 50, Max = 500, Default = State.JumpPower },
    Step = 1,
    Callback = function(v)
        if type(v) ~= "number" then return end
        State.JumpPower = v
        if Char then
            local hum = Char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end,
})
SafeInput(PlayerTab, {
    Title = "JumpPower (textbox)",
    Placeholder = tostring(State.JumpPower),
    Callback = function(text)
        local n = tonumber(text) or 50
        State.JumpPower = n
        if Char then
            local hum = Char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = n end
        end
    end,
})
SafeToggle(PlayerTab, {
    Title = "Keep JumpPower",
    Desc = "Lock current value",
    Icon = "lock",
    Value = State.KeepJP,
    Callback = function(v)
        State.KeepJP = v
        if v then
            task.spawn(function()
                while State.KeepJP do
                    if Char then
                        local hum = Char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.JumpPower ~= State.JumpPower then
                            hum.JumpPower = State.JumpPower
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- ================================================================
--                          BINDS TAB
-- ================================================================
SafeSection(BindsTab, { Title = "Keybinds" })
SafeParagraph(BindsTab, {
    Title = "Note",
    Desc = "Press key to toggle. Clear = reset bind.",
    Icon = "info",
})

local BindRegistry = {}

local function MakeBind(name, cfg, onActivate)
    local bind = SafeKeybind(BindsTab, {
        Title = cfg.Title,
        Desc = cfg.Desc,
        Icon = cfg.Icon or "key",
        Value = Binds[name] or "None",
        Callback = onActivate,
    })
    if bind then BindRegistry[name] = bind end

    SafeButton(BindsTab, {
        Title = "Clear Bind: " .. name,
        Desc = "Reset to None",
        Icon = "x",
        Callback = function()
            local b = BindRegistry[name]
            if b then pcall(function() b:Set(Enum.KeyCode.Unknown) end) end
            Binds[name] = "None"
            pcall(function()
                WindUI:Notify({
                    Title = "Bind Cleared",
                    Content = name .. " -> None",
                    Icon = "check",
                    Duration = 2,
                })
            end)
        end,
    })
end

MakeBind("KillAll", { Title = "Bind: Kill All", Desc = "Toggle Kill All", Icon = "skull" }, function()
    if KillAllToggle then pcall(function() KillAllToggle:Set(not State.KillAll) end) end
end)

MakeBind("Noclip", { Title = "Bind: Noclip", Desc = "Toggle Noclip", Icon = "key" }, function()
    if NoclipToggle then pcall(function() NoclipToggle:Set(not State.Noclip) end) end
end)

MakeBind("Invis", { Title = "Bind: Invisibility", Desc = "Toggle Invis", Icon = "ghost" }, function()
    if InvisToggle then pcall(function() InvisToggle:Set(not State.Invis) end) end
end)

MakeBind("ESP", { Title = "Bind: ESP Player", Desc = "Toggle ESP", Icon = "eye" }, function()
    if ESPToggle then pcall(function() ESPToggle:Set(not State.ESP) end) end
end)

MakeBind("Wallshot", { Title = "Bind: Magic Bullet", Desc = "Toggle Magic Bullet", Icon = "crosshair" }, function()
    if MagicBulletToggle then pcall(function() MagicBulletToggle:Set(not _G.MagicBullet.Enabled) end) end
end)

MakeBind("AntiFling", { Title = "Bind: Anti-Fling", Desc = "Toggle Anti-Fling", Icon = "shield" }, function()
    if AntiFlingToggle then pcall(function() AntiFlingToggle:Set(not State.AntiFling) end) end
end)

-- ================================================================
--                        GLOBAL LOOPS
-- ================================================================
task.spawn(function()
    while task.wait(0.25) do
        pcall(tickESP)
        pcall(tickGunESP)
    end
end)

pcall(function()
    WindUI:Notify({ Title = "AstraL Lite v4", Content = "Loaded", Icon = "check", Duration = 3 })
end)
