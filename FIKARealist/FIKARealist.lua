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

local templates = {
    "Jaha, da var du har ocksa, %s. Valkommen till " .. guildName .. ".",
    "Ingen panik, %s - forvantningarna i " .. guildName .. " ar redan laga.",
    "%s har joinat. Perfekt, nu blev " .. guildName .. " exakt sa kaotiskt som vantat.",
    "Valkommen %s. Hoppas du trivs med lagom daliga beslut i " .. guildName .. ".",
    "Kul att se dig, %s. Vi lovar inget utom sen pull och kallt kaffe.",
    "%s, du ar nu officiellt en del av " .. guildName .. ". Beklagar i forvag.",
    "Bra timing, %s. Vi var precis pa vag att sakna nagon att skylla pa.",
    "Valkommen %s - " .. guildName .. " blev just lite mer tveksamt.",
    "%s joinade. Moral: oforandrat tveksam.",
    "Hoppas du fler ganger nu nar du joinat " .. guildName .. " an innan, %s.",
    "%s ar inne. Nu ar fragan bara hur lange entusiasmen overlever.",
    "Valkommen %s. Du far en gratis plats i var overfulla kaosbudget.",
    "Javisst, en till. Tja %s, och valkommen till " .. guildName .. ".",
    "%s, din resa i " .. guildName .. " borjar med latt besvikelse och slutar med fler wipes.",
    "Valkommen in %s. Forhoppningsvis laser du inte var raidlogg.",
    "%s har anslutit till " .. guildName .. ". Nagon maste ju gora det.",
    "Kul, %s ar har. Vi marker knappt skillnad an.",
    "Valkommen %s. Vi ar inte sena - vi ar bara konsekventa.",
    "%s joinade " .. guildName .. ". Nu saknas bara disciplin och tur.",
    "Bra jobbat %s, du hittade till " .. guildName .. " trots var reputation.",
    "Valkommen %s. I " .. guildName .. " ar 'snart klar' en livsstil.",
    "%s ar med nu. Forvarning: vi tar pauser pa allvar.",
    "Tjena %s. " .. guildName .. " ar platsen dar planer dör i voice.",
    "Valkommen %s - du kommer passa in sa fort nagot gar fel.",
    "%s har joinat. Hoppas du gillar improviserad strategi.",
    "Japp, %s ar har. Nu blev guildchatten 3%% mer passivt aggressiv.",
    "Valkommen till " .. guildName .. ", %s. Vi lovar minst ett 'oops' per kvall.",
    "%s, du ar nu del av laget som alltid 'nastan' hade det.",
    "Kul med nytt blod, %s. Vi hoppas du tagit med tälamod.",
    "%s har klivit in i " .. guildName .. ". Ingen vet varfor, men valkommen.",
    "Valkommen %s. Har far man lara sig skillnaden pa plan och verklighet.",
    "%s joinade precis. Tur, vi behovde fler vittnen.",
    "Tjena %s, i " .. guildName .. " ar tystnad ofta ett daligt tecken.",
    "Valkommen %s. Oroa dig inte - forsta missen ar gratis.",
    "%s ar inne. Nu har vi annu en som kan skriva 'my bad'.",
    "Valkommen till " .. guildName .. ", %s. Forhoppning ar tillaten men ej garanterad.",
    "%s joinade. Bra, da kan vi rotera vem som suckar i chatten.",
    "Tjena %s. Vi ar glada pa vart eget lite bittra satt.",
    "Valkommen %s - i " .. guildName .. " kallar vi det 'karaktarbyggande'.",
    "%s har anslutit. Exakt vad vi behovde: fler fragetecken.",
    "Kul %s, nu ar du ocksa fast i var sociala cooldown.",
    "Valkommen %s. Har firar vi framgang med skeptiska nickningar.",
    "%s joinade " .. guildName .. ". Bara att stalla in sig pa blandade signaler.",
    "Hej %s. Vi ar inte negativa, bara realistiska med extra krydda.",
    "Valkommen %s. Haller du ut en vecka far du veteranstatus i klagomur.",
    "%s har kommit in. Nasta steg: overleva en raidkvall med humor kvar.",
    "Jaha %s, valkommen till " .. guildName .. " dar plan B ar plan A.",
    "Valkommen %s. Vi har hog narvaro och lag sjalvinsikt.",
    "%s ar har nu. Perfekt, da ar gruppen komplett ofullstandig.",
    "Tjena %s - hoppas du gillar konstruktiv gnallighet.",
    "Valkommen till " .. guildName .. ", %s. Vi kallar kaos for personlighet.",
    "%s joinade. Oroa dig inte, ingen vet heller vad som hander.",
    "Valkommen %s. Har blir allt bra... tillrackligt ofta.",
    "%s ar med! Vi later bittra, men vi menar oftast val.",
    "Tjena %s, lagg ribban lagom lagt sa blir du positivt overraskad.",
    "Valkommen %s. " .. guildName .. " levererar 50%% kvalitet och 100%% kommentarer.",
}

local function escapePattern(text)
    return text:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

local function getGuildJoinName(systemMessage)
    if not ERR_GUILD_JOIN_S then
        return nil
    end

    local pattern = "^" .. escapePattern(ERR_GUILD_JOIN_S):gsub("%%s", "(.+)") .. "$"
    return systemMessage:match(pattern)
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
        printStatus("Aktiverad. Skriver i guildchat nar nagon joinar.")
    else
        printStatus("Avstangd. Skriver inte i guildchat.")
    end
end

SLASH_FIKANEG1 = "/fikaneg"
SLASH_FIKANEG2 = "/fikneg"
SlashCmdList.FIKANEG = function(msg)
    local command = string.lower((msg or ""):match("^%s*(.-)%s*$"))

    if command == "" then
        toggleEnabled()
        return
    end

    if command == "on" then
        setEnabled(true)
        printStatus("Aktiverad. Skriver i guildchat nar nagon joinar.")
        return
    end

    if command == "off" then
        setEnabled(false)
        printStatus("Avstangd. Skriver inte i guildchat.")
        return
    end

    if command == "test" then
        isTestMode = not isTestMode
        if isTestMode then
            printStatus("Testlage PA. Skriver lokal debugrad nar join upptacks.")
        else
            printStatus("Testlage AV.")
        end
        return
    end

    printStatus("Anvand: /fikaneg (toggle), /fikaneg on, /fikneg off, /fikaneg test")
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
        return
    end

    if isTestMode then
        printStatus("Join upptackt: " .. playerName)
    end

    if not isEnabled then
        return
    end

    local template = getNextTemplate()
    local message = string.format(template, playerName)
    SendChatMessage(message, "GUILD")
end)
