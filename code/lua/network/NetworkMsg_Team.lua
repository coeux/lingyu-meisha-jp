--NetworkMsg_Team.lua

--========================================================================
--队伍

NetworkMsg_Team =
	{
	};


--阵型改变
function NetworkMsg_Team:onChangeTeamOrder(msg)
	ActorManager.user_data.team = msg.team;
	
	ActorManager:UpdateFightAbility();
	uiSystem:UpdateDataBind();
	--GemPanel:totleFp();
end

function NetworkMsg_Team:onExpeditionChangeTeam(msg)
	--Debug.print_var_dump(msg);
end

function NetworkMsg_Team:onCardEventChangeTeam(msg)
	--Debug.print_var_dump(msg);
end
