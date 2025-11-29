local LinksHistory = {}

function extractAllLinks(text)
    local links = {}
    local url_pattern = "https?://[%w%-%._~%:/?#%[%]@!%$&%'%(%)%*%+,;%=]+"
    
    for link in text:gmatch(url_pattern) do
        table.insert(links, link)
    end
    
    return links
end

local old_loadstring = loadstring
loadstring = function(source, chunkname)
    local links = extractAllLinks(tostring(source))
    
    if #links > 0 then
        for _, link in ipairs(links) do
            table.insert(LinksHistory, link)
        end
        updateDisplay()
    end
    
    return old_loadstring(source, chunkname)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "沙脚本链接间谍"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "沙脚本链接间谍 - 实时监控中"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ResultsFrame = Instance.new("ScrollingFrame")
ResultsFrame.Size = UDim2.new(1, -20, 1, -60)
ResultsFrame.Position = UDim2.new(0, 10, 0, 50)
ResultsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ResultsFrame.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 1, -30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "已捕获链接: 0"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

function updateDisplay()
    for _, child in ipairs(ResultsFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if #LinksHistory > 0 then
        ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, #LinksHistory * 25)
        
        for i, link in ipairs(LinksHistory) do
            local linkLabel = Instance.new("TextLabel")
            linkLabel.Size = UDim2.new(1, -10, 0, 20)
            linkLabel.Position = UDim2.new(0, 5, 0, (i-1)*25)
            linkLabel.BackgroundTransparency = 1
            linkLabel.Text = i .. ": " .. link
            linkLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
            linkLabel.TextXAlignment = Enum.TextXAlignment.Left
            linkLabel.TextSize = 11
            linkLabel.Font = Enum.Font.Code
            linkLabel.TextWrapped = true
            linkLabel.Parent = ResultsFrame
        end
        
        StatusLabel.Text = "已捕获链接: " .. #LinksHistory
    end
end

updateDisplay()