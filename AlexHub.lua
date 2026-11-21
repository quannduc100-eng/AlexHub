--[[
    AlexHub v2.0
    Fix lag + tối ưu toàn diện cho Roblox
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

-- Dọn UI cũ
for _, name in ipairs({"AlexHub_UI", "AlexHub_Loading"}) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ================== LOADING (không tween) ==================
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
lt.Position = UDim2.fromScale(0, 0.38)
lt.BackgroundTransparency = 1
lt.Text = "ALEX HUB"
lt.TextColor3 = Color3.fromRGB(80, 200, 255)
lt.Font = Enum.Font.GothamBold
lt.TextSize = 36
lt.Parent = lf

local lv = Instance.new("TextLabel")
lv.Size = UDim2.fromScale(1, 0.04)
lv.Position = UDim2.fromScale(0, 0.46)
lv.BackgroundTransparency = 1
lv.Text = "v2.0"
lv.TextColor3 = Color3.fromRGB(100, 100, 130)
lv.Font = Enum.Font.Gotham
lv.TextSize = 14
lv.Parent = lf

local sub = Instance.new("TextLabel")
sub.Size = UDim2.fromScale(1, 0.05)
sub.Position = UDim2.fromScale(0, 0.5)
sub.BackgroundTransparency = 1
sub.Text = "loading modules..."
sub.TextColor3 = Color3.fromRGB(140, 140, 170)
sub.Font = Enum.Font.Gotham
sub.TextSize = 13
sub.Parent = lf

local barBg = Instance.new("Frame")
barBg.Size = UDim2.fromScale(0.4, 0.014)
barBg.Position = UDim2.fromScale(0.3, 0.56)
barBg.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
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
pct.Position = UDim2.fromScale(0, 0.59)
pct.BackgroundTransparency = 1
pct.Text = "0%"
pct.TextColor3 = Color3.fromRGB(180, 180, 210)
pct.Font = Enum.Font.Gotham
pct.TextSize = 14
pct.Parent = lf

-- Loading đơn giản, không tween, không task.spawn
for i = 0, 100 do
    bar.Size = UDim2.fromScale(i/100, 1)
    pct.Text = i .. "%"
    task.wait(0.008)
end
task.wait(0.15)
loadingGui:Destroy()

-- ================== MAIN UI ==================
local gui = Instance.new("ScreenGui")
gui.Name = "AlexHub_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 998
gui.Parent = playerGui

-- Nút toggle
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(130, 36)
toggle.Position = UDim2.new(1, -150, 0, 70)
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

local tst = Instance.new("UIStroke")
tst.Color = Color3.fromRGB(80, 200, 255)
tst.Thickness = 1.5
tst.Transparency = 0.5
tst.Parent = toggle

-- Main frame
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(460, 580)
main.Position = UDim2.new(0.5, -230, 0.5, -290)
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

-- Title bar
local tb = Instance.new("Frame")
tb.Size = UDim2.new(1, 0, 0, 48)
tb.BackgroundTransparency = 1
tb.Parent = main

local ttl = Instance.new("TextLabel")
ttl.Size = UDim2.new(1, -140, 1, 0)
ttl.Position = UDim2.fromOffset(18, 0)
ttl.BackgroundTransparency = 1
ttl.Text = "⚡ ALEX HUB"
ttl.TextColor3 = Color3.fromRGB(220, 235, 255)
ttl.Font = Enum.Font.GothamBold
ttl.TextSize = 18
ttl.TextXAlignment = Enum.TextXAlignment.Left
ttl.Parent = tb

local ver = Instance.new("TextLabel")
ver.Size = UDim2.fromOffset(40, 20)
ver.Position = UDim2.new(1, -148, 0, 14)
ver.BackgroundTransparency = 1
ver.Text = "v2.0"
ver.TextColor3 = Color3.fromRGB(100, 100, 130)
ver.Font = Enum.Font.Gotham
ver.TextSize = 11
ver.Parent = tb

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

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -36, 0, 36)
tabBar.Position = UDim2.fromOffset(18, 54)
tabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local tbc = Instance.new("UICorner")
tbc.CornerRadius = UDim.new(0, 8)
tbc.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = tabBar

-- Container cho từng tab
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -36, 1, -170)
content.Position = UDim2.fromOffset(18, 96)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}
local activeTab = nil

local tabs = {
    {name="FIX LAG", id="fix"},
    {name="TỐI ƯU", id="opt"},
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
            else
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(24, 24, 36),
                    TextColor3 = Color3.fromRGB(170, 180, 210),
                }):Play()
            end
        end
    end
    activeTab = id
end

for i, t in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = "tab_" .. t.id
    btn.Size = UDim2.fromOffset(130, 28)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
    btn.Text = t.name
    btn.TextColor3 = Color3.fromRGB(170, 180, 210)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = tabBar

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(t.id)
    end)
end

-- Tạo page cho từng tab
for _, t in ipairs(tabs) do
    local page = Instance.new("ScrollingFrame")
    page.Name = "page_" .. t.id
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(80, 200, 255)
    page.Visible = false
    page.Parent = content

    local pl = Instance.new("UIListLayout")
    pl.Padding = UDim.new(0, 8)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Parent = page

    local pp = Instance.new("UIPadding")
    pp.PaddingRight = UDim.new(0, 8)
    pp.Parent = page

    pages[t.id] = page
end

-- ================== TAB 1: FIX LAG ==================
local fixPage = pages["fix"]

local levelLabel = Instance.new("TextLabel")
levelLabel.Size = UDim2.new(1, 0, 0, 20)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "CHỌN MỨC TỐI ƯU"
levelLabel.TextColor3 = Color3.fromRGB(140, 160, 190)
levelLabel.Font = Enum.Font.GothamBold
levelLabel.TextSize = 12
levelLabel.TextXAlignment = Enum.TextXAlignment.Left
levelLabel.LayoutOrder = 1
levelLabel.Parent = fixPage

local current = 30

local levelGrid = Instance.new("Frame")
levelGrid.Size = UDim2.new(1, 0, 0, 130)
levelGrid.BackgroundTransparency = 1
levelGrid.LayoutOrder = 2
levelGrid.Parent = fixPage

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.fromScale(0.185, 0.42)
grid.CellPadding = UDim2.fromScale(0.015, 0.08)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = levelGrid

local btns = {}
local LVLS = {10,20,30,40,50,60,70,80,90,100}

local function updateInfoBox()
    local info = INFO[current]
    it.Text = "MỨC " .. current .. "% — " .. info.n
    id.Text = info.d
end

for i, p in ipairs(LVLS) do
    local b = Instance.new("TextButton")
    b.LayoutOrder = i
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
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
        updateInfoBox()
    end)
end

-- Info box
local ib = Instance.new("Frame")
ib.Size = UDim2.new(1, 0, 0, 82)
ib.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
ib.BorderSizePixel = 0
ib.LayoutOrder = 3
ib.Parent = fixPage

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

-- Nút apply
local ab = Instance.new("TextButton")
ab.Size = UDim2.new(1, 0, 0, 44)
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
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 170, 240)),
})
abg.Rotation = 90
abg.Parent = ab

ab.MouseEnter:Connect(function()
    TweenService:Create(ab, TweenInfo.new(0.15), {Size = UDim2.new(1, 4, 0, 46)}):Play()
end)
ab.MouseLeave:Connect(function()
    TweenService:Create(ab, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 44)}):Play()
end)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Sẵn sàng."
statusLabel.TextColor3 = Color3.fromRGB(140, 150, 175)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.LayoutOrder = 5
statusLabel.Parent = fixPage

-- ================== TAB 2: TỐI ƯU (toggle riêng lẻ) ==================
local optPage = pages["opt"]

local TOGGLES = {
    {id="shadow", name="Tắt Shadow", default=true},
    {id="fog", name="Tắt Sương Mù", default=true},
    {id="ambient", name="Tắt Ambient", default=true},
    {id="light", name="Tắt Đèn Phụ", default=true},
    {id="particle", name="Tắt Particle", default=true},
    {id="beam", name="Tắt Beam/Trail", default=true},
    {id="decal", name="Tắt Decal/Texture", default=false},
    {id="material", name="Đổi Vật Liệu", default=false},
    {id="nametag", name="Ẩn Name Tag", default=true},
    {id="physics", name="Throttle Physics", default=false},
    {id="streaming", name="Giảm Streaming", default=false},
}

local toggleStates = {}

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 20)
header.BackgroundTransparency = 1
header.Text = "BẬT/TẮT TỪNG MODULE"
header.TextColor3 = Color3.fromRGB(140, 160, 190)
header.Font = Enum.Font.GothamBold
header.TextSize = 12
header.TextXAlignment = Enum.TextXAlignment.Left
header.LayoutOrder = 1
header.Parent = optPage

for i, t in ipairs(TOGGLES) do
    toggleStates[t.id] = t.default

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
    row.BorderSizePixel = 0
    row.LayoutOrder = i + 1
    row.Parent = optPage

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 8)
    rc.Parent = row

    local rs = Instance.new("UIStroke")
    rs.Color = Color3.fromRGB(45, 60, 85)
    rs.Thickness = 1
    rs.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = t.name
    label.TextColor3 = Color3.fromRGB(200, 210, 235)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local sw = Instance.new("TextButton")
    sw.Size = UDim2.fromOffset(44, 24)
    sw.Position = UDim2.new(1, -56, 0.5, -12)
    sw.BackgroundColor3 = t.default and Color3.fromRGB(80, 200, 255) or Color3.fromRGB(40, 40, 55)
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.Parent = row

    local swc = Instance.new("UICorner")
    swc.CornerRadius = UDim.new(1, 0)
    swc.Parent = sw

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(18, 18)
    dot.Position = t.default and UDim2.new(1, -21, 0.5, -9) or UDim2.fromOffset(3, 3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = sw

    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot

    sw.MouseButton1Click:Connect(function()
        toggleStates[t.id] = not toggleStates[t.id]
        if toggleStates[t.id] then
            TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 200, 255)}):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
        else
            TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play()
        end
    end)
end

local applyOpt = Instance.new("TextButton")
applyOpt.Size = UDim2.new(1, 0, 0, 44)
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
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 170, 240)),
})
aog.Rotation = 90
aog.Parent = applyOpt

-- ================== TAB 3: CÔNG CỤ ==================
local toolPage = pages["tool"]

local toolHeader = Instance.new("TextLabel")
toolHeader.Size = UDim2.new(1, 0, 0, 20)
toolHeader.BackgroundTransparency = 1
toolHeader.Text = "CÔNG CỤ BỔ SUNG"
toolHeader.TextColor3 = Color3.fromRGB(140, 160, 190)
toolHeader.Font = Enum.Font.GothamBold
toolHeader.TextSize = 12
toolHeader.TextXAlignment = Enum.TextXAlignment.Left
toolHeader.LayoutOrder = 1
toolHeader.Parent = toolPage

local function makeToolButton(text, order, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(200, 210, 235)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.AutoButtonColor = false
    b.LayoutOrder = order
    b.Parent = toolPage

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = b

    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(45, 60, 85)
    bs.Thickness = 1
    bs.Parent = b

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 36, 50)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 32)}):Play()
    end)
    b.MouseButton1Click:Connect(callback)
    return b
end

makeToolButton("🚀 Unlock FPS (tắt giới hạn 60)", 2, function()
    pcall(function()
        setfpscap(9999)
    end)
    statusLabel.Text = "✓ Đã unlock FPS"
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
end)

makeToolButton("🔇 Tắt Ambient Sound", 3, function()
    pcall(function()
        SoundService.AmbientReverb = Enum.ReverbType.NoReverb
    end)
    for _, s in ipairs(SoundService:GetDescendants()) do
        if s:IsA("Sound") and s.Looped then
            s.Volume = 0
        end
    end
    statusLabel.Text = "✓ Đã tắt ambient"
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
end)

makeToolButton("🌫 Xóa Hiệu Ứng Môi Trường", 4, function()
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect")
        or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
    statusLabel.Text = "✓ Đã xóa hiệu ứng môi trường"
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
end)

makeToolButton("🧹 Clear Cache UI", 5, function()
    for _, v in ipairs(playerGui:GetChildren()) do
        if v ~= gui and v:IsA("ScreenGui") and v.Name ~= "AlexHub_UI" then
            v:Destroy()
        end
    end
    statusLabel.Text = "✓ Đã clear cache UI"
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
end)

makeToolButton("♻ Reset Tất Cả Fix Lag", 6, function()
    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
    end)
    statusLabel.Text = "✓ Đã reset fix lag"
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
end)

-- ================== LOGIC FIX ==================
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
    local ok, err = pcall(applyFix, current)
    if ok then
        statusLabel.Text = "✓ Đã áp dụng mức " .. current .. "%"
        statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
    else
        statusLabel.Text = "Lỗi: " .. tostring(err)
        statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
end)

applyOpt.MouseButton1Click:Connect(function()
    statusLabel.Text = "Đang áp dụng tối ưu..."
    statusLabel.TextColor3 = Color3.fromRGB(80, 200, 255)
    task.wait(0.05)
    local ok, err = pcall(applyToggles)
    if ok then
        statusLabel.Text = "✓ Đã áp dụng tối ưu"
        statusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
    else
        statusLabel.Text = "Lỗi: " .. tostring(err)
        statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
end)

-- Cập nhật label khi chọn mức
local oldClick = ab.MouseButton1Click
-- gắn thêm update text vào nút mức đã có ở trên

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
end)

-- Khởi động
switchTab("fix")
main.Size = UDim2.fromOffset(0, 0)
TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(460, 580)
}):Play()

print("[AlexHub v2.0] loaded.")
