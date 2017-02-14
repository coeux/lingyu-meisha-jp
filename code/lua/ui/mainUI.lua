--mainUI.lua

--========================================================================
--主UI

MainUI =
	{
		dragDropData	= {};				--拖拽数据
		menuList		= {};				--窗口队列
		IsInitSuccess	= false;			--是否初始化完成 
	};

local refCount = 0;

local desktop;
local mainShadePanel;
local floatEffectLabel = nil;				--经验和金币的浮动特效

--公会按钮
local returnToMainButton;					--公会场景返回按钮
local unionInfoButton;						--公会信息按钮
local unionBossButton;						--公会boss按钮

--系统公告
local btnLetter;							--系统公告信封
local labelLetterCount;						--消息个数标签
local letterList = {};						--当前信封个数

--走马灯
local marqueeLine;							--走马灯
local marqueePanel;							--走马灯面板
local marqueeSpeed = 70;					--走马灯移动速度
local marqueeMoveMaxDistance = -1200;		--走马灯移动最大距离后隐藏

--服务器时间
local serverTimeLabel;						--服务器时间Label

--系统设置
-- local settingButton;

local sceneType = SceneType.MainCity;			--场景类型（主城，公会，世界boss）
local heroPos;									--影响主城位置

local isMoveIn = false;							--+号默认不移入

local heroTempPos;

local ShowEffectLabel = {};

--初始化面板
function MainUI:Init()
	--变量初始化
	floatEffectLabel = nil;						--经验和金币的浮动特效	
	labelLetterCount = 0;						--消息个数标签
	letterList = {};							--当前信封个数	
	marqueeSpeed = 70;							--走马灯移动速度
	marqueeMoveMaxDistance = -1200;				--走马灯移动最大距离后隐藏	
	sceneType = SceneType.MainCity;				--场景类型（主城，公会，世界boss）	
	isMoveIn = false;							--+号默认不移入	
	heroTempPos = nil;
	
	--主UI	
	uiSystem:LoadSchemeXML('godsSenki.lay');
	uiSystem:LoadResource('godsSenki');
	uiSystem:LoadResource('xingzuo');
	desktop = uiSystem:GetDesktop('godsSenki');			
	
	SetDesktopSize(desktop);
	
	desktop:SubscribeScriptedEvent('Desktop::DragStartEvent', 'MainUI:onDragStart');
	desktop:SubscribeScriptedEvent('Desktop::DragDropEvent', 'MainUI:onDragDrop');
	desktop:SubscribeScriptedEvent('Desktop::DragDropCancelEvent', 'MainUI:onDragDropCancel');

	--========================================================================
	-- 策划用于测试时动态加载的UI控件
	--========================================================================
	--[[
	local cc1, cc2 = TopRenderStep:onPlotTest();
	if cc1 then 
		desktop:AddChild(cc1); 
		desktop:AddChild(cc2); 
	end
	--]]

	--========================================================================
	--初始化界面

	RolePortraitPanel:InitPanel(desktop);		--角色头像
	WorldPanel:InitPanel(desktop);				--世界地图
	PveEliteBarrierPanel:InitPanel(desktop);	--精英关卡
	PveBarrierPanel:InitPanel(desktop);			--关卡地图

	--PveMutipleTeamPanel:InitPanel(desktop); -- 初始化战前多队伍
	ExpeditionPanel:InitPanel(desktop);
	ExpeditionShopPanel:InitPanel(desktop);
	SelectActorPanel:InitPanel(desktop);

	PveBarrierInfoPanel:InitPanel(desktop);		--进入关卡战斗
	FbIntroductionPanel:InitPanel(desktop);		--进入战前配置
	PveAutoBattlePanel:InitPanel(desktop);		--挂机
	--PveSweepPanel:InitPanel(desktop);			--新挂机
	AutoBattleInfoPanel:InitPanel(desktop);		--挂机信息
	RoleInfoPanel:InitPanel(desktop);			--人物属性地图
	RoleAdvancePanel:InitPanel(desktop);		--角色进阶面板
	RoleRefinementPanel:InitPanel(desktop);		--角色洗练面板
	QianliPanel:InitPanel(desktop);				--潜力面板
	--TeamOrderPanel:InitPanel(desktop);			--阵型面板
	PackagePanel:InitPanel(desktop);			--背包面板
	TooltipPanel:InitPanel(desktop);			--Tooltip面板
	EquipStrengthPanel:InitPanel(desktop);		--装备强化面板
	DrawingSynthesisPanel:InitPanel(desktop);	--图纸合成面板
	GemPanel:InitPanel( desktop );				--宝石合成镶嵌面板
	GemSelectPanel:InitPanel(desktop);			--宝石选择界面		
	ZodiacSignPanel:InitPanel(desktop);			--十二宫界面
	ArenaPanel:InitPanel(desktop);				--竞技场主界面
	ArenaDialogPanel:InitPanel(desktop);
	PrestigeShopPanel:InitPanel(desktop);
	ChipShopPanel:InitPanel(desktop);
	SkillPanel:InitPanel(desktop);				--技能面板
	AllRolePanel:InitPanel(desktop);			--图鉴面板
	PlayerInfoPanel:InitPanel(desktop);			--其他玩家信息面板
	ArmoryPanel:InitPanel(desktop);				--英雄榜
	TrialFieldPanel:InitPanel(desktop);	        --试炼场
	TrialTaskPanel:InitPanel(desktop);	        --试炼任务
	--GemSynResultPanel:InitPanel(desktop);		--宝石合成结果界面
	TrainPanel:InitPanel(desktop);				--训练场初始化
	ChatPanel:InitPanel(desktop);				--聊天界面
	LimitTaskPanel:InitPanel(desktop);			--限时信息面板
	
	UnionPanel:InitPanel(desktop);				--公会信息界面
	UnionInputPanel:InitPanel(desktop);			--公会输入界面
	UnionSkillPanel:InitPanel(desktop);			--公会技能
	UnionAlterPanel:InitPanel(desktop);			--公会祭坛
	UnionMemberPanel:InitPanel(desktop);		--公会成员
	UnionListPanel:InitPanel(desktop);			--公会列表
	UnionDonatePanel:InitPanel(desktop);		--公会捐献
	UnionCreatePanel:InitPanel(desktop);		--创建公会
	UnionApplyPanel:InitPanel(desktop);			--公会申请列表界面
	UnionAdjustPosition:InitPanel(desktop);		--公会调整职位
	UnionDialogPanel:InitPanel(desktop);		--公会对话框
	UnionExplainPanel:InitPanel (desktop);            
	UnionSetBossTimePanel:InitPanel(desktop);	--设置公会boss时间
	UnionBattlePanel:InitPanel(desktop);		--社团战斗
	UnionBuZhenPanel:InitPanel(desktop);		--社团战斗布阵
	FriendAssistPanel:InitPanel(desktop);		--助战英雄选择界面
	FriendRequestPanel:InitPanel(desktop);		--好友申请界面
	FriendPanel:InitPanel(desktop);		        --好友界面
	FriendAddPanel:InitPanel(desktop);		    --添加好友界面	
	FriendListPanel:InitPanel(desktop);			--新好友列表
	FriendFlowerPanel:InitPanel(desktop);		--接受鲜花列表
	FriendApplyPanel:InitPanel(desktop);		--好友申请界面
	PlotTaskPanel:InitPanel(desktop); 			--剧情任务界面
	TaskDialogPanel:InitPanel(desktop);		    --任务NPC对话界面
	TaskAcceptAndRewardPanel:InitPanel(desktop) --任务领取交付界面
	TaskFindPathPanel:InitPanel(desktop);		--任务自动寻路界面
	TaskGuidePanel:InitPanel(desktop);			--自动任务界面
	PlotPanel:InitPanel(desktop);				--剧情界面
	UserGuidePanel:InitPanel(desktop);			--新手引导界面初始化
	-- ChroniclePanel:InitPanel(desktop); 	--编年史初始化
	
	ShopPanel:InitPanel(desktop);				--商城面板初始化
	NpcShopPanel:InitPanel(desktop);			--npc商城面板初始化
	RechargePanel:InitPanel(desktop);			--充值界面
	BuyUniversalPanel:InitPanel(desktop);		--通用购买界面
	BuyCountPanel:InitPanel(desktop);			--购买次数
	VipPanel:InitPanel(desktop);				--vip特权面板
	UserGuidePartnerPanel:InitPanel(desktop);	--新手引导送伙伴界面
	UserGuideRenamePanel:InitPanel(desktop);	--新手引导重命名
	
	TotalRechargePanel:InitPanel(desktop);		--累计充值
	InviteFriendPanel:InitPanel(desktop);		--好友邀请
	FirstRechargePanel:InitPanel(desktop);		--首次充值
	DoubleFirstChargePanel:InitPanel(desktop);	--首充双倍
	OpenPackPanel:InitPanel(desktop);			--打开礼包

	PromotionPizzaPanel:InitPanel(desktop);		--吃披萨活动
	PromotionGoldPanel:InitPanel(desktop);		--炼金活动
	RewardOnlinePanel:InitPanel(desktop);		--在线奖励
	HelpPanel:InitPanel(desktop);				--帮助界面	
	PromotionPanel:InitPanel(desktop);			--活动面板
	SystemPanel:InitPanel(desktop);				--系统界面
	QuestPanel:InitPanel(desktop);				--问题反馈界面
	LoginRewardGetPanel:InitPanel(desktop);		--累积登录奖励领取	
	ConvertPackagePanel:InitPanel(desktop);		--礼包兑换
	
	TreasurePanel:InitPanel(desktop);		--幻境探宝
	Toast:InitPanel(desktop);					--toast消息	
	WOUBossPanel:InitPanel( desktop );			--世界boss
	UnionSceneUIPanel:InitPanel(desktop);		--公会boss场景
	RmbNotEnoughPanel:InitPanel(desktop);		--水晶不足提示界面
	CoinNotEnoughPanel:InitPanel(desktop);		--金币不足提示界面

	RuneHuntPanel:InitPanel(desktop);			--符文猎魔界面
	RuneInlayPanel:InitPanel(desktop);			--符文镶嵌界面
	RuneComposePanel:InitPanel(desktop);			--符文镶嵌界面
--	RunePanel:InitPanel(desktop);				--符文界面
	RuneExchangePanel:InitPanel(desktop);		--符文兑换界面	
	MorePanel:InitPanel(desktop);				--更多菜单界面
	--StarMapPanel:InitPanel(desktop);			--星图界面
	XinghunPanel:InitPanel(desktop);			--新 星魂界面
	cardPropertyPanel:InitPanel(desktop);
	--okCanelPanel:InitPanel(desktop);			--星魂选择界面，为新手
	--StarMapAttrPanel:InitPanel(desktop);		--星魂属性确定界面
	RunePackageFullPanel:InitPanel(desktop);	--符文背包满提示界面
	RuneEatAllPromptPanel:InitPanel(desktop);	--符文背包一键合成提示界面
	RuneEatPromptPanel:InitPanel(desktop);		--符文吞噬提示界面
	PveStarRewardPanel:InitPanel(desktop)		--关卡奖励界面
	ScufflePanel:InitPanel( desktop );			--乱斗场界面
	ActivityAllPanel:InitPanel(desktop);			--活动主界面			
	UpdateInfoPanel:InitPanel(desktop);			--更新公告界面
	RankPanel:InitPanel(desktop);				--排行榜界面

	ZhaomuPanel:InitPanel(desktop);				--招募抽卡界面
	ZhaomuResultPanel:InitPanel(desktop);		--结果以及演示界面

	StoryBoard:InitPanel(desktop);				--界面动画初始化
	RoleMiKuPanel:InitPanel(desktop);			--英雄迷窟界面
	RoleMiKuInfoPanel:InitPanel(desktop);		--英雄迷窟信息界面
	RoleAdvanceInfoPanel:InitPanel(desktop);	--升星确认界面初始化
	RoleAdvanceSoulPanel:InitPanel(desktop);	--兑换灵能初始化
	RoleLevelUpPanel:InitPanel(desktop);		--角色升级面板
	PartnerFirePanel:InitPanel(desktop);		--英雄分解
	--InnerTestPackPanel:InitPanel(desktop);		--内测补偿
	ChipSelectPanel:InitPanel(desktop);			--碎片选择
	EmailPanel:InitPanel(desktop);
	--EmailCheckPanel:InitPanel(desktop);
	GodPartnerForLimitTimePanel:InitPanel(desktop);	--限时神将活动
	PropertyRoundPanel:InitPanel(desktop);
	--WingActivityPanel:InitPanel(desktop);		--翅膀活动界面
	--WingActivityInfoPanel:InitPanel(desktop);	--翅膀活动信息
	WingPanel:InitPanel(desktop);				--翅膀界面
	PetPanel:InitPanel(desktop);				--宠物界面
	--WingDismissPanel:InitPanel(desktop);		--翅膀分解界面
	
	HomePanel:InitPanel(desktop);				--家界面
    CardListPanel:InitPanel(desktop);			--卡牌列表界面
	CardDetailPanel:InitPanel(desktop);			--卡牌详情界面
	CardLvlupPanel:InitPanel(desktop);			--卡牌升级弹窗
	CardRankupPanel:InitPanel(desktop);			--卡牌升星弹窗
	LovePanel:InitPanel(desktop);
	SkillStrPanel:InitPanel(desktop);			--技能升级升阶界面

	--队伍界面
	TeamPanel:InitPanel(desktop);				--队伍编制界面
	--TeamSelectPanel:InitPanel(desktop);			--队伍选择界面
	--TeamComprisePanel:InitPanel(desktop);		--队伍编辑界面
	--TeamMemberSelectPanel:InitPanel(desktop);	--队员选择界面

	PersonInfoPanel:InitPanel(desktop);			--个人信息界面
	DailySignPanel:InitPanel(desktop);			--每日签到界面

	WorldMapPanel:InitPanel(desktop);			--出城地图界面
	TaskTipPanel:InitPanel(desktop);			--任务提示界面
	BuyPowerPanel:InitPanel(desktop);			--购买体力界面
	ShopBuyPanel:InitPanel(desktop);

	BagListPanel:InitPanel( desktop )           --  背包界面
	TipsPanel:InitPanel(desktop)				-- tips界面
	ActivityRechargePanel:InitPanel(desktop)	-- 活动充返界面
	CardEventPosterPanel:InitPanel(desktop)
	CardEventPanel:InitPanel(desktop)
	ComboPro:init();
	SettingPanel:InitPanel(desktop);
	TomorrowRewardPanel:InitPanel(desktop);
	LoginRewardPanel:InitPanel(desktop);
	OpenServiceRewardPanel:InitPanel(desktop);
	RolechangePanelPanel:InitPanel(desktop);
	FirstPassRoundRewardPanel:InitPanel(desktop);
	CardCommentPanel:InitPanel(desktop);
	RankSelectActorPanel:InitPanel(desktop)    --排位界面
	HunShiPanel:InitPanel(desktop)		       --魂师界面
	SoulPanel:InitPanel(desktop)				--晶魂界面
	HunShiLevelUpPanel:InitPanel(desktop)	   --魂师升级
	CityPersonInfoPanel:InitPanel(desktop)     --主城人物点击弹窗
	UnionBattleSelectActorPanel:InitPanel(desktop) --社团战组队界面
	ChipSmashPanel:InitPanel(desktop)
	OnlineRewardPanel:InitPanel(desktop);
	WeekRewardPanel:InitPanel(desktop);
	PlantShopPanel:InitPanel(desktop);
	InventoryShopPanel:InitPanel(desktop);
	WorldScufflePanel:InitPanel(desktop);		--world乱斗场
	RoleDetailsPanel:InitPanel(desktop);
	HomeAllRolePanel:InitPanel(desktop);

	ShopSetPanel:initPanel(desktop);			-- 商店集合
	CuriosityPanel:InitPanel(desktop);
	PropertyBonusesPanel:InitPanel(desktop);
--    ProAttachPanel:InitPanel(desktop)
	AnnouncementPanel:InitPanel( desktop )
	FeedbackPanel:InitPanel(desktop);
	EverydayTipPanel:InitPanel(desktop);
	ModelChangePanel:InitPanel(desktop);
	SWeaponPanel:InitPanel(desktop)
	ThirtyDaysNotLoginRewardPanel:InitPanel(desktop);

	--========================================================================
	--放到所有界面初始化完成之后

	MenuPanel:InitPanel(desktop);				--菜单按钮界面
	
	BuyCountPanel:InitBuyCallBack();			--初始化购买的回调函数
	NewChatPanel:InitPanel(desktop);				--新的聊天
	--========================================================================
	--初始化自身数据
	
	--设置鼠标位置
	mouseCursor:SetHotPoint(0.5, 0.8);
	
	returnToMainButton = desktop:GetLogicChild('returnToMain');	

	--系统公告
	btnLetter = desktop:GetLogicChild('letter');
	labelLetterCount = btnLetter:GetLogicChild('count');

	--走马灯
	marqueePanel = desktop:GetLogicChild('marquee');
	marqueeLine = marqueePanel:GetLogicChild('infomation');
	marqueePanel.Visibility = Visibility.Hidden;
	self:SetMarqueeState(true);
	
	--服务器时间
--	serverTimeLabel = desktop:GetLogicChild('curTimeLabel');
	
	-- settingButton = desktop:GetLogicChild('setting');
	
	heroPos = Label(desktop:GetLogicChild('heroPos'));
	heroPos.Visibility = Visibility.Hidden;
	mainShadePanel = desktop:GetLogicChild('mainShade');
	mainShadePanel.Visibility = Visibility.Hidden;

	self:ShowLetter();					--显示信封

	--==========================================================================

	-- Network:Send(NetworkCmdType.req_arena_reward_countdown, {}, true);		--向服务器申请竞技场奖励的剩余时间
	Network:Send(NetworkCmdType.req_mail_info, {}, true);						--申请离线信封
	MainUI:RequestMarqueeInfoList();										--向服务器发送走马灯请求
	
	--==========================================================================
	
	timerManager:CreateTimer(GlobalData.HeartBeatPeriod, 'MainUI:HeartBeat', 0);
	
	self.IsInitSuccess = true;

end

function MainUI:IncCount()
	refCount = refCount + 1;
end

function MainUI:DecCount()
	refCount = refCount - 1;
end

function MainUI:RefCount()
	return refCount;
end

--运行过程中保持心跳请求，避免被服务器踢掉
function MainUI:HeartBeat()
	Network:Send(NetworkCmdType.req_heartbeat, {seskey = Network.serverData.seskey}, true);	
end

--销毁
function MainUI:Destroy()
	
	--========================================================================
	--销毁界面

	RolePortraitPanel:Destroy();				--角色头像
	WorldPanel:Destroy();						--世界地图
	PveEliteBarrierPanel:Destroy();			--精英关卡
	PveBarrierPanel:Destroy();					--关卡地图

	--PveMutipleTeamPanel:Destroy(); -- 战前多队伍
	ExpeditionPanel:Destroy();
	ExpeditionShopPanel:Destroy();
	SelectActorPanel:Destroy();

	PveBarrierInfoPanel:Destroy();				--进入关卡战斗
	FbIntroductionPanel:Destroy();				--进入战前配置界面
	PveAutoBattlePanel:Destroy();				--挂机
	AutoBattleInfoPanel:Destroy();				--挂机信息
	RoleInfoPanel:Destroy();					--人物属性地图
	RoleAdvancePanel:Destroy();				--角色进阶面板
	RoleRefinementPanel:Destroy();				--角色洗练面板
	QianliPanel:Destroy();						--潜力界面
	--TeamOrderPanel:Destroy();					--阵型面板
	PackagePanel:Destroy();					--背包面板
	TooltipPanel:Destroy();					--Tooltip面板
	EquipStrengthPanel:Destroy();				--装备强化面板
	DrawingSynthesisPanel:Destroy();			--图纸合成面板
	GemPanel:Destroy(  );						--宝石合成镶嵌面板
	GemSelectPanel:Destroy();					--宝石选择界面		
	ZodiacSignPanel:Destroy();					--十二宫界面
	ArenaPanel:Destroy();						--竞技场主界面
	ArenaDialogPanel:Destroy();
	PrestigeShopPanel:Destroy();
	ChipShopPanel:Destroy();
	SkillPanel:Destroy();						--技能面板
	AllRolePanel:Destroy();					--图鉴面板
	PlayerInfoPanel:Destroy();					--其他玩家信息面板
	ArmoryPanel:Destroy();						--英雄榜
	TrialFieldPanel:Destroy();	  	    		--试炼场
	TrialTaskPanel:Destroy();	  			    --试炼任务
	--GemSynResultPanel:Destroy();				--宝石合成结果界面
	TrainPanel:Destroy();						--训练场初始化
	ChatPanel:Destroy();						--聊天界面
	LimitTaskPanel:Destroy();					--限时信息面板

	UnionPanel:Destroy();						--公会信息界面
	UnionInputPanel:Destroy();					--公会输入界面
	UnionSkillPanel:Destroy();					--公会技能
	UnionAlterPanel:Destroy();					--公会祭坛
	UnionMemberPanel:Destroy();				--公会成员
	UnionListPanel:Destroy();					--公会列表
	UnionDonatePanel:Destroy();				--公会捐献
	UnionExplainPanel:Destroy();
	UnionCreatePanel:Destroy();				--创建公会
	UnionApplyPanel:Destroy();					--公会申请列表界面
	UnionAdjustPosition:Destroy();				--公会调整职位
	UnionDialogPanel:Destroy();				--公会对话框
	UnionSetBossTimePanel:Destroy();			--设置公会boss时间
	UnionBattlePanel:Destroy();					--社团战斗
	UnionBuZhenPanel:Destroy()					--社团战斗布阵
	FriendAssistPanel:Destroy();				--助战英雄选择界面
	FriendRequestPanel:Destroy();				--好友申请界面
	FriendPanel:Destroy();		     		 	--好友界面
	FriendAddPanel:Destroy();		 		 	--添加好友界面	
	FriendListPanel:Destroy();					--新好友列表
	FriendFlowerPanel:Destroy();				--接受鲜花列表
	FriendApplyPanel:Destroy();					--好友申请界面
	PlotTaskPanel:Destroy(); 					--剧情任务界面
	TaskDialogPanel:Destroy();		 		 	--任务NPC对话界面
	TaskAcceptAndRewardPanel:Destroy() --任务领取交付界面
	TaskFindPathPanel:Destroy();				--任务自动寻路界面
	TaskGuidePanel:Destroy();					--自动任务界面
	PlotPanel:Destroy();						--剧情界面
	UserGuidePanel:Destroy();					--新手引导界面初始化
	-- ChroniclePanel:Destroy(); 	--编年史初始化
	
	ShopPanel:Destroy();						--商城面板初始化
	NpcShopPanel:Destroy();						--npc商城面板初始化
	RechargePanel:Destroy();					--充值界面
	BuyUniversalPanel:Destroy();				--通用购买界面
	BuyCountPanel:Destroy();					--购买次数
	VipPanel:Destroy();						--vip特权面板
	UserGuidePartnerPanel:Destroy();			--新手引导送伙伴界面
	UserGuideRenamePanel:Destroy();			--新手引导重命名
	
	TotalRechargePanel:Destroy();				--累计充值
	InviteFriendPanel:Destroy();				--好友邀请
	FirstRechargePanel:Destroy();				--首次充值
	DoubleFirstChargePanel:Destroy();			--首充双倍
	OpenPackPanel:Destroy();					--打开礼包

	PromotionPizzaPanel:Destroy();				--吃披萨活动
	PromotionGoldPanel:Destroy();				--炼金活动
	RewardOnlinePanel:Destroy();				--在线奖励
	HelpPanel:Destroy();						--帮助界面	
	PromotionPanel:Destroy();					--活动面板
	SystemPanel:Destroy();						--系统界面
	QuestPanel:Destroy();						--问题反馈界面
	LoginRewardGetPanel:Destroy();				--累积登录奖励领取
	XinghunPanel:Destroy();					    --星魂界面
	cardPropertyPanel:Destroy();                --卡牌属性界面
	--StarMapPanel:Destroy();					--星图界面
	--okCanelPanel:Destroy();					--星魂选择界面
	--StarMapAttrPanel:Destroy();				--星魂属性确定界面
	ConvertPackagePanel:Destroy();				--礼包兑换
	
	TreasurePanel:Destroy();				--幻境探宝
	WOUBossPanel:Destroy();					--世界boss
	UnionSceneUIPanel:Destroy();
	ActivityAllPanel:Destroy(desktop);			--活动主界面
	RankPanel:Destroy(desktop);				--排行榜界面
	
	RuneHuntPanel:Destroy();			--符文猎魔界面
	RuneInlayPanel:Destroy();
	RuneComposePanel:Destroy();
	--RunePanel:Destroy(desktop);				--符文界面
	RuneExchangePanel:Destroy(desktop);		--符文兑换界面		
	RunePackageFullPanel:Destroy(desktop);		--符文背包满提示界面
	RuneEatAllPromptPanel:Destroy(desktop);	--符文背包一键合成提示界面
	RuneEatPromptPanel:Destroy(desktop);		--符文吞噬提示界面	
	ScufflePanel:Destroy( desktop );			--乱斗场界面
	
	RmbNotEnoughPanel:Destroy();				--水晶不足提示界面
	CoinNotEnoughPanel:Destroy();				--金币不足提示界面
	RoleMiKuPanel:Destroy();					--英雄迷窟界面
	RoleMiKuInfoPanel:Destroy();				--英雄迷窟信息界面
	RoleAdvanceInfoPanel:Destroy();			--升星确认界面销毁
	RoleAdvanceSoulPanel:Destroy();			--兑换灵能销毁
	RoleLevelUpPanel:Destroy();				--角色升级面板
	--InnerTestPackPanel:Destroy();				--内测补偿
	GodPartnerForLimitTimePanel:Destroy();		--限时神将
	PropertyRoundPanel:Destroy();
	--WingActivityPanel:Destroy();			--翅膀活动界面
	--WingActivityInfoPanel:Destroy();		--翅膀活动信息
	LovePanel:Destroy();
	SkillStrPanel:Destroy();				--技能升级升阶界面

	TeamPanel:Destroy();					--队伍编制界面
	--TeamSelectPanel:Destroy();				--队伍选择界面
	--TeamComprisePanel:Destroy();			--队伍编辑界面
	--TeamMemberSelectPanel:Destroy();		--队员选择界面

	PersonInfoPanel:Destroy();				--个人信息界面
	DailySignPanel:Destroy();				--每日签到界面

	WorldMapPanel:Destroy();					--世界地图界面
	TaskTipPanel:Destroy();					--任务提示界面
	BuyPowerPanel:Destroy();					--购买体力界面
	ShopBuyPanel:Destroy();
--    ProAttachPanel:Destroy()
	--========================================================================
	--放到所有界面初始化完成之后

	MenuPanel:Destroy();					--菜单按钮界面
	MorePanel:Destroy();					--更多菜单界面

	ZhaomuPanel:Destroy();					--招募抽卡界面
	ZhaomuResultPanel:Destroy();			--结果以及演示界面

	StoryBoard:Destroy();					--界面动画销毁
	PartnerFirePanel:Destroy();				--英雄分解
	ChipSelectPanel:Destroy();				--碎片选择
	EmailPanel:Destroy();
	--EmailCheckPanel:Destroy();
	WingPanel:Destroy();					--翅膀界面
	PetPanel:Destroy();						--宠物界面
	--WingDismissPanel:Destroy();
	ActivityRechargePanel:Destroy();

	TipsPanel:Destroy();
	CardEventPosterPanel:Destroy()
	CardEventPanel:Destroy()
	
	uiSystem:DestroyControl(desktop);
	uiSystem:UnloadResource('xingzuo');
	uiSystem:UnloadResource('godsSenki');
	
	BagListPanel:Destroy();               --  背包界面
	SettingPanel:Destroy();
	TomorrowRewardPanel:Destroy();
	LoginRewardPanel:Destroy();
	OpenServiceRewardPanel:Destroy();
	RolechangePanelPanel:Destroy();
	FirstPassRoundRewardPanel:Destroy();
	CardCommentPanel:Destroy();
	RankSelectActorPanel:Destroy()      --  排位界面
	HunShiPanel:Destroy()				--  魂师界面
	SoulPanel:Destroy()					--  晶魂界面
	HunShiLevelUpPanel:Destroy()        --  魂师升级
	CityPersonInfoPanel:Destroy()
	UnionBattleSelectActorPanel:Destroy()
	ChipSmashPanel:Destroy()
	OnlineRewardPanel:Destroy();
	WeekRewardPanel:Destroy();
	PlantShopPanel:Destroy();
	InventoryShopPanel:Destroy();
	WorldScufflePanel:Destroy();
	RoleDetailsPanel:Destroy();
	HomeAllRolePanel:Destroy();
	
	ShopSetPanel:Destroy();
	CuriosityPanel:Destroy();
	PropertyBonusesPanel:Destroy()
	AnnouncementPanel:Destroy()
	FeedbackPanel:Destroy();
	EverydayTipPanel:Destroy();
	NewChatPanel:Destroy();
	ModelChangePanel:Destroy();
	SWeaponPanel:Destroy();
	ThirtyDaysNotLoginRewardPanel:Destroy();
	desktop = nil;

end

--主界面更新
function MainUI:Update(Elapse)
	-- 更新走马灯
	self:UpdateMarquee(Elapse);
	
	FightPoint:Update(Elapse);


	PromotionPanel:HideControlOfActivity();					--隐藏活动相关控件

	self:NewShowFloatEffect();
	--self:testAdd(Elapse);
end

--活动
function MainUI:Active()
	uiSystem:SwitchToDesktop(desktop);
end

--获取desktoop
function MainUI:GetDesktop()
	return desktop;
end

--测试是否有显示的界面
function MainUI:IsShowMenu()
	return #(self.menuList) ~= 0;
end

--获取顶层窗口
function MainUI:GetTopMenu()
	local length = #(self.menuList);
	return self.menuList[length];
end

--检查是否已经有某个窗口
function MainUI:IsHaveMenu( menu )
	for k, v in ipairs(self.menuList) do
		if v == menu then
			return true;
		end
	end
	
	return false;
end
	
--压入
function MainUI:Push(menu)
	--新手引导，自动任务提示隐藏
	UserGuidePanel:HideAutoTaskGuide();
	
	--避免重复显示
	local length = #(self.menuList);
	if (length > 0) and (self.menuList[length] == menu) then
		print('repeat open same panel!!!');
	else
		table.insert(self.menuList, menu);
		StoryBoard:OnPopPlayingUI();
		menu:Show();
		--menu:AddStoryBoard();
	end
	
	if TaskDialogPanel == menu then
		MainUI:onHideShade();	
	else
		MainUI:onShowShade();
	end
end

--弹出
function MainUI:Pop()
	local length = #(self.menuList);
	if length > 0 then
		local menu = self.menuList[length];
		--先删除，再调用Hide，防止嵌套调用，Hide里面还有Pop
		table.remove(self.menuList, length);
		menu:Hide();
		
		if 0 == #(self.menuList) then
			--显示对话框其他区域遮罩
			MainUI:onHideShade();
		end
	end
end

--弹出所有
function MainUI:PopAll()
	local length = #(self.menuList);
	if length > 0 then
		while nil ~= self.menuList[1] do
			local menu = self.menuList[1];
			--先删除，再调用Hide，防止嵌套调用，Hide里面还有PopAll
			table.remove(self.menuList, 1);
			menu:Hide();
		end	
		
		--显示对话框其他区域遮罩
		MainUI:onHideShade();
	end
end

--========================================================================
--场景相关
--========================================================================
--返回当前场景类型
function MainUI:GetSceneType()
	return sceneType;
end

--设置当前场景类型
function MainUI:SetSceneType(t)
	sceneType = t;
end	

--保存英雄进入世界boss或者公会时候的位置坐标
function MainUI:SaveHeroTempPosition(pos)
	heroTempPos = Vector3(pos.x, pos.y, pos.z);
end

--请求进入公会
function MainUI:RequestUnionScene()
	if 0 == ActorManager.user_data.ggid then
		--请求公会列表第一页
		local msg = {};
		msg.page = 1;
		Network:Send(NetworkCmdType.req_gang_list, msg);
	else
		UnionPanel:onRequestShowUnionPanel();				--请求工会信息
	end
end

--进入公会场景
function MainUI:EnterUnionScene()
	
	local pos = ActorManager.hero:GetPosition();
	heroTempPos = Vector3(pos.x, pos.y, pos.z);
	
	if isMoveIn then
		MenuPanel:onExtentClick();
	end
	
	self:ShowUnionUI();
	sceneType = SceneType.Union;
	
	
	--设置影响位置，要在设置活动场景之后	
	ActorManager.hero:SetStartPosition( Convert2Vector3( Vector2(-100, -150) ) );
	
	if UnionBattlePanel:isUnionBattleTip() then
		ActorManager.hero:StopMove();
		local pos = resTableManager:GetValue(ResTable.npc, tostring(907), 'coord');
		ActorManager.hero:MoveTo(Vector2(pos[1],pos[2]));
		ActorManager.hero:SetFindPathType(FindPathType.union);			--设置向工会npc移动
		UnionDialogPanel:SetNpcID(907);
	end
end

--请求回到主城
function MainUI:ReturnToMainCity()
	if (SceneType.WorldBoss == MainUI:GetSceneType()) or (SceneType.UnionBoss == MainUI:GetSceneType()) then
		WOUBossPanel:LeaveBossScene();
	elseif SceneType.Scuffle == MainUI:GetSceneType() then
--[[		local okDelegate = Delegate.new(ScufflePanel, ScufflePanel.LeaveScuffleScene, 0);
		MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_mainUI_1, okDelegate);--]]
		--直接离开就好
		--ScufflePanel:LeaveScuffleScene();
	else
		--先暂停玩家移动
		ActorManager.hero:StopMove();
		
		--请求进入主城
		local newmsg = {};
		newmsg.resid = ActorManager.user_data.sceneid;
		newmsg.show_player_num = GlobalData.MaxSceneRoleNum;
		Network:Send(NetworkCmdType.req_enter_city, newmsg);
	end	
end

--回到主城场景
function MainUI:EnterMainCityScene()
	sceneType = SceneType.MainCity;	
	
	--设置影响位置，要在设置活动场景之后	
	ActorManager.hero:SetStartPosition( Convert2Vector3( Vector2(heroTempPos.x, heroTempPos.y) ) );
	
	self:ShowMainUI();
end		

--任务的浮动特效
function MainUI:ShowEffectTask(experience, coin)
	self:ShowEffectGeneral(experience, coin);
end

--金币的浮动特效
function MainUI:ShowEffectCoin(coin)
	self:ShowEffectGeneral(0, coin);
end

--通用参数的浮动特效
function MainUI:ShowEffectGeneral(experience, coin)
	local str = '';
	if (nil ~= experience) and (0 ~= experience) then
		str = str .. LANG_mainUI_2 .. experience .. '  ';
	end
	if (nil ~= coin) and (0 ~= coin) then
		str = str .. LANG_mainUI_3 .. coin .. '  ';
	end
	if '' ~= str then
		self:ShowFloatEffect(str);
	end	
end

--显示浮动特效
function MainUI:ShowFloatEffect(str)
	if nil == str or '' == str then
		return;
	end
	if nil == floatEffectLabel then
		floatEffectLabel = uiSystem:CreateControl('Label');
		floatEffectLabel.Margin = Rect(0, 0, 0, 145);
		floatEffectLabel.Size = Size(500, 40);
		floatEffectLabel.TextAlignStyle = TextFormat.MiddleCenter;
		floatEffectLabel.Horizontal = ControlLayout.H_CENTER;
		floatEffectLabel.Vertical = ControlLayout.V_CENTER;
		floatEffectLabel.Font = uiSystem:FindFont('huakang_20');
		floatEffectLabel.Pick = false;
		topDesktop:AddChild(floatEffectLabel);	
	end
	
	floatEffectLabel.Text = str;
	floatEffectLabel.Visibility = Visibility.Visible;
	floatEffectLabel.Storyboard = '';
	floatEffectLabel.Storyboard = 'storyboard.floatUp';	
end	
function MainUI:NewShowEffectGeneral(exp,coin)
	local str = '';
	if (nil ~= exp) and (0 ~= exp) then
		str = str .. LANG_mainUI_2 .. exp .. '  ';
	end
	if (nil ~= coin) and (0 ~= coin) then
		str = str .. LANG_mainUI_3 .. coin .. '  ';
	end
	if '' ~= str then
		local effectLabel = uiSystem:CreateControl('Label');
		effectLabel.Margin = Rect(0, 0, 0, 145);
		effectLabel.Size = Size(500, 40);
		effectLabel.TextAlignStyle = TextFormat.MiddleCenter;
		effectLabel.Horizontal = ControlLayout.H_CENTER;
		effectLabel.Vertical = ControlLayout.V_CENTER;
		effectLabel.Font = uiSystem:FindFont('huakang_20');
		effectLabel.Pick = false;
		effectLabel.ZOrder = 100;
		effectLabel.Text = str;
		effectLabel.Visibility = Visibility.Visible;
		topDesktop:AddChild(effectLabel);
		table.insert(ShowEffectLabel,effectLabel);
	end	
end

function MainUI:NewShowFloatEffect(Elapse)
	---[[
	if #ShowEffectLabel == 0 then
		return;
	end
	local effectLabel = ShowEffectLabel[1];
	if effectLabel.Translate.y <= -150 then
		topDesktop:RemoveChild(effectLabel);
		table.remove(ShowEffectLabel,1);
    else
		effectLabel.Opacity  = 1-(-effectLabel.Translate.y/150);
		effectLabel.Translate = Vector2(effectLabel.Translate.x,effectLabel.Translate.y-2);
	end
	--]]
end
--=======================================================================
--消息推送
--显示信封
function MainUI:ShowLetter()
	self:RefreshLetter();
end

--隐藏信封
function MainUI:HideLetter()
	btnLetter.Visibility = Visibility.Hidden;
end

--刷新信封
function MainUI:RefreshLetter()
	if #letterList > 0 then
		btnLetter.Visibility = Visibility.Visible;
		labelLetterCount.Text = tostring(#letterList);
		FriendListPanel:requireFriendList();
	else
		btnLetter.Visibility = Visibility.Hidden;
	end
end

--添加信封
function MainUI:AddLetter(letter)
	table.insert(letterList, letter);
	self:RefreshLetter();
end

--添加升级信封
function MainUI:AddLocalLetter(level)
	if TeamOpenType.pos4 == level then

	elseif TeamOpenType.pos5 == level then

	elseif FunctionOpenLevel.assist == level then
		--self:AddLetterByMessage(FunctionOpenLevel.assist, level, LANG_mainUI_6);

	elseif FunctionOpenLevel.HangUpOpenLevel == level then
		--self:AddLetterByMessage(FunctionOpenLevel.HangUpOpenLevel, level, LANG_mainUI_7);
	end
	self:RefreshLetter();
end

function MainUI:AddLetterByMessage(openLevel, currentLevel, msg)
	if openLevel == currentLevel then
		local letter = {};
		letter.msg = msg;
		table.insert(letterList, letter);
	end
end
function MainUI:formatLetterContent(content, sep)
	if sep == nil then
		sep = "%s";
	end
	local t = {}; 
	local i = 1;
	for str in string.gmatch(content, "([^"..sep.."]+)") do
		t[i] = str;
		i = i + 1;
	end
	return t;
end
--查看信封
function MainUI:ViewLetter()
	if 0 == #letterList then
		return;
	end
	local formatContents = self:formatLetterContent(letterList[1].msg,'/n');
	local contents = {};
	for _ , content in pairs(formatContents) do
		table.insert(contents,{cType = MessageContentType.Text; text = tostring(content)});
	end
	MessageBox:ShowDialog(MessageBoxType.Ok,contents);
	table.remove(letterList, 1);
	self:RefreshLetter();
end

--========================================================================
--走马灯
--========================================================================

local marqueeInfomationList = {};
local curInfomationIndex = 0;						--当前播放的消息下标
local isRunning = false;							--走马灯是否运行
local isAvailible = true;							--是否可用
local marqueeTimer = 0;							--定时器
local reqMarqueenInfoTimer = 0;					--定时从php拉取走马灯消息


--请求走马灯信息
function MainUI:RequestMarqueeInfoList()
	if reqMarqueenInfoTimer == 0 then
		reqMarqueenInfoTimer = timerManager:CreateTimer(300, 'MainUI:RequestMarqueeInfoList', 0);
	end
	local arg = VersionUpdate.serverUrl .. '/up_maquee.php?hostnum=' .. Login.hostnum .. '&domain=' .. platformSDK.m_Platform.. '&system=' .. platformSDK.m_System;
	if VersionUpdate.curLanguage == LanguageType.cn then
		curlManager:SendHttpScriptRequest(arg, '', 'MainUI:ReceiveMarqueeInfoList', 0);
	elseif VersionUpdate.curLanguage == LanguageType.tw then
		curlManager:SendHttpScriptRequest(arg, '', 'MainUI:ReceiveMarqueeInfoList', 0);
	end
		
end

--接收走马灯信息
function MainUI:ReceiveMarqueeInfoList( request )
	if request.m_Data == nil or request.m_Data == '' then
		return;
	end
	marqueeInfomationList = cjson.decode(request.m_Data);
	curInfomationIndex = 1;
	MainUI:SetMarqueeState(true)
end

--开始播放新一轮走马灯
function MainUI:StarPlayMarquee()
	if isRunning and (not isAvailible) then
		return;
	end	
	
	if marqueeInfomationList[curInfomationIndex] == nil then
		return;
	end
	
	isRunning = true;
	marqueeLine.Translate = Vector2(0, 0);				--重置位置	
	marqueePanel.Visibility = Visibility.Visible;		--显示面板
	--因聊天功能控件不存在暂时注掉，待改
	self:AnalyzeMarqueeTip(marqueeInfomationList[curInfomationIndex]);	
	if marqueeTimer ~= 0 then
		timerManager:DestroyTimer(marqueeTimer);
		marqueeTimer = 0;
	end

	--屏蔽点击事件
	marqueeLine.Pick = false;
	for index = 0, 2 do
		if marqueeLine and marqueeLine:GetLogicChild(index) then
			marqueeLine:GetLogicChild(index).Pick = false;
		end
	end
end

--更新走马灯
function MainUI:UpdateMarquee(elapse)
	if isRunning and (marqueeInfomationList ~= nil) then
		local pos = marqueeLine.Translate;
		marqueeLine.Translate = Vector2(pos.x - marqueeSpeed * elapse, pos.y);
		if marqueeLine.Translate.x < marqueeMoveMaxDistance then			--一轮更新结束
			isRunning = false;
			if curInfomationIndex < #marqueeInfomationList then				--间隔2秒播放下一个信息
				curInfomationIndex = curInfomationIndex + 1;				--下一条
				marqueeTimer = timerManager:CreateTimer(Configuration.PerInfomationUpdateTime, 'MainUI:StarPlayMarquee', 0);
			elseif curInfomationIndex == #marqueeInfomationList then		--一轮结束，间隔5分钟
				marqueePanel.Visibility = Visibility.Hidden;				--隐藏面板
				curInfomationIndex = 1;										--第一条
				marqueeTimer = timerManager:CreateTimer(Configuration.PerRoundUpdateTime, 'MainUI:StarPlayMarquee', 0);
			end		
		end
	end
end

--解析走马灯信息
function MainUI:AnalyzeMarqueeTip(tipStr)
	local preIndex = 0;
	local nextIndex = 0;
	local needAddStr;
	local colorIndex = 0;
	local font = uiSystem:FindFont('huakang_20');
	local chatFont = uiSystem:FindFont('huakang_20');
	
	local allRtb = ChatPanel:GetAllRichTextBox();
	local sysRtb = ChatPanel:GetSystemRichTextBox();
	local mainRtb = ChatPanel:GetMainRichTextBox();
	local tipcolor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
	marqueeLine:RemoveAllChildren();
	
	while true do
		preIndex = string.find(tipStr, '/');		--查找'/'所在位置
		if nil == preIndex then						--无'/'，直接使用默认颜色，白色
			marqueeLine:AddText(tipStr, tipcolor, font);
			break;									--跳出循环
		else
			needAddStr = string.sub(tipStr, 1, preIndex - 1);
			tipStr = string.sub(tipStr, preIndex+1, -1);
			if nil ~= needAddStr then				--添加默认颜色消息段
				marqueeLine:AddText(needAddStr, tipcolor, font);
			end
			
			colorIndex = tonumber(string.sub(tipStr, 1, 1));						--字体颜色
			nextIndex = string.find(tipStr, '/');									--查找'/'所在位置
			needAddStr = string.sub(tipStr, 2, nextIndex - 1);						--变颜色的消息段
			if nil ~= needAddStr then												--添加颜色消息段
				marqueeLine:AddText(needAddStr, tipcolor, font);
			end
			
			tipStr = string.sub(tipStr, nextIndex + 1, -1);
			if nil == tipStr then
				break;
			end
		end
	end
end

--设置可用状态
function MainUI:SetMarqueeState(state)
	isAvailible = state;
	isRunning = state;
	if state then	
		self:StarPlayMarquee();
	else
		marqueePanel.Visibility = Visibility.Hidden;
		if marqueeTimer ~= 0 then
			timerManager:DestroyTimer(marqueeTimer);
			marqueeTimer = 0;
		end
	end
end


--========================================================================
--服务器时间显示
--========================================================================
function MainUI:ShowServerTime(time)
--	serverTimeLabel.Text = time;
end

--========================================================================
--辅助函数
--========================================================================

function MainUI:SetHeroPos( pos )
	heroPos.Text = 'x:' .. math.floor(pos.x) .. ' y:' .. math.floor(pos.y);
end

--========================================================================
--界面响应
--========================================================================

--右上角任务按钮
function MainUI:onMissionClick()
	GodsSenki:onEnterFight();
end	

--人物按下
function MainUI:onRenWuClick()
	MainUI:Push(RoleInfoPanel);
end

--队伍按下
function MainUI:onDuiWuClick()
	--TeamOrderPanel:onShowTeamPanel();
end

--任务
function MainUI:onTask()
	PlotTaskPanel:onShow();
end

--招募
function MainUI:onYingLingDian(Args)
	if Args then
		local args = UIDragDopEventArgs(Args);
		local tag = args.m_pControl.Tag;
		if tag ~= 0 then
			ZhaomuPanel:onShow(tag);
			return;
		end
	end
	ZhaomuPanel:onShow();
end

--公会
function MainUI:onShowUnion()
	MainUI:RequestUnionScene();
--	 LimitTaskPanel:findNpc(103, FindPathType.union)
--[[	--第一次点击检查
	if MenuPanel:FunctionClick(FunctionFirstClickOpen.union) then
		--公会不需要引导
		UserGuidePanel:SetInGuiding(false);
	end

	--停止英雄移动
	ActorManager.hero:StopMove();

	MainUI:RequestUnionScene();--]]

end

--商城按下
function MainUI:onShopClick()
	-- ShopPanel:OpenShop();
	ShopSetPanel:show(ShopSetType.gameShop)
end

--聊天
function MainUI:onChat()
	--ChatPanel:Show();
	NewChatPanel:Show();
end	

--好友
function MainUI:onShowFriend()
	FriendPanel:onShowFriend();	
end

--邮件按下
function MainUI:onShowMail()
	EmailPanel:onShow();
end

--竞技场按下
function MainUI:onJiangJiChangClick()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.arena);
	ArenaPanel.flag = 0;
	ArenaPanel:ReqArenaInfo(ArenaPanel.flag);
end

--购买体力
function MainUI:onBuyPower()
	BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
end

--购买金币
function MainUI:onBuyGold()
	BuyCountPanel:ApplyData(VipBuyType.vop_do_buy_money);
end

--礼包按下
function MainUI:onOnlieReward()
	RewardOnlinePanel:ReqOnlineRewardNum()
end

--npc商城购买按下
function MainUI:onBuyClick()
	BuyPanel:OnShop();
end

--npc商城按下
function MainUI:onNpcShopClick()
	NpcShopPanel:OpenShop();
end

--世界boss按下
function MainUI:onWorldClick()
	--停止英雄移动
	ActorManager.hero:StopMove();
	
	WOUBossPanel:RequestBossFlag(1);	
end

--公会bossanxia
function MainUI:onUnionBossClick()
	WOUBossPanel:RequestBossFlag(2);
end

--背包按下
function MainUI:onBeiBaoClick()
	MainUI:Push(PackagePanel);
end

--乱斗场
function MainUI:onScuffleClick()
	--停止英雄移动
	ActorManager.hero:StopMove();
	
	ScufflePanel:onClickScuffleBtn();
end

--宝石按下
function MainUI:onBaoShiClick()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.gem);
	
	MainUI:Push(GemPanel);
end

--符文按下
function MainUI:onFuWenClick()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.rune);

	RunePanel:onShow();
end

--限时副本按下
function MainUI:onLimitRound()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.limitround);
	
	PropertyRoundPanel:onShow();
end

--技能按下
function MainUI:onJiNengClick()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.skill);
	
	self:Push(SkillPanel);
end

--升星按下
function MainUI:onShengXingClick()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.roleadvance);
	
	self:Push(RoleAdvancePanel);
end

--巨龙宝库按下
function MainUI:onJuLongBaoKuClick()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.dragon);
	
	TreasurePanel:onShowTreasure();
end

--训练场按下
function MainUI:onXunLianChangClick()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.train);
	
	Network:Send(NetworkCmdType.req_practice_info, {});
end

--更多按下
function MainUI:onGengDuoClick()
	MorePanel:onShowMore();
end

--十二宫按下
function MainUI:onShiErGongClick()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.zodiac);

	self:Push(ZodiacSignPanel);
end

--精英按下
function MainUI:onEliteClick()
	MainUI:Push(PveEliteBarrierPanel);
end

--人物升星按下
function MainUI:onRoleAdvanceClick()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.roleadvance);
	
	RoleInfoPanel:onShowAdvancePanel();
end

--试炼
function MainUI:onTrial()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.trial);
	
	TrialFieldPanel:onRequestShowTrial();
end

--系统帮助
function MainUI:onHelp()
	self:Push(HelpPanel);
end

--系统设置
function MainUI:onSystem()
	self:Push(SystemPanel);
end

--星魂
--
function MainUI:OnStarMapUI()
	--第一次点击检查
	--[[
	MenuPanel:FunctionClick(FunctionFirstClickOpen.starMap);

	StarMapPanel:ShowStarMapPanel();
	--]]
end

--潜力
function MainUI:onQianLi()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.refine);
	
	self:Push(RoleRefinementPanel);
end

--迷窟
function MainUI:onMiKu()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.miku);
	
	MainUI:Push(RoleMiKuPanel);
end

--翅膀
function MainUI:onWing()
	--第一次点击检查
	MenuPanel:FunctionClick(FunctionFirstClickOpen.wing);
	
	MainUI:Push(WingPanel);
end

--========================================================================
--拖拽响应
--========================================================================

--拖起
function MainUI:onDragStart( Args )

	local args = UIDragDopEventArgs(Args);

	if args.m_pSrcControl.TagExt == DragDropGroup.bodyEquipPackage then
		
		local image = ItemCell(args.m_pSrcControl);
		if image.Image ~= nil then
			mouseCursor.Image = image.Image;
			mouseCursor.Size = image.Size;
			mouseCursor.Visible = true;
			
--[[			--手机抖动
			appFramework:Vibrate();--]]
		else
			desktop:CancelDragDrop();
		end
		
	elseif args.m_pSrcControl.TagExt == DragDropGroup.equipPackage then	
		
		local image = ImageElement(args.m_pSrcControl);
		if image.Image ~= nil then
			mouseCursor.Image = image.Image;
			mouseCursor.Size = image.Size;
			mouseCursor.Visible = true;
			
--[[			--手机抖动
			appFramework:Vibrate();--]]
		else
			desktop:CancelDragDrop();
		end
		
	elseif args.m_pSrcControl.TagExt == DragDropGroup.joinInTeam then
		print('join team')
		--[[
		local aui = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );			--创建ArmatureUI
		local actorPid = ActorManager.user_data.team[args.m_pSrcControl.Tag];		--角色pid
		if actorPid >= 0 then
			local rolePro = TeamOrderPanel.inTeamList[actorPid].role;
			local path = GlobalData.AnimationPath .. resTableManager:GetValue(ResTable.actor, tostring(rolePro.resid), 'path') .. '/';
			AvatarManager:LoadFile(path);
			aui:LoadArmature(rolePro.actorForm);
			aui:SetAnimation(AnimationType.f_idle);

			--加载翅膀
			local wingData = rolePro.wings;
			if (wingData ~= nil) and (#wingData > 0) then
				AddWingsToUIActor(aui, wingData[1].resid);
			end 

			mouseCursor:AddChild(aui);
			mouseCursor.Size = aui.Size;
			mouseCursor.Visible = true;
			
			--手机抖动
--			appFramework:Vibrate();
		else
			desktop:CancelDragDrop();
		end
		--]]
	elseif args.m_pSrcControl.TagExt == DragDropGroup.joinInFellow then
		print('join fellow')
		--[[
		local aui = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );			--创建ArmatureUI
		local actorPid = ActorManager.user_data.fellow[args.m_pSrcControl.Tag];		--角色pid
		if actorPid >= 0 then
			local rolePro = TeamOrderPanel.inFellowList[actorPid].role;
			local path = GlobalData.AnimationPath .. resTableManager:GetValue(ResTable.actor, tostring(rolePro.resid), 'path') .. '/';
			AvatarManager:LoadFile(path);
			aui:LoadArmature(rolePro.actorForm);
			aui:SetAnimation(AnimationType.f_idle);

			--加载翅膀
			local wingData = rolePro.wings;
			if (wingData ~= nil) and (#wingData > 0) then
				AddWingsToUIActor(aui, wingData[1].resid);
			end 

			mouseCursor:AddChild(aui);
			mouseCursor.Size = aui.Size;
			mouseCursor.Visible = true;
			
			--手机抖动
--			appFramework:Vibrate();
		else
			desktop:CancelDragDrop();
		end
		--]]
	elseif args.m_pSrcControl.TagExt == DragDropGroup.leaveTeam then
		print('leave team')
	--[[
		local aui = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );			--创建ArmatureUI
		local role = TeamOrderPanel:getRoleFromRoleList(args.m_pSrcControl.Tag);	--获取角色		
		--队伍页未上阵，或小伙伴页未上阵
		if (-1 == role.teamIndex and TeamOrderPanel:isTeamPage()) or (-1 == role.fellowIndex and not TeamOrderPanel:isTeamPage()) then
			local path = GlobalData.AnimationPath .. resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'path') .. '/';
			AvatarManager:LoadFile(path);
			aui:LoadArmature(role.actorForm);
			aui:SetAnimation(AnimationType.f_idle);

			--加载翅膀
			local wingData = role.wings;
			if (wingData ~= nil) and (#wingData > 0) then
				AddWingsToUIActor(aui, wingData[1].resid);
			end 

			mouseCursor:AddChild(aui);
			mouseCursor.Size = aui.Size;
			mouseCursor.Visible = true;
			
			--手机抖动
			appFramework:Vibrate();
		else
			desktop:CancelDragDrop();
		end
		--]]
	elseif args.m_pSrcControl.TagExt == DragDropGroup.runeInPackage then	
		
		local rb = RadioButton(args.m_pSrcControl);
		local item;
		if nil ~= rb then
			item = ItemCell(rb:GetLogicChild('itemCell'));
		end
		if rb ~= nil and nil ~= item and nil ~= item.Image then
			mouseCursor.Image = item.Image;
			mouseCursor.Size = item.Size;
			mouseCursor.Visible = true;
			
--[[			--手机抖动
			appFramework:Vibrate();--]]
		else
			desktop:CancelDragDrop();
		end

	elseif args.m_pSrcControl.TagExt == DragDropGroup.runeEquip then	
		
		local image = ItemCell(args.m_pSrcControl);
		if image.Image ~= nil then
			mouseCursor.Image = image.Image;
			local imgStr = Converter.Image2String(image.Image);
			local index = string.find(imgStr, 'fuwen_lv');
			if nil == index then
				mouseCursor.Size = image.Size;
				mouseCursor.Visible = true;
				
--[[				--手机抖动
				appFramework:Vibrate();--]]
			else
				desktop:CancelDragDrop();
			end
		else
			desktop:CancelDragDrop();
		end	
		
	end
	
end

--拖拽放下
function MainUI:onDragDrop( Args )

	local args = UIDragDopEventArgs(Args);
	
	if (args.m_pSrcControl.TagExt == DragDropGroup.runeEquip or args.m_pSrcControl.TagExt == DragDropGroup.runeInPackage) and
		(args.m_pDesControl.TagExt == DragDropGroup.runeEquip or args.m_pDesControl.TagExt == DragDropGroup.runeInPackage)
	then --符文合成，装备或卸下
		if args.m_pSrcControl.Tag ~= args.m_pDesControl.Tag then
			RunePanel:onSwitchPos(args.m_pSrcControl.Tag, args.m_pDesControl.Tag);
		end
		MainUI:onDragDropCancel();
		return;
	end
	
	if (args.m_pSrcControl.TagExt == args.m_pDesControl.TagExt) and (DragDropGroup.joinInTeam ~= args.m_pSrcControl.TagExt) then
		MainUI:onDragDropCancel();
		return;
	end
	
	if (args.m_pSrcControl.TagExt == DragDropGroup.bodyEquipPackage) and
		(args.m_pDesControl.TagExt == DragDropGroup.equipPackage)
	then --脱下		
		if ((SystemTaskId.pub + 1) > Task:getMainTaskId()) or (ActorManager.user_data.role.lvl.level <= 3) then
			desktop:CancelDragDrop();
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_mainUI_11);
			return;
		end
		--测试背包是否满了
		if Package:IsFull() then
			desktop:CancelDragDrop();
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_mainUI_12);
			return;
		end
		
		local msg = {}
		msg.pid = RoleInfoPanel.role.pid;
		msg.eid = RoleInfoPanel.role.equips[tostring(args.m_pSrcControl.Tag)].eid;
		msg.flag = EquipTakeOnOff.off;
		msg.slot_pos = args.m_pSrcControl.Tag;
		
		Network:Send(NetworkCmdType.req_wear_equip, msg);

	elseif (args.m_pSrcControl.TagExt == DragDropGroup.equipPackage) and
		(args.m_pDesControl.TagExt == DragDropGroup.bodyEquipPackage)
	then --穿上

		local msg = {}
		msg.pid = RoleInfoPanel.role.pid;
		msg.eid = RoleInfoPanel.equipList[args.m_pSrcControl.Tag].eid;
		msg.flag = EquipTakeOnOff.on;
		msg.slot_pos = args.m_pDesControl.Tag;
		
		Network:Send(NetworkCmdType.req_wear_equip, msg);
	
	elseif (args.m_pSrcControl.TagExt == DragDropGroup.joinInTeam) and
		(args.m_pDesControl.TagExt == DragDropGroup.leaveTeam or args.m_pDesControl.TagExt == DragDropGroup.leaveTeamPanel)	
	then --下阵		
		if 0 == ActorManager.user_data.team[args.m_pSrcControl.Tag] then
			--主角不可下阵
			MainUI:onDragDropCancel();
			TeamOrderPanel:ShowMessageBox();
			return;
		else
			TeamOrderPanel:LeaveTeam(args.m_pSrcControl.Tag);
		end	
		
	elseif (args.m_pSrcControl.TagExt == DragDropGroup.joinInTeam) and
		(args.m_pDesControl.TagExt == DragDropGroup.joinInTeam)
	then --阵型中的角色位置交换		
		TeamOrderPanel:ExchangeRolePosition(args.m_pSrcControl.Tag, args.m_pDesControl.Tag);
	
	elseif (args.m_pSrcControl.TagExt == DragDropGroup.joinInFellow) and
		(args.m_pDesControl.TagExt == DragDropGroup.leaveTeam or args.m_pDesControl.TagExt == DragDropGroup.leaveTeamPanel)	
	then --下阵
		TeamOrderPanel:LeaveFellow(args.m_pSrcControl.Tag);	
		
	elseif (args.m_pSrcControl.TagExt == DragDropGroup.leaveTeam) and
		(args.m_pDesControl.TagExt == DragDropGroup.joinInTeam)
	then --上阵	
		local teamIndex = TeamOrderPanel:GetFirstEmptyPosition();
		if nil ~= teamIndex then
			--有空位置，可以加入阵型队列
			local role = TeamOrderPanel:getRoleFromRoleList(args.m_pSrcControl.Tag);
			--不在小伙伴中
			if role.fellowIndex == -1 then
				TeamOrderPanel:JoinInTeam(args.m_pSrcControl.Tag, teamIndex);
			else
			--在小伙伴中
				TeamOrderPanel:JoinInTeamFromFellow(args.m_pSrcControl.Tag, teamIndex);
			end
			
		else
			--没有空位置，替换原来位置上的角色
			if 0 == ActorManager.user_data.team[args.m_pDesControl.Tag] then
				--主角不可下阵
				MainUI:onDragDropCancel();
				TeamOrderPanel:ShowMessageBox();
				return;
			else
				local role = TeamOrderPanel:getRoleFromRoleList(args.m_pSrcControl.Tag);
				--不在小伙伴队伍中
				if role.fellowIndex == -1 then
					TeamOrderPanel:LeaveJoinTeam(args.m_pSrcControl.Tag, args.m_pDesControl.Tag);
				else
				--在小伙伴队伍中，小伙伴要下阵
					TeamOrderPanel:ExchangeTeamFellow(args.m_pDesControl.Tag, nil, args.m_pSrcControl.Tag);
				end	
			end	
		end
	
	elseif (args.m_pSrcControl.TagExt == DragDropGroup.leaveTeam) and
		(args.m_pDesControl.TagExt == DragDropGroup.joinInFellow)
	then --上阵	
		local teamIndex = TeamOrderPanel:GetFellowFirstEmptyPosition();
		if nil ~= teamIndex then
			--有空位置，可以加入阵型队列
			local role = TeamOrderPanel:getRoleFromRoleList(args.m_pSrcControl.Tag);
			--不在队伍中
			if role.teamIndex == -1 then
				TeamOrderPanel:JoinInFellow(args.m_pSrcControl.Tag, teamIndex);
			else
			--在小伙伴中
				TeamOrderPanel:JoinInFellowFromTeam(args.m_pSrcControl.Tag, teamIndex);				
			end
			
		else
			local role = TeamOrderPanel:getRoleFromRoleList(args.m_pSrcControl.Tag);
			--不在队伍中
			if role.teamIndex == -1 then
				TeamOrderPanel:LeaveJoinFellow(args.m_pSrcControl.Tag, args.m_pDesControl.Tag);
			else
			--在队伍中，队伍中伙伴要下阵
				TeamOrderPanel:ExchangeTeamFellow(nil, args.m_pDesControl.Tag, args.m_pSrcControl.Tag);
			end	
		end
		
	end

	MainUI:onDragDropCancel();

end

--拖拽取消
function MainUI:onDragDropCancel( )

	mouseCursor:RemoveAllChildren();
	mouseCursor.Image = nil;
	mouseCursor.Visible = false;
	self.dragDropData = {};

end

--测试战斗结果
function MainUI:onTestFight()
	local msg = {};
	msg.test_total_num = 10;
	msg.cast_resid = 1002;
	msg.cast_lv = 2;
	msg.target_resid = 1002;
	msg.target_lv = 20;
	Network:Send(NetworkCmdType.req_test_arena, msg);
end	

--对话框遮罩显示
function MainUI:onShowShade()
	mainShadePanel.Visibility = Visibility.Visible;
end

--对话框遮罩隐藏
function MainUI:onHideShade()
	mainShadePanel.Visibility = Visibility.Hidden;
end	

--克隆遮罩
function MainUI:CloneHideShade()
	return mainShadePanel:Clone();
end

--显示主界面UI控件
function MainUI:ShowMainUI()
	RolePortraitPanel:Show();								--隐藏头像界面
	TaskGuidePanel:Show();								
	PromotionPanel:RefreshActivityPanel();					--显示活动相关控件
	RolePortraitPanel:RefreshActivityPanel();				--显示在线礼包
	TaskTipPanel:onShow();
	MenuPanel:onShow();
	PromotionPanel:HideControlOfActivity();					--隐藏活动相关控件
	--ScufflePanel:onHide();
	self:ShowLetter();										--显示信封
	self:SetMarqueeState(true);							--隐藏走马灯
	UnionSceneUIPanel:CloseUnionSceneUI();					--隐藏公会相关控件
	WOUBossPanel:CloseBossPanel();							--关闭boss界面
--	serverTimeLabel.Visibility = Visibility.Visible;		--服务器时间
	-- settingButton.Visibility = Visibility.Visible;			--系统设置
	returnToMainButton.Visibility = Visibility.Hidden;		--返回按钮
end

--隐藏主界面UI控件
function MainUI:HideMainUI()
	RolePortraitPanel:Hide();								--隐藏头像界面
	TaskGuidePanel:Hide();						
	MenuPanel:onHideMenu();
	UserGuidePanel:HideAutoTaskGuide();			
	PromotionPanel:HideControlOfActivity();					--隐藏活动相关控件
	TaskTipPanel:Hide();
	MenuPanel:Hide();
	TaskFindPathPanel:Hide();								--隐藏自动寻路
	self:HideLetter();										--隐藏信封
	UnionSceneUIPanel:CloseUnionSceneUI();					--隐藏公会相关控件
	WOUBossPanel:CloseBossPanel();							--关闭boss界面
--	serverTimeLabel.Visibility = Visibility.Hidden;			--服务器时间
	-- settingButton.Visibility = Visibility.Hidden;			--系统设置
	returnToMainButton.Visibility = Visibility.Hidden;		--返回按钮
end

--显示公会相关控件
function MainUI:ShowUnionUI()
	self:HideMainUI();
	WOUBossPanel:CloseBossPanel();							--关闭boss界面
	self:ShowLetter();
	--returnToMainButton.Visibility = Visibility.Visible;		--返回按钮
	UnionSceneUIPanel:ShowUnionSceneUI();					--显示公会相关控件
end

--显示世界boss准备界面
function MainUI:ShowWorldBossUI()
	self:PopAll();											--隐藏界面
	self:HideMainUI();
	WOUBossPanel:ShowBossPanel();							--打开boss UI
	self:SetMarqueeState(false);							--隐藏走马灯
	--returnToMainButton.Visibility = Visibility.Visible;		--返回按钮
end

--显示大竞技场界面
function MainUI:ShowScuffleUI()
	self:HideMainUI();
	returnToMainButton.Visibility = Visibility.Visible;		--返回按钮
--	serverTimeLabel.Visibility = Visibility.Visible;			--服务器时间
end

--关闭应用
function MainUI:TerminateApp()
	appFramework:Terminate();
end

--显示更新公告
function MainUI:ShowUpdateInfo()
	MainUI:Push(UpdateInfoPanel);
end
