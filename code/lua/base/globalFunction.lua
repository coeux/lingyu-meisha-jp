--globalFunction.lua

--========================================================================
--全局函数
function CheckDiv(number)
   --print(number);
   if (number == (1/0)) then
      local uidStr = "UID: " .. tostring(ActorManager.user_data.uid);
      Debug.report(uidStr .. " Div by 0\n" .. debug.traceback());
   end

   return number;
end

--加载lua文件
function LoadLuaFile(fileName)
  appFramework:DoScriptFile(fileName);
end

--字符串的分隔功能
string.split = function(s, p)
  local rt= {}
  string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
  return rt
end

--克隆对象
function clone(object)

  local lookup_table = {}
  local function _copy(object)

    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end

    local new_table = {}
    lookup_table[object] = new_table
    for key, value in pairs(object) do
      new_table[_copy(key)] = _copy(value)
    end

    return setmetatable(new_table, getmetatable(object))

  end

  return _copy(object)

end

--序列化表
function serialize(t)
  local mark={}
  local assign={}

  local function ser_table(tbl,parent)
    mark[tbl]=parent
    local tmp={}
    for k,v in pairs(tbl) do
      local key= type(k)=="number" and "["..k.."]" or k
      if type(v)=="table" then
        local dotkey= parent..(type(k)=="number" and key or "."..key)
        if mark[v] then
          table.insert(assign,dotkey.."="..mark[v])
        else
          table.insert(tmp, key.."="..ser_table(v,dotkey))
        end
      else
        table.insert(tmp, key.."="..v)
      end
    end
    return "{"..table.concat(tmp,",").."}"
  end

  return ser_table(t,"ret")..table.concat(assign," ")
end


--========================================================================
--游戏相关

--计算
function Convert2Vector3( Pos )
  return Vector3(Pos, 0);
end

--转换到ZOrder
function Convert2ZOrder( y )
  return -y + GlobalData.MainSceneLogicHeightHalf;
end


--分解以下划线分隔的字符串
function separateUnderLineString(str)
  local list = {};
  while true do
    local index = string.find(str, "_");
    if nil ~= index then
      local item = string.sub(str, 1, index - 1);
      str = string.sub(str, index + 1, -1);
      table.insert(list, item);
    else
      table.insert(list, str);
      break;
    end
  end
  return list;
end

--分解以逗号分隔的字符串
function separateConfig(configure)
  local list = {};
  while true do
    local index = string.find(configure, ",");
    if nil ~= index then
      local item = string.sub(configure, 1, index - 1);
      configure = string.sub(configure, index + 1, -1);
      table.insert(list, item);
    else
      table.insert(list, configure);
      break;
    end
  end
  return list;
end

function print_r(t, name)
    local pr = function(t, name, indent)
        local tableList = {}
        function table_r (t, name, indent, full)
            local id = not full and name or type(name)~="number" and tostring(name) or '['..name..']'
            local tag = indent .. id .. ' = '
            local out = {}  -- result
            if type(t) == "table" then
                if tableList[t] ~= nil then
                    table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
                else
                    tableList[t]= full and (full .. '.' .. id) or id
                    if next(t) then -- Table not empty
                        table.insert(out, tag .. '{')
                        for key,value in pairs(t) do
                            table.insert(out,table_r(value,key,indent .. '|  ',tableList[t]))
                        end
                        table.insert(out,indent .. '}')
                    else table.insert(out,tag .. '{}') end
                end
            else
                local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
                table.insert(out, tag .. val)
            end
            return table.concat(out, '\n')
        end
        return table_r(t,name or 'Value',indent or '')
    end
    print(pr(t,name))
end

--打印表数据
function printTable(t,name)
    name = name or "DEFAULT"
    if type(t) ~= "table" then 
        print(name.." is not a table value")
        return
    end 
    print("-------------TABLE:"..name)
    local count = 0
    local format_str = ""
    local setFormatStr = function()
        local i
        format_str = "" 
        for i = 0,count do
            format_str = format_str.."  "
        end 
    end
    function executePrint(t,name)
        setFormatStr()
        print(format_str.."{")
        count = count + 1
        setFormatStr()
        local k,v
        for k,v in pairs(t) do 
            if type(v) == "table" then 
                print(format_str.."["..k.."] = :")
                executePrint(v)
            elseif type(v) == "string" then 
                print(format_str.."["..k.."] = \""..v.."\"")
            elseif type(v) == "userdata" then 
                print(format_str.."["..k.."] = userdata")
            elseif type(v) == "number" then 
                print(format_str.."["..k.."] = "..v)
            elseif type(v) == nil then 
                print(format_str.."["..k.."] = nil ------------------------") 
            elseif type(v) == "boolean" then
              if v then
                print(format_str.."["..k.."] = TRUE")
              else
                print(format_str.."["..k.."] = FALSE")
              end
            else
                print("a unknow type.")  
            end  
        end 
        count = count - 1
        setFormatStr()
        print(format_str.."}")
    end 
    
    executePrint(t)
    print("-------------TABLE_END:"..name)  
end


--获取图标
function GetIcon( iconName )
  local name = 'icon/' .. iconName .. '.ccz';
  local icon = uiSystem:FindImage(name);
  if icon == nil then
    icon = uiSystem:CreateFileImage( name, name, Rect(0, 0, 100, 100) );
    icon:Load();
  end

  return icon;
end

function FixCCZPath(path)
  --Debug.assert(false, path);
  local cczPath = string.gsub(path, ".png", ".ccz");
  local pngPath = string.gsub(path, ".ccz", ".png");

  local realPath = path
  if OperationSystem.IsPathExist(GlobalData.UIPath .. cczPath) then
    realPath = cczPath
  elseif OperationSystem.IsPathExist(GlobalData.UIPath .. pngPath) then
    realPath = pngPath
  else
    --Debug.assert(false, "file not found: " .. path);
  end
  return realPath
end

_G["fileImageMap"] = {}
local old_createFileImage = uiSystem.CreateFileImage;
uiSystem.CreateFileImage = function(uiSystem, path, ...)

  if _G["fileImageMap"][path] then
    _G["fileImageMap"][path] = _G["fileImageMap"][path] + 1;
  else
    _G["fileImageMap"][path] = 1;
  end
  local pictureImage = old_createFileImage(uiSystem, path, ...);
  return pictureImage
end

--获取指定图片
function GetPicture(path, area)
  path = FixCCZPath(path)

  local picture = uiSystem:FindImage(path);
  if picture == nil then
    if area ~= nil then
      picture = uiSystem:CreateFileImage(path, path, area);
      picture:Load();
    else
      --零散文件一定是同步加载
      local asyncLoadFlag = renderer.AsyncLoadFlag;
      renderer.AsyncLoadFlag = false;

      picture  = uiSystem:CreateFileImage(path, path);
      picture:Load();

      renderer.AsyncLoadFlag = asyncLoadFlag;
    end
  end
  return picture;
end

--根据图片创建普通纹理刷
function CreateTextureBrush(picPath, groupName, area)

  picPath = FixCCZPath(picPath)

  local skillPicBrush = uiSystem:FindResource(picPath, groupName);
  if skillPicBrush == nil then
    local image = uiSystem:FindImage(picPath);
    if image == nil then
      if area ~= nil then
        uiSystem:CreateFileImage(picPath, picPath, area);
      else
        uiSystem:CreateFileImage(picPath, picPath);
      end
    end

    skillPicBrush = uiSystem:CreateTextureBrush(groupName, picPath, picPath);

    local asyncLoadFlag = renderer.AsyncLoadFlag;
    if area == nil then
      renderer.AsyncLoadFlag = false;
    end

    skillPicBrush:Load();

    renderer.AsyncLoadFlag = asyncLoadFlag;
  end
  return skillPicBrush;
end

--根据图片创建裁剪纹理刷
function CreateClipTextureBrush(picPath, groupName, stepOrientation)

  picPath = FixCCZPath(picPath)

  local skillPicBrush = uiSystem:FindResource(picPath, groupName);
  if skillPicBrush == nil then
    --零散文件一定是同步加载
    local asyncLoadFlag = renderer.AsyncLoadFlag;
    renderer.AsyncLoadFlag = false;

    uiSystem:CreateFileImage(picPath, picPath);
    skillPicBrush = uiSystem:CreateClipTextureBrush(groupName, picPath, picPath, stepOrientation);
    skillPicBrush:Load();

    renderer.AsyncLoadFlag = asyncLoadFlag;
  end

  return skillPicBrush;
end

--根据图片创建中间拉伸纹理刷
function CreateCenterStretchBrush(picPath, groupName, width, tailer)

  picPath = FixCCZPath(picPath)

  local picBrush = uiSystem:FindResource(picPath, groupName);
  if pic == nil then
    --零散文件一定是同步加载
    local asyncLoadFlag = renderer.AsyncLoadFlag;
    renderer.AsyncLoadFlag = false;

    uiSystem:CreateFileImage(picPath, picPath);
    picBrush = uiSystem:CreateCenterStretchBrush(groupName, picPath, picPath, width, tailer);
    picBrush:Load();

    renderer.AsyncLoadFlag = asyncLoadFlag;
  end

  return picBrush;
end

local old_destroyImage = uiSystem.DestroyImage;
uiSystem.DestroyImage = function(uiSystem, path, ...)
  if _G["fileImageMap"][path] and _G["fileImageMap"][path] > 1 then
    _G["fileImageMap"][path] = _G["fileImageMap"][path] - 1;
  elseif _G["fileImageMap"][path] == 1 then
    --old_DestroyImage( path, ... )
    _G["fileImageMap"][path] = nil;
    uiSystem:DestroyImage(path);
  elseif not _G["fileImageMap"][path] then
    Debug.assert("[DestroyImage error]");
    return
  end
end


--销毁刷子和图片（！！！相应的图片也会销毁，逻辑确保没有使用者！！！）
function DestroyBrushAndImage( picPath, groupName )
  uiSystem:DestroyResource(picPath, groupName);
  uiSystem:DestroyImage(picPath);
end

--将场景坐标转换成ui坐标
function SceneToUiPT(sceneCamera, uiCamera, position)

  local screenPosition = sceneCamera:WorldToScreenPT(position);
  local uiPosition = uiCamera:ScreenToWorldPT(screenPosition);
  return uiPosition;

end

--将UI坐标转化成场景坐标
function UIToScenePT(uiCamera, sceneCamera, uiPosition)
  local screenPosition = uiCamera:WorldToScreenPT(Vector3(uiPosition.x, uiPosition.y, 0));
  local origin = Vector3();
  local dir = Vector3();
  sceneCamera:ScreenPTToRay(screenPosition.x, screenPosition.y, origin, dir);
  return Vector3(math.floor(origin.x), math.floor(origin.y), 0);
end

function RectContainLine(point1, point2, rect)
  if nil == point1 or nil == point2 then
    return false;
  end

  local lineHeight = point1.y - point2.y;
  local lineWidth = point2.x - point1.x;  --计算叉乘
  local c = point1.x * point2.y - point2.x * point1.y;

  if (lineHeight * rect.Left + lineWidth * rect.Top + c >= 0 and lineHeight * rect.Right + lineWidth * rect.Bottom + c <= 0)
    or (lineHeight * rect.Left + lineWidth * rect.Top + c <= 0 and lineHeight * rect.Right + lineWidth * rect.Bottom + c >= 0)
    or (lineHeight * rect.Left + lineWidth * rect.Bottom + c >= 0 and lineHeight * rect.Right + lineWidth * rect.Top + c <= 0)
    or (lineHeight * rect.Left + lineWidth * rect.Bottom + c <= 0 and lineHeight * rect.Right + lineWidth * rect.Top + c >= 0) then
    if rect.Left > rect.Right then
      local temp = rect.Left;
      rect.Left = rect.Right;
      rect.Right = temp;
    end
    if rect.Top < rect.Bottom then
      local temp1 = rect.Top;
      rect.Top = rect.Bottom;
      rect.Bottom = temp1;
    end
    if (point1.x < rect.Left and point2.x < rect.Left)
      or (point1.x > rect.Right and point2.x > rect.Right)
      or (point1.y > rect.Top and point2.y > rect.Top)
      or (point1.y < rect.Bottom and point2.y < rect.Bottom) then
      return false;
    else
      return true;
    end
  else
    return false;
  end
end

--转换到时、分、秒
function Time2HourMinSec( time )

  local hour = math.floor(time / 3600);
  time = time - hour * 3600;
  local min = math.floor(time / 60);
  local sec = math.floor(time - min * 60);

  return hour, min, sec;
end

--按格式00:00转化时间
function Time2MinSecStr( time )

  local hour, min, sec = Time2HourMinSec(time);
  local str = '';
  if min < 10 then
    str = str .. '0' .. min;
  else
    str = str .. min;
  end
  str = str .. ':';
  if sec < 10 then
    str = str .. '0' .. sec;
  else
    str = str .. sec;
  end
  return str;
end

--按格式00：00转化（小时：分钟）
function Time2HMStr(time)
  local hour, min = Time2HourMinSec(time);
  local str = '' .. hour .. LANG_globalFunction_1;
  if min < 10 then
    str = str .. '0' .. min;
  else
    str = str .. min;
  end
  str = str .. LANG_globalFunction_2;
  return str;
end

--按格式00：00转化（小时：分钟）
function Time2HMStr2(time)
  local hour, min = Time2HourMinSec(time);
  local str = '' .. hour .. ':';
  if min < 10 then
    str = str .. '0' .. min;
  else
    str = str .. min;
  end
  return str;
end

--按格式00:00:00转化时间
function Time2HMSStr( time )

  local hour, min, sec = Time2HourMinSec(time);
  local str = '';
  if hour < 10 then
    str = str .. '0' .. hour;
  else
    str = str .. hour;
  end
  str = str .. ':';
  if min < 10 then
    str = str .. '0' .. min;
  else
    str = str .. min;
  end
  str = str .. ':';
  if sec < 10 then
    str = str .. '0' .. sec;
  else
    str = str .. sec;
  end
  return str;
end

--Kim Larsson caculation formula(获取某年某月某日为星期几)
function KimLarssonYearMonthDay(y, m, d)
  if m == 1 or m == 2 then m = m + 12; y = y - 1; end; -- 1月2月看做去年13,14月
  return (d + 2*m + math.floor(3*(m+1)/5) + y + math.floor(y/4) - math.floor(y/100) + math.floor(y/400) + 1) % 7;
end
--
function KimLarssonYearMonth(y, m)
  if m == 1 or m == 2 then m = m + 12; y = y - 1; end;
  return (2*m + math.floor(3*(m+1)/5) + y + math.floor(y/4) - math.floor(y/100) + math.floor(y/400) + 1) % 7;
end
--

--创建技能升级等特效
function PlayEffect(output, rect, armatureName, parentUIControl)
  --效果表现
  local path = GlobalData.EffectPath .. output;
  AvatarManager:LoadFile(path);
  local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
  armatureUI.Pick = false;
  armatureUI.Margin = rect;
  armatureUI.Horizontal = ControlLayout.H_CENTER;
  armatureUI.Vertical = ControlLayout.V_CENTER;
  armatureUI:LoadArmature(armatureName);
  armatureUI:SetAnimation('play');
  if (parentUIControl == nil) then
    topDesktop:AddChild(armatureUI);
  else
    parentUIControl:AddChild(armatureUI);
  end

  return armatureUI;
end

--创建技能升级等特效（参考坐标为左上角）
function PlayEffectLT(output, rect, armatureName)
  --效果表现
  local path = GlobalData.EffectPath .. output;
  AvatarManager:LoadFile(path);
  local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
  armatureUI.Pick = false;
  armatureUI.Margin = rect;
  armatureUI.Horizontal = ControlLayout.H_LEFT;
  armatureUI.Vertical = ControlLayout.V_TOP;
  armatureUI:LoadArmature(armatureName);
  armatureUI:SetAnimation('play');
  topDesktop:AddChild(armatureUI);

  return armatureUI;
end

--创建技能升级等特效（可放大）
function PlayEffectScale(output, rect, armatureName, sx, sy, parentUIControl)
  --效果表现
  local path = GlobalData.EffectPath .. output;
  AvatarManager:LoadFile(path);
  local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
  armatureUI.Pick = false;
  armatureUI.Margin = rect;
  armatureUI.Horizontal = ControlLayout.H_CENTER;
  armatureUI.Vertical = ControlLayout.V_CENTER;
  armatureUI:LoadArmature(armatureName);
  armatureUI:SetScale(sx, sy);
  armatureUI:SetAnimation('play');
  if (parentUIControl == nil) then
    topDesktop:AddChild(armatureUI);
  else
    parentUIControl:AddChild(armatureUI);
  end

  return armatureUI;
end

--创建金币浮动特效
function CreateFloatMoneyEffect(money, bottom, right)
  return CreateGeneralEffect(1, money, bottom, right);
end

--创建炼金浮动特效
function CreateGoldMoneyEffect(money, bottom, right)
  return CreateGeneralEffect(2, money, bottom, right);
end

--创建体力浮动特效
function CreateGeneralEffect(effectType, money, bottom, right)
  local floatMoneyEffect = uiSystem:CreateControl('Label');
  floatMoneyEffect.Margin = Rect(0, 0, bottom, right);
  floatMoneyEffect.Size = Size(500, 40);
  floatMoneyEffect.TextAlignStyle = TextFormat.MiddleCenter;
  floatMoneyEffect.Horizontal = ControlLayout.H_CENTER;
  floatMoneyEffect.Vertical = ControlLayout.V_CENTER;
  floatMoneyEffect.Font = uiSystem:FindFont('huakang_20');
  floatMoneyEffect.Pick = false;

  floatMoneyEffect.Visibility = Visibility.Visible;
  floatMoneyEffect.Storyboard = '';
  if effectType == 1 then
    floatMoneyEffect.Text = LANG_globalFunction_3 .. money;
    floatMoneyEffect.Storyboard = 'storyboard.floatTrialUp';
  elseif effectType == 2 then
    floatMoneyEffect.Text = LANG_globalFunction_4 .. money;
    floatMoneyEffect.Storyboard = 'storyboard.floatGoldUp';
  end

  return floatMoneyEffect;
end

--创建浮动特效
function CreateaddPowerEffect(typeid)
  local floatPowerEffect = uiSystem:CreateControl('Label');
  floatPowerEffect.Size = Size(500, 40);
  floatPowerEffect.TextAlignStyle = TextFormat.MiddleCenter;
  floatPowerEffect.Horizontal = ControlLayout.H_CENTER;
  floatPowerEffect.Vertical = ControlLayout.V_CENTER;
  floatPowerEffect.Font = uiSystem:FindFont('huakang_20');
  floatPowerEffect.Pick = false;

  floatPowerEffect.Visibility = Visibility.Visible;
  floatPowerEffect.Storyboard = '';
  if typeid == 1 then
    floatPowerEffect.Text = LANG_buyPower_1 .. 60;
    floatPowerEffect.Margin = Rect(0, 0, 0, 80);
  else
    floatPowerEffect.Margin = Rect(0, 0, 375, 80);
    floatPowerEffect.Text = LANG_buyPower_2 .. 60;
  end
  floatPowerEffect.Storyboard = 'storyboard.floatGoldUp';
  return floatPowerEffect;
end

--判断表是否为空
function TableIsEmpty(t)
    return next( t ) == nil;
end

--排序伙伴
function sortPartner( partner1, partner2 )
  if (partner1.teamIndex ~= -1) and (partner2.teamIndex ~= -1) then
    return partner1.teamIndex < partner2.teamIndex;
  end

  if (partner1.teamIndex ~= -1) or (partner2.teamIndex ~= -1) then
    return partner1.teamIndex > partner2.teamIndex;
  end

  if (partner1.fellowIndex ~= -1) and (partner2.fellowIndex ~= -1) then
    return partner1.fellowIndex < partner2.fellowIndex;
  end

  if (partner1.fellowIndex ~= -1) or (partner2.fellowIndex ~= -1) then
    return partner1.fellowIndex > partner2.fellowIndex;
  end

  if partner1.lvl.level ~= partner2.lvl.level then
    return partner1.lvl.level > partner2.lvl.level;
  end

  if partner1.rare ~= partner2.rare then
    return partner1.rare > partner2.rare;
  end

  return partner1.pid < partner2.pid;
end

function WriteFile(text)
  local file = io.open("fight.txt", "w");
  file:write(text);
  file:close();
end

function ReadFile()
  local file = io.open("fight.txt", "r")
  local str = file:read("*all")
  file:close();
  return str;
end

--验证场景坐标
function VerifyScenePos( sceneType, x, y )
  if sceneType == SceneType.Union then
    if y > GlobalData.UnionSceneMaxY then
      y = GlobalData.UnionSceneMaxY;
    end
  elseif sceneType == SceneType.Scuffle then
	  if y > -140 then
		y = -140;
      end
  elseif sceneType == SceneType.UnionBoss then
    if y > GlobalData.UnionSceneMaxY then
      y = GlobalData.UnionSceneMaxY;
    end
  else
    -- if y > GlobalData.MainSceneMaxY then
    --   y = GlobalData.MainSceneMaxY;
    -- end
    if y < GlobalData.MainSceneMinY then
      y=GlobalData.MainSceneMinY;
    elseif y > GlobalData.MainSceneMaxY then
      y=GlobalData.MainSceneMaxY;
    end

    if x < GlobalData.MainSceneMinX then
      x = GlobalData.MainSceneMinX;
    elseif x > GlobalData.MainSceneMaxX then
      x = GlobalData.MainSceneMaxX;
    end


  end
  return x,y;
end

--给角色UI armature添加翅膀
function AddWingsToUIActor(armature, wingResid)
	local wingType = resTableManager:GetValue(ResTable.wing, tostring(wingResid), 'type') or 23000;
	if wingType == nil then
		print('error! no such wing type, resid = ' .. wingResid);
		return;
	end
	armature:DetachAllEffect();
	if WingType.w1_101 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_halo');
	elseif WingType.w1_201 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_halo');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_head_right_1');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_head_left_1');
	elseif WingType.w1_301 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_halo');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_head_right_1');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_head_left_1');
		AttachWingToAvatar(armature, AvatarPos.right_up_wing, 'wing01_up_right_1');
		AttachWingToAvatar(armature, AvatarPos.left_up_wing, 'wing01_up_left_1');
	elseif WingType.w1_401 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_halo');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_head_right_1');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_head_left_1');
		AttachWingToAvatar(armature, AvatarPos.right_up_wing, 'wing01_up_right_2');
		AttachWingToAvatar(armature, AvatarPos.left_up_wing, 'wing01_up_left_2');
		AttachWingToAvatar(armature, AvatarPos.right_down_wing, 'wing01_down_right_2');
		AttachWingToAvatar(armature, AvatarPos.left_down_wing, 'wing01_down_left_2');
	elseif WingType.w1_501 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_halo');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_head_right_2');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_head_left_2');
		AttachWingToAvatar(armature, AvatarPos.right_up_wing, 'wing01_up_right_3');
		AttachWingToAvatar(armature, AvatarPos.left_up_wing, 'wing01_up_left_3');
		AttachWingToAvatar(armature, AvatarPos.right_down_wing, 'wing01_down_right_texiao');
		AttachWingToAvatar(armature, AvatarPos.left_down_wing, 'wing01_down_left_texiao');
		AttachWingToAvatar(armature, AvatarPos.right_down_wing, 'wing01_down_right_3');
		AttachWingToAvatar(armature, AvatarPos.left_down_wing, 'wing01_down_left_3');
	elseif WingType.w1_601 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_halo');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_head_right_5');
		AttachWingToAvatar(armature, AvatarPos.head_wing, 'wing01_head_left_5');
		AttachWingToAvatar(armature, AvatarPos.right_up_wing, 'wing01_up_right_5');
		AttachWingToAvatar(armature, AvatarPos.left_up_wing, 'wing01_up_left_5');
		AttachWingToAvatar(armature, AvatarPos.right_down_wing, 'wing01_down_right_texiao');
		AttachWingToAvatar(armature, AvatarPos.left_down_wing, 'wing01_down_left_texiao');
		if wingResid == 23055 then
			AttachWingToAvatar(armature, AvatarPos.right_down_wing, 'wing01_right_texiao_1');
			AttachWingToAvatar(armature, AvatarPos.left_down_wing, 'wing01_left_texiao_1');
		end
		AttachWingToAvatar(armature, AvatarPos.right_down_wing, 'wing01_down_right_4');
		AttachWingToAvatar(armature, AvatarPos.left_down_wing, 'wing01_down_left_4');
		if wingResid == 23055 then
			AttachWingToAvatar(armature, AvatarPos.right_up_wing, 'wing01_right_texiao_2');
			AttachWingToAvatar(armature, AvatarPos.left_up_wing, 'wing01_left_texiao_2');
		end
	end

end

--挂载某个翅膀
function AttachWingToAvatar(armature, avatarPos, avatarName)
  local wing = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
  wing:LoadArmature(avatarName);
  wing:SetAnimation('play');
  armature:AttachEffect(avatarPos, wing, true);

  return wing;
end

--字符串空判断
string.isNilOrTemp = function ( str )
  if str == nil or string.len(str) == 0 then
    return true;
  end

  return false;
end

--UI onSmall
function onSmall(Args)
  local args = UIControlEventArgs(Args);
  args.m_pControl:SetScale(0.95, 0.95);
end
--
--UI onBig
function onBig(Args)
  local args = UIControlEventArgs(Args);
  args.m_pControl:SetScale(1.05, 1.05);
end
--
--UI onRecover
function onRecover(Args)
  local args = UIControlEventArgs(Args);
  args.m_pControl:SetScale(1, 1);
end

--获取一个字符串多项式的值
function GetMathsValue(Args)
  --多项式检测
  --这里的算法感觉有点傻 有空改进，不过估计没空
  local legalChar = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '+', '-', '*', '/', '(', ')', '^'};
  local haveIllegalChar = false;
  for i=1, string.len(Args) do
    haveIllegalChar = false;
    local argsChar = string.sub(Args,i,i);
    local isMatch = false;
    for _, char in pairs(legalChar) do
      if string.byte(char) == string.byte(argsChar) then
        isMatch = true;
        break;
      end
    end
    if isMatch == false then
      haveIllegalChar = true;
      break;
    end
  end
  if haveIllegalChar == true then
    print('error! Multinomial: ' .. Args .. ' have illegal char.');
    return 0;
  end

  local fun = assert(loadstring('return ' .. Args));
  return fun();
end

--将一个大table分片成多个小数组，默认小数组大小为6
function table.split(t, span)
  local s = {};
  local r = {};
  span = span or 6;
  for i, v in ipairs(t) do
    table.insert(s, v);
    if i%span == 0 then table.insert(r, s); s = {}; end
  end
  if next(s) then table.insert(r, s); end
  return r;
end

-- lua table __newindex bind event (just table)
function listener(table, obj, func)
  if type(table) ~= 'table' then return table end
  local _t = table
  table = {}
  local mt = {
    __index = _t,
    __newindex = function(t, k, v)
      _t[k] = v;
      func(obj, k, v);
    end,
  }
  setmetatable(table, mt);
  for k, v in pairs(_t) do table[k] = v end
  return table
end

local overWriteRandom = math.random
math.random = function( ... )
  if FightType.noviceBattle == FightManager.mFightType then
    --math.randomseed(10)
    for i,v in ipairs{...} do
      if i == 1 then
        return v
      end
    end
  end
  return overWriteRandom(...)
end

function viplevelToImage(number, path)
  local img = uiSystem:CreateControl('ImageElement');
  img.Pick = false;
  img.Image = uiSystem:FindImage(path .. number);

  return img;
end

function VToImage(imgv)
  local imgVip = uiSystem:CreateControl('ImageElement');
  imgVip.Pick = false;

  if imgv == 101 then
    imgVip.Image = uiSystem:FindImage('vip_white_v');
  elseif imgv == 102 then
    imgVip.Image = uiSystem:FindImage('vip_black_v');
  elseif imgv == 103 then
    imgVip.Image = uiSystem:FindImage('vip_yellow_v');
  end

  return imgVip;
end

function vipToImage(viplevel)
  local vipLabel  = uiSystem:CreateControl('Label');
  vipLabel.Pick = false;
  vipLabel.Margin = Rect(0,0,0,0);
  local bg = 'godsSenki.vip_bg_red';
  if viplevel > 9 then
    -- bg = 'godsSenki.vip_bg_sliver';
    -- if viplevel > 13 then
      bg = 'godsSenki.vip_bg_gold';
    -- end
  end
  vipLabel.Background = Converter.String2Brush(bg);

  local imgbg = uiSystem:CreateControl('CombinedElement');
  imgbg.Horizontal = ControlLayout.H_CENTER;
  imgbg.Vertical = ControlLayout.V_CENTER;
  imgbg.Alignment = Alignment.Center;


  if viplevel > 9 then
    vipLabel.Size = Size(55,22);
    imgbg.Margin = Rect(0,1,0,0);
    local high = math.floor(viplevel/10);
    local low = viplevel - high*10;
    -- local str = 'vip_black_';
    -- local imgv = VToImage(102);
    -- local imgv2 = viplevelToImage(5, 'vip_black_');
    -- if viplevel > 13 then
      str = 'vip_yellow_';
      imgv = VToImage(103);
      imgv2 = viplevelToImage(5, 'vip_yellow_');
      imgv2.Translate = Vector2(-4,0);
      imgv.Translate = Vector2(-1,0);
    -- else
    --   -- imgv.Translate = Vector2(-1,0);
    --   imgv2.Translate = Vector2(-5,0);
    -- end
    imgv:SetScale(1.5,1.5);
    imgv2:SetScale(1.5,1.5);
    imgbg:AddChild(imgv2);
    imgbg:AddChild(imgv);

    local imghigh = viplevelToImage(high, str);
    imghigh:SetScale(1.5,1.5);
    imghigh.Translate = Vector2(2,0);
    imgbg:AddChild(imghigh);

    local imglow = viplevelToImage(low, str);
    imglow:SetScale(1.5,1.5);
    imglow.Translate = Vector2(4,0);
    imgbg:AddChild(imglow);

    -- if viplevel <= 13 then
    --   imghigh.Translate = Vector2(3,0);
    --   imglow.Translate = Vector2(6,0);
    -- end
  else
    vipLabel.Size = Size(30,18);
    imgbg.Margin = Rect(0,0,0,0);
    local imgv = VToImage(101);
    imgv:SetScale(1.5,1.5);
    imgv.Translate = Vector2(-3,0);
    imgbg:AddChild(imgv);
    local imglow = viplevelToImage(viplevel,'vip_white_');
    imglow:SetScale(1.5,1.5);
    imglow.Translate = Vector2(3,0);
    imgbg:AddChild(imglow);
  end
	imgbg:ForceLayout()
    vipLabel:AddChild(imgbg);
  return vipLabel;
end
function AppendDelayTriggerEvent(func, frameCount)
  if _G['cb_queue'] == nil then
    _G['cb_queue'] = {}
  end
  table.insert(_G['cb_queue'], {fun = func, count = frameCount} );
end

--=============================================================================================
