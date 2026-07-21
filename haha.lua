local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

repeat task.wait() until Players.LocalPlayer
local player = Players.LocalPlayer
local uid = tostring(player.UserId)
local username = player.Name
local placeId = tostring(game.PlaceId)

-- Lấy tên Game thực tế (nếu lỗi sẽ lấy mặc định)
local gameName = "Unknown Game"
pcall(function()
    local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    if productInfo and productInfo.Name then
        gameName = productInfo.Name
    end
end)

-- Mã hóa URL an toàn để tránh lỗi chữ cái tiếng Việt hoặc ký tự đặc biệt
local baseUrl = "https://check-host-one.vercel.app/ping"
local pingUrl = string.format(
    "%s?uid=%s&username=%s&place_id=%s&game_name=%s&source=executor",
    baseUrl,
    HttpService:UrlEncode(uid),
    HttpService:UrlEncode(username),
    HttpService:UrlEncode(placeId),
    HttpService:UrlEncode(gameName)
)

print("[Checkonl] Start ping for UID:", uid, "| User:", username)

local function sendPing()
    local ok, res = pcall(function()
        return game:HttpGet(pingUrl)
    end)
    if ok then
        print("[Checkonl] ping ok")
    else
        warn("[Checkonl] ping failed:", res)
    end
end

local function is_disconnected()
    local prompt = CoreGui:FindFirstChild("RobloxPromptGui")
    if prompt then
        for _, d in ipairs(prompt:GetDescendants()) do
            local name = tostring(d.Name):lower()
            if name:find("error") or name:find("disconnect") or name:find("lost") then
                return true
            end
        end
    end
    return false
end

-- Bắt sự kiện Teleport/Hop Server để ping giữ kết nối
player.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.InProgress or teleportState == Enum.TeleportState.Started then
        print("[Checkonl] Teleporting/Hopping... Sending last-minute ping!")
        sendPing()
    end
end)

-- Vòng lặp ping chính
while true do
    if not player or not player.Parent or is_disconnected() then
        warn("[Checkonl] Player disconnected -> stop ping")
        break
    end

    sendPing()
    task.wait(30)
end

print("[Checkonl] Stopped ping loop")
