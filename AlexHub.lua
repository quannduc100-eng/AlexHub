--[[
    AlexHub - Script Fix Lag Tự Động (Không UI)
    Chạy ngầm - Tự động tối ưu hóa ngay khi Execute
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ================== CẤU HÌNH MỨC FIX LAG ==================
-- Bạn có thể sửa số này để đổi mức độ fix:
-- 10 = Nhẹ (Tắt bóng, sương mù)
-- 30 = Vừa (Tắt đèn phụ, ambient)
-- 50 = Cao (Đổi vật liệu phẳng)
-- 80 = Rất cao (Tắt particle, decal)
-- 100 = Tối đa (Ẩn tên người chơi, tắt mọi thứ)
local FIX_LEVEL = 100 
-- ==========================================================

-- Hàm hiển thị thông báo nhỏ (Toast)
local function showToast(text)
    local toastGui = Instance.new("ScreenGui")
    toastGui.Name = "AlexHub_Toast"
    toastGui.ResetOnSpawn = false
    toastGui.IgnoreGuiInset = true
    toastGui.DisplayOrder = 999
    toastGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(250, 50)
    frame.Position = UDim2.new(0.5, -125, 0, -60) -- Bắt đầu ẩn trên màn hình
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = toastGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 220, 150)
    stroke.Thickness = 2
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = frame

    -- Hiệu ứng trượt xuống
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -125, 0, 20)
    }):Play()

    -- Tự động ẩn sau 3 giây
    task.delay(3, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -125, 0, -60)
        }):Play()
        task.wait(0.3)
        toastGui:Destroy()
    end)
end

-- ================== LOGIC FIX LAG ==================
local function runFix()
    -- Bậc 10
    if FIX_LEVEL >= 10 then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
    end
    
    -- Bậc 30
    if FIX_LEVEL >= 30 then
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = false
            end
        end
    end
    
    -- Bậc 50
    if FIX_LEVEL >= 50 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
    end
    
    -- Bậc 80
    if FIX_LEVEL >= 80 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end
    end
    
    -- Bậc 100
    if FIX_LEVEL >= 100 then
        -- Ẩn NameTag người chơi khác
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = p.Character:FindFirstChild("Head")
                if h then
                    local g = h:FindFirstChildOfClass("BillboardGui")
                    if g then g.Enabled = false end
                end
            end
        end
        -- Xóa hiệu ứng môi trường (Atmosphere, Bloom, Blur...)
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
    end
end

-- ================== CHẠY SCRIPT ==================
local ok, err = pcall(runFix)
if ok then
    showToast("⚡ AlexHub: Đã tối ưu hóa xong (" .. FIX_LEVEL .. "%)")
    print("[AlexHub] Auto-fix loaded successfully at " .. FIX_LEVEL .. "%")
else
    showToast("❌ AlexHub: Có lỗi xảy ra!")
    warn("[AlexHub] Error: " .. tostring(err))
end
