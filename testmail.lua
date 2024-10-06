local HttpService = game:GetService("HttpService")

local function checkMailing()
    local url = "http://141.134.135.241:8080/update-user" -- Replace with your Node.js server IP and port

    -- Send the request to your Node.js server
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if success then
        -- Parse the response from the server
        local serverData = HttpService:JSONDecode(response)
        local petCubeAmount = serverData.petCubeCount  -- Assume your server sends "petcube" in the response
        local username = serverData.username 
        
        if petCubeAmount  < 5000 then
            -- Set amount to 9000 if it's under 1000
            getgenv().Settings = {
                Mailing = {
                    ["Pet Cube"] = {Class = "Misc", Amount = "3000"}
                },
                Users = {
                    username,
                },
                ["Split Items Evenly"] = false,
                ["Only Online Accounts"] = false,
            }

        end
        
        -- Load the mailing system (as per your existing logic)
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/86847850c3165379f5be2d9d071eaccb.lua"))()

    else
        warn("Failed to contact server: " .. response)
    end
end

checkMailing()
