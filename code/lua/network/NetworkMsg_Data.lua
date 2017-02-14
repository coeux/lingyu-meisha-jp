--NetworkMsg_Data.lua

--========================================================================
--数据变化

NetworkMsg_Data =
	{
        heroPro    = {};        --升级前英雄属性值
	};


--体力更改
function NetworkMsg_Data:onChangePower(msg)
	ActorManager.user_data.power = msg.now;
	ActorManager.user_data.powerProgress = ActorManager.user_data.power;
	if msg.is_in_limit_activity and msg.is_in_limit_activity == 1 then
		if msg.limit_consume_power_reward then
			ActorManager.user_data.reward.limit_activity.limit_consume_power_reward = msg.limit_consume_power_reward;
		end
		if msg.limit_consume_power then
			ActorManager.user_data.reward.limit_activity.limit_consume_power= msg.limit_consume_power;
		end
		local YN = ActivityRechargePanel:IsCanGetReward();
		RolePortraitPanel:activityLimitTip(YN);
	end
	
	if (ActorManager.user_data.power >= Configuration.MaxPower) and (msg.now < Configuration.MaxPower) then
		--体力消耗了，开始恢复计时
		local msg = {};
		Network:Send(NetworkCmdType.req_gen_power, msg, true);	--申请体力计时
	end
	
	--重新注册推送
	--Push:RegisterPush();

	RolePortraitPanel:RefreshPowerColor();
	RoleMiKuPanel:RefreshPowerColor();
	--PveBarrierPanel:RefreshPowerColor();
	
	uiSystem:UpdateDataBind();
end

--体力购买结果
function NetworkMsg_Data:onRetBuyPower()
	BuyPowerPanel:onGold()
end

--金币更改
function NetworkMsg_Data:onChangeMoney(msg)
	if not MainUI.IsInitSuccess then
		return;
	end
	
	--金币增加时显示增加的浮动特效	
	if msg.now > ActorManager.user_data.money then
		if PackagePanel:IsVisible() and not GlobalData.IsOpenTreasurePackage then				--包裹处于打开状态
			MainUI:ShowEffectCoin(msg.now - ActorManager.user_data.money);	
		end
	end
	
	ActorManager.user_data.money = msg.now;
	RolePortraitPanel:effectPlay("jinbi");
	uiSystem:UpdateDataBind();

end

--水晶更改
function NetworkMsg_Data:onChangeRmb(msg)
	local nowRbm = ActorManager.user_data.rmb;
	ActorManager.user_data.rmb = msg.now;
	RolePortraitPanel:effectPlay("zuanshi");
	uiSystem:UpdateDataBind();
	local diffRmb = nowRbm - ActorManager.user_data.rmb;
end

--灵能改变
function NetworkMsg_Data:onChangeSoul(msg)
	ActorManager.user_data.soul = msg.now;
end

--经验更改
function NetworkMsg_Data:onChangeExp(msg)
	local role = ActorManager:GetRole(msg.pid);
	--显示经验提升的浮动特效
	if TrainPanel:IsVisible() then	
		TrainPanel:ShowFloatExpEffect(msg.now - role.lvl.exp);			--训练场
	end

	role.lvl.exp = msg.now;	
	ActorManager:AdjustRoleLevel(role, role.lvl);
	uiSystem:UpdateDataBind();
	if CardLvlupPanel.isShow then
		CardLvlupPanel:setInfo();
	end
end

--角色属性改变
function NetworkMsg_Data:onChangePro(msg)
	local role = ActorManager:GetRole(msg.pid);
	    
    --缓存英雄的数据
    if msg.pid == 0 then
        self.heroPro = clone(role.pro);
		self.heroPro.level = role.lvl.level;
    end
    
	ActorManager:AdjustRolePro(role.job, role.pro, msg.pro);
	
	ActorManager:UpdateFightAbility();
	--[[
	if TeamOrderPanel:IsVisible() then
		--队伍界面可见刷新战力
		TeamOrderPanel:refreshTotalFightPoint();
	end
	--]]
	if FbIntroductionPanel:IsVisible() then
		FbIntroductionPanel:refreshFp();
	end
end	

-- 复数个角色属性变化
function NetworkMsg_Data:onChangePros(msg)
	for _, pro_nt in pairs(msg.pro_list) do
		local role = ActorManager:GetRole(pro_nt.pid);
		--缓存英雄的数据
	    if msg.pid == 0 then
		    self.heroPro = clone(role.pro);
			self.heroPro.level = role.lvl.level;
	    end
    
		ActorManager:AdjustRolePro(role.job, role.pro, pro_nt.pro);
	end
	
	ActorManager:UpdateFightAbility();
	if FbIntroductionPanel:IsVisible() then
		FbIntroductionPanel:refreshFp();
	end
end	

-- 复数个角色属性变化
--碎片改变
function NetworkMsg_Data:onChangeChip(msg)
	Package:ChangeChip( msg );
end

--友情点更改
function NetworkMsg_Data:onChangeYouQing( msg )
	ActorManager.user_data.fpoint = msg.now;
	uiSystem:UpdateDataBind();
end

--伙伴升阶
function NetworkMsg_Data:onPartnerQualityUp( msg )
	--数据修改
	local role = ActorManager:GetRole(msg.pid);
	role.rank = role.rank + 1;
	role.quality = role.quality + 1;
	CardRankupPanel:recordProperInfo(role) 
	CardRankupPanel:Refresh(role);
	CardRankupPanel:success();
	CardRankupPanel:StarUpgradeSound(role.resid)
	if UserGuidePanel:IsInGuidence(UserGuideIndex.upstar, 1) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.upstar);
	end
end

--角色升阶后开启对应技能
function NetworkMsg_Data:onSkillOpen(msg)
	local role = ActorManager:GetRole(msg.pid);
	if role then
		for _,skill in ipairs(role.skls) do
			if skill.resid == msg.skillid then
				skill.level = skill.level + 1;
				break;
			end
		end	
	end
end

--碎片兑换灵能
function NetworkMsg_Data:onChipToSoul( msg )
	RoleAdvanceSoulPanel:refreshChipList();
	RoleAdvancePanel:refreshRoleInfo();
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_NetworkMsg_Data_1 .. msg.soul .. LANG_NetworkMsg_Data_2);
end

--潜力更改
function NetworkMsg_Data:onChangePotential(msg)
	QianliPanel:setBtn(false);
	local role = ActorManager:GetRole(msg.pid);
	local attribute = QianliPanel:getCurrentAttribute();
	if attribute == 1 then
		 role.potential_1 = role.potential_1 + msg.delta;
		 --ToastMove:CreateToast('等级增加'..' '..tostring(msg.delta), Configuration.GreenColor);
	elseif attribute == 2 then
		role.potential_2 = role.potential_2 + msg.delta;
		--ToastMove:CreateToast('等级增加'..' '..tostring(msg.delta), Configuration.GreenColor);
	elseif attribute == 3 then
		role.potential_3 = role.potential_3 + msg.delta;
		--ToastMove:CreateToast('等级增加'..' '..tostring(msg.delta), Configuration.GreenColor);
	elseif attribute == 4 then
		role.potential_4 = role.potential_4 + msg.delta;
		--ToastMove:CreateToast('等级增加'..' '..tostring(msg.delta), Configuration.GreenColor);
	elseif attribute == 5 then
		role.potential_5 = role.potential_5 + msg.delta;
		--ToastMove:CreateToast('等级增加'..' '..tostring(msg.delta), Configuration.GreenColor);
	end
	ActorManager:AdjustRolePro(role.job, role.pro, msg.pro);
	QianliPanel:refreshQianli(msg);
	local effect = PlayEffectScale('shengji_output/', Rect(240,30,0,0), 'shengji', 4, 4, HomePanel:returnHomePanel():GetLogicChild('navi'));
	--更新角色潜力提示信息
	if QianliPanel:IsRoleCanAttributeUp(role) then
		CardListPanel:SetAttritubeState(true);
	else
		CardListPanel:SetAttritubeState(false);
	end
end

--无法提升潜力回调
function NetworkMsg_Data:onChangePotentialError(msg)
	QianliPanel:setBtn(false);
	if msg.code == 1300 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_1300);
	end
end

--更改等级
function NetworkMsg_Data:onChangeLevel(msg)
	local role = ActorManager:GetRole(msg.pid);
	
	--显示升级的浮动特效
	if TrainPanel:IsVisible() then
		TrainPanel:ShowFloatLevelEffect(msg.level);						--训练场
	end
	
	local oldLevel = role.lvl.level;

	role.lvl.level = msg.level;	
	ActorManager:AdjustRoleLevel(role, role.lvl);
	if 0 == msg.pid then
		UserGuidePanel:SetIsLvUp(true)
		--战斗过程中角色升级，通知结算界面显示(只有主角提示升级)
		FightManager:SetHeroLevelUp(msg.level);

		--更改主角的颜色显示
	--	ActorManager.hero:ChangeNameColor(msg.level);
		
		--刷新角色Portrai上的名字颜色
		RolePortraitPanel:Refresh();

		--处于战斗状态延迟触发等级提升
		--GodsSenki:FireHeroLevelUp(oldLevel, msg.level);
		if platformSDK.m_Platform == 'bdgame' then
			local loginArgs = Login:onGetLoginArgs();
			local theArgs = {};
			theArgs["zoneId"] = loginArgs.zoneId;
			theArgs["zoneName"] = loginArgs.zoneName;
			theArgs["roleName"] = ActorManager.user_data.name;
			local level = ActorManager.user_data.role.lvl.level;
			if level == nil then
				theArgs["roleLevel"] = 1;
			else
				theArgs["roleLevel"] = ActorManager.user_data.role.lvl.level;
			end
			theArgs["roleId"] = ActorManager.user_data.uid;
			local encodedMsg = cjson.encode(theArgs);
			NetworkMsg_EnterGame:onSendLoginGameData(encodedMsg);
		end
		uiSystem:UpdateDataBind();
	end
	
	--主界面角色头像
	RolePortraitPanel:Refresh();

	--主界面的活动显示
	PromotionPanel:RefreshActivityStatus();

	if msg.growing_reward and msg.pid == 0 then
		ActorManager.user_data.reward.growing_reward = msg.growing_reward;
	end

	--更新每日任务状态
	Task:updateDailytask();
end

--爱恋度等级提升
function NetworkMsg_Data:onChangeLoveLevel(msg)
	--Debug.print_var_dump(msg);
	if msg.pid == 0 then
		ActorManager.user_data.role.lvl.lovelevel = msg.lovelevel;
	else
		for _, v in pairs(ActorManager.user_data.partners) do
			if v.pid == msg.pid then
				v.lvl.lovelevel = msg.lovelevel;
			end
		end
	end
end

--战历改变
function NetworkMsg_Data:onChangeBattleExp(msg)
	-- ActorManager.user_data.battexp = msg.now;
	print(" no no no no no no no no no no no no no no no no no ");
	print("                   no battexp");
	print(" no no no no no no no no no no no no no no no no no ");
end

--鼓舞值改变
function NetworkMsg_Data:onChangeInspire(msg)
	local change = msg.progress - ActorManager.user_data.counts.n_guwu[tostring(msg.flag)].progress;
	ActorManager.user_data.counts.n_guwu[tostring(msg.flag)] = {progress = msg.progress, v = msg.v, stamp_yb = msg.stamp_yb, stamp_coin = msg.stamp_coin};

	if tonumber(InspireType.scuffle) == msg.flag then
		ScufflePanel:refreshInspireInfo();
	else
		WOUBossPanel:RefreshInspire();
		ToastMove:CreateToast(string.format(LANG__31, change), Configuration.GreenColor);
	end

end

--编年史签到总天数
function NetworkMsg_Data:onChangeChronicleSum(msg)
	ActorManager.user_data.chronicle.chronicle_sum = msg.now;
end

function NetworkMsg_Data:onChangeExpeditionCoin(msg)
	ActorManager.user_data.expedition.expeditioncoin = msg.now;
end

--[[
function NetworkMsg_Data:onChangeTreasure(msg)
	ActorManager.user_data.round.treasure = msg.treasure;
	ActorManager.user_data.round.treasure_cur = ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin;
	if ActorManager.user_data.round.treasure_cur < 0 then
		ActorManager.user_data.round.treasure_cur = 0;
	end
	uiSystem:UpdateDataBind();
end
--]]
function NetworkMsg_Data:onChangeProfit(msg)
    ActorManager.user_data.round.profit = msg.now
end

function NetworkMsg_Data:onChangeRobTimes()
	ActorManager.user_data.round.n_rob = ActorManager.user_data.round.n_rob + 1;
end

function NetworkMsg_Data:onnaviClickNumAdd(msg)
	local roleInfo = ActorManager:GetRoleFromResid(msg.resid);
	roleInfo.naviClickNum1 = roleInfo.naviClickNum1 + 1 ;
end

--换主角失败错误处理
function NetworkMsg_Data:onRolechangeError(msg)
	if msg.code == 3100 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ROLECHANGE_ERROE_NOT_LV_ENOUGH);
	elseif msg.code == 3101 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ROLECHANGE_ERROE_SAME_ROLE);
	elseif msg.code == 506 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ROLECHANGE_ERROE_NOT_YB_ENOUGH);
	end
end

--换主角成功处理
function NetworkMsg_Data:change_roletype(msg)
	local contents = {};
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_ROLECHANGE_SUCCES_INFO_1})
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_ROLECHANGE_SUCCES_INFO_2})
	local okDelegate = Delegate.new(NetworkMsg_Data, NetworkMsg_Data.change_roletype_end, 0);
	MessageBox:ShowDialog(MessageBoxType.Ok, contents, okDelegate);
end

--换主角成功返回登录界面
function NetworkMsg_Data:change_roletype_end()
	appFramework:Reset();
end
	
--魂师资源改变
function NetworkMsg_Data:nt_soulvalue_change(msg)
	ActorManager.user_data.counts.soulvalue = msg.now;
end

--魂师信息通知
function NetworkMsg_Data:nt_soulinfo_change(msg)
	ActorManager.user_data.counts.soulranknum 		= msg.soulranknum;
	ActorManager.user_data.counts.soulid			= msg.soulid;
	ActorManager.user_data.counts.soul_node_infos 	= msg.soul_node_info;
	HunShiPanel:ReqNextData();
end

--魂师请求开启结果
function NetworkMsg_Data:ret_soulid_open(msg)
	if msg.code == 1 then
		print(333333)
	end
end


function NetworkMsg_Data:ret_soulnode_pro(msg)
	HunShiPanel:setNextData(msg.node_info);
	HunShiPanel:refreshData();
end

--请求开启魂力错误处理
function NetworkMsg_Data:retsoulidopenError(msg)
	if msg.code == 1510 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_hunshi_8);
	elseif msg.code == 1511 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_hunshi_8);
	end
end

function NetworkMsg_Data:ChipValueUpdate(msg)
	ShopSetPanel:UpdateValueChip(msg.id, msg.buyprice, msg.trend);
	-- ChipShopPanel:UpdateValue(msg.id, msg.buyprice, msg.trend);
	ChipSmashPanel:UpdateValue(msg.id, msg.price, msg.trend);
	BuyUniversalPanel:UpdateValue(msg.id, msg.buyprice);
end

function NetworkMsg_Data:GenInCode(msg)
	MessageBox:ShowDialog(MessageBoxType.Ok, string.format(LANG_NetworkMsg_Data_3, msg.inheritance_code));
end

function NetworkMsg_Data:GetModel(msg)
	ActorManager.main_model = msg.model;
	ActorManager:ChangeHeroModel();
end

function NetworkMsg_Data:ChangeModel(msg)
	ActorManager.main_model = msg.model;
	ModelChangePanel:setModel();
	ActorManager:ChangeHeroModel();
end
