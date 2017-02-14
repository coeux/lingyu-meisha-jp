--utf8.lua
utf8 = {}

utf8.chsize = function(char)
  if not char then
    return 0
  elseif char > 240 then
    return 4
  elseif char > 225 then
    return 3
  elseif char > 192 then
    return 2
  else
    return 1
  end
end

utf8.sub = function(str, startChar, numChars)
  local startIndex = 1
  while startChar > 1 do
    local char = string.byte(str, startIndex)
    startIndex = startIndex + utf8.chsize(char)
    startChar = startChar - 1
  end

  local currentIndex = startIndex

  while numChars > 0 and currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    currentIndex = currentIndex + utf8.chsize(char)
    numChars = numChars - 1
  end

  return str:sub(startIndex, currentIndex - 1)
end

---
-- @param utf8_str - string
-- @param length -- int - number of chars in line
utf8.wrap = function(utf8_str, length)

  local accum_str = ""

  local idx = 0

  local isFirstLine = true
  while true do
    local ret_str = utf8.sub(utf8_str, idx, length - 1)
    if #ret_str == 0 then
      break
    end

    if isFirstLine then
      idx = idx + length
      isFirstLine = false
    else
      idx = idx + length -1
    end

    if #accum_str == 0 then
      accum_str = accum_str .. ret_str
    else
      accum_str = accum_str .. "\n" .. ret_str
    end
  end

  return accum_str
end

utf8.len = function(str)
  local pos = 1
  local bytes = string.len(str)
  local len = 0

  while pos <= bytes do
    local c = string.byte(str, pos)
    len = len + 1

    pos = pos + utf8.chsize(c)
  end

  return len
end

--example.
--for char in utf8.each(str) do
--  syslog(char)
--end
utf8.each = function(str)
  str = str or ""
  --FIXME 
  return str:gmatch("([\1-\127\192-\255][\128-\191]*)")
end

-- 
utf8.getCharSize = function(text)
  local length = 0
  for char in utf8.each(text) do
    if utf8.chsize(string.byte(char)) == 1 then
      length = length + 0.5
    else
      length = length + 1
    end
  end
  length = math.ceil(length)

  return length
end
