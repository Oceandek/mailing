--bluesotk
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Pet inventory module
local Save = require(ReplicatedStorage.Library.Client.Save)
local daycareSlotVoucherConsume = ReplicatedStorage:WaitForChild("Network"):WaitForChild("DaycareSlotVoucher_Consume")
local mailboxClaimAll = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Mailbox: Claim All")
local daycareCmds = require(ReplicatedStorage.Library.Client.DaycareCmds)

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


-- Function to check total slots and consume voucher if needed
local function checkAndConsumeVoucherIfNeeded()
    local totalSlots = daycareCmds.GetMaxSlots()

    print("Current Total Slots:", totalSlots)
    local counter = totalSlots  -- Store the current slot count

    if totalSlots < 30 then
        print("Consuming voucher because slots are less than 30...")

        -- Consume the voucher
        local success, error = pcall(function()
            daycareSlotVoucherConsume:InvokeServer()
        end)

        if success then
            print("Voucher consumed successfully!") -- Debug
            
            -- Check if the total slots increased after consuming the voucher
            local newTotalSlots = daycareCmds.GetMaxSlots()

            print("Total Slots after consuming voucher:", newTotalSlots)

            if newTotalSlots == counter then
                -- Send webhook if the slots didn't increase
                sendWebhook("Voucher consumed but slots did not increase. Current slots: " .. tostring(newTotalSlots) .. "/30.")
            else
                print("Slots increased to " .. newTotalSlots .. " after voucher consumption.")
            end
        else
            print("Error consuming voucher: " .. tostring(error)) -- Debug
        end
    else
        print("Total slots are already 30 or more.")
    end
end




-- Function to find one pet that has an amount of 30 or more
local function findPetWithThirtyAmount()
    -- Loop through the player's pet inventory to find one pet with amount >= 30
    for id, data in pairs(Save.Get().Inventory.Pet) do
        if data._am ~= nil and data._am >= 30 and data.pt ~= nil and data.pt == 1 then
            return id -- Return the first pet ID that matches the condition
        end
    end

    return nil -- Return nil if no pet matches the condition
end

-- Function to enroll the pet in daycare
local function enrollPetInDaycare()
    local petId = findPetWithThirtyAmount()

    if petId then
        local args = { [1] = {} }

        -- Set the pet ID to 30, as requested
        args[1][petId] = 30

        -- Enroll the pet by invoking the server
        print("Enrolling pet with ID:", petId)
        ReplicatedStorage:WaitForChild("Network"):WaitForChild("Daycare: Enroll"):InvokeServer(unpack(args))

        -- Notify via webhook
        local message = "Enrolled pet with ID " .. petId .. " in the daycare with value 30."
        sendWebhook(message)
    else
        print("No pet found with amount >= 30.")
    end
end

-- Function to run daycare enrollment every 10 minutes
local function autoDaycare()
    task.spawn(function()
        while true do
            print("Running auto-enroll for daycare...")
            checkAndConsumeVoucherIfNeeded() -- Check and consume voucher if slots are less than 30
            enrollPetInDaycare()
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

            task.wait(60)  -- Wait 30 seconds before checking the mailbox again
        end
    end)
end

-- Start the automatic mailbox claiming and daycare enrollment
autoClaimMailbox()  -- Automatically claims mailbox rewards every 30 seconds
autoDaycare()       -- Automatically enrolls pet with amount >= 30 every 10 minutes
