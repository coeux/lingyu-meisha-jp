--fightEffectManager.lua
--========================================================================
--战斗场景特效管理

FightEffectManager =
{
  effects = {}; -- 场景特效
};

local effect = {};
local inE;
--
-- 特效动作必须!!! keep, disappear 动作, inAction 进入场景立刻发生的动作
--
--初始化
function FightEffectManager:Initialize()
  effect = {};

  --获取场景特效种类
  local effect_ids = resTableManager:GetValue(ResTable.barriers, tostring(FightManager.barrierId), 'effect_ids');
  if not effect_ids then return end;

  --获取本场景中的所有动画特效相关数值
  for _, id in pairs(effect_ids) do
    local data = resTableManager:GetRowValue(ResTable.barrier_effect, tostring(id));
    local e = {id = data['id'], x = data['x'], y = data['y'], zorder = data['zorder'], radius = data['radius'], armature = data['armature'], inAction = (data['switch_id'] == -1 and true or false)};
    e.hp, e.scale, e.next_mov = 0, 1, 0;
    if not e.inAction then
      data = resTableManager:GetRowValue(ResTable.barrier_effect_switch, tostring(data['switch_id'])); -- 默认keep特效的数值
      e.hp, e.scale, e.next_mov = data['hp'], data['scale'], data['next_mov'];
    end
    table.insert(effect, e);
  end
  inE = false;
end

--加载场景特效(只加载一次)
function FightEffectManager:loadEnvEffect()
  if inE then return end; 
  inE = true;
  for _, v in pairs(effect) do
    self:createEnvEffect(v);
  end
end

--创建场景特效
function FightEffectManager:createEnvEffect(effectData)
  local e = Armature(sceneManager:CreateSceneNode('Armature'));

  e.x = effectData.x;
  e.hp = effectData.hp;
  e.scale = effectData.scale;
  e.radius = effectData.radius;
  e.next_mov = effectData.next_mov;
  e.inAction = effectData.inAction;

  e.Translate = Vector3(effectData.x, effectData.y, 0);
	e.ZOrder = effectData.zorder;
  e:LoadArmature(effectData.armature);
  if not e.inAction then
    e:SetAnimation('keep');
  else
    e:SetAnimation('inAction');
  end
  e:SetScriptAnimationCallback('FightEffectManager:EnvEffectCallBack', effectData.id);
  e:SetScale(effectData.scale, effectData.scale, 1);

  local scene = SceneManager:GetActiveScene();
  scene:GetRootCppObject():AddChild(e);
  scene:GetRootCppObject():SortChildren();
  self.effects[effectData.id] = e;
end

--回调
function FightEffectManager:EnvEffectCallBack(e, _index)
  if e:IsCurAnimationLoop() then
    --循环动作
    e:Replay();
    return;
  end
  sceneManager:AddAutoReleaseNode(e);
end

--特效更新
function FightEffectManager:UpdateEnvEffect(curAttacker)
  if curAttacker == nil or curAttacker.m_isEnemy then return end;

  for _, e in pairs(self.effects) do
    --判断特效点距离人物的距离是否满足特效受到伤害的范围
    if not e.inAction and e.radius >= math.abs(math.floor(e.x - curAttacker:GetPosition().x)) then
      if e.hp >= 0 then
        e.hp = e.hp - 1;
      elseif e.next_mov ~= -1 then
        local data = resTableManager:GetRowValue(ResTable.barrier_effect_switch, tostring(e.next_mov));
        e.hp = data['hp'];
        e.scale = data['scale'];
        e:SetScale(e.scale, e.scale, 1);
        e:SetAnimation(tostring(data['mov_name']));
      else
        e:SetAnimation("disappear");
      end
    end
  end
end
--[[
如何为关卡添加特效：
1.在关卡表（例如：round.txt表），effect_ids填round_effect.txt中特效id，其他关卡表类似。
2.特效输出时必须有keep,disappear两个mov name,若有立场立即发生的动作，如：破门而入需添加inAction的mov。
3.特效在程序中在加载，策划需要在round_effect.txt中的armature字段添加特效名称，该名称为skeleton.xml中的<skeleton name=所跟随的名称。
4.round_effect.txt中switch_id字段若为-1则表明是入场后立刻发生的特效，发生且仅发生一次。动作必须 keep, inAction, disappear。 无需再填round_effect_switch.txt
5.若switch_id字段不为-1则程序根据该id去round_effect_switch.txt表中查找入场后发生的特效动作。
5.1. 每一个从round_effect表进入该表的特效都必须添加一条记录，该记录mov_name可为空(策划直接填keep，以免搞混)，默认为keep动作，当该动作hp（被攻击次数）降为0时根据next_mov字段切换动画特效。也就是说keep动作不能什么都没有，并且当且仅当keep动作hp为0时才会切换到下一个状态。
5.2. 场景中着火，下雪，落树叶（非粒子特效，被策划定义为场景特效的）通常只需要keep,disappear就够了，其中keep是默认状态，如：着火。

如何用好以上功能就看策划和做特效的人了。

PS: 特效Zorder做功能时已和策划定过，git可查看log，（这个的层级优先级事先和策划已商量过）
PPS: 做功能的时候策划不记录 那我只好再看遍代码然后把填写规则写在这儿了。
PPSS: 特效zorder已经放到表中
--]]
