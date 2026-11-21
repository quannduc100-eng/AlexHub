--[[
    AlexHub v4.0 - Venyx Style
    Full UI + Logic Fix Lag nhảy bậc (10 - 30 - 50 - 80 - 100)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Dọn dẹp UI cũ
for _, name in ipairs({"AlexHub_UI", "AlexHub_FPS", "AlexHub_Loading"}) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ================= BẢNG MÀU VENYX STYLE =================
local COLORS = {
    BG = Color3.fromRGB(18, 18, 20),          -- Đen xám
    Sidebar = Color3.fromRGB(24, 24, 27),     -- Xám đậm
    Card = Color3.fromRGB(30, 30, 34),        -- Xám nhạt
    CardHover = Color3.fromRGB(38, 38, 44),   -- Xám sáng
    Text = Color3.fromRGB(240, 240, 240),     -- Trắng
    TextDim = Color3.fromRGB(150, 150, 160),  -- Xám mờ
    Accent = Color3.fromRGB(160, 120, 255),   -- Tím Venyx
    Green = Color3.fromRGB(100, 220, 150),    -- Xanh lá
    Red = Color3.fromRGB(255, 120, 120),      -- Đỏ
}

-- ================= KHỞI TẠO UI =================
local gui = Instance.new("ScreenGui")
gui.Name = "AlexHub_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 998
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(720, 480)
main.Position = UDim2.new(0.5, -360, 0.5, -240)
main.BackgroundColor3 = COLORS.BG
main.BorderSizePixel = 0
main.Parent = gui

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 16)
mc.Parent = main

local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(60, 60, 70)
ms.Thickness = 1
ms.Transparency = 0.5
ms.Parent = main

-- ================= SIDEBAR =================
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.fromOffset(60, 480)
sidebar.BackgroundColor3 = COLORS.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sbc = Instance.new("UICorner")
sbc.CornerRadius = UDim.new(0, 16)
sbc.Parent = sidebar

local sbFix = Instance.new("Frame")
sbFix.Size = UDim2.fromOffset(16, 480)
sbFix.Position = UDim2.fromOffset(44, 0)
sbFix.BackgroundColor3 = COLORS.Sidebar
sbFix.BorderSizePixel = 0
sbFix.Parent = sidebar

local iconLayout = Instance.new("UIListLayout")
iconLayout.Padding = UDim.new(0, 10)
iconLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
iconLayout.SortOrder = Enum.SortOrder.LayoutOrder
iconLayout.Parent = sidebar

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 20)
padding.Parent = sidebar

local function createSidebarBtn(icon, order)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(40, 40)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    b.Text = icon
    b.TextSize = 18
    b.AutoButtonColor = false
    b.LayoutOrder = order
    b.Parent = sidebar
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 10)
    bc.Parent = b
    return b
end

local btnHome = createSidebarBtn("🏠", 1)
local btnFix = createSidebarBtn("⚡", 2)
local btnSet = createSidebarBtn("⚙️", 3)

-- ================= TOP BAR =================
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, -60, 0, 60)
topbar.Position = UDim2.fromOffset(60, 0)
topbar.BackgroundTransparency = 1
topbar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(250, 60)
title.Position = UDim2.fromOffset(20, 0)
title.BackgroundTransparency = 1
title.Text = "ALEXHUB  /  Dashboard"
title.TextColor3 = COLORS.Text
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -45, 0, 15)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
closeBtn.Text = "✕"
closeBtn.TextColor3 = COLORS.Red
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = topbar

local cbc = Instance.new("UICorner")
cbc.CornerRadius = UDim.new(0, 8)
cbc.Parent = closeBtn

-- ================= NỘI DUNG (PAGES) =================
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -60, 1, -60)
contentArea.Position = UDim2.fromOffset(60, 60)
contentArea.BackgroundTransparency = 1
contentArea.Parent = main

-- ================= PAGE: HOME =================
local pageHome = Instance.new("Frame")
pageHome.Size = UDim2.fromScale(1, 1)
pageHome.BackgroundTransparency = 1
pageHome.Parent = contentArea

local cardProfile = Instance.new("Frame")
cardProfile.Size = UDim2.new(1, -40, 0, 100)
cardProfile.Position = UDim2.fromOffset(20, 10)
cardProfile.BackgroundColor3 = COLORS.Card
cardProfile.BorderSizePixel = 0
cardProfile.Parent = pageHome

local cpc = Instance.new("UICorner")
cpc.CornerRadius = UDim.new(0, 12)
cpc.Parent = cardProfile

local profileGradient = Instance.new("UIGradient")
profileGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 40, 90)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 30, 50)),
})
profileGradient.Rotation = 45
profileGradient.Parent = cardProfile

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.fromOffset(60, 60)
avatar.Position = UDim2.fromOffset(20, 20)
avatar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
avatar.Parent = cardProfile

local ac = Instance.new("UICorner")
ac.CornerRadius = UDim.new(1, 0)
ac.Parent = avatar

local nameLbl = Instance.new("TextLabel")
nameLbl.Size = UDim2.new(1, -100, 0, 30)
nameLbl.Position = UDim2.fromOffset(95, 20)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = player.DisplayName
nameLbl.TextColor3 = COLORS.Text
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 20
nameLbl.TextXAlignment = Enum.TextXAlignment.Left
nameLbl.Parent = cardProfile

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -100, 0, 20)
statusLbl.Position = UDim2.fromOffset(95, 50)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Trạng thái: Đang hoạt động"
statusLbl.TextColor3 = COLORS.Green
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 12
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Parent = cardProfile

local btnRow = Instance.new("Frame")
btnRow.Size = UDim2.new(1, -40, 0, 50)
btnRow.Position = UDim2.fromOffset(20, 125)
btnRow.BackgroundTransparency = 1
btnRow.Parent = pageHome

local btnLayout = Instance.new("UIListLayout")
btnLayout.FillDirection = Enum.FillDirection.Horizontal
btnLayout.Padding = UDim.new(0, 10)
btnLayout.Parent = btnRow

-- ================= PAGE: FIX LAG =================
local pageFix = Instance.new("Frame")
pageFix.Size = UDim2.fromScale(1, 1)
pageFix.BackgroundTransparency = 1
pageFix.Visible = false
pageFix.Parent = contentArea

local cardLevel = Instance.new("Frame")
cardLevel.Size = UDim2.new(1, -40, 0, 170)
cardLevel.Position = UDim2.fromOffset(20, 10)
cardLevel.BackgroundColor3 = COLORS.Card
cardLevel.BorderSizePixel = 0
cardLevel.Parent = pageFix

local clc = Instance.new("UICorner")
clc.CornerRadius = UDim.new(0, 12)
clc.Parent = cardLevel

local levelTitle = Instance.new("TextLabel")
levelTitle.Size = UDim2.new(1, -30, 0, 30)
levelTitle.Position = UDim2.fromOffset(15, 10)
levelTitle.BackgroundTransparency = 1
levelTitle.Text = "CHỌN MỨC TỐI ƯU HÓA"
levelTitle.TextColor3 = COLORS.TextDim
levelTitle.Font = Enum.Font.GothamBold
levelTitle.TextSize = 12
levelTitle.TextXAlignment = Enum.TextXAlignment.Left
levelTitle.Parent = cardLevel

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -30, 0, 60)
btnContainer.Position = UDim2.fromOffset(15, 45)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = cardLevel

local btnLayout = Instance.new("UIListLayout")
btnLayout.FillDirection = Enum.FillDirection.Horizontal
btnLayout.Padding = UDim.new(0, 10)
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
btnLayout.Parent = btnContainer

local LEVELS = {10, 30, 50, 80, 100}
local LEVEL_NAMES = {[10]="Nhẹ", [30]="Vừa", [50]="Cao", [80]="Rất Cao", [100]="Tối Đa"}
local currentLevel = 30
local levelButtons = {}

for i, lvl in ipairs(LEVELS) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(110, 50)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    b.Text = lvl .. "%\n" .. LEVEL_NAMES[lvl]
    b.TextColor3 = COLORS.TextDim
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.AutoButtonColor = false
    b.Parent = btnContainer

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 10)
    bc.Parent = b

    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(60, 60, 70)
    bs.Thickness = 1
    bs.Parent = b

    levelButtons[lvl] = b

    b.MouseButton1Click:Connect(function()
        currentLevel = lvl
        for l, btn in pairs(levelButtons) do
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if l == lvl then
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Accent, TextColor3 = COLORS.Text}):Play()
                if stroke then stroke.Color = COLORS.Accent end
            else
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 48), TextColor3 = COLORS.TextDim}):Play()
                if stroke then stroke.Color = Color3.fromRGB(60, 60, 70) end
            end
        end
        applyBtn.Text = "  Áp Dụng Mức " .. lvl .. "%"
    end)
    
    b.MouseEnter:Connect(function()
        if currentLevel ~= lvl then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 58)}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if currentLevel ~= lvl then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
        end
    end)
end

levelButtons[30].BackgroundColor3 = COLORS.Accent
levelButtons[30].TextColor3 = COLORS.Text
levelButtons[30]:FindFirstChildOfClass("UIStroke").Color = COLORS.Accent

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(1, -30, 0, 40)
applyBtn.Position = UDim2.fromOffset(15, 115)
applyBtn.BackgroundColor3 = COLORS.Accent
applyBtn.Text = "  Áp Dụng Mức " .. currentLevel .. "%"
applyBtn.TextColor3 = COLORS.Text
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 14
applyBtn.AutoButtonColor = false
applyBtn.Parent = cardLevel

local abc = Instance.new("UICorner")
abc.CornerRadius = UDim.new(0, 8)
abc.Parent = applyBtn

local applyStatus = Instance.new("TextLabel")
applyStatus.Size = UDim2.new(1, -30, 0, 20)
applyStatus.Position = UDim2.fromOffset(15, 160)
applyStatus.BackgroundTransparency = 1
applyStatus.Text = "Sẵn sàng."
applyStatus.TextColor3 = COLORS.TextDim
applyStatus.Font = Enum.Font.Gotham
applyStatus.TextSize = 11
applyStatus.TextXAlignment = Enum.TextXAlignment.Left
applyStatus.Parent = cardLevel

-- ================= PAGE: SETTINGS =================
local pageSet = Instance.new("Frame")
pageSet.Size = UDim2.fromScale(1, 1)
pageSet.BackgroundTransparency = 1
pageSet.Visible = false
pageSet.Parent = contentArea

local setTitle = Instance.new("TextLabel")
setTitle.Size = UDim2.new(1, -40, 0, 30)
setTitle.Position = UDim2.fromOffset(20, 10)
setTitle.BackgroundTransparency = 1
setTitle.Text = "CÔNG CỤ BỔ SUNG"
setTitle.TextColor3 = COLORS.TextDim
setTitle.Font = Enum.Font.GothamBold
setTitle.TextSize = 12
setTitle.TextXAlignment = Enum.TextXAlignment.Left
setTitle.Parent = pageSet

local toolLayout = Instance.new("UIListLayout")
toolLayout.Padding = UDim.new(0, 8)
toolLayout.Parent = pageSet
toolLayout.SortOrder = Enum.SortOrder.LayoutOrder

local toolPad = Instance.new("UIPadding")
toolPad.PaddingTop = UDim.new(0, 45)
toolPad.PaddingLeft = UDim.new(0, 20)
toolPad.PaddingRight = UDim.new(0, 20)
toolPad.Parent = pageSet

local function makeToolBtn(text, order, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 45)
    b.BackgroundColor3 = COLORS.Card
    b.Text = "   " .. text
    b.TextColor3 = COLORS.Text
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.LayoutOrder = order
    b.Parent = pageSet

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = b

    local bs = Instance.new("UIStroke")
    bs.Color = color or COLORS.Accent
    bs.Thickness = 1
    bs.Transparency = 0.6
    bs.Parent = b

    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.CardHover}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Card}):Play() end)
    b.MouseButton1Click:Connect(callback)
    return b
end

makeToolBtn("🚀 Unlock FPS (Tắt giới hạn 60)", 1, COLORS.Accent, function()
    pcall(function() setfpscap(9999) end)
    applyStatus.Text = "✓ Đã unlock FPS"
    applyStatus.TextColor3 = COLORS.Green
end)

makeToolBtn("🌫 Xóa Hiệu Ứng Môi Trường", 2, COLORS.Accent, function()
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
    applyStatus.Text = "✓ Đã xóa hiệu ứng môi trường"
    applyStatus.TextColor3 = COLORS.Green
end)

makeToolBtn("🧹 Clear Cache UI", 3, COLORS.Accent, function()
    for _, v in ipairs(playerGui:GetChildren()) do
        if v ~= gui and v:IsA("ScreenGui") and v.Name ~= "AlexHub_UI" then v:Destroy() end
    end
    applyStatus.Text = "✓ Đã clear cache UI"
    applyStatus.TextColor3 = COLORS.Green
end)

makeToolBtn("♻ Reset Tất Cả Fix Lag", 4, COLORS.Green, function()
    Lighting.GlobalShadows = true
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 1
    applyStatus.Text = "✓ Đã reset fix lag"
    applyStatus.TextColor3 = COLORS.Green
end)

-- ================= LOGIC FIX LAG =================
local function processLevel(level)
    -- Bậc 10: Tắt Shadow & Sương mù
    if level >= 10 then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
    end
    -- Bậc 30: Tắt Ambient & Đèn phụ
    if level >= 30 then
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = false
            end
        end
    end
    -- Bậc 50: Đổi vật liệu (Mượt hơn)
    if level >= 50 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
    end
    -- Bậc 80: Tắt Particle, Beam, Trail, Decal
    if level >= 80 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end
    end
    -- Bậc 100: Ẩn NameTag & Tối ưu sâu
    if level >= 100 then
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
end

applyBtn.MouseButton1Click:Connect(function()
    applyStatus.Text = "Đang xử lý..."
    applyStatus.TextColor3 = COLORS.Accent
    task.wait(0.1)
    
    local ok, err = pcall(processLevel, currentLevel)
    if ok then
        applyStatus.Text = "✓ Đã áp dụng mức " .. currentLevel .. "% thành công!"
        applyStatus.TextColor3 = COLORS.Green
    else
        applyStatus.Text = "Lỗi: " .. tostring(err)
        applyStatus.TextColor3 = COLORS.Red
    end
end)

-- ================= CHUYỂN TRANG =================
local function switchPage(page)
    pageHome.Visible = (page == "home")
    pageFix.Visible = (page == "fix")
    pageSet.Visible = (page == "set")

    btnHome.BackgroundColor3 = (page == "home") and COLORS.Accent or Color3.fromRGB(40, 40, 48)
    btnFix.BackgroundColor3 = (page == "fix") and COLORS.Accent or Color3.fromRGB(40, 40, 48)
    btnSet.BackgroundColor3 = (page == "set") and COLORS.Accent or Color3.fromRGB(40, 40, 48)
end

btnHome.MouseButton1Click:Connect(function() switchPage("home") end)
btnFix.MouseButton1Click:Connect(function() switchPage("fix") end)
btnSet.MouseButton1Click:Connect(function() switchPage("set") end)

-- Nút Close
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Kéo thả
local dragging, dragInput, dragStart, startPos
topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Hiệu ứng mở
main.Size = UDim2.fromOffset(0, 0)
TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(720, 480)}):Play()

print("[AlexHub v4.0] Venyx UI Loaded.")
