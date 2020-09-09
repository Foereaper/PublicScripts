-- Name this script "xprates.lua"
-- This script requires the CommandHandler script for XP command functionality

local Rates = {}
local defaultMaxRate = 7
local defaultRate = 1

function Rates.OnFirstLogin(event, player)
    Rates.ProcessRate(player:GetGUIDLow(), defaultRate, defaultMaxRate)
    player:SendBroadcastMessage("Your XP rate has been set to "..defaultRate.."! To change this, type .xp")
end

function Rates.OnLevelUp(event, player, oldLevel)
    if(player:GetLevel() == 80) then
        Rates.ProcessRate(player:GetGUIDLow(), defaultMaxRate, defaultMaxRate)
    end
end

function Rates.OnGainXP(event, player, amount, victim)
    if(Rates["Cache"][player:GetGUIDLow()] and player:GetLevel() < 80) then
        amount = amount*Rates["Cache"][player:GetGUIDLow()][1]
        return amount;
    end
end

function Rates.OnPetGiveXP(event, player, amount)
    if(Rates["Cache"][player:GetGUIDLow()] and Rates["Cache"][player:GetGUIDLow()][1] > 1) then
        amount = amount*Rates["Cache"][player:GetGUIDLow()][1]
        return amount;    
    end
end

function Rates.LoadCache()
    Rates["Cache"] = {}
       
    local Query = CharDBQuery("SELECT * FROM xprates;");
    if(Query)then
        repeat
            Rates["Cache"][Query:GetUInt32(0)] = {Query:GetUInt32(1), Query:GetUInt32(2)};
        until not Query:NextRow()
    end
end

function Rates.ProcessRate(guid, rate, maxRate)
    Rates["Cache"][guid] = {rate, maxRate};
    CharDBExecute("REPLACE into xprates (guid, rate, maxRate) values("..guid..", "..rate..", "..maxRate..");");
end

function Player:SetXPRate(rate, maxRate)
    if(maxRate == nil) then
        maxRate = Rates["Cache"][self:GetGUIDLow()][2];
    end
    
    Rates.ProcessRate(self:GetGUIDLow(), rate, maxRate)
end

function Player:GetXPRateInfo()
    return Rates["Cache"][self:GetGUIDLow()];
end

Rates.LoadCache()
RegisterPlayerEvent(13, Rates.OnLevelUp)
RegisterPlayerEvent(30, Rates.OnFirstLogin)
RegisterPlayerEvent(12, Rates.OnGainXP)
RegisterPlayerEvent(44, Rates.OnPetGiveXP)