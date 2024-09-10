local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Pet inventory module
local Save = require(ReplicatedStorage.Library.Client.Save)
local daycareSlotVoucherConsume = ReplicatedStorage:WaitForChild("Network"):WaitForChild("DaycareSlotVoucher_Consume")
local mailboxClaimAll = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Mailbox: Claim All")

-- Discord Webhook Config
local webhookUrl = "https://discord.com/api/webhooks/1283130489758285900/q_p3g7_SSsnwi8pfHces1_ZVlpqMG45fd1ytzu9PXhu1PE8UFvPK-ZQ4xChaobEvQoNM"

-- Function to send a webhook notification
local function sendWebhook(message)
    print("Sending webhook with message: " .. message) -- Debug
    local data = {
        ["username"] = game.Players.LocalPlayer.Name .. " has enrolled pets in daycare.",
        ["avatar_url"] = "https://cdn.discordapp.com/avatars/593552251939979275/58ea82801d6003749293c7bba1efabc8.webp?size=1024&format=webp&width=0&height=256",
        ["content"] = message,
        ["embeds"] = {
            {
                ["author"] = {
                    ["name"] = game.Players.LocalPlayer.Name,
                    ["url"] = "https://www.roblox.com/users/" .. game.Players.LocalPlayer.UserId,
                    ["icon_url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. game.Players.LocalPlayer.UserId .. "&width=420&height=420&format=png",
                },
                ["title"] = "Daycare Enrollment Notification",
                ["color"] = 0x212325,
                ["footer"] = {
                    ["text"] = "Pet Simulator",
                },
            },
        },
        ['timestamp'] = DateTime.now():ToIsoDate(),
    }

    local success, response = pcall(function()
        return request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data),
        })
    end)

    if success then
        print("Webhook sent successfully!") -- Debug
    else
        print("Failed to send webhook: " .. tostring(response)) -- Debug
    end
end

-- Function to find pets that can be enrolled in daycare
local function findPetsForDaycare()
    local petIds = {}

    -- Loop through the player's pet inventory
    for id, data in pairs(Save.Get().Inventory.Pet) do
        if data._am ~= nil and data._am >= 10 and data.pt ~= nil and data.pt == 1 then
            table.insert(petIds, id)
            -- Enroll exactly 30 pets
            if #petIds >= 30 then
                break
            end
        end
    end

    return petIds
end

-- Function to enroll 30 pets in daycare
local function enrollPetsInDaycare()
    local petIds = findPetsForDaycare()

    if #petIds == 30 then
        local args = { [1] = {} }

        -- Add pets to the enrollment args with value 30
        for _, petId in pairs(petIds) do
            args[1][petId] = 30 -- Each pet will be set to 30 as required
        end

        -- Enroll pets by invoking the server
        print("Enrolling 30 pets in daycare:", args)
        ReplicatedStorage:WaitForChild("Network"):WaitForChild("Daycare: Enroll"):InvokeServer(unpack(args))

        -- Notify via webhook
        local message = "Enrolled 30 pets in the daycare."
        sendWebhook(message)
    else
        print("Not enough pets found for enrollment. Found:", #petIds)
    end
end

-- Function to run daycare enrollment every 10 minutes
local function autoDaycare()
    task.spawn(function()
        while true do
            print("Running auto-enroll for daycare...")
            enrollPetsInDaycare()
            task.wait(600)  -- Wait for 10 minutes (600 seconds) before running again
        end
    end)
end

-- Function to check mailbox every 30 seconds and claim rewards
local function autoClaimMailbox()
    task.spawn(function()
        print("Starting mailbox claim loop...") -- Debug
        while true do
            print("Attempting to claim from mailbox...") -- Debug
            local success, error = pcall(function()
                mailboxClaimAll:InvokeServer()
            end)
            
            if success then
                print("Claimed rewards from mailbox successfully!") -- Debug
            else
                print("Error claiming from mailbox: " .. tostring(error)) -- Debug
            end

            task.wait(30)  -- Wait 30 seconds before checking the mailbox again
        end
    end)
end

-- Start the automatic mailbox claiming and daycare enrollment
autoClaimMailbox()  -- Automatically claims mailbox rewards every 30 seconds
autoDaycare()       -- Automatically enrolls pets in daycare every 10 minutes
