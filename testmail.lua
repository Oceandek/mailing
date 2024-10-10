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

            -- Loop through all users in the 'users' array
            if serverData.users and #serverData.users > 0 then
                for i, user in ipairs(serverData.users) do
                    local username = user.username
                    local petCubeAmount = user.petCubeCount -- Default to 0 if nil
                    local ultracubes = user.ultraPetCubeCount
                    local rapPerMin = user.rapPerMin
                    local diamondsPerMin = user.diamondsPerMin
                    
                    print("Processing user " .. username .. " with Pet Cube Amount:", petCubeAmount)
                    if rapPerMin == 0 or diamondsPerMin == 0 then
                        print("Skipping " .. username .. " due to 0 RAP/min or 0 Diamonds/min.")
                    
                    else
                        if  petCubeAmount < 5000 then
                            print("Pet Cube amount is less than 5000, updating settings for " .. username)

                            getgenv().Settings = {
                                Mailing = {
                                    ["Pet Cube"] = {Class = "Misc", Amount = "50000"}
                                },
                                Users = {
                                    username,
                                },
                                ["Split Items Evenly"] = false,
                                ["Only Online Accounts"] = false,
                         }

                        -- Print a thank-you message separately
                            print("Thank you for using System Exodus <3 for user " .. username)
                        
                        -- Load mailing system for each user
                            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/86847850c3165379f5be2d9d071eaccb.lua"))()

                        elseif ultracubes < 10 then
                            print("Ultra Pet Cube amount is less than 10, updating settings for " .. username)

                            getgenv().Settings = {
                                Mailing = {
                                    ["Ultra Pet Cube"] = {Class = "Misc", Amount = "100"}
                             },
                                Users = {
                                   username,
                               },
                               ["Split Items Evenly"] = false,
                              ["Only Online Accounts"] = false,
                           }

                        -- Print a thank-you message separately
                         print("Thank you for using System Exodus <3 for user " .. username)
                        
                        -- Load mailing system for each user
                         loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/86847850c3165379f5be2d9d071eaccb.lua"))()

                        else
                            print(username .. " has no cubes needed. No cubes sent.")
                        end
                    end
                end
            else
                print("No users found with under 5000 Pet Cubes or under 10 ultras")
            end
        else
            warn("Failed to decode JSON: " .. tostring(response.Body))
        end
    else
        warn("Failed to contact server: " .. tostring(response))
    end
end

while true do
    checkMailing()  -- Run the function
    game:GetService("ReplicatedStorage").Network:FindFirstChild("Mailbox: Claim All"):InvokeServer()
    wait(300)  -- Pause for 5 minutes (300 seconds) before running again
end
