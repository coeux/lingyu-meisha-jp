--NetworkMsg_Friend.lua

--======================================================================
--好友

NetworkMsg_Friend =
	{
	};


--服务器返回申请添加好友结果
function NetworkMsg_Friend:onApplyAddFriend(msg)
	Toast:MakeToast(Toast.TimeLength_Long, LANG_NetworkMsg_Friend_1);
end

--好友挑战
local friendTimer = -1;
function NetworkMsg_Friend:onFriendFight( msg )
	if nil ~= msg and nil ~= msg.info then	
		local enemy = cjson.decode(msg.info);
		local tmp = {};
	    for strIndex,role in pairs(enemy.roles) do
		    tmp[tonumber(strIndex)] = role;
	    end	
		
		FightManager:Initialize(FightType.FriendBattle, tmp);
		--预加载声音资源
		FightManager:PreLoadSoundResource();
		friendTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_Friend:onRealFriendFight', 0);
		Loading:SetProgress(60);
	end
end

function NetworkMsg_Friend:onRealFriendFight()
	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end		

	timerManager:DestroyTimer(friendTimer);
	friendTimer = -1;
	
	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();
	
	Loading:DecWaitNum();
	Loading:SetProgress(90);
end

--获得好友邀请码及邀请好友情况
function NetworkMsg_Friend:onFriendInviteStatus(msg)
	ActivityAllPanel:onShowInvite(msg);
end	

--领取好友邀请码奖励
function NetworkMsg_Friend:onFriendInviteReward(msg)
	ActivityAllPanel:onGetInviteReward(msg);
end	

--验证邀请码成功
function NetworkMsg_Friend:onVerifyInviteCode(msg)
	FriendPanel:FriendInviteSuccess();
end

--设置显示是否有花
function NetworkMsg_Friend:onFriendFlower(msg)
	local haveFlowers = (#msg.flowers > 0);
	FriendListPanel.setHaveFlowerStatus(haveFlowers);	
	FriendFlowerPanel:refresh(msg);
end

--接受到通知有人送花
function NetworkMsg_Friend:onFriendFlowerReceieve(msg)
	FriendFlowerPanel.newFlower = true
	FriendFlowerPanel:UpdateFlowerTip()
end

--返回接受到的鲜花
function NetworkMsg_Friend:onReceiveFlower(msg)
	if #msg.idList > 0 then
		FriendFlowerPanel:retAccept(msg.idList)
	end
end
