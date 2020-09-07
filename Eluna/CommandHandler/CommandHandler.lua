-- Name this script "CommandHandler.lua"
-- Declare required scripts below
require("xprates")

local Comm = {}

--[[ Helper Functions BEGIN ]]

function Comm.IsAccountWhitelisted(accid, whitelist)
    -- Helper function to determine whether an account is whitelisted to use the specific command in question
    for _, v in pairs(whitelist) do
        if(v == accid) then
            return true;
        end
    end
    
    return false;
end

function Comm.SplitString(inputstr)
    -- Helper function to split a string into a table with each space separated string of the original string as its own value
    local t = {}
    local e, i = 0, 1
    
    while true do
        local b = e+1
        b = inputstr:find("%S", b)
        
        if b == nil then
            break
        end
        
        if inputstr:sub(b,b) == "'" then
            e = inputstr:find("'", b+1)
            b = b+1
        elseif inputstr:sub(b,b) == '"' then
            e = inputstr:find('"', b+1)
            b = b+1
        else
            e = inputstr:find("%s", b+1)
        end
        
        if e == nil then 
            e = #inputstr+1
        end

        t[i] = inputstr:sub(b,e-1)
        i = i + 1
    end
    
    return t
end

--[[ Helper Functions END ]]

--[[ Command Handler Functions BEGIN ]]

function Comm.HandleXPCommand(com, player)
    local rateInfo = player:GetXPRateInfo();
    
    if(tonumber(com[2]) ~= nil) then
        if((tonumber(com[2]) >= 0) and (tonumber(com[2]) <= rateInfo[2])) then
            player:SetXPRate(tonumber(com[2]))
            player:SendBroadcastMessage("Your XP rate has now been set to "..math.ceil(com[2]).."!")
        else
            player:SendBroadcastMessage("You must set a valid XP rate between 0 and "..rateInfo[2].."! Default XP rate is 1.")
        end
    else
        player:SendBroadcastMessage("Command syntax: .xp <0-"..rateInfo[2].."> - Value must be between 0 and "..rateInfo[2].." depending on XP rate of your choice. Your current XP rate is "..rateInfo[1]..".")
    end
end

--[[ Command Handler Functions END ]]

--[[ Raw Handler Function BEGIN ]]

function Comm.Handler(event, player, command)
    local commandTable = Comm.SplitString(command)
    
    if(Comm["register"][commandTable[1]]) then
        if(player) then
            local security, whitelist = Comm["register"][commandTable[1]][2], Comm.IsAccountWhitelisted(player:GetAccountId(), Comm["register"][commandTable[1]][3])
        
            if(player:GetGMRank() >= security or whitelist == true) then
                Comm["register"][commandTable[1]][1](commandTable, player)
            else
                player:SendBroadcastMessage("You do not have access to that command!")
            end
        else -- Assume sent from console
            if(Comm["register"][commandTable[1]][2] >= 4) then
                Comm["register"][commandTable[1]][1](commandTable, nil)
            end
        end
        
        return false;
    end
end

--[[ Raw Handler Function END ]]

--[[ Registers BEGIN ]]

Comm.register = {
    --["commandname"] = {CommandFunction, SecurityLevel, {WhiteListAccIds}}
    ["xp"] = {Comm.HandleXPCommand, 0, {}},
}

RegisterPlayerEvent(42, Comm.Handler)

--[[ Registers END ]]