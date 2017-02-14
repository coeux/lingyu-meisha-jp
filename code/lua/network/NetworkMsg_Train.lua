--NetworkMsg_Train.lua

--======================================================================
--训练

NetworkMsg_Train = 
	{
	};


--收到训练场信息
function NetworkMsg_Train:onTrainInfo(msg)
	TrainPanel:onShowTrainPanel(msg.infos);
end

--接收到服务器训练结束消息
function NetworkMsg_Train:onTrainEnd(msg)
	local armatureUI = PlayEffect('xunlianwancheng_output/', Rect((1 - msg.pos)*240, 0, 0, 0), 'xunlianwancheng');		--播放特效
	armatureUI.Tag = msg.pos + 1;
	armatureUI:SetScriptAnimationCallback('trainEffectAnimationEnd', 0);
end

--合成特效结束响应事件
function trainEffectAnimationEnd( armature, arg )
	if armature:IsCurAnimationLoop() then
		armature:Replay();			--循环动作
		return;
	end
	
	uiSystem:AddAutoReleaseControl(armature);
	TrainPanel:onShowTrainEnd(armature.Tag);
end	

--响应服务器清除训练cd的消息
function NetworkMsg_Train:onClearTrainCD(msg)
	TrainPanel:onClearTrainCD(msg.pos + 1);
end
