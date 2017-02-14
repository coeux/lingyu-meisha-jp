--NetworkMsg_Pub.lua

--======================================================================
--酒馆

NetworkMsg_Pub =
	{
	};


--刷新酒馆
function NetworkMsg_Pub:onRefreshPub( msg )
	if ActorManager.user_data.role.draw_num then
		ActorManager.user_data.role.draw_num = ActorManager.user_data.role.draw_num + msg.draw_num;
	end

	if msg.is_in_limit_activity == 1 then
		ActorManager.user_data.reward.limit_activity.limit_draw_ten = ActorManager.user_data.reward.limit_activity.limit_draw_ten + 1;
		if msg.limit_draw_reward then
			ActorManager.user_data.reward.limit_activity.limit_draw_ten_reward = msg.limit_draw_reward;
		end;
		local YN = ActivityRechargePanel:IsCanGetReward();
		RolePortraitPanel:activityLimitTip(YN);
	end

	if msg.is_ten_diamond and msg.is_ten_diamond == 1 then
		ActorManager.user_data.role.draw_ten_diamond = ActorManager.user_data.role.draw_ten_diamond + 1;
	end
	if msg.draw_reward then
		ActorManager.user_data.role.draw_reward = msg.draw_reward;
	end

	if msg.is_pub_4 ~= nil then
		ActorManager.user_data.extra_data.is_pub_4 = msg.is_pub_4;
	end
	ZhaomuResultPanel:refresh(msg);
	ZhaomuResultPanel:Show();
	ZhaomuPanel.rest_free_times = msg.flush1times;
	ZhaomuPanel:refreshCallBackTime(msg.left_flush_seconds);
	NetworkMsg_LoveTask:reqLoveTask();
end

--返回获取刷新时间
function NetworkMsg_Pub:onRefreshTime( msg )
	ZhaomuPanel:refreshTimeFromServer(msg);
end

--伙伴雇佣（碎片合成英雄）
function NetworkMsg_Pub:onHirePartner( msg )
	CardDetailPanel:setBtn(false);
	ActorManager:AddRole(msg.partner);
	if PackagePanel:IsVisible() then
		PackagePanel:RefreshChipPage();
	end	
	LimitTaskPanel:updatePartnerTask(LimitNews.getpartner,msg.partner.resid)
	HomePanel.isGetRolePanelShow = true;
	HomePanel:RoleShow();
	local ctrl = {};
	ctrl.m_pControl = {};
	ctrl.m_pControl.TagExt = msg.partner.resid;
	CardDetailPanel:roleCloseClick();
	HomePanel:ShowRoleInfo(ctrl);
	HomePanel:UpdateCurentRole(msg.partner.resid, msg.partner.pid);
	NetworkMsg_LoveTask:reqLoveTask();
	MutipleTeam:addPartnerToDefaultTeam(msg.partner.pid);
	CardRankupPanel:IsHaveRoleCanAdv();
	PlayEffectScale('shengji_output/', Rect(240,30,0,0), 'shengji', 4, 4, HomePanel:returnHomePanel():GetLogicChild('navi'));--获得成功后的动画
	HomePanel:showGetRolePanel(msg.partner.resid);
end

--新手刷新伙伴
function NetworkMsg_Pub:onGuidenceHireHero( msg )
	ActorManager:AddRole(msg.partner);
	if PackagePanel:IsVisible() then
		PackagePanel:RefreshChipPage();
	end
	
	local item = {};
	item.resid = msg.partner.resid;
	item.reduced = 0;
	item.count = 1;	
	print('NetworkMsg_Pub:onGuidenceHireHero');
end

--伙伴解雇
function NetworkMsg_Pub:onFirePartner( msg )
	if ActorManager.user_data.helphero == msg.pid then
		--如果助战英雄解雇，则助战英雄改为主角
		ActorManager.user_data.helphero = 0;
	end
	local pos = ActorManager:RemoveRole(msg.pid);
	RoleInfoPanel:FireRole(pos);
	
	--判断角色是否在队伍中
	for index,pid in ipairs(ActorManager.user_data.team) do
		if pid == msg.pid then
			ActorManager.user_data.team[index] = -1;
			break;
		end
	end
	
	--判断角色是否在小伙伴中
	for index,pid in ipairs(ActorManager.user_data.fellow) do
		if pid == msg.pid then
			ActorManager.user_data.fellow[index] = -1;
			break;
		end
	end
	
	PartnerFirePanel:onClose();
end

-- 占位函数
function NetworkMsg_Pub:onAllPartner(msg)
  -- TO DO Nothing
end

function NetworkMsg_Pub:onEnter(msg)
	ZhaomuPanel.rest_free_times = msg.flush1times;
	ZhaomuPanel:Show({show_3 = msg.flush3flag, show_4 = msg.flush4flag, state_4 = msg.stepup_state, state_3 = msg.event_state});
end
