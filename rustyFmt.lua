---@alias FmtState { fmtStr: string, pos: integer, subKey: string, result: string }
---@alias FmtArgs { [1]: string }
---@alias FmtConfig { error: function?, tostring: function? }
---@alias PrefSide "left"|"right"

-- Defaults if no config is provided
local requireTimeErr = _G.error
local requireTimeTostring = _G.tostring

---@param state FmtState
---@param intoKey string
---@param charUntil string
---@param prefers PrefSide
---@returns boolean?
local function readIntoUntil(state, intoKey, charUntil, prefers)
    local fmtStr = state.fmtStr
    local untilStart, untilEnd = fmtStr:find(charUntil .. "+", state.pos)
    state[intoKey] = state[intoKey] .. fmtStr:sub(state.pos, untilStart and untilStart-1):gsub("}}", "}")

    -- Indicate the pattern failed to match
    if untilStart == nil then return nil end

    local blockLength = (untilEnd+1) - untilStart

    if (blockLength % 2) == 0 then
        -- It's just one big escape, append the escaped characters
        state[intoKey] = state[intoKey] .. string.rep(charUntil, blockLength/2)
        state.pos = untilEnd+1
        return false -- No state change
    else
        state.pos = untilEnd
        -- Not all an escape block
        if prefers == "right" then
            -- Process leading characters
            state[intoKey] = state[intoKey] .. string.rep(charUntil, (blockLength-1)/2)
        end

        state.pos = state.pos + 1
        return true -- State change
    end
end

---@param subKey string
---@param autoIdx integer
---@return string|integer, integer
local function findSubstitutionKey(subKey, autoIdx)
    if subKey == "" then
        -- Implicitly indexed substitutions
        return autoIdx, autoIdx+1
    end

    local numericKey = tonumber(subKey)
    if numericKey ~= nil then
        return numericKey+1, numericKey+2
    end

    return subKey, autoIdx
end

---@param argTbl FmtArgs
---@param key string
---@param autoIdx integer
---@return any, integer
local function findSubstitutionValue(argTbl, key, autoIdx)
    local subKey
    subKey, autoIdx = findSubstitutionKey(key, autoIdx)
    local subVal = argTbl[subKey]
    if subVal == nil then
        error("No substitution value \"" .. subKey .. "\" found passed to RustyFmt!")
    end

    return subVal, math.min(autoIdx, #argTbl)
end

---@param argTbl FmtArgs
---@param cfg? FmtConfig
---@return string
local function rustyFmt(argTbl, cfg)
    local error = (cfg and cfg.error) or requireTimeErr -- Configurable error function
    local tostring = (cfg and cfg.tostring) or requireTimeTostring
    if type(argTbl) ~= "table" then error("RustyFmt takes only a single table as it's arguments.") end
    
    local fmtStr = argTbl[1]
    if type(fmtStr) ~= "string" then error("argTbl[1] should be a format string, recieved a \"" .. type(fmtStr) .. "\" instead!") end

    local state = {
        fmtStr = fmtStr,
        pos = 1,
        result = ""
    }
    
    local argTblCount = #argTbl
    local inSubstitution = false
    local autoIdx = 2
    while true do
        local readResult
        if inSubstitution then
            readResult = readIntoUntil(state, "subKey", '}', "left")
        else
            readResult = readIntoUntil(state, "result", '{', "right")
        end

        if readResult == nil then
            -- End of fmt string
            if state.inSub then error("Format string contained unclosed substitution!") end
            return state.result
        elseif readResult and inSubstitution then
            -- State change back to reading the fmtStr straight to the result
            local subValue
            subValue, autoIdx = findSubstitutionValue(argTbl, state.subKey, autoIdx)
            state.result = state.result .. tostring(subValue)
            inSubstitution = false
        elseif readResult then
            -- Change to reading substitution key
            state.subKey = ""
            inSubstitution = true
        end

    end
end

---@class RustyFmt
---@field private __fmtcfg FmtConfig
---@operator call(FmtArgs): string
local rustyFmtInstance = {}
rustyFmtInstance.__index = rustyFmtInstance

---@param cfg FmtConfig
---@return RustyFmt
function rustyFmtInstance:WithConfig(cfg)
    local newInstance = setmetatable({ __fmtcfg = cfg }, rustyFmtInstance)
    return newInstance
end

function rustyFmtInstance:__call(argTbl)
    return rustyFmt(argTbl, self.__fmtcfg)
end

return rustyFmtInstance