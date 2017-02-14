--networkMsg_Bullet.lua

--======================================================================
--弹幕

NetworkMsg_Bullet =
{
};

--请求所有弹幕
function NetworkMsg_Bullet:requestBullets(round)
  local t = {}
  t.round = round
  Network:Send(NetworkCmdType.req_bullets, t, true);
end

--收到所有弹幕
function NetworkMsg_Bullet:retBullets(json)
  if not FightManager.isPanelInit then
    return;
  end

  BulletScreenManager:onReceiveBullets(json)
end

--请求发送弹幕
function NetworkMsg_Bullet:requestSendBullet(msg, pos, round)
  local t = {};
  t.msg = msg;
  t.pos = pos;
  t.round = round;
  Network:Send(NetworkCmdType.req_send_bullet, t, true);
end

--发送弹幕返回结果
function NetworkMsg_Bullet:retSendBullet(json)
  --什么都不做
  if not FightManager.isPanelInit then
    return;
  end

  BulletScreenManager:retSendBullet(json)
end
