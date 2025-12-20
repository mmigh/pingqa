local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

repeat task.wait() until Players.LocalPlayer
local player = Players.LocalPlayer
local uid = tostring(player.UserId)
local pingUrl = "https://check-host-two.vercel.app/ping?uid=" .. uid .. "&source=executor"

print("[Checkonl] Start ping for UID:", uid)

local function is_disconnected()
    -- kiểm tra nếu có RobloxPromptGui báo lỗi/disconnect
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

while true do
    if not player or not player.Parent or is_disconnected() then
        warn("[Checkonl] Player disconnected -> stop ping")
        break
    end

    local ok, res = pcall(function()
        return game:HttpGet(pingUrl)
    end)
    if ok then
        print("[Checkonl] ping ok")
    else
        warn("[Checkonl] ping failed:", res)
    end

    task.wait(30)
end

print("[Checkonl] Stopped ping loop")
