--networkMsg_godssenki.lua

--========================================================================
--网络消息_进入战斗类

NetworkMsg_GodsSenki =
	{
	};

--返回vip购买信息
function NetworkMsg_GodsSenki:onRetBuyVipInfo(msg)
	BuyCountPanel:onShowBuyCountPanel(msg.yb, msg.count);
end

--向服务器发送统计数据
function NetworkMsg_GodsSenki:SendStatisticsData(taskID, index)
--[[	local id = resTableManager:GetValue(ResTable.gathering, taskID .. '_' .. index, 'sid');
	if nil ~= id then
		local msg = {};
		msg.step = id;
		Network:Send(NetworkCmdType.nt_quit_step, msg, true);
	end--]]
end

--领取等级奖励成功
function NetworkMsg_GodsSenki:onGetLevelReward(msg)
	ActivityAllPanel:onGetLevelReward(msg)
end
