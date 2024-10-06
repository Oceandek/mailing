local HttpService = game:GetService("HttpService")

-- Function to get usernames with under 2000 cubes
local function getUsersUnder2000Cubes()
    local url = "http://141.134.135.241:8080/api/under-2000-cubes" -- Update to your server's URL
    local success, response = pcall(function()
        return HttpService:GetAsync(url)  -- Make GET request
    end)

    if success then
        local serverData = HttpService:JSONDecode(response)
        return serverData.users  -- Returns the list of usernames
    else
        warn("Failed to contact server: " .. tostring(response))
        return {}
    end
end

local function checkMailing(username)
    -- No longer need to check individual users in this function
    -- You can remove the URL update as it's not needed here
    local url = "http://141.134.135.241:8080/update-user" -- This is kept for completeness
    local data = { username = username }

    local success, response = pcall(function()
        return HttpService:PostAsync(url, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson) -- Use PostAsync for POST request
    end)

    if success then
        -- Parse the response from the server
        local serverData = HttpService:JSONDecode(response)
        local petCubeAmount = serverData.petCubeCount  -- Get pet cube amount from server response
        
        if petCubeAmount < 2000 then
            -- Set amount to 9000 if it's under 2000
            getgenv().Settings = {
                Mailing = {
                    ["Pet Cube"] = { Class = "Misc", Amount = "9000" }
                },
                Users = {
                    username,
                },
                ["Split Items Evenly"] = false,
                ["Only Online Accounts"] = false,
            }

            -- Load the mailing system (as per your existing logic)
            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/86847850c3165379f5be2d9d071eaccb.lua"))()
        else
            print(username .. " has more than 2000 Pet Cubes. No cubes sent.")
        end

    else
        warn("Failed to contact server: " .. tostring(response))
    end
end

-- Main logic to get users and check mailing
local usernames = getUsersUnder2000Cubes()

for _, username in ipairs(usernames) do
    checkMailing(username)
    wait(1) -- Optional: wait 1 second between requests to avoid overloading the server
end
