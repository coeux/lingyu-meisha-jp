--Rank.lua
--========================================================================
Rank =
{
	rankTeam = {},
	rankEnemyTeam = {}
};
function Rank:Init()
	self.rankTeam = {}
end
function Rank:setRankTeam(teamData)
	self.rankTeam = {}
	self.rankTeam = teamData
end
function Rank:getRankTeam()
	return self.rankTeam
end
function Rank:getRankTeamPidList()
	local rankTeamPid = {}
	for i = 1 , 5 do
		table.insert(rankTeamPid,self.rankTeam[i].pid)
	end
	return rankTeamPid
end
function Rank:reqExitRank(is_win)
	local msg = {}
	msg.is_win = is_win;
	Network:Send(NetworkCmdType.req_rank_season_fight_end_t, msg)
end
function Rank:setSelfData(data)
	self.self_data = {};
	self.self_data = data;
end
--========================================================================
