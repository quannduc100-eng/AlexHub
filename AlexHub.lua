--[[
    AlexHub v3.0
    Fix lag + tối ưu toàn diện + UI glassmorphism
    Chạy cục bộ, không loadstring ngoài.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 15)
if not playerGui then
    repeat task.wait(0.5) until player:FindFirstChild("PlayerGui")
    playerGui = player.PlayerGui
end

for _, name in ipairs({"AlexHub_UI", "AlexHub_Loading", "AlexHub_FPS"}) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ================== DATA ==================
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

local TOGGLES = {
    {id="shadow", name="Tắt Shadow", default=true, tip="Tắt bóng đổ toàn cục, giảm tải GPU"},
    {id="fog", name="Tắt Sương Mù", default=true, tip="Đẩy fog ra xa, giảm tính toán render"},
    {id="ambient", name="Tắt Ambient", default=true, tip="Tắt ánh sáng môi trường, giảm tải lighting"},
    {id="light", name="Tắt Đèn Phụ", default=true, tip="Tắt PointLight/SpotLight/SurfaceLight"},
    {id="particle", name="Tắt Particle", default=true, tip="Tắt hiệu ứng hạt, giảm tải CPU/GPU"},
    {id="beam", name="Tắt Beam/Trail", default=true, tip="Tắt hiệu ứng beam và trail"},
    {id="decal", name="Tắt Decal/Texture", default=false, tip="Tắt texture bề mặt, mất chi tiết nhưng mượt hơn"},
    {id="material", name="Đổi Vật Liệu", default=false, tip="Đổi tất cả vật liệu sang SmoothPlastic"},
    {id="nametag", name="Ẩn Name Tag", default=true, tip="Ẩn tên người chơi khác, giảm tải render"},
    {id="physics", name="Throttle Physics", default=false, tip="Giảm tần suất cập nhật physics"},
    {id="streaming", name="Giảm Streaming", default=false, tip="Giảm tầm nhìn streaming, tải ít hơn"},
    {id="animation", name="Tắt Animation", default=false, tip="Tắt animation nhân vật khác"},
}

local toggleStates = {}
local current = 30
local logLines = {}

-- ================== UTIL ==================
local function addLog(msg)
    table.insert(logLines, 1, os.date("%H:%M:%S") .. " — " .. msg)
    if #logLines > 30 then table.remove(logLines) end
end

local function safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        addLog("Lỗi: " .. tostring(err))
    end
    return ok
end

local function createRipple(parent, x, y)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.fromOffset(0, 0)
    ripple.Position = UDim2.fromOffset(x, y)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 10
    ripple.Parent = parent
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(1, 0)
    rc.Parent = ripple
    TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        Size = UDim2.fromOffset(200, 200),
        Position = UDim2.fromOffset(x - 100, y - 100),
        BackgroundTransparency = 1,
    }):Play()
    task.delay(0.5, function() ripple:Destroy() end)
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
lf.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
lf.BorderSizePixel = 0
lf.Parent = loadingGui

local lg = Instance.new("UIGradient")
lg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 8, 18)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 12, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 8, 18)),
})
lg.Rotation = 45
lg.Parent = lf

local lt = Instance.new("TextLabel")
lt.Size = UDim2.fromScale(1, 0.1)
lt.Position = UDim2.fromScale(0, 0.36)
lt.BackgroundTransparency = 1
lt.Text = "ALEX HUB"
lt.TextColor3 = Color3.fromRGB(120, 220, 255)
lt.Font = Enum.Font.GothamBold
lt.TextSize = 42
lt.Parent = lf

local lv = Instance.new("TextLabel")
lv.Size = UDim2.fromScale(1, 0.04)
lv.Position = UDim2.fromScale(0, 0.45)
lv.BackgroundTransparency = 1
lv.Text = "v3.0 — glassmorphism edition"
lv.TextColor3 = Color3.fromRGB(140, 140, 180)
lv.Font = Enum.Font.Gotham
lv.TextSize = 14
lv.Parent = lf

local sub = Instance.new("TextLabel")
sub.Size = UDim2.fromScale(1, 0.05)
sub.Position = UDim2.fromScale(0, 0.5)
sub.BackgroundTransparency = 1
sub.Text = "loading modules..."
sub.TextColor3 = Color3.fromRGB(120, 120, 160)
sub.Font = Enum.Font.Gotham
sub.TextSize = 13
sub.Parent = lf

local barBg = Instance.new("Frame")
barBg.Size = UDim2.fromScale(0.4, 0.014)
barBg.Position = UDim2.fromScale(0.3, 0.56)
barBg.BackgroundColor3 = Color3.fromRGB(24, 24, 40)
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

local barG = Instance.new("UIGradient")
barG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 120, 255)),
})
barG.Parent = bar

local pct = Instance.new("TextLabel")
pct.Size = UDim2.fromScale(1, 0.04)
pct.Position = UDim2.fromScale(0, 0.59)
pct.BackgroundTransparency = 1
pct.Text = "0%"
pct.TextColor3 = Color3.fromRGB(200, 200, 230)
pct.Font = Enum.Font.Gotham
pct.TextSize = 14
pct.Parent = lf

for i = 0, 30 do
    bar.Size = UDim2.fromScale(i/30, 1)
    pct.Text = math.floor(i/30 * 100) .. "%"
    task.wait(0.015)
end
task.wait(0.1)
loadingGui:Destroy()

-- ================== FPS COUNTER ==================
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "AlexHub_FPS"
fpsGui.ResetOnSpawn = false
fpsGui.IgnoreGuiInset = true
fpsGui.DisplayOrder = 100
fpsGui.Parent = playerGui

local fpsFrame = Instance.new("Frame")
fpsFrame.Size = UDim2.fromOffset(90, 28)
fpsFrame.Position = UDim2.new(0, 12, 0, 12)
fpsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
fpsFrame.BackgroundTransparency = 0.3
fpsFrame.BorderSizePixel = 0
fpsFrame.Parent = fpsGui

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0, 8)
fpsCorner.Parent = fpsFrame

local fpsStroke = Instance.new("UIStroke")
fpsStroke.Color = Color3.fromRGB(80, 200, 255)
fpsStroke.Thickness = 1
fpsStroke.Transparency = 0.5
fpsStroke.Parent = fpsFrame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.fromScale(1, 1)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(80, 200, 255)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 13
fpsLabel.Parent = fpsFrame

local fpsConn
task.spawn(function()
    local frames = 0
    local lastTime = tick()
    fpsConn = RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - lastTime >= 0.5 then
            local fps = math.floor(frames / (now - lastTime))
            fpsLabel.Text = "FPS: " .. fps
            if fps >= 50 then
                fpsLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
            elseif fps >= 30 then
                fpsLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
            else
                fpsLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
            end
            frames = 0
            lastTime = now
        end
    end)
end)

-- ================== MAIN UI ==================
local gui = Instance.new("ScreenGui")
gui.Name = "AlexHub_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 998
gui.Parent = playerGui

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(140, 40)
toggle.Position = UDim2.new(1, -160, 0, 70)
toggle.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
toggle.Text = "⚡ ALEX HUB"
toggle.TextColor3 = Color3.fromRGB(120, 220, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
toggle.Visible = false
toggle.Parent = gui

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 10)
tc.Parent = toggle

local tst = Instance.new("UIStroke")
tst.Color = Color3.fromRGB(80, 200, 255)
tst.Thickness = 1.5
tst.Transparency = 0.3
tst.Parent = toggle

local tg = Instance.new("UIGradient")
tg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 120, 255)),
})
tg.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.6),
    NumberSequenceKeypoint.new(1, 1),
})
tg.Parent = tst

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(500, 620)
main.Position = UDim2.new(0.5, -250, 0.5, -310)
main.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Parent = gui

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 18)
mc.Parent = main

local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(80, 100, 150)
ms.Thickness = 1
ms.Transparency = 0.4
ms.Parent = main

local mg = Instance.new("UIGradient")
mg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 38)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 18)),
})
mg.Rotation = 90
mg.Parent = main

-- Title bar
local tb = Instance.new("Frame")
tb.Size = UDim2.new(1, 0, 0, 52)
tb.BackgroundTransparency = 1
tb.Parent = main

local ttl = Instance.new("TextLabel")
ttl.Size = UDim2.new(1, -180, 1, 0)
ttl.Position = UDim2.fromOffset(20, 0)
ttl.BackgroundTransparency = 1
ttl.Text = "⚡ ALEX HUB"
ttl.TextColor3 = Color3.fromRGB(230, 240, 255)
ttl.Font = Enum.Font.GothamBold
ttl.TextSize = 20
ttl.TextXAlignment = Enum.TextXAlignment.Left
ttl.Parent = tb

local ver = Instance.new("TextLabel")
ver.Size = UDim2.fromOffset(60, 20)
ver.Position = UDim2.new(1, -180, 0, 16)
ver.BackgroundTransparency = 1
ver.Text = "v3.0"
ver.TextColor3 = Color3.fromRGB(140, 140, 190)
ver.Font = Enum.Font.Gotham
ver.TextSize = 12
ver.Parent = tb

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.new(1, -44, 0, 10)
close.BackgroundColor3 = Color3.fromRGB(40, 18, 24)
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(255, 130, 130)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.AutoButtonColor = false
close.Parent = tb

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 8)
cc.Parent = close

close.MouseEnter:Connect(function()
    TweenService:Create(close, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70, 25, 35)}):Play()
end)
close.MouseLeave:Connect(function()
    TweenService:Create(close, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 18, 24)}):Play()
end)

local min = Instance.new("TextButton")
min.Size = UDim2.fromOffset(32, 32)
min.Position = UDim2.new(1, -84, 0, 10)
min.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
min.Text = "—"
min.TextColor3 = Color3.fromRGB(180, 180, 210)
min.Font = Enum.Font.GothamBold
min.TextSize = 16
min.AutoButtonColor = false
min.Parent = tb

local mnc = Instance.new("UICorner")
mnc.CornerRadius = UDim.new(0, 8)
mnc.Parent = min

min.MouseEnter:Connect(function()
    TweenService:Create(min, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 52)}):Play()
end)
min.MouseLeave:Connect(function()
    TweenService:Create(min, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 34)}):Play()
end)

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -40, 0, 42)
tabBar.Position = UDim2.fromOffset(20, 58)
tabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local tbc = Instance.new("UICorner")
tbc.CornerRadius = UDim.new(0, 10)
tbc.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = tabBar

local tabIndicator = Instance.new("Frame")
tabIndicator.Size = UDim2.fromOffset(0, 34)
tabIndicator.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
tabIndicator.BackgroundTransparency = 0.85
tabIndicator.BorderSizePixel = 0
tabIndicator.ZIndex = 1
tabIndicator.Parent = tabBar

local tic = Instance.new("UICorner")
tic.CornerRadius = UDim.new(0, 8)
tic.Parent = tabIndicator

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -40, 1, -180)
content.Position = UDim2.fromOffset(20, 108)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}
local tabs = {
    {name="FIX LAG", id="fix"},
    {name="TỐI ƯU", id="opt"},
    {name="MÁY YẾU", id="weak"},
    {name="CÔNG CỤ", id="tool"},
}

local function switchTab(id)
    for _, p in pairs(pages) do p.Visible = false end
    if pages[id] then pages[id].Visible = true end
    for _, btn in pairs(tabBar:GetChildren()) do
        if btn:IsA("TextButton") then
            if btn.Name == "tab_" .. id then
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(80, 200, 255),
                    TextColor3 = Color3.fromRGB(10, 10, 20),
                }):Play()
                TweenService:Create(tabIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                    Position = UDim2.fromOffset(btn.Position.X.Offset, 4),
                    Size = UDim2.fromOffset(btn.Size.X.Offset, 34),
                }):Play()
            else
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(24, 24, 38),
                    TextColor3 = Color3.fromRGB(170, 180, 210),
                }):Play()
            end
        end
    end
end

for i, t in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = "tab_" .. t.id
    btn.Size = UDim2.fromOffset(100, 32)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 38)
    btn.Text = t.name
    btn.TextColor3 = Color3.fromRGB(170, 180, 210)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.ZIndex = 2
    btn.Parent = tabBar

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(t.id)
    end)
end

for _, t in ipairs(tabs) do
    local page = Instance.new("ScrollingFrame")
    page.Name = "page_" .. t.id
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(80, 200, 255)
    page.Visible = false
    page.Parent = content

    local pl = Instance.new("UIListLayout")
    pl.Padding = UDim.new(0, 8)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Parent = page

    local pp = Instance.new("UIPadding")
    pp.PaddingRight = UDim.new(0, 10)
    pp.PaddingBottom = UDim.new(0, 10)
    pp.Parent = page

    pages[t.id] = page
end

-- ================== TAB FIX LAG ==================
local fixPage = pages["fix"]

local levelLabel = Instance.new("TextLabel")
levelLabel.Size = UDim2.new(1, 0, 0, 20)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "CHỌN MỨC TỐI ƯU"
levelLabel.TextColor3 = Color3.fromRGB(140, 160, 200)
levelLabel.Font = Enum.Font.GothamBold
levelLabel.TextSize = 12
levelLabel.TextXAlignment = Enum.TextXAlignment.Left
levelLabel.LayoutOrder = 1
levelLabel.Parent = fixPage

local levelGrid = Instance.new("Frame")
levelGrid.Size = UDim2.new(1, 0, 0, 120)
levelGrid.BackgroundTransparency = 1
levelGrid.LayoutOrder = 2
levelGrid.Parent = fixPage

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.fromScale(0.185, 0.42)
grid.CellPadding = UDim2.fromScale(0.015, 0.08)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = levelGrid

local ib = Instance.new("Frame")
ib.Size = UDim2.new(1, 0, 0, 86)
ib.BackgroundColor3 = Color3.fromRGB(20, 22, 36)
ib.BackgroundTransparency = 0.3
ib.BorderSizePixel = 0
ib.LayoutOrder = 3
ib.Parent = fixPage

local ibc = Instance.new("UICorner")
ibc.CornerRadius = UDim.new(0, 10)
ibc.Parent = ib

local ibs = Instance.new("UIStroke")
ibs.Color = Color3.fromRGB(60, 80, 120)
ibs.Thickness = 1
ibs.Transparency = 0.4
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
id.Size = UDim2.new(1, -20, 0, 50)
id.Position = UDim2.fromOffset(10, 30)
id.BackgroundTransparency = 1
id.Text = ""
id.TextColor3 = Color3.fromRGB(160, 170, 200)
id.Font = Enum.Font.Gotham
id.TextSize = 12
id.TextWrapped = true
id.TextXAlignment = Enum.TextXAlignment.Left
id.TextYAlignment = Enum.TextYAlignment.Top
id.Parent = ib

local function updateInfoBox()
    local info = INFO[current]
    it.Text = "MỨC " .. current .. "% — " .. info.n
    id.Text = info.d
end

local btns = {}
local LVLS = {10,20,30,40,50,60,70,80,90,100}

for i, p in ipairs(LVLS) do
    local b = Instance.new("TextButton")
    b.LayoutOrder = i
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 36)
    b.Text = p .. "%"
    b.TextColor3 = Color3.fromRGB(170, 180, 210)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.AutoButtonColor = false
    b.Parent = levelGrid

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = b

    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(45, 55, 80)
    bs.Thickness = 1
    bs.Parent = b

    btns[p] = b

    b.MouseEnter:Connect(function()
        if current ~= p then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(34, 38, 56)}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if current ~= p then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 36)}):Play()
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
                    BackgroundColor3 = Color3.fromRGB(22, 22, 36),
                    TextColor3 = Color3.fromRGB(170, 180, 210),
                }):Play()
                if st then st.Color = Color3.fromRGB(45, 55, 80) end
            end
        end
        updateInfoBox()
        ab.Text = "ÁP DỤNG MỨC " .. p .. "%"
    end)
end

local ab = Instance.new("TextButton")
ab.Size = UDim2.new(1, 0, 0, 46)
ab.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
ab.Text = "ÁP DỤNG MỨC " .. current .. "%"
ab.TextColor3 = Color3.fromRGB(10, 10, 20)
ab.Font = Enum.Font.GothamBold
ab.TextSize = 15
ab.AutoButtonColor = false
ab.LayoutOrder = 4
ab.Parent = fixPage

local abc = Instance.new("UICorner")
abc.CornerRadius = UDim.new(0, 10)
abc.Parent = ab

local abg = Instance.new("UIGradient")
abg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 160, 255)),
})
abg.Rotation = 90
abg.Parent = ab

ab.MouseEnter:Connect(function()
    TweenService:Create(ab, TweenInfo.new(0.15), {Size = UDim2.new(1, 4, 0, 48)}):Play()
end)
ab.MouseLeave:Connect(function()
    TweenService:Create(ab, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 46)}):Play()
end)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Sẵn sàng."
statusLabel.TextColor3 = Color3.fromRGB(140, 150, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.LayoutOrder = 5
statusLabel.Parent = fixPage

-- ================== TAB TỐI ƯU ==================
local optPage = pages["opt"]

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 20)
header.BackgroundTransparency = 1
header.Text = "BẬT/TẮT TỪNG MODULE"
header.TextColor3 = Color3.fromRGB(140, 160, 200)
header.Font = Enum.Font.GothamBold
header.TextSize = 12
header.TextXAlignment = Enum.TextXAlignment.Left
header.LayoutOrder = 1
header.Parent = optPage

for i, t in ipairs(TOGGLES) do
    toggleStates[t.id] = t.default

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(20, 22, 36)
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    row.LayoutOrder = i + 1
    row.Parent = optPage

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 8)
    rc.Parent = row

    local rs = Instance.new("UIStroke")
    rs.Color = Color3.fromRGB(45, 60, 90)
    rs.Thickness = 1
    rs.Transparency = 0.4
    rs.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = t.name
    label.TextColor3 = Color3.fromRGB(200, 210, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local tip = Instance.new("TextLabel")
    tip.Size = UDim2.new(1, -30, 0, 0)
    tip.Position = UDim2.fromOffset(12, 26)
    tip.BackgroundTransparency = 1
    tip.Text = t.tip
    tip.TextColor3 = Color3.fromRGB(120, 130, 160)
    tip.Font = Enum.Font.Gotham
    tip.TextSize = 10
    tip.TextXAlignment = Enum.TextXAlignment.Left
    tip.Visible = false
    tip.Parent = row

    local sw = Instance.new("TextButton")
    sw.Size = UDim2.fromOffset(46, 26)
    sw.Position = UDim2.new(1, -58, 0.5, -13)
    sw.BackgroundColor3 = t.default and Color3.fromRGB(80, 200, 255) or Color3.fromRGB(40, 42, 60)
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.Parent = row

    local swc = Instance.new("UICorner")
    swc.CornerRadius = UDim.new(1, 0)
    swc.Parent = sw

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(20, 20)
    dot.Position = t.default and UDim2.new(1, -23, 0.5, -10) or UDim2.fromOffset(3, 3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = sw

    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot

    row.MouseEnter:Connect(function()
        tip.Visible = true
        TweenService:Create(row, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(30, 34, 52),
        }):Play()
    end)
    row.MouseLeave:Connect(function()
        tip.Visible = false
        TweenService:Create(row, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(20, 22, 36),
        }):Play()
    end)

    sw.MouseButton1Click:Connect(function()
        toggleStates[t.id] = not toggleStates[t.id]
        if toggleStates[t.id] then
            TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 200, 255)}):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, -10)}):Play()
        else
            TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 42, 60)}):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play()
        end
    end)
end

local applyOpt = Instance.new("TextButton")
applyOpt.Size = UDim2.new(1, 0, 0, 46)
applyOpt.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
applyOpt.Text = "ÁP DỤNG TỐI ƯU"
applyOpt.TextColor3 = Color3.fromRGB(10, 10, 20)
applyOpt.Font = Enum.Font.GothamBold
applyOpt.TextSize = 15
applyOpt.AutoButtonColor = false
applyOpt.LayoutOrder = 100
applyOpt.Parent = optPage

local aoc = Instance.new("UICorner")
aoc.CornerRadius = UDim.new(0, 10)
aoc.Parent = applyOpt

local aog = Instance.new("UIGradient")
aog.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 160, 255)),
})
aog.Rotation = 90
aog.Parent = applyOpt

-- ================== TAB MÁY YẾU ==================
local weakPage = pages["weak"]

local weakHeader = Instance.new("TextLabel")
weakHeader.Size = UDim2.new(1, 0, 0, 20)
weakHeader.BackgroundTransparency = 1
weakHeader.Text = "PRESET 1-CLICK CHO MÁY YẾU"
weakHeader.TextColor3 = Color3.fromRGB(140, 160, 200)
weakHeader.Font = Enum.Font.GothamBold
weakHeader.TextSize = 12
weakHeader.TextXAlignment = Enum.TextXAlignment.Left
weakHeader.LayoutOrder = 1
weakHeader.Parent = weakPage

local PRESETS = {
    {id="low", name="LOW", desc="Máy yếu vừa. Giữ hình ảnh, giảm hiệu ứng.", color=Color3.fromRGB(80, 200, 255), level=30},
    {id="medium", name="MEDIUM", desc="Máy yếu. Đơn giản hóa vật liệu.", color=Color3.fromRGB(255, 200, 80), level=50},
    {id="high", name="HIGH", desc="Máy rất yếu. Giảm chi tiết mạnh.", color=Color3.fromRGB(255, 140, 80), level=70},
    {id="ultra", name="ULTRA LOW", desc="Máy cực yếu. Tối giản hoàn toàn.", color=Color3.fromRGB(255, 90, 90), level=100},
}

for i, p in ipairs(PRESETS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 56)
    btn.BackgroundColor3 = Color3.fromRGB(20, 22, 36)
    btn.BackgroundTransparency = 0.2
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = i + 1
    btn.Parent = weakPage

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 10)
    bc.Parent = btn

    local bs = Instance.new("UIStroke")
    bs.Color = p.color
    bs.Thickness = 1
    bs.Transparency = 0.5
    bs.Parent = btn

    local accent = Instance.new("Frame")
    accent.Size = UDim2.fromOffset(4, 40)
    accent.Position = UDim2.fromOffset(12, 8)
    accent.BackgroundColor3 = p.color
    accent.BorderSizePixel = 0
    accent.Parent = btn

    local ac = Instance.new("UICorner")
    ac.CornerRadius = UDim.new(1, 0)
    ac.Parent = accent

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -40, 0, 22)
    name.Position = UDim2.fromOffset(24, 8)
    name.BackgroundTransparency = 1
    name.Text = p.name
    name.TextColor3 = p.color
    name.Font = Enum.Font.GothamBold
    name.TextSize = 15
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = btn

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 18)
    desc.Position = UDim2.fromOffset(24, 30)
    desc.BackgroundTransparency = 1
    desc.Text = p.desc
    desc.TextColor3 = Color3.fromRGB(150, 160, 190)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 11
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(30, 34, 52),
        }):Play()
        TweenService:Create(bs, TweenInfo.new(0.15), {Transparency = 0.1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(20, 22, 36),
        }):Play()
        TweenService:Create(bs, TweenInfo.new(0.15), {Transparency = 0.5}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        current = p.level
        for pp, bb in pairs(btns) do
            local st = bb:FindFirstChildOfClass("UIStroke")
            if pp == p.level then
                TweenService:Create(bb, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(80, 200, 255),
                    TextColor3 = Color3.fromRGB(10, 10, 20),
                }):Play()
                if st then st.Color = Color3.fromRGB(80, 200, 255) end
            else
                TweenService:Create(bb, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(22, 22, 36),
                    TextColor3 = Color3.fromRGB(170, 180, 210),
                }):Play()
                if st then st.Color = Color3.fromRGB(45, 55, 80) end
            end
        end
        updateInfoBox()
        ab.Text = "ÁP DỤNG MỨC " .. p.level .. "%"
        statusLabel.Text = "Đã chọn preset " .. p.name .. " (" .. p.level .. "%)"
        statusLabel.TextColor3 = p.color
        addLog("Preset " .. p.name .. " → mức " .. p.level .. "%")
    end)
end

-- ================== TAB CÔNG CỤ ==================
local toolPage = pages["tool"]

local toolHeader = Instance.new("TextLabel")
toolHeader.Size = UDim2.new(1, 0, 0, 20)
toolHeader.BackgroundTransparency = 1
toolHeader.Text = "CÔNG CỤ BỔ SUNG"
toolHeader.TextColor3 = Color3.fromRGB(140, 160, 200)
toolHeader.Font = Enum.Font.GothamBold
toolHeader.TextSize = 12
toolHeader.TextXAlignment = Enum.TextXAlignment.Left
toolHeader.LayoutOrder = 1
toolHeader.Parent = toolPage

local function makeToolButton(text, order, callback, color)
    color = color or Color3.fromRGB(80, 200, 255)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 44)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 36)
    b.BackgroundTransparency = 0.2
    b.Text = text
    b.TextColor3 = Color3.fromRGB(200, 210, 240)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.AutoButtonColor = false
    b.LayoutOrder = order
    b.Parent = toolPage

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 10)
    bc.Parent = b

    local bs = Instance.new("UIStroke")
    bs.Color = color
    bs.Thickness = 1
    bs.Transparency = 0.6
    bs.Parent = b

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 36, 54)}):Play()
        TweenService:Create(bs, TweenInfo.new(0.15), {Transparency = 0.2}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 36)}):Play()
        TweenService:Create(bs, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
    end)
    b.MouseButton1Click:Connect(callback)
    return b
end

makeToolButton("🚀 Unlock FPS", 2, function()
    safe(function() setfpscap(9999) end)
    statusLabel.Text = "✓ Đã unlock FPS"
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
    addLog("Unlock FPS")
end)

makeToolButton("🔇 Tắt Ambient Sound", 3, function()
    safe(function()
        for _, s in ipairs(SoundService:GetDescendants()) do
            if s:IsA("Sound") and s.Looped then s.Volume = 0 end
        end
    end)
    statusLabel.Text = "✓ Đã tắt ambient"
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
    addLog("Tắt ambient sound")
end)

makeToolButton("🌫 Xóa Hiệu Ứng Môi Trường", 4, function()
    safe(function()
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect")
            or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
    end)
    statusLabel.Text = "✓ Đã xóa hiệu ứng môi trường"
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
    addLog("Xóa hiệu ứng môi trường")
end)

makeToolButton("🧹 Clear Cache UI", 5, function()
    safe(function()
        for _, v in ipairs(playerGui:GetChildren()) do
            if v ~= gui and v ~= fpsGui and v:IsA("ScreenGui") and v.Name ~= "AlexHub_UI" then
                v:Destroy()
            end
        end
    end)
    statusLabel.Text = "✓ Đã clear cache UI"
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
    addLog("Clear cache UI")
end)

makeToolButton("♻ Reset Tất Cả Fix Lag", 6, function()
    safe(function()
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
    end)
    statusLabel.Text = "✓ Đã reset fix lag"
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
    addLog("Reset fix lag")
end)

makeToolButton("⚠ PANIC — Khôi phục mọi thứ", 7, function()
    safe(function()
        for _, t in ipairs(TOGGLES) do toggleStates[t.id] = false end
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect")
            or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = true
            end
        end
    end)
    statusLabel.Text = "⚠ Đã khôi phục mọi thứ về mặc định"
    statusLabel.TextColor3 = Color3.fromRGB(255, 180, 80)
    addLog("PANIC — khôi phục mặc định")
end, Color3.fromRGB(255, 120, 120))

local logHeader = Instance.new("TextLabel")
logHeader.Size = UDim2.new(1, 0, 0, 20)
logHeader.BackgroundTransparency = 1
logHeader.Text = "LOG"
logHeader.TextColor3 = Color3.fromRGB(140, 160, 200)
logHeader.Font = Enum.Font.GothamBold
logHeader.TextSize = 12
logHeader.TextXAlignment = Enum.TextXAlignment.Left
logHeader.LayoutOrder = 50
logHeader.Parent = toolPage

local logBox = Instance.new("Frame")
logBox.Size = UDim2.new(1, 0, 0, 150)
logBox.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
logBox.BackgroundTransparency = 0.3
logBox.BorderSizePixel = 0
logBox.LayoutOrder = 51
logBox.Parent = toolPage

local lbc = Instance.new("UICorner")
lbc.CornerRadius = UDim.new(0, 8)
lbc.Parent = logBox

local lbl = Instance.new("UIStroke")
lbl.Color = Color3.fromRGB(40, 50, 80)
lbl.Thickness = 1
lbl.Transparency = 0.5
lbl.Parent = logBox

local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, -16, 1, -16)
logText.Position = UDim2.fromOffset(8, 8)
logText.BackgroundTransparency = 1
logText.Text = "Chưa có hoạt động."
logText.TextColor3 = Color3.fromRGB(150, 160, 190)
logText.Font = Enum.Font.Code
logText.TextSize = 10
logText.TextWrapped = true
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.Parent = logBox

local function refreshLog()
    if #logLines == 0 then
        logText.Text = "Chưa có hoạt động."
    else
        logText.Text = table.concat(logLines, "\n")
    end
end

local origAddLog = addLog
addLog = function(msg)
    origAddLog(msg)
    if logText then refreshLog() end
end

-- ================== LOGIC ==================
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

local function applyToggles()
    if toggleStates.shadow then Lighting.GlobalShadows = false end
    if toggleStates.fog then Lighting.FogEnd = 9e9; Lighting.FogStart = 9e9 end
    if toggleStates.ambient then
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if toggleStates.light and (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) then
            obj.Enabled = false
        end
        if toggleStates.particle and obj:IsA("ParticleEmitter") then obj.Enabled = false end
        if toggleStates.beam and (obj:IsA("Beam") or obj:IsA("Trail")) then obj.Enabled = false end
        if toggleStates.decal and (obj:IsA("Decal") or obj:IsA("Texture")) then obj.Transparency = 1 end
        if toggleStates.material and obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic end
        if toggleStates.animation and obj:IsA("Animator") then
            for _, track in ipairs(obj:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
    if toggleStates.nametag then
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
    if toggleStates.physics then
        pcall(function()
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
        end)
    end
    if toggleStates.streaming then
        pcall(function()
            Workspace.StreamingTargetRadius = 512
        end)
    end
end

ab.MouseButton1Click:Connect(function()
    ab.Text = "ÁP DỤNG MỨC " .. current .. "%"
    statusLabel.Text = "Đang áp dụng mức " .. current .. "%..."
    statusLabel.TextColor3 = Color3.fromRGB(80, 200, 255)
    task.wait(0.05)
    local ok = safe(applyFix, current)
    if ok then
        statusLabel.Text = "✓ Đã áp dụng mức " .. current .. "%"
        statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
        addLog("Áp dụng mức " .. current .. "%")
    else
        statusLabel.Text = "Lỗi — xem log"
        statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
end)

applyOpt.MouseButton1Click:Connect(function()
    statusLabel.Text = "Đang áp dụng tối ưu..."
    statusLabel.TextColor3 = Color3.fromRGB(80, 200, 255)
    task.wait(0.05)
    local ok = safe(applyToggles)
    if ok then
        statusLabel.Text = "✓ Đã áp dụng tối ưu"
        statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
        addLog("Áp dụng toggle tối ưu")
    else
        statusLabel.Text = "Lỗi — xem log"
        statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
end)

-- ================== KÉO THẢ / ĐÓNG MỞ ==================
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
    if fpsConn then fpsConn:Disconnect() end
    fpsGui:Destroy()
end)

-- Keybind RightShift
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if main and main.Parent then
            main.Visible = not main.Visible
            toggle.Visible = not main.Visible
        end
    end
end)

-- Khởi động
switchTab("fix")
main.Size = UDim2.fromOffset(0, 0)
TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(500, 620)
}):Play()

addLog("AlexHub v3.0 khởi động")
print("[AlexHub v3.0] loaded.")
