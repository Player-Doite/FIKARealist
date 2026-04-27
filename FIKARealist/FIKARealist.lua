local addonName = ...
local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:RegisterEvent("CHAT_MSG_SYSTEM")

local guildName = "FIKA"
local addonPrefix = "|cff7fd4ffFIKARealist|r"
local lastUsedIndex = nil
local rotation = {}
local rotationPos = 1
local isEnabled = true
local isTestMode = false
local pendingMessages = {}

local templates = {
    "Jaha, då var du här också, %s. Välkommen till " .. guildName .. ".",
    "Ingen panik, %s – förväntningarna i " .. guildName .. " är redan låga.",
    "%s har joinat. Perfekt, nu blev " .. guildName .. " exakt så kaotiskt som väntat.",
    "Välkommen %s. Hoppas du trivs med lagom dåliga beslut i " .. guildName .. ".",
    "Kul att se dig, %s. Vi lovar inget utom sena pulls och kallt kaffe.",
    "%s, du är nu officiellt en del av " .. guildName .. ". Beklagar i förväg.",
    "Bra tajming, %s. Vi var precis på väg att sakna någon att skylla på.",
    "Välkommen %s – " .. guildName .. " blev just lite mer tveksamt.",
    "%s joinade. Moralen: oförändrat tveksam.",
    "Hoppas du ler fler gånger nu när du joinat " .. guildName .. " än innan, %s.",
    "%s är inne. Nu är frågan bara hur länge entusiasmen överlever.",
    "Välkommen %s. Du får en gratis plats i vår överfulla kaosbudget.",
    "Javisst, en till. Tja %s, och välkommen till " .. guildName .. ".",
    "%s, din resa i " .. guildName .. " börjar med lätt besvikelse och slutar med fler wipes.",
    "Välkommen in %s. Förhoppningsvis läser du inte vår raidlogg.",
    "%s har anslutit till " .. guildName .. ". Någon måste ju göra det.",
    "Kul, %s är här. Vi märker knappt skillnad än.",
    "Välkommen %s. Vi är inte sena – vi är bara konsekventa.",
    "%s joinade " .. guildName .. ". Nu saknas bara disciplin och tur.",
    "Bra jobbat %s, du hittade till " .. guildName .. " trots vårt rykte.",
    "Välkommen %s. I " .. guildName .. " är 'snart klar' en livsstil.",
    "%s är med nu. Förvarning: vi tar pauser på allvar.",
    "Tjena %s. " .. guildName .. " är platsen där planer dör i voice.",
    "Välkommen %s – du kommer passa in så fort något går fel.",
    "%s har joinat. Hoppas du gillar improviserad strategi.",
    "Japp, %s är här. Nu blev guildchatten 3%% mer passivt aggressiv.",
    "Välkommen till " .. guildName .. ", %s. Vi lovar minst ett 'oops' per kväll.",
    "%s, du är nu del av laget som alltid 'nästan' hade det.",
    "Kul med nytt blod, %s. Vi hoppas du tagit med tålamod.",
    "%s har klivit in i " .. guildName .. ". Ingen vet varför, men välkommen.",
    "Välkommen %s. Här får man lära sig skillnaden på plan och verklighet.",
    "%s joinade precis. Tur, vi behövde fler vittnen.",
    "Tjena %s, i " .. guildName .. " är tystnad ofta ett dåligt tecken.",
    "Välkommen %s. Oroa dig inte – första missen är gratis.",
    "%s är inne. Nu har vi ännu en som kan skriva 'my bad'.",
    "Välkommen till " .. guildName .. ", %s. Förhoppning är tillåten men ej garanterad.",
    "%s joinade. Bra, då kan vi rotera vem som suckar i chatten.",
    "Tjena %s. Vi är glada på vårt eget lite bittra sätt.",
    "Välkommen %s – i " .. guildName .. " kallar vi det 'karaktärsbyggande'.",
    "%s har anslutit. Exakt vad vi behövde: fler frågetecken.",
    "Kul %s, nu är du också fast i vår sociala cooldown.",
    "Välkommen %s. Här firar vi framgång med skeptiska nickningar.",
    "%s joinade " .. guildName .. ". Bara att ställa in sig på blandade signaler.",
    "Hej %s. Vi är inte negativa, bara realistiska med extra krydda.",
    "Välkommen %s. Håller du ut en vecka får du veteranstatus i klagomuren.",
    "%s har kommit in. Nästa steg: överleva en raidkväll med humorn kvar.",
    "Jaha %s, välkommen till " .. guildName .. " där plan B är plan A.",
    "Välkommen %s. Vi har hög närvaro och låg självinsikt.",
    "%s är här nu. Perfekt, då är gruppen komplett ofullständig.",
    "Tjena %s – hoppas du gillar konstruktiv gnällighet.",
    "Välkommen till " .. guildName .. ", %s. Vi kallar kaos för personlighet.",
    "%s joinade. Oroa dig inte, ingen vet heller vad som händer.",
    "Välkommen %s. Här blir allt bra… tillräckligt ofta.",
    "%s är med! Vi låter bittra, men vi menar oftast väl.",
    "Tjena %s, lägg ribban lagom lågt så blir du positivt överraskad.",
    "Välkommen %s. " .. guildName .. " levererar 50%% kvalitet och 100%% kommentarer.",
}

local function escapePattern(text)
    return text:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

local function getGuildJoinName(systemMessage)
    local linkName = systemMessage:match("|Hplayer:([^:|]+)")
    if linkName and linkName ~= "" then
        return linkName
    end

    if not ERR_GUILD_JOIN_S then
        local englishName = systemMessage:match("^%[?([^%]]+)%]? has joined the guild%.$")
        return englishName
    end

    local pattern = "^" .. escapePattern(ERR_GUILD_JOIN_S):gsub("%%s", "(.+)") .. "$"
    local rawName = systemMessage:match(pattern)
    if not rawName then
        rawName = systemMessage:match("^%[?([^%]]+)%]? has joined the guild%.$")
    end

    if not rawName then
        return nil
    end

    return rawName:gsub("^%[", ""):gsub("%]$", "")
end

local function rebuildRotation()
    rotation = {}
    for i = 1, #templates do
        rotation[i] = i
    end

    for i = #rotation, 2, -1 do
        local j = math.random(i)
        rotation[i], rotation[j] = rotation[j], rotation[i]
    end

    if #rotation > 1 and lastUsedIndex and rotation[1] == lastUsedIndex then
        rotation[1], rotation[2] = rotation[2], rotation[1]
    end

    rotationPos = 1
end

local function getNextTemplate()
    if rotationPos > #rotation or #rotation == 0 then
        rebuildRotation()
    end

    local idx = rotation[rotationPos]
    rotationPos = rotationPos + 1
    lastUsedIndex = idx
    return templates[idx]
end

local function printStatus(message)
    DEFAULT_CHAT_FRAME:AddMessage(addonPrefix .. " " .. message)
end

local function setEnabled(newValue)
    isEnabled = newValue and true or false
    FIKARealistDB = FIKARealistDB or {}
    FIKARealistDB.enabled = isEnabled
end

local function toggleEnabled()
    setEnabled(not isEnabled)
    if isEnabled then
        printStatus("Aktiverad. Skriver i guildchat när någon joinar.")
    else
        printStatus("Avstängd. Skriver inte i guildchat.")
    end
end

SLASH_FIKAREAL1 = "/fikareal"
SlashCmdList.FIKAREAL = function(msg)
    local command = string.lower((msg or ""):match("^%s*(.-)%s*$"))

    if command == "" then
        toggleEnabled()
        return
    end

    if command == "on" then
        setEnabled(true)
        printStatus("Aktiverad. Skriver i guildchat när någon joinar.")
        return
    end

    if command == "off" then
        setEnabled(false)
        printStatus("Avstängd. Skriver inte i guildchat.")
        return
    end

    if command == "test" then
        isTestMode = not isTestMode
        if isTestMode then
            printStatus("Testläge PÅ. Skriver lokal debugrad när join upptäcks.")
        else
            printStatus("Testläge AV.")
        end
        return
    end

    printStatus("Använd: /fikareal (toggle), /fikareal on, /fikareal off, /fikareal test")
end

addonFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then
            return
        end

        FIKARealistDB = FIKARealistDB or {}
        if type(FIKARealistDB.enabled) == "boolean" then
            isEnabled = FIKARealistDB.enabled
        else
            FIKARealistDB.enabled = isEnabled
        end
        return
    end

    if event ~= "CHAT_MSG_SYSTEM" or not arg1 then
        return
    end

    local playerName = getGuildJoinName(arg1)
    if not playerName then
        if isTestMode and arg1:find("has joined the guild%.") then
            printStatus("Trigger upptäckt men kunde inte läsa namn: " .. arg1)
        end
        return
    end

    if isTestMode then
        printStatus("Join upptäckt: " .. playerName)
    end

    if not isEnabled then
        return
    end

    local template = getNextTemplate()
    local message = string.format(template, playerName)
    table.insert(pendingMessages, {
        message = message,
        sendAt = GetTime() + 1,
    })
end)

addonFrame:SetScript("OnUpdate", function()
    if #pendingMessages == 0 then
        return
    end

    local nextMessage = pendingMessages[1]
    if GetTime() < nextMessage.sendAt then
        return
    end

    if isEnabled then
        SendChatMessage(nextMessage.message, "GUILD")
    end

    table.remove(pendingMessages, 1)
end)
