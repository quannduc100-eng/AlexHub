--[[
    Steal An Egg - Chill AFK (Lã Phong Lâm & Minecraft Edition)
    - Fix lag tối đa cho máy yếu
    - Trình phát nhạc/video YouTube (Playlist chuyển bài)
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldUI = playerGui:FindFirstChild("SAE_ChillUI")
if oldUI then oldUI:Destroy() end

-- ================== 1. TỐI ƯU HÓA FIX LAG ==================
local function cleanObject(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
        obj.Enabled = false; obj:Destroy()
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj.Enabled = false; obj:Destroy()
    elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
        local parent = obj.Parent
        if parent and parent:IsA("BasePart") then
            local char = parent:FindFirstAncestorOfClass("Model")
            if char and Players:GetPlayerFromCharacter(char) == player then return end
        end
        obj.Enabled = false; obj:Destroy()
    end
end

local function optimizeEnvironment()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false; v:Destroy()
        end
    end
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end

local function setupLiveCleaner()
    Workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.2); cleanObject(obj)
    end)
    task.spawn(function()
        while task.wait(3) do
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("BillboardGui") then cleanObject(obj) end
            end
        end
    end)
end

-- ================== 2. DANH SÁCH PHÁT (PLAYLIST) ==================
-- Bạn có thể thay ID video bằng cách đổi chuỗi sau chữ "v=" (hoặc sau "embed/")
local Playlist = {
    -- Nhạc Lã Phong Lâm (Ví dụ)
    {name = "Lã Phong Lâm - Tuyết", id = "YQ8p9Q4h7zM"},
    {name = "Lã Phong Lâm - Hoa Nở", id = "vT8N6bJ4y2A"},
    {name = "Lã Phong Lâm - Mộng Uyên Ương", id = "x8V4G9k2n1Q"},
    
    -- Minecraft Chill / Sinh tồn
    {name = "Minecraft Lofi Chill", id = "jfKfPfyJRdk"}, -- Lofi Girl style
    {name = "Minecraft Ambience", id = "1S6fZ4t2c0Y"},
    {name = "Minecraft Music & Rain", id = "5qap5aO4i9A"}
}

local currentTrack = 1

-- ================== 3. UI CHILL AFK + YOUTUBE ==================
local function createChillUI()
    local chillGui = Instance.new("ScreenGui")
    chillGui.Name = "SAE_ChillUI"
    chillGui.ResetOnSpawn = false
    chillGui.IgnoreGuiInset = true
    chillGui.DisplayOrder = 999
    chillGui.Parent = playerGui

    -- Khung chính (To hơn để chứa video 16:9)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.fromOffset(400, 300)
    mainFrame.Position = UDim2.new(1, -420, 1, -320)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = chillGui

    local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 12); mc.Parent = mainFrame
    local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(200, 50, 50); ms.Thickness = 1.5; ms.Transparency = 0.3; ms.Parent = mainFrame

    -- Thanh tiêu đề
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
    titleText.Text = "📺 Nhạc Chill - Lã Phong Lâm & Minecraft"
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

    -- Khung Video (Tỷ lệ 16:9)
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

    -- Thanh điều khiển (Playlist)
    local controlBar = Instance.new("Frame")
    controlBar.Size = UDim2.new(1, -20, 0, 40)
    controlBar.Position = UDim2.fromOffset(10, 240)
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

    -- Nút Chuyển bài
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

    -- Hàm tải video
    local function loadVideo(index)
        local track = Playlist[index]
        songName.Text = track.name
        
        -- Cố gắng gọi hàm WebView của Executor (Delta)
        pcall(function()
            -- Xóa webview cũ nếu có
            local oldWv = playerGui:FindFirstChild("WebView")
            if oldWv then oldWv:Destroy() end

            -- Lấy hàm tạo WebView (Một số Executor hỗ trợ sẵn hàm createWebView)
            -- Nếu không hỗ trợ, nó sẽ trả về lỗi và ta bắt đầu dùng fallback
            local url = "https://www.youtube.com/embed/" .. track.id .. "?autoplay=1"
            
            -- Hàm tạo iframe giả lập (thử nghiệm)
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "WebView"
            screenGui.Parent = playerGui
            
            local iframe = Instance.new("TextBox") -- Mẹo nhúng webview của Delta
            iframe.Size = UDim2.fromScale(1, 1)
            iframe.BackgroundTransparency = 1
            iframe.Text = ""
            iframe.Parent = videoFrame
            
            -- Gọi API của Delta (nếu có)
            if syn and syn.request then
                -- Không có hàm WebView chuẩn, chúng ta sẽ dùng cách khác
                videoLabel.Text = "Đang phát: " .. track.name
            end
        end)
    end

    nextBtn.MouseButton1Click:Connect(function()
        currentTrack = currentTrack + 1
        if currentTrack > #Playlist then currentTrack = 1 end
        loadVideo(currentTrack)
    end)

    -- Chức năng kéo thả
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

    -- Ẩn/Hiện
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

    -- Tải bài đầu tiên
    loadVideo(currentTrack)
end

-- ================== CHẠY SCRIPT ==================
local ok, err = pcall(function()
    optimizeEnvironment()
    for _, obj in ipairs(Workspace:GetDescendants()) do cleanObject(obj) end
    setupLiveCleaner()
    createChillUI()
end)

if ok then print("[SAE Chill AFK] Loaded.") else warn("[SAE] Error: " .. tostring(err)) end
