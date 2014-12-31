local f = io.open('./res/values.json', "r+")
if f == nil then
  f = io.open('./res/values.json', "w+")
  f:write("{}") -- Write empty table
  f:close()
  _values = {}
else
  local c = f:read "*a"
  f:close()
  _values = json:decode(c)
end

function fetch_value(chat, value_name)
  if (_values[chat] == nil) then
    return nil
  end
  if (value_name == nil ) then
    return nil
  end 
  local value = _values[chat][value_name]
  return value
end

function get_value(chat, value_name)

  -- If chat values is empty
  if (_values[chat] == nil) then
    return "There isn't any data"
  end

  -- If there is not value name, return all the values.
  if (value_name == nil ) then
    local text = ""
    for key,value in pairs(_values[chat]) do
      text = text..key.." = "..value.."\n"
    end
    return text
  end 
  local value = _values[chat][value_name]
  if ( value == nil) then
    return "Can't find "..value_name
  end
  return value_name.." = "..value
end

function run(msg, matches)
  local chat_id = tostring(msg.to.id)
  if matches[1] == "!get" then
    return get_value(chat_id, nil)
  end  
   return get_value(chat_id, matches[1])
end

function lex(msg, text)
  local chat_id = tostring(msg.to.id)
  local s, e = text:find("%$%a+")
  if (s == nil) then 
    return nil
  end
  local var = text:sub(s + 1, e)
  local value = fetch_value(chat_id, var)
  if (value == nil) then
    value = "(unknown value " .. var .. ")"
  end
  return text:sub(0, s - 1) .. value .. text:sub(e + 1)
end

return {
    description = "retrieves variables saved with !set", 
    usage = "!get (value_name)",
    patterns = {
      "^!get (%a+)$",
      "^!get$"}, 
    run = run,
    lex = lex
}

