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

local gameName = "Unknown Game"
pcall(function()
    local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    if productInfo and productInfo.Name then
        gameName = productInfo.Name
    end
end)

local baseUrl = "http://78.154.103.36:9302/ping"

local function sendPing(isHop)
    isHop = isHop or false
    
    local pingUrl = string.format(
        "%s?uid=%s&username=%s&place_id=%s&game_name=%s&source=executor&is_hop=%s",
        baseUrl,
        HttpService:UrlEncode(uid),
        HttpService:UrlEncode(username),
        HttpService:UrlEncode(placeId),
        HttpService:UrlEncode(gameName),
        tostring(isHop)
    )

    local ok, res = pcall(function()
        return game:HttpGet(pingUrl)
    end)
    
    if ok then
        print("[Checkonl] ping ok (isHop:", isHop, ")")
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

player.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.InProgress or teleportState == Enum.TeleportState.Started then
        print("[Checkonl] Hopping Server detected! Sending ping with isHop=true...")
        sendPing(true)
    end
end)

print("[Checkonl] Start ping loop for UID:", uid)

while true do
    if not player or not player.Parent or is_disconnected() then
        warn("[Checkonl] Player disconnected -> stop ping")
        break
    end

    sendPing(false)
    task.wait(60)
end

print("[Checkonl] Stopped ping loop")
