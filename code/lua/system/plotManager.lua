--plotManager.lua

--========================================================================
--剧情管理类

PlotManager =
	{
		plotList		= {};				--剧情条件和函数映射
		MinChangeTime	= 0.1;				--最小渐变时间
		isPlay			= false;			--是否在播放剧情
	};

TriggerPlotTime =
{
	[1] = 5,  -- 进入之后N秒触发第一个剧情
	[2] = 0.6, -- 主角血掉到此百分比就触发第二个剧情
};

TriggerPlotID = 
{
	[1] = 000001,  -- 第1个触发的剧情id
	[2] = 000004,  -- 第2个触发的剧情id
	[3] = 000013,  -- 第3个触发的剧情id
	[4] = 000014,  -- 第4个触发的剧情id
	[5] = 000015,  -- 第5个触发的剧情id
	[6] = 000016,  -- 第6个触发的剧情id
	[7] = 000019,  -- 第7个触发的剧情id
	[8] = 000021,  -- 第8个触发的剧情id
	[9] = 000024,  -- 第9个触发的剧情id
	[10] = 000025,  -- 第10个触发的剧情id
	[11] = 000026,  -- 第11个触发的剧情id
	[12] = 000027,  -- 第12个触发的剧情id
};

NoviceBattleSkill = 
{
	[1] = 95,                   --  第一次怒气满时释放的技能ID
	[2] = 91,                   --  第二次怒气满时释放的技能ID
	[3] = 93,                   --  第三次怒气满时释放的技能ID
}
	
local currentCo;   						--当前剧情协程

local stepStatus = PlotStepType.none;		--剧情步骤是否在执行
local waitTime = 0;						--剧情等待时间
local totalElapse = 0;						--等待已花时间
local plotfunc = nil;						--剧情函数
local plotType = nil;						--剧情类型

--初始化
function PlotManager:Init()
	if VersionUpdate.curLanguage == LanguageType.cn then
		PlotsTw = nil;
		for _,v in ipairs(Plots) do
			self:RegisterPlot( v );
		end

	-- TW版剧情配置 暂时不考虑 如若需要查看git log
	elseif VersionUpdate.curLanguage == LanguageType.tw then
		Plots = nil;
		for _,v in ipairs(PlotsTw) do
			self:RegisterPlot( v );
		end
	end
	
end

--更新
function PlotManager:Update( Elapse )
	if false == self.isPlay then
		return;
	end
	if 0 ~= waitTime then
		totalElapse = totalElapse + Elapse;
		if totalElapse > waitTime then
			totalElapse = 0;
			waitTime = 0;
			self:FinishPlotStep(PlotStepType.wait);
		end
	end
	
	PlotPanel:Update(Elapse);	
end

--====================================
-- NPC对话
-- res：NPC半身像资源ID，res值为0，表示主角
-- text：对话文本
-- wait：是否等待
--====================================
function PlotManager:Talk(res, side, text)
	PlotPanel:Talk(res, side, text, true);
	self:setWait(PlotStepType.npcTalk, true, self.MinChangeTime);
end

--====================================
-- NPC对话
-- res：NPC半身像资源ID，res值为0，表示主角
-- text：对话文本
-- wait：是否等待
--====================================
function PlotManager:TalkTw(res, text)
	PlotPanel:TalkTw(res, text, true);
	self:setWait(PlotStepType.npcTalkTw, true, self.MinChangeTime);
end


--====================================
-- 对话半身像进入
-- res：NPC半身像资源ID，res值为0，表示主角
-- side：0表示左边，1表示右边
--====================================
function PlotManager:PortraitIn(res, side)
	PlotPanel:PortraitIn(res, side, true);
	self:setWait(PlotStepType.portraitIn, true);
end

--====================================
-- 对话半身像移出
-- res：NPC半身像资源ID，res值为0，表示主角
-- side：0表示左边，1表示右边
--====================================
function PlotManager:PortraitOut(res, side)
	PlotPanel:PortraitOut(res, side, true);
	self:setWait(PlotStepType.portraitOut, true);
end

--====================================
-- 对话遮罩显示
--====================================
function PlotManager:ShadeIn()
	PlotPanel:ShadeIn();
	--self:setWait(PlotStepType.shadeIn, true, self.MinChangeTime);
end

--====================================
-- 对话遮罩隐藏
--====================================
function PlotManager:ShadeOut()
	PlotPanel:ShadeOut();
	--self:setWait(PlotStepType.shadeOut, true, self.MinChangeTime);
end

--====================================
-- 屏幕淡入
-- time: 屏幕淡入时间
-- wait: 是否等待
--====================================
function PlotManager:BlackIn(time, wait)
	PlotPanel:BlackInShade(time, wait);
	self:setWait(PlotStepType.blackIn, wait, time);
end

--====================================
-- 屏幕淡出
-- time: 屏幕淡出时间
-- wait: 是否等待
--====================================
function PlotManager:BlackOut(time, wait)
	PlotPanel:BlackOutShade(time, wait);
	self:setWait(PlotStepType.blackOut, wait, time);
end

--====================================
-- 文本淡入
-- text: 文本内容
-- time: 文本淡入时间
-- wait: 是否等待
--====================================
function PlotManager:BlackInText(text, time, wait)
	PlotPanel:BlackInText(text, time, wait)
	self:setWait(PlotStepType.blackInText, wait, time);
end

--====================================
-- 文本淡出
-- time: 文本淡出时间
-- wait: 是否等待
--====================================
function PlotManager:BlackOutText(time, wait)
	PlotPanel:BlackOutText(time, wait);
	self:setWait(PlotStepType.blackOutText, wait, time);
end	

--====================================
-- 图片淡入
-- path: 图片路径，ui目录下路径
-- time: 图片淡入时间
-- scale：图片长宽缩放比例
-- x: 图片相对中心位置x轴偏移量
-- y: 图片相对中心位置y轴偏移量
-- wait: 是否等待
--====================================
function PlotManager:BlackInImage(path, time, wait, scale, x, y)
	PlotPanel:BlackInImage(path, time, scale, x, y, wait);
	self:setWait(PlotStepType.blackInImage, wait, time);
end

--====================================
-- 图片淡出
-- time: 图片淡出时间
-- wait: 是否等待
--====================================
function PlotManager:BlackOutImage(time, wait)
	PlotPanel:BlackOutImage(time, wait);
	self:setWait(PlotStepType.blackOutImage, wait, time);
end	


--====================================
-- NPC移动
-- id：NPC唯一标示符
-- x：移动到x坐标
-- y：移动到y坐标
-- wait：是否等待
--====================================
function PlotManager:NpcMove(id, x, y, wait)
	local npc = ActorManager:GetActor(id);
	if nil == npc then
		return;
	end
	npc:MoveTo(Vector2(x, y));
	self:setWait(PlotStepType.npcMove, wait, self.MinChangeTime);
end

--====================================
-- 创建NPC
-- id：NPC唯一标示符
-- res：NPC头像资源ID，res值为0，表示主角
-- x：移动到x坐标
-- y：移动到y坐标
--====================================
function PlotManager:CreateNpc(id, res, x, y)
	if 0 == res then
		res = ActorManager.hero.resID;
	end
	local npc = ActorManager:CreatePlotNPC(id, res);
	npc:InitPlotNpc(x,y);
	npc:InitData();
	npc:InitAvatar();
	npc:SetAwaitAimation();
	SceneManager:GetActiveScene():AddSceneNode(npc);
end

--====================================
-- 播放特效
-- output: 特效路径
-- armatureName: 特效名字
--====================================
function PlotManager:PlayEffect(output, armatureName, timescale)
	local path = GlobalData.EffectPath .. output;
	AvatarManager:LoadFile(path);
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI.Pick = false;
	local desktop = uiSystem:GetActiveDesktop();
	armatureUI.Margin = Rect(desktop.Width/2, desktop.Height/2, 0, 0);
	armatureUI.Horizontal = ControlLayout.H_LEFT;
	armatureUI.Vertical = ControlLayout.V_TOP;
	armatureUI:LoadArmature(armatureName);
	
	if timescale ~= nil then
		armatureUI:SetAnimation('play', timescale);
	else
		armatureUI:SetAnimation('play');
	end

	topDesktop:AddChild(armatureUI);
	return armatureUI;
end

--====================================
-- NPC销毁
-- id：NPC唯一标示符
--====================================
function PlotManager:DestroyNpc(id)
	local npc = ActorManager:GetActor(id);
	SceneManager:GetActiveScene():RemoveSceneNode(npc);
	npc:Destroy();
end

--====================================
-- 剧情等待
-- time: 等待时间
--====================================
function PlotManager:Wait(time)
	totalElapse = 0;
	waitTime = time;
	stepStatus = PlotStepType.wait;
	coroutine.yield();
end

--设置步骤等待标示位
function PlotManager:setWait(id, wait, time)
	if wait then
		stepStatus = id;
		coroutine.yield();
	end
end

--====================================
-- 剧情:取消等待时间，强制继续
--====================================
function PlotManager:Continue()
	waitTime = 0.1;
end

--是否会播放剧情
function PlotManager:WillPlayPlot(ptype, arg1, arg2)
	local key;

	if arg2 ~= nil then
		key = '' .. ptype .. '_' .. arg1 .. '_' .. arg2;
	else
		key = '' .. ptype .. '_' .. arg1;
	end

	if (self.plotList[key] ~= nil) then
		return true;
	else
		return false;
	end
end

--触发剧情
function PlotManager:TriggerPlot(ptype, arg1, arg2)
	plotType = ptype;
	local key;

	if arg2 ~= nil then
		key = '' .. plotType .. '_' .. arg1 .. '_' .. arg2;
	else
		key = '' .. plotType .. '_' .. arg1;
	end
	
	local plot = self.plotList[key];
	-- Debug.dump_lua(self.plotList)
	if nil ~= plot then	
		self:runProcess(plot);
		return true;
	else
		return false;
	end
end

--结束等待步骤
function PlotManager:FinishPlotStep(plotStepType, id)
	if stepStatus == plotStepType then
		stepStatus = PlotStepType.none;
		coroutine.resume(currentCo);
	end
end

--注册事件
function PlotManager:RegisterPlot( plot )
	local key;
	if plot[3] ~= nil then
		key = '' .. plot[1] .. '_' .. plot[2] .. '_' .. plot[3];
	else
		key = '' .. plot[1] .. '_' .. plot[2];
	end
	self.plotList[key] = plot;
end

--运行剧情
function PlotManager:runProcess( plot )
	self.isPlay = true;
	plotfunc = plot;
  currentCo = coroutine.create(self.process);  --  协程,接受一个参数，这个参数是coroutine的主函数
  coroutine.resume(currentCo);
end

--剧情过程函数
function PlotManager:process()
	
	if plotfunc['before'] ~= nil then
		plotfunc['before']();
	end

	PlotPanel:CreateShadeBg();
	
  plotfunc['run']();
	PlotPanel:Hide();
	
	PlotPanel:DestroyShadeBg();
	
	PlotManager:SetStatus(false);
	
	if plotfunc['after'] ~= nil then
		plotfunc['after']();
	end
end

--是否在播放剧情
function PlotManager:isPlayPlot()
    return self.isPlay;
end	

function PlotManager:SetStatus(status)
    self.isPlay = status;
end	

--=========================================================================
--特殊函数

local waitFightPreloadTimer = 0;
function plotWaitFightPreload()
	if not threadPool:IsThreadFuncFinished() then
		return;
	end
	
	timerManager:DestroyTimer(waitFightPreloadTimer);
	FightManager:NoviceBattle();
	Loading:DecWaitNum();
	Loading:SetProgress(90);
end

--旷世大战加载检查
function PlotManager:FirstFightCheck()
  if threadPool:IsThreadFuncFinished() then
		FightManager:NoviceBattle();
		FightManager:FinishLoadState();
	else
		--向服务器发送统计数据
		NetworkMsg_GodsSenki:SendStatisticsData(0, 3);
					
		waitFightPreloadTimer = timerManager:CreateTimer(0.1, 'plotWaitFightPreload', 0);
		Loading.waitMsgNum = 1;
		Game:SwitchState(GameState.loadingState);
	end
end	

--显示所有
function PlotManager:Show()
	bottomDesktop.Visibility = Visibility.Visible;
	MainUI:ShowMainUI();
end

--隐藏所有
function PlotManager:Hidden()
	bottomDesktop.Visibility = Visibility.Hidden;
	MainUI:HideMainUI();
end	
