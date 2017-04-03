local tableHelper = {};

-- Check whether a table contains a key/value pair, optionally checking inside
-- nested tables
function tableHelper.containsKeyValue(t, keyToFind, valueToFind, checkNestedTables)
    if t[keyToFind] ~= nil then
        if t[keyToFind] == valueToFind then
            return true
        end
    elseif checkNestedTables == true then
        for key, value in pairs(t) do
            if type(value) == "table" and tableHelper.containsKeyValue(value, keyToFind, valueToFind, true) then
                return true
            end
        end
    end
    return false
end

-- Check whether a table contains a certain value, optionally checking inside
-- nested tables
function tableHelper.containsValue(t, valueToFind, checkNestedTables)
    for key, value in pairs(t) do
        if checkNestedTables == true and type(value) == "table" then
            if tableHelper.containsValue(value, valueToFind, true) == true then
                return true
            end
        elseif value == valueToFind then
            return true
        end
    end
    return false
end

function tableHelper.getIndexByPattern(t, patternToFind)
    for key, value in pairs(t) do
        if string.match(value, patternToFind) ~= nil then
            return key
        end
    end
    return nil
end

function tableHelper.removeValue(t, valueToFind)

    tableHelper.replaceValue(t, valueToFind, nil)
end

function tableHelper.replaceValue(t, valueToFind, newValue)
    for key, value in pairs(t) do
        if type(value) == "table" then
            tableHelper.replaceValue(value, valueToFind, newValue)
        elseif value == valueToFind then
            t[key] = newValue
        end
    end
end

-- Add a 2nd table's key/value pairs to the 1st table
--
-- Based on http://stackoverflow.com/a/1283608
function tableHelper.merge(t1, t2)
    for key, value in pairs(t2) do
        if type(value) == "table" then
            if type(t1[key] or false) == "table" then
                tableHelper.merge(t1[key] or {}, t2[key] or {})
            else
                t1[key] = value
            end
        else
            t1[key] = value
        end
    end
end

-- Converts string keys containing numbers into numerical keys,
-- useful for JSON tables
function tableHelper.fixNumericalKeys(t)

    local newTable = {}

    for key, value in pairs(t) do

        if type(value) == "table" then
            tableHelper.fixNumericalKeys(value)
        end
        
        if type(key) ~= "number" and type(tonumber(key)) == "number" then
            newTable[tonumber(key)] = value
            t[key] = nil
        end
    end

    tableHelper.merge(t, newTable)
end

-- Checks whether the table contains only numerical keys, though they
-- don't have to be consecutive
function tableHelper.usesNumericalKeys(t)
    for key, value in pairs(t) do
        if type(key) ~= "number" then
            return false
        end
    end
    return true
end

-- Checks whether the table is an array with only consecutive numerical keys,
-- i.e. without any gaps between keys
-- Based on http://stackoverflow.com/a/6080274
function tableHelper.isArray(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

-- Based on http://lua-users.org/wiki/CopyTable
function tableHelper.shallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Based on http://stackoverflow.com/a/13398936
function tableHelper.print(t, indentLevel)
    local str = ""
    local indentStr = "#"

    if (t == nil) then
        return
    end

    if (indentLevel == nil) then
        print(tableHelper.print(t, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr .. "\t"
    end

    for index, value in pairs(t) do
        str = str .. indentStr .. index

        if type(value) == "boolean" then
            if value == true then
                value = "true"
            else
                value = "false"
            end
        end

        if type(value) == "table" then
            str = str .. ": \n" .. tableHelper.print(value, (indentLevel + 1))
        else
            str = str .. ": " .. value .. "\n"
        end
    end

    return str
end

return tableHelper;