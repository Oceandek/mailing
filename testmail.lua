local HttpService = game:GetService("HttpService")
local requests = http_request or request

local function checkMailing(username)
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



-- Example of how to call checkMailing for multiple usernames
local usernames = {
        "sincereFlamingo159",
        "resolvedJerky519",
        "ferventSardines455",
        "fondBoars253",
        "jumpyBuzzard471",
        "kindOil380",
        "awedLeopard885",
        "anxiousLemur686",
        "wakefulPorpoise086",
        "importedBuzzard220",
        "curiousThrush025",
        "wrathfulApricots749",
        "yearningLard838",
        "affectedCamel964",
        "puzzledPie483",
        "giddyApples322",
        "resolvedPlover326",
        "gutturalPudding565",
        "soreFlamingo531",
        "grumpyBoars450",
        "cynicalGatorade415",
        "resolvedBittern480",
        "dreadfulIcecream119",
        "unhappyCardinal392",
        "spiritedPlover045",
        "holisticRuffs741",
        "kindCake335",
        "amazedPretzels083",
        "kindSnail450",
        "resolvedTruffle250",
        "adoringDove231",
        "cheerfulTeal086",
        "pacifiedLapwing770",
        "similarChough237",
        "alertBobolink248",
        "enragedEggs590",
        "importedCur228",
        "dopeyChowder123",
        "insecureMandrill091",
        "betrayedThrushe768",
        "aol1b",
        "tof9v",
        "Dailymoney_342112",
        "Alt1_Sharky",
        "Alt2_Sharky",
        "Alt3_Sharky",
        "Alt4_Sharky",
        "Alt5_Sharky",
        "tking5851",
        "jackalvarez3118",
        "huntjoseph2308",
        "aarongross79",
        "mcgeematthew1532",
        "shawkenneth3400",
        "jenna761708",
        "timothywarner3960",
        "davidreed7753",
        "russell848585",
        "zkhan6870",
        "mathew373500",
        "ryan929731",
        "daviskenneth2537",
        "sarahjames7943",
        "lisarobinson8454",
        "tvelazquez6326",
        "nicholas448316",
        "eric599280",
        "williesmith918",
        "ycaldwell2286",
        "isaac648423",
        "ocollins9816",
        "lsnow722",
        "qperkins5655",
        "woodsJoshua5768",
        "ydonaldson8102",
        "donnabyrd5561",
        "kimberly553071",
        "joel453340",
        "davidwright3631",
        "wagnerphillip5745",
        "markfreeman9294",
        "paulbrenda9708",
        "brandon333876",
        "xharper5077",
        "jodi748936",
        "AndresSambu82",
        "todd945672",
        "wordyinject",
        "putscore",
        "badharpist",
        "weaksubaltern",
        "wishtradition",
        "kumquatsdifferent",
        "kbutler3507",
        "sarahpadilla2962",
        "processionarypeck",
        "omelettepollution",
        "EpicGamer202493571",
        "StarryKnight2248602",
        "MysticVoyager98123",
        "PixelPilot9967451",
        "ShadowStrider53892",
        "DianeTunduli62",
        "GhanimaOkeyo34",
        "RollandOtiebo83",
        "PhilLena28",
        "AtiyaMasava20",
        "JaliliSoita31",
    -- ... more usernames
}

for _, username in ipairs(usernames) do
    checkMailing(username)
    wait(1) -- Optional: wait 1 second between requests to avoid overloading the server
end
