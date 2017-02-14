--cardProperty.lua

--========================================================================
--领取累积登录礼包界面

cardPropertyPanel =
	{
	};

--控件
local mainDesktop;
local roleInfo;
local recordRoleProperInfo;
local roleLevel;
local roleName;
local nickname;
local bottomLeftList;
local bottomRightList;
local leftList;
local rightList;
local middleInfoList;
local nameLabelList;
local aptitudeLabel;
local panel;
--初始化面板
function cardPropertyPanel:InitPanel(desktop)
	--界面初始化
	mainDesktop = desktop;
	cardProperPanel = Panel(mainDesktop:GetLogicChild('cardPropertyPanel'));
	cardProperPanel.ZOrder = PanelZOrder.xinghun;
	cardProperPanel:IncRefCount();
    local topBg = cardProperPanel:GetLogicChild('topBg');
    roleLevel   = topBg:GetLogicChild('LevelLabel'); -- 修改需求为角色编号 而不是角色等级 名字暂用
    roleName    = topBg:GetLogicChild('NameLabel');
    nickname    = topBg:GetLogicChild('nickLabel');
    panel = cardProperPanel:GetLogicChild('panel');
    leftList    = panel:GetLogicChild('2'):GetLogicChild('LeftListClip'):GetLogicChild('List');
    rightList   = panel:GetLogicChild('2'):GetLogicChild('RightListClip'):GetLogicChild('List');
    rightList.CanVScroll = false;
    
    local quotations = panel:GetLogicChild('1'):GetLogicChild('quotations');     --角色介绍Label
    local weapons = panel:GetLogicChild('1'):GetLogicChild('weapons');           --武器介绍
    --local story = panel:GetLogicChild('1'):GetLogicChild('story');               --经典语录
    --nameLabelList = {'キャラ紹介', '元武器紹介', '  趣味            '};
    nameLabelList = {'キャラ紹介', '  趣味            '};
    middleInfoList = {quotations, weapons};  
    local close = cardProperPanel:GetLogicChild('close');
    close:SubscribeScriptedEvent('Button::ClickEvent', 'cardPropertyPanel:Hide');
    cardProperPanel.Visibility = Visibility.Hidden;	
	  self.isShow = false; 
	  
	--资质
	aptitudeLabel = panel:GetLogicChild('2'):GetLogicChild('aptitudePanel'):GetLogicChild('aptitudeLabel');
end	
--显示
function cardPropertyPanel:Show(roleresid, roleinfo)
	local resid = roleresid;
	roleInfo = roleinfo;
	if resid == 0 then
		resid = ActorManager.user_data.role.resid;
	end
	rightList:RemoveAllChildren();
	leftList:RemoveAllChildren();
	local dataInfo = resTableManager:GetValue(ResTable.actor, tostring(resid), {'cdescription','wdescription','petphrase'});           --角色介绍  武器介绍 经典语录
	local bottomDataInfo = resTableManager:GetValue(ResTable.actor, tostring(resid), {'birthday','BWH','Blood_type', 'Height', 'hobby'});  --生日 BWH 血型 身高 爱好
  local roleNickname = resTableManager:GetValue(ResTable.actor, tostring(resid),'Nickname');
	local name = resTableManager:GetValue(ResTable.actor, tostring(resid),'name');
  local roleTitle = resTableManager:GetValue(ResTable.actor, tostring(resid),'title');  
	local roleOrder = resTableManager:GetValue(ResTable.actor, tostring(resid),'Order'); 
	local roleAptitude = resTableManager:GetValue(ResTable.actor, tostring(resid),'Quality');
	aptitudeLabel.Text = tostring(roleAptitude);
	if roleOrder == 0 then
		roleLevel.Text = '    ';
	else
		roleLevel.Text = 'N0.'.. tostring(roleOrder);
	end
    if roleTitle then
      if string.sub(roleTitle,1,1) == '?' then
        tRoleTitle = string.sub(roleTitle,2);
        roleTitle  = '·'..tRoleTitle;
      end
      roleName.Text = tostring(name..roleTitle);
    else
      roleName.Text = tostring(name);
    end
    nickname.Text = tostring(roleNickname);
    middleList = {
       tostring(dataInfo['cdescription']),
       tostring(dataInfo['wdescription']),
       tostring(dataInfo['petphrase']),
    };  
    bottomLeftList = {
       tostring(bottomDataInfo['birthday']),
       tostring(bottomDataInfo['BWH']),
       tostring(bottomDataInfo['Blood_type']),
       tonumber(bottomDataInfo['Height']),
       tostring(bottomDataInfo['hobby']),
    };

    bottomRightList = {                       --生命 物攻 技攻 物防 技防  
       tonumber(roleInfo.pro.atk),
       tonumber(roleInfo.pro.mgc),
       tonumber(roleInfo.pro.def),
       tonumber(roleInfo.pro.res),
       tonumber(roleInfo.pro.hp),
    };
   self.isShow = true; 
   CardDetailPanel:HideSelfPanel().Visibility = Visibility.Hidden;
   cardProperPanel.Visibility = Visibility.Visible;
   self:Refresh();
	--StoryBoard:ShowUIStoryBoard(loginRewardGetPanel, StoryBoardType.ShowUI1);
end
--隐藏
function cardPropertyPanel:Hide()
	--取消模式对话框
	self.isShow = false; 
  CardDetailPanel:HideSelfPanel().Visibility = Visibility.Visible;
	cardProperPanel.Visibility = Visibility.Hidden;	
  if  HomePanel:rolePanelInfo() then HomePanel:ListClick() end
end	

function cardPropertyPanel:IsShow()
  return self.isShow;
end

--销毁
function cardPropertyPanel:Destroy()
	cardProperPanel:DecRefCount();
	cardProperPanel = nil;
end	

function cardPropertyPanel:Refresh()
  middleInfoList[1].Text = nameLabelList[1]..'   '..middleList[1];
  middleInfoList[2].Text = nameLabelList[2]..'   '..bottomLeftList[5];
	for i = 1, 5 do 
    --[[
	  if(i <= 3) then
        if i < 3 then
          middleInfoList[i].Text = nameLabelList[i]..'   '..middleList[i];
        else
          middleInfoList[i].Text = nameLabelList[i]..'   '..bottomLeftList[5];
        end
	  end
    ]]
    if i < 5 then
      local LeftInfo = customUserControl.new(leftList, 'cardPropertyTemplate');
      LeftInfo.initLeft(i, bottomLeftList[i]);
    end
    local RightInfo = customUserControl.new(rightList, 'cardPropertyTemplate');
    RightInfo.initRight(i, bottomRightList[i]);
	end
end

