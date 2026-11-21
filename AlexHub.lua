--[[
    Steal An Egg - NO MERCY EDITION
    - Xóa sổ mọi Texture, Decal, GUI phụ.
    - Ép tất cả vật liệu thành SmoothPlastic.
    - Tắt mọi ánh sáng, sương mù, hiệu ứng.
    - Giới hạn render distance xuống mức tối thiểu.
    - Vẫn giữ Widget xem YouTube ở góc màn hình.
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Dọn dẹp UI cũ
for _, name in ipairs({"SAE_ChillUI", "WebView"}) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- =====================================================================
-- PHẦN 1: HỦY DIỆT ĐỒ HỌA (NO MERCY)
-- =====================================================================

local function totalWipe(obj)
    -- 1. Xóa sổ mọi thứ chuyển động/hiệu ứng
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        obj:Destroy()
    
    -- 2. Tắt mọi nguồn sáng
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj:Destroy()
        
    -- 3. Xóa sổ Texture và Decal (MẤT HÌNH ẢNH)
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy()
        
    -- 4. Xóa mọi Text bay lên (BillboardGui, SurfaceGui)
    elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
        local parent = obj.Parent
        if parent and parent:IsA("BasePart") then
            local char = parent:FindFirstAncestorOfClass("Model")
            if char and Players:GetPlayerFromCharacter(char) == player then return end
        end
        obj:Destroy()
        
    -- 5. Ép vật liệu phẳng lì, xóa phản chiếu
    elseif obj:IsA("BasePart") then
        pcall(function()
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false -- Không đổ bóng
        end)
    end
end

local function destroyEnvironment()
    -- Xóa sương mù, bóng đổ, ép ánh sáng sáng trưng
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.Ambient = Color3.new(1, 1, 1)
    
    -- Xóa hiệu ứng môi trường
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
            v:Destroy()
        end
    end
    
    -- GIỚI HẠN RENDER DISTANCE (Cực kỳ quan trọng)
    pcall(function()
        Workspace.StreamingEnabled = true
        Workspace.StreamingTargetRadius = 64 -- Chỉ load trong bán kính 64 studs
    end)

    -- Ép đồ họa xuống mức thấp nhất có thể
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.EagerBulkExecution = true
    end)
end

local function startWiper()
    -- Quét sạch ngay lập tức
    for _, obj in ipairs(Workspace:GetDescendants()) do
        totalWipe(obj)
    end
    
    -- Quét liên tục mỗi 0.1 giây (siêu tốc)
    task.spawn(function()
        while task.wait(0.1) do
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("BillboardGui") or obj:IsA("Decal") or obj:IsA("Texture") then
                    totalWipe(obj)
                end
            end
        end
    end)
    
    -- Theo dõi object mới sinh ra
    Workspace.DescendantAdded:Connect(function(obj)
        totalWipe(obj)
    end)
end

-- =====================================================================
-- PHẦN 2: GIAO DIỆN CHILL AFK + YOUTUBE (Giữ nguyên)
-- =====================================================================

local Playlist = {
    {name = "Lã Phong Lâm - Tuyết", id = "YQ8p9Q4h7zM"},
    {name = "Lã Phong Lâm - Hoa Nở", id = "vT8N6bJ4y2A"},
    {name = "Minecraft Lofi Chill", id = "jfKfPfyJRdk"},
    {name = "Minecraft Ambience", id = "1S6fZ4t2c0Y"}
}
local currentTrack = 1

local function createChillUI()
    local chillGui = Instance.new("ScreenGui")
    chillGui.Name = "SAE_ChillUI"
    chillGui.ResetOnSpawn = false
    chillGui.IgnoreGuiInset = true
    chillGui.DisplayOrder = 999
    chillGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.fromOffset(400, 300)
    mainFrame.Position = UDim2.new(1, -420, 1, -320)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = chillGui

    local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 12); mc.Parent = mainFrame
    local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(200, 50, 50); ms.Thickness = 1.5; ms.Transparency = 0.3; ms.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0, 12); tbc.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.fromOffset(10, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "📺 Chill AFK - No Mercy Mode"
    titleText.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 11
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.fromOffset(20, 20)
    hideBtn.Position = UDim2.new(1, -25, 0, 5)
    hideBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
    hideBtn.Text = "✕"
    hideBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
    hideBtn.Font = Enum.Font.GothamBold
    hideBtn.TextSize = 10
    hideBtn.Parent = titleBar
    local hbc = Instance.new("UICorner"); hbc.CornerRadius = UDim.new(1, 0); hbc.Parent = hideBtn

    local videoFrame = Instance.new("Frame")
    videoFrame.Size = UDim2.new(1, -20, 0, 200)
    videoFrame.Position = UDim2.fromOffset(10, 35)
    videoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    videoFrame.BorderSizePixel = 0
    videoFrame.ClipsDescendants = true
    videoFrame.Parent = mainFrame
    local vfc = Instance.new("UICorner"); vfc.CornerRadius = UDim.new(0, 8); vfc.Parent = videoFrame

    local videoLabel = Instance.new("TextLabel")
    videoLabel.Size = UDim2.fromScale(1, 1)
    videoLabel.BackgroundTransparency = 1
    videoLabel.Text = "Đang tải video..."
    videoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    videoLabel.Font = Enum.Font.Gotham
    videoLabel.TextSize = 12
    videoLabel.Parent = videoFrame

    local controlBar = Instance.new("Frame")
    controlBar.Size = UDim2.new(1, -20, 0, 40)
    controlBar.Position = UDim2.fromOffset(10, 245)
    controlBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    controlBar.BorderSizePixel = 0
    controlBar.Parent = mainFrame
    local cbc2 = Instance.new("UICorner"); cbc2.CornerRadius = UDim.new(0, 8); cbc2.Parent = controlBar

    local songName = Instance.new("TextLabel")
    songName.Size = UDim2.new(1, -80, 1, 0)
    songName.Position = UDim2.fromOffset(10, 0)
    songName.BackgroundTransparency = 1
    songName.Text = Playlist[currentTrack].name
    songName.TextColor3 = Color3.fromRGB(200, 220, 255)
    songName.Font = Enum.Font.GothamBold
    songName.TextSize = 11
    songName.TextXAlignment = Enum.TextXAlignment.Left
    songName.Parent = controlBar

    local nextBtn = Instance.new("TextButton")
    nextBtn.Size = UDim2.fromOffset(30, 30)
    nextBtn.Position = UDim2.new(1, -40, 0.5, -15)
    nextBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    nextBtn.Text = "⏭"
    nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextBtn.Font = Enum.Font.GothamBold
    nextBtn.TextSize = 14
    nextBtn.Parent = controlBar
    local nbc = Instance.new("UICorner"); nbc.CornerRadius = UDim.new(0, 6); nbc.Parent = nextBtn

    local function loadVideo(index)
        local track = Playlist[index]
        songName.Text = track.name
        local oldWv = playerGui:FindFirstChild("WebView")
        if oldWv then oldWv:Destroy() end

        pcall(function()
            local url = "https://www.youtube.com/embed/" .. track.id .. "?autoplay=1"
            if WebView then
                WebView.new(url, videoFrame)
                videoLabel.Visible = false
            else
                videoLabel.Text = "Đang phát: " .. track.name
            end
        end)
    end

    nextBtn.MouseButton1Click:Connect(function()
        currentTrack = currentTrack + 1
        if currentTrack > #Playlist then currentTrack = 1 end
        loadVideo(currentTrack)
    end)

    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    hideBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        local reopenBtn = Instance.new("TextButton")
        reopenBtn.Size = UDim2.fromOffset(40, 40)
        reopenBtn.Position = UDim2.new(1, -60, 1, -60)
        reopenBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        reopenBtn.Text = "📺"
        reopenBtn.TextSize = 20
        reopenBtn.Parent = chillGui
        local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(1, 0); rc.Parent = reopenBtn
        reopenBtn.MouseButton1Click:Connect(function()
            mainFrame.Visible = true
            reopenBtn:Destroy()
        end)
    end)

    loadVideo(currentTrack)
end

-- =====================================================================
-- CHẠY SCRIPT
-- =====================================================================
local ok, err = pcall(function()
    destroyEnvironment()
    startWiper()
    createChillUI()
end)

if ok then print("[SAE No Mercy] Loaded successfully.") else warn("[SAE] Error: " .. tostring(err)) end
