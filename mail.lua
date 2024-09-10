local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = ReplicatedStorage:FindFirstChild("Library")
local daycareSlotVoucherConsume = ReplicatedStorage:WaitForChild("Network"):WaitForChild("DaycareSlotVoucher_Consume", 5) -- Timeout after 5 seconds if not found
local mailboxClaimAll = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Mailbox: Claim All", 5) -- Timeout after 5 seconds if not found

-- Discord Webhook Config
local webhookUrl = "https://discord.com/api/webhooks/1283130489758285900/q_p3g7_SSsnwi8pfHces1_ZVlpqMG45fd1ytzu9PXhu1PE8UFvPK-ZQ4xChaobEvQoNM"

-- Function to send a webhook notification
local function sendWebhook(message)
    print("Sending webhook with message: " .. message) -- Debug
    local data = {
        ["username"] = game.Players.LocalPlayer.Name .. " needs tickets!",
        ["avatar_url"] = "https://cdn.discordapp.com/avatars/593552251939979275/58ea82801d6003749293c7bba1efabc8.webp?size=1024&format=webp&width=0&height=256",
        ["content"] = message,
        ["embeds"] = {
            {
                ["author"] = {
                    ["name"] = game.Players.LocalPlayer.Name,
                    ["url"] = "https://www.roblox.com/users/" .. game.Players.LocalPlayer.UserId,
                    ["icon_url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. game.Players.LocalPlayer.UserId .. "&width=420&height=420&format=png",
                },
                ["title"] = "Slot Upgrade Request",
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

-- Function to consume ticket until max slots reach 30
local function consumeTicketsUntilMaxSlots(targetSlots)
    print("Checking for Library...") -- Debug
    if not Library then
        print("Library not found in ReplicatedStorage!") -- Debug
        return
    end

    print("Library found!") -- Debug
    local success, daycareCmds = pcall(function()
        return require(Library.Client.DaycareCmds)
    end)

    if not success or not daycareCmds then
        print("Failed to load DaycareCmds: " .. tostring(daycareCmds)) -- Debug
        return
    end

    print("DaycareCmds loaded successfully!") -- Debug

    -- Start autoclaim mailbox every 30 seconds
    autoClaimMailbox()

    -- Loop until the total slots reach the targetSlots (in this case, 30)
    while true do
        -- Check current number of slots
        local success, totalSlots = pcall(function()
            return daycareCmds.GetMaxSlots()
        end)

        if not success then
            print("Error getting max slots: " .. tostring(totalSlots)) -- Debug
            break
        end

        print("Total Slots:", totalSlots) -- Debug

        -- If slots are already 30 or more, break out of the loop
        if totalSlots >= targetSlots then
            print("Max slots reached:", totalSlots) -- Debug
            break
        end

        -- Consume a ticket if possible, otherwise send a webhook message
        print("Attempting to consume a ticket...") -- Debug
        local consumeSuccess, consumeError = pcall(function()
            daycareSlotVoucherConsume:InvokeServer()
        end)

        if not consumeSuccess then
            local remainingSlots = targetSlots - (totalSlots or 0)
            local message = game.Players.LocalPlayer.Name .. " needs " .. remainingSlots .. " more tickets to reach " .. targetSlots .. " slots."
            print("Failed to consume ticket. Sending webhook...") -- Debug
            print("Message: " .. message) -- Debug
            sendWebhook(message)
        else
            print("Ticket consumed successfully!") -- Debug
        end

        -- Optional: Add a short wait to avoid spamming the server (depends on the system)
        task.wait(1)
    end
end

-- Check for critical components before starting
if not daycareSlotVoucherConsume then
    print("Failed to find daycareSlotVoucherConsume in ReplicatedStorage!") -- Debug
elseif not mailboxClaimAll then
    print("Failed to find mailboxClaimAll in ReplicatedStorage!") -- Debug
else
    print("Starting ticket consumption loop...") -- Debug
    consumeTicketsUntilMaxSlots(30)
end
