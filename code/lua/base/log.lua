--log.lua
Log = class()

function Log:constructor()
  self.content = {};
  self.max_size = 25; -- default = 25条记录
end

function Log:clear()
  self.content = {};
end

function Log:set_max_size(i)
  if i < self.max_size then
    self:clear()
  end
  self.max_size = i
end

function Log:push_back(msg)
  if #self.content == self.max_size then
    table.remove(self.content, 1)
  end
  table.insert(self.content, tostring(os.clock()) .. ":" ..  msg)
end

function Log:to_s()
  local res = "";
  for _, s in ipairs(self.content) do
    res = res .. s .. "\n"
  end
	print(res)
  return res
end

Logger = Log.new()


