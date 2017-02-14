--bulletScreenManager.lua

--========================================================================
--战斗UI管理者类


BulletScreenManager = 
{
  bulletLabels = {},
  curBullets = {},
  allBullets = nil,
  desktop = nil,
  isRunning = false,
  isEnabled = true,
};

BulletLabelState = 
{
  Idle = 0,
  Running = 1,
}


--初始化
function BulletScreenManager:Initialize(desktop)

  --TODO: 这个值需要在数据库中读取
  --self.isEnabled = loadFromDatabase()


  math.randomseed(os.time())
  self.desktop = desktop;
  local bulletsPanel = self.desktop:GetLogicChild('bulletsPanel');

  --获取5个弹幕控件
  for i = 1, 5, 1 do
    local lbBullet = bulletsPanel:GetLogicChild('bullet' .. i );
    lbBullet.state = BulletLabelState.Idle;
    lbBullet:SetTranslateX ( math.random(0, 960) );
    table.insert(self.bulletLabels, lbBullet);
  end

  --每次进入都先设置成不播放
  self.isRunning = false;

  --请求所有弹幕
  local round = 5;
  NetworkMsg_Bullet:requestBullets(round);

end

--更新函数
function BulletScreenManager:Update(elapse)

  local sceneCamera = FightManager.scene:GetCamera();
  local width = FightManager.scene.width;
  local uiCamera = self.desktop.Camera;
  local scenePosition = UIToScenePT(uiCamera, sceneCamera, Vector2(480, 320));

  if not self.isRunning then
    return
  end



  --提取所有活动中的弹幕（没有内容的就在屏幕外面放着即可）
  local active_labels = __.select(self.bulletLabels, function(v) 
    return v.state == BulletLabelState.Running; 
  end);

  --设置位置
  __.each(active_labels, function(lbBullet)
    --当前位置
    local pos = lbBullet.Translate;
    local new_x = pos.x - 200 * elapse;
    lbBullet.Translate = Vector2(pos.x - 200 * elapse, pos.y);
    if new_x < 0-lbBullet.Width then
      lbBullet.Translate = Vector2(1150, pos.y)
      lbBullet.state = BulletLabelState.Idle;
    end
  end)

  --设置文本
  for i, lbBullet in ipairs(self.bulletLabels) do 
    if lbBullet.state == BulletLabelState.Running then
      break
    end
    local msg = self:getOneBullet()
    --可能没有弹幕了，需要判断是否为nil
    if msg then
      lbBullet.Text = msg .. "[" ..math.floor(lbBullet.Translate.x) .. "]";
      lbBullet.length = uiSystem:FindFont('huakang_20'):GetTextExtent(lbBullet.Text, 1.0);
      lbBullet.Width = lbBullet.length + 10;
      lbBullet.state = BulletLabelState.Running;
    end
  end
end

--接收弹幕回调函数
function BulletScreenManager:onReceiveBullets(json)
  self.allBullets = {};
  --以pos作为key，放到本地待用

  __.each(json.bullets, function(v)
    if not self.allBullets[v.pos] then
      self.allBullets[v.pos] = {};
    end
    table.insert(self.allBullets[v.pos], v);
  end)
  self.isRunning = true;
end

--获取下一条有效的弹幕
function BulletScreenManager:getOneBullet()
  local bulletMsg = nil;

  local pos = 3;
  local bulletList = self.allBullets[pos];
  if bulletList and #bulletList > 0 then
    bulletMsg = bulletList[1].msg;
    table.remove(bulletList, 1);
  end
  return bulletMsg;
end

--外部设置弹幕系统是否生效
function BulletScreenManager:setEnable(enable)
  --如果设置没有改变，直接返回
  if enable == self.isEnabled then
    return
  end
  self.isEnabled = enable;

  --设置弹幕系统是否可用
  local visible = enable and Visibility.Visible or Visibility.Hidden; -- enable ? true : false

  for i, lbBullet in ipairs(self.bulletLabels) do
    lbBullet.Visibility = visible;
  end
end

--外部获取弹幕系统是否生效
function BulletScreenManager:getEnable()
  return self.isEnabled;
end

function BulletScreenManager:SendBullet()
  local bulletsPanel = self.desktop:GetLogicChild('bulletsPanel');
  local bulletMsg = bulletsPanel:GetLogicChild('bulletMsg');
  local text = bulletMsg.Text;

  local pos = 3;
  local round = 5;
  NetworkMsg_Bullet:requestSendBullet(text, pos, round);
end

function BulletScreenManager:retSendBullet(json)
  print_r(json)
end
