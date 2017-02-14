--卡牌活动
NetworkMsg_CardEvent =
{
};

function NetworkMsg_CardEvent:notice(msg)
  ChatPanel:ParseEventXML(msg.info);
end

function NetworkMsg_CardEvent:coin(msg)
  ActorManager.user_data.functions.card_event.coin = msg.now
end

function NetworkMsg_CardEvent:score(msg)
  ActorManager.user_data.functions.card_event.score = msg.now
  if msg.goal_level then
    ActorManager.user_data.functions.card_event.goal_level = msg.goal_level
  end
end

function NetworkMsg_CardEvent:open(msg)
  ActorManager.user_data.functions.card_event.open_times = msg.open_times;
  ActorManager.user_data.functions.card_event.open_level = msg.open_level;
  ActorManager.user_data.functions.card_event.next_count = msg.next_count;
end

function NetworkMsg_CardEvent:drop(msg)
	local font = {};
	font[2] = 'FZ_20_miaobian_R255G255B255';
  local data = resTableManager:GetRowValue(ResTable.item,
               tostring(msg.resid));
  if data then
    ToastMove:CreateToast(LANG_trialTaskPanel_12, nil, 
							data['name'], QualityColor[data['quality']], 
                          '×' .. msg.num, nil,
						  nil, nil,
						  font);
  end
end

function NetworkMsg_CardEvent:fight(msg)
	local fill_pro = function(pro, arr)
		pro.atk 	= arr[1];
		pro.mgc 	= arr[2];
		pro.def		= arr[3];
		pro.res 	= arr[4];
		pro.hp  	= arr[5];
		pro.cri		= arr[6];
		pro.acc 	= arr[7]; 
		pro.dodge	= arr[8]; 
		pro.fp		= arr[9];
		pro.power	= arr[10]; 
		pro.ten 	= arr[11]; 
		pro.imm_dam_pro = arr[12];
		pro.move_speed = arr[13]; 
		pro.factor = {};
		table.insert(pro.factor, arr[14]);
		table.insert(pro.factor, arr[15]);
		table.insert(pro.factor, arr[16]);
		table.insert(pro.factor, arr[17]);
		table.insert(pro.factor, arr[18]);
		pro.atk_power = arr[19]; 
		pro.hit_power = arr[19]; 
		pro.kill_power = arr[19];
		pro.pd = {};
		pro.pa = {};
		for i=1, 5 do
			pro.pd[i] = arr[19+i] or 0;
			pro.pa[i] = arr[24+i] or 0;
		end
	end
	local fill_skls = function(skls, arr)
		for _, a in pairs(arr) do
			local skl = {};
			skl.skid = a[1];
			skl.resid = a[2];
			skl.level = a[3];
			table.insert(skls, skl);
		end
	end
	local fill_lvl = function(lvl, arr)
		lvl.level = arr[1];
		lvl.lovelevel = arr[2];
	end


  local tmp = {}
	local dc = cjson.decode(msg.view_data);
  for _, role in pairs(dc.roles) do
    tmp[role.pid] = role.resid
    role.equips = nil
    local pro = role.pro; role.pro = {}
    fill_pro(role.pro, pro)
		local skls = role.skls; role.skls = {}
		fill_skls(role.skls, skls);
		local lvl = role.lvl; role.lvl = {}
		fill_lvl(role.lvl, lvl)
  end
  dc.resid = msg.resid

  CardEvent.enemyTeamList = {}
  for _, actor in pairs(msg.team) do
    if actor.pid ~= -1 then
      table.insert(CardEvent.enemyTeamList, {
        pid = actor.pid, resid = tmp[actor.pid], hp = actor.hp
      })
    end
  end
  tmp = nil
  ComboPro:InitEnemyData(dc.combo_pro);
  Rune:InitEnemyAttribute(dc.roles);
  NetworkMsg_Fight:onHandleEnter(dc)
end
