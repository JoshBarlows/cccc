wait(1)
local args = {"Tablet"}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("ChangeLastDevice"):FireServer(unpack(args))
wait(2)

local p = game.Players.LocalPlayer
local c = p.Character or p.CharacterAdded:Wait()
local hrp = c:WaitForChild("HumanoidRootPart")
local ts = game:GetService("TweenService")
local replicated = game:GetService("ReplicatedStorage")
local collected = 0
local max = _G.Config.CollectHop
local gui

task.spawn(function()
    while task.wait() do
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end)

local function HideChar(state)
    for _,v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.Transparency = state and 1 or 0
        end
    end
end

HideChar(true)

local noclip = true
game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        local char = p.Character
        if char then
            for _,v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end
end)

local RS = game:GetService("ReplicatedStorage")
local lp = game.Players.LocalPlayer

local function GetMyHalloweenPoints()
    local args = {"Friends", "Halloween2025Points"}
    local lb = RS.Remotes.Events.Generic.GetLeaderboard:InvokeServer(unpack(args))
    local myId = lp.UserId
    local myPoints = 0

    if typeof(lb) ~= "table" then  
        return 0  
    end  

    if lb[myId] or lb[tostring(myId)] then  
        myPoints = lb[myId] or lb[tostring(myId)]  
        return tonumber(myPoints) or 0  
    end  

    for _, v in pairs(lb) do  
        if typeof(v) == "table" then  
            local uid = v.UserId or v.userId or v.PlayerId or v.playerId or v.Id or v.id  
            if uid and (uid == myId or tostring(uid) == tostring(myId)) then  
                local val = v.Points or v.points or v.Value or v.value or v.Score or v.score or v.Amount or v.amount or v.Candies or v.candies  
                return tonumber(val) or 0  
            end  
        end  
    end  

    return 0
end

local function BackpackCandy()
    local inv = p:FindFirstChild("Inventory")
    if not inv then return 0 end
    local candy = inv:FindFirstChild("Candy")
    if not candy then return 0 end
    return candy.Value
end

local function ResetChar()
    p.Character:BreakJoints()
end

if _G.Config.BlackScreen then
    gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Name = "TDT_UI"
    gui.Parent = game.CoreGui

    -- CARD CHÍNH
    local card = Instance.new("Frame")
    card.Parent = gui
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.new(0.5, 0, 0.25, 0)
    card.Size = UDim2.new(0, 520, 0, 260)
    card.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    card.BackgroundTransparency = 0.15

    -- BO GÓC
    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 18)

    -- VIỀN
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.8

    -- PADDING
    local padding = Instance.new("UIPadding", card)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)

    -- TITLE
    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "TDT HUB"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamSemibold
    title.TextScaled = true

    -- PLAYER NAME
    local name = Instance.new("TextLabel", card)
    name.Size = UDim2.new(1, 0, 0, 55)
    name.Position = UDim2.new(0, 0, 0, 45)
    name.BackgroundTransparency = 1
    name.Text = p.Name
    name.TextColor3 = Color3.new(1,1,1)
    name.Font = Enum.Font.GothamBlack
    name.TextScaled = true

    -- STATUS
    local status = Instance.new("TextLabel", card)
    status.Name = "Status"
    status.Size = UDim2.new(1, 0, 0, 40)
    status.Position = UDim2.new(0, 0, 0, 110)
    status.BackgroundTransparency = 1
    status.Text = "Collect: +0"
    status.TextColor3 = Color3.new(1,1,1)
    status.Font = Enum.Font.GothamSemibold
    status.TextScaled = true

    -- TOTAL CANDY
    local total = Instance.new("TextLabel", card)
    total.Name = "TotalCandy"
    total.Size = UDim2.new(1, 0, 0, 40)
    total.Position = UDim2.new(0, 0, 0, 155)
    total.BackgroundTransparency = 1
    total.Text = "Total Candy: 0"
    total.TextColor3 = Color3.new(1,1,1)
    total.Font = Enum.Font.GothamSemibold
    total.TextScaled = true
end


local currentTotal = 0

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            currentTotal = GetMyHalloweenPoints()
            if gui then
                gui.Frame.TotalCandy.Text = "Total Candy: "..currentTotal
            end
        end)
    end
end)

local function update(state)
    if not gui then return end
    if state=="waiting" then
        gui.Frame.Status.Text = "Waiting..."
        return
    end
    gui.Frame.TotalCandy.Text = "Total Candy: "..currentTotal
    gui.Frame.Status.Text = "Collect: +"..collected
end

local function HopOrReset()
    collected = 0
    if not _G.Config.Hop then
        if gui then gui.Frame.Status.Text="Reset..." end
        task.wait(0.5)
        ResetChar()
        return
    end
    if gui then gui.Frame.Status.Text="Hopping..." end
    task.wait(1)
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end

local function TweenToCandy(candy)
    if not candy or not candy.Parent then return end

    local pos = candy.Position
    local underY = pos.Y - 8
    if underY < -4 then underY = -4 end
    hrp.CFrame = CFrame.new(pos.X,underY,pos.Z)

    if not candy.Parent then return end

    local targetPos = pos + Vector3.new(0,3,0)
    local dist = (hrp.Position - targetPos).Magnitude
    local t = math.max(dist/60,0.2)

    local tw = ts:Create(hrp,TweenInfo.new(t,Enum.EasingStyle.Linear),{CFrame=CFrame.new(targetPos)})
    tw:Play()
    tw.Completed:Wait()

    if not candy.Parent then return end

    for i=1,2 do
        firetouchinterest(hrp,candy,0)
        task.wait(0.05)
        firetouchinterest(hrp,candy,1)
        task.wait(0.05)
        if not candy.Parent then break end
    end

    if not candy.Parent then return end

    collected = collected + 1
    SendWebhook(
    "Candy Collect",
    "User: **"..p.Name.."**\n+1 Candy Collected\nThis Hop: **"..collected.."** / "..max.."\nTotal Candy: **"..currentTotal.."**"
)
    update()

    if collected >= max then
        HopOrReset()
        return
    end

    local backPos = Vector3.new(pos.X,underY,pos.Z)
    local tw2 = ts:Create(hrp,TweenInfo.new(0.9,Enum.EasingStyle.Linear),{CFrame=CFrame.new(backPos)})
    tw2:Play()
    tw2.Completed:Wait()
end

local function getCandies()
    local t = {}
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name=="Candy" or v.Name=="Candy_Server" or v.Name=="Coin_Server") then
            table.insert(t,v)
        end
    end
    table.sort(t,function(a,b)
        return (hrp.Position - a.Position).Magnitude < (hrp.Position - b.Position).Magnitude
    end)
    return t
end

local function inLobby()
    local lb = workspace:FindFirstChild("Lobby")
    if not lb then return false end
    return (hrp.Position - lb:GetModelCFrame().Position).Magnitude < 100
end

local function WaitCharacter()
    p = game.Players.LocalPlayer
    c = p.Character or p.CharacterAdded:Wait()
    hrp = nil
    repeat task.wait()
        pcall(function()
            hrp = c:FindFirstChild("HumanoidRootPart")
        end)
    until hrp
    HideChar(true)
end

p.CharacterAdded:Connect(function()
    task.wait(0.5)
    WaitCharacter()
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        pcall(function()

            if not p.Character or not hrp then
                WaitCharacter()
            end

            if BackpackCandy() >= max then
                HopOrReset()
                return
            end

            OpenCrate()

            if inLobby() then
                update("waiting")
                repeat task.wait(1.5) until not inLobby()
            end

            local candies = getCandies()
            if #candies==0 then return end

            for _,candy in ipairs(candies) do
                if candy and candy.Parent then
                    TweenToCandy(candy)
                    task.wait(0.85)
                end
            end

        end)
    end
end)
