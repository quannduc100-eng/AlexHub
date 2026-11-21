--[[
    AlexHub.lua
    Host trên raw.githubusercontent.com — gọi từ Delta X bằng loadstring.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("AlexHub_UI") then
    playerGui.AlexHub_UI:Destroy()
end
if playerGui:FindFirstChild("AlexHub_Loading") then
    playerGui.AlexHub_Loading:Destroy()
end

-- ================== LOADING ==================
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "AlexHub_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.IgnoreGuiInset = true
loadingGui.DisplayOrder = 999
loadingGui.Parent = playerGui

local lf = Instance.new("Frame")
lf.Size = UDim2.fromScale(1, 1)
lf.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
lf.BorderSizePixel = 0
lf.Parent = loadingGui

local lt = Instance.new("TextLabel")
lt.Size = UDim2.fromScale(1, 0.08)
lt.Position = UDim2.fromScale(0, 0.4)
lt.BackgroundTransparency = 1
lt.Text = "ALEX HUB"
lt.TextColor3 = Color3.fromRGB(80, 200, 255)
lt.Font = Enum.Font.GothamBold
lt.TextSize = 34
lt.Parent = lf

local sub = Instance.new("TextLabel")
sub.Size = UDim2.fromScale(1, 0.05)
sub.Position = UDim2.fromScale(0, 0.47)
sub.BackgroundTransparency = 1
sub.Text = "loading modules..."
sub.TextColor3 = Color3.fromRGB(120, 120, 150)
sub.Font = Enum.Font.Gotham
sub.TextSize = 13
sub.Parent = lf

local barBg = Instance.new("Frame")
barBg.Size = UDim2.fromScale(0.4, 0.012)
barBg.Position = UDim2.fromScale(0.3, 0.54)
barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
barBg.BorderSizePixel = 0
barBg.Parent = lf

local barBgC = Instance.new("UICorner")
barBgC.CornerRadius = UDim.new(1, 0)
barBgC.Parent = barBg

local bar = Instance.new("Frame")
bar.Size = UDim2.fromScale(0, 1)
bar.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
bar.BorderSizePixel = 0
bar.Parent = barBg

local barC = Instance.new("UICorner")
barC.CornerRadius = UDim.new(1, 0)
barC.Parent = bar

local pct = Instance.new("TextLabel")
pct.Size = UDim2.fromScale(1, 0.04)
pct.Position = UDim2.fromScale(0, 0.57)
pct.BackgroundTransparency = 1
pct.Text = "0%"
pct.TextColor3 = Color3.fromRGB(180, 180, 210)
pct.Font = Enum.Font.Gotham
pct.TextSize = 14
pct.Parent = lf

task.spawn(function()
    for i = 0, 100 do
        bar:TweenSize(UDim2.fromScale(i/100, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.05, true)
        pct.Text = i .. "%"
        task.wait(0.012)
    end
    task.wait(0.2)
    for _, el in ipairs({lf, lt, sub, barBg, bar, pct}) do
        TweenService:Create(el, TweenInfo.new(0.4), {
            BackgroundTransparency = 1, TextTransparency = 1
        }):Play()
    end
    task.wait(0.5)
    loadingGui:Destroy()
end)

-- ================== MAIN UI ==================
local gui = Instance.new("ScreenGui")
gui.Name = "AlexHub_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 998
gui.Parent = playerGui

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(120, 36)
toggle.Position = UDim2.new(1, -140, 0, 70)
toggle.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
toggle.Text = "⚡ ALEX HUB"
toggle.TextColor3 = Color3.fromRGB(80, 200, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
toggle.Visible = false
toggle.Parent = gui

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 8)
tc.Parent = toggle

local ts = Instance.new("UIStroke")
ts.Color = Color3.fromRGB(80, 200, 255)
ts.Thickness = 1.5
ts.Transparency = 0.5
ts.Parent = toggle

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(440, 540)
main.Position = UDim2.new(0.5, -220, 0.5, -270)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
main.BorderSizePixel = 0
main.Parent = gui

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 14)
mc.Parent = main

local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(55, 75, 110)
ms.Thickness = 1
ms.Parent = main

local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 16, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 14)),
})
grad.Rotation = 90
grad.Parent = main

local tb = Instance.new("Frame")
tb.Size = UDim2.new(1, 0, 0, 48)
tb.BackgroundTransparency = 1
tb.Parent = main

local ttl = Instance.new("TextLabel")
ttl.Size = UDim2.new(1, -90, 1, 0)
ttl.Position = UDim2.fromOffset(18, 0)
ttl.BackgroundTransparency = 1
ttl.Text = "⚡ ALEX HUB"
ttl.TextColor3 = Color3.fromRGB(220, 235, 255)
ttl.Font = Enum.Font.GothamBold
ttl.TextSize = 18
ttl.TextXAlignment = Enum.TextXAlignment.Left
ttl.Parent = tb

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -38, 0, 10)
close.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(255, 120, 120)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = tb

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 6)
cc.Parent = close

local min = Instance.new("TextButton")
min.Size = UDim2.fromOffset(28, 28)
min.Position = UDim2.new(1, -72, 0, 10)
min.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
min.Text = "—"
min.TextColor3 = Color3.fromRGB(180, 180, 200)
min.Font = Enum.Font.GothamBold
min.TextSize = 14
min.Parent = tb

local mnc = Instance.new("UICorner")
mnc.CornerRadius = UDim.new(0, 6)
mnc.Parent = min

local div = Instance.new("Frame")
div.Size = UDim2.new(1, -36, 0, 1)
div.Position = UDim2.fromOffset(18, 48)
div.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
div.BorderSizePixel = 0
div.Parent = main

local sl = Instance.new("TextLabel")
sl.Size = UDim2.new(1, -36, 0, 24)
sl.Position = UDim2.fromOffset(18, 62)
sl.BackgroundTransparency = 1
sl.Text = "CHỌN MỨC TỐI ƯU"
sl.TextColor3 = Color3.fromRGB(140, 160, 190)
sl.Font = Enum.Font.GothamBold
sl.TextSize = 12
sl.TextXAlignment = Enum.TextXAlignment.Left
sl.Parent = main

local current = 30

local lc = Instance.new("Frame")
lc.Size = UDim2.new(1, -36, 0, 130)
lc.Position = UDim2.fromOffset(18, 92)
lc.BackgroundTransparency = 1
lc.Parent = main

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.fromScale(0.18, 0.42)
grid.CellPadding = UDim2.fromScale(0.02, 0.08)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = lc

local btns = {}
local LVLS = {10,20,30,40,50,60,70,80,90,100}

for i, p in ipairs(LVLS) do
    local b = Instance.new("TextButton")
    b.LayoutOrder = i
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    b.Text = p .. "%"
    b.TextColor3 = Color3.fromRGB(170, 180, 210)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.AutoButtonColor = false
    b.Parent = lc

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = b

    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(45, 55, 75)
    bs.Thickness = 1
    bs.Parent = b

    btns[p] = b

    b.MouseEnter:Connect(function()
        if current ~= p then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 36, 50)}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if current ~= p then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 32)}):Play()
        end
    end)

    b.MouseButton1Click:Connect(function()
        current = p
        for pp, bb in pairs(btns) do
            local st = bb:FindFirstChildOfClass("UIStroke")
            if pp == p then
                TweenService:Create(bb, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(80, 200, 255),
                    TextColor3 = Color3.fromRGB(10, 10, 20),
                }):Play()
                if st then st.Color = Color3.fromRGB(80, 200, 255) end
            else
                TweenService:Create(bb, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(22, 22, 32),
                    TextColor3 = Color3.fromRGB(170, 180, 210),
                }):Play()
                if st then st.Color = Color3.fromRGB(45, 55, 75) end
            end
        end
        updateInfo()
    end)
end

local ib = Instance.new("Frame")
ib.Size = UDim2.new(1, -36, 0, 82)
ib.Position = UDim2.fromOffset(18, 234)
ib.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
ib.BorderSizePixel = 0
ib.Parent = main

local ibc = Instance.new("UICorner")
ibc.CornerRadius = UDim.new(0, 10)
ibc.Parent = ib

local ibs = Instance.new("UIStroke")
ibs.Color = Color3.fromRGB(45, 60, 85)
ibs.Thickness = 1
ibs.Parent = ib

local it = Instance.new("TextLabel")
it.Size = UDim2.new(1, -20, 0, 22)
it.Position = UDim2.fromOffset(10, 8)
it.BackgroundTransparency = 1
it.Text = "MỨC 30% — NHẸ+"
it.TextColor3 = Color3.fromRGB(80, 200, 255)
it.Font = Enum.Font.GothamBold
it.TextSize = 13
it.TextXAlignment = Enum.TextXAlignment.Left
it.Parent = ib

local id = Instance.new("TextLabel")
id.Size = UDim2.new(1, -20, 0, 46)
id.Position = UDim2.fromOffset(10, 30)
id.BackgroundTransparency = 1
id.Text = ""
id.TextColor3 = Color3.fromRGB(155, 165, 190)
id.Font = Enum.Font.Gotham
id.TextSize = 12
id.TextWrapped = true
id.TextXAlignment = Enum.TextXAlignment.Left
id.TextYAlignment = Enum.TextYAlignment.Top
id.Parent = ib

local INFO = {
    [10]  = {n="RẤT NHẸ", d="Tắt shadow + fog. Không đổi hình ảnh."},
    [20]  = {n="NHẸ", d="Thêm tắt đèn phụ, ambient. Hình ảnh gần như giữ nguyên."},
    [30]  = {n="NHẸ+", d="Tắt particle nhỏ. Mượt hơn, không mất chi tiết chính."},
    [40]  = {n="TRUNG BÌNH", d="Tắt beam/trail. Hợp game nhiều hiệu ứng kỹ năng."},
    [50]  = {n="TRUNG BÌNH+", d="Đổi vật liệu SmoothPlastic. Hình ảnh đơn giản hơn."},
    [60]  = {n="CAO", d="Tắt decal/texture. Giảm tải render đáng kể."},
    [70]  = {n="CAO+", d="Throttle physics. Có thể lệch đồng bộ nhẹ."},
    [80]  = {n="RẤT CAO", d="Ẩn name tag người chơi khác. Hợp server đông."},
    [90]  = {n="CỰC CAO", d="Tắt query + giảm streaming radius. Hình ảnh thay đổi rõ."},
    [100] = {n="TỐI ĐA", d="Tất cả. Hình ảnh tối giản, FPS tối đa."},
}

function updateInfo()
    local i = INFO[current]
    it.Text = "MỨC " .. current .. "% — " .. i.n
    id.Text = i.d
end
updateInfo()

local ab = Instance.new("TextButton")
ab.Size = UDim2.new(1, -36, 0, 44)
ab.Position = UDim2.new(0, 18, 1, -110)
ab.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
ab.Text = "ÁP DỤNG"
ab.TextColor3 = Color3.fromRGB(10, 10, 20)
ab.Font = Enum.Font.GothamBold
ab.TextSize = 15
ab.AutoButtonColor = false
ab.Parent = main

local abc = Instance.new("UICorner")
abc.CornerRadius = UDim.new(0, 10)
abc.Parent = ab

local abg = Instance.new("UIGradient")
abg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 170, 240)),
})
abg.Rotation = 90
abg.Parent = ab

ab.MouseEnter:Connect(function()
    TweenService:Create(ab, TweenInfo.new(0.15), {Size = UDim2.new(1, -32, 0, 46)}):Play()
end)
ab.MouseLeave:Connect(function()
    TweenService:Create(ab, TweenInfo.new(0.15), {Size = UDim2.new(1, -36, 0, 44)}):Play()
end)

local st = Instance.new("TextLabel")
st.Size = UDim2.new(1, -36, 0, 20)
st.Position = UDim2.new(0, 18, 1, -56)
st.BackgroundTransparency = 1
st.Text = "Sẵn sàng."
st.TextColor3 = Color3.fromRGB(140, 150, 175)
st.Font = Enum.Font.Gotham
st.TextSize = 12
st.Parent = main

local function processPart(part, level)
    if not part:IsA("BasePart") then return end
    if level >= 50 then part.Material = Enum.Material.SmoothPlastic end
    if level >= 90 then part.CanQuery = false end
end

local function processEffect(obj, level)
    if level >= 30 and obj:IsA("ParticleEmitter") then obj.Enabled = false end
    if level >= 40 and (obj:IsA("Beam") or obj:IsA("Trail")) then obj.Enabled = false end
    if level >= 20 and (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) then
        obj.Enabled = false
    end
    if level >= 60 and (obj:IsA("Decal") or obj:IsA("Texture")) then
        obj.Transparency = 1
    end
end

local function applyFix(level)
    if level >= 10 then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
    end
    if level >= 20 then
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        processPart(obj, level)
        processEffect(obj, level)
    end

    Workspace.DescendantAdded:Connect(function(obj)
        processPart(obj, level)
        processEffect(obj, level)
    end)

    if level >= 80 then
        local function hide()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local h = p.Character:FindFirstChild("Head")
                    if h then
                        local g = h:FindFirstChildOfClass("BillboardGui")
                        if g then g.Enabled = false end
                    end
                end
            end
        end
        hide()
        Players.PlayerAdded:Connect(function()
            task.wait(1)
            hide()
        end)
    end

    if level >= 70 then
        pcall(function()
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
        end)
    end

    if level >= 90 then
        pcall(function()
            Workspace.StreamingTargetRadius = 512
        end)
    end
end

ab.MouseButton1Click:Connect(function()
    st.Text = "Đang áp dụng mức " .. current .. "%..."
    st.TextColor3 = Color3.fromRGB(80, 200, 255)
    task.wait(0.1)
    local ok, err = pcall(applyFix, current)
    if ok then
        st.Text = "✓ Đã áp dụng mức " .. current .. "%"
        st.TextColor3 = Color3.fromRGB(120, 255, 160)
    else
        st.Text = "Lỗi: " .. tostring(err)
        st.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
end)

local dragging, dragInput, dragStart, startPos
tb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
tb.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

min.MouseButton1Click:Connect(function()
    main.Visible = false
    toggle.Visible = true
end)
toggle.MouseButton1Click:Connect(function()
    main.Visible = true
    toggle.Visible = false
end)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

main.Size = UDim2.fromOffset(0, 0)
TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(440, 540)
}):Play()

print("[AlexHub] loaded.")
