--commonUserControl.lua
--=============================================================================
--local 方法

local getDotStr = function(num)
	local str;
	if num > 999 then
		str = math.floor(num/1000) .. ',' .. string.sub(tostring(num),-3,-1);
	else
		str = tostring(num);
	end
	return str;
end

local changeClickArea = function(plist)

	local width = appFramework.ScreenWidth;
	local height = appFramework.ScreenHeight;
	local scalex = width / 1024;
	local scaley = height / 576;
	return plist[1] * scalex, plist[2] * scaley, plist[3] *scalex, plist[4] * scaley;
end
--local 表
local skillEnum = 
{
	'active1',  --无用项
	'active2',	--无用项
	'active3',	--无用项
	'active1',
	'active2',
	'passive1',
	'passive2',
	'passive3',
}

local listColor = {};
listColor[1] = Color(182, 212, 208, 255);
listColor[2] = Color(226, 202, 238, 255);
listColor[3] = Color(185, 213, 237, 255);
listColor[4] = Color(242, 215, 178, 255);

--用以封装各自定义控件的类以及方法


--各不同自定义控件的方法
local typeMethodList = {};
typeMethodList.memberResultTemplate = function(o)
	--用到的控件
	local imageActor = o.ctrl:GetLogicChild('image');
	local labelExp = o.ctrl:GetLogicChild('exp');
	local progressExp = o.ctrl:GetLogicChild('expProgress');
	local imgStar = o.ctrl:GetLogicChild('grade');
	local labelIsLvlup = o.ctrl:GetLogicChild('lvlup');
	imageActor.AutoSize = false;
	imageActor.Visibility = Visibility.Visible;
	labelExp.Visibility = Visibility.Visible;
	progressExp.Visibility = Visibility.Visible;
	imgStar.Visibility = Visibility.Visible;
	labelIsLvlup.Visibility = Visibility.Hidden;

	o.init = function()

	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.setActorImage = function(headPic)
		imageActor.Image = headPic;
	end

	o.setExp = function(curExp, maxExp, addExp)
		addExp = addExp or 0;
		progressExp.Text = curExp .. '/' .. maxExp;
		progressExp.MaxValue = maxExp;
		progressExp.CurValue = curExp;
		labelExp.Text = '+' .. addExp;
		if tonumber(addExp) > tonumber(curExp) then
			o.setLvlup();
		end
	end

	o.setLvlup = function()
		labelIsLvlup.Visibility = Visibility.Visible;
	end

	o.setRank = function(rank)
		imgStar.Image = GetPicture('kapai/rank_' .. rank ..'.ccz')
	end
end

typeMethodList.rewardTemplate = function(o)
	--用到的控件
	local imageItem = o.ctrl:GetLogicChild('rewardImage');
	local labelNum = o.ctrl:GetLogicChild('rewardNum');


	o.init = function()
		if labelNum  then
			labelNum.Text = '-1';		
		end
		labelNum.Visibility = (labelNum.Text == '-1') and Visibility.Hidden or Visibility.Visible;
	end

	o.ctrlShow = function()
		o.ctrl.Visibility = Visibility.Visible;
		imageItem.Visibility = Visibility.Visible;
		labelNum.Visibility = (labelNum.Text == '-1') and Visibility.Hidden or Visibility.Visible;
	end

	o.ctrlHide = function()
		o.ctrl.Visibility = Visibility.Hidden;
	end

	o.setItemImage = function(itemid)
		imageItem.Image = GetPicture('icon/' .. itemid ..'.ccz');		
	end

	o.setImageSize = function(width, height)
		imageItem:SetSize(width, height);
	end

	o.setScale = function(x, y)
		o.ctrl:SetScale(x, y);
	end

	o.setItemNum = function(num)
		labelNum.Text = tostring(num);
		labelNum.Visibility = Visibility.Visible;	
	end

	o.setMargin = function(x1,y1,x2,y2)
		o.ctrl.Margin = Rect(x1,y1,x2,y2);
	end
end

typeMethodList.midCardTemplate = function(o)
	--用到的控件
	local imageRole = o.ctrl:GetLogicChild('role_img');
	local labelName = o.ctrl:GetLogicChild('name');
	local imageStar = o.ctrl:GetLogicChild('gradeStar');
	local labelLv = o.ctrl:GetLogicChild('lv');
	local labelHp = o.ctrl:GetLogicChild('hp');
	local labelNa = o.ctrl:GetLogicChild('nor_att');
	local labelSa = o.ctrl:GetLogicChild('ski_att');
	local labelNd = o.ctrl:GetLogicChild('nor_def');
	local labelSd = o.ctrl:GetLogicChild('ski_def');
	local imageAtt = o.ctrl:GetLogicChild('attribute_img');

	o.init = function()

	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.setRoleImage = function(roleid)
		imageItem.Image = GetPicture('icon/' .. roleid ..'.ccz');		
	end

	o.setStar = function(star)
		imageStar.Image = GetPicture('fight/starGrade_' .. star ..'.ccz');		
	end

	o.setLv = function(lv)
		labelLv.Text = tostring(lv);		
	end

	o.setHp = function(hp)
		labelHp.Text = tostring(hp);		
	end

	o.setNormalAttack = function(value)
		labelNa.Text = tostring(value);		
	end

	o.setSkillAttack = function(value)
		labelSa.Text = tostring(value);		
	end

	o.setNormalDefence = function(value)
		labelNd.Text = tostring(value);		
	end

	o.setSkillDefence = function(value)
		labelSd.Text = tostring(value);		
	end

	o.setAttribute = function(value)
		imageAtt.Image = GetPicture('icon/' .. value ..'.ccz');		
	end
end

typeMethodList.lovePhaseTemplate = function(o)
	--用到的控件
	local panelLock = o.ctrl:GetLogicChild('lockPanel');
	local panelEnable = o.ctrl:GetLogicChild('enablePanel');
	local btnClick = o.ctrl:GetLogicChild('btn');
	local imagePhase = o.ctrl:GetLogicChild('phaseImage');
	local shader	= o.ctrl:GetLogicChild('shader');

	--变量
	local loveLevel;

	o.init = function()

	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.initWithRole = function(role, level)
		loveLevel = level;
		if level <= role.lvl.lovelevel then
			o.setEnable(true);
			btnClick:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:onClickLovePhase');
		else
			o.setEnable(false);
		end
		local path = resTableManager:GetValue(ResTable.love_task, tostring(tonumber(role.resid)*100 + level), 'icon');
		imagePhase.AutoSize = false;
		imagePhase.Image = GetPicture('renwu/' .. path .. '.ccz');
	end

	o.setPhaseImage = function(imagepath)
		imageItem.Image = GetPicture('icon/' .. imagepath ..'.ccz');		
	end

	o.setEnable = function(isEnable)
		panelLock.Visibility = isEnable and Visibility.Hidden or Visibility.Visible;
		shader.Visibility = isEnable and Visibility.Hidden or Visibility.Visible;
		panelEnable.Visibility = isEnable and Visibility.Visible or Visibility.Hidden;
	end

	o.setBtnTag = function(tag)
		btnClick.Tag = tag;
	end	
end

--自定义button
local buttonImgList =
{
	homeback = 'home_returnIcon';
	mainPage = 'home_homeIcon';
	dailytask = 'task';
	plottask = 'task';
}

local buttonTextList = 
{
	dailytask = LANG_button_3;
	homeback  = LANG_button_1;
	mainPage  = LANG_button_2;
	plottask  = LANG_button_4;
}
local buttonCallbacklist = 
{
	dailytask = 'PlotTaskPanel:RefreshDailyTask';
	homeback  = 'HomePanel:onClickBack';
	listback  = 'CardListPanel:Hide';
	mainPage  = 'HomePanel:onClickBack';
	plottask  = 'PlotTaskPanel:RefreshPlotTask';
}

typeMethodList.buttonTemplate = function(o)
	--用到的控件
	local btnButton = o.ctrl:GetLogicChild('btn');
	--local imageButton = btnButton:GetLogicChild('buttonImage');

	o.init = function()

	end

	o.ctrlShow = function()
		o.ctrl:GetVisualParent().Visibility = Visibility.Visible;	
	end

	o.ctrlHide = function()
		o.ctrl:GetVisualParent().Visibility = Visibility.Hidden;
	end

	o.setButtonImage = function(imagetype)
		--imageButton.Image = GetPicture('godsSenki/' .. buttonImgList[imagetype] ..'.ccz');
		btnButton.Text = buttonTextList[imagetype];
	end

	o.setButtonCallback = function(funtype)
		btnButton:SubscribeScriptedEvent('Button::ClickEvent', buttonCallbacklist[funtype]); --imageButton:SubscribeScriptedEvent('UIControl::MouseClickEvent', buttonCallbacklist[funtype]);
	end

	o.setScale = function(x, y)
		btnButton:SetScale(x, y);
	end
end

typeMethodList.cardMidTemplate = function(o)
	--用到的控件
	local rBtnCenter = o.ctrl:GetLogicChild('center');
	local imgRole = rBtnCenter:GetLogicChild('cardImage');
	local panelBg = rBtnCenter:GetLogicChild('bg');
	local imgkanban = rBtnCenter:GetLogicChild('isKanban');
	local shade = rBtnCenter:GetLogicChild('isKanban');
	local frame1 = panelBg:GetLogicChild('frame1');
	local frame2 = panelBg:GetLogicChild('frame2');
	local showList = 
	{
		level = panelBg:GetLogicChild('level');
		skill = panelBg:GetLogicChild('skill');
		love = panelBg:GetLogicChild('love');
		equip = panelBg:GetLogicChild('equip');
		unknown = panelBg:GetLogicChild('unknown');
	}
	--变量

	o.init = function()
		for _, panel in pairs(showList) do
			panel.Visibility = Visibility.Hidden;
		end
		frame1.Visibility = Visibility.Hidden;
		frame2.Visibility = Visibility.Hidden;
		imgRole.Visibility = Visibility.Hidden;
		panelBg.Visibility = Visibility.Visible;
		imgkanban.Visibility = Visibility.Hidden;
		shade.Visibility = Visibility.Hidden;
	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.initWithRole = function(role, index)
		--头像 
		imgRole.Image = GetPicture('navi/' .. role.midImage .. '.ccz');
		imgRole.Visibility = Visibility.Visible;
		rBtnCenter.Tag = index;
		if index == ActorManager:getKanbanRole() then
			imgkanban.Visibility = Visibility.Visible;
		else
			imgkanban.Visibility = Visibility.Hidden;
		end

		--等级
		local lvl = role.lvl.level;
		showList.level:GetLogicChild('level').Text = lvl .. '/100';
		showList.level:GetLogicChild('gradeStar').Image = GetPicture('kapai/rank_' .. role.rank .. '.ccz');
		showList.level:GetLogicChild('propertyIcon').Image = GetPicture('kapai/shuxing_' .. role.attribute .. '.ccz');

		--技能
		local i=1;
		for _,skill in ipairs(role.skls) do
			if i <= 5 then
				local imgSkill = showList.skill:GetLogicChild('skill' .. i);
				local skillLevel = imgSkill:GetLogicChild(0);
				if skill.resid == 0 then
					imgSkill.Visibility = Visibility.Hidden;
				else
					local iconPath = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'icon');
					if not iconPath then
						iconPath = resTableManager:GetValue(ResTable.passiveSkill, tostring(skill.resid), 'icon');
					end
					imgSkill.Image = GetIcon(iconPath);
					imgSkill.Visibility = Visibility.Visible;
					i = i + 1;
					skillLevel.Text = 'Lv.' .. skill.level;
				end
			end
		end

		--爱恋度
		local loveNum = role.lvl.lovelevel;
		for i=1, 4 do
			local heartBg = showList.love:GetLogicChild('starPanel'):GetLogicChild(tostring(i)):GetLogicChild('star');
			local heart = showList.love:GetLogicChild('starPanel'):GetLogicChild(tostring(i)):GetLogicChild('star1');
			if i <= loveNum then
				heartBg.Visibility = Visibility.Visible;
				heart.Visibility = Visibility.Visible;
			else
				heartBg.Visibility = Visibility.Visible;
				heart.Visibility = Visibility.Hidden;			
			end
		end

		--装备		
		for i=1,5 do
			local imgEquip = showList.equip:GetLogicChild('equip' .. i);
			local labelLevel = imgEquip:GetLogicChild(0);
			if role.equips[tostring(i)] then
				labelLevel.Text = 'Lv.' .. (tostring(role.equips[tostring(i)].strenlevel) or '1');
				local icon_path = resTableManager:GetValue(ResTable.equip, tostring(role.equips[tostring(i)].resid), 'icon');
				imgEquip.Image = GetPicture('icon/' .. icon_path ..'.ccz');
				imgEquip.Visibility = Visibility.Hidden;			
			end
		end
	end

	o.setUnknown = function()
		shade.Visibility = Visibility.Visible;
		imgRole.Visibility = Visibility.Hidden;
		frame2.Visibility = Visibility.Hidden;
		frame1.Visibility = Visibility.Hidden;
		for _, panel in pairs(showList) do
			panel.Visibility = Visibility.Hidden;
		end
		showList.unknown.Visibility = Visibility.Visible;
		imgkanban.Visibility = Visibility.Hidden;
	end

	o.setMargin = function(x1,y1,x2,y2)
		o.ctrl.Margin = Rect(x1,y1,x2,y2);
	end

	o.setShowState = function(showtype)
		for _, panel in pairs(showList) do
			panel.Visibility = Visibility.Hidden;
		end
		frame1.Visibility = Visibility.Hidden;
		frame2.Visibility = Visibility.Hidden;
		if showtype == 'list' then
			frame1.Visibility = Visibility.Visible;
			showList.level.Visibility = Visibility.Visible;
		elseif showtype == 'lvlup' then
			frame1.Visibility = Visibility.Visible;
			showList.level.Visibility = Visibility.Visible;		
		elseif showtype == 'strength' then
			frame1.Visibility = Visibility.Visible;
			showList.level.Visibility = Visibility.Visible;		
		elseif showtype == 'skill' then
			frame2.Visibility = Visibility.Visible;
			showList.skill.Visibility = Visibility.Visible;		
		elseif showtype == 'qianli' then
			frame1.Visibility = Visibility.Visible;
			showList.level.Visibility = Visibility.Visible;		
		elseif showtype == 'love' then
			frame2.Visibility = Visibility.Visible;
			showList.love.Visibility = Visibility.Visible;		
		elseif showtype == 'eLvlup' then
			frame2.Visibility = Visibility.Visible;
			showList.equip.Visibility = Visibility.Visible;		
		elseif showtype == 'eRankup' then
			frame2.Visibility = Visibility.Visible;
			showList.equip.Visibility = Visibility.Visible;		
		end
	end

	o.setListEvent = function()
		rBtnCenter:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardListPanel:onClickCard');
	end

	o.unsetListEvent = function()
		rBtnCenter:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardListPanel:onClickCard');
	end

	o.setNormal = function()
		for _, panel in pairs(showList) do
			panel.Visibility = Visibility.Hidden;
		end
		frame2.Visibility = Visibility.Hidden;
		frame1.Visibility = Visibility.Visible;
		showList.level.Visibility = Visibility.Visible;	
	end

	o.rankup = function(newRank)
		showList.level:GetLogicChild('gradeStar').Image = GetPicture('kapai/rank_' .. newRank .. '.ccz');
	end
end

--Navi控件
typeMethodList.naviTemplate = function(o)
	--常量
	local naviSound = nil
	local scalex = 1138/1024;
	local scaley = 640/576;
	--用到的控件
	o.ctrl.ZOrder = 0;
	o.ctrl.Visibility = Visibility.Visible;
	local imgBg = o.ctrl:GetLogicChild('bg');
	imgBg.ZOrder = 5;
	--local imgRole = o.ctrl:GetLogicChild('role');

	--imgRole.ZOrder = 10;
	local imgList = {};
	local eventList = {};
	local is_enter;

	imgBg.Visibility = Visibility.Visible;
	--imgRole.Visibility = Visibility.Visible;


	--用到的变量
	local role_resid;

	o.init = function()
		is_enter = false;
	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.setResid = function(resid)
		role_resid = resid;
		local path = resTableManager:GetValue(ResTable.navi_main, tostring(role_resid), 'bg_path');
		o.setNaviBg(path);
		if is_enter then
			NaviLogic:Enter();
		end
	end

	o.leave = function()
		is_enter = false;
		for _,event in pairs(eventList) do
			event.click = 0;		
		end
		for _,img in pairs(imgList) do
			img.Visibility = Visibility.Hidden;
		end
		eventList = {};
		imgList = {};
	end

	o.setRoleVisible = function(flag)
		--imgRole.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	end

	o.setImageBGVisible = function(flag)
		imgBg.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	end

	o.getJpg = function(path)
		return GetPicture('navi/' .. path .. '.jpg');
	end
	o.setNaviBg = function(path)
		imgBg.Background = CreateTextureBrush('navi/' .. path .. '.jpg', 'navi');
	end

	o.enter = function()
		is_enter = true;
		imgList = {};
		eventList = {};
		local roleInfo = resTableManager:GetValue(ResTable.navi_main, tostring(role_resid), {'imglist', 'eventlist', 'soundlist', 'role_path', 'role_position', 'bg_path'});
		o.setNaviBg(roleInfo['bg_path']);
		--local tResid = role_resid%10000;
		if ActorManager:IsHavePartner(role_resid) or ActorManager:IsMainHero(role_resid) then
			--初始化图片
			if roleInfo['imglist'] then
				for _,imgid in pairs(roleInfo['imglist']) do
					local imgInfo = resTableManager:GetValue(ResTable.navi_effect, tostring(imgid), {'position', 'path', 'img_num'});
					local imgEvent = ImageElement(uiSystem:CreateControl('ImageElement'));
					imgEvent.Image = o.getJpg(imgInfo['path']);
					imgEvent.Margin = Rect(imgInfo['position'][1]*scalex,imgInfo['position'][2]*scaley,0,0);
					imgEvent.TransformPoint = Vector2(0, 0);
					imgEvent:SetScale(scalex,scaley);
					imgEvent.ZOrder = 15;
					imgEvent.AlwaysOnTop = true;
					imgEvent.Visibility = Visibility.Hidden;
					o.ctrl:GetLogicChild('bg'):AddChild(imgEvent);
					imgList[imgInfo.img_num] = imgEvent;
				end
			else
				roleInfo['imglist'] = {};
			end

			--初始化事件
			if roleInfo['eventlist'] then
				for _,eventid in ipairs(roleInfo['eventlist']) do
					local eventInfo = resTableManager:GetValue(ResTable.navi_event, tostring(eventid), {'click_area', 'click_sound', 'event_sound', 'click_num', 'action_list', 'conflict'});
					if eventInfo then
						eventList[eventid] = {};
						--点击次数
						eventList[eventid].click = 0;
						eventList[eventid].clickNum = eventInfo['click_num'] or 1;
						--点击范围
						eventList[eventid].click_area = eventInfo['click_area'] or {0,0,960,640};
						--点击声音
						eventList[eventid].click_sound = eventInfo['click_sound'];
						--事件声音
						eventList[eventid].event_sound = eventInfo['event_sound'];
						--事件id 用于处理冲突
						eventList[eventid].id = eventid;
						--事件冲突列表
						eventList[eventid].conflict_list = eventInfo['conflict'] or {};
						--各图片时间表
						eventList[eventid].actions = {};
						eventList[eventid].actionMaxTime = 0;
						if eventInfo['action_list'] then
							for _,actionid in pairs(eventInfo['action_list']) do
								local actionInfo = resTableManager:GetValue(ResTable.navi_action, tostring(actionid), {'img_num', 'time_list'});
								local timeMax = 15;
								eventList[eventid].actions[actionInfo.img_num] = {};				
								for i=0, 15, 0.5 do
									eventList[eventid].actions[actionInfo.img_num][tostring(i)] = 0;
								end
								for _, time in pairs(actionInfo['time_list']) do
									eventList[eventid].actions[actionInfo.img_num][tostring(time)] = 1;
									if time > eventList[eventid].actionMaxTime then
										eventList[eventid].actionMaxTime = time;
									end
								end
							end
						end			
					end
				end
			else
				roleInfo['eventlist'] = {};
			end
		end
	end

	o.getEventList = function()
		return eventList;
	end

	o.getResid = function()
		return role_resid;
	end
	o.destroyNaviSound = function()
		if naviSound then
			soundManager:DestroySource(naviSound);
			naviSound = nil
		end
	end
	o.touch = function(x, y)
		for _,event in pairs(eventList) do
			local x1, y1, x2, y2 = changeClickArea(event.click_area);
			if x >= x1 and y >= y1 and x <= x2 and y <= y2 then
				event.click = event.click + 1;

				--声音
				SoundManager:PlayEffect(event.click_sound);

				--触发事件
				if event.click >= event.clickNum then
					o.destroyNaviSound()
					naviSound = SoundManager:PlayEffect(event.event_sound);
					event.click = 0;
					for _,conflictEvent in pairs(event.conflict_list) do
						NaviLogic:clearEvent(conflictEvent);
					end
					NaviLogic:clearEvent(event.id);
					NaviLogic:FireEvent(event.id);
				end
				--向服务器发送增加navi计数点击请求
				LovePanel:naviClick(event.id, x, y)	
				return true;
			end		
		end		
		return false;
	end

	o.fireEvent = function(eventid, timecount)
		local event = eventList[eventid];
		--声音

		--触发图片状态
		for imgId,timelist in pairs(event.actions) do
			if timelist[tostring(timecount)] == 1 then
				o.swithImgState(imgList[imgId]);
			end
		end
		if event.actionMaxTime == timecount then
			return false;		
		else
			return true;
		end		
	end

	o.clearEvent = function(eventid)
		local event = eventList[eventid];

		--hid图片
		for imgId,v in pairs(event.actions) do
			imgList[imgId].Visibility = Visibility.Hidden;
		end
	end

	o.swithImgState = function(img)
		if img.Visibility == Visibility.Visible then
			img.Visibility = Visibility.Hidden;
		else
			img.Visibility = Visibility.Visible;
		end
	end

end

--成就和评级图标
typeMethodList.gradeInfoTemplate = function(o)
	--用到的控件
	local control = Panel(uiSystem:CreateControl('gradeInfoTemplate'));
	local selectFlag = o.ctrl:GetLogicChild('pointLabel');
	local image = o.ctrl:GetLogicChild('imgPanel');
	local imgS = image:GetLogicChild('gradeImageS');
	local imgA = image:GetLogicChild('gradeImageA');
	local imgB = image:GetLogicChild('gradeImageB');
	local imgC = image:GetLogicChild('gradeImageC');
	local star1 = image:GetLogicChild('star1');
	local star2 = image:GetLogicChild('star2');
	local star3 = image:GetLogicChild('star3');

	imgS.Visibility = Visibility.Hidden;
	imgA.Visibility = Visibility.Hidden;
	imgB.Visibility = Visibility.Hidden;
	imgC.Visibility = Visibility.Hidden;
	star1.Visibility = Visibility.Hidden;
	star2.Visibility = Visibility.Hidden;
	star3.Visibility = Visibility.Hidden;

	o.init = function()

	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.setScale = function(x, y)
		o.ctrl:SetScale(x, y);
	end

	o.setRank = function(str)
		imgS.Visibility = Visibility.Hidden;
		imgA.Visibility = Visibility.Hidden;
		imgB.Visibility = Visibility.Hidden;
		imgC.Visibility = Visibility.Hidden;
		if 's' == str then
			imgS.Visibility = Visibility.Visible;
		elseif 'a' == str then
			imgA.Visibility = Visibility.Visible;
		elseif 'b' == str then
			imgB.Visibility = Visibility.Visible;
		elseif 'c' == str then
			imgC.Visibility = Visibility.Visible;	
		end
	end

	o.setAchievement = function(str)
		local a1c = (string.sub(str, 1, 1) == '1');
		local a2c = (string.sub(str, 2, 2) == '1');
		local a3c = (string.sub(str, 3, 3) == '1');
		star1.Visibility = a1C and Visibility.Visible or Visibility.Hidden;
		star2.Visibility = a2C and Visibility.Visible or Visibility.Hidden;
		star3.Visibility = a3C and Visibility.Visible or Visibility.Hidden;
	end

end

typeMethodList.clickLabel = function(o)
	--用到的控件
	local label = o.ctrl;
	local lastTime;

	o.init = function()
		label.Margin = Rect(65, 0, 0, 105);
		label.ZOrder = 40;
		label.AlwaysTop = true;
		label.Visibility = Visibility.Visible;
	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.setLastTime = function(t)
		lastTime = t;
	end

	o.getLastTime = function()
		return lastTime;
	end

	o.changeTime = function(t)
		lastTime = lastTime - t;
		o.setOpacicty(1/500*lastTime);
	end

	o.setOpacicty = function(value)
		label.Opacicty = value;
	end
end

typeMethodList.UpgreadeTemplate = function(o)     --By enlai 
	--用到的控件
	local btnEat = o.ctrl:GetLogicChild('eatone');
	local btnCram = o.ctrl:GetLogicChild('mengchi');
	local num = o.ctrl:GetLogicChild('num');
	local panelHead = o.ctrl:GetLogicChild('panelHead');
	local roleInfo = ActorManager:GetRole(0);   --主角信息   
	local item = customUserControl.new(panelHead, 'itemTemplate');

	o.init = function()
	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.initWithItem = function(itemResid, role)	  	
		local itemData = Package:GetItem(itemResid);
		o.ctrl.Background = CreateTextureBrush('home/home_cardlist_upgrade_item_bg.ccz','godsSenki');
		item.initWithInfo(itemResid,-1,70,false);
		item.addExtraClickEvent(itemResid, 'CardLvlupPanel:touchIcon');
		if itemData then
			local itemNum = itemData.num;
			if itemNum > 0 then
				if(role.pid == 0 or role.lvl.level >= roleInfo.lvl.level) then
					btnEat.Enable = false;
					btnCram.Enable = false;	
				else
					btnEat.Enable = true;
					btnCram.Enable = true;
				end
			else
				btnEat.Enable = false;
				btnCram.Enable = false;				
			end		
			num.Text = tostring(itemNum);		
		else
			num.Text = '0';
			btnEat.Enable = false;
			btnCram.Enable = false;
		end		
		btnEat.Tag = itemResid;		
		btnEat:SubscribeScriptedEvent('Button::ClickEvent', 'CardLvlupPanel:onEat');
		btnCram.Tag = itemResid;		
		btnCram:SubscribeScriptedEvent('Button::ClickEvent', 'CardLvlupPanel:onCram');
	end

	o.setNum = function(eatNum, role)
		num.Text = tostring(eatNum);
		if(tonumber( num.Text) == 0) then
			btnEat.Enable = false;
			btnCram.Enable = false;		
		end
		if(role.lvl.level >= roleInfo.lvl.level) then          
			return true;  
		end
	end

	o.setEnable = function()
		return {btnEat, btnCram};
	end

	o.setScale = function(x, y)
		o.ctrl:SetScale(x, y);
	end

	o.setMargin = function(x1,y1,x2,y2)
		o.ctrl.Margin = Rect(x1,y1,x2,y2);
	end

	o.getBtn = function()
		return btnEat;
	end
end

typeMethodList.HomeIconTemplate = function(o)
	--用到的控件
	local labelName = o.ctrl:GetLogicChild('iconName');
	local imageIcon = o.ctrl:GetLogicChild('item'):GetLogicChild('skillIcon');
	local imageGrade = o.ctrl:GetLogicChild('item');
	local advTip 	= o.ctrl:GetLogicChild('tip');
	local suoImg	= o.ctrl:GetLogicChild('suo');

	o.init = function()
	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()
	end

	o.initSkill = function(skill, role, index, indexnum, typeindex)
		local btn = o.ctrl:GetLogicChild('btn')
		btn.Tag = skill.resid;
		btn.TagExt = index;

		local skillArray = resTableManager:GetRowValue(ResTable.skill, tostring(skill.resid));
		if not skillArray then
			skillArray = resTableManager:GetRowValue(ResTable.passiveSkill, tostring(skill.resid));
			if not skillArray then
				return;
			else
				skillArray['skill_class'] = 6; 
			end
		end	
		labelName.Text = skillArray['name'];
		imageIcon.Image = GetPicture('icon/' .. tostring(skillArray['icon'] .. '.ccz'));
		local requireRank = 5;
		local isfindrank = false;
		for rank=1, 5 do
			if not isfindrank then
				local skillinfo = resTableManager:GetRowValue(ResTable.qualityup_attribute, tostring(role.resid * 100 + rank));
				for _,typeindex in ipairs (skillEnum) do	
					if skillinfo[typeindex] == skill.resid then
						requireRank = rank;
						isfindrank = true;
						break;
					end
				end
			end
		end
		if role.rank < requireRank and skillArray['next_skill'] ~= 0 then
			suoImg.Visibility = Visibility.Visible;
			advTip.Visibility = Visibility.Hidden;
		else
			if SkillStrPanel:IsCanAdv(skill.resid, role) and typeindex == 2 then
				advTip.Visibility = Visibility.Visible;
			else
				advTip.Visibility = Visibility.Hidden;
			end
			suoImg.Visibility = Visibility.Hidden;
		end
		imageGrade.Background = CreateTextureBrush('home/home_dikuang' .. skillArray['quality'] - 1 .. '.ccz', 'home');
	end

	o.initEquip = function(equip, role, index, typenum)
		local btn = o.ctrl:GetLogicChild('btn')
		btn.Tag = equip.resid;
		btn.TagExt = index;
		local equipArray = resTableManager:GetRowValue(ResTable.equip, tostring(equip.resid));
		if not equipArray then
			return;
		end
		if EquipStrengthPanel:isCanAdvance(equip) and typenum == 1 then
			advTip.Visibility = Visibility.Visible;
		else
			advTip.Visibility = Visibility.Hidden;
		end
		labelName.Text = equipArray['name'];
		imageIcon.Image = GetPicture('icon/' .. tostring(equipArray['icon'] .. '.ccz'));

		local quaNum = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'rank');
		imageGrade.Background = CreateTextureBrush('home/head_frame_' .. quaNum .. '.ccz', 'home');
	end

	o.initWithBtnClick = function(typeNum)
		local btn = o.ctrl:GetLogicChild('btn');
		if typeNum == HomeTemplateType.Skillup then
			btn:SubscribeScriptedEvent('Button::ClickEvent', 'SkillStrPanel:UpdateInfo');
		elseif typeNum == HomeTemplateType.Skilladv then
			btn:SubscribeScriptedEvent('Button::ClickEvent', 'SkillStrPanel:UpdateAdvInfo');
		elseif typeNum == HomeTemplateType.Equipup then
			btn:SubscribeScriptedEvent('Button::ClickEvent', 'EquipStrengthPanel:UpdateInfo');
		elseif typeNum == HomeTemplateType.Equipadv then
			btn:SubscribeScriptedEvent('Button::ClickEvent', 'EquipStrengthPanel:UpdateAdvInfo');
		end
	end
end

--宝石item自定义控件
typeMethodList.gemSystemTemplate = function(o)
	--用到的控件
	--[[local labelLevel = o.ctrl:GetLogicChild('level');
	local labelNum = o.ctrl:GetLogicChild('num');
	local imageGem = o.ctrl:GetLogicChild('gem_img');
	local gemLevel;--]]

	local quickSynPanel = o.ctrl:GetLogicChild('quickSynPanel');
	local upgratebtn    = o.ctrl:GetLogicChild('upgratebtn');
	local labelNum = o.ctrl:GetLogicChild('num');              --宝石的数量
	local button = o.ctrl:GetLogicChild('button'); 
	o.init = function()

	end

	o.ctrlShow = function()
		o.ctrl.Visibility = Visibility.Visible;
	end
	o.ctrlHide = function()

	end
	o.initWithGem  = function (gemPanel, resid, level, gemNum)
		local debus = gemPanel:GetLogicChild('gemPanel');  --卸下
		local inlay = gemPanel:GetLogicChild('inlay');     --镶嵌
		local name = resTableManager:GetValue(ResTable.item, tostring(resid), 'name')
		local label = gemPanel:GetLogicChild('label');
		label.Text = name;
		labelNum.Text = tostring(gemNum);
	end

	o.setImage = function (resid)
		local iconid = resTableManager:GetValue(ResTable.item, tostring(resid), 'icon');
		quickSynPanel.Image = GetPicture('icon/' .. iconid .. '.ccz');
		quickSynPanel.Size = Size(60, 60);
	end
	o.destroyImage = function (resid)      
		local iconid = resTableManager:GetValue(ResTable.item, tostring(resid), 'icon');
		quickSynPanel.Image = nil;
	end
	o.setScale = function(x, y)
		o.ctrl:SetScale(x, y);
	end

	o.setMargin = function (bottom, left, right, top)
		o.ctrl.Margin = Rect(bottom, left, right, top);
	end

	o.initWithRightGems = function (rightGemPanel, resid, index, num)                   --魂器右侧栏的魂器列表
		rightGemPanel:GetLogicChild('panel').Visibility = Visibility.Visible;
		if resid % 10000 == 8 then
			upgratebtn.Visibility = Visibility.Hidden;
		end
		local properLabel = rightGemPanel:GetLogicChild('label');
		properLabel.Visibility = Visibility.Visible;
		local name = resTableManager:GetValue(ResTable.item, tostring(resid), 'name');
		properLabel.Text = name;
		button.Tag = tonumber(resid);
		o.setImage(resid);
		labelNum.Visibility = Visibility.Visible;
		labelNum.Text = tostring(num);
		button:SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:onShowQuick');
	end
	o.resetRightGems = function(rightGemPanel)
		upgratebtn.Visibility = Visibility.Hidden;
		local properLabel = rightGemPanel:GetLogicChild('label');
		properLabel.Visibility = Visibility.Hidden;
		o.destroyImage(resid);
		labelNum.Visibility = Visibility.Hidden;
		rightGemPanel:GetLogicChild('panel').Visibility = Visibility.Hidden;
	end
	local allNoHorcruxImage = { 'gem/wugong_03.ccz', 'gem/jigong_03.ccz',              --当卡槽内没有魂器时候的图片
	'gem/wufang_03.ccz', 'gem/jifang_03.ccz', 
	'gem/shegnming_03.ccz'};

	o.initWithGems = function(gemPanel, gemid, equipIndex, gemIndex, gemNum)     --中间部分的魂器列表
		local btnXiangqian = gemPanel:GetLogicChild('inlay');
		local btn_xiexia = gemPanel:GetLogicChild('debus');
		local label = gemPanel:GetLogicChild('label');
		local name = resTableManager:GetValue(ResTable.item, tostring(gemid), 'name');
		local nogemImage = gemPanel:GetLogicChild('panel'):GetLogicChild('NogemImage');
		labelNum.Visibility = Visibility.Hidden;         --宝石的数量
		if 0 >= gemid then		
			local gemList = resTableManager:GetValue(ResTable.gemstone_part, tostring(equipIndex), 'attribute');
			local attribute = gemList[gemIndex];          
			o.setMargin(0, 20, 0, 0);               
			upgratebtn.Enable = false;
			upgratebtn.Visibility = Visibility.Hidden;       --升级按钮
			label.Visibility = Visibility.Hidden;            --宝石属性名字   
			btnXiangqian.Visibility = Visibility.Visible;    --镶嵌按钮
			nogemImage.Visibility = Visibility.Visible;      --宝石属性的文字
			nogemImage.Image = GetPicture(allNoHorcruxImage[equipIndex]);
			btn_xiexia.Visibility = Visibility.Hidden;
			btnXiangqian.Tag = gemIndex;
			o.destroyImage(gemid);
		else
			btnXiangqian.Visibility = Visibility.Hidden;
			upgratebtn.Visibility = Visibility.Hidden;       --TODO
			btn_xiexia.Visibility = Visibility.Visible;
			label.Text = name;
			label.Visibility = Visibility.Visible;            --宝石属性名字   
			--  labelNum.Visibility = Visibility.Visible;         --宝石的数量
			upgratebtn.Enable = true;
			o.setImage(gemid);
			nogemImage.Visibility = Visibility.Hidden;
			btn_xiexia.Tag = gemIndex;
			o.setMargin(0, 1, 0, 0);
			upgratebtn.Tag = tonumber(gemIndex);
			if gemid % 100 == 8 then
				upgratebtn.Visibility = Visibility.Hidden;
			end
		end
		upgratebtn:SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:onShowQuick');
		btnXiangqian:SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:onChooseMosGem');
		btn_xiexia:SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:onDismantle');
		o.getUserGuideBtn = function()
			return btnXiangqian;
		end
	end
	local gemProperStr = { 'cardRelated/home_aktpsy.ccz', --物攻 物防 技攻 技防 生命
	'cardRelated/home_slatk.ccz', 'cardRelated/home_atkdef.ccz', 
	'cardRelated/home_skdef.ccz',  'cardRelated/home_life.ccz'};

	o.initWithGem = function(allBottombg, resid, level, haveNum, requireNum, mos_selectEquipIndex)                   --宝石合成界面
		local iconId = resTableManager:GetValue(ResTable.item, tostring(resid), 'icon')
		quickSynPanel.Image = GetPicture('icon/' .. iconId .. '.ccz');
		quickSynPanel.Size = Size(60, 60);
		upgratebtn.Visibility = Visibility.Hidden;
		if(requireNum) then                         --初始化右侧的魂器icon
			allBottombg[7].Text = string.format(LANG_GEM_COMPOSE_CONDITION, level, level + 1);  --合成弹框下面对应的长的Label
			local gemVale = resTableManager:GetValue(ResTable.gemstone, tostring(resid), 'value');
			allBottombg[1]:GetLogicChild('label').Text = GemWord[mos_selectEquipIndex]..LANG_GEM;
			allBottombg[2]:GetLogicChild('label').Text = tostring(level);
			allBottombg[3]:GetLogicChild('label').Text ='+'..' '..tostring(gemVale);
			allBottombg[3]:GetLogicChild('forProper').Image = GetPicture(gemProperStr[mos_selectEquipIndex]);
			labelNum.Text = tostring(haveNum);
		else
			local gemVale = resTableManager:GetValue(ResTable.gemstone, tostring(resid), 'value');
			allBottombg[4]:GetLogicChild('label').Text = GemWord[mos_selectEquipIndex]..LANG_GEM;
			allBottombg[5]:GetLogicChild('label').Text = tostring(level);
			allBottombg[6]:GetLogicChild('label').Text = '+'..' '..tostring(gemVale);
			allBottombg[6]:GetLogicChild('forProper').Image = GetPicture(gemProperStr[mos_selectEquipIndex]);
			labelNum.Text = tostring(haveNum);
		end
	end

	o.setSelectEvent = function(groupID, method)
		o.ctrl.GroupID = groupID;
		o.ctrl:SubscribeScriptedEvent('RadioButton::SelectedEvent', method);
	end

	o.setClickEvent = function(method)
		o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', method);
	end

	o.setTag = function(tag)
		o.ctrl.Tag = tag;
		--o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'GemPanel:onChooseMosGem');
	end

	o.setSelected = function()
		o.ctrl.Selected = true;
	end

	o.getTag = function()
		return o.ctrl.Tag;
	end

	o.getNum = function()
		return labelNum.Text;
	end

	o.getLevel = function()
		return gemLevel;
	end

	o.setMargin = function(x1,y1,x2,y2)
		o.ctrl.Margin = Rect(x1,y1,x2,y2);
	end

	o.setNumVisible = function(isVisible)
		labelNum.Visibility = isVisible and Visibility.Visible or Visibility.Hidden;
	end

	o.isVisible = function()
		return o.ctrl.Visibility == Visibility.Visible;
	end
end

--小头像控件
typeMethodList.memberRETemplate = function(o)
	--用到的控件
	local panelMember = o.ctrl:GetLogicChild('memberRE');
	local panelClear = o.ctrl:GetLogicChild('clearPanel');
	local panelExtra = panelMember:GetLogicChild('extraInfo');

	local imgMember = panelMember:GetLogicChild('memberREImage');
	local labelName = panelMember:GetLogicChild('top'):GetLogicChild('memberName');
	local imgGrade = panelMember:GetLogicChild('top'):GetLogicChild('gradeStar');
	local labelLevel = panelMember:GetLogicChild('lvPanel'):GetLogicChild('lvNum');	
	local extraInfo = panelExtra:GetLogicChild('extraInfo');
	local imgProperty = panelMember:GetLogicChild('propertyIcon');

	o.init = function()
		o.ctrl.Margin = Rect(10,10,0,0);
	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.initWithRole = function(role)
		imgMember.Image = GetPicture('navi/' .. role.headImage .. '.ccz');
		labelName.Text = role.name;
		imgGrade.Image = GetPicture('kapai/rank_' .. role.rank .. '.ccz');
		labelLevel.Text = tostring(role.lvl.level)
		panelExtra.Visibility = Visibility.Hidden;
		imgProperty.Image = GetPicture('kapai/shuxing_' .. role.attribute .. '.ccz');
	end

	o.setClear = function()
		panelMember.Visibility = Visibility.Hidden;
		panelClear.Visibility = Visibility.Visible;
	end

	o.setRoleWithPid = function(roleid)
		local role = ActorManager:GetRole(roleid)

		panelMember.Visibility = Visibility.Visible;
		panelClear.Visibility = Visibility.Hidden;

		imgMember.Image = GetPicture('navi/' .. role.headImage .. '.ccz');
		labelName.Text = role.name;
		imgGrade.Image = GetPicture('kapai/rank_' .. role.rank .. '.ccz');
		labelLevel.Text = tostring(role.lvl.level)
		panelExtra.Visibility = Visibility.Hidden;
		imgProperty.Image = GetPicture('kapai/shuxing_' .. role.attribute .. '.ccz');
	end

	o.setClickFun = function(fun)
		o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', fun);
	end

	o.setMargin = function(x, y)
		o.ctrl.Margin = Rect(x,y,0,0);
	end

	o.setTag = function(tag)
		o.ctrl.Tag = tag;
	end
end

local properStr = {'生命', '攻撃', '技攻', '防御', '技防'};--生命 物攻 技攻 物防  技防                                 
local properinfo = {'rankup_hp', 'rankup_atk', 'rankup_mgc', 'rankup_def', 'rankup_res'};
typeMethodList.UpStar_BottomBgTemplate = function (o)
	local curnum = o.ctrl:GetLogicChild('CurNum');
	local nextnum = o.ctrl:GetLogicChild('NextNum');
	local propertyImage = o.ctrl:GetLogicChild('propertyImage');
	local propertext = o.ctrl:GetLogicChild('propertyText');
	local arrowImg = o.ctrl:GetLogicChild('arrowImg');
	o.init = function()    
	end
	local s_curPro, s_nextPro;
	o.initProperInfo = function (role, index)
		s_curPro = resTableManager:GetValue(ResTable.qualityup_attribute, 
		tostring(role.resid * 100 + role.rank), properinfo[index]);
		if(role.rank < 5) then
			s_nextPro = resTableManager:GetValue(ResTable.qualityup_attribute, tostring(role.resid * 100 + role.rank + 1), properinfo[index]);

		else
			s_nextPro = resTableManager:GetValue(ResTable.qualityup_attribute, tostring(role.resid * 100 + role.rank ), properinfo[index]);	                              
		end
		curnum.Text = tostring(s_curPro * 100).. '%';
		nextnum.Text = tostring(s_nextPro * 100).. '%';
		return s_curPro, s_nextPro;
	end
	o.initbg = function(tag)
		propertext.Text = properStr[tag];
	end

end

typeMethodList.gemMosTemplate = function(o)
	--用到的控件
	local panelGem = o.ctrl:GetLogicChild('gem');
	local gemItem = customUserControl.new(panelGem, 'gemItemTemplate');
	local btnHecheng = o.ctrl:GetLogicChild('btn_hecheng');
	local btnXiexia = o.ctrl:GetLogicChild('btn_xiexia');
	local btnXiangqian = o.ctrl:GetLogicChild('btn_xiangqian');
	local labelGemType = o.ctrl:GetLogicChild('labelGemType');
	local labelGem = o.ctrl:GetLogicChild('labelGem');
	local brush = o.ctrl:GetLogicChild('brush');

	o.init = function()

	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.initWithGem = function(gemid, equipIndex, gemIndex)
		if 0 >= gemid then
			local gemList = resTableManager:GetValue(ResTable.gemstone_part, tostring(equipIndex), 'attribute');
			local attribute = gemList[gemIndex];
			labelGemType.Text = GemWord[attribute];
			btnXiangqian.Tag = attribute * 100 + gemIndex;

			labelGem.Visibility = Visibility.Visible;
			labelGemType.Visibility = Visibility.Visible;
			btnXiangqian.Visibility = Visibility.Visible;
			brush.Visibility = Visibility.Visible;
			panelGem.Visibility = Visibility.Hidden;
			btnHecheng.Visibility = Visibility.Hidden;
			btnXiexia.Visibility = Visibility.Hidden;
		else
			btnXiexia.Tag = gemIndex;
			labelGem.Visibility = Visibility.Hidden;
			labelGemType.Visibility = Visibility.Hidden;
			btnXiangqian.Visibility = Visibility.Hidden;
			brush.Visibility = Visibility.Hidden;
			gemItem.initWithGem(gemid);
			panelGem.Visibility = Visibility.Visible;
			btnHecheng.Visibility = Visibility.Visible;
			btnXiexia.Visibility = Visibility.Visible;
			btnHecheng.Tag = gemid;
			if gemid % 100 == 7 then
				btnHecheng.Visibility = Visibility.Hidden;
			end
		end

		btnHecheng:SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:onShowQuick');
		btnXiangqian:SubscribeScriptedEvent('Button::ClickEvent', 'GemSelectPanel:Show');
		btnXiexia:SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:onDismantle')
	end
end

typeMethodList.smallItemTemplate = function(o)
	local item = customUserControl.new(o.ctrl:GetLogicChild('img'), 'itemTemplate');
	local lblCount = o.ctrl:GetLogicChild('count');

	o.init = function()

	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.initReward = function(itemId, count)
		item.initWithInfo(itemId, -1, 50, false);
		lblCount.Text = 'x' .. count;
	end
end

typeMethodList.TaskTemplate = function(o)
	local bp 			= o.ctrl:GetLogicChild('buttonPanel');
	bp.Visibility      = Visibility.Visible;
	local btnGo        = bp:GetLogicChild('advanceBtn');
	local btnGet       = bp:GetLogicChild('getBtn');
	local btnno        = bp:GetLogicChild('noBtn');
	local btnGetReward = bp:GetLogicChild('getNow');
	local ceName       = o.ctrl:GetLogicChild('taskName');
	local lblContent   = o.ctrl:GetLogicChild('taskInfoText');
	local lblCondition = o.ctrl:GetLogicChild('progressORgrade');
	local spReward     = o.ctrl:GetLogicChild('rewardPanel');
	local imgIcon      = o.ctrl:GetLogicChild('actorFrame'):GetLogicChild('actorImage');
	local dailyIcon 	 = o.ctrl:GetLogicChild('dailyIcon');

	local setReward = function(data ,flag)
		flag = flag or 0

		local item;
		if data['power'] and data['power'] ~= 0 then
			item = customUserControl.new(spReward, 'smallItemTemplate');
			item.initReward(10005, data['power']);
		end
		if data['coin'] and data['coin'] ~= 0 then
			item = customUserControl.new(spReward, 'smallItemTemplate');
			item.initReward(10001, data['coin']);
		end
		if data['diamond'] and data['diamond'] ~= 0 then
			item = customUserControl.new(spReward, 'smallItemTemplate');
			item.initReward(10003, data['diamond']);
		end
		if data['exp'] and data['exp'] ~= 0 then
			item = customUserControl.new(spReward, 'smallItemTemplate');
			item.initReward(10011, data['exp']);
			--双倍每日任务
			if ActivityRechargePanel:QuiryDoubleReward("DailyTask") and flag > 0 then
				item.initReward(10011, data['exp']*1.2)
			end 
		end
		if data['reward'] and next(data['reward']) then
			for _, r in ipairs(data['reward']) do
				if not ActivityRechargePanel:isInMidAutumnActivity() and r[1] == 16018 then
				else
					item = customUserControl.new(spReward, 'smallItemTemplate');
					item.initReward(r[1], r[2]);
				end
			end
		end
		if data['item_id'] and next(data['item_id']) then
			for _, r in ipairs(data['item_id']) do
				if not ActivityRechargePanel:isInMidAutumnActivity() and r[1] == 16018 then
				else
					item = customUserControl.new(spReward, 'smallItemTemplate');
					item.initReward(r[1], r[2]);
				end
			end
		end
	end

	o.init = function()

	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.initPlotTask = function(task)
		local font = uiSystem:FindFont('huakang_20_noborder');
		ceName:AddText(task['name'], Configuration.BlackColor, font);
		font = uiSystem:FindFont('huakang_16');
		if task['task_class'] == TaskClass.main then
			ceName:AddText(LANG_plotTaskPanel_1, Configuration.MainColor, font);
		elseif task['task_class'] == TaskClass.Bline then
			ceName:AddText(LANG_plotTaskPanel_2, Configuration.BLineColor, font);
		end
		lblContent.Text = task['description'];
		imgIcon.Visibility = Visibility.Hidden;
		dailyIcon.Visibility = Visibility.Visible;
		dailyIcon.Image = GetPicture('icon/' .. task['icon'] .. '.ccz');
		local level = ActorManager.user_data.role.lvl.level;		
		if level < task['level'] then
			lblCondition.Font = uiSystem:FindFont('huakang_20_noborder');
			lblCondition.TextColor = Configuration.PinkColor;
			lblCondition.Text = string.format(LANG_plotTaskPanel_8, task['level']);
			btnno.Visibility = Visibility.Visible;
			btnGet.Visibility, btnGo.Visibility = Visibility.Hidden, Visibility.Hidden;
		elseif Task:isComplete(task) then
			lblCondition.Text = LANG_plotTaskPanel_3;
			btnGet.Text = LANG_plotTaskPanel_6;
			btnGet.Visibility, btnGo.Visibility= Visibility.Visible, Visibility.Hidden;
		elseif task.step == Task.TaskUnreceive then
			lblCondition.TextColor = Configuration.YellowColor;
			lblCondition.Text = "";
			btnGo.Visibility, btnGet.Visibility= Visibility.Hidden, Visibility.Hidden;
			btnGetReward.Visibility = Visibility.Visible;
		else
			lblCondition.TextColor = Configuration.WhiteColor;
			lblCondition.Text ="達成度".. task.step .. '/' .. task['value'][2];
			--btnGo.Text = LANG_plotTaskPanel_5;
			btnGo.Visibility, btnGet.Visibility = Visibility.Visible, Visibility.Hidden;
		end        
		setReward(task);
		--
		btnGo.Tag, btnGet.Tag, btnGetReward.Tag = task['id'], task['id'], task['id']
		btnGo:SubscribeScriptedEvent('Button::ClickEvent', 'PlotTaskPanel:onGoToClick');
		btnGet:SubscribeScriptedEvent('Button::ClickEvent', 'PlotTaskPanel:onGetToClick');
		btnGetReward:SubscribeScriptedEvent('Button::ClickEvent', 'PlotTaskPanel:onGetToClick');
	end

	o.initDailyTask = function(dtid, step)
		local data = resTableManager:GetRowValue(ResTable.daily_task, tostring(dtid));
		local font = uiSystem:FindFont('huakang_20_noborder');
		ceName:AddText(data['name'], Configuration.BlackColor, font);
		lblContent.Text = data['description'];
		imgIcon:GetVisualParent().Visibility = Visibility.Hidden;
		dailyIcon.Visibility = Visibility.Visible;
		dailyIcon.Image   = GetPicture('icon/' .. data['icon'] .. '.ccz');
		local collected = false;
		for _, dt in pairs(Task.dailyTask) do
			if dt.resid == dtid and dt.collect == 1 then
				collected = true;
			end
		end
		--进度
		if ActorManager.user_data.role.lvl.level < data['openlv'] then
			lblCondition.Font = uiSystem:FindFont('huakang_20_noborder');
			lblCondition.TextColor = Configuration.PinkColor;
			lblCondition.Text      = string.format(LANG_plotTaskPanel_8, data['openlv']);
			btnno.Visibility = Visibility.Visible;
			btnGet.Visibility, btnGo.Visibility = Visibility.Hidden, Visibility.Hidden;
		elseif step < data['times'] then
			lblCondition.Text = step .. '/' .. data['times'];
			btnGo.Visibility, btnGet.Visibility = Visibility.Visible, Visibility.Hidden;
		elseif collected then
			lblCondition.Text = "";
			btnGet.Text = LANG_plotTaskPanel_9;
			btnGet.Visibility, btnGo.Visibility = Visibility.Visible, Visibility.Hidden;
			btnGet.Enable = false;
		else
			lblCondition.Text = LANG_plotTaskPanel_3;
			btnGet.Text = LANG_plotTaskPanel_6;
			btnGet.Visibility, btnGo.Visibility = Visibility.Visible, Visibility.Hidden;
		end

		setReward(data , 2);  --双倍奖励显示 增加参数

		btnGo.Tag, btnGet.Tag = dtid, dtid;
		btnGo:SubscribeScriptedEvent('Button::ClickEvent', 'PlotTaskPanel:onGoToDailyClick');
		btnGet:SubscribeScriptedEvent('Button::ClickEvent', 'PlotTaskPanel:onGetToDailyClick');
	end

	o.initAchievementTask = function(dtid, step)
		local data = resTableManager:GetRowValue(ResTable.achievement_task, tostring(dtid));
		local font = uiSystem:FindFont('huakang_20_noborder');
		ceName:AddText(data['name'], Configuration.BlackColor, font);
		lblContent.Text = data['description'];
		imgIcon:GetVisualParent().Visibility = Visibility.Hidden;
		dailyIcon.Visibility = Visibility.Visible;
		dailyIcon.Image   = GetPicture('icon/' .. data['icon'] .. '.ccz');
		local collected = false;
		for _, dt in pairs(Task.achievement) do
			if dt.resid == dtid and dt.collect == 1 then
				collected = true;
			end
		end
		--进度
		if ActorManager.user_data.role.lvl.level < data['openlv'] then
			lblCondition.Font = uiSystem:FindFont('huakang_20_noborder');
			lblCondition.TextColor = Configuration.PinkColor;
			lblCondition.Text      = string.format(LANG_plotTaskPanel_8, data['openlv']);
			btnno.Visibility = Visibility.Visible;
			btnGet.Visibility, btnGo.Visibility = Visibility.Hidden, Visibility.Hidden;
		elseif step < data['times'] then
			lblCondition.Text = step .. '/' .. data['times'];
			btnGo.Visibility, btnGet.Visibility = Visibility.Visible, Visibility.Hidden;
		elseif collected then
			lblCondition.Text = "";
			btnGet.Text = LANG_plotTaskPanel_9;
			btnGet.Visibility, btnGo.Visibility = Visibility.Visible, Visibility.Hidden;
			btnGet.Enable = false;
		else
			lblCondition.Text = LANG_plotTaskPanel_3;
			btnGet.Text = LANG_plotTaskPanel_6;
			btnGet.Visibility, btnGo.Visibility = Visibility.Visible, Visibility.Hidden;
			if UserGuidePanel:IsInGuidence(UserGuideIndex.dailytask, 1) and data['id'] == 10001 then
				UserGuidePanel:ShowGuideShade( btnGet,GuideEffectType.hand,GuideTipPos.right,'', 0.3);
			end
		end
		setReward(data);

		btnGo.Tag, btnGet.Tag = dtid, dtid;
		btnGet.TagExt = data['typeindex'];
		btnGo:SubscribeScriptedEvent('Button::ClickEvent', 'PlotTaskPanel:onGoToAchievementClick');
		btnGet:SubscribeScriptedEvent('Button::ClickEvent', 'PlotTaskPanel:onGetToAchievementClick');
	end

end

typeMethodList.teamTemplate = function(o)
	local labelTeamNum = o.ctrl:GetLogicChild('teamNumber');
	local labelTeamName = o.ctrl:GetLogicChild('teamName');
	local memberList = {};
	for i=1, 5 do
		memberList[i] = o.ctrl:GetLogicChild('member' .. i);
	end

	o.init = function()

	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.initWithTeam = function(team)
		labelTeamNum.Text = tostring(team.tid);
		for i=1, 5 do
			if team[i] ~= -1 then
				local role = ActorManager:GetRole(team[i]);
				local image = uiSystem:CreateControl('ImageElement');
				image.AutoSize = false;
				image.Size = Size(140,116);
				image.Image = GetPicture('navi/' .. role.headImage .. '.ccz');
				memberList[i]:AddChild(image);
			end
		end
	end

	o.setMargin = function(x, y)
		o.ctrl.Margin = Rect(x,y,0,0);
	end
end

--公会技能模板
typeMethodList.guildSkillTemplate = function(o)
	local imgSkill = o.ctrl:GetLogicChild('item'):GetLogicChild('skillIcon');
	local labelSkillName = o.ctrl:GetLogicChild('skillName');
	local labelProperty = o.ctrl:GetLogicChild(''):GetLogicChild('Font');
	local labelPropertyNum = o.ctrl:GetLogicChild(''):GetLogicChild('num');
	local labelLvNum = o.ctrl:GetLogicChild('lvPanel'):GetLogicChild('num');
	local labelgm = o.ctrl:GetLogicChild('xiaohaoLabel'):GetLogicChild('num');
	local panelXiaohao = o.ctrl:GetLogicChild('xiaohaoLabel');
	local panelOpen = o.ctrl:GetLogicChild('openLabel');
	local labelOpen = panelOpen:GetLogicChild('num');
	local btnLearn = o.ctrl:GetLogicChild('Button');

	o.init = function()
	end

	o.ctrlShow = function()

	end

	o.ctrlHide = function()

	end

	o.initWithSkill = function(skillid, lv)
		local data = resTableManager:GetRowValue(ResTable.unionSkill, tostring(skillid*1000+lv));
		imgSkill.Image = GetPicture('icon/' .. data['icon'] .. '.ccz');
		labelSkillName.Text = data['name'];
		labelProperty.Text = data['name'];
		labelPropertyNum.Text = '+' .. data['value'];
		labelLvNum.Text = tostring(lv);

		--设置消耗
		local data2 = resTableManager:GetRowValue(ResTable.unionSkillCon, tostring(lv));
		for _,id in ipairs(data2['type_one']) do
			if id == resid then
				return data['cost_one'];
			end
		end
		return data['cost_two'];

		--设置状态
	end

	o.setConsume = function()
		panelXiaohao.Visibility = Visibility.Visible;
		panelOpen.Visibility = Visibility.Hidden;
	end

	o.setOpenLv = function(lv)
		panelOpen.Visibility = Visibility.Visible;
		panelXiaohao.Visibility = Visibility.Hidden;
		labelOpen.Text = tostring(lv);
	end

	o.setLearnFun = function(fun)
		btnLearn:SubscribeScriptedEvent('Button::ClickEvent', fun);
	end
end

typeMethodList.arenaResultTemplate = function(o)
	local iconAttack = o.ctrl:GetLogicChild('attack');
	local iconDefend = o.ctrl:GetLogicChild('defend');
	local iconWin = o.ctrl:GetLogicChild('win');
	local iconLose = o.ctrl:GetLogicChild('lose');
	local name = o.ctrl:GetLogicChild('name');
	local fp = o.ctrl:GetLogicChild('fp');
	local time = o.ctrl:GetLogicChild('time');
	local rank = o.ctrl:GetLogicChild('rank');
	local iconUp = o.ctrl:GetLogicChild('arrowUp');
	local iconDown = o.ctrl:GetLogicChild('arrowDown');
	local btnShare = o.ctrl:GetLogicChild('share');
	local btnPlayback = o.ctrl:GetLogicChild('playRecord');
	local lAttack = o.ctrl:GetLogicChild('lAttack');
	local lDefend = o.ctrl:GetLogicChild('lDefend');

	local setAttack = function()
		iconAttack.Visibility = Visibility.Visible;
		iconDefend.Visibility = Visibility.Hidden;
		lAttack.Visibility = Visibility.Visible;
		lDefend.Visibility = Visibility.Hidden;
	end

	local setDefend = function()
		iconAttack.Visibility = Visibility.Hidden;
		iconDefend.Visibility = Visibility.Visible;
		lAttack.Visibility = Visibility.Hidden;
		lDefend.Visibility = Visibility.Visible;
	end

	local setWin = function()
		iconWin.Visibility = Visibility.Visible;
		iconLose.Visibility = Visibility.Hidden;
	end

	local setLose = function()
		iconWin.Visibility = Visibility.Hidden;
		iconLose.Visibility = Visibility.Visible;
	end

	local setArrowUp = function()
		iconUp.Visibility = Visibility.Visible;
		iconDown.Visibility = Visibility.Hidden;
	end

	local setArrowDown = function()
		iconUp.Visibility = Visibility.Visible;
		iconDown.Visibility = Visibility.Hidden;
	end

	local setArrowNone = function()
		iconUp.Visibility = Visibility.Hidden;
		iconDown.Visibility = Visibility.Hidden;
	end

	local getTime = function(t)
		if t < 60 then
			return LANG_arenaPanel_18;
		elseif t < 3600 then
			return math.floor(t/60) .. LANG_arenaPanel_19;
		elseif t < 86400 then
			return math.floor(t/3600) .. LANG_arenaPanel_20;
		elseif t < 2592000 then
			return math.floor(t/86400) .. LANG_arenaPanel_21;
		end
	end

	local setTargetInfo = function(name_, fp_, time_, rank_)
		name.Text = tostring(name_);
		fp.Text = tostring(fp_);
		time.Text = getTime(time_);
		rank.Text = tostring(rank_);
	end

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithRecord = function(record)
		if record.caster_uid == ActorManager.user_data.uid then
			setTargetInfo(record.target_name, record.target_fp, record.during, record.cast_rank);
			setAttack();
			if record.is_win then
				setWin(); setArrowUp();
			else
				setLose(); setArrowNone();
			end
		else
			setTargetInfo(record.caster_name, record.caster_fp, record.during, record.target_rank);
			setDefend();
			if not record.is_win then
				setWin(); setArrowNone();
			else
				setLose(); setArrowDown();
			end
		end
		btnShare:SubscribeScriptedEvent('Button::ClickEvent', 'ArenaDialogPanel:onShare');
		btnPlayback:SubscribeScriptedEvent('Button::ClickEvent', 'ArenaDialogPanel:onPlayback');
	end
end

typeMethodList.PrestigeShopTemplate = function(o)
	local itemPanel = o.ctrl:GetLogicChild('item');
	local limitIcon = o.ctrl:GetLogicChild('limit');
	local itemName = o.ctrl:GetLogicChild('name');
	local itemConsume = o.ctrl:GetLogicChild('xiaohaoLabel');
	local tipPanel = o.ctrl:GetLogicChild('tip');
	local limitBuy = tipPanel:GetLogicChild('num');
	local btnBuy = o.ctrl:GetLogicChild('Button');
	local overPanel = o.ctrl:GetLogicChild('over');
	local haveLabel = o.ctrl:GetLogicChild('haveLabel');
	local SWicon = o.ctrl:GetLogicChild('icon1')
	local price = 0;
	local limitnum = 0;
	local itemNum = 0;
	local haveCount = 0;
	local limitTip = tipPanel:GetLogicChild(2);
	local limitImg = tipPanel:GetLogicChild(0);
	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithItem = function(item, shopindex)
		local itm;
		if shopindex == Prestige_shoptype.normal then
			itm = resTableManager:GetRowValue(ResTable.item, tostring(10010))
		else
			itm = resTableManager:GetRowValue(ResTable.item, tostring(16013))
		end
		SWicon.Image = GetPicture('icon/'..itm['icon']..'.ccz')
		if item.isnew then
			limitIcon.Visibility = Visibility.Hidden;
		end
		local itemO = customUserControl.new(itemPanel, 'itemTemplate');
		itemO.initWithInfo(item.item_id,item.count,75,true);
		itemName.Text = tostring(item.name);
		itemConsume.Text = tostring(item.price);
		limitnum = item.limited - item.buy_num;
		if limitnum == 0 and item.limited ~= 0 then
			btnBuy.Visibility = Visibility.Hidden;
			tipPanel.Visibility = Visibility.Hidden;
			overPanel.Visibility = Visibility.Visible;
		else
			if limitnum == 0 then
				limitBuy.Visibility = Visibility.Hidden;
				limitTip.Visibility = Visibility.Hidden;
				limitImg.Visibility = Visibility.Hidden;
			else
				limitBuy.Text = tostring(limitnum);
				limitBuy.Visibility = Visibility.Visible;
				limitTip.Visibility = Visibility.Visible;
				limitImg.Visibility = Visibility.Visible;
			end
		end
		price = item.price;
		btnBuy.Tag = item.id;
		btnBuy:SubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onBuyItem');
		-- btnBuy:SubscribeScriptedEvent('Button::ClickEvent', 'PrestigeShopPanel:onBuyItem');
		haveLabel.Text = LANG_prestigeShopPanel_7 .. Package:GetItemCount( item.item_id );
		haveCount = Package:GetItemCount( item.item_id );
		itemNum = item.count;
	end

	o.setTimes = function(times)
		limitBuy.Text = tostring(times);
	end

	o.getPrice = function()
		return price;
	end
	o.updateItem = function()
		haveCount = haveCount + itemNum;
		haveLabel.Text = LANG_prestigeShopPanel_7 .. haveCount;
		limitnum = limitnum - 1;
		if limitnum == 0 then
			btnBuy.Visibility = Visibility.Hidden;
			tipPanel.Visibility = Visibility.Hidden;
			local overPanel = o.ctrl:GetLogicChild('over');
			overPanel.Visibility = Visibility.Visible;
		else
			limitBuy.Text = tostring(limitnum);
		end

	end
end

typeMethodList.ChipShopTemplate = function(o)
	local itemPanel = o.ctrl:GetLogicChild('item');
	local limitIcon = o.ctrl:GetLogicChild('limit');
	local itemName = o.ctrl:GetLogicChild('name');
	local itemConsume = o.ctrl:GetLogicChild('xiaohaoLabel');
	local tipPanel = o.ctrl:GetLogicChild('tip');
	local limitBuy = tipPanel:GetLogicChild('num');
	local btnBuy = o.ctrl:GetLogicChild('Button');
	local overPanel = o.ctrl:GetLogicChild('over');
	local haveLabel = o.ctrl:GetLogicChild('haveLabel');
	local pointLabel = o.ctrl:GetLogicChild('point');
	local SWicon = o.ctrl:GetLogicChild('icon1')
	local price = 0;
	local limitnum = 0;
	local itemNum = 0;
	local haveCount = 0;
	local limitTip = tipPanel:GetLogicChild(2);
	local limitImg = tipPanel:GetLogicChild(0);
	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithItem = function(item)
		local itm = resTableManager:GetRowValue(ResTable.item, tostring(16005))
		SWicon.Image = GetPicture('icon/'..itm['icon']..'.ccz')
		if item.isnew then
			limitIcon.Visibility = Visibility.Hidden;
		end
		local itemO = customUserControl.new(itemPanel, 'itemTemplate');
		itemO.initWithInfo(item.item_id,item.count,75,true);
		itemName.Text = tostring(item.name);
		itemConsume.Text = tostring(item.price);
		limitnum = item.limited - item.buy_num;
		if limitnum == 0 and item.limited ~= 0 then
			btnBuy.Visibility = Visibility.Hidden;
			tipPanel.Visibility = Visibility.Hidden;
			overPanel.Visibility = Visibility.Visible;
		else
			if limitnum == 0 then
				limitBuy.Visibility = Visibility.Hidden;
				limitTip.Visibility = Visibility.Hidden;
				limitImg.Visibility = Visibility.Hidden;
			else
				limitBuy.Text = tostring(limitnum);
				limitBuy.Visibility = Visibility.Visible;
				limitTip.Visibility = Visibility.Visible;
				limitImg.Visibility = Visibility.Visible;
			end
		end

		if item.trend == 0 then
			pointLabel.Visibility = Visibility.Hidden;
		elseif item.trend < 0  then
			pointLabel.Visibility = Visibility.Visible;
			pointLabel.Image = GetPicture('common/chipsmash_point.ccz');
		elseif item.trend > 0 then
			pointLabel.Visibility = Visibility.Visible;
			pointLabel.Image = GetPicture('love/love_point.ccz');
		end
		price = item.price;
		btnBuy.Tag = item.id;
		btnBuy:SubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onBuyItemChip');
		haveLabel.Text = LANG_prestigeShopPanel_7 .. Package:GetItemCount( item.item_id );
		haveCount = Package:GetItemCount( item.item_id );
		itemNum = item.count;
	end

	o.setTimes = function(times)
		limitBuy.Text = tostring(times);
	end

	o.getPrice = function()
		return price;
	end
	o.updateItem = function(num)
		haveLabel.Text = LANG_prestigeShopPanel_7 .. haveCount;
		limitnum = limitnum - num;
		if limitnum == 0 then
			btnBuy.Visibility = Visibility.Hidden;
			tipPanel.Visibility = Visibility.Hidden;
			local overPanel = o.ctrl:GetLogicChild('over');
			overPanel.Visibility = Visibility.Visible;
		else
			limitBuy.Text = tostring(limitnum);
		end

	end
	o.SetPrice = function(priceNum,trend)
		price = priceNum;
		itemConsume.Text = tostring(priceNum);
		if trend == 0 then
			pointLabel.Visibility = Visibility.Hidden;
		elseif trend < 0  then
			pointLabel.Visibility = Visibility.Visible;
			pointLabel.Image = GetPicture('common/chipsmash_point.ccz');
		elseif trend > 0 then
			pointLabel.Visibility = Visibility.Visible;
			pointLabel.Image = GetPicture('love/love_point.ccz');
		end
	end

	o.SetNum = function(num)
		haveCount = num;
		haveLabel.Text = LANG_prestigeShopPanel_7 .. haveCount;
	end
end


typeMethodList.meritoriousTemplate = function(o)
	local lName = o.ctrl:GetLogicChild('name');
	local lCount = o.ctrl:GetLogicChild('num');
	local lNeed = o.ctrl:GetLogicChild('need');
	local iIcon = o.ctrl:GetLogicChild('icon');
	local notopen = o.ctrl:GetLogicChild('unselect');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithData = function(data)
		lName.Text = data['name'];
		local icon = resTableManager:GetValue(ResTable.item, tostring(data['reward'][1]), 'icon');
		iIcon.Image = GetPicture('icon/' .. icon .. '.ccz');
		lCount.Text = 'x' .. data['reward'][2];
		lNeed.Text = tostring(data['meritorious']);
	end

	o.open = function()
		notopen.Visibility = Visibility.Hidden;	
	end

	o.height = function()
		return o.ctrl.Size.Height;
	end
end

typeMethodList.FriendFlowerTemplate = function(o)
	local labelName = o.ctrl:GetLogicChild('name');
	local labelFp = o.ctrl:GetLogicChild('zhandouli');
	local btnFlower = o.ctrl:GetLogicChild('SendButton');
	btnFlower.Text = '応援';
	local panelHead = o.ctrl:GetLogicChild('panelHead');
	local bSelected = o.ctrl:GetLogicChild('bg');
	local head = customUserControl.new(panelHead, 'teamInfoTemplate');
	local sendheart = o.ctrl:GetLogicChild('sendheart');
	btnFlower:SubscribeScriptedEvent('Button::ClickEvent', 'FriendListPanel:sendFlower');
	local friendName;
	local uid;
	local Lv;
	local resid;
	local hasSendFlower = false;
	o.init = function()
		bSelected.Visibility = Visibility.Hidden;
		btnFlower.Visibility = Visibility.Hidden;
		head.setFriendStatus();
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
		bSelected.Visibility = Visibility.Hidden;
	end

	o.setSelected = function(flag)
		head.showlvPanel();
		bSelected.Visibility = flag and Visibility.Visible or Visibility.Hidden;	   
	end

	o.initWithRole = function(role)
		head.initWithFriendRole(role);
		labelName.Text = tostring(role.name);
		labelFp.Text = tostring(role.fp);
		if role.online == 0  then
			o.setOffline();
		else
			o.setOnline();
		end
		if role.checkGiveState then

		end
		hasSendFlower = (role.checkGiveState == 1);
		btnFlower.Visibility = hasSendFlower and Visibility.Hidden or Visibility.Visible;
		sendheart.Visibility = hasSendFlower and Visibility.Visible or Visibility.Hidden;
		head.setScale(0.7,0.7);
		head.setMargin(-11,-10);
		friendName = role.name;
		uid = role.uid;
		Lv = role.lv;
		resid = role.resid;
	end

	o.setTag = function(tag)
		btnFlower.Tag = tag;
		o.ctrl.Tag = tag;
		o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'FriendListPanel:onSelectFriend');
	end

	o.setOffline = function()

		head.setFriendOffline(); 	
	end

	o.setOnline = function()
		btnFlower.Visibility = hasSendFLower and Visibility.Hidden or Visibility.Visible;
		head.setFriendOnline();
	end

	o.getUid = function()
		return uid;
	end

	o.getSendBtn = function ()
		return btnFlower;
	end

	o.getName = function()
		return friendName;
	end

	o.getLv = function()
		return Lv;
	end
	o.getResid = function()
		return resid;
	end

	o.setHasSendFlower = function()
		btnFlower.Visibility = Visibility.Hidden;
		sendheart.Visibility = Visibility.Visible;
	end

end

local function checklevel(role)
	local curLv = nil;
	local s_lv = nil;
	if (role.lv) then
		s_lv = role.lv;
	else
		s_lv = role.lvl.level;
	end
	if(s_lv <= 10) then
		curLv = '0'..s_lv;
	else
		curLv = s_lv;
	end
	return curLv;  	 	
end

typeMethodList.gemSystemInfoTemplate = function (o)
	local btn = o.ctrl:GetLogicChild('radio');
	local rolePanel = btn:GetLogicChild('panel');
	local role = customUserControl.new(rolePanel, 'cardHeadTemplate');

	o.init = function()
	end

	o.initWithPid = function(pid)
		btn.GroupID = RadionButtonGroup.selectGemMosRole;
		role.initWithPid(pid, 80);
		btn.Tag = pid;
		btn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'GemPanel:onRoleClick');
	end

	o.setSelected = function()
		btn.Selected = true;
	end
end

typeMethodList.cardPropertyTemplate = function (o)
	local nameProper = o.ctrl:GetLogicChild('nameProper');
	local nameInfo   = o.ctrl:GetLogicChild('nameInfo');
	local leftList   = {'生日', 'BWH', '血型', '身長', '趣味'};
	o.init = function()
	end
	o.initLeft = function (tagIndex, leftInfo)
		nameInfo.Text = tostring(leftInfo);
		nameProper.Text = leftList[tagIndex];
	end
	o.initRight= function (tagIndex, rightInfo)
		nameInfo.Text = tostring(rightInfo);
		nameProper.Text = GemWord[tagIndex];
	end
end

typeMethodList.teamInfoTemplate = function(o)
	local imageHead = o.ctrl:GetLogicChild('image');
	local imgQuality = o.ctrl:GetLogicChild('nature');
	local imgSelect = o.ctrl:GetLogicChild('select');
	local lvpanel = o.ctrl:GetLogicChild('lvPanel');
	local labelLv = lvpanel:GetLogicChild('lv');
	local frame = o.ctrl:GetLogicChild('1');
	local button = o.ctrl:GetLogicChild('button');
	o.init = function()
	end

	o.showlvPanel = function ()
		lvpanel.Visibility = Visibility.Visible;
	end
	o.ctrlShow = function()
		o.ctrl:GetVisualParent().Visibility = Visibility.Visible;
	end

	o.ctrlHide = function()
		o.ctrl:GetVisualParent().Visibility = Visibility.Hidden;
	end

	o.getImageHead = function(  )
		return button
	end

	o.initWithFriendRole = function(role)
		local imagePath = resTableManager:GetValue(ResTable.navi_main, tostring(role.resid), 'role_path_icon');
		if not imagePath then
			imagePath = resTableManager:GetValue(ResTable.navi_main, tostring(101), 'role_path_icon');
		end
		imageHead.Image = GetPicture('navi/' .. imagePath .. '.ccz');
		if(role.lv) then
			labelLv.Text = tostring(checklevel(role));	
		end	
	end
	o.initWithTrain  = function (role, tag)    --培养icon info
		local imagePath = resTableManager:GetValue(ResTable.navi_main, tostring(role.resid), 'role_path_icon');
		if not imagePath then
			imagePath = resTableManager:GetValue(ResTable.navi_main, tostring(101), 'role_path_icon');
		end
		imageHead.Image = GetPicture('navi/' .. imagePath .. '.ccz');
		labelLv.Text = tostring(checklevel(role));	   
		imgSelect.Visibility = Visibility.Hidden; 
		-- if(role.rank < 5) then
		if(tag == 1) then
			imgQuality.Image = GetPicture('personInfo/nature_' .. role.rank - 1 .. '.ccz');
			--frame.Image = GetPicture('personInfo/personInfo_'..role.rank - 1 .. '.ccz');
		else
			imgQuality.Image = GetPicture('personInfo/nature_' .. role.rank  .. '.ccz');
			--frame.Image = GetPicture('personInfo/personInfo_'.. tostring(role.rank) .. '.ccz');
		end
		-- else
		-- imgQuality.Image = GetPicture('personInfo/nature_' .. role.rank .. '.ccz');
		--end
	end
	o.initWithPiece = function (role)        --培养碎片信息
		local imagePath = resTableManager:GetValue(ResTable.navi_main, tostring(role.resid), 'role_path_icon');
		if not imagePath then
			imagePath = resTableManager:GetValue(ResTable.navi_main, tostring(101), 'role_path_icon');
		end
		-- frame.Image = GetPicture('personInfo/personInfo_' .. role.rank.. '.ccz');
		imgSelect.Visibility = Visibility.Hidden;   
		lvpanel.Visibility = Visibility.Hidden;
		imgQuality.Visibility = Visibility.Hidden;
		local s_suipianImage = uiSystem:CreateControl('ImageElement');
		s_suipianImage.Image = GetPicture('Welfare/welfare_SuiPian.ccz');
		s_suipianImage.Margin = Rect(5, 4, 0, 0);
		frame:AddChild(s_suipianImage); 
		imageHead.Image = GetPicture('navi/' .. imagePath .. '.ccz');
	end 

	o.setFriendStatus = function()
		imgSelect.Visibility = Visibility.Hidden; 
		imgQuality.Visibility = Visibility.Hidden;
	end

	o.setFriendOnline = function()
		frame.Enable = true;
		imageHead.Enable = true;
	end

	o.setFriendOffline = function()
		frame.Enable = false;
		imageHead.Enable = false;
	end

	o.setScale = function(x,y)
		o.ctrl:SetScale(x,y);
	end

	o.setMargin = function(x,y)
		o.ctrl.Margin = Rect(x,y,0,0);
	end

	-- expedition my actor item
	o.initWithActorRole = function(role)
		imageHead.Image = GetPicture('navi/' .. role.headImage .. '.ccz');
		labelLv.Text = tostring(role.lvl.level);
		imgQuality.Image = GetPicture('personInfo/nature_' .. role.rank - 1 .. '.ccz');
		imgSelect.Visibility = Visibility.Hidden; 
		o.pid = role.pid;
		button.Tag = role.pid;
		button:SubscribeScriptedEvent('Button::ClickEvent', 'SelectActorPanel:Selected');
	end

	o.Selected = function()
		imgSelect.Visibility = Visibility.Visible; 
	end

	o.isSelected = function()
		return imgSelect.Visibility == Visibility.Visible;
	end

	o.Unselected = function()
		imgSelect.Visibility = Visibility.Hidden; 
	end

	-- expedition enemy actor item
	o.initWithMsgActor = function(role)
		imageHead.Image = ActorManager:getHeadImage(role.resid, role.lovelevel);
		labelLv.Text = tostring(role.level);
		imgSelect.Visibility = Visibility.Hidden;  --ceshi 
	end

	o.setDied = function()
		imageHead.ShaderType = IRenderer.UI_GrayShader;
	end

	o.isDied = function()
		return imageHead.ShaderType == IRenderer.UI_GrayShader;
	end

	-- treasure
	o.initWithPlayerInfo = function(info)
		o.ctrl:GetVisualParent().Horizontal = ControlLayout.H_CENTER;
		o.ctrl:GetVisualParent().Vertical = ControlLayout.V_CENTER;
		o.ctrl:GetVisualParent().Scale = Vector2(0.6, 0.6);

		if info.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
			imageHead.Image = GetPicture('navi/' .. resTableManager:GetValue(ResTable.navi_main, tostring(10000 + info.resid), 'role_path_icon') .. '.ccz');
		else
			imageHead.Image = GetPicture('navi/' .. resTableManager:GetValue(ResTable.navi_main, tostring(info.resid), 'role_path_icon') .. '.ccz');
		end

		labelLv.Text = tostring(info.grade);
		imgSelect.Visibility = Visibility.Hidden;
	end

	-- treasure revenge
	o.initWithRecord = function(record)
		if record.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
			imageHead.Image = GetPicture('navi/' .. resTableManager:GetValue(ResTable.navi_main, tostring(10000 + record.resid), 'role_path_icon') .. '.ccz');
		else
			imageHead.Image = GetPicture('navi/' .. resTableManager:GetValue(ResTable.navi_main, tostring(record.resid), 'role_path_icon') .. '.ccz');
		end
		labelLv.Text = tostring(record.lv);
		imgSelect.Visibility = Visibility.Hidden;
	end

	-- property round
	o.initWithActorRolePR = function(role, index)
		imageHead.Image = GetPicture('navi/' .. role.headImage .. '.ccz');
		labelLv.Text = tostring(role.lvl.level);
		imgQuality.Image = GetPicture('personInfo/nature_' .. role.rank - 1 .. '.ccz');
		imgSelect.Visibility = Visibility.Hidden; 
		o.index = index;
		o.pid = role.pid;
		o.role = role;
		button.Tag = index;
		button:SubscribeScriptedEvent('Button::ClickEvent', 'SelectActorPanel:Selected');
	end

	--队伍编制
	o.initWithTeamRole = function(role)
		local isShow = true;
		if not ActorManager:IsHavePartner(role.resid) then
			isShow = false;
		end

		imageHead.Image = GetPicture('navi/' .. role.headImage .. '.ccz');
		labelLv.Text = tostring(role.lvl.level);
		imgSelect.Visibility = Visibility.Hidden;
		imgQuality.Image = GetPicture('personInfo/nature_' .. role.rank - 1 .. '.ccz');
		button.Tag = role.pid;
		button:SubscribeScriptedEvent('Button::ClickEvent', 'TeamPanel:SelectEvent');

		if not isShow then
			frame.Image = GetPicture('home/head_frame_1.ccz');
		else
			--找到等级最低的装备
			local equip_lvl = 100;
			for i=1, 5 do
				local equip_resid = role.equips[tostring(i)].resid;
				local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank');
				if equip_rank < equip_lvl then
					equip_lvl = equip_rank;
				end
			end
			--根据装备等级来决定边框颜色
			frame.Image = GetPicture('home/head_frame_' .. tostring(equip_lvl) .. '.ccz');
		end
	end

	--结算界面
	o.initWithPveWin = function(role)
		imageHead.Image = GetPicture('navi/' .. role.headImage .. '.ccz');
		labelLv.Text = tostring(role.lvl.level);
		imgSelect.Visibility = Visibility.Hidden;
		imgQuality.Image = GetPicture('personInfo/nature_' .. role.rank - 1 .. '.ccz');
	end

	o.setScale = function(scale)
		o.ctrl:SetScale(scale, scale);
	end
end

typeMethodList.RankingTemplate = function(o)
	local rank 			= o.ctrl:GetLogicChild('ranking');
	local name		 	= o.ctrl:GetLogicChild('name');
	local level		 	= o.ctrl:GetLogicChild('level');
	--local chenghao 		= o.ctrl:GetLogicChild('chenghao');
	local exp	 		= o.ctrl:GetLogicChild('fp');
	local bg 			= o.ctrl:GetLogicChild('bg');
	local rank1			= o.ctrl:GetLogicChild('rewrd1');
	local rank2			= o.ctrl:GetLogicChild('rewrd2');
	local rank3			= o.ctrl:GetLogicChild('rewrd3');
	--local myself		= o.ctrl:GetLogicChild('myself');
	local title 		= o.ctrl:GetLogicChild('title');
	--local vipPanel		= o.ctrl:GetLogicChild('vipPanel');
	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initRankinfo = function(data, num, typenum, self)
		bg.Background = CreateTextureBrush('rank/ranking_item_bg_0.ccz','godsSenki');
		if data.uid and data.uid ~= '' then
			o.ctrl.TagExt = tonumber(data.uid);
			--o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RankPanel:RankingTemplateClick');
		end
		if self == true then
			bg.Background = CreateTextureBrush('rank/ranking_item_bg_1.ccz','godsSenki');
		end
		rank.Text = tostring(num);
		if typenum == RankType.Union then
			name.Text = tostring(data.name);
		else
			name.Text = tostring(data.nickname);
		end
		title.Visibility = Visibility.Visible;
		--vipPanel.Visibility = Visibility.Hidden;

		if num >5 then
			--chenghao.Visibility = Visibility.Hidden;
			title.Visibility = Visibility.Hidden;
		elseif num == 1 then
			if typenum == RankType.Fight then
				--chenghao.Text = LANG_rankPanel_11;
				title.Image = uiSystem:FindImage('rank_fight1')
			elseif typenum == RankType.Level then
				--chenghao.Text = LANG_rankPanel_13;
				title.Image = uiSystem:FindImage('rank_lv1')
			elseif typenum == RankType.Card then
				--chenghao.Text = LANG_rankPanel_15;
				title.Image = uiSystem:FindImage('rank_love1')
			elseif typenum == RankType.CardEvent then
				--chenghao.Text = LANG_rankPanel_20;
				title.Image = uiSystem:FindImage('card_event_up')
			elseif typenum == RankType.Union then
				title.Image = uiSystem:FindImage('rank_role1')
			else
				--chenghao.Text = LANG_rankPanel_18;
				title.Image = uiSystem:FindImage('rank_arena1')
			end
		else
			if typenum == RankType.Fight then
				--chenghao.Text = LANG_rankPanel_12;
				title.Image = uiSystem:FindImage('rank_fight2')
			elseif typenum == RankType.Level then
				--chenghao.Text = LANG_rankPanel_14;
				title.Image = uiSystem:FindImage('rank_lv2')
			elseif typenum == RankType.Card then
				--chenghao.Text = LANG_rankPanel_16;
				title.Image = uiSystem:FindImage('rank_love2')
			elseif typenum == RankType.CardEvent then
				--chenghao.Text = LANG_rankPanel_21;
				title.Image = uiSystem:FindImage('card_event_up')
			elseif typenum == RankType.Union then
				title.Visibility = Visibility.Hidden;
			else
				--chenghao.Text = LANG_rankPanel_19;
				title.Image = uiSystem:FindImage('rank_arena2')
			end
		end
		if typenum == RankType.Fight then
			exp.Text 	= tostring('戦闘力:'..data.fp);
			level.Text = tostring('Lv:'..data.lv);
		elseif typenum == RankType.Level then
			exp.Text 	= tostring('経験値:'..data.exp);
			level.Text = tostring('Lv:'..data.lv);
		elseif typenum == RankType.Card then
			exp.Text 	= tostring('昇格数:'..data.starnum);
			level.Text = tostring('Lv:'..data.level);
		elseif typenum == RankType.Arena then
			exp.Text = tostring('戦闘力:'..data.fp);
			level.Text = tostring('Lv:'..data.lv);
		elseif typenum == RankType.Union then
			exp.Text = tostring('総貢献値:'..data.allgm);
			level.Text = tostring('Lv:'..data.grade);	
		elseif typenum == RankType.CardEvent then
			exp.Text = tostring('勇気pt:'..data.score);
			level.Text = tostring('Lv:'..data.level);
		end
		if num == 1 then
			--o.ctrl.Background = Converter.String2Brush("godsSenki.rank_dibian1");
			rank1.Visibility = Visibility.Visible;
			rank2.Visibility = Visibility.Hidden;
			rank3.Visibility = Visibility.Hidden;
			rank.Visibility = Visibility.Hidden;
		elseif num == 2 then
			--o.ctrl.Background = Converter.String2Brush("godsSenki.rank_dibian2");
			rank2.Visibility = Visibility.Visible;
			rank1.Visibility = Visibility.Hidden;
			rank.Visibility = Visibility.Hidden;
			rank3.Visibility = Visibility.Hidden;
		elseif num == 3 then
			--o.ctrl.Background = Converter.String2Brush("godsSenki.rank_dibian3");
			rank3.Visibility = Visibility.Visible;
			rank1.Visibility = Visibility.Hidden;
			rank2.Visibility = Visibility.Hidden;
			rank.Visibility = Visibility.Hidden;
		elseif num % 2 == 1 then
			--o.ctrl.Background = Converter.String2Brush("godsSenki.rank_dibian4");
		end
		if typenum == RankType.CardEvent then
			title.Visibility = Visibility.Hidden;
		end
	end
end

typeMethodList.RankingRenQiTemplate = function(o)
	local rank 			= o.ctrl:GetLogicChild('ranking');
	local name		 	= o.ctrl:GetLogicChild('name');
	local level		 	= o.ctrl:GetLogicChild('level');
	local chenghao 		= o.ctrl:GetLogicChild('chenghao');
	local exp	 		= o.ctrl:GetLogicChild('exp');
	local total			= o.ctrl:GetLogicChild('total');
	local bg 			= o.ctrl:GetLogicChild('bg');
	local rank1			= o.ctrl:GetLogicChild('rewrd1');
	local rank2			= o.ctrl:GetLogicChild('rewrd2');
	local rank3			= o.ctrl:GetLogicChild('rewrd3');
	local myself		= o.ctrl:GetLogicChild('myself');
	local title 		= o.ctrl:GetLogicChild('title');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initRankinfo = function(data, num, typenum, self)
		if self == true then 
			myself.Visibility = Visibility.Visible;
		end
		if num >1 then
			exp.Visibility = Visibility.Hidden;
			title.Visibility = Visibility.Hidden;
		elseif num == 1 then
			exp.Text = LANG_rankPanel_17;
			title.Image = uiSystem:FindImage('rank_role1')
		end
		if typenum == RankType.Union then
			rank.Text = tostring(num);
			level.Text = tostring(data.leadername);
			chenghao.Text = tostring(data.grade);
			name.Text = tostring(data.name);
			total.Text = tostring(data.allgm);
		elseif typenum == RankType.Popular then
			exp.Text = tostring(data.fp);
		end
		if num == 1 then
			o.ctrl.Background = Converter.String2Brush("godsSenki.rank_dibian1");
			rank1.Visibility = Visibility.Visible;
			rank2.Visibility = Visibility.Hidden;
			rank.Visibility = Visibility.Hidden;
			rank3.Visibility = Visibility.Hidden;
		elseif num == 2 then
			o.ctrl.Background = Converter.String2Brush("godsSenki.rank_dibian2");
			rank2.Visibility = Visibility.Visible;
			rank1.Visibility = Visibility.Hidden;
			rank.Visibility = Visibility.Hidden;
			rank3.Visibility = Visibility.Hidden;
		elseif num == 3 then
			o.ctrl.Background = Converter.String2Brush("godsSenki.rank_dibian3");
			rank3.Visibility = Visibility.Visible;
			rank.Visibility = Visibility.Hidden;
			rank1.Visibility = Visibility.Hidden;
			rank2.Visibility = Visibility.Hidden;
		end
	end
end

typeMethodList.flowerTemplate = function(o)
	local labelTime = o.ctrl:GetLogicChild('time');
	local labelName = o.ctrl:GetLogicChild('name');
	local btnReception = o.ctrl:GetLogicChild('reception');
	local panelHead = o.ctrl:GetLogicChild('panelHead');
	local head = customUserControl.new(panelHead, 'teamInfoTemplate');   --后添加的
	local time;
	local id;
	local name;

	o.init = function()
		time = 0;
		head.setFriendStatus();           --后添加的
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end
	o.initWithInfo = function(info)
		head.initWithFriendRole(info);     --后添加的
		head.setScale(0.7,0.7);
		head.setMargin(-3, -15);          --后添加的
		id = info.id;
		time = info.rest_time;
		o.updateTime();
		if info.online == 0 then            --后添加的
			o.setOffline();
		else
			o.setOnline();
		end
		name = info.name;
		labelName.Text = tostring(info.name)--string.format(LANG_FRIEND_FLOWER_SEND, info.name);
		btnReception:SubscribeScriptedEvent('Button::ClickEvent', 'FriendFlowerPanel:accept');
		btnReception.Tag = info.id;
	end  
	o.setOffline = function()
		head.setFriendOffline(); 	
	end
	o.setOnline = function()
		head.setFriendOnline();
	end

	o.getName = function()
		return name;
	end
	o.update = function()
		time = time - 1;
		if time <= 0 then
			return false;
		end
		o.updateTime();
		return true;
	end

	local s_Time;
	o.updateTime = function() 
		s_Time =  UnionPanel:getTime(time);
		local hour = math.floor(time/3600);
		hour = (hour < 10) and ('0' .. hour) or hour;
		local minute = math.floor((time%3600)/60);
		minute = (minute < 10) and ('0' .. minute) or minute;
		local second = math.floor(time%60);
		second = (second < 10) and ('0' .. second) or second;
		labelTime.Text = hour .. ':' .. minute .. ':' .. second;
		--labelTime.Text = s_Time;
	end

	o.getId = function()
		return id;
	end
end

typeMethodList.FriendInfoTemplate = function(o)
	local labelLevel = o.ctrl:GetLogicChild('level');
	local labelName = o.ctrl:GetLogicChild('name');
	local btnAccept = o.ctrl:GetLogicChild('accept');
	local labelFp = o.ctrl:GetLogicChild('zhandouli');
	local btnIgnore = o.ctrl:GetLogicChild('ignore');
	local panelHead = o.ctrl:GetLogicChild('panelHead');
	local head = customUserControl.new(panelHead, 'teamInfoTemplate');    --后增加
	o.init = function()
		btnAccept:SubscribeScriptedEvent('Button::ClickEvent', 'FriendApplyPanel:onAgree');
		btnIgnore:SubscribeScriptedEvent('Button::ClickEvent', 'FriendApplyPanel:onIgnore');
		head.setFriendStatus();
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(info, tag)
		head.initWithFriendRole(info);       --后增加
		head.setScale(0.7,0.7);
		head.setMargin(-15, -18);            --后添加的
		if info.online == 0 then             --后添加的
			o.setOffline();
		else
			o.setOnline();
		end
		labelLevel.Text = tostring(info.lv);
		labelName.Text = tostring(info.name);--string.format(LANG_FRIEND_FLOWER_SEND_Name, info.name);
		--tip.Text = string.format(LANG_FRIEND_FLOWER_TIP, 60);
		labelFp.Text = tostring(info.fp);
		btnAccept.Tag = tag;
		btnIgnore.Tag = tag;	
	end
	o.setOffline = function()
		head.setFriendOffline(); 	
	end
	o.setOnline = function()
		head.setFriendOnline();
	end
end

typeMethodList.NewWeekTemplate = function(o)
	local panel = o.ctrl:GetLogicChild(0);
	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithMonth = function(year, month, d)
		local mr = ChroniclePanel.story[year][month];
		for i = 1, 7 do
			local item = panel:GetLogicChild(tostring(i));
			local sign, today, day = item:GetLogicChild('icon1'), item:GetLogicChild('icon2'), item:GetLogicChild('num');
			item:GetLogicChild('icon3').Visibility = Visibility.Hidden;
			local ifinished, icycle, ifont, icolor;
			if mr[d] then
				if mr[d].week == i - 1 then
					ifont = true;
					if mr[d].id >= ChroniclePanel.today then icolor = true end;
					if mr[d].progress then
						if mr[d].progress.state == ChroniclePanel.Done then
							ifinished, icolor = true, true;
						elseif mr[d].progress.state == ChroniclePanel.CAN_READ then
							ifinished, icolor = false, true;
						end
					end
					if not ifinished and mr[d].id == ChroniclePanel.today then icycle = true end;
					if not ifinished and ChroniclePanel:isFinished(year, month, d) then
						ifinished, icycle, ifont, icolor = true, false, true, true;
					end
				end
			end
			sign.Visibility = ifinished and Visibility.Visible or Visibility.Hidden;
			today.Visibility = icycle and Visibility.Visible or Visibility.Hidden;
			day.Visibility = ifont and Visibility.Visible or Visibility.Hidden;
			day.TextColor = icolor and Configuration.BlackColor or Configuration.DarkSalmon;
			day.Text = tostring(d);
			local isToday = mr[d] and mr[d].id == ChroniclePanel.today
			local isRead = mr[d] and mr[d].progress and mr[d].progress.state == ChroniclePanel.CAN_READ
			if ifinished or isToday or isRead then
				item.Tag = mr[d].id;
				item:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChroniclePanel:onShowStory');
			end
			if ifont then d = d + 1 end;
		end
		return d;
	end

	o.initHead = function()
		for i = 1, 7 do
			local it = panel:GetLogicChild(tostring(i));
			it:GetLogicChild('icon1').Visibility = Visibility.Hidden;
			it:GetLogicChild('icon2').Visibility = Visibility.Hidden;
			it:GetLogicChild('icon3').Visibility = Visibility.Visible;
			it:GetLogicChild('num').Visibility = Visibility.Hidden;
		end
	end
end


typeMethodList.rightChatTemplate = function(o)
	local iconPanel = o.ctrl:GetLogicChild('icon');
	local labelText = o.ctrl:GetLogicChild('richText');
	local bgLable	= o.ctrl:GetLogicChild('richText1');
	local nameLable = o.ctrl:GetLogicChild('stackPanel'):GetLogicChild('name');
	local vipPanel	= o.ctrl:GetLogicChild('stackPanel'):GetLogicChild('vip');
	o.child.Horizontal = ControlLayout.H_RIGHT;
	vipPanel:GetLogicChild('bg').Visibility = Visibility.Hidden
	vipPanel.Visibility = Visibility.Hidden;
	local titleLText = o.ctrl:GetLogicChild('stackPanel'):GetLogicChild('panel'):GetLogicChild('title');

	o.ctrl:GetLogicChild('stackPanel'):GetLogicChild('panel').Visibility = Visibility.Hidden;

	labelText.Margin = Rect(25,37,0,0)

	o.init = function()
	end
	o.initInfo = function(rtb, msg, title, color, font, isMainUI)
		local img = iconPanel:GetLogicChild('image');
		img.Image = GetPicture('navi/' .. ActorManager.user_data.role.headImage .. '.ccz');
		local imgbg = iconPanel:GetLogicChild('1');
		imgbg.Image 	= GetPicture('personInfo/' .. 'personInfo_' .. (ActorManager.user_data.role.quality - 1) .. '.ccz');
		titleLText.Text = title;
		nameLable.Text = msg.name;
		if msg.vipLevel >= 1 then
			local vipLabel = vipToImage(msg.vipLevel)
			vipPanel.Size = vipLabel.Size
			vipLabel.Margin = Rect(2,5,0,0)
			vipPanel:AddChild(vipLabel)
			vipPanel.Visibility = Visibility.Visible;
		end

		if isMainUI then
			o.analyseAndShowMessage(labelText, msg.msg, color, font, false);
		else
			o.analyseAndShowMessage(labelText, msg.msg, color, font, true);
		end	
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	--解析并显示表情和文字
	o.analyseAndShowMessage = function(rtb, message, color, font, isAppend)
		local mes = message
		rtb.LogicMaxLine = 20
		rtb.VisualMaxLine = 20
		local preStr;
		local expressionID = 0;
		local expressionIDStr;
		local startIndex, endIndex = string.find(message, '\\c');
		local index = 0
		while nil ~= startIndex do
			--寻找表情的转义字符位置
			preStr = string.sub(message, 1, startIndex - 1);
			if isAppend then
				rtb:AppendText(preStr, color, font);
			else
				rtb:AddText(preStr, color, font);
			end

			expressionIDStr = string.sub(message, endIndex + 1, endIndex + 2);           --表情id
			expressionID = tonumber(expressionIDStr);                                    --转化成数字
			if (nil ~= expressionID) and (expressionID > 10) and (expressionID <= Configuration.MaxExpressionCount + 10) then --存在表情转义字符
				local armatureUI = uiSystem:CreateControl('ArmatureUI');
				if expressionID <= 20 then
					armatureUI:LoadArmature('biaoqing_' .. (expressionID - 10));
				else
					armatureUI:LoadArmature('liaotian_' .. (expressionID - 10));
				end
				armatureUI:SetAnimation('play');
				armatureUI.Size = Size(50, 50);
				if (isAppend) then
					rtb:AppendUIControl(armatureUI);
					armatureUI.Translate = Vector2(25, 35);
				else
					rtb:AddUIControl(armatureUI);
					armatureUI.Translate = Vector2(25, 35);
				end
			else    --不存在表情的转义字符
				if (isAppend) then
					rtb:AppendText('\\c' .. expressionIDStr, color, font);
				else
					rtb:AddText('\\c' .. expressionIDStr, color, font);
				end
			end
			--截断message
			message = string.sub(message, endIndex + 3, -1);
			startIndex, endIndex = string.find(message, '\\c');
			index = index + 1
		end

		if isAppend then
			rtb:AppendText(message, color, font);
		else
			rtb:AddText(message, color, font);
		end
		rtb:ForceLayout()

		local length = utf8.getCharSize(mes) + index
		if length < 15 then
			bgLable.Size = Size(257, 25);
			o.child.Size = Size(340, 55)--25+30);
			if index ~= 0 then 
				bgLable.Size = Size(257, 60)--25+35);
				o.child.Size = Size(340, 90)--25+35+30);
			end
		elseif length < 29 then
			bgLable.Size = Size(257, 50);
			o.child.Size = Size(340, 80);
			if index ~= 0 then 
				bgLable.Size = Size(257, 85)--50+35);
				o.child.Size = Size(340, 115)--50+35+30);
				if index > 1 then
					bgLable.Size = Size(257, 120)--50+35*2);
					o.child.Size = Size(340, 150)--50+35*2+30);
				end
			end
		else
			if ChatPanel.feedbackSize then
				local feedHeight = 0
				for i = 0 , rtb:GetLogicChildrenCount()-1 do
					feedHeight = feedHeight+rtb:GetLogicChild(i).Height+rtb.LineSpace
				end
				bgLable.Size = Size(257, 32+feedHeight);
				o.child.Size = Size(340, 66+feedHeight);
				rtb.Size = Size(223,feedHeight);
			else
				bgLable.Size = Size(257, 73);
				o.child.Size = Size(340, 105);
				if index ~= 0 then 
					bgLable.Size = Size(257, 110)--75+35);
					o.child.Size = Size(340, 140)--75+35+30);
					if index > 2 then
						bgLable.Size = Size(257, 150)--75*2);
						o.child.Size = Size(340, 180)--75*2+30);
					end
				end
			end
		end
	end
end


typeMethodList.leftChatTemplate = function(o)
	local iconPanel = o.ctrl:GetLogicChild('icon');
	local labelText = o.ctrl:GetLogicChild('richText');
	local bgLable	= o.ctrl:GetLogicChild('richText1');
	local nameLable = o.ctrl:GetLogicChild('stackPanel'):GetLogicChild('name');
	local vipPanel	= o.ctrl:GetLogicChild('stackPanel'):GetLogicChild('vip');
	o.child.Horizontal = ControlLayout.H_LEFT;
	vipPanel:GetLogicChild('bg').Visibility = Visibility.Hidden
	vipPanel.Visibility = Visibility.Hidden;
	local titleLText = o.ctrl:GetLogicChild('stackPanel'):GetLogicChild('panel'):GetLogicChild('title');
	o.ctrl:GetLogicChild('stackPanel'):GetLogicChild('panel').Visibility = Visibility.Hidden;
	o.init = function()
	end
	o.initInfo = function(rtb, msg, title, color, font, isMainUI)
		iconPanel.Tag = msg.uid
		local roleid = msg.resid;
		if msg.lovelevel and msg.lovelevel == 4 then
			roleid = roleid + 10000;
		end
		local imageName = resTableManager:GetValue(ResTable.navi_main, tostring(roleid), 'role_path_icon');
		local img = iconPanel:GetLogicChild('image');
		img.Image = GetPicture('navi/' .. imageName .. '.ccz');
		local imgbg = iconPanel:GetLogicChild('1');
		imgbg.Image 	= GetPicture('personInfo/' .. 'personInfo_' .. (msg.quality - 1) .. '.ccz');
		titleLText.Text = title;
		nameLable.Text = msg.name;
		if msg.vipLevel >= 1 then
			local vipLabel = vipToImage(msg.vipLevel)
			vipPanel.Size = vipLabel.Size
			vipLabel.Margin = Rect(-4,-5,0,0)
			vipPanel:AddChild(vipLabel)
			vipPanel.Visibility = Visibility.Visible;
		end

		if isMainUI then
			o.analyseAndShowMessage(labelText, msg.msg, color, font, false);
		else
			o.analyseAndShowMessage(labelText, msg.msg, color, font, true);
		end	
	end

	o.setIconClickEvent = function(callback)
		iconPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent',callback)
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end
	--解析并显示表情和文字
	o.analyseAndShowMessage = function(rtb, message, color, font, isAppend)
		local preStr;
		local expressionID = 0;
		local expressionIDStr;
		local startIndex, endIndex = string.find(message, '\\c');
		local index = 0
		while nil ~= startIndex do
			--寻找表情的转义字符位置
			preStr = string.sub(message, 1, startIndex - 1);
			if isAppend then
				rtb:AppendText(preStr, color, font);
			else
				rtb:AddText(preStr, color, font);
			end

			expressionIDStr = string.sub(message, endIndex + 1, endIndex + 2);           --表情id
			expressionID = tonumber(expressionIDStr);                                    --转化成数字
			if (nil ~= expressionID) and (expressionID > 10) and (expressionID <= Configuration.MaxExpressionCount + 10) then --存在表情转义字符
				local armatureUI = uiSystem:CreateControl('ArmatureUI');
				if expressionID <= 20 then
					armatureUI:LoadArmature('biaoqing_' .. (expressionID - 10));
				else
					armatureUI:LoadArmature('liaotian_' .. (expressionID - 10));
				end
				armatureUI:SetAnimation('play');
				armatureUI.Size = Size(50, 50);
				if (isAppend) then
					rtb:AppendUIControl(armatureUI);
					armatureUI.Translate = Vector2(25, 35);
				else
					rtb:AddUIControl(armatureUI);
					armatureUI.Translate = Vector2(25, 35);
				end
			else    --不存在表情的转义字符
				if (isAppend) then
					rtb:AppendText('\\c' .. expressionIDStr, color, font);
				else
					rtb:AddText('\\c' .. expressionIDStr, color, font);
				end
			end
			--截断message
			message = string.sub(message, endIndex + 3, -1);
			startIndex, endIndex = string.find(message, '\\c');
			index = index + 1
		end
		if isAppend then
			rtb:AppendText(message, color, font);
		else
			rtb:AddText(message, color, font);
		end

		local length = utf8.getCharSize(message) + index
		if length < 15 then
			bgLable.Size = Size(257, 25);
			o.child.Size = Size(340, 55);
			if index ~= 0 then 
				bgLable.Size = Size(257, 60);
				o.child.Size = Size(340, 90);
			end
		elseif length < 29 then
			bgLable.Size = Size(257, 50);
			o.child.Size = Size(340, 80);
			if index ~= 0 then 
				bgLable.Size = Size(257, 85);
				o.child.Size = Size(340, 115);
				if index > 1 then 
					bgLable.Size = Size(257, 120);
					o.child.Size = Size(340, 150);
				end
			end
		else
			bgLable.Size = Size(257, 75);
			o.child.Size = Size(340, 105);
			if index ~= 0 then 
				bgLable.Size = Size(257, 110);
				o.child.Size = Size(340, 140);
				if index > 2 then 
					bgLable.Size = Size(257, 150);
					o.child.Size = Size(340, 180);
				end
			end
		end
	end
end

typeMethodList.SysChatTemplate = function(o)
	local labelText = o.ctrl:GetLogicChild('richText');

	o.init = function()
	end
	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end
end

typeMethodList.TeamSelectTemplate = function(o)
	local teamList = {};
	local name;
	local tid;
	local totalFp = 0;
	local roleNum = 0

	for i=1, 5 do
		teamList[i] = {};
		teamList[i].armature = o.ctrl:GetLogicChild(tostring(i)):GetLogicChild('armature');
	end

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithTeam = function(teamId)
		local team = MutipleTeam:getTeam(teamId);
		totalFp = 0;
		roleNum = 0;
		name = team.name;
		tid = teamId;
		for i=1, 5 do			
			teamList[i].role = team[i] or -1;
			if team[i] > -1 then
				local role = ActorManager:GetRole(team[i]);
				totalFp = totalFp + role.pro.fp;
				roleNum = roleNum + 1;
				local data = resTableManager:GetValue(ResTable.actor, tostring(role.resid), {'path', 'img'});

				teamList[i].armature:Destroy();
				AvatarManager:LoadFile(GlobalData.AnimationPath .. data['path'] .. '/');
				teamList[i].armature:LoadArmature(data['img']);
				teamList[i].armature:SetAnimation(AnimationType.f_idle);
				teamList[i].armature:SetScale(1.35, 1.35);
			end
			local heroClickBtn = o.ctrl:GetLogicChild(tostring(i)):GetLogicChild('button')     --  点击英雄头像，响应对应事件，即将英雄撤离队伍
			heroClickBtn.Tag = i
			heroClickBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TeamPanel:withdrawHero')
		end

	end

	o.getTeamName = function()
		return name;
	end

	o.getFp = function()
		local curFp=0;
		for i=1, 5 do
			if teamList[i].role ~= -1 then
				local role = ActorManager:GetRole(teamList[i].role);
				if role then
					local add_fp = GemPanel:reCalculateFp(role, i);
					curFp = curFp + add_fp;
				end
			end
		end
		return math.floor(curFp);
	end
	o.getRoleNum = function()
		return roleNum;
	end
	o.hasMember = function(pid)
		local has = false;
		for i=1, 5 do
			if teamList[i] and teamList[i].role and (tonumber(teamList[i].role) == pid) then
				has = true;
				break;
			end
		end
		return has;
	end

	o.getTeamMember = function()
		local team = {};
		for i=1, 5 do
			if teamList[i] and teamList[i].role and (tonumber(teamList[i].role) > -1) then
				table.insert(team, teamList[i].role);
			end
		end
		return team;
	end

	o.getWholeTeam = function()
		local team = {};
		for i=1, 5 do
			team[i] = teamList[i].role;
		end
		return team;
	end

	o.isFull = function()
		local num = 0;
		for i=1, 5 do
			if teamList[i] and teamList[i].role and (tonumber(teamList[i].role) > -1) then
				num = num + 1;
			end
		end
		return num == 5;
	end

	o.leave = function(pid)
		--如果没找到，直接退出
		local find = false;
		local pos;
		for i=1, 5 do
			if teamList[i] and teamList[i].role and (tonumber(teamList[i].role) == pid) then
				find = true;
				pos = i;
				break;
			end
		end
		if not find then
			return;
		end

		--更新战斗力
		local role = ActorManager:GetRole(pid);
		totalFp = totalFp - role.pro.fp;
		roleNum = roleNum - 1;
		--找到以后 下去的那个人之后所有人往前挪一格
		-- teamList[pos].role = -1;
		-- teamList[pos].armature:Destroy();

		for i=pos, 2, -1 do

			if teamList[i-1].role ~= -1 then
				teamList[i].role = teamList[i-1].role;
				local role = ActorManager:GetRole(teamList[i].role);
				local data = resTableManager:GetValue(ResTable.actor, tostring(role.resid), {'path', 'img'});

				teamList[i].armature:Destroy();
				AvatarManager:LoadFile(GlobalData.AnimationPath .. data['path'] .. '/');
				teamList[i].armature:LoadArmature(data['img']);
				teamList[i].armature:SetAnimation(AnimationType.f_idle);
				teamList[i].armature:SetScale(1.35, 1.35);
			else
				teamList[i].role = -1;
				teamList[i].armature:Destroy();
			end
		end
		teamList[1].role = -1;
		teamList[1].armature:Destroy();
	end

	o.join = function(pid)
		--先找出要放的位置
		local pos = 1;
		for i=5, 2, -1 do
			if teamList[i].role == -1 then
				pos = i;
				break;
			end
			local role_t = ActorManager:GetRole(teamList[i].role);
			local role = ActorManager:GetRole(pid);
			local hit_range_t = resTableManager:GetValue(ResTable.actor, tostring(role_t.resid), 'hit_area');
			local hit_range = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'hit_area');
			if hit_range < hit_range_t then
				pos = i;
				break;
			end
		end

		--更新战斗力
		local role = ActorManager:GetRole(pid);
		totalFp = totalFp + role.pro.fp;
		roleNum = roleNum + 1;
		if pos ~= 1 then
			for i=1, pos-1 do
				if teamList[i+1].role ~= -1 then
					teamList[i].role = teamList[i+1].role;
					local role = ActorManager:GetRole(teamList[i].role);
					local data = resTableManager:GetValue(ResTable.actor, tostring(role.resid), {'path', 'img'});

					teamList[i].armature:Destroy();
					AvatarManager:LoadFile(GlobalData.AnimationPath .. data['path'] .. '/');
					teamList[i].armature:LoadArmature(data['img']);
					teamList[i].armature:SetAnimation(AnimationType.f_idle);
					teamList[i].armature:SetScale(1.35, 1.35);
				end
			end
		end

		teamList[pos].role = pid;
		local role = ActorManager:GetRole(teamList[pos].role);
		local data = resTableManager:GetValue(ResTable.actor, tostring(role.resid), {'path', 'img'});

		teamList[pos].armature:Destroy();
		AvatarManager:LoadFile(GlobalData.AnimationPath .. data['path'] .. '/');
		teamList[pos].armature:LoadArmature(data['img']);
		teamList[pos].armature:SetAnimation(AnimationType.f_idle);
		teamList[pos].armature:SetScale(1.35, 1.35);
	end
end

typeMethodList.propertyRoundTemplate = function(o)
	local img = o.ctrl:GetLogicChild('img');
	local openLevel = o.ctrl:GetLogicChild('openLabel');
	local diff = o.ctrl:GetLogicChild("diff");
	local btn = o.ctrl:GetLogicChild('btn');
	local icon1 = o.ctrl:GetLogicChild('p1'):GetLogicChild('sp'):GetLogicChild('p1'):GetLogicChild('icon');
	local count1 = o.ctrl:GetLogicChild('p1'):GetLogicChild('sp'):GetLogicChild('p1'):GetLogicChild('count');
	local icon2 = o.ctrl:GetLogicChild('p1'):GetLogicChild('sp'):GetLogicChild('p2'):GetLogicChild('icon');
	local count2 = o.ctrl:GetLogicChild('p1'):GetLogicChild('sp'):GetLogicChild('p2'):GetLogicChild('count');
	local Roman = {[1] = 'I', [2] = 'II', [3] = 'III', [4] = 'IV', [5] = 'V', [6] = 'VI'};

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.getButton = function()
		return btn
	end

	o.initWithId = function(id)
		local data = resTableManager:GetValue(ResTable.limit_round, tostring(id), {'difficult', 'description', 'fp', 'lv', 'lmt_battle_drop'});
		local imgPre = "ShuXingShiLian_diff" .. id % 10;
		img.Image = GetPicture('xianshifuben/' .. imgPre .. '.ccz');
		icon1.Image = GetIcon(resTableManager:GetValue(ResTable.item, tostring(data['lmt_battle_drop'][1][1]), 'icon'));
		count1.Text = 'x' .. data['lmt_battle_drop'][1][3];
		icon2.Image = GetIcon(resTableManager:GetValue(ResTable.item, tostring(data['lmt_battle_drop'][2][1]), 'icon'));
		count2.Text = 'x' .. data['lmt_battle_drop'][2][3];
		btn.Tag = id;
		if ActorManager.user_data.role.lvl.level >= data['lv'] then
			btn:SubscribeScriptedEvent('Button::ClickEvent', 'PropertyRoundPanel:onReqFight');
			img.Enable = true;
			openLevel.Text = "";
		else
			img.Enable = false;
			openLevel.Text = LANG_propertyRoundPanel_13..data['lv'] .. LANG_propertyRoundPanel_7;
		end
		diff.Text = LANG_propertyRoundPanel_9 .. Roman[id % 10];
	end
end

typeMethodList.treasureItemTemplate = function(o)
	local open = o.ctrl:GetLogicChild('open');
	local close = o.ctrl:GetLogicChild('close');
	local round = o.ctrl:GetLogicChild('round');
	local mask = o.ctrl:GetLogicChild('mask')
	local feet = o.ctrl:GetLogicChild('feet')

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.ctrlGetfeet = function()
		return feet
	end

	o.initWithId = function(id)
		close:GetLogicChild('close_bg').Image = GetPicture('julong/julong_socket.ccz');
		open:GetLogicChild('open_bg').Image = GetPicture('julong/julong_unselect.ccz');
		close.SelectedBrush = CreateTextureBrush('julong/julong_select.ccz', 'julong');
		open.SelectedBrush = CreateTextureBrush('julong/julong_normal1.ccz', 'julong');
		close.Visibility = Visibility.Visible;
		open.Visibility = Visibility.Hidden;
		mask.Visibility = Visibility.Hidden
		feet.Visibility = Visibility.Hidden
		if id > ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin + 1 then
			close:GetLogicChild('close_bg').ShaderType = IRenderer.UI_GrayShader;
			round.ShaderType = IRenderer.UI_GrayShader;
		elseif id == ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin + 1 then

		else
			close.Visibility = Visibility.Hidden;
			open.Visibility = Visibility.Visible;
		end
		--  开启的最大关卡显示图标
		-- if id == ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin then
		-- 	feet.Visibility = Visibility.Visible
		-- end

		local roundID = id + RoundIDSection.TreasureBegin
		local data = resTableManager:GetRowValue(ResTable.treasure, tostring(roundID))
		local drop = data['treasure_drop']
		if drop and #drop > 0 then
			round.Background = Converter.String2Brush('godsSenki.julong_daofeng')
			mask.Visibility = Visibility.Visible
		end
		round.Text = string.format(LANG_dragonTreasurePanel_5, id);
		open.Tag, close.Tag = id, id;
		open.GroupID = RadionButtonGroup.selectDragonFloor;
		close.GroupID = RadionButtonGroup.selectDragonFloor;
		open:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TreasurePanel:onRadioButton');
		close:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TreasurePanel:onRadioButton');
	end

	o.getTag = function()
		return open.Tag;
	end

	o.selected = function()
		if open.Visibility == Visibility.Visible then
			open.Selected = true;
		else
			close.Selected = true
		end
	end

	o.LayoutPoint = function()
		return o.ctrl:GetVisualParent().LayoutPoint;
	end

	o.finished = function()
		open.Visibility = Visibility.Visible;
		close.Visibility = Visibility.Hidden;
	end

	o.open = function()
		close:GetLogicChild('close_bg').ShaderType = IRenderer.UI_NormalShader;
		round.ShaderType = IRenderer.UI_NormalShader;
	end
end

typeMethodList.treasureRevengeTemplate = function(o)
	local name = o.ctrl:GetLogicChild('name');
	local state = o.ctrl:GetLogicChild('floor');
	local time = o.ctrl:GetLogicChild('time');
	local income = o.ctrl:GetLogicChild('income');
	local rob = o.ctrl:GetLogicChild('rob');
	local capture = o.ctrl:GetLogicChild('capture');
	local head = o.ctrl:GetLogicChild('head');

	local t = {};

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithRecord = function(record)
		local r = TreasurePanel:getRoundIndex(record.pos);
		name.Text 	= tostring(record.nickname);
		local uc = customUserControl.new(head, 'teamInfoTemplate');
		uc.initWithRecord(record);
		t.secs = record.secs;
		t.pos = record.pos;
		t.gold = record.gold;
		t.uid = record.uid;
		if record.pos == -1 then
			state.Text = LANG_dragonTreasurePanel_49;
			time.Text = '--';
			income.Text = '--';
			rob.Enable = false;
			capture.Enable = false;
		else
			local data = resTableManager:GetValue(ResTable.treasure, tostring(r + RoundIDSection.TreasureBegin), 
			{'gold_minute', 'gold_1hour', 'gold_2hour', 'gold_3hour', 'gold_4hour'});
			t.minute = data['gold_minute'];
			t.g1hour = data['gold_1hour'];
			t.g2hour = data['gold_2hour'];
			t.g3hour = data['gold_3hour'];
			t.g4hour = data['gold_4hour'];
			income.Text = tostring(TreasurePanel:getIncome(record.secs, t.minute, t.g1hour, t.g2hour, t.g3hour, t.g4hour, record.gold));
			capture.Tag, rob.Tag = record.uid, record.uid;
			capture:SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onRevengeOccupy');
			rob:SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onRevengeRob');
			time.Text = Time2HMSStr(record.secs);
			state.Text 	= string.format(LANG_dragonTreasurePanel_51, r);
			local r = math.floor(t.pos / 4) + 1
			if r > ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin then
				rob.Enable = false;
				capture.Enable = false;
			end
		end
	end

	o.onRevengeOccupy = function()
		local mineNum = math.mod(t.pos, 4);
		mineNum = mineNum == 0 and 4 or mineNum;
		if ActorManager.user_data.round.cur_slot ~= -1 then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_dragonTreasurePanel_33);
		elseif ActorManager.user_data.round.debian_secs <= 0 then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_dragonTreasurePanel_34);
		elseif ActorManager.user_data.round.cur_help_slot ~= -1 then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_TreasurePanel_80); 
		else
			local msg = {};
			msg.pos = t.pos;
			msg.uid = t.uid;
			Network:Send(NetworkCmdType.req_treasure_fight, msg);
		end
	end

	o.onRevengeRob = function()
		local msg = {};
		msg.pos = t.pos;
		msg.uid = t.uid;
		Network:Send(NetworkCmdType.req_treasure_rob, msg);
	end

	o.updateTime = function()
		if t.pos ~= -1 then
			t.secs = t.secs + 1;
			if t.secs < 14400 then
				time.Text = Time2HMSStr(t.secs);
				income.Text = tostring(TreasurePanel:getIncome(t.secs, t.minute, t.g1hour, t.g2hour, t.g3hour, t.g4hour, t.gold));
			else
				state.Text = LANG_dragonTreasurePanel_49;
				time.Text = '--';
				income.Text = '--';
				rob.Enable = false;
				capture.Enable = false;
			end
		end
	end
end

typeMethodList.FBCommonTemplate = function(o)
	local commonPanel = o.ctrl:GetLogicChild('CommonPanel');               --普通关卡panel
	local JYPanel = o.ctrl:GetLogicChild('JYPanel');               --普通关卡panel
	local bossPanel = o.ctrl:GetLogicChild('BossPanel');               --普通关卡panel
	local imgCommon = commonPanel:GetLogicChild('icon');
	local imgJY = JYPanel:GetLogicChild('icon');
	local num_jy = JYPanel:GetLogicChild('panel_num'):GetLogicChild('cur_num');
	local imgBoss = bossPanel:GetLogicChild('iconPanel'):GetLogicChild('icon');
	local starList={};
	local isVisible;
	local bid_;
	local is_select = o.ctrl:GetLogicChild('select');
	is_select.ZOrder = 50;

	for i=1, 4 do
		starList[i] = o.ctrl:GetLogicChild('starPanel'):GetLogicChild(tostring(i));
	end

	o.init = function()
		commonPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PveBarrierPanel:onEnterPveBattle');
		JYPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PveBarrierPanel:onEnterPveBattle');
		bossPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PveBarrierPanel:onEnterPveBattle');
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.setStar = function(num)
		for i=1, 4 do
			starList[i].Visibility = (num >= i) and Visibility.Visible or Visibility.Hidden;
		end
	end

	o.initWithBarrier = function(barrierID)
		--隐去动画
		is_select.Visibility = Visibility.Hidden;
		--获取关卡
		local data = resTableManager:GetRowValue(ResTable.barriers, tostring(barrierID));

		--首先根据关卡ID去监测是普通，精英还是boss关卡
		local curPanel;
		local curImg;

		if data['type'] == 0 then
			curPanel = commonPanel;
			curImg = imgCommon;
		elseif data['type'] == 1 then
			curPanel = bossPanel;
			curImg = imgBoss;
		else
			curPanel = JYPanel;
			curImg = imgJY;
			local bid = barrierID - 5000;
			local str;
			local tmp = ActorManager.user_data.round.elite_round_times and ActorManager.user_data.round.elite_round_times or '';
			if string.len(tmp) < bid then
				str = 0;
			else
				str = string.sub(tmp, bid, bid);
			end
			num_jy.Text = tostring(3-tonumber(str));
		end
		--把除了当前panel以外的所有panel隐藏
		commonPanel.Visibility = Visibility.Hidden;
		bossPanel.Visibility = Visibility.Hidden;
		JYPanel.Visibility = Visibility.Hidden;
		curPanel.Visibility = Visibility.Visible;

		--增加TAG
		curPanel.Tag = barrierID;
		bid_ = barrierID;
		--让成就星级都不显示
		o.setStar(0);

		--设置关卡图像
		curImg.AutoSize = false;
		curImg.Image = GetPicture('navi/' .. data['icon'] .. '.ccz');

		--设置关卡图标位置
		o.ctrl.Translate = Vector2(data['coordinate'][1], data['coordinate'][2]);
	end

	o.setVisibility = function(flag)
		isVisible = flag;
	end

	o.getVisibility = function()
		return isVisible;
	end

	o.destroy = function()
		commonPanel:RemoveAllPropertyHandlers();
		JYPanel:RemoveAllPropertyHandlers();
		bossPanel:RemoveAllPropertyHandlers();
	end

	o.selected = function(flag)
		is_select.Visibility = flag and Visibility.Visible or Visibility.Hidden;
		if flag then
			is_select:Destroy();
			AvatarManager:LoadFile(GlobalData.EffectPath .. 'guanqia_output/');
			is_select:LoadArmature('guanqia');
			is_select.Horizontal = ControlLayout.H_CENTER;
			is_select.Vertical = ControlLayout.V_CENTER;
			is_select:SetScale(0.8, 0.8);
			is_select:SetAnimation('play');
			is_select.Pick = false;
		else
			is_select:Destroy();
		end
	end

	o.updateSelect = function(bid)
		o.selected(bid_ == bid);
	end
end


typeMethodList.treasureReportTemplate = function(o)
	local time = o.ctrl:GetLogicChild('time');
	local desc = o.ctrl:GetLogicChild('desc');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithRecord = function(record, font1, font2)
		time.Text = ArenaPanel:GetTime(record.elapsed);

		local element = TextElement(uiSystem:CreateControl('TextElement'));
		element.Font = font1;
		if record.uid == ActorManager.user_data.uid then
			element.Text = record.name2;
			element.TextColor = Configuration.WhiteColor;
			element.Tag = record.uid2;
			if record.flag == 1 then
				if record.is_win == 1 then
					desc:AppendUIControl(element);
					desc:AppendText(LANG_TreasurePanel_58, Configuration.BlackColor, font2);
					desc:AppendText(tostring(record.money), Configuration.YellowColor, font1);
					desc:AppendText(LANG_TreasurePanel_59, Configuration.BlackColor, font2);
				else
					desc:AppendText(LANG_TreasurePanel_60, Configuration.BlackColor, font2);
					desc:AppendUIControl(element);
					desc:AppendText(LANG_TreasurePanel_61, Configuration.BlackColor, font2);
				end
			else
				if record.is_win == 1 then
					--desc:AppendText(LANG_TreasurePanel_62, Configuration.BlackColor, font2);
					desc:AppendUIControl(element);
					desc:AppendText(LANG_TreasurePanel_63, Configuration.BlackColor, font2);
				else
					--desc:AppendText(LANG_TreasurePanel_64, Configuration.BlackColor, font2);
					desc:AppendUIControl(element);
					desc:AppendText(LANG_TreasurePanel_65, Configuration.BlackColor, font2);
				end
			end
		else
			element.Text = record.name;
			element.TextColor = Configuration.WhiteColor;
			element.Tag = record.uid;
			if record.flag == 1 then
				if record.is_win == 0 then
					desc:AppendUIControl(element);
					desc:AppendText(LANG_TreasurePanel_66, Configuration.BlackColor, font2);
				else
					desc:AppendUIControl(element);
					desc:AppendText(LANG_TreasurePanel_67, Configuration.BlackColor, font2);
					desc:AppendText(tostring(record.money), Configuration.YellowColor, font1);
					desc:AppendText(LANG_TreasurePanel_68, Configuration.BlackColor, font2);
				end
			else
				if record.is_win == 0 then
					desc:AppendUIControl(element);
					desc:AppendText(LANG_TreasurePanel_69, Configuration.BlackColor, font2);
				else
					desc:AppendUIControl(element);
					desc:AppendText(LANG_TreasurePanel_70, Configuration.BlackColor, font2);
					desc:AppendText(tostring(record.money), Configuration.YellowColor, font1);
					desc:AppendText(LANG_TreasurePanel_71, Configuration.BlackColor, font2);
				end
			end
		end
	end
end

typeMethodList.homeInfoTemplate = function(o)
	local imageHead = o.ctrl:GetLogicChild('image');
	local imgQuality = o.ctrl:GetLogicChild('nature');
	-- local imgSelect = o.ctrl:GetLogicChild('select');
	local lvpanel = o.ctrl:GetLogicChild('lvPanel');
	local labelLv = lvpanel:GetLogicChild('lv');
	local button = o.ctrl:GetLogicChild('button');
	local bg = o.ctrl:GetLogicChild('bg');
	local frame = o.ctrl:GetLogicChild('1');
	local callable = o.ctrl:GetLogicChild('callable');
	local tip = o.ctrl:GetLogicChild('tip');

	o.init = function()
	end

	o.ctrlShow = function()
		o.ctrl:GetVisualParent().Visibility = Visibility.Visible;
	end

	o.ctrlHide = function()
		o.ctrl:GetVisualParent().Visibility = Visibility.Hidden;
	end

	o.initWithActorRole = function(role)
		local isShow = true;
		callable.Visibility = Visibility.Hidden;
		local chipId = 30000 + role.pid;
		local chipItem = Package:GetChip(tonumber(chipId));
		local dataInfo = resTableManager:GetRowValue(ResTable.actor, tostring(role.pid));
		local curChipNum = 0;
		local allChipNum = 1;
		if not ActorManager:IsHavePartner(role.resid) then
			bg.Visibility = Visibility.Visible; 
			isShow = false;
			tip.Visibility = Visibility.Hidden;
			if chipItem then
				curChipNum = chipItem.count;
			end
			if dataInfo then
				allChipNum = dataInfo['hero_piece'];
			end
			if curChipNum >= allChipNum then
				callable.Visibility = Visibility.Visible;
			end

		elseif CardRankupPanel:isRoleCanAdvance( role ) or EquipStrengthPanel:IsEquipCanAdv(role) then
			tip.Visibility = Visibility.Visible;
		end
		imageHead.Image = GetPicture('navi/' .. role.headImage .. '.ccz');
		labelLv.Text = tostring(role.lvl.level);
		imgQuality.Image = GetPicture('personInfo/nature_' .. role.rank - 1 .. '.ccz');
		--		imgSelect.Visibility = Visibility.Hidden; 
		o.pid = role.pid;
		button.Tag = role.pid;
		button.TagExt = role.resid;
		button:SubscribeScriptedEvent('Button::ClickEvent', 'HomePanel:ShowRoleInfo');
		if not isShow then
			frame.Image = GetPicture('home/head_frame_1.ccz');
			lvpanel.Visibility = Visibility.Hidden;
		else
			--找到等级最低的装备
			local equip_lvl = 100;
			for i=1, 5 do
				local equip_resid = role.equips[tostring(i)].resid;
				local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank');
				if equip_rank < equip_lvl then
					equip_lvl = equip_rank;
				end
			end
			--根据装备等级来决定边框颜色
			frame.Image = GetPicture('home/head_frame_' .. tostring(equip_lvl) .. '.ccz');
		end
	end
end

typeMethodList.expeditionRoundTemplate = function(o)
	local round = o.ctrl:GetLogicChild('round');
	local pass = o.ctrl:GetLogicChild('pass');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end
	o.getRoundBtn = function (  )
		return round
	end

	o.initWithRound = function(r_id)
		local data = resTableManager:GetValue(ResTable.expedition, tostring(r_id), 'coordinate');
		o.ctrl:GetVisualParent().Translate = Vector2(data[1], data[2]);
		round.Tag = r_id;
		round:SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:onFight');
		pass.Tag = r_id
		pass:SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:notOpenOrPassed')

		local img_type = resTableManager:GetValue(ResTable.expedition, tostring(r_id), 'drop');

		round.CoverBrush = TextureBrush(uiSystem:FindResource('expedition_roundicon'..img_type[1], 'godsSenki'));
		round.NormalBrush = TextureBrush(uiSystem:FindResource('expedition_roundicon'..img_type[1], 'godsSenki'));
		round.PressBrush = TextureBrush(uiSystem:FindResource('expedition_roundicon'..img_type[1], 'godsSenki'));
		pass.CoverBrush = TextureBrush(uiSystem:FindResource('expedition_passicon'..img_type[1], 'godsSenki'));
		pass.NormalBrush = TextureBrush(uiSystem:FindResource('expedition_passicon'..img_type[1], 'godsSenki'));
		pass.PressBrush = TextureBrush(uiSystem:FindResource('expedition_passicon'..img_type[1], 'godsSenki'));
	end

	o.canfight = function(flag)
		if flag then
			round.Visibility = Visibility.Visible;
			pass.Visibility = Visibility.Hidden;
		else
			round.Visibility = Visibility.Hidden;
			pass.Visibility = Visibility.Visible;
		end
	end
end

typeMethodList.expeditionRewardTemplate = function(o)
	local box = o.ctrl:GetLogicChild('box');
	local img = o.ctrl:GetLogicChild('img');
	local arm = o.ctrl:GetLogicChild('arm');
	local resid;

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithReward = function(r_id)
		resid = r_id;
		local data = resTableManager:GetValue(ResTable.expedition, tostring(r_id), 'reward_coordinate');
		o.ctrl.Translate = Vector2(data[1], data[2]);
		box.Tag = r_id;
		box:SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:onOpen');
	end

	o.getResid = function()
		return resid;
	end

	o.play = function(name)
		arm:SetAnimation(name);
	end

	o.setStatus = function(flag)
		local img_type = resTableManager:GetValue(ResTable.expedition, tostring(resid), 'drop');
		-- box.Visibility = Visibility.Visible
		arm.Visibility = Visibility.Visible
		arm:LoadArmature('YZ_baoxiang_' .. img_type[1]);
		if flag == -1  then
			-- box.Visibility = Visibility.Hidden;
			arm:SetAnimation('keep')
			arm.ShaderType = IRenderer.Scene_GrayShader;
		elseif flag == 0 then
			-- box.Visibility = Visibility.Hidden;
			arm:SetAnimation('look2')
		elseif flag == 1 then
			box.Visibility = Visibility.Visible;
			arm:SetAnimation('keep');
			arm.ShaderType = IRenderer.Scene_NormalShader;
			arm:SetScale(1,1);
		end
	end
end

typeMethodList.itemIconNameTemplate = function(o)
	local ic = o.ctrl:GetLogicChild('itemCell');
	local icon = ic:GetLogicChild('item');
	local num = ic:GetLogicChild('num');
	local name = o.ctrl:GetLogicChild('name');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithItem = function(item)
		local data = resTableManager:GetValue(ResTable.item, tostring(item.resid), {'icon', 'name', 'quality'});
		ic.Image = GetPicture('item/i' .. data['quality'] .. '.ccz');
		icon.Image = GetPicture('icon/' .. tostring(data['icon']) .. '.ccz');
		name.Text = tostring(data['name']);
		num.Text = tostring(item.num);
	end
end

typeMethodList.npcgoodTemplate = function(o)
	local itemPanel = o.ctrl:GetLogicChild('item');
	local itemName = o.ctrl:GetLogicChild('name');
	local price = o.ctrl:GetLogicChild('price');
	local currencyIcon = o.ctrl:GetLogicChild('gem');
	local owner = o.ctrl:GetLogicChild('haveLabel');
	local over = o.ctrl:GetLogicChild('over'); -- 售罄
	local tips = o.ctrl:GetLogicChild('tip');
	local tipsLabel = o.ctrl:GetLogicChild('tip'):GetLogicChild('label');
	local tipsNum = o.ctrl:GetLogicChild('tip'):GetLogicChild('num');
	local btn = o.ctrl:GetLogicChild('Button');
	local cardeventTip = o.ctrl:GetLogicChild('cardevent');

	local itemData = {};
	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	-- 远征商店
	o.initWithItemExSp = function(item)
		-- item
		local data = resTableManager:GetRowValue(ResTable.expedition_shop, tostring(item.id));
		local idata = resTableManager:GetRowValue(ResTable.item, tostring(data['item_id']));
		itemName.Text = tostring(data['name']);
		local itemO = customUserControl.new(itemPanel, 'itemTemplate');
		itemO.initWithInfo(data['item_id'], data['item_num'],75,true);

		local icon;
		if data['money_type'] == 3 then -- 此为远征商店 表中只能填写3，若为其他值 需同时更改服务器客户端消耗逻辑
			icon = resTableManager:GetValue(ResTable.item, tostring(10019), 'icon');
			currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');
		end

		price.Text = tostring(data['price']);
		owner.Text = string.format(LANG_expeditionShopPanel_3, Package:GetItemCount( data['item_id'] ));
		if item.buy_num >= data['islimited'] then
			btn.Visibility = Visibility.Hidden;
			over.Visibility = Visibility.Visible;
			tips.Visibility = Visibility.Hidden;
		else
			btn.Visibility = Visibility.Visible;
			over.Visibility = Visibility.Hidden;
			tips.Visibility = Visibility.Visible;
			tipsNum.Text = tostring(data['islimited'] - item.buy_num);
		end
		btn.Tag = item.id;
		btn:SubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onClick');
		itemData = {
			currencyIcon = GetPicture('icon/'..icon..'.ccz'),
			index = item.id,
			itemid = item.item_id,
			name = tostring(data['name']),
			count = tostring(data['item_num']),
			own = owner.Text,
			price = tostring(data['price']),
			enum = 1, -- ShopBuyPanel's enum
		}
		o.resid = item.item_id;
		o.item_id = idata['id'];
	end

	-- 公会商店
	o.initWithItemGuild = function(item)
		-- item
		local data = resTableManager:GetRowValue(ResTable.guild_shop, tostring(item.id));
		local idata = resTableManager:GetRowValue(ResTable.item, tostring(data['item_id']));
		itemName.Text = tostring(data['name']);
		local itemO = customUserControl.new(itemPanel, 'itemTemplate');
		itemO.initWithInfo(data['item_id'], data['item_num'],75,true);

		local icon;
		if data['money_type'] == 4 then -- 此为远征商店 表中只能填写3，若为其他值 需同时更改服务器客户端消耗逻辑
			icon = resTableManager:GetValue(ResTable.item, tostring(16006), 'icon');
			currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');
		end

		price.Text = tostring(data['price']);
		owner.Text = string.format(LANG_expeditionShopPanel_3, Package:GetItemCount( data['item_id'] ));
		if item.buy_num >= data['islimited'] then
			btn.Visibility = Visibility.Hidden;
			over.Visibility = Visibility.Visible;
			tips.Visibility = Visibility.Hidden;
		else
			btn.Visibility = Visibility.Visible;
			over.Visibility = Visibility.Hidden;
			tips.Visibility = Visibility.Visible;
			tipsNum.Text = tostring(data['islimited'] - item.buy_num);
		end
		btn.Tag = item.id;
		btn:SubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onClick');
		-- btn:SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionShopPanel:onClick');
		itemData = {
			currencyIcon = GetPicture('icon/'..icon..'.ccz'),
			index = item.id,
			itemid = item.item_id,
			name = tostring(data['name']),
			count = tostring(data['item_num']),
			own = owner.Text,
			price = tostring(data['price']),
			enum = 2, -- ShopBuyPanel's enum
		}
		o.resid = item.item_id;
		o.item_id = idata['id'];
	end

	--  符文商店
	o.initWithItemRune = function(item)
		-- item
		local data = resTableManager:GetRowValue(ResTable.rune_shop, tostring(item.id));
		local idata = resTableManager:GetRowValue(ResTable.item, tostring(data['item_id']));
		itemName.Text = tostring(data['name']);
		local itemO = customUserControl.new(itemPanel, 'itemTemplate');
		itemO.initWithInfo(data['item_id'], data['item_num'],75,true);

		local icon;
		if data['money_type'] == 5 then -- 此为远征商店 表中只能填写3，若为其他值 需同时更改服务器客户端消耗逻辑
			icon = resTableManager:GetValue(ResTable.item, tostring(18001), 'icon');
			currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');
		end

		price.Text = tostring(data['price']);
		owner.Text = string.format(LANG_expeditionShopPanel_3, Package:GetItemCount( data['item_id'] ));
		if item.buy_num >= data['islimited'] then
			btn.Visibility = Visibility.Hidden;
			over.Visibility = Visibility.Visible;
			tips.Visibility = Visibility.Hidden;
		else
			btn.Visibility = Visibility.Visible;
			over.Visibility = Visibility.Hidden;
			tips.Visibility = Visibility.Visible;
			tipsNum.Text = tostring(data['islimited'] - item.buy_num);
		end
		btn.Tag = item.id;
		btn:SubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onClick');
		-- btn:SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionShopPanel:onClick');
		itemData = {
			currencyIcon = GetPicture('icon/'..icon..'.ccz'),
			index = item.id,
			itemid = item.item_id,
			name = tostring(data['name']),
			count = tostring(data['item_num']),
			own = owner.Text,
			price = tostring(data['price']),
			enum = 3, -- ShopBuyPanel's enum
		}
		o.resid = item.item_id;
		o.item_id = idata['id'];
	end

	-- 活动商店
	o.initWithItemCardEvent = function(item)
		-- item
		local data = resTableManager:GetRowValue(ResTable.cardeventshop, tostring(item.id));
		local idata = resTableManager:GetRowValue(ResTable.item, tostring(data['item_id']));
		itemName.Text = tostring(data['name']);
		local itemO = customUserControl.new(itemPanel, 'itemTemplate');
		itemO.initWithInfo(data['item_id'], data['item_num'],75,true);

		local icon;
		icon = resTableManager:GetValue(ResTable.item, tostring(16101), 'icon');
		currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');
		cardeventTip.Visibility = Visibility.Visible;
		currencyIcon.Visibility = Visibility.Hidden;

		price.Text = tostring(data['price']);
		owner.Text = string.format(LANG_expeditionShopPanel_3, Package:GetItemCount( data['item_id'] ));
		if item.buy_num >= data['islimited'] then
			btn.Visibility = Visibility.Hidden;
			over.Visibility = Visibility.Visible;
			tips.Visibility = Visibility.Hidden;
		else
			btn.Visibility = Visibility.Visible;
			over.Visibility = Visibility.Hidden;
			tips.Visibility = Visibility.Visible;
			tipsLabel.Text = LANG_CARDEVENTSHOP_2;
			tipsNum.Text = tostring(data['islimited'] - item.buy_num);
		end
		tips:GetLogicChild('img').Visibility = Visibility.Hidden;
		btn.Tag = item.id;
		btn:SubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onClick');
		itemData = {
			currencyIcon = GetPicture('icon/'..icon..'.ccz'),
			index = item.id,
			itemid = item.item_id,
			name = tostring(data['name']),
			count = tostring(data['item_num']),
			own = owner.Text,
			price = tostring(data['price']),
			enum = 4, -- ShopBuyPanel's enum
		}
		o.resid = item.item_id;
		o.item_id = idata['id'];
	end

	-- 种子商店
	o.initWithItemPlant = function(item)
		-- item
		local data = resTableManager:GetRowValue(ResTable.plant_shop, tostring(item.id));
		local idata = resTableManager:GetRowValue(ResTable.item, tostring(data['item_id']));
		itemName.Text = tostring(data['name']);
		local itemO = customUserControl.new(itemPanel, 'itemTemplate');
		itemO.initWithInfo(data['item_id'], data['item_num'],75,true);

		local icon;
		if data['money_type'] == 10001 then
			icon = resTableManager:GetValue(ResTable.item, tostring(10001), 'icon');
			currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');
		elseif data['money_type'] == 10003 then
			icon = resTableManager:GetValue(ResTable.item, tostring(10003), 'icon');
			currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');
		end	

		price.Text = tostring(data['price']);
		owner.Text = string.format(LANG_expeditionShopPanel_3, Package:GetItemCount( data['item_id'] ));

		over.Visibility = Visibility.Hidden;
		tips.Visibility = Visibility.Hidden;

		btn.Tag = item.id;
		btn.TagExt = item.item_id;
		btn:SubscribeScriptedEvent('Button::ClickEvent', 'PlantShopPanel:onBuy');
		itemData = {
			currencyIcon = GetPicture('icon/'..icon..'.ccz'),
			index = item.id,
			itemid = item.item_id,
			name = tostring(data['name']),
			count = tostring(data['item_num']),
			own = owner.Text,
			price = tostring(data['price']),
			enum = 1, -- ShopBuyPanel's enum
		}
		o.resid = item.item_id;
		o.item_id = idata['id'];
	end

	-- 库存商店
	o.initWithItemIventory = function(item)
		-- item
		local data = resTableManager:GetRowValue(ResTable.inventory_shop, tostring(item.id));
		local idata = resTableManager:GetRowValue(ResTable.item, tostring(data['item_id']));
		itemName.Text = tostring(data['name']);
		local itemO = customUserControl.new(itemPanel, 'itemTemplate');
		itemO.initWithInfo(data['item_id'], data['item_num'],75,true);

		local icon;
		if data['money_type'] == 1 then
			icon = resTableManager:GetValue(ResTable.item, tostring(10001), 'icon');
			currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');
		elseif data['money_type'] == 2 then
			icon = resTableManager:GetValue(ResTable.item, tostring(10003), 'icon');
			currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');
		end	

		price.Text = tostring(data['price']);
		owner.Text = string.format(LANG_expeditionShopPanel_3, Package:GetItemCount( data['item_id'] ));

		over.Visibility = Visibility.Hidden;
		tips.Visibility = Visibility.Hidden;

		btn.Tag = item.id;
		btn.TagExt = item.item_id;
		btn:SubscribeScriptedEvent('Button::ClickEvent', 'InventoryShopPanel:onBuy');
		itemData = {
			currencyIcon = GetPicture('icon/'..icon..'.ccz'),
			index = item.id,
			itemid = item.item_id,
			name = tostring(data['name']),
			count = tostring(data['item_num']),
			own = owner.Text,
			price = tostring(data['price']),
			enum = 1, -- ShopBuyPanel's enum
		}
		o.resid = item.item_id;
		o.item_id = idata['id'];
	end

	o.getItemData = function()
		return itemData;
	end

	o.refresh = function()
		local curNum = tonumber(tipsNum.Text - 1);
		tipsNum.Text = tostring(curNum);
		if curNum <= 0 then
			tips.Visibility = Visibility.Hidden;
			btn.Visibility = Visibility.Hidden;
			over.Visibility = Visibility.Visible;
		end
		owner.Text = string.format(LANG_expeditionShopPanel_3, Package:GetItemCount( o.item_id ));
	end
end

typeMethodList.worldMapTemplate = function(o)
	local image = o.ctrl:GetLogicChild('image');
	image:SetScale(0.8,0.8)
	local textPanel = o.ctrl:GetLogicChild('textPanel')
	textPanel:SetScale(0.9,0.9)
	textPanel.Margin = Rect(20,220,0,0)
	local text1 =  o.ctrl:GetLogicChild('textPanel'):GetLogicChild('text1');
	local text2 =  o.ctrl:GetLogicChild('textPanel'):GetLogicChild('text2');
	local noticeRound = text2:GetLogicChild(0);
	local curRound = text2:GetLogicChild(1);
	local maxRound = text2:GetLogicChild(2);
	local text3 =  o.ctrl:GetLogicChild('textPanel'):GetLogicChild('text3');
	local text4 =  o.ctrl:GetLogicChild('textPanel'):GetLogicChild('text4');
	local tip = o.ctrl:GetLogicChild('tip');
	local currentTime =LuaTimerManager:GetCurrentTime()
	local effect = o.ctrl:GetLogicChild('effect');
	local btn = o.ctrl:GetLogicChild('btn'); 
	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.getButton = function()
		return btn
	end

	o.initWithItem = function(index)
		local currentTime = LuaTimerManager:GetCurrentTime()
		local hero = ActorManager.hero;
		local level = hero:GetLevel();
		image.Image = GetPicture('worldmap/worldmap_0' .. index .. '.ccz');
		image.ZOrder = 0;
		effect.ZOrder = -1;
		--effect.Visibility  = Visibility.Visible;
		effect:LoadArmature('fubenjiemian');
		effect:SetAnimation('play');
		--effect:SetScale(2.2,2.2)
		effect:SetScale(1.8,1.8)
		effect.Margin = Rect(170,125,0,0)
		local is_finish = false;
		if index == 1 then
			text3.Text = LANG_WorldMap_1;
			text3.Visibility = Visibility.Visible;
			o.ctrl:SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:onEnterPveBarrier');
		elseif index == 2 then
			o.ctrl:SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onShowTreasure');
			if level >= FunctionOpenLevel.treasure then
				text1.Text = LANG_WorldMap_2;
				ActorManager.user_data.round.treasure_cur = ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin;
				if ActorManager.user_data.round.treasure_cur < 0 then
					ActorManager.user_data.round.treasure_cur = 0;
				end
				noticeRound.Text = tostring(LANG_WorldMap_8);
				curRound.Text = tostring((ActorManager.user_data.role.lvl.level - ActorManager.user_data.round.treasure_cur));
				maxRound.Text = '/' .. ActorManager.user_data.role.lvl.level;
				if ActorManager.user_data.round.treasure_cur < ActorManager.user_data.role.lvl.level then
					is_finish = false;
					effect.Visibility = Visibility.Visible;
				else
					is_finish = true;
					effect.Visibility = Visibility.Hidden;
				end
				text1.Visibility = Visibility.Visible;
				text2.Visibility = Visibility.Visible;
			else
				text3.Text = LANG_WorldMap_2;
				text3.Visibility = Visibility.Visible;
				image.Enable = false;
			end 
		elseif index == 3 then
			o.ctrl:SubscribeScriptedEvent('Button::ClickEvent', 'MainUI:onJiangJiChangClick');
			if level >= FunctionOpenLevel.arena then
				if LuaTimerManager.fightArenaCDTime == 0 or ArenaPanel.remainTimes == 0 then
					noticeRound.Text = tostring(LANG_WorldMap_8);
					curRound.Text = tostring(ArenaPanel.remainTimes) or '0' ;
					maxRound.Text = '/'..'5';
					text2.Visibility = Visibility.Visible;
					text4.Visibility = Visibility.Hidden;
				else
					text4.Text = LANG_propertyRoundPanel_4 .. Time2HMSStr(LuaTimerManager.fightArenaCDTime) or '0'
					text4.Visibility = Visibility.Visible;
					text2.Visibility = Visibility.Hidden;
				end
				if ArenaPanel.remainTimes == 0  then
					is_finish = true;
				end
				text1.Text = LANG_WorldMap_4;
				text1.Visibility = Visibility.Visible;
				image.Enable = true;
			else
				text3.Text = LANG_WorldMap_4;
				text3.Visibility = Visibility.Visible;
				image.Enable = false;
			end
			if ActorManager.user_data.role.lvl.level >= FunctionOpenLevel.arena and ArenaPanel.remainTimes > 0 and LuaTimerManager.fightArenaCDTime <= 0 then
				effect.Visibility = Visibility.Visible
			else
				effect.Visibility = Visibility.Hidden
			end
		elseif index == 4 then
			o.ctrl:SubscribeScriptedEvent('Button::ClickEvent', 'MainUI:onWorldClick'); 
			if (currentTime >= 12 * 3600 + 300  and currentTime <= 13 * 3600 + 300) or   (currentTime >= 20 * 3600 + 300 and currentTime <= 21 * 3600 + 300)  then
				text1.Text = LANG_WorldMap_7;
				text1.Visibility = Visibility.Visible;
				text2.Visibility = Visibility.Visible;
				text3.Visibility = Visibility.Hidden;
				image.Enable = true;
			else
				if (currentTime < 12 * 3600 + 300  or currentTime >= 21 * 3600) then
					text3.Text = LANG_WorldMapOpen[0];
				else
					text3.Text = LANG_WorldMapOpen[1];
				end
				text3.Visibility = Visibility.Visible;
				image.Enable = false;
			end
		elseif index == 5 then
			if level >= FunctionOpenLevel.rankMatch then
				o.ctrl:SubscribeScriptedEvent('Button::ClickEvent', 'RankSelectActorPanel:reqEnterRankPanel');
				text3.Visibility = Visibility.Visible
				text3.Text = LANG_WorldMap_10
			else
				text3.Visibility = Visibility.Visible;
				text3.Text = LANG_WorldMap_10;
				image.Enable = false;
			end
		elseif index == 6 then
			o.ctrl:SubscribeScriptedEvent('Button::ClickEvent', 'PropertyRoundPanel:onShow');
			if level >= FunctionOpenLevel.limitround then
				text1.Text = LANG_WorldMap_3;	
				local max_round = 3--resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_trial') or 4;
				if tonumber(max_round - ActorManager.user_data.round.limit_round_left) > 0 then
					if ActorManager.user_data.round.limit_round_sec == 0 then
						noticeRound.Text = tostring(LANG_WorldMap_8);
						curRound.Text = tostring(max_round - ActorManager.user_data.round.limit_round_left);
						maxRound.Text = '/ '.. max_round;
						text2.Visibility = Visibility.Visible;
						text4.Visibility = Visibility.Hidden;
					else
						if not (PropertyRoundPanel:isShow()) then
							if ActorManager.user_data.round.limit_round_sec > 0 then
								ActorManager.user_data.round.limit_round_sec = ActorManager.user_data.round.limit_round_sec - 1;
							end
						end
						text4.Text = LANG_propertyRoundPanel_4 .. Time2HMSStr(ActorManager.user_data.round.limit_round_sec);
						text4.Visibility = Visibility.Visible;
						text2.Visibility = Visibility.Hidden;
					end
					is_finish = false;
					effect.Visibility = Visibility.Visible;
				else
					is_finish = true;
					text2.Visibility = Visibility.Hidden
					effect.Visibility = Visibility.Hidden;
				end	
				text1.Visibility = Visibility.Visible;
				image.Enable = true;
			else
				text3.Text = LANG_WorldMap_3;
				text3.Visibility = Visibility.Visible;
				image.Enable = false;
			end 

		elseif index == 7 then
			o.ctrl:SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:onShow');
			if level >= FunctionOpenLevel.expedition then
				image.Enable = true;
				text1.Text = LANG_WorldMap_5;
				noticeRound.Text = LANG_WorldMap_8;
				local roundNum = Configuration.EXPEDITION_MAX_ROUND - ActorManager.user_data.round.expedition_max_round
				if roundNum < 0 then
					roundNum = 0
				end
				curRound.Text = tostring(roundNum);
				maxRound.Text = '/' .. Configuration.EXPEDITION_MAX_ROUND;
				if ActorManager.user_data.round.expedition_max_round < Configuration.EXPEDITION_MAX_ROUND then
					is_finish = false;
					effect.Visibility = Visibility.Visible;
				else
					is_finish = true;
					effect.Visibility = Visibility.Hidden;
				end	
				text1.Visibility = Visibility.Visible;
				text2.Visibility = Visibility.Visible;	
			else
				text3.Text = LANG_WorldMap_5;
				text3.Visibility = Visibility.Visible;
				image.Enable = false;
			end
		elseif index == 8 then
			o.ctrl:SubscribeScriptedEvent('Button::ClickEvent', 'ScufflePanel:rqScuffleState');
			image:SetScale(0.77,0.77)
			if level >= FunctionOpenLevel.scuffle then
				image.Enable = true;
			else
				image.Enable = false;
			end
			textPanel.Margin = Rect(30,220,0,0)
			text1.Text = LANG_WorldMap_9;
			text1.Visibility = Visibility.Visible;
			text4.Text = LANG_WorldMap_11;
			text4.Visibility = Visibility.Visible;

		end

		noticeRound.TextColor = QuadColor(Color(255, 255, 255, 255));
		if is_finish then
			curRound.TextColor = QuadColor(Color(255, 0, 0, 255));
			maxRound.TextColor = QuadColor(Color(255, 255, 255, 255));
		else
			curRound.TextColor = QuadColor(Color(60, 137, 11, 255));
			maxRound.TextColor = QuadColor(Color(255, 255, 255, 255));
		end
	end

	o.showtimer = function(flag)
		image.Image = GetPicture('worldmap/worldmap_0' .. 4 .. '.ccz');
		if flag == 1 then
			text1.Text = LANG_WorldMap_7;
			text1.Visibility = Visibility.Visible;
			text3.Visibility = Visibility.Hidden;
			image.Enable = true;
		else
			text1.Visibility = Visibility.Hidden;
			text3.Visibility = Visibility.Visible;
			if (currentTime < 12 * 3600 + 300 or currentTime >= 21 * 3600) then
				text3.Text = LANG_WorldMapOpen[0];
			else
				text3.Text = LANG_WorldMapOpen[1];
			end
			image.Enable = false;
		end
	end

	o.setPos = function(x,y)
		o.child.Translate = Vector2(x,y);
	end
end

typeMethodList.noRewardSweepTemplate = function(o)
	local title = o.ctrl:GetLogicChild('title');
	local num = o.ctrl:GetLogicChild('coin_num');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.setTitle = function(title_num)
		title.Text = string.format(LANG_dragonTreasurePanel_55, title_num);
	end

	o.setCoin = function(coin_num)
		num.Text = tostring(coin_num);
	end
end

typeMethodList.rewardSweepTemplate = function(o)
	local title = o.ctrl:GetLogicChild('title');
	local num = o.ctrl:GetLogicChild('coin_num');
	local items = {};
	for i=1,5 do
		items[i] = {};
		items[i].setImg = function(path)
			o.ctrl:GetLogicChild('itemPanel'):GetLogicChild(tostring(i)):GetLogicChild('img').Image = GetPicture(path);
		end
		items[i].setNum = function(num)
			o.ctrl:GetLogicChild('itemPanel'):GetLogicChild(tostring(i)):GetLogicChild('num').Text = tostring(num);
		end
		items[i].setName = function(name)
			o.ctrl:GetLogicChild('itemPanel'):GetLogicChild(tostring(i)):GetLogicChild('name').Text = tostring(name);
		end
	end
	items.setNum = function(count)
		o.ctrl:GetLogicChild('itemPanel').Size = Size(70*count+(count-1)*5,70);
		for i=1, 5 do
			if i<=count then
				o.ctrl:GetLogicChild('itemPanel'):GetLogicChild(tostring(i)).Visibility = Visibility.Visible;
			else
				o.ctrl:GetLogicChild('itemPanel'):GetLogicChild(tostring(i)).Visibility = Visibility.Hidden;
			end
		end
	end

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.setTitle = function(title_num)
		title.Text = string.format(LANG_dragonTreasurePanel_55, title_num);
	end

	o.setCoin = function(coin_num)
		num.Text = tostring(coin_num);
	end

	o.setItems = function(itemList)
		local count = 1;
		for resid, num in pairs(itemList) do
			local img_path = resTableManager:GetValue(ResTable.item, tostring(resid), 'icon');
			local name = resTableManager:GetValue(ResTable.item, tostring(resid), 'name');
			items[count].setImg('icon/' .. img_path .. '.ccz');
			items[count].setNum(num);
			items[count].setName(name);
			count = count + 1;
		end
		items.setNum(count-1);
	end
end

typeMethodList.itemTemplate = function(o)
	local bg = o.ctrl:GetLogicChild('bg');
	local img = o.ctrl:GetLogicChild('img');
	local fg = o.ctrl:GetLogicChild('fg');
	local numLabel = o.ctrl:GetLogicChild('num');
	local selectMark = o.ctrl:GetLogicChild('select');
	local shadow = o.ctrl:GetLogicChild('shadow');
	local eventSubscribe = false;
	local isSubscribe = false;
	local curNum = -1;

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	--物品id item表中的
	--数量 -1表示不显示
	--大小 100/128
	--是否点击会出tips
	o.initWithInfo = function(itemid, num, size, isTip, isShadow)
		itemid = tonumber(itemid);
		if itemid == 39999 then
			itemid = ActorManager:GetRole(0).resid + 30000;
		end
		if math.floor(itemid/100) == 59999 then
			itemid = (ActorManager:GetRole(0).resid + 50000)*100+itemid%100;
		end
		local itemData = resTableManager:GetRowValue(ResTable.item, tostring(itemid));
		if not itemData then
			Debug.print("Error! there's no item, id = " .. tostring(itemid));
			Debug.print("----------------trace begin-------------------------");
			Debug.print(debug.traceback());
			Debug.print("----------------trace end---------------------------");
			return;
		end

		num = num or -1;
		curNum = num;
		size = size or 100;
		isTip = isTip or false;
		isShadow = isShadow or false;

		o.ctrl.Size = Size(size, size);
		bg.Size = Size(size, size);
		fg.Size = Size(size, size);
		img.Size = Size(size, size);
		img.Visibility = Visibility.Visible;
		shadow.Visibility = isShadow and Visibility.Visible or Visibility.Hidden;
		numLabel.TransformPoint = Vector2(1,1);
		numLabel:SetScale(size/100,size/100);

		--分类 背景显示
		--1.钱/钻石等货币  基本上有数量 / 有tip / 底框待定 /
		--2.装备升阶材料 
		--3.碎片 有前景无后景
		if itemid > 40000 and itemid < 50000 then
			bg.Background = Converter.String2Brush("common.icon_bg");
			bg.Visibility = Visibility.Hidden;
			fg.Visibility = Visibility.Visible;
			fg.Background = CreateTextureBrush('home/head_frame_1.ccz', 'home');
		elseif itemid > 30000 and itemid < 40000 then
			bg.Visibility = Visibility.Hidden;
			fg.Visibility = Visibility.Visible;
			fg.Background = Converter.String2Brush("godsSenki.icon_fg2");
		else
			if tonumber(itemData['quality']) == 0 then
				bg.Background = Converter.String2Brush("common.icon_bg");
				bg.Visibility = Visibility.Visible;
				fg.Visibility = Visibility.Hidden;
			else
				bg.Visibility = Visibility.Visible;
				fg.Visibility = Visibility.Hidden;
				bg.Background = Converter.String2Brush("godsSenki.icon_bg_" .. tostring(itemData['quality']));
			end
		end

		--内容显示
		if itemid > 30000 and itemid < 50000 then
			img.Image = GetPicture('navi/'..itemData['icon']..'.ccz');
		else
			img.Image = GetPicture('icon/'..itemData['icon']..'.ccz');
			if itemid == 10002 then
				img.Image = GetPicture('jingji/jingji_gongxun.ccz');
				img:SetScale(0.75,0.75);
			end
			if itemid == 10010 then
				img:SetScale(0.75,0.75);
			end
		end

		--数量显示
		if num == -1 then
			numLabel.Visibility = Visibility.Hidden;
		else
			numLabel.Visibility = Visibility.Visible;
			numLabel.Text = tostring(num);
		end

		--事件绑定
		if isTip then
			o.ctrl.Tag = itemid;
			if (not isSubscribe) then
				o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TipsPanel:fromIconShow');
				isSubscribe = true;
			end
		end

	end

	o.addExtraClickEvent = function(tagid, event)
		if not event then
			Debug.print("Error! there's no event");
			Debug.print("----------------trace begin-------------------------");
			Debug.print(debug.traceback());
			Debug.print("----------------trace end---------------------------");
			return;
		end
		if not eventSubscribe then
			o.ctrl.Tag = tagid;
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', tostring(event));
			eventSubscribe = true;
		else
			o.ctrl.Tag = tagid;
		end
	end

	o.isRole = function()
		return ((o.ctrl.Tag > 40000) and (o.ctrl.Tag < 50000));
	end

	o.getRoleResid = function()
		return (o.ctrl.Tag - 40000);
	end

	o.getChipResid = function()
		return (o.ctrl.Tag - 30000);
	end
	o.getResid = function()
		return o.ctrl.Tag
	end
	o.getNum = function()
		return curNum;
	end
	o.setNum = function(num)
		numLabel.Text = tostring(num);
	end

	o.beSelected = function(flag)
		selectMark.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	end
end

--活动
typeMethodList.WelfareTemplate = function(o)
	local nameLabel = o.ctrl:GetLogicChild('reward');
	local nameLabel2 = o.ctrl:GetLogicChild('reward2');
	local btn = o.ctrl:GetLogicChild('button');
	local itemPanel = o.ctrl:GetLogicChild('item');
	local onGet = o.ctrl:GetLogicChild('get');
	local setPos = true;
	o.ctrl.Background = CreateTextureBrush('Welfare/Welfare_item_bg.ccz', 'Welfare');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithId = function(id, showWeapon)
		local rowData = resTableManager:GetRowValue(ResTable.login_count, tostring(id));
		if not rowData then
			print("Error! there's no item, id = " .. tostring(id));
			return;
		end

		--描述
		local name;
		if showWeapon == true then
			name = resTableManager:GetValue(ResTable.item, tostring(rowData['item2']), 'name');
			nameLabel.Text = LANG_activityAllPanel_28..id..LANG_activityAllPanel_29;
			nameLabel2.Text = name ' x 1';
		else
			name = resTableManager:GetValue(ResTable.item, tostring(rowData['item1']), 'name');
			nameLabel.Text = LANG_activityAllPanel_28..id..LANG_activityAllPanel_29;
			nameLabel2.Text = name ..' x '..rowData['count1'];
		end

		--图
		local item = customUserControl.new(itemPanel, 'itemTemplate');
		item.initWithInfo(rowData['item1'],-1,65,true);

		--按钮
		btn.Tag = id;

	end

	o.initBtn = function(loginStatus, gotReward, i, callback)
		onGet.Text = '';
		if loginStatus == -1 then
			btn.Visibility = Visibility.Hidden;
			onGet.Visibility = Visibility.Visible;
		elseif loginStatus == 0 then
			--btn.Text = LANG_activityAllPanel_25;
			btn.Enable = false;
			btn.Visibility = Visibility.Visible;
			onGet.Visibility = Visibility.Hidden;
		elseif loginStatus == 1 then
			--btn.Text = LANG_activityAllPanel_26;
			btn.Enable = true;		

			for k,v in ipairs(gotReward) do
				if i == v then
					btn.Enable = false;
					btn.Visibility = Visibility.Hidden;
					onGet.Visibility = Visibility.Visible;					
				end
			end	
		end

		if btn.Visibility == Visibility.Visible and setPos then
			ActivityAllPanel:initPos(i);
			setPos = false;
		end
		btn:SubscribeScriptedEvent('UIControl::MouseClickEvent', callback);
	end

	o.getBtn = function()
		return btn;
	end	
end

typeMethodList.cardHeadTemplate = function(o)
	local eventSet = false;
	local imgRole = o.ctrl:GetLogicChild('img');
	local qualityMark = o.ctrl:GetLogicChild('quality');
	local lvlMark = o.ctrl:GetLogicChild('lvl');
	local attributeMark = o.ctrl:GetLogicChild('attribute');
	local loveMark = o.ctrl:GetLogicChild('love');
	local fg = o.ctrl:GetLogicChild('fg');
	local up = o.ctrl:GetLogicChild('up');
	local achieveNeedMark = o.ctrl:GetLogicChild('achieveNeed');
	achieveNeedMark.Visibility = Visibility.Hidden;
	local isInAchieveMark = false;
	local topBrush = o.ctrl:GetLogicChild('topBrush');
	local selectMark = o.ctrl:GetLogicChild('select');
	local shadow = o.ctrl:GetLogicChild('shadow');
	local callable = o.ctrl:GetLogicChild('callable');
	local tip = o.ctrl:GetLogicChild('tip');
	local tanhao = o.ctrl:GetLogicChild('tanhao');
	selectMark.Visibility = Visibility.Hidden;
	shadow.Visibility = Visibility.Hidden;
	callable.Visibility = Visibility.Hidden;
	tip.Visibility = Visibility.Hidden;
	tanhao.Visibility = Visibility.Hidden;
	o.init = function()
	end

	o.setDefeated = function()
		qualityMark.ShaderType = IRenderer.UI_GrayShader
		attributeMark.ShaderType = IRenderer.UI_GrayShader
		imgRole.ShaderType = IRenderer.UI_GrayShader
		fg.ShaderType = IRenderer.UI_GrayShader
		loveMark.ShaderType = IRenderer.UI_GrayShader
	end

	o.ctrlShow = function()
		o.ctrl:GetVisualParent().Visibility = Visibility.Visible;
	end

	o.ctrlHide = function()
		o.ctrl:GetVisualParent().Visibility = Visibility.Hidden;
	end

	o.ctrlSetInfo = function(index,role)
		o.index = index
		o.pid = role.pid
		o.role = role
	end

	o.isDied = function()
		return imgRole.ShaderType == IRenderer.UI_GrayShader
	end

	o.setDied = function()
		imgRole.ShaderType = IRenderer.UI_GrayShader
	end

	o.setRevived = function()
		imgRole.ShaderType = IRenderer.UI_NormalShader
	end

	o.setUp = function(flag)
		up.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	end
	o.initUnionItemEnemy = function(size)
		--社团战斗时用到
		size = size or 100
		lvlMark.Visibility = Visibility.Hidden
		qualityMark.Visibility = Visibility.Hidden
		attributeMark.Visibility = Visibility.Hidden
		shadow.Visibility = Visibility.Hidden
		callable.Visibility = Visibility.Hidden
		selectMark.Visibility = Visibility.Hidden
		tip.Visibility = Visibility.Hidden
		topBrush.Visibility = Visibility.Hidden
		loveMark.Visibility = Visibility.Hidden
		imgRole.Image = GetPicture('union/wenhao.ccz');
		imgRole:SetScale(0.6,0.8)
		fg.Image = GetPicture('home/head_frame_1.ccz');
		o.ctrl:SetScale(size/100,size/100);
	end

	o.initUnionDefendItemEnemy = function(size,icon)
		--社团战斗时用到
		size = size or 100
		lvlMark.Visibility = Visibility.Hidden
		qualityMark.Visibility = Visibility.Hidden
		attributeMark.Visibility = Visibility.Hidden
		shadow.Visibility = Visibility.Hidden
		callable.Visibility = Visibility.Hidden
		selectMark.Visibility = Visibility.Hidden
		tip.Visibility = Visibility.Hidden
		topBrush.Visibility = Visibility.Hidden
		loveMark.Visibility = Visibility.Hidden
		imgRole.Image = GetPicture('navi/'..icon..'.ccz');
		--imgRole:SetScale(0.6,0.8)
		fg.Image = GetPicture('home/head_frame_1.ccz');
		o.ctrl:SetScale(size/100,size/100);
	end
	o.initEnemyInfo = function(enemy, size)
		lvlMark.Visibility = Visibility.Visible
		qualityMark.Visibility = Visibility.Visible
		attributeMark.Visibility = Visibility.Visible
		shadow.Visibility = Visibility.Hidden
		callable.Visibility = Visibility.Hidden
		selectMark.Visibility = Visibility.Hidden
		tip.Visibility = Visibility.Hidden

		size = size or 100
		--print('resid--->'..tostring(enemy.resid))
		local role = resTableManager:GetRowValue(ResTable.actor,tostring(enemy.resid))
		--头像
		imgRole.Image = GetPicture('navi/' .. role.img .. '_icon_01.ccz')
		if enemy.lovelevel == 4 then
			imgRole.Image = GetPicture('navi/' .. role.img .. '_icon_02.ccz')
		end
		--等级
		lvlMark.Text = tostring(enemy.level)
		--左上角属性角标
		attributeMark.Image = GetPicture('login/login_icon_' .. role.attribute .. '.ccz')
		--右上角的阶数图标
		local rank = enemy.starnum or 1
		qualityMark.Image = GetPicture('personInfo/nature_' .. (rank - 1) .. '.ccz')
		--根据装备等级来决定边框颜色
		fg.Image = GetPicture('home/head_frame_' .. (enemy.equiplv or 1) .. '.ccz')
		--是否觉醒标识
		loveMark.Visibility = (enemy.lovelevel == 4) and Visibility.Visible or Visibility.Hidden	
		--根据size设置缩放，默认为100
		o.ctrl:SetScale(size/100,size/100);
	end

	o.initWithPid = function(pid, size, tag)
		size = size or 100;
		--有这人的情况下
		lvlMark.Visibility = Visibility.Visible;
		qualityMark.Visibility = Visibility.Visible;
		attributeMark.Visibility = Visibility.Visible;
		shadow.Visibility = Visibility.Hidden;
		callable.Visibility = Visibility.Hidden;

		local role = ActorManager:GetRole(pid);

		--头像
		imgRole.Image = GetPicture('navi/' .. role.headImage .. '.ccz');

		--等级
		lvlMark.Text = tostring(role.lvl.level);

		--左上角属性角标
		attributeMark.Image = GetPicture('login/login_icon_' .. role.attribute .. '.ccz');

		--右上角的阶数图标
		qualityMark.Image = GetPicture('personInfo/nature_' .. (role.rank - 1) .. '.ccz'); 
		if tag then
			qualityMark.Image = GetPicture('personInfo/nature_' .. role.rank .. '.ccz'); 
		end

		--前景框
		--找到等级最低的装备
		local equip_lvl = 100;
		for i=1, 5 do
			local equip_resid = role.equips[tostring(i)].resid;
			local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank');
			if equip_rank < equip_lvl then
				equip_lvl = equip_rank;
			end
		end
		--根据装备等级来决定边框颜色
		fg.Image = GetPicture('home/head_frame_' .. tostring(equip_lvl) .. '.ccz');

		--爱恋状态显示
		if (role.lvl.lovelevel == 4) then
			loveMark.Storyboard = "";
			loveMark.Visibility = Visibility.Visible;
		else

			local totalLovevalue = resTableManager:GetValue(ResTable.love_task, tostring(role.resid * 100 + role.lvl.lovelevel + 1), 'love_max');
			if role.lovevalue >= totalLovevalue and role.lvl.lovelevel < 4 then
				loveMark.Storyboard = "storyboard.Shine";
			else
				loveMark.Storyboard = "";
				loveMark.Visibility = Visibility.Hidden;
			end
		end

		--根据size设置缩放，默认为100
		o.ctrl:SetScale(size/100,size/100);		
	end

	o.initModleChangeHeadInfo = function(role_resid, size, is_qua)
		--更换形象的头像方法
		size = size or 100;
		lvlMark.Visibility = Visibility.Hidden;
		qualityMark.Visibility = Visibility.Visible;
		attributeMark.Visibility = Visibility.Visible;
		loveMark.Visibility = Visibility.Hidden;
		shadow.Visibility = is_qua and Visibility.Hidden or Visibility.Visible;
		callable.Visibility = Visibility.Hidden;

		local roleData = resTableManager:GetRowValue(ResTable.navi_main, tostring(role_resid));
		local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(role_resid));
		--print('role_resid->'..tostring(actorData));
		--头像
		imgRole.Image = GetPicture('navi/' .. roleData['role_path_icon'] .. '.ccz');

		--左上角属性角标
		attributeMark.Image = GetPicture('login/login_icon_' .. actorData['attribute'] .. '.ccz');

		--右上角的阶数图标
		local rank = resTableManager:GetValue(ResTable.item, tostring(role_resid + 30000), 'quality');
		qualityMark.Image = GetPicture('personInfo/nature_' .. (rank - 1) .. '.ccz');

		--前景框
		fg.Image = GetPicture('home/head_frame_1.ccz');

		--根据size设置缩放，默认为100
		o.ctrl:SetScale(size/100,size/100);
	end

	o.initWithNotExistRole = function(not_exist_role, size, canCall)
		--通常没这人的时候用这个方法
		lvlMark.Visibility = Visibility.Hidden;
		qualityMark.Visibility = Visibility.Visible;
		attributeMark.Visibility = Visibility.Visible;
		loveMark.Visibility = Visibility.Hidden;
		shadow.Visibility = Visibility.Visible;
		callable.Visibility = canCall and Visibility.Visible or Visibility.Hidden;

		--头像
		imgRole.Image = GetPicture('navi/' .. not_exist_role.headImage .. '.ccz');

		--左上角属性角标
		attributeMark.Image = GetPicture('login/login_icon_' .. not_exist_role.attribute .. '.ccz');

		--右上角的阶数图标
		qualityMark.Image = GetPicture('personInfo/nature_' .. (not_exist_role.rank - 1) .. '.ccz');

		--前景框
		fg.Image = GetPicture('home/head_frame_1.ccz');

		--根据size设置缩放，默认为100
		o.ctrl:SetScale(size/100,size/100);
	end

	o.setTip = function(role)
		local isVisible = EquipStrengthPanel:IsEquipCanAdv(role) or SkillStrPanel:IsRoleSkillCanAdv(role) or LovePanel:IsRoleCanAttack(role);
		tip.Visibility = isVisible and Visibility.Visible or Visibility.Hidden;
		if CardRankupPanel:isRoleCanAdvance( role ) then
			tanhao.Visibility = Visibility.Visible;
		else
			tanhao.Visibility = Visibility.Hidden;
		end
	end

	o.clickEvent = function(event, tag, tagExt)
		tagExt = tagExt or 0;
		if not event then
			Debug.print("Error! there's no event");
			Debug.print("----------------trace begin-------------------------");
			Debug.print(debug.traceback());
			Debug.print("----------------trace end---------------------------");
			return;
		end
		if not eventSet then
			o.ctrl.Tag = tag;
			o.ctrl.TagExt = tagExt;
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', tostring(event));
			eventSet = true;
		else
			o.ctrl.Tag = tag;
			o.ctrl.TagExt = tagExt;
		end
	end

	o.Selected = function()
		selectMark.Visibility = Visibility.Visible;
		if isInAchieveMark then
			achieveNeedMark.Visibility = Visibility.Hidden;
		end
	end

	o.isSelected = function()
		return selectMark.Visibility == Visibility.Visible;
	end

	o.Unselected = function()
		selectMark.Visibility = Visibility.Hidden;
		if isInAchieveMark then
			achieveNeedMark.Visibility = Visibility.Visible;
		end
	end

	o.addAchieveMark = function()
		isInAchieveMark = true;
	end
	o.RankSetLevel = function()
		lvlMark.Text = '85'
	end
end

typeMethodList.unionSkillTemplate = function(o)
	local skillIcon = o.ctrl:GetLogicChild('skill');
	local labelLevel = o.ctrl:GetLogicChild('level');
	local labelName = o.ctrl:GetLogicChild('name');
	local labelValue = o.ctrl:GetLogicChild('value');
	local labelInfo = o.ctrl:GetLogicChild('labelInfo');
	local labelConsume = o.ctrl:GetLogicChild('consume');
	local btn = o.ctrl:GetLogicChild('advance');
	local cost;
	local maxLv = 90;

	o.init = function()
		btn:SubscribeScriptedEvent('Button::ClickEvent', 'UnionSkillPanel:onAdvanceSkill');
	end

	o.setButtonEnabled = function()
		btn.Enable = false;
	end

	o.getcostPoint = function()
		return cost
	end 

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(resid, level, curDonate)
		UnionSkillPanel:setLeftPoint(curDonate)
		local id = resid*1000+level;
		local data = resTableManager:GetRowValue(ResTable.unionSkill, tostring(id));

		skillIcon.Image = GetPicture('icon/' .. data['icon'] .. '.ccz');

		labelLevel.Text = 'Lv.' .. level;

		labelName.Text = tostring(data['name']);

		labelValue.Text = '+' .. data['value'];

		local nextCost = resTableManager:GetValue(ResTable.unionSkill, tostring(id+1), 'cost');
		cost = nextCost;
		labelConsume.Text = tostring(cost);

		--确认下一级技能是否开启
		local open = false;
		local str;
		if data['level']+1 > ActorManager.hero:GetLevel() then
			--未达到人物等级
			open = false;
			str = LANG_unionSkillPanel_10;
		elseif data['level'] >= maxLv then
			open = false;
			str = LANG_unionSkillPanel_12;
		else
			local union_level_need = resTableManager:GetValue(ResTable.unionSkill, tostring(resid*1000+level+1), 'unlock_guildlv');
			if union_level_need > ActorManager.user_data.unionLevel then
				--未到开放的公会等级
				open = false;
				str = LANG_unionSkillPanel_8 .. union_level_need .. LANG_unionSkillPanel_9;
			else
				open = true;
				str = LANG_unionSkillPanel_11;
			end
		end
		if open then
			labelInfo.Text = str;
			labelConsume.Visibility = Visibility.Visible;
			btn.Text = LANG_unionSkillPanel_1;
			btn.Enable = (curDonate >= cost);
		else
			labelInfo.Text = str;
			labelConsume.Visibility = Visibility.Hidden;
			btn.Text = LANG_unionSkillPanel_7;
			btn.Enable = false;
		end
		btn.Tag = resid; 
	end

	o.initWithDefault = function()
		skillIcon.Image = GetPicture('icon/unionSkillDefault.ccz');

		labelLevel.Text = 'Lv. X';

		labelName.Text = '?????:';

		labelValue.Text = '+ X';

		labelConsume.Visibility = Visibility.Hidden;
		btn.Text = LANG_unionSkillPanel_7;
		btn.Enable = false;

		labelInfo.Text = LANG_unionSkillPanel_8 .. 'X' .. LANG_unionSkillPanel_9;
	end
end

typeMethodList.selectLvTemplate = function(o)
	local btn = o.ctrl:GetLogicChild('btn');
	local label = btn:GetLogicChild('label');

	o.init = function()
		btn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'CardEventPanel:selectLv');
		btn.GroupID = RadionButtonGroup.cardEventSelectLv;
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithLv = function(lv)
		label.Text = tostring(resTableManager:GetValue(ResTable.event_difficulty, tostring(lv), 'name'));
		btn.Tag = 6000+(lv-1)*100+1;
	end

	o.selected = function()
		btn.Selected = true;
	end

	o.unSelected = function()
		btn.Selected = false;
	end
end

typeMethodList.wingTemplate = function(o)
	local img = o.ctrl:GetLogicChild('img');
	local qualityMark = o.ctrl:GetLogicChild('quality');
	local selectMark = o.ctrl:GetLogicChild('select');
	local hasEquip = o.ctrl:GetLogicChild('hasEquip');
	local bg = o.ctrl:GetLogicChild('bg');

	o.init = function()
		o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'WingPanel:onSelectWing');
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithWing = function(wing)
		local wingIcon = resTableManager:GetValue(ResTable.item, tostring(wing.resid), 'icon');
		img.Image = GetPicture('icon/'..wingIcon..'.ccz');
		o.ctrl.Tag = wing.wid;
		local quality = wing.resid % 100 % 10;
		qualityMark.Image = GetPicture('wing/word_' .. quality .. '.ccz');
		bg.Size = Size(80, 80);
		local level = math.floor((wing.resid % 100)/10)+1;
		bg.Background = Converter.String2Brush("godsSenki.icon_bg_" .. tostring(level));
	end

	o.equip = function(flag)
		hasEquip.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	end

	o.beSelected = function(flag)
		selectMark.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	end
end

typeMethodList.runeHuntNewsTemplate = function(o)
	local label = o.ctrl:GetLogicChild('label');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(name,resid)
		local runeName = resTableManager:GetValue(ResTable.item, tostring(resid), 'name');
		if not runeName then
			return -1;
		end
		label.Text = string.format(LANG_RUNE_NEWS, name, runeName);
		return 0;
	end
end

typeMethodList.achievement_task = function(o)
	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end
end

typeMethodList.runeInfoTemplate = function(o)
	local icon = o.ctrl:GetLogicChild('icon');
	local name_lvl = o.ctrl:GetLogicChild('name_lvl');
	local label_info = o.ctrl:GetLogicChild('info');
	local brush = o.ctrl:GetLogicChild('brush');
	local num = o.ctrl:GetLogicChild('num');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(runeItem, order, state, is_stack)
		brush:SetVertexColor(listColor[order%4+1]);
		local data = resTableManager:GetRowValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv));
		if not data then
			return -1;
		end
		name_lvl.Text = string.format(LANG_RUNE_INFO_1, data['name'], runeItem.lv);
		label_info.Text = tostring(data['description']);
		icon.Image = GetPicture('icon/'..data['icon']..'.ccz');
		o.ctrl.Tag = runeItem.id;
		if is_stack then
			o.ctrl.TagExt = 1;
		else
			o.ctrl.TagExt = 0;
		end

		if is_stack then
			num.Visibility = Visibility.Visible;
			num.Text = tostring('X' .. runeItem.num);
		else
			num.Visibility = Visibility.Hidden;
		end

		if state == 'inlay' then
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneInlayPanel:clickRune');
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseDownEvent', 'RuneInlayPanel:mouseDown');
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseMoveEvent', 'RuneInlayPanel:moveItem');
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseUpEvent', 'RuneInlayPanel:overMove');
		elseif state == 'compose' then
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneComposePanel:mouseClick');
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseDownEvent', 'RuneComposePanel:mouseDown');
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseMoveEvent', 'RuneComposePanel:moveItem');
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseUpEvent', 'RuneComposePanel:overMove');
		end

		return 0;
	end
end

typeMethodList.runeInlayTemplate = function(o)
	local bg = o.ctrl:GetLogicChild('bg');
	local lvl_lmt = o.ctrl:GetLogicChild('lvl_lmt');
	local lv_label = lvl_lmt:GetLogicChild('lv');
	local lock = o.ctrl:GetLogicChild('lock');
	local rune = o.ctrl:GetLogicChild('rune');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(rune_id, pos, show_type_, lmt_lv)
		rune.Visibility = Visibility.Hidden;
		lvl_lmt.Visibility = Visibility.Hidden;
		lock.Visibility = Visibility.Hidden;

		local type_ = math.floor((pos-1)/10) + 1;
		bg.Image = GetPicture('rune/rune_bg_type_'..type_..'.ccz');
		if type_ == 3 then
			bg.Scale = Vector2(0.8, 0.8);
		else
			bg.Scale = Vector2(0.9, 0.9);
		end

		if show_type_ == 'slot' then
			rune.Visibility = Visibility.Visible;
			if rune_id == -1 then
				rune.Visibility = Visibility.Hidden;
			else
				local runeItem = Rune:GetRuneById(rune_id);
				if runeItem.resid == -1 then
					return;
				end
				local resid = runeItem.resid;
				local lv = runeItem.lv;
				local data = resTableManager:GetRowValue(ResTable.rune, tostring(resid*100+lv))
				local icon_path = resTableManager:GetValue(ResTable.rune, tostring(resid*100+lv), 'icon');
				rune.Image = GetPicture('icon/'..icon_path..'.ccz');
				if type_ == 3 then
					rune.Scale = Vector2(0.8, 0.8);
				else
					rune.Scale = Vector2(0.6, 0.6);
				end
				o.ctrl.Tag = pos;
				o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneInlayPanel:clickPageRune');
			end
		elseif show_type_ == 'lv_lmt' then
			lv_label.Text = tostring('LV' .. lmt_lv);
			lvl_lmt.Visibility = Visibility.Visible;
		elseif show_type_ == 'lock' then
			lock.Visibility = Visibility.Visible;
		end
	end
end

typeMethodList.runeCheckPageTemplate = function(o)
	local check = o.ctrl:GetLogicChild('check');
	local label = check:GetLogicChild('label');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithIndex = function(order)
		if order == 1 then
			check.Selected = true;
		else
			check.Selected = false;
		end
		check.GroupID = RadionButtonGroup.runeInlayPage;
		check.Tag = order;
		check:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RuneInlayPanel:changePage');
		label.Text = tostring(order);
	end
end

typeMethodList.runeAttributeInfoTemplate = function(o)
	local name = o.ctrl:GetLogicChild('name');
	local value = o.ctrl:GetLogicChild('value');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(type_, v)
		name.Text = LANG_RUNE_ATTRIBUTE_NAME[type_];
		if (type_ >= 100 and type_ <= 104) or (type_ >= 200 and type_ <= 204) then
			value.Text = tostring(v*100) ..'%';
		else
			value.Text = tostring(v);
		end
	end
end

typeMethodList.runeAttributeTemplate = function(o)
	local name = o.ctrl:GetLogicChild('name');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(id, word, event)
		name.Text = tostring(word);
		o.ctrl.Tag = id;
		if event == 'inlay' then
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneInlayPanel:chooseAttribute');
		elseif event == 'compose' then
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneComposePanel:chooseAttribute');
		end
	end
end

typeMethodList.unionBattleSacrificeItemTemplate = function(o)
	local infoPanel = o.ctrl:GetLogicChild('infoPanel');
	local name = infoPanel:GetLogicChild('nameLabel');
	local fp = infoPanel:GetLogicChild('zhandouli');
	local roleList = {};
	for i=1, 5 do
		roleList[i] = o.ctrl:GetLogicChild('rolePanel'):GetLogicChild('role_'..i);
	end
	local openingBtns = o.ctrl:GetLogicChild('btnPanel'):GetLogicChild('opening');
	local occupyBtns = o.ctrl:GetLogicChild('btnPanel'):GetLogicChild('occupy');
	local closeBtns = o.ctrl:GetLogicChild('btnPanel'):GetLogicChild('close');
	local joinBtn = openingBtns:GetLogicChild('joinBtn');
	joinBtn:SubscribeScriptedEvent('Button::ClickEvent', 'UnionBuZhenPanel:newMinor');
	local changeBtn = occupyBtns:GetLogicChild('changeBtn');
	changeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'UnionBuZhenPanel:changeSTeam');
	local cancelBtn = occupyBtns:GetLogicChild('cancelBtn');
	cancelBtn:SubscribeScriptedEvent('Button::ClickEvent', 'UnionBuZhenPanel:cancelTeam');
	local openBtn = closeBtns:GetLogicChild('openBtn');
	openBtn:SubscribeScriptedEvent('Button::ClickEvent', 'UnionBuZhenPanel:openNewBlank');

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(data, id, is_close)
		openingBtns.Visibility = Visibility.Hidden;
		occupyBtns.Visibility = Visibility.Hidden;
		closeBtns.Visibility = Visibility.Hidden;
		infoPanel.Visibility = Visibility.Hidden;
		if is_close then
			closeBtns.Visibility = Visibility.Visible;
			for i=1, 5 do
				local head = customUserControl.new(roleList[i], 'cardHeadTemplate');
				head.initUnionItemEnemy(80);
			end				
		else
			if not data or data.uid == -1 then
				openingBtns.Visibility = Visibility.Visible;
				joinBtn.Tag = id;
				for i=1, 5 do
					local head = customUserControl.new(roleList[i], 'cardHeadTemplate');
					head.initUnionItemEnemy(80);
				end				
			else
				occupyBtns.Visibility = Visibility.Visible;
				infoPanel.Visibility = Visibility.Visible;
				changeBtn.Tag = id;
				cancelBtn.Tag = id;

				name.Text = tostring(data.name);
				fp.Text = tostring(data.fp);
				for i=1, 5 do
					if data.team_info[i] then
						local head = customUserControl.new(roleList[i], 'cardHeadTemplate');
						head.initEnemyInfo(data.team_info[i], 80);
					end
				end				
			end
		end
	end
end

typeMethodList.pubBtnTemplate = function(o)
	local selected = o.ctrl:GetLogicChild('selected');
	local img = o.ctrl:GetLogicChild('img');
	local is_selected = false;
	local redPoint = o.ctrl:GetLogicChild('redPoint');

	o.init = function()
		o.child.Horizontal = ControlLayout.H_CENTER;
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(num)
		img.Image = GetPicture('chouka/pub_radio_'..num..'.ccz');
		img.Tag = num;
		img:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ZhaomuPanel:SelectPub');
		selected.Visibility = Visibility.Hidden;
		is_selected = false;
		redPoint.Visibility = Visibility.Hidden;
	end

	o.GetTag = function()
		return img.Tag;
	end

	o.beSelected = function()
		if is_selected then
			return;
		end
		selected.Visibility = Visibility.Visible;
		is_selected = true;
	end

	o.beUnSelected = function()
		selected.Visibility = Visibility.Hidden;
		is_selected = false;
	end

	o.setRedPoint = function(flag_)
		redPoint.Visibility = flag_ and Visibility.Visible or Visibility.Hidden;
	end
end

typeMethodList.stepupBtnGreyTemplate = function(o)
	local bg = o.ctrl:GetLogicChild('bg');
	local des = o.ctrl:GetLogicChild('des');
	local num = o.ctrl:GetLogicChild('num');

	local state_list = {
		[1] = {x = 268, y = 75, scale = 1, zorder = 50},
		[2] = {x = 22, y = 88, scale = 0.7, zorder = 30},
		[3] = {x = 145, y = 48, scale = 0.6, zorder = 10},
		[4] = {x = 385, y = 48, scale = 0.6, zorder = 10},
		[5] = {x = 510, y = 88, scale = 0.7, zorder = 30},
	};
	local pos;
	local new_pos;

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(id, cur_show, init_state)
		bg.Background = CreateTextureBrush('chouka/button_step'..id..'.ccz', 'chouka');
		if init_state == 4 then
			des.Background = CreateTextureBrush('chouka/bonus_step'..id..'.ccz', 'chouka');
		elseif init_state == 3 then
			des.Background = CreateTextureBrush('chouka/event_step'..id..'.ccz', 'chouka');
		end
		local num_value = resTableManager:GetValue(ResTable.config, tostring(48+id),'value');
		num.Text = getDotStr(num_value);
		pos = id - cur_show + 1;
		if pos < 1 then
			pos = pos + 5;
		elseif pos > 5 then
			pos = pos - 5;
		end

		new_pos = pos - 1;
		if new_pos < 1 then
			new_pos = 5;
		elseif new_pos > 5 then
			new_pos = 1;
		end

		o.child:SetScale(state_list[pos].scale, state_list[pos].scale);
		o.child.ZOrder = state_list[pos].zorder;
		o.child.Translate = Vector2(state_list[pos].x, state_list[pos].y);
	end

	o.updateToNextPos = function(elapse)
		local scale = state_list[pos].scale + (state_list[new_pos].scale - state_list[pos].scale) * elapse;
		local zorder = state_list[pos].zorder + (state_list[new_pos].zorder - state_list[pos].zorder) * elapse;
		local x = state_list[pos].x + (state_list[new_pos].x - state_list[pos].x) * elapse;
		local y = state_list[pos].y + (state_list[new_pos].y - state_list[pos].y) * elapse;
		o.child:SetScale(scale, scale);
		o.child.ZOrder = zorder;
		o.child.Translate = Vector2(x, y);
	end

	o.setNewPos = function()
		pos = new_pos;
		new_pos = pos - 1;
		if new_pos < 1 then
			new_pos = 5;
		elseif new_pos > 5 then
			new_pos = 1;
		end
		o.child:SetScale(state_list[pos].scale, state_list[pos].scale);
		o.child.ZOrder = state_list[pos].zorder;
		o.child.Translate = Vector2(state_list[pos].x, state_list[pos].y);
	end
end

typeMethodList.stepupBtnTemplate = function(o)
	local bg = o.ctrl:GetLogicChild('bg');
	local des = o.ctrl:GetLogicChild('des');
	local num = o.ctrl:GetLogicChild('num');
	local state=4;

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(id, init_state)
		bg.Background = CreateTextureBrush('chouka/button_step'..id..'.ccz', 'chouka');
		if init_state == 4 then
			des.Background = CreateTextureBrush('chouka/bonus_step'..id..'.ccz', 'chouka');
		elseif init_state == 3 then
			des.Background = CreateTextureBrush('chouka/event_step'..id..'.ccz', 'chouka');
		end
		state = init_state;
		local num_value = resTableManager:GetValue(ResTable.config, tostring(48+id),'value');
		num.Text = getDotStr(num_value);
		o.child.ZOrder = 100;
		o.child.Translate = Vector2(268, 75);
		o.child:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ZhaomuPanel:clickStepupBtn');
	end

	o.changeID = function(id)
		bg.Background = CreateTextureBrush('chouka/button_step'..id..'.ccz', 'chouka');
		if state == 4 then
			des.Background = CreateTextureBrush('chouka/bonus_step'..id..'.ccz', 'chouka');
		elseif state == 3 then
			des.Background = CreateTextureBrush('chouka/event_step'..id..'.ccz', 'chouka');
		end
		local num_value = resTableManager:GetValue(ResTable.config, tostring(48+id),'value');
		num.Text = getDotStr(num_value);
	end
end

typeMethodList.cardEventLevelTemplate = function(o)
	local cur = o.ctrl:GetLogicChild('cur');
	local uncur = o.ctrl:GetLogicChild('uncur');
	local name1 = o.ctrl:GetLogicChild('name1');
	local lock = o.ctrl:GetLogicChild('lock');
	local show2 = o.ctrl:GetLogicChild('label_show2');
	local icon = o.ctrl:GetLogicChild('icon');
	local num = o.ctrl:GetLogicChild('num');
	local is_lock = false;

	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(id)
		local bg_index = id;
		local data = resTableManager:GetRowValue(ResTable.event_difficulty, tostring(id));
		if id < 5 then
			name1.Size = Size(80, 35);
			show2.Margin = Rect(140, 30, 0, 0);
		else
			name1.Size = Size(100, 35);
			show2.Margin = Rect(166, 30, 0, 0);
		end
		name1.Text = tostring(data['name']);
		o.ctrl.Tag = 6000+(id-1)*100+1;
		o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardEventPanel:onOpen');
		is_lock = false;
		cur.Background = CreateTextureBrush('card_event/card_event_level'..bg_index..'_cur.ccz', 'card_event');
		uncur.Background = CreateTextureBrush('card_event/card_event_level'..bg_index..'_uncur.ccz', 'card_event');
		lock.Visibility = Visibility.Hidden;
		uncur.Visibility = Visibility.Hidden;
		cur.Visibility = Visibility.Visible;
		num.Text = string.format('x%s', data['open_cost'] or 50);
		icon.Background = CreateTextureBrush(CardEventPanel.icon.pic, CardEventPanel.icon.dir)		
	end

	o.setLock = function(flag)
		if is_lock == flag then
			return;
		end
		if flag then
			o.ctrl:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardEventPanel:onOpen');
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardEventPanel:onLock');
			lock.Visibility = Visibility.Visible;
			uncur.Visibility = Visibility.Visible;
			cur.Visibility = Visibility.Hidden;
		else
			o.ctrl:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardEventPanel:onLock');
			o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardEventPanel:onOpen');
			lock.Visibility = Visibility.Hidden;
			uncur.Visibility = Visibility.Hidden;
			cur.Visibility = Visibility.Visible;
		end
		is_lock = flag;
	end
end
typeMethodList.chatRoleItemTemplate = function(o)
	local panel = o.ctrl:GetLogicChild('panel');
	local heamPanel = panel:GetLogicChild('headPanel');
	local roleName = panel:GetLogicChild('roleName');
	local tipLabel = panel:GetLogicChild('tipLabel');
	local roleLevel = panel:GetLogicChild('roleLevel');
	local tip = panel:GetLogicChild('tip');
	tipLabel.Visibility = Visibility.Hidden;
	o.ctrl.Selected = false;
	tip.Visibility = Visibility.Hidden;
	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end
	o.initWithInfo = function(uid, name, level,resid)
		--print('init-uid->'..tostring(uid)..' name->'..tostring(name)..' level->'..tostring(level)..' resid->'..tostring(resid));
		roleName.Text = tostring(name or '');
		roleLevel.Text = 'Lv.'..level or 0;
		local imageName = resTableManager:GetValue(ResTable.navi_main, tostring(resid), 'role_path_icon');
		if imageName then
			heamPanel.Image = GetPicture('navi/' .. imageName .. '.ccz');
		end
		o.ctrl.Tag = uid;
		--o.ctrl:SubscribeScriptedEvent('RadioButton::SelectedEvent','NewChatPanel:roleSelectedEvent');
		o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent','NewChatPanel:roleSelectedEvent');
	end
	o.setTipShow = function(isShow)
		tip.Visibility = isShow and Visibility.Visible or Visibility.Hidden;
	end
	o.setSelected = function(isSelected)
		o.ctrl.Selected = isSelected;
	end
end

typeMethodList.pubDetailRoleTemplate = function(o)
	local be_select = o.ctrl:GetLogicChild('speical');
	local role_img = o.ctrl:GetLogicChild('role_img');
	local pub_package = nil;
	
	o.init = function()
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithRoleId = function(role_id, state)
		role_img.Image = GetPicture('chouka/chouka_role_'..role_id..'.ccz');
		be_select.Visibility = Visibility.Hidden;
		if state == 4 then
			pub_package = 98;
		end
		if pub_package then
			for i=1, 999 do
				local role_id_pub = resTableManager:GetValue(ResTable.pub_special, tostring(pub_package*100+i), 'role_id');
				if not role_id_pub then
					break;
				end
				if role_id_pub == role_id then
					be_select.Visibility = Visibility.Visible;
					break;
				end
			end
		end
	end
end

typeMethodList.sweaponTemplate = function(o)
	local bg = o.ctrl:GetLogicChild('bg');
	local itemImage = o.ctrl:GetLogicChild('img');
	local iconUp = {};
	local iconDown = {};
	local cur_attribute = {};
	local label_attribute = {};
	for i=1, 5 do
		iconUp[i] = o.ctrl:GetLogicChild('up'..i);
		iconDown[i] = o.ctrl:GetLogicChild('down'..i);
		cur_attribute[i] = 0;
	end
	local fontColorUp = Color(184, 53, 53, 255);
	local fontColorDown = Color(64, 106, 242, 255);
	local fontColor =  Color(255, 255, 255, 255);
	label_attribute[1] = o.ctrl:GetLogicChild('label_atk');
	label_attribute[2] = o.ctrl:GetLogicChild('label_mgc');
	label_attribute[3] = o.ctrl:GetLogicChild('label_def');
	label_attribute[4] = o.ctrl:GetLogicChild('label_res');
	label_attribute[5] = o.ctrl:GetLogicChild('label_hp');
	
	o.init = function()
		bg.Background = CreateTextureBrush('home/sweapon_icon.ccz', 'home');
		for i=1, 5 do
			iconUp[i].Background = CreateTextureBrush('home/sweapon_arrow_up.ccz', 'home');
			iconDown[i].Background = CreateTextureBrush('home/sweapon_arrow_down.ccz', 'home');
		end
	end

	o.ctrlShow = function()
	end

	o.ctrlHide = function()
	end

	o.initWithInfo = function(cur_weapon, main_weapon)
		o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'SWeaponPanel:chooseWeapon');
		o.ctrl.Tag = cur_weapon.id;
		local itemWeaponData = resTableManager:GetRowValue(ResTable.item, tostring(cur_weapon.resid));
		itemImage.Image = GetPicture('icon/'..itemWeaponData['icon']..'.ccz');
		local attribute_c = {};
		for i=1, 5 do
			attribute_c[i] = 0;
		end
		if main_weapon then
			attribute_c[1] = main_weapon.atk_ori+main_weapon.atk;
			attribute_c[2] = main_weapon.mgc_ori+main_weapon.mgc;
			attribute_c[3] = main_weapon.def_ori+main_weapon.def;
			attribute_c[4] = main_weapon.res_ori+main_weapon.res;
			attribute_c[5] = main_weapon.hp_ori+main_weapon.hp;
		end

		cur_attribute[1] = cur_weapon.atk_ori+cur_weapon.atk;
		cur_attribute[2] = cur_weapon.mgc_ori+cur_weapon.mgc;
		cur_attribute[3] = cur_weapon.def_ori+cur_weapon.def;
		cur_attribute[4] = cur_weapon.res_ori+cur_weapon.res;
		cur_attribute[5] = cur_weapon.hp_ori+cur_weapon.hp;

		for i=1, 5 do
			iconUp[i].Visibility = Visibility.Hidden;
			iconDown[i].Visibility = Visibility.Hidden;
			if cur_attribute[i] > attribute_c[i] then
				iconUp[i].Visibility = Visibility.Visible;
				label_attribute[i].Text = '+'..tostring(cur_attribute[i]-attribute_c[i]);
				label_attribute[i].TextColor = QuadColor(fontColorUp);
			elseif cur_attribute[i] < attribute_c[i] then
				iconDown[i].Visibility = Visibility.Visible;
				label_attribute[i].Text = '-'..tostring(attribute_c[i]-cur_attribute[i]);
				label_attribute[i].TextColor = QuadColor(fontColorDown);
			else
				label_attribute[i].Text = '+0';
				label_attribute[i].TextColor = QuadColor(fontColor);
			end
		end
	end

	o.update = function(main_weapon)
		local attribute_c = {};
		for i=1, 5 do
			attribute_c[i] = 0;
		end
		if main_weapon then
			attribute_c[1] = main_weapon.atk_ori+main_weapon.atk;
			attribute_c[2] = main_weapon.mgc_ori+main_weapon.mgc;
			attribute_c[3] = main_weapon.def_ori+main_weapon.def;
			attribute_c[4] = main_weapon.res_ori+main_weapon.res;
			attribute_c[5] = main_weapon.hp_ori+main_weapon.hp;
		end

		for i=1, 5 do
			iconUp[i].Visibility = Visibility.Hidden;
			iconDown[i].Visibility = Visibility.Hidden;
			if cur_attribute[i] > attribute_c[i] then
				iconUp[i].Visibility = Visibility.Visible;
				label_attribute[i].Text = '+'..tostring(cur_attribute[i]-attribute_c[i]);
				label_attribute[i].TextColor = QuadColor(fontColorUp);
			elseif cur_attribute[i] < attribute_c[i] then
				iconDown[i].Visibility = Visibility.Visible;
				label_attribute[i].Text = '-'..tostring(attribute_c[i]-cur_attribute[i]);
				label_attribute[i].TextColor = QuadColor(fontColorDown);
			else
				label_attribute[i].Text = '+0';
				label_attribute[i].TextColor = QuadColor(fontColor);
			end
		end
	end
end

--自定义控件名-方法集
--[[
typeMethodList = 
{
	TaskTemplate         = typeMethodList.taskFun;
	buttonTemplate       = typeMethodList.buttonFun;
	cardMidTemplate      = typeMethodList.cardmidFun;
	clickLabel           = typeMethodList.cLabelFun;
	UpgreadeTemplate     = typeMethodList.eatExpFun;
	--gemItemTemplate      = gemItemFun;
	gemSystemTemplate    = gemItemFun;
	gemSystemInfoTemplate = gemRoleFun;
	cardPropertyTemplate  = cardProperFun;
	gemMosTemplate       = gemMosFun;
	UpStar_BottomBgTemplate = initPropertyInfo;  --初始化培养 升星 底框
	gradeInfoTemplate    = gradeInfoFun;
	lovePhaseTemplate    = lovePhaseFun;
	memberRETemplate     = memberREFun;
	memberResultTemplate = memberRewardFun;
	midCardTemplate      = midCardFun;
	naviTemplate         = naviFun;
	rewardTemplate       = rewardFun;
	HomeIconTemplate     = homeFun;
	smallItemTemplate    = taskRewardItemFun;
	teamTemplate		 = teamFun;
	guildSkillTemplate   = guildSkillFun;
	arenaResultTemplate	 = arenaRecordFun;
	PrestigeShopTemplate = prestigeShopFun;
	ChipShopTemplate 	 = chipShopFun;
	meritoriousTemplate  = meritoriousFun;
	FriendFlowerTemplate = friendInfoFun;
	teamInfoTemplate	 = headInfoFun;
	RankingTemplate		 = rankFun;
	RankingRenQiTemplate = rankspecialFun;
	flowerTemplate		 = flowerFun;
	FriendInfoTemplate   = friendApplyFun;
	NewWeekTemplate = weekFun;
	rightChatTemplate	 = rightChatFun;
	leftChatTemplate	 = leftChatFun;
	SysChatTemplate		 = sysChatFun;
	TeamSelectTemplate	 = roleTeamFun;
	propertyRoundTemplate = propertyRoundFun;
	treasureItemTemplate = treasureItemFun;
	treasureRevengeTemplate = treasureRevengeFun;
	treasureReportTemplate = treasureReportFun;
	FBCommonTemplate	 = FBcommonFun;
	homeInfoTemplate	 = homeInfoFun;
	expeditionRoundTemplate = expeditionRoundFun;
	expeditionRewardTemplate = expeditionRewardFun;
	itemIconNameTemplate = itemIconNameFun;
	npcgoodTemplate = shopGoodsFun;
	worldMapTemplate	= worldmapFun;
	noRewardSweepTemplate = noRewardSweepFun;
	rewardSweepTemplate  = rewardSweepFun;
	itemTemplate		= itemFun;
	WelfareTemplate		= WelfareFun;
	cardHeadTemplate	= cardHeadFun;
	unionSkillTemplate	= unionSkillFun;
	selectLvTemplate	= selectLvFun;
	wingTemplate		= wingFun;
	achievement_task	= achievementFun;
	runeHuntNewsTemplate = runeHuntNewsFun;
	runeInfoTemplate	= runeInfoFun;
	runeInlayTemplate	= runeInlayFun;
	runeCheckPageTemplate = runeCheckPageFun;
	runeAttributeInfoTemplate = runeAIFun;
	runeAttributeTemplate = runeAFun;
	unionBattleSacrificeItemTemplate = gbsItemFun;
	pubBtnTemplate = pubBtnFun;
	stepupBtnTemplate = stepupBtnFun;
}
-]]
--============================================================================
customUserControl = class();

--构造函数
function customUserControl:constructor(father, typeid, name)
	--self.name = name;
	self.typeid = typeid;
	self.father = father;
	if not father then
		print("Error! customUserControl: father not exsit! the typeid is " .. tostring(typeid));
		print("---------------trace begin-----------------");
		print(debug.traceback());
		print("---------------trace end-------------------");
		return;
	end
	if name then
		self.child = UserControl(father:GetLogicChild(name)); 
	else
		self.child = uiSystem:CreateControl(typeid);
		father:AddChild(self.child);
	end
	if not self.child then
		print("Error! create control fail! typeid = " .. tostring(typeid));
		print("---------------trace begin-----------------");
		print(debug.traceback());
		print("---------------trace end-------------------");
		return;
	end
	self.ctrl = self.child:GetLogicChild(0); 	
	typeMethodList[typeid](self);
	self.init();

	return self;
end

function customUserControl:destructor()
	if self.destroy then
		self.destroy();
	end	
end

--公用方法
function customUserControl:Show()
	self.ctrl.Visibility = Visibility.Visible;
	self.ctrlShow();
end

function customUserControl:Hide()
	self.ctrl.Visibility = Visibility.Hidden;
	self.ctrlHide();
end

function customUserControl:BeRemoved() 
	self.father:RemoveChild(self.child);
end

function customUserControl:getControl()
	return self.ctrl;
end
