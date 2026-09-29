-- ======================================================
-- AstraL | for MM2 (by @burmaldashell)
-- UI: WindUI | Theme: Dark | Z to toggle
-- ======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

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
        if ok and result then WindUI = result break end
    end
    if not WindUI then error("[AstraL] Failed to load WindUI") end
end

-- ==================== STATE ====================
local State = {
    PlayerESP = false, GunESP = false, Invisibility = false,
    AutoGrabGun = false, AntiFling = false, KillAll = false,
    ShotMurder = false, BombJump = false,
    AntiFlingHeartbeat = nil,
    GunGrabThread = nil, KillThread = nil,
    ShotMurderLoop = nil,
    ESPData = {}, GunHL = nil,
    RoleNameOf = {},

    WalkSpeed = 16, JumpPower = 50,
    BHop = false, BHopMaxSpeed = 25, BHopSpeed = 0,
    BHopConn = nil, BHopLabel = nil,

    ShootSoundChoice = "Custom 1",
    HitSoundChoice = "Custom 1",

    BindMap = {},
}

-- ==================== ROLES ====================
local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(70, 140, 255),
    Hero     = Color3.fromRGB(255, 215, 90),
    Innocent = Color3.fromRGB(80, 255, 130),
    Lobby    = Color3.fromRGB(150, 150, 150),
}
local ROLE_PRIORITY = { Murderer=1, Sheriff=2, Hero=3, Innocent=4, Lobby=5 }
local function RoleColorOf(n) return ROLE_COLORS[State.RoleNameOf[n] or "Lobby"] or ROLE_COLORS.Lobby end
local function RoleOf(n) return State.RoleNameOf[n] or "Lobby" end

local function UpdateRoles()
    local gpd = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not gpd then return end
    local ok, data = pcall(function() return gpd:InvokeServer() end)
    if not ok or type(data) ~= "table" then return end
    local names = {}
    for n, i in pairs(data) do
        if type(i) == "table" then
            names[n] = true
            local r = i.Role
            if r == "Murderer" then State.RoleNameOf[n] = "Murderer"
            elseif r == "Sheriff" then State.RoleNameOf[n] = "Sheriff"
            elseif r == "Hero" then State.RoleNameOf[n] = "Hero"
            elseif r == "Innocent" then State.RoleNameOf[n] = "Innocent"
            else State.RoleNameOf[n] = "Lobby" end
        end
    end
    for n in pairs(State.RoleNameOf) do
        if not names[n] then State.RoleNameOf[n] = nil end
    end
end

-- ==================== SOUNDS ====================
local SOUND_PRESETS = {
    Shoot = {
        { name = "Custom 1", id = "78469882347907" },
        { name = "Custom 2", id = "139452805868562" },
    },
    Hit = {
        { name = "Custom 1", id = "78469882347907" },
        { name = "Custom 2", id = "139452805868562" },
    },
}
local activeShootSounds = {}

local function GetSoundId(kind)
    local choice = (kind == "Shoot") and State.ShootSoundChoice or State.HitSoundChoice
    for _, p in ipairs(SOUND_PRESETS[kind]) do
        if p.name == choice then return "rbxassetid://" .. p.id end
    end
    return "rbxassetid://" .. SOUND_PRESETS[kind][1].id
end

local function PlayShootSound()
    local s = Instance.new("Sound")
    s.SoundId = GetSoundId("Shoot")
    s.Volume = 3
    s.Parent = SoundService
    s:Play()
    table.insert(activeShootSounds, s)
    task.delay(3, function()
        pcall(function() s:Destroy() end)
        for i, v in ipairs(activeShootSounds) do
            if v == s then table.remove(activeShootSounds, i) break end
        end
    end)
end

local function PlayHitSound()
    for _, s in ipairs(activeShootSounds) do pcall(function() s:Stop() end) end
    activeShootSounds = {}
    local s = Instance.new("Sound")
    s.SoundId = GetSoundId("Hit")
    s.Volume = 3
    s.Parent = SoundService
    s:Play()
    task.delay(2, function() pcall(function() s:Destroy() end) end)
end

-- ==================== ESP ====================
local function BuildESP(P)
    local C = P.Character
    local H = C and C:FindFirstChild("Head")
    if not H then return nil end
    local HL = Instance.new("Highlight")
    HL.FillTransparency = 0.35
    HL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    local BB = Instance.new("BillboardGui")
    BB.Size = UDim2.fromOffset(220, 50)
    BB.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    BB.AlwaysOnTop = true
    BB.MaxDistance = 450
    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1, 0, 0.6, 0)
    nm.BackgroundTransparency = 1
    nm.Font = Enum.Font.GothamBold
    nm.TextSize = 17
    nm.TextStrokeTransparency = 0.3
    nm.Text = P.DisplayName
    local dst = Instance.new("TextLabel")
    dst.Size = UDim2.new(1, 0, 0.4, 0)
    dst.Position = UDim2.new(0, 0, 0.6, 0)
    dst.BackgroundTransparency = 1
    dst.Font = Enum.Font.Gotham
    dst.TextSize = 13
    dst.TextColor3 = Color3.fromRGB(170, 170, 170)
    dst.TextStrokeTransparency = 0.5
    dst.Text = "0 studs"
    nm.Parent = BB
    dst.Parent = BB
    HL.Parent = C
    BB.Parent = H
    return { Character=C, Highlight=HL, Billboard=BB, Name=nm, Dist=dst }
end

local function RefreshESP(P)
    local E = State.ESPData[P]
    if not P.Character then
        if E then
            pcall(function() E.Highlight:Destroy() end)
            pcall(function() E.Billboard:Destroy() end)
            State.ESPData[P] = nil
        end
        return
    end
    if not E or E.Character ~= P.Character or not E.Billboard.Parent then
        if E then
            pcall(function() E.Highlight:Destroy() end)
            pcall(function() E.Billboard:Destroy() end)
        end
        State.ESPData[P] = BuildESP(P)
        E = State.ESPData[P]
        if not E then return end
    end
    local col = RoleColorOf(P.Name)
    pcall(function()
        E.Highlight.OutlineColor = col
        E.Highlight.FillColor = col
        E.Name.TextColor3 = col
    end)
    local myC = LocalPlayer.Character
    local myHRP = myC and myC:FindFirstChild("HumanoidRootPart")
    local tC = P.Character
    local tHRP = tC and (tC:FindFirstChild("HumanoidRootPart") or tC:FindFirstChild("Head"))
    if myHRP and tHRP then
        local d = (myHRP.Position - tHRP.Position).Magnitude
        pcall(function() E.Dist.Text = string.format("%d studs", math.floor(d + 0.5)) end)
    end
end

local function CleanESP()
    for _, E in pairs(State.ESPData) do
        pcall(function() E.Highlight:Destroy() end)
        pcall(function() E.Billboard:Destroy() end)
    end
    State.ESPData = {}
end

-- ==================== GUN ESP ====================
local function CleanGunESP()
    if State.GunHL then
        pcall(function() State.GunHL:Destroy() end)
        State.GunHL = nil
    end
end

local function UpdateGunESP()
    if not State.GunESP then CleanGunESP(); return end
    local gun = workspace:FindFirstChild("GunDrop", true)
    if not gun then CleanGunESP(); return end
    local parent = gun:IsA("Model") and gun or (gun:IsA("BasePart") and gun or gun:FindFirstChildWhichIsA("BasePart"))
    if not parent then return end
    if not State.GunHL or State.GunHL.Parent ~= parent then
        CleanGunESP()
        State.GunHL = Instance.new("Highlight")
        State.GunHL.FillColor = Color3.fromRGB(255, 215, 0)
        State.GunHL.FillTransparency = 0.4
        State.GunHL.OutlineColor = Color3.fromRGB(255, 170, 0)
        State.GunHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        State.GunHL.Parent = parent
    end
end

-- ==================== INVIS ====================
local invisBodyParts = {}
local invisHumanoid = nil
local invisHRP = nil
local invisInvisible = false
local invisOriginalTransparency = {}

local function InvisCollectParts()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    invisHumanoid = char:WaitForChild("Humanoid")
    invisHRP = char:WaitForChild("HumanoidRootPart")
    invisBodyParts = {}
    invisOriginalTransparency = {}
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(invisBodyParts, part)
            invisOriginalTransparency[part] = part.Transparency
        end
    end
end

local function InvisApplyTransparency()
    for _, part in pairs(invisBodyParts) do
        if part and part.Parent then
            if invisInvisible then
                part.Transparency = (invisOriginalTransparency[part] == 0) and 0.5 or 0
            else
                part.Transparency = invisOriginalTransparency[part] or 0
            end
        end
    end
end

local function InvisSet(state)
    invisInvisible = state
    State.Invisibility = state
    InvisApplyTransparency()
end

RunService.Heartbeat:Connect(function()
    if invisInvisible and invisHRP and invisHumanoid and invisHRP.Parent and invisHumanoid.Parent then
        local originalCFrame = invisHRP.CFrame
        local originalCameraOffset = invisHumanoid.CameraOffset
        local hiddenCFrame = originalCFrame * CFrame.new(0, -200000, 0)
        invisHRP.CFrame = hiddenCFrame
        invisHumanoid.CameraOffset = hiddenCFrame:ToObjectSpace(CFrame.new(originalCFrame.Position)).Position
        RunService.RenderStepped:Wait()
        invisHRP.CFrame = originalCFrame
        invisHumanoid.CameraOffset = originalCameraOffset
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    InvisCollectParts()
    if invisInvisible then InvisApplyTransparency() end
end)
task.spawn(function() task.wait(1); InvisCollectParts() end)

-- ==================== AUTO GRAB ====================
local function StartAutoGrab()
    if State.GunGrabThread then return end
    State.GunGrabThread = task.spawn(function()
        while State.AutoGrabGun do
            task.wait(0.1)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local gun = workspace:FindFirstChild("GunDrop", true)
                if gun and gun:IsA("BasePart") then
                    if firetouchinterest then
                        pcall(function()
                            firetouchinterest(root, gun, 0)
                            firetouchinterest(root, gun, 1)
                        end)
                    else
                        pcall(function() gun.CFrame = root.CFrame end)
                    end
                end
            end
        end
        State.GunGrabThread = nil
    end)
end

local function SetAutoGrab(s)
    State.AutoGrabGun = s
    if s then StartAutoGrab() else State.GunGrabThread = nil end
end

-- ==================== ANTI-FLING ====================
local function AntiFling()
    for _, v in next, game:GetDescendants() do
        if v and v:IsA("Part")
            and v.Parent ~= LocalPlayer.Character
            and v.Anchored == false
            and v.Name == "HumanoidRootPart" then
            State.AntiFlingHeartbeat = RunService.Heartbeat:Connect(function()
                v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                v.Velocity = Vector3.new(0, 0, 0)
                v.RotVelocity = Vector3.new(0, 0, 0)
                v.CanCollide = false
                task.wait(1)
            end)
        end
    end
end

local function SetAntiFling(s)
    State.AntiFling = s
    if s then
        AntiFling()
    else
        if State.AntiFlingHeartbeat then
            pcall(function() State.AntiFlingHeartbeat:Disconnect() end)
            State.AntiFlingHeartbeat = nil
        end
    end
end

workspace.DescendantAdded:Connect(function(part)
    if part:IsA("Part") and part.Name == "HumanoidRootPart"
        and part.Parent ~= LocalPlayer.Character and State.AntiFling then
        task.wait(2)
        if State.AntiFling then AntiFling() end
    end
end)

-- ==================== KILL ALL ====================
local Anchored = {}
local function Unanchor()
    for p in pairs(Anchored) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            pcall(function() hrp.Anchored = false; hrp.CanCollide = true end)
        end
    end
    Anchored = {}
end

local function FindKnife()
    local c = LocalPlayer.Character
    if not c then return nil end
    local t = c:FindFirstChildOfClass("Tool")
    if t and t:FindFirstChild("Handle") and tostring(t.Name):lower():find("knife") then return t end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, x in ipairs(bp:GetChildren()) do
            if x:IsA("Tool") and x:FindFirstChild("Handle") and tostring(x.Name):lower():find("knife") then
                return x
            end
        end
    end
    return nil
end

local function EquipKnife(k)
    if not k or k.Parent == LocalPlayer.Character then return end
    local c = LocalPlayer.Character
    if c then
        k.Parent = c
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h:EquipTool(k) end) end
    end
end

local function StabFire(knife)
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

local function KillAllStep()
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    EquipKnife(FindKnife())
    local knife = c:FindFirstChild("Knife")
    local any = false
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local tHRP = p.Character.HumanoidRootPart
            any = true
            pcall(function()
                tHRP.Anchored = true
                tHRP.CanCollide = false
                tHRP.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 2
            end)
            Anchored[p] = true
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
            end
        end
    end
    if any then
        StabFire(knife)
        task.wait(0.2)
        Unanchor()
    end
end

local function SetKillAll(s)
    State.KillAll = s
    if s then
        State.KillThread = task.spawn(function()
            while State.KillAll do
                pcall(KillAllStep)
                task.wait(0.15)
            end
            Unanchor()
        end)
    else
        State.KillThread = nil
        Unanchor()
    end
end

-- ==================== SHOT MURDER ====================
local shotMurderHighlight = nil

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and RoleOf(p.Name) == "Murderer" and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then return p end
        end
    end
    return nil
end

local function ClearShotMurderHighlight()
    if shotMurderHighlight then
        pcall(function() shotMurderHighlight:Destroy() end)
        shotMurderHighlight = nil
    end
end

local function RefreshShotMurder()
    if not State.ShotMurder then ClearShotMurderHighlight(); return end
    local target = GetMurderer()
    if not target or not target.Character then ClearShotMurderHighlight(); return end
    if shotMurderHighlight and shotMurderHighlight.Parent == target.Character then return end
    ClearShotMurderHighlight()
    shotMurderHighlight = Instance.new("Highlight")
    shotMurderHighlight.Name = "AstraL_ShotMurderHL"
    shotMurderHighlight.FillColor = Color3.fromRGB(255, 50, 50)
    shotMurderHighlight.FillTransparency = 0.3
    shotMurderHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    shotMurderHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    shotMurderHighlight.Parent = target.Character
end

local function StartShotMurder()
    if State.ShotMurderLoop then return end
    State.ShotMurderLoop = RunService.Heartbeat:Connect(function()
        pcall(RefreshShotMurder)
    end)
end

local function StopShotMurder()
    if State.ShotMurderLoop then
        pcall(function() State.ShotMurderLoop:Disconnect() end)
        State.ShotMurderLoop = nil
    end
    ClearShotMurderHighlight()
end

local function SetShotMurder(s)
    State.ShotMurder = s
    if s then StartShotMurder() else StopShotMurder() end
end

-- ==================== SOUND HOOKS ====================
local hookedRemotes = {}

local function HookGun(gun)
    if not gun or hookedRemotes[gun] then return end
    local shoot = gun:FindFirstChild("Shoot")
    if not shoot then return end
    hookedRemotes[gun] = true
    if shoot:IsA("RemoteEvent") then
        pcall(function()
            shoot.OnClientEvent:Connect(function(...)
                PlayShootSound()
            end)
        end)
        if hookfunction then
            local old = hookfunction(shoot.FireServer, newcclosure(function(self, ...)
                PlayShootSound()
                task.spawn(function()
                    task.wait(0.12)
                    local m = GetMurderer()
                    if m and m.Character then
                        local hum = m.Character:FindFirstChildOfClass("Humanoid")
                        if not hum or hum.Health <= 0 then PlayHitSound() end
                    end
                end)
                return old(self, ...)
            end))
        end
    end
end

local function ScanGuns()
    local c = LocalPlayer.Character
    if c then
        local gun = c:FindFirstChild("Gun") or c:FindFirstChild("Revolver")
        if gun then HookGun(gun) end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, x in ipairs(bp:GetChildren()) do
            if x:IsA("Tool") and (x.Name == "Gun" or x.Name == "Revolver") then HookGun(x) end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function() task.wait(1); ScanGuns() end)
task.spawn(function() while task.wait(1) do pcall(ScanGuns) end end)

-- ==================== BOMB JUMP ====================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not State.BombJump then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local c = LocalPlayer.Character
    local T = c and c:FindFirstChildOfClass("Tool")
    if not T then return end
    local n = tostring(T.Name):lower()
    if not (n:find("bomb") or n:find("grenade") or n:find("explosive")) then return end
    task.spawn(function()
        task.wait(0.05)
        local c2 = LocalPlayer.Character
        local h = c2 and c2:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

-- ==================== TELEPORT ====================
local function TeleportTo(T)
    local c = LocalPlayer.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    local tc = T.Character
    local tr = tc and (tc:FindFirstChild("HumanoidRootPart") or tc:FindFirstChild("Head"))
    if not (root and tr) then return end
    root.CFrame = CFrame.new(tr.Position + Vector3.new(0, 3, 0))
end

-- ==================== FLING ====================
getgenv().AstraLOldPos = nil
getgenv().AstraLFPDH = workspace.FallenPartsDestroyHeight
local FlingLock = false

local function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    local THumanoid, TRootPart, THead, Accessory, Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then THumanoid = TCharacter:FindFirstChildOfClass("Humanoid") end
    if THumanoid and THumanoid.RootPart then TRootPart = THumanoid.RootPart end
    if TCharacter:FindFirstChild("Head") then THead = TCharacter.Head end
    if TCharacter:FindFirstChildOfClass("Accessory") then Accessory = TCharacter:FindFirstChildOfClass("Accessory") end
    if Accessory and Accessory:FindFirstChild("Handle") then Handle = Accessory.Handle end
    if not (Character and Humanoid and RootPart) then return end
    if RootPart.Velocity.Magnitude < 50 then getgenv().AstraLOldPos = RootPart.CFrame end
    if THumanoid and THumanoid.Sit then return end
    if THead then workspace.CurrentCamera.CameraSubject = THead
    elseif Handle then workspace.CurrentCamera.CameraSubject = Handle
    elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end
    if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
    local FPos = function(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end
    local SFBasePart = function(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0
        repeat
            if RootPart and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle = Angle + 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                else
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                end
            end
        until Time + TimeToWait < tick()
    end
    workspace.FallenPartsDestroyHeight = 0/0
    local BV = Instance.new("BodyVelocity")
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    if TRootPart then SFBasePart(TRootPart)
    elseif THead then SFBasePart(THead)
    elseif Handle then SFBasePart(Handle) end
    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = Humanoid
    if getgenv().AstraLOldPos then
        repeat
            RootPart.CFrame = getgenv().AstraLOldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().AstraLOldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                end
            end
            task.wait()
        until (RootPart.Position - getgenv().AstraLOldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().AstraLFPDH
    end
end

local function Fling(T)
    if FlingLock then return end
    FlingLock = true
    task.spawn(function()
        pcall(SkidFling, T)
        task.wait(0.1)
        FlingLock = false
    end)
end

-- ==================== MOVEMENT ====================
local function ApplyWalkSpeed(v)
    State.WalkSpeed = v
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h and not State.BHop then h.WalkSpeed = v end
end

local function ApplyJumpPower(v)
    State.JumpPower = v
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then
        h.JumpPower = v
        h.UseJumpPower = true
    end
end

LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then
        h.WalkSpeed = State.WalkSpeed
        h.JumpPower = State.JumpPower
        h.UseJumpPower = true
    end
    State.BHopSpeed = 0
    local root = c:FindFirstChild("HumanoidRootPart")
    if root then State.LastHRPPos = root.Position end
end)

-- ==================== B-HOP ====================
local function CreateBHopLabel()
    if State.BHopLabel then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "AstraL_BHop"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromOffset(320, 32)
    lbl.Position = UDim2.new(0.5, -160, 0, 90)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 20
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.Text = "Speed: 0"
    lbl.Visible = false
    lbl.Parent = gui
    local st = Instance.new("UIStroke", lbl)
    st.Color = Color3.fromRGB(0, 0, 0)
    st.Thickness = 2
    st.Transparency = 0
    State.BHopLabel = lbl
end

local function ResetBHop()
    State.BHopSpeed = 0
    if State.BHopLabel then
        State.BHopLabel.Text = string.format("Speed: %d", math.floor(State.BHopSpeed))
    end
end

local function StartBHop()
    if State.BHopConn then return end
    CreateBHopLabel()
    State.BHopLabel.Visible = true
    State.LastHRPPos = nil
    State.BHopConn = RunService.Heartbeat:Connect(function(dt)
        if not State.BHop then
            if State.BHopLabel then State.BHopLabel.Visible = false end
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = State.WalkSpeed end
            State.BHopSpeed = 0
            if State.BHopConn then
                pcall(function() State.BHopConn:Disconnect() end)
                State.BHopConn = nil
            end
            return
        end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if not (h and root) then return end
        local curPos = root.Position
        if State.LastHRPPos then
            local delta = (curPos - State.LastHRPPos).Magnitude
            local expected = State.WalkSpeed * dt * 0.5
            if h.MoveDirection.Magnitude > 0.1 and delta < expected * 0.3 then
                ResetBHop()
            end
        end
        State.LastHRPPos = curPos
        if h:GetState() == Enum.HumanoidStateType.Freefall
            or h:GetState() == Enum.HumanoidStateType.Jumping then
            if h.MoveDirection.Magnitude > 0.1 then
                State.BHopSpeed = math.min(State.BHopSpeed + dt * 8, State.BHopMaxSpeed)
            end
        end
        if h:GetState() == Enum.HumanoidStateType.Running and h.MoveDirection.Magnitude < 0.1 then
            State.BHopSpeed = math.max(State.BHopSpeed - dt * 6, 0)
        end
        local applied = State.WalkSpeed + State.BHopSpeed
        h.WalkSpeed = applied
        if State.BHopLabel then
            State.BHopLabel.Text = string.format("Speed: %d", math.floor(applied))
        end
    end)
end

local function StopBHop()
    if State.BHopConn then
        pcall(function() State.BHopConn:Disconnect() end)
        State.BHopConn = nil
    end
    if State.BHopLabel then State.BHopLabel.Visible = false end
    State.BHopSpeed = 0
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = State.WalkSpeed end
end

-- ==================== WINDOW ====================
local Window = WindUI:CreateWindow({
    Title = "AstraL", Author = "for MM2", Icon = "sword", Folder = "AstraL",
    Size = UDim2.fromOffset(660, 480), Theme = "Dark",
    Transparent = true, Resizable = true, SideBarWidth = 180,
    ToggleKey = Enum.KeyCode.Z,
    OpenButton = {
        Title = "AstraL", Enabled = true, OnlyMobile = false,
        Draggable = true, OnlyIcon = false, Scale = 1, StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromRGB(80, 120, 255)),
    },
})

pcall(function()
    local OB = Window and Window.OpenButtonMain
    if OB and OB.Button then
        local Btn = OB.Button
        Btn.AutomaticSize = ""
        Btn.Size = UDim2.new(0, 170, 0, 44)
        Btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
        Btn.BackgroundTransparency = 0.05
        local corner = Btn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", Btn)
        corner.CornerRadius = UDim.new(0, 10)
        local grad = Btn:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", Btn)
        grad.Rotation = 90
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 70, 78)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(36, 36, 42)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 12, 16)),
        })
        local stroke = Btn:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", Btn)
        stroke.Color = Color3.fromRGB(120, 120, 130)
        stroke.Thickness = 1.2
        stroke.Transparency = 0.35
    end
end)

local MainTab = Window:Tab({ Title = "Main", Desc = "ESP, Combat", Icon = "sword" })
local MovementTab = Window:Tab({ Title = "Movement", Desc = "Speed / Jump / BHop", Icon = "footprints" })
local SoundsTab = Window:Tab({ Title = "Sounds", Desc = "Shoot & Hit", Icon = "music" })
local PlayersTab = Window:Tab({ Title = "Players", Desc = "Roles", Icon = "users" })

-- ==================== BINDS ====================
local BindMap = {}
local function CreateBind(tab, title, bindName, callback)
    BindMap[bindName] = { key = "None", callback = callback }
    tab:Keybind({
        Title = "Bind: " .. title,
        Desc = "Set keybind",
        Icon = "key",
        Value = "None",
        Callback = function(newKey)
            if type(newKey) == "string" and newKey ~= "" then
                BindMap[bindName].key = newKey
            elseif type(newKey) == "table" and newKey.Name then
                BindMap[bindName].key = newKey.Name
            end
        end,
    })
    tab:Button({
        Title = "Clear Bind: " .. title,
        Desc = "Reset keybind to None",
        Icon = "x",
        Callback = function()
            BindMap[bindName].key = "None"
            pcall(function()
                WindUI:Notify({
                    Title = "Bind Cleared",
                    Content = bindName .. " -> None",
                    Icon = "check",
                    Duration = 2,
                })
            end)
        end,
    })
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.Z then return end
    for bindName, data in pairs(BindMap) do
        if data.key ~= "None" and data.key == input.KeyCode.Name then
            task.spawn(function() pcall(data.callback) end)
            break
        end
    end
end)

-- ==================== MAIN TAB ====================
MainTab:Section({ Title = "ESP" })

MainTab:Toggle({ Title = "Player ESP", Desc = "Role-colored outline + distance", Icon = "eye",
    Value = State.PlayerESP,
    Callback = function(v) State.PlayerESP = v; if not v then CleanESP() end end })
CreateBind(MainTab, "Player ESP", "PlayerESP", function()
    State.PlayerESP = not State.PlayerESP
    if not State.PlayerESP then CleanESP() end
end)

MainTab:Toggle({ Title = "Gun ESP", Desc = "Highlight dropped gun", Icon = "crosshair",
    Value = State.GunESP,
    Callback = function(v) State.GunESP = v; if not v then CleanGunESP() end end })
CreateBind(MainTab, "Gun ESP", "GunESP", function()
    State.GunESP = not State.GunESP
    if not State.GunESP then CleanGunESP() end
end)

MainTab:Section({ Title = "Invisibility" })
MainTab:Toggle({ Title = "Invisibility", Desc = "Teleport under map", Icon = "ghost",
    Value = State.Invisibility,
    Callback = function(v) InvisSet(v) end })
CreateBind(MainTab, "Invisibility", "Invisibility", function()
    InvisSet(not State.Invisibility)
end)

MainTab:Section({ Title = "Combat" })
MainTab:Toggle({ Title = "Auto Grab Gun", Desc = "Touch-pickup gun drop", Icon = "zap",
    Value = State.AutoGrabGun,
    Callback = function(v) SetAutoGrab(v) end })
CreateBind(MainTab, "Auto Grab Gun", "AutoGrabGun", function()
    State.AutoGrabGun = not State.AutoGrabGun
    SetAutoGrab(State.AutoGrabGun)
end)

MainTab:Toggle({ Title = "Anti-Fling", Desc = "Protection against fling", Icon = "shield",
    Value = State.AntiFling,
    Callback = function(v) SetAntiFling(v) end })
CreateBind(MainTab, "Anti-Fling", "AntiFling", function()
    State.AntiFling = not State.AntiFling
    SetAntiFling(State.AntiFling)
end)

MainTab:Toggle({ Title = "Kill All", Desc = "Stab everyone with knife", Icon = "skull",
    Value = State.KillAll,
    Callback = function(v) SetKillAll(v) end })
CreateBind(MainTab, "Kill All", "KillAll", function()
    State.KillAll = not State.KillAll
    SetKillAll(State.KillAll)
end)

MainTab:Toggle({ Title = "Shot Murder", Desc = "Highlight Murderer (you shoot him)", Icon = "crosshair",
    Value = State.ShotMurder,
    Callback = function(v) SetShotMurder(v) end })
CreateBind(MainTab, "Shot Murder", "ShotMurder", function()
    SetShotMurder(not State.ShotMurder)
end)

MainTab:Toggle({ Title = "Bomb Jump", Desc = "Jump when throwing bomb", Icon = "zap",
    Value = State.BombJump,
    Callback = function(v) State.BombJump = v end })
CreateBind(MainTab, "Bomb Jump", "BombJump", function()
    State.BombJump = not State.BombJump
end)

-- ==================== MOVEMENT ====================
MovementTab:Section({ Title = "Speed" })
MovementTab:Slider({
    Title = "WalkSpeed", Desc = "Base walk speed", Icon = "wind",
    Value = { Min = 16, Max = 100, Default = State.WalkSpeed }, Step = 1,
    Callback = function(v) ApplyWalkSpeed(v) end,
})

MovementTab:Section({ Title = "Jump" })
MovementTab:Slider({
    Title = "Jump Power", Desc = "Jump height", Icon = "arrow-up",
    Value = { Min = 50, Max = 300, Default = State.JumpPower }, Step = 5,
    Callback = function(v) ApplyJumpPower(v) end,
})

MovementTab:Section({ Title = "B-Hop" })
MovementTab:Toggle({
    Title = "B-Hop", Desc = "Speed builds on jumps, resets on wall", Icon = "wind",
    Value = false,
    Callback = function(v)
        State.BHop = v
        if v then StartBHop() else StopBHop() end
    end,
})
CreateBind(MovementTab, "B-Hop", "BHop", function()
    State.BHop = not State.BHop
    if State.BHop then StartBHop() else StopBHop() end
end)

MovementTab:Slider({
    Title = "B-Hop Max Speed", Desc = "Max B-Hop bonus speed", Icon = "gauge",
    Value = { Min = 0, Max = 50, Default = State.BHopMaxSpeed }, Step = 1,
    Callback = function(v) State.BHopMaxSpeed = v end,
})

-- ==================== SOUNDS ====================
SoundsTab:Section({ Title = "Shoot Sound" })
SoundsTab:Dropdown({
    Title = "Shoot Sound", Values = { "Custom 1", "Custom 2" }, Value = State.ShootSoundChoice,
    Callback = function(v) State.ShootSoundChoice = v end,
})
SoundsTab:Button({
    Title = "Test Shoot Sound", Desc = "Play selected shoot sound", Icon = "play",
    Callback = function() PlayShootSound() end,
})

SoundsTab:Section({ Title = "Hit Sound" })
SoundsTab:Dropdown({
    Title = "Hit Sound", Values = { "Custom 1", "Custom 2" }, Value = State.HitSoundChoice,
    Callback = function(v) State.HitSoundChoice = v end,
})
SoundsTab:Button({
    Title = "Test Hit Sound", Desc = "Play selected hit sound", Icon = "play",
    Callback = function() PlayHitSound() end,
})

-- ==================== PLAYERS ====================
PlayersTab:Section({ Title = "Live Roles" })

local LastHash = ""
local PlayerRowObjects = {}

local function SortPlayers()
    local list = {}
    for _, P in ipairs(Players:GetPlayers()) do
        if P ~= LocalPlayer then
            local R = RoleOf(P.Name)
            table.insert(list, { P = P, Role = R, Priority = ROLE_PRIORITY[R] or 99 })
        end
    end
    table.sort(list, function(a, b)
        if a.Priority ~= b.Priority then return a.Priority < b.Priority end
        return a.P.Name:lower() < b.P.Name:lower()
    end)
    return list
end

local function CreatePlayerRows(P, Role)
    local icon = (Role == "Murderer" and "skull")
        or (Role == "Sheriff" and "crosshair")
        or (Role == "Hero" and "shield")
        or (Role == "Innocent" and "user") or "user"
    local header = PlayersTab:Paragraph({
        Title = P.DisplayName .. "  [" .. Role .. "]",
        Desc = "@" .. P.Name, Icon = icon,
    })
    local tpBtn = PlayersTab:Button({
        Title = "Teleport → " .. P.DisplayName,
        Desc = "Go to @" .. P.Name, Icon = "map-pin",
        Callback = function() task.spawn(function() pcall(TeleportTo, P) end) end,
    })
    local flBtn = PlayersTab:Button({
        Title = "Fling → " .. P.DisplayName,
        Desc = "Fling @" .. P.Name, Icon = "zap",
        Callback = function() task.spawn(function() pcall(Fling, P) end) end,
    })
    return { Header = header, TP = tpBtn, FL = flBtn }
end

local function DestroyRow(row)
    if not row then return end
    pcall(function() if row.Header then row.Header:Destroy() end end)
    pcall(function() if row.TP then row.TP:Destroy() end end)
    pcall(function() if row.FL then row.FL:Destroy() end end)
end

local function RebuildPlayers()
    local list = SortPlayers()
    local hash = ""
    for _, i in ipairs(list) do hash = hash .. i.P.Name .. ":" .. i.Role .. "|" end
    if hash == LastHash then return end
    LastHash = hash
    for _, row in pairs(PlayerRowObjects) do DestroyRow(row) end
    PlayerRowObjects = {}
    for _, i in ipairs(list) do
        PlayerRowObjects[i.P] = CreatePlayerRows(i.P, i.Role)
    end
end

RebuildPlayers()
Players.PlayerAdded:Connect(function(P) if P ~= LocalPlayer then task.wait(1); RebuildPlayers() end end)
Players.PlayerRemoving:Connect(function(P)
    local row = PlayerRowObjects[P]
    if row then DestroyRow(row); PlayerRowObjects[P] = nil end
    task.wait(0.1); RebuildPlayers()
end)

-- ==================== LOOPS ====================
task.spawn(function()
    while task.wait(0.15) do
        if State.PlayerESP then
            for _, P in pairs(Players:GetPlayers()) do
                if P ~= LocalPlayer then pcall(RefreshESP, P) end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.25) do pcall(UpdateGunESP) end
end)

task.spawn(function()
    while task.wait(1) do pcall(UpdateRoles); pcall(RebuildPlayers) end
end)

pcall(function()
    WindUI:Notify({ Title = "AstraL", Content = "Loaded successfully", Icon = "check", Duration = 3 })
end)
