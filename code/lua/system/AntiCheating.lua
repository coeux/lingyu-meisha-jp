--AntiCheating.lua

AntiCheating =
  {
    propStr = nil;
    initialized = false;
    counter = 0;
  }


function AntiCheating:Serialize()
  if not ActorManager.user_data or not ActorManager.user_data.partners then
    return "";
  end

  local prop_str = ""
  local user_data = ActorManager.user_data
  --
  local count = 1 + #user_data.partners;
  local container = {};
  local max_resid = 0;
  for index = 1, count do
    local role = {};
    if 1 == index then
      role = user_data.role;
      role.name = ActorManager.user_data.name;
    else
      role = user_data.partners[index - 1];
    end

    local resid = role.resid;
    local pro = role.pro;

    local str = tostring(resid) .. ":";
    str = str .. tostring(pro.atk) .. "|";
    str = str .. tostring(pro.mgc) .. "|";
    str = str .. tostring(pro.hp) .. "|";
    str = str .. tostring(pro.def) .. "|";
    str = str .. tostring(pro.res) .. "|";
    str = str .. tostring(pro.cri) .. "|";
    str = str .. tostring(pro.acc) .. "|";
    str = str .. tostring(pro.dodge) .. "|";
    str = str .. tostring(pro.fp) .. "|";
    str = str .. tostring(pro.power) .. "|";
    container[resid] = str;
    if resid > max_resid then max_resid = resid end;
  end
  for index = 1, max_resid do
    if container[index] then
      prop_str = prop_str .. container[index] .. "#";
    end
  end
  return prop_str;
end

function AntiCheating:Init()
  self.initialized = true;
  self.propStr = self:Serialize();
end

function AntiCheating:AdjustRolePro()
  if not self.initialized then
    return;
  end

  self.propStr = self:Serialize();
end

function AntiCheating:Check()
  if self.propStr == nil then
    self.propStr = self:Serialize();
    return;
  end

  local str = self:Serialize();
  if self.propStr ~= str then
    Debug.report("god:\n   data: " .. str .. "\nolddata: " .. self.propStr);
    self:Punish(str);
    self.propStr = str;
  end

end

function AntiCheating:Update()
  if not self.initialized then
    return
  end
  self.counter = self.counter + 1;
  if self.counter > 10 then
    self.counter = 0;
    self:Check();
  end
end

function AntiCheating:Punish(str)
    --for hotfix
    appFramework:Terminate();
end
