--networkMsg_Wing.lua

--======================================================================
--翅膀

NetworkMsg_Wing = 
	{
	};	

--返回装备/卸下翅膀
function NetworkMsg_Wing:onWearWing(msg)
	WingPanel:equipCallback(msg);
	uiSystem:UpdateDataBind();
end

--返回合成/分解翅膀
function NetworkMsg_Wing:onComposeWing(msg)
	if msg.flag == WingCompose.split then
		WingPanel:decomposCallback(msg);
	elseif msg.flag == WingCompose.compose then
		WingPanel:composeCallback(msg);
	end
end
