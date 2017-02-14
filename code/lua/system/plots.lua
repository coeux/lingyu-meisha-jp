--plots.lua

--====================================
-- NPC对话
-- res：NPC半身像资源ID，res值为0，表示主角
-- side：0表示左边，1表示右边
-- text：对话文本
-- wait：是否等待
--====================================
local Talk 	= 	function(res, side, text) 
					PlotManager:Talk(res, side, text);
				end;					


--====================================
-- NPC对话
-- res：NPC半身像资源ID，res值为0，表示主角
-- text：对话文本
-- wait：是否等待
--====================================
local TalkTw = 	function(res, text) 
					PlotManager:TalkTw(res, text);
				end;

--====================================
-- 设置等待时间
-- time: 剧情步骤最长等待时间
--====================================			
local Timeout   = function(time)
					PlotPanel:SetTimeout(time);
				end;

--====================================
-- NPC移动
-- id：NPC唯一标示符
-- x：移动到x坐标
-- y：移动到y坐标
-- wait：是否等待
--====================================
local NpcMove 	= function(id, x, y, wait)
					PlotManager:NpcMove(id, x, y, wait);
				end;

--====================================
-- 创建NPC
-- id：NPC唯一标示符
-- res：NPC头像资源ID，res值为0，表示主角
-- x：移动到x坐标
-- y：移动到y坐标
--====================================
local CreateNpc = function(id, res, x, y)
					PlotManager:CreateNpc(id, res, x, y);
				end;

--====================================
-- NPC销毁
-- id：NPC唯一标示符
--====================================
local DestroyNpc = function(id)
					PlotManager:DestroyNpc(id);
				end;

--====================================
-- 剧情等待
-- time: 等待时间
--====================================
local Wait   = function(time)
					PlotManager:Wait(time);
				end;

--====================================
-- 屏幕淡入
-- time: 屏幕淡入时间
-- wait: 是否等待
--====================================
local BlackIn   = function(time, wait)
					PlotManager:BlackIn(time, wait);
				end;

--====================================
-- 屏幕淡出
-- time: 屏幕淡出时间
-- wait: 是否等待
--====================================
local BlackOut   = function(time, wait)
					PlotManager:BlackOut(time, wait);
				end;

--====================================
-- 文本淡入
-- text: 文本内容
-- time: 文本淡入时间
-- wait: 是否等待
--====================================
local BlackInText   = function(text, time, wait)
					PlotManager:BlackInText(text, time, wait);
				end;	

--====================================
-- 文本淡出
-- time: 文本淡出时间
-- wait: 是否等待
--====================================			
local BlackOutText   = function(time, wait)
					PlotManager:BlackOutText(time, wait);
				end;
				
--====================================
-- 图片淡入
-- path: 图片路径，ui目录下路径
-- time: 图片淡入时间
-- scale：图片长宽缩放比例
-- x: 图片相对中心位置x轴偏移量
-- y: 图片相对中心位置y轴偏移量
-- wait: 是否等待
--====================================
local BlackInImage   = function(path, time, wait, scale, x, y)
					PlotManager:BlackInImage(path, time, wait, scale, x, y);
				end;

--====================================
-- 图片淡出
-- time: 图片淡出时间
-- wait: 是否等待
--====================================		
local BlackOutImage   = function(time, wait)
					PlotManager:BlackOutImage(time, wait);
				end;

--====================================
-- 播放特效
-- output: 特效路径
-- armatureName: 特效名字
-- timeScale: 时间缩放
--====================================		
local PlayEffect   = function(output, armatureName, timeScale)
					return PlotManager:PlayEffect(output, armatureName, timeScale);
				end;
				
--====================================
-- 对话半身像进入
-- res：NPC半身像资源ID，res值为0，表示主角
-- side：0表示左边，1表示右边
--====================================
local PortraitIn   = function(res, side)
					PlotManager:PortraitIn(res, side);
				end;

--====================================
-- 对话半身像移出
-- res：NPC半身像资源ID，res值为0，表示主角
-- side：0表示左边，1表示右边
--====================================
local PortraitOut   = function(res, side)
					PlotManager:PortraitOut(res, side);
				end;

--====================================
-- 对话遮罩显示
--====================================				
local ShadeIn   = function()
					PlotManager:ShadeIn();
				end;

--====================================
-- 对话遮罩隐藏
--====================================					
local ShadeOut   = function()
					PlotManager:ShadeOut();
				end;


--========================================================================
--========================================================================

--说明:
--触发方式一：进入主城
--		EventType.EnterCity
--		arg1：主线任务
--		arg2：场景类型

--触发方式二：进入战斗
--		EventType.EnterFight
--		arg1：主线任务
--		arg2：nil

--触发方式三：战斗胜利
--		EventType.FightWin
--		arg1：主线任务
--		arg2：nil

--触发方式四：个体进入战斗场景
--		EventType.LeftPersonEnterFightScene 
--		arg1：主线任务
--		arg2：出场位置

--触发方式五：销毁战斗
--		EventType.DestroyFight 
--		arg1：0（左侧） 1（右侧）
--		arg2：出场位置



PlotsArg =
			{
				TouchSkillNum				= 2;		--进行2次手滑技能引导
				GestureSkillEffectNum		= 3;		--全局技能动画次数
				RunSkill					= 0;		--主动技能释放次数

				isFightWithBoss             = false;    --是否和boss对战
				isSecondAngerMax            = false;    --  第二次怒气是否满
				isTraggerBossRunSkill       =false;    --  是否触发大龙准备释放剧情
			};


Plots =
{
	--进入游戏第一次黑屏连环画
	{
		EventType.EnterCity,
		100001, -- 任务ID
		1001, 	-- 场景
		run = function ()
			-- print("event 1: picture begin");
			-- BlackInImage("background/start_bg1.jpg", 1, 0, 1, 0, 0);
			-- Wait(5);
			-- BlackOutImage(5, 0);
			-- BlackInImage("background/start_bg2.jpg", 1, 0, 1, 0, 0);
			-- Wait(5);
			-- BlackOutImage(5, 0);
			-- BlackInImage("background/start_bg3.jpg", 1, 0, 1, 0, 0);
			-- Wait(5);
			-- BlackOutImage(5, 0);
			-- BlackInImage("background/start_bg4.jpg", 1, 0, 1, 0, 0);
			-- Wait(5);
			-- BlackOutImage(5, 0);
			-- BlackInImage("background/start_bg5.jpg", 1, 0, 1, 0, 0);
			-- Wait(5);
			-- BlackOutImage(5, 0);
			-- BlackInImage("background/start_bg6.jpg", 1, 0, 1, 0, 0);
			-- Wait(5);
			-- BlackOutImage(5, 0);
			
			SoundManager:PauseBackgroundSound();
			--Game:SwitchState(GameState.loadingState);
			FightManager:PreLoadNoviceBattleResource();	
			FightManager:Initialize(RoundIDSection.NoviceBattleID);
			FightManager:InitAllFightersAvatar();
			PlotManager:FirstFightCheck();
			Wait(TriggerPlotTime[1]);
		end,
		after	= function ()
			-- print("event 1: picture end");
			EventManager:FireEvent(EventType.Time, 100001, TriggerPlotTime[1]);
		end,
	},
	-- 第一次时间触发
	{
		EventType.Time,
		100001,
		TriggerPlotTime[1], -- 倒计时到00:00:00时触发时间
		run = function()
			-- print("event 2: plot 1 begin");
			FightManager:Pause();
			MainUI:Active();
			TaskDialogPanel:onNovice(TriggerPlotID[1]); -- 播放剧情
			Wait(8640)
		end,
		after = function()
			-- print("event 3: plot 2 end");
			FightManager:Continue();
		end,
	},
	-- 第二次时间触发
	{
		EventType.Time,
		100001,
		TriggerPlotTime[2], -- 倒计时到00:00:00时触发时间
		run = function()
			-- print("event 3: plot 2 begin");
			Wait(1);
			FightManager:Pause();
			MainUI:Active();
			TaskDialogPanel:onNovice(TriggerPlotID[2]); -- 播放剧情
			Wait(8640);
		end,
		after = function()
			-- print("event 3: plot 2 end");
			FightManager:Continue();
			FightManager:NoviceEnterScene();
		end,
	},
	-- 我方第一次怒气满触发
	{
		EventType.AngerMax,
		100001,
		1, -- 第1次怒气满
		run = function()
			-- print("event 4: ally max anger 1 begin");
			NetworkMsg_GodsSenki:SendStatisticsData(0, 4);
			FightManager:Pause();
			MainUI:Active();
			TaskDialogPanel:onNovice(TriggerPlotID[3]); -- 播放剧情
			Wait(8640);
		end,
		after = function()
			-- print("event 4: ally max anger skill 1 end");
			FightManager:Continue();
		end,
	},
	-- 引导触发点击卡牌
	{
		EventType.CanTouchSkill,
		100001,
		1, -- 第1次引导触发卡牌
	 	run = function()
			-- print("event 5: ally skill 1 begin");
			-- print("guide: 此处应该是技能释放引导");
			FightManager:Pause();
			MainUI:Active()
			FightShowSkillManager:AddShader(  )
			--  显示提示框
			PlotPanel:showContent(  )
			PlotPanel:changeContentPos(100,0)
			PlotPanel:changeContentText( LANG_GUIDE_CONTENT_1 )
			--  播放引导特效
			local handSkill = FightSkillCardManager:getHandSkillList()
			--  这里用常数640，而用appFramework.ScreenHeight不正确，是因为这个特性是添加在topDesktop上 ，而topdesktop的大小是调用了SetDesktopSize(topDesktop)方法
			FightSkillCardManager:displayGuideEffect( handSkill[1].Translate.x + 60, handSkill[1].Translate.y + 640 - 110, false)  --  appFramework.ScreenHeight
			FightManager.canClickCard = true    --  技能卡能点击
            FightSkillCardManager:setCardEnabled(  )   --  卡牌可点击
            -- print("first =", os.clock())
			Wait(8640);
		end,
		after = function()
			-- print("event 5: ally skill 1 end");
			FightManager:Continue();
		end,
	},
	-- 我方第2次怒气满触发
	{
		EventType.AngerMax,
		100001,
		2, -- 第2次怒气满
		run = function()
			-- print("event 6: ally max anger 2 begin");
			NetworkMsg_GodsSenki:SendStatisticsData(0, 5);
			FightManager:Pause();
			PlotsArg.isSecondAngerMax = true
			MainUI:Active();
			TaskDialogPanel:onNovice(TriggerPlotID[4]) -- 第二次怒气满时，播放剧情4
			-- TaskDialogPanel:onNovice(TriggerPlotID[5]) -- 第三次怒气满时，播放剧情5
			Wait(8640);
		end,
		after = function()
			-- print("event 6: ally max anger skill 2 end");
			FightManager:Continue();
		end,
	},
	-- 引导触发点击卡牌
	{
		EventType.CanTouchSkill,
		100001,
		2, -- 第2次引导触发卡牌
	 	run = function()
			-- print("event 7: ally skill 2 begin");
			-- print("guide: 此处应该是技能释放引导");
			FightManager:Pause();
			MainUI:Active();
			--  先蒙灰，然后引导玩家选择后排敌人，之后引导玩家释放技能
			-- local handSkill = FightSkillCardManager:getHandSkillList()
			-- FightShowSkillManager:AddShader(  )
			-- PlotPanel:showContent(  )
			-- PlotPanel:changeContentText( LANG_GUIDE_CONTENT_2 )   
			FightManager:playSelectArmature(8004, LANG_GUIDE_CONTENT_2)
			Wait(8640);
		end,
		after = function()
			-- print("event 7: ally skill 2 end");
			FightManager:Continue();
		end,
	},
	-- 我方第3次怒气满触发
	-- {
	-- 	EventType.AngerMax,
	-- 	100001,
	-- 	3, -- 第3次怒气满
	-- 	run = function()
	-- 		-- print("event 8: ally max anger 3 begin");
	-- 		FightManager:Pause();
	-- 		MainUI:Active();
	-- 		TaskDialogPanel:onNovice(TriggerPlotID[5]) -- 第三次怒气满时，播放剧情5
	-- 		Wait(8640);
	-- 	end,
	-- 	after = function()
	-- 		-- print("event 8: ally max anger skill 3 end");
	-- 		FightManager:Continue();
	-- 	end,
	-- },
	-- -- 引导触发点击卡牌
	-- {
	-- 	EventType.CanTouchSkill,
	-- 	100001,
	-- 	3, -- 第3次引导触发卡牌
	--  	run = function()
	-- 		-- print("event 9: ally skill 3 begin");
	-- 		-- print("guide: 此处应该是技能释放引导");
	-- 		FightManager:Pause();
	-- 		MainUI:Active();
	-- 		FightShowSkillManager:AddShader(  )
	-- 		--  显示提示框
	-- 		PlotPanel:showContent(  )
	-- 		PlotPanel:changeContentPos(100,0)
	-- 		PlotPanel:changeContentText( LANG_GUIDE_CONTENT_1 )
	-- 		--  播放引导特效
	-- 		local handSkill = FightSkillCardManager:getHandSkillList()
	-- 		FightSkillCardManager:displayGuideEffect( handSkill[1].Translate.x + 60, handSkill[1].Translate.y + 640 - 110 )
	-- 		FightManager.canClickCard = true    --  技能卡能点击
 --            FightSkillCardManager:setCardEnabled(  )   --  卡牌可点击
 --            -- print("third  = ", os.clock())
	-- 		Wait(8640);
	-- 	end,
	-- 	after = function()
	-- 		-- print("event 9: ally skill 3 end");
	-- 		FightManager:Continue();
	-- 		FightSkillCardManager.canFightContinue = true
	-- 	end,
	-- },
	-- boss入场触发事件
	{
		EventType.BossEnterFightScene,
		100001,
		run	= function ()
			-- print("event 9: enemy monster 5 die, boss in begin");
			FightManager:Pause();
			MainUI:Active();
			TaskDialogPanel:onNovice(TriggerPlotID[6])  -- 敌方英雄全死，在boss入场前播放剧情6
			PlotsArg.isFightWithBoss = true
			Wait(8640);
		end,
		after	= function ()
			-- print("event 9: enemy monster 5 die, boss in end");
			FightManager:Continue();
		end,
	},
	-- boss准备释放技能事件
	{
		EventType.ReadyRunSkill,
		100001, -- mainTaskId
		8006, -- boss id
		run = function()
			print("event 10: boss run skill begin");
			NetworkMsg_GodsSenki:SendStatisticsData(0, 6);
			FightManager:Pause();
			FightShowSkillManager:PauseActorShowSkill()
			MainUI:Active();
			TaskDialogPanel:onNovice(TriggerPlotID[7])  --  boss释放技能播放剧情7)
			PlotsArg.isTraggerBossRunSkill = true;
			Wait(8640)
		end,
		after = function()
			print("event 10: boss run skill end");
			FightManager:Continue();
		end,
	},
	-- 我方第4次怒气满触发
	{
		EventType.AngerMax,
		100001,
		3, -- 第4次怒气满
		run = function()
			-- print("event 11: ally max anger 4 begin");
			FightManager:Pause();
			MainUI:Active();
			TaskDialogPanel:onNovice(TriggerPlotID[8])  -- 第四次怒气满时，播放剧情8
			Wait(8640);
		end,
		after = function()
			-- print("event 11: ally max anger skill 4 end");
			FightManager:Continue();
		end,
	},
	-- 引导触发点击卡牌
	{
		EventType.CanTouchSkill,
		100001,
		3, -- 第4次引导触发卡牌
	 	run = function()
			-- print("event 12: ally skill 4 begin");
			-- print("guide: 此处应该是技能释放引导");
			FightManager:Pause();
			MainUI:Active();
			FightShowSkillManager:AddShader(  )
			--  显示提示框
			PlotPanel:showContent(  )
			PlotPanel:changeContentPos(100,0)
			PlotPanel:changeContentText( LANG_GUIDE_CONTENT_1 )
			--  播放引导特效
			local handSkill = FightSkillCardManager:getHandSkillList()
			--  这里用常数640，而用appFramework.ScreenHeight不正确，是因为这个特性是添加在topDesktop上 ，而topdesktop的大小是调用了SetDesktopSize(topDesktop)方法
			FightSkillCardManager:displayGuideEffect( handSkill[1].Translate.x + 60, handSkill[1].Translate.y + 640 - 110, false)
			FightManager.canClickCard = true    --  技能卡能点击
            FightSkillCardManager:setCardEnabled(  )   --  卡牌可点击
            -- print("fourth = ", os.clock())
			Wait(8640);
		end,
		after = function()
			-- print("event 12: ally skill 4 end");
			FightManager:Continue();
		end,
	},
	--  第一连
	{
		EventType.FirstCombo,
		100001,
		1, 
		run = function()
			-- print("event 13: first combo begin")
			FightManager:Pause()
			NetworkMsg_GodsSenki:SendStatisticsData(0, 7);
			MainUI:Active()
			TaskDialogPanel:onNovice(TriggerPlotID[9])
			Wait(8640);
		end,
		after = function()
			-- print("event 13: first combo end");
			FightComboQueue:setStatus(2)
			FightComboQueue.curComboNum = FightComboQueue.curComboNum + 1
			FightComboQueue.isTragger = true
			FightManager:Continue();
		end,
	},
	--  第二连
	{
		EventType.SecondCombo,
		100001,
		2, 
		run = function()
			-- print("event 14: second combo begin");
			FightManager:Pause();
			MainUI:Active();
			TaskDialogPanel:onNovice(TriggerPlotID[10])  
			Wait(8640);
		end,
		after = function()
			-- print("event 14: second combo end");
			FightComboQueue:setStatus(2)
			FightComboQueue.curComboNum = FightComboQueue.curComboNum + 1
			FightComboQueue.isTragger = true
			FightManager:Continue();
		end,
	},
	--  主角连
	{
		EventType.ThirdCombo,
		100001,
		3, 
		run = function()
			-- print("event 15: third combo begin");
			FightManager:Pause();
			MainUI:Active();
			TaskDialogPanel:onNovice(TriggerPlotID[11])  
			Wait(8640);
		end,
		after = function()
			-- print("event 15: third combo end");
			FightComboQueue:setStatus(2)
			FightComboQueue.curComboNum = FightComboQueue.curComboNum + 1
			FightComboQueue.isTragger = true
			FightManager:Continue();
		end,
	},
	--  boss死亡
	{
		EventType.NoviceBossDie,
		100001,
		run = function()
			NetworkMsg_GodsSenki:SendStatisticsData(0, 8);
			-- print("event 16: boss die begin");
			FightManager:Pause();
			MainUI:Active();
			TaskDialogPanel:onNovice(TriggerPlotID[12]) 
			Wait(8640);
		end,
		after = function()
			-- print("event 16: aboss die end");
			FightManager:Continue();
			FightOverUIManager:OnBackToCity()
		end,
	},

	--  技能播放结束
	-- {
	-- 	EventType.TouchSkillFinish,
	-- 	100001,
	-- 	run = function()
	-- 		print("event 13: touch skill 4 finish");
	-- 		print("guide: 此处应该是技能释放结束");
	-- 		FightManager:Pause();
	-- 		MainUI:Active();
	-- 		TaskDialogPanel:onNovice(TriggerPlotID[10]); -- 播放剧情
	-- 		Wait(8640);
	-- 	end,
	-- 	after = function()
	-- 		print("event 13: touch skill 4 really finish");
	-- 		FightManager:Continue();
	-- 	end,
	-- },
}
	
--[[
	{
		EventType.LeftPersonEnterFightScene,
		0,
		3,
		run		= function ()
					Wait(1);
					FightManager:Pause();
					ShadeIn();
					PortraitIn(101, 0);
					Talk(101, 0, LANG_plots_12);
					PortraitOut(101, 0);
					ShadeOut();
					FightManager:Continue();
				end,
		after	= function ()
					EventManager:UnregisterEvent(EventType.LeftPersonEnterFightScene);
				end,
	},
	
	--boss进入战斗场景
{
		EventType.BossEnterFightScene,
		0,
		101,
		run		= function ()
					FightManager:Pause();
					FightUIManager:SetAllSkillEffectEnable(false);
					--BlackIn(0, false);
					Wait(0.1);
					--PlayEffect('cutin_output/', 'cutin');
					Wait(2);
					--BlackOut(0, false);
					FightUIManager:SetAllSkillEffectEnable(true);
					FightManager:Continue();
					
					--注册释放技能事件
					EventManager:RegisterEvent(EventType.RunSkill, Event, Event.OnRunSkill);
				end,
		after	= function ()
					EventManager:UnregisterEvent(EventType.OnBossEnterFightScene);
				end,
	},
	
	--释放技能(阿瑞斯)
	{
		EventType.RunSkill,
		0,
		901,
		run		= function ()
					if PlotsArg.RunSkill == 0 then
						FightManager:Pause();
						
						PortraitIn(131, 1);
						Talk(131, 1, LANG_plots_59);
						PortraitOut(131, 1);
						Wait(2);
					
						--特殊情况不用继续
						--FightManager:Continue();
						
						PlotsArg.RunSkill = 1;
					end
				end,
	},
	--释放技能(宙斯)
	{
		EventType.RunSkill,
		0,
		911,
		run		= function ()
					FightManager:Pause();
					
					PortraitIn(101, 0);
					Talk(101, 0, LANG_plots_60);
					PortraitOut(101, 0);
					Wait(2);
					
					--特殊情况不用继续
					--FightManager:Continue();
				end,
		after	= function ()
					EventManager:UnregisterEvent(EventType.RunSkill);
				end,
	},
	
	--旷世大战胜利
	{
		EventType.FightWin,
		0,
		101,
		run		= function ()
					--向服务器发送统计数据
					NetworkMsg_GodsSenki:SendStatisticsData(0, 7);
					Wait(1.5);
					ShadeIn();
					PortraitIn(102, 0);
					Talk(102, 0, LANG_plots_13);
					PortraitIn(131, 1);
					Talk(131, 1, LANG_plots_14);
					Talk(131, 1, LANG_plots_15);
					PortraitOut(131, 1);
					Talk(102, 0, LANG_plots_16);
					PortraitOut(102, 0);

				end,
		after	= function ()
					FightManager.isAuto = false;
					FightManager:DisplayResult();
				end,
	},
	
	--旷世大战结束
	{
		EventType.DestroyFight,
		0,
		101,
		run		= function ()
					--向服务器发送统计数据
					NetworkMsg_GodsSenki:SendStatisticsData(0, 8);

					--屏蔽第二段动画					
					-- BlackIn(0, false);
					-- Wait(1);
					-- local armatureUI = PlayEffect('start_2_output/', 'start_2');
					-- armatureUI.Scale = Vector2(1, 1);
					-- armatureUI:IncRefCount();
					-- Wait(8.1);
					-- topDesktop:RemoveChild(armatureUI);
					-- armatureUI:DecRefCount();

					BlackIn(0, true);
					BlackInText(LANG_plots_17, 0.5, true);
					Wait(2)
					BlackInText(LANG_plots_18, 0.5, true);
					Wait(2)
					BlackInText(LANG_plots_19, 0.5, true);
					Wait(1);
					
					--触发回收显存事件
					EventManager:FireEvent(EventType.RecoverDisplayMemory, true);
					PlotScene:onEnter();

					MainUI:SetMarqueeState(false);
					CreateNpc(91, 202, -50, -80);
					CreateNpc(92, 0, -300, -100);
					BlackOut(1, true);
					ShadeOut();
					NpcMove(91, -200, -100, true);

					--向服务器发送统计数据
					NetworkMsg_GodsSenki:SendStatisticsData(0, 9);
					--ShadeIn();
					PortraitIn(102, 1);
					Talk(102, 1, LANG_plots_20);
					PortraitIn(0, 0);
					Talk(0, 0, LANG_plots_21);
					Talk(102, 1, LANG_plots_22);
					Talk(0, 0, LANG_plots_23);
					-- Talk(102, 1, LANG_plots_24);
					-- Talk(0, 0, LANG_plots_25);
					PortraitOut(102, 1);
					PortraitOut(0, 0);
					--ShadeOut();

				end,
		after	= function ()
					PlotScene:destroy();
					UserGuidePanel:SetInGuiding(true);
					UserGuidePanel:ShowGuideShade(TaskGuidePanel:GetGuideButton(), GuideEffectType.arrow, GuideTipPos.left, LANG_plots_26, nil, 0.5);
					UserGuidePanel:SetInGuiding(false);
					
					--触发回收显存事件
					EventManager:FireEvent(EventType.RecoverDisplayMemory, true);
				end
	},
	
	--第1关引导
	{
		EventType.EnterFight,
		203,
		1001,
		run		= function ()
					FightManager:Pause(true);
					ShadeIn();
					Wait(0.5);
					PortraitIn(102, 0);
					Talk(102, 0,LANG_plots_27);
					PortraitOut(102, 0);
					PortraitIn(0, 1);
					Talk(0, 1,LANG_plots_28);
					PortraitOut(0, 1);
					ShadeOut();
					FightManager:InsertLeftActor(2, 6002,3);
					FightManager:InsertRightActor(11, 5065, 2);
					Wait(0.5);
				end,
		after	= function ()
					EventManager:RegisterEvent(EventType.LeftPersonEnterFightScene, Event, Event.OnLeftPersonEnterFightScene);
					FightManager:Continue();
				end,
	},
	{
		EventType.LeftPersonEnterFightScene,
		203,
		3,
		run		= function ()
					Wait(0.5);
					ShadeIn();
					FightManager:Pause(true);
					PortraitIn(151, 0);
					Talk(151, 0,LANG_plots_29);
					PortraitIn(0, 1);
					Talk(0, 1,LANG_plots_30);
					PortraitOut(151, 0);
					PortraitOut(0, 1);
					FightManager:Continue();
					ShadeOut();
				end
	},	
	{
		EventType.FightWin,
		203,
		1001,
		run		= function ()
					Wait(0.5);
					ShadeIn();
					PortraitIn(102, 0);
					Talk(102, 0,LANG_plots_31);
					PortraitOut(102, 0);
					ShadeOut();
				end,
		after	= function ()
					EventManager:UnregisterEvent(EventType.LeftPersonEnterFightScene);
					FightManager:DisplayResult();
				end,
	},
	
	--第2关引导
	{
		EventType.EnterFight,
		204,
		1002,
		run		= function ()
					EventManager:RegisterEvent(EventType.LeftPersonEnterFightScene, Event, Event.OnLeftPersonEnterFightScene);
					FightManager:InsertLeftActor(1, 6002,1);
					FightManager:InsertLeftActor(3, 6076,3);
					FightManager:InsertRightActor(21, 5070, 2);
					Wait(0.5);
					ShadeIn();
					PortraitIn(102, 0);
					Talk(102, 0, LANG_plots_32);
					PortraitOut(102, 0);
					ShadeOut();
				end,
	},
	{
		EventType.LeftPersonEnterFightScene,
		204,
		3,
		run		= function ()
					FightManager:Pause(true);
					Wait(0.5);
					ShadeIn();
					PortraitIn(171, 0);
					Talk(171, 0, LANG_plots_33);
					PortraitOut(171, 0);
					FightManager:Continue();
					ShadeOut();
				end
	},	

	{
		EventType.FightWin,
		204,
		1002,
		run		= function ()
					Wait(1);
					ShadeIn();
					PortraitIn(171, 0);
					Talk(171, 0, LANG_plots_34);
					PortraitOut(171, 0);
					ShadeOut();
				end,
		after	= function ()
					EventManager:UnregisterEvent(EventType.LeftPersonEnterFightScene);
					FightManager:DisplayResult();
				end,
	},
	
	--第3关引导
	{
		EventType.EnterFight,
		210,
		1003,
		run		= function ()
					FightUIManager:AddInitGesturePower(4);	--增加4点，保证可以使用陨石技能

					--EventManager:RegisterEvent(EventType.LeftPersonEnterFightScene, Event, Event.OnLeftPersonEnterFightScene);
					FightManager:Pause(true);
					Wait(0.5);
					FightManager:InsertLeftActor(2, 6002,1);
					FightManager:InsertRightActor(17, 5020, 2)

					FightManager:Pause(true);
					ShadeIn();
					PortraitIn(102, 0);
					Talk(102, 0, LANG_plots_35);
					PortraitOut(102, 0);
					FightManager:Continue();
					ShadeOut();					

					PlotsArg.GestureSkillEffectNum = 4;
					FightUIManager:PlayTeachGestureSkillEffect(GestureSkillID.V);

				end,
		after	= function ()
					EventManager:RegisterEvent(EventType.CanPlayGestureSkill, Event, Event.OnCanPlayGestureSkill);
					EventManager:RegisterEvent(EventType.PlayGestureSkill, Event, Event.OnPlayGestureSkill);
					FightManager:Continue();
				end,
	},	
	{
		EventType.FightWin,
		210,
		1003,
		run		= function ()
					FightUIManager:DestroyTeachGestureSkillEffect();
					Wait(1);
					ShadeIn();
					PortraitIn(0, 0);
					Talk(0, 0,LANG_plots_36);					
					PortraitOut(0, 0);
					ShadeOut();	
				end,
		after	= function ()
					--EventManager:UnregisterEvent(EventType.LeftPersonEnterFightScene);
					EventManager:UnregisterEvent(EventType.CanPlayGestureSkill);
					EventManager:UnregisterEvent(EventType.PlayGestureSkill);
					FightManager:DisplayResult();
				end,
	},

	--第4关继续引导
	{
		EventType.EnterFight,
		211,
		1004,
		run		= function ()
					FightManager:Pause(true);
					PlotsArg.GestureSkillEffectNum = 1;
					--FightUIManager:PlayTeachGestureSkillEffect(GestureSkillID.V);
					
					EventManager:RegisterEvent(EventType.LeftPersonEnterFightScene, Event, Event.OnLeftPersonEnterFightScene);

					FightManager:InsertLeftActor(2, 6002,1);
					FightManager:InsertRightActor(8, 5081, 2);
					ShadeIn();
					PortraitIn(102, 0);
					Talk(102, 0, LANG_plots_37);
					PortraitOut(102, 0);
					ShadeOut();	

				end,
		after	= function ()
					EventManager:RegisterEvent(EventType.CanPlayGestureSkill, Event, Event.OnCanPlayGestureSkill);
					EventManager:RegisterEvent(EventType.PlayGestureSkill, Event, Event.OnPlayGestureSkill);
					FightManager:Continue();
				end,
	},
	
	{
		EventType.FightWin,
		211,
		1004,
		run		= function ()
					FightUIManager:DestroyTeachGestureSkillEffect();
					Wait(1);
					ShadeIn();
					PortraitIn(102, 0);
					Talk(102, 0, LANG_plots_38);
					PortraitOut(102, 0);
					ShadeOut();	
				end,
		after	= function ()
					EventManager:UnregisterEvent(EventType.LeftPersonEnterFightScene);
					EventManager:UnregisterEvent(EventType.CanPlayGestureSkill);
					EventManager:UnregisterEvent(EventType.PlayGestureSkill);
					FightManager:DisplayResult();
				end,
	},

	--第5关任务的战斗对话
	{
		EventType.EnterFight,
		213,
		1005,
		run		= function ()
					FightManager:Pause(true);
					FightManager:InsertLeftActor(1, 6002,3);
					FightManager:InsertLeftActor(2, 6003,1);
					ShadeIn();
					PortraitIn(102, 0);
					Talk(102, 0, LANG_plots_39);
					PortraitOut(102, 0);
					PortraitIn(101, 0);
					Talk(101, 0, LANG_plots_40);
					PortraitOut(101, 0);
					ShadeOut();
				end,
		after	= function ()
					FightManager:Continue();
				end,
	},
	{
		EventType.FightWin,
		213,
		1005,
		run		= function ()
					Wait(1);
					ShadeIn();
					PortraitIn(101, 0);
					Talk(101, 0, LANG_plots_41);
					PortraitOut(101, 0);
					ShadeOut();
				end,
		after	= function ()
						FightManager:DisplayResult();
				end,
	},
	
	--第7关开放闪电技能
	{
		EventType.EnterFight,
		219,
		1007,
		run		= function ()
					FightUIManager:AddInitGesturePower(6);		--增加6点，保证可以使用闪电技能

					FightManager:Pause(true);
					ShadeIn();
					PortraitIn(101, 0);
					Talk(101, 0, LANG_plots_42);
					PortraitOut(101, 0);
					ShadeOut();	
					
					Wait(0.1);
					BlackInText(LANG_plots_43, 0.5, false);
					Wait(1.5);
					BlackOutText(0.3, false);
					Wait(0.3);
					BlackOutImage(1, false);
										
					FightManager:Continue();

					PlotsArg.GestureSkillEffectNum = 1;
					FightUIManager:PlayTeachGestureSkillEffect(GestureSkillID.Lighting);
				end
	},

	--美杜莎任务的战斗对话
	{
		EventType.EnterFight,
		1020,
		1015,
		run = function ()
				FightManager:Pause(true);
				Wait(1);
				ShadeIn();
				PortraitIn(102, 0);
				Talk(102, 0, LANG_plots_44);
				PortraitOut(102, 0);
				ShadeOut();					
				FightManager:Continue();
			end
	},
	
	--泰坦与宙斯任务的战斗对话
	{
		EventType.EnterFight,
		1025,
		1020,
		run		= function ()
					FightManager:Pause(true);
					ShadeIn();
					PortraitIn(103, 0);
					Talk(103, 0, LANG_plots_45);
					PortraitIn(101, 1);
					Talk(101, 1, LANG_plots_46);
					PortraitOut(103, 0);
					PortraitOut(101, 1);
					ShadeOut();							
					FightManager:Continue();
				end
	},
	
	--泰坦与宙斯任务的战斗胜利对话
	{
		EventType.FightWin,
		1025,
		1020,
		run		= function ()
					BlackIn(0, false);
					Wait(0.1);
					BlackInText(LANG_plots_47, 0.5, true);
					Wait(2);
					BlackInText(LANG_plots_48, 0.5, true);
					Wait(2);			
					BlackOut(0, false);
					Wait(1);
					ShadeIn();
					PortraitIn(101, 1);
					Talk(101, 1, LANG_plots_49);
					PortraitOut(101, 1);
					PortraitIn(103, 0);
					Talk(103, 0, LANG_plots_50);
					PortraitOut(103, 0);
					ShadeOut();		
				end,
		after	= function ()
					FightManager:DisplayResult();
				end
	},
	
	--伟大的阿伽门农王任务的战斗对话
	--开放○恢复技能
	{
		EventType.EnterFight,
		1032,
		1025,
		run		= function ()
					FightManager:CloseAutoTemporarily();
					FightUIManager:AddInitGesturePower(7);		--增加7点，保证可以使用○技能
					FightManager:Pause(true);
					Wait(1);
					ShadeIn();
					PortraitIn(102, 0);
					Talk(102, 0, LANG_plots_51);
					PortraitOut(102, 0);
					ShadeOut();	
					Wait(0.1);
					BlackInText(LANG_plots_52, 0.5, false);
					Wait(0.5);
					BlackOutText(0.3, false);			
					--插入○技能图片
					PlayEffect('donghua_201_output/', 'donghua_201', 2);
					Wait(0.5);
					BlackOutImage(1, false);
					FightManager:Continue();
				end
	},
	
	--伟大的阿伽门农王任务的战斗胜利对话
	{
		EventType.FightWin,
		1032,
		1025,
		run		= function ()
					Wait(1);
					ShadeIn();
					PortraitIn(102, 0);
					Talk(102, 0, LANG_plots_53);
					PortraitOut(102, 0);
					FightManager:RecoverAutoTemporarily();
					ShadeOut();	
				end,
		after	= function ()
					FightManager:DisplayResult();
				end
	},
	
	--邪神登场任务的战斗对话
	--开放终极技能
	{
		EventType.EnterFight,
		1066,
		1055,
		run		= function ()
					FightManager:CloseAutoTemporarily();
					FightUIManager:AddInitGesturePower(12);		--增加12点，保证可以使用z技能
					FightManager:Pause(true);
					Wait(1);
					ShadeIn();
					PortraitIn(113, 0);
					Talk(113, 0, LANG_plots_54);
					PortraitOut(113, 0);
					ShadeOut();	
					Wait(0.1);
					BlackInText(LANG_plots_55, 0.5, false);
					Wait(0.5);
					BlackOutText(0.3, false);
					--插入Z技能图片
					PlayEffect('donghua_401_output/', 'donghua_401', 2);
					Wait(0.5);
					BlackOutImage(1, false);
					Wait(1);
					ShadeIn();
					PortraitIn(103, 0);
					Talk(103, 0, LANG_plots_56);
					PortraitOut(103, 0);					
					PortraitIn(124, 1);
					Talk(124, 1, LANG_plots_57);
					PortraitOut(124, 1);
					ShadeOut();						
					Wait(1);
					FightManager:Continue();
				end
	},
	
	--邪神登场任务的战斗胜利对话
	{
		EventType.FightWin,
		1066,
		1055,
		run		= function ()
					FightManager:RecoverAutoTemporarily();
					Wait(1);
					ShadeIn();
					PortraitIn(124,1);
					Talk(124, 1, LANG_plots_58);
					PortraitOut(124, 1);
					ShadeOut();					
				end,
		after	= function ()
					FightManager:DisplayResult();
				end
	}
--]]

Plots = {}


----------------------------------------------------------------------
------TW版剧情配置 暂时不考虑 如若需要查看git log
----------------------------------------------------------------------
