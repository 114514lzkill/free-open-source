local LinksHistory = {}
local HttpRequests = {}

function extractAllLinks(text)
    local links = {}
    local url_pattern = "https?://[%w%-%._~%:/?#%[%]@!%$&%'%(%)%*%+,;%=]+"
    
    for link in text:gmatch(url_pattern) do
        table.insert(links, link)
    end
    
    return links
end

local old_loadstring
if _G.old_loadstring == nil then
    old_loadstring = loadstring
    _G.old_loadstring = old_loadstring
else
    old_loadstring = _G.old_loadstring
end

loadstring = function(source, chunkname)
    local links = extractAllLinks(tostring(source))
    
    if #links > 0 then
        for _, link in ipairs(links) do
            table.insert(LinksHistory, {
                link = link,
                type = "loadstring",
                timestamp = os.time()
            })
        end
        updateDisplay()
    end
    
    return old_loadstring(source, chunkname)
end

local function safeHttpGet(url)
    local success, result = pcall(function()
        if game:GetService("HttpService"):GetHttpEnabled() then
            return game:HttpGet(url)
        else
            return "HTTP服务未启用"
        end
    end)
    return success and result or "HTTP请求失败: " .. tostring(result)
end

local function safeHttpPost(url, data)
    local success, result = pcall(function()
        if game:GetService("HttpService"):GetHttpEnabled() then
            return game:HttpPost(url, data)
        else
            return "HTTP服务未启用"
        end
    end)
    return success and result or "HTTP请求失败: " .. tostring(result)
end

if game.HttpGet then
    local old_HttpGet = game.HttpGet
    game.HttpGet = function(self, url, ...)
        table.insert(HttpRequests, {
            link = url,
            type = "HttpGet",
            timestamp = os.time()
        })
        updateDisplay()
        return old_HttpGet(self, url, ...)
    end
end

if game.HttpPost then
    local old_HttpPost = game.HttpPost
    game.HttpPost = function(self, url, ...)
        table.insert(HttpRequests, {
            link = url,
            type = "HttpPost", 
            timestamp = os.time()
        })
        updateDisplay()
        return old_HttpPost(self, url, ...)
    end
end

local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "沙脚本链接间谍"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 500)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "沙脚本链接间谍 - 实时监控中"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local LoadstringTab = Instance.new("TextButton")
LoadstringTab.Size = UDim2.new(0.5, 0, 1, 0)
LoadstringTab.Position = UDim2.new(0, 0, 0, 0)
LoadstringTab.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
LoadstringTab.Text = "Loadstring监控"
LoadstringTab.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadstringTab.TextSize = 14
LoadstringTab.Font = Enum.Font.GothamSemibold
LoadstringTab.Parent = TabContainer

local HttpTab = Instance.new("TextButton")
HttpTab.Size = UDim2.new(0.5, 0, 1, 0)
HttpTab.Position = UDim2.new(0.5, 0, 0, 0)
HttpTab.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
HttpTab.Text = "HTTP请求监控"
HttpTab.TextColor3 = Color3.fromRGB(255, 255, 255)
HttpTab.TextSize = 14
HttpTab.Font = Enum.Font.GothamSemibold
HttpTab.Parent = TabContainer

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -120)
ContentFrame.Position = UDim2.new(0, 10, 0, 90)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local LoadstringFrame = Instance.new("ScrollingFrame")
LoadstringFrame.Size = UDim2.new(1, 0, 1, 0)
LoadstringFrame.Position = UDim2.new(0, 0, 0, 0)
LoadstringFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
LoadstringFrame.BorderSizePixel = 0
LoadstringFrame.ScrollBarThickness = 4
LoadstringFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LoadstringFrame.Visible = true
LoadstringFrame.Parent = ContentFrame

local LoadstringCorner = Instance.new("UICorner")
LoadstringCorner.CornerRadius = UDim.new(0, 4)
LoadstringCorner.Parent = LoadstringFrame

local HttpFrame = Instance.new("ScrollingFrame")
HttpFrame.Size = UDim2.new(1, 0, 1, 0)
HttpFrame.Position = UDim2.new(0, 0, 0, 0)
HttpFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HttpFrame.BorderSizePixel = 0
HttpFrame.ScrollBarThickness = 4
HttpFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
HttpFrame.Visible = false
HttpFrame.Parent = ContentFrame

local HttpCorner = Instance.new("UICorner")
HttpCorner.CornerRadius = UDim.new(0, 4)
HttpCorner.Parent = HttpFrame

local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 30)
StatusBar.Position = UDim2.new(0, 0, 1, -30)
StatusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.7, 0, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Loadstring: 0 | HTTP: 0"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(0.3, 0, 1, 0)
ButtonContainer.Position = UDim2.new(0.7, 0, 0, 0)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = StatusBar

local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0.5, -5, 1, -10)
ClearButton.Position = UDim2.new(0, 0, 0, 5)
ClearButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
ClearButton.Text = "清空记录"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.TextSize = 12
ClearButton.Font = Enum.Font.Gotham
ClearButton.Parent = ButtonContainer

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.5, -5, 1, -10)
CloseButton.Position = UDim2.new(0.5, 0, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "关闭"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 12
CloseButton.Font = Enum.Font.Gotham
CloseButton.Parent = ButtonContainer

local function createLogEntry(parent, data, index)
    local logFrame = Instance.new("Frame")
    logFrame.Size = UDim2.new(1, -10, 0, 60)
    logFrame.Position = UDim2.new(0, 5, 0, (index-1)*65)
    logFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    logFrame.BorderSizePixel = 0
    logFrame.Parent = parent
    
    local logCorner = Instance.new("UICorner")
    logCorner.CornerRadius = UDim.new(0, 4)
    logCorner.Parent = logFrame
    
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Size = UDim2.new(0.2, 0, 0, 20)
    typeLabel.Position = UDim2.new(0, 5, 0, 5)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = data.type
    typeLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    typeLabel.TextSize = 12
    typeLabel.Font = Enum.Font.GothamBold
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    typeLabel.Parent = logFrame
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.3, 0, 0, 20)
    timeLabel.Position = UDim2.new(0.8, 0, 0, 5)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%H:%M:%S", data.timestamp)
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    timeLabel.TextSize = 10
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = logFrame
    
    local linkLabel = Instance.new("TextLabel")
    linkLabel.Size = UDim2.new(1, -10, 0, 30)
    linkLabel.Position = UDim2.new(0, 5, 0, 25)
    linkLabel.BackgroundTransparency = 1
    linkLabel.Text = data.link
    linkLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    linkLabel.TextSize = 11
    linkLabel.Font = Enum.Font.Code
    linkLabel.TextWrapped = true
    linkLabel.TextXAlignment = Enum.TextXAlignment.Left
    linkLabel.TextYAlignment = Enum.TextYAlignment.Top
    linkLabel.Parent = logFrame
    
    logFrame.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(data.link)
        end
    end)
    
    return logFrame
end

function updateDisplay()
    for _, child in ipairs(LoadstringFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for _, child in ipairs(HttpFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if #LinksHistory > 0 then
        LoadstringFrame.CanvasSize = UDim2.new(0, 0, 0, #LinksHistory * 65)
        for i, data in ipairs(LinksHistory) do
            createLogEntry(LoadstringFrame, data, i)
        end
    end
    
    if #HttpRequests > 0 then
        HttpFrame.CanvasSize = UDim2.new(0, 0, 0, #HttpRequests * 65)
        for i, data in ipairs(HttpRequests) do
            createLogEntry(HttpFrame, data, i)
        end
    end
    
    StatusLabel.Text = string.format("Loadstring: %d | HTTP: %d", #LinksHistory, #HttpRequests)
end

LoadstringTab.MouseButton1Click:Connect(function()
    LoadstringFrame.Visible = true
    HttpFrame.Visible = false
    LoadstringTab.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    HttpTab.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
end)

HttpTab.MouseButton1Click:Connect(function()
    LoadstringFrame.Visible = false
    HttpFrame.Visible = true
    HttpTab.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    LoadstringTab.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
end)

ClearButton.MouseButton1Click:Connect(function()
    LinksHistory = {}
    HttpRequests = {}
    updateDisplay()
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

updateDisplay()

print("沙脚本链接间谍已启动 - 监控Loadstring和HTTP请求")
