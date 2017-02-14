--xinghunPanel.lua
--==============================================
--星魂界面
--

XinghunPanel = 
{
  IsVisible = false;
  beforeColor = 0;
  afterColor = 0;
  btnTag = 0;
  isRefreshServeral = false;
};

local materialIds = 
{
  19001,
  19002,
  19003,
  19004,
  19005,
}

local getState = 
{
  item = 1,
  coin = 2,
  none = 3,
}

--变量
local currentRoleId;
local currentRole;
local currentStarStatus = {};
local starsList = {};					--以pos为基准的星位列表
local ranLabelColorTabel;
--控件
local mainDesktop;
local panel;
------------------------------------------------------
local topPanelList = {};
local panelList = {};
local topBallNum = {};   --（hp 物防 技攻  技防 物攻）Num

local panelOneOfCircleList = {};
local panelOneOfBottomCircleList = {};
local panelTwoOfCircleList = {};
local panelTwoOfBottomCircleList = {};
local panelThreeOfCircleList = {};
local panelThreeOfBottomCircleList = {};
local panelFourOfCircleList = {};
local panelFourOfBottomCircleList = {};
local panelFiveOfCircleList = {};
local panelFiveOfBottomCircleList = {};

local panelAllLabelList = {};      --Panel 1 组件
local PopPanelTabel;
local PopPanel;
local resumLabel;
local iconTable;
local iconBottomTable;
local paneltype;
local allsuoImage = {};
local typeList;
local typeTagList = {};
local recordPopstate = false;
local isMaterialNotEnough = false

local checkBoxList = {};
local tipList = {};
local selectList = {}; 

function XinghunPanel:InitPanel(desktop)
  --变量初始化
  self.beforeColor = 0;
  self.afterColor = 0;
  self.btnTag = 0;
  self.isRefreshServeral = false;
  self.refreshCount = 0;
  --控件初始化
  mainDesktop = desktop;
  panel = desktop:GetLogicChild('TalentPanel');
  panel.ZOrder = PanelZOrder.xinghun;
  panel:IncRefCount();
  local topPanel = panel:GetLogicChild('TopPanel');
  iconTable = {'home_star0', 'home_star1', 'home_star4', 'home_star3', 'home_star2' };
  iconBottomTable = {'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang1.ccz', 'cardRelated/home_kuang4.ccz', 'cardRelated/home_kuang3.ccz','cardRelated/home_kuang2.ccz' };
  topPanel:GetLogicChild('bottombg1').Background = CreateTextureBrush('home/home_cardlist_duanlian_bg_2.ccz','godsSenki');
  self.secondSurePanel = panel:GetLogicChild('secondSurePanel');
  self.secondSurePanel.Visibility = Visibility.Hidden;
  self.secondCancelBtn = self.secondSurePanel:GetLogicChild('canelBtn');
  self.secondCancelBtn:SubscribeScriptedEvent('Button::ClickEvent', 'XinghunPanel:onSecondRefresh');
  self.secondSureBtn = self.secondSurePanel:GetLogicChild('confirmBtn');
  self.secondSureBtn:SubscribeScriptedEvent('Button::ClickEvent', 'XinghunPanel:onChangeProperty');

  local popPanel1 = panel:GetLogicChild('popPanel1');
  local taperedImage = panel:GetLogicChild('taperedImage');
  local popPanel2 = panel:GetLogicChild('popPanel2');
  local popPanel3 = panel:GetLogicChild('popPanel3');
  local popPanel4 = panel:GetLogicChild('popPanel4');

  for i =2,4 do
    checkBoxList[i] = panel:GetLogicChild('popPanel' .. i):GetLogicChild('checkBox');
    checkBoxList[i].Tag = i;
    checkBoxList[i]:SubscribeScriptedEvent('CheckBox::CheckChangedEvent', 'XinghunPanel:onCheckBoxChanged');
    tipList[i] = panel:GetLogicChild('popPanel' .. i):GetLogicChild('tip');
    selectList[i] = checkBoxList[i]:GetLogicChild('select');
	tipList[i].Text = LANG_XINGHUN_1;
    tipList[i].Visibility = Visibility.Hidden;
    checkBoxList[i].Visibility = Visibility.Hidden;
    selectList[i].Visibility = Visibility.Hidden;
  end
  -- 适配
  if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
    local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
    for i = 1, 4 do
      panel:GetLogicChild('popPanel' .. i).Translate = Vector2(518*(1-factor),0);
    end
  end

  resumLabel = popPanel4:GetLogicChild('resumnum');
  PopPanelTabel = {popPanel1, popPanel2, popPanel3, popPanel4};
  ranLabelColorTabel = {QualityColor[1], QualityColor[2], QualityColor[3], QualityColor[4], QualityColor[5], QualityColor[7]};  
  for i = 1, 5 do
    panelList[i] = panel:GetLogicChild('Panel' .. tostring(i));  --Panel1 ~ panel5
    if i == 1 then
        panelList[i].Background = CreateTextureBrush('home/home_cardlist_upgrade_item_bg.ccz','godsSenki');
    else
        panelList[i].Background = CreateTextureBrush('home/home_cardlist_duanlian_bg_1.ccz','godsSenki');
    end
  end
  local function initPanel(i)
    if(i <= 2) then
      topPanelList[i] = topPanel:GetLogicChild('bottombg1'.. tostring(i));
      panelAllLabelList[i + 4] = panelList[2]:GetLogicChild('Label'.. tostring(i));
      panelTwoOfCircleList[i] = panelList[2]:GetLogicChild('circle'.. tostring(i));               --Panel2的组件
      panelTwoOfBottomCircleList[i] = panelList[2]:GetLogicChild('circleBottom'.. tostring(i));
      panelAllLabelList[i + 6] = panelList[3]:GetLogicChild('Label'.. tostring(i));
      panelThreeOfBottomCircleList[i] = panelList[3]:GetLogicChild('circleBottom'.. tostring(i));   --panel3的组件
      panelThreeOfCircleList[i] = panelList[3]:GetLogicChild('circle'.. tostring(i));              
      panelAllLabelList[i + 8] = panelList[4]:GetLogicChild('Label'.. tostring(i));
      panelFourOfCircleList[i] = panelList[4]:GetLogicChild('circle'.. tostring(i));               --panel4的组件
      panelFourOfBottomCircleList[i] = panelList[4]:GetLogicChild('circleBottom'.. tostring(i));
      panelAllLabelList[i + 10] = panelList[5]:GetLogicChild('Label'.. tostring(i));
      panelFiveOfCircleList[i] = panelList[5]:GetLogicChild('circle'.. tostring(i));               --panel5的组件    
      panelFiveOfBottomCircleList[i] = panelList[5]:GetLogicChild('circleBottom'.. tostring(i));
    end
  end
  for i = 1, 5 do	
    topBallNum[i] =  topPanel:GetLogicChild('bottombg1'):GetLogicChild('num'.. tostring(i));                                                                   --加载各个组件  
    if(i <= 4) then                                                                    --panel1的组件
      panelAllLabelList[i] = panelList[1]:GetLogicChild('Label'.. tostring(i));       
      panelOneOfCircleList[i] = panelList[1]:GetLogicChild('circle'.. tostring(i))  
      panelOneOfBottomCircleList[i] = panelList[1]:GetLogicChild('circleBottom'.. tostring(i));
    end
    if(i <= 2) then    
      initPanel(i); 
    end  
  end
  PopPanel = {                                                                          --这个是点击星魂时候的弹框组件 
  setVisible = function(tag)
  local oldRefreshstate = self.isRefreshServeral;
    for i = 1, 4 do
      PopPanelTabel[i].Visibility = Visibility.Hidden;
	  if i ~= 1 then
        PopPanelTabel[i]:GetLogicChild('checkBox').Checked = false;
        PopPanelTabel[i]:GetLogicChild('checkBox'):GetLogicChild('select').Visibility = Visibility.Hidden;
      end
    end
    paneltype = PopPanelTabel[tag];
	if oldRefreshstate then
        self.isRefreshServeral = true;
    end
    PopPanelTabel[tag].Visibility = Visibility.Visible;
    paneltype:GetLogicChild('canelBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'XinghunPanel:closePop');
    if(tag ==3 or tag == 4) then
      --    uiSystem:Bind(DDXTYPE.DDX_STRING, ActorManager.user_data, 'rmb', paneltype:GetLogicChild('resumnum'), 'Text');          --绑定姓名
    end
  end,
  setPopPanel4Btn = function(isPick)
    PopPanelTabel[4]:GetLogicChild('refreshBtn').Pick = isPick;
    PopPanelTabel[4]:GetLogicChild('canelBtn').Pick = isPick;
	PopPanelTabel[4]:GetLogicChild('checkBox').Enable = isPick;
  end,
  setPopPanel4 = function(diamondNum, beforeProperty, propertyValue)
    --判断vip等级是否大于等于11
    if ActorManager.user_data.viplevel >= 11 then
      checkBoxList[4].Visibility = Visibility.Visible;
      tipList[4].Visibility = Visibility.Visible;
    else
      checkBoxList[4].Visibility = Visibility.Hidden;
      tipList[4].Visibility = Visibility.Hidden;
    end
    if self.isRefreshServeral then
        checkBoxList[4].Checked = true;
        selectList[4].Visibility = Visibility.Visible;
    else
        selectList[4].Visibility = Visibility.Hidden;
    end
    paneltype:GetLogicChild('resumLabel').Text = string.format(LANG_XINGHUN_ZUANSHI, diamondNum);
    local id = materialIds[self.lv];
    local propername = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(id), 'name');
    local qualitynum = resTableManager:GetValue(ResTable.item, tostring(id), 'quality');
    -- paneltype:GetLogicChild('resumLabels').TextColor = ranLabelColorTabel[qualitynum];
    paneltype:GetLogicChild('resumLabels').Text = propername;
    --paneltype:GetLogicChild('propenot').TextColor =  ranLabelColorTabel[qualitynum];
    paneltype:GetLogicChild('tips').Text = propername..'不足';
    paneltype:GetLogicChild('resumnum').Text = 'X'..' '..tostring(ActorManager.user_data.rmb);
    paneltype:GetLogicChild('beforeProperLabel').Text = "暂无属性";
    paneltype:GetLogicChild('newProperLabel').Text = "個性付与";
    paneltype:GetLogicChild('icon').Image = GetPicture('recharge/GuildWelfare_gem.ccz'); 
    paneltype:GetLogicChild('refreshBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'XinghunPanel:refreshBtnClick');

    if beforeProperty then
      paneltype:GetLogicChild('beforeProperLabel').Text = tostring(beforeProperty);
      paneltype:GetLogicChild('beforeProperLabel').TextColor = ranLabelColorTabel[self:confirmQualityColor(self.lv, self.att, self.value )];
    else
      paneltype:GetLogicChild('beforeProperLabel').TextColor = ranLabelColorTabel[self:confirmQualityColor(self.lv, self.att, self.value )];
    end
    if propertyValue then
      paneltype:GetLogicChild('beforeProperNum').Text = tostring(propertyValue);
      paneltype:GetLogicChild('beforeProperNum').Visibility = Visibility.Visible;
    else
      paneltype:GetLogicChild('beforeProperNum').Visibility = Visibility.Hidden;
    end
  end,
  setPopPanel3Btn = function(isPick)
    PopPanelTabel[3]:GetLogicChild('confirmBtn').Pick = isPick;
    PopPanelTabel[3]:GetLogicChild('canelBtn').Pick = isPick;
    PopPanelTabel[3]:GetLogicChild('replaceBtn').Pick = isPick;
	PopPanelTabel[3]:GetLogicChild('checkBox').Enable = isPick;
  end,
  setPopPanel3 = function(diamondNum)
    if ActorManager.user_data.viplevel >= 11 then
      checkBoxList[3].Visibility = Visibility.Visible;
      tipList[3].Visibility = Visibility.Visible;
    else
      checkBoxList[3].Visibility = Visibility.Hidden;
      tipList[3].Visibility = Visibility.Hidden;
    end
     if self.isRefreshServeral then
        checkBoxList[3].Checked = true;
        selectList[3].Visibility = Visibility.Visible;
    else
        selectList[3].Visibility = Visibility.Hidden;
    end 
    paneltype:GetLogicChild('resumnum').Text = 'x'..' '..tostring(ActorManager.user_data.rmb);
    paneltype:GetLogicChild('resumLabel1').Text = string.format(LANG_XINGHUN_ZUANSHI, diamondNum);
    paneltype:GetLogicChild('newProperLabel').Text = XinghunAtt[self.att]; 

    paneltype:GetLogicChild('newProperLabel').TextColor = ranLabelColorTabel[self:confirmQualityColor(self.lv, self.att, self.value )];
    paneltype:GetLogicChild('beforeNormalLabel').TextColor = ranLabelColorTabel[self:confirmQualityColor(currentStarStatus.lv, currentStarStatus.att, currentStarStatus.value)];

    paneltype:GetLogicChild('newProperNum').Text = tostring(self.value);
    paneltype:GetLogicChild('beforeNormalLabel').Text = XinghunAtt[currentStarStatus.att];
    paneltype:GetLogicChild('beforeProperNum').Text =  tostring(currentStarStatus.value);
    local id = materialIds[self.lv];
    local propername = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(id), 'name');
    local qualitynum = resTableManager:GetValue(ResTable.item, tostring(id), 'quality');
    paneltype:GetLogicChild('tips').Text = propername..'不足';
    paneltype:GetLogicChild('resumLabels').Text = propername;
    paneltype:GetLogicChild('icon').Image = GetPicture('recharge/GuildWelfare_gem.ccz');
	paneltype:GetLogicChild('replaceBtn').Visibility = Visibility.Visible;
    paneltype:GetLogicChild('replaceBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'XinghunPanel:onReplace');   
    paneltype:GetLogicChild('confirmBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'XinghunPanel:refreshBtnClick');
    -- if(not tagState) then  
    paneltype:GetLogicChild('replaceBtn').Visibility = Visibility.Visible;
    --end 
  end,
   setPopPanel2Btn = function(isPick)
    PopPanelTabel[2]:GetLogicChild('confirmBtn').Pick = isPick;
    PopPanelTabel[2]:GetLogicChild('canelBtn').Pick = isPick;
    PopPanelTabel[2]:GetLogicChild('replaceBtn').Pick = isPick;
	PopPanelTabel[2]:GetLogicChild('checkBox').Enable = isPick;
  end,
  setPopPanel2 = function(newPropLabel, tagState)
    if ActorManager.user_data.viplevel >= 11 then
      checkBoxList[2].Visibility = Visibility.Visible;
      tipList[2].Visibility = Visibility.Visible;
    else
      checkBoxList[2].Visibility = Visibility.Hidden;
      tipList[2].Visibility = Visibility.Hidden;
    end	
    if self.isRefreshServeral then
        checkBoxList[2].Checked = true;
        selectList[2].Visibility = Visibility.Visible;
    else
        selectList[2].Visibility = Visibility.Hidden;
    end	

    paneltype:GetLogicChild('resumnum').Text = 'X'.. ' '..tostring(topBallNum[self.lv].Text);
    paneltype:GetLogicChild('newProperLabel').Text = newPropLabel;
    paneltype:GetLogicChild('newProperNum').Text = tostring(self.value);
    local id = materialIds[self.lv];
    local propername = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(id), 'name');
    local qualitynum = resTableManager:GetValue(ResTable.item, tostring(id), 'quality');
    paneltype:GetLogicChild('icon').Image = GetPicture('cardRelated/'..iconTable[self.lv] .. '.ccz');
    paneltype:GetLogicChild('replaceBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'XinghunPanel:onReplace');      
    paneltype:GetLogicChild('confirmBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'XinghunPanel:refreshBtnClick');
    --paneltype:GetLogicChild('resumLabels').TextColor = ranLabelColorTabel[qualitynum];
    if(tagState) then                   
      paneltype:GetLogicChild('newProperNum').Text = '';	 
      paneltype:GetLogicChild('newProperLabel').TextColor = Configuration.WhiteColor;
    else                 
      paneltype:GetLogicChild('newProperLabel').TextColor = ranLabelColorTabel[self:confirmQualityColor(self.lv, self.att, self.value )];            
    end
    paneltype:GetLogicChild('resumLabels').Text = propername;
    if(self.att and self.value ~= 0 and tagState) then
      paneltype:GetLogicChild('replaceBtn').Visibility = Visibility.Hidden;		 
      paneltype:GetLogicChild('beforeNormalLabel').Text = XinghunAtt[self.att]; 
      paneltype:GetLogicChild('beforeNormalLabel').TextColor = ranLabelColorTabel[self:confirmQualityColor(self.lv, self.att, self.value)];
      paneltype:GetLogicChild('beforeProperNum').Text = tostring(self.value);
    end		
    if(not tagState) then  
      paneltype:GetLogicChild('replaceBtn').Visibility = Visibility.Visible;
    end	
  end,
  setRplacePanel2 = function ( replaceTag)
    if(replaceTag) then   --替换
      paneltype:GetLogicChild('newProperLabel').Text = XinghunAtt[currentStarStatus.att]; 
      paneltype:GetLogicChild('newProperNum').Text = tostring(currentStarStatus.value); 
      paneltype:GetLogicChild('newProperLabel').TextColor = ranLabelColorTabel[currentStarStatus.lv];
      paneltype:GetLogicChild('beforeNormalLabel').Text = XinghunAtt[self.lv];
      paneltype:GetLogicChild('beforeNormalLabel').TextColor = ranLabelColorTabel[self:confirmQualityColor(self.lv, self.att, self.value )];
      paneltype:GetLogicChild('beforeProperNum').Text = tostring(self.value);
    end
  end,
  setPopPanel1 = function()
    local id = materialIds[self.lv];
    local propername = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(id), 'name');
    local qualitynum = resTableManager:GetValue(ResTable.item, tostring(id), 'quality');
    --paneltype:GetLogicChild('resumLabels').TextColor = ranLabelColorTabel[qualitynum];
    paneltype:GetLogicChild('resumLabels').Text = propername;
    paneltype:GetLogicChild('resumnum').Text = 'X'..' '..tostring(topBallNum[self.lv].Text);
    paneltype:GetLogicChild('newProperLabel').Text = "個性付与";
    paneltype:GetLogicChild('newProperNum').Text = "???";
    paneltype:GetLogicChild('icon').Image = GetPicture('cardRelated/'..iconTable[self.lv] .. '.ccz');       
    paneltype:GetLogicChild('confirmBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'XinghunPanel:conFirmClick');
  end,
}
self.isShow = false; 
panel.Visibility = Visibility.Hidden;
end

function XinghunPanel:IsShow()
	return panel.Visibility == Visibility.Visible;
end

--销毁
function XinghunPanel:Destroy()
  panel:DecRefCount();
  panel = nil;
end

function XinghunPanel:onCheckBoxChanged(Args)
  local args = UIControlEventArgs(Args);
  local index = args.m_pControl.Tag;
  self.isRefreshServeral = checkBoxList[index].Checked;
  if checkBoxList[index].Checked then
    selectList[index].Visibility = Visibility.Visible;
  else
    selectList[index].Visibility = Visibility.Hidden;
  end
end

--显示
function XinghunPanel:Show(role_id, roleinfo)
  currentRoleId = role_id or 1;
  --刷新界面信息
  self:addImage();
  currentRole = roleinfo;
  panel:SetUIStoryBoard("storyboard.showUIBoard2"); 
  self:refresh();
  panel.Visibility = Visibility.Visible;
  self.isShow = true; 
  IsVisible = true;
  if UserGuidePanel:IsInGuidence(UserGuideIndex.talent, 1) then
	timerManager:CreateTimer(0.2, 'XinghunPanel:GetCircleBtn', 0, true);
  end
end

function XinghunPanel:GetCircleBtn()
	UserGuidePanel:ShowGuideShade( panelList[1]:GetLogicChild('circle1'),GuideEffectType.hand,GuideTipPos.right,'');
end


function XinghunPanel:addImage()
  typeList =  {[1] = {'cardRelated/home_star0.ccz',  'cardRelated/home_star0.ccz', 'cardRelated/home_star0.ccz', 'cardRelated/home_star1.ccz'},
  [2] = {'cardRelated/home_star0.ccz',  'cardRelated/home_star0.ccz', 'cardRelated/home_star0.ccz', 'cardRelated/home_star1.ccz', 'cardRelated/home_star1.ccz',  'cardRelated/home_star4.ccz'},
  [3] = {'cardRelated/home_star0.ccz',  'cardRelated/home_star0.ccz', 'cardRelated/home_star0.ccz', 'cardRelated/home_star1.ccz', 'cardRelated/home_star1.ccz',  'cardRelated/home_star4.ccz','cardRelated/home_star4.ccz',  'cardRelated/home_star3.ccz'},
  [4] = {'cardRelated/home_star0.ccz',  'cardRelated/home_star0.ccz', 'cardRelated/home_star0.ccz', 'cardRelated/home_star1.ccz', 'cardRelated/home_star1.ccz',  'cardRelated/home_star4.ccz','cardRelated/home_star4.ccz',  'cardRelated/home_star3.ccz', 'cardRelated/home_star1.ccz',  'cardRelated/home_star2.ccz'},
  [5] = {'cardRelated/home_star0.ccz',  'cardRelated/home_star0.ccz', 'cardRelated/home_star0.ccz', 'cardRelated/home_star1.ccz', 'cardRelated/home_star1.ccz',  'cardRelated/home_star4.ccz','cardRelated/home_star4.ccz',  'cardRelated/home_star3.ccz', 'cardRelated/home_star1.ccz',  'cardRelated/home_star2.ccz', 'cardRelated/home_star3.ccz',  'cardRelated/home_star2.ccz'}}; 

  iconBottomTable = {[1] = {'cardRelated/home_kuang0.ccz',  'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang1.ccz'},
  [2] = {'cardRelated/home_kuang0.ccz',  'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang1.ccz', 'cardRelated/home_kuang1.ccz',  'cardRelated/home_kuang4.ccz'},
  [3] = {'cardRelated/home_kuang0.ccz',  'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang1.ccz', 'cardRelated/home_kuang1.ccz',  'cardRelated/home_kuang4.ccz','cardRelated/home_kuang4.ccz',  'cardRelated/home_kuang3.ccz'},
  [4] = {'cardRelated/home_kuang0.ccz',  'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang1.ccz', 'cardRelated/home_kuang1.ccz',  'cardRelated/home_kuang4.ccz','cardRelated/home_kuang4.ccz',  'cardRelated/home_kuang3.ccz', 'cardRelated/home_kuang1.ccz',  'cardRelated/home_kuang2.ccz'},
  [5] = {'cardRelated/home_kuang0.ccz',  'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang0.ccz', 'cardRelated/home_kuang1.ccz', 'cardRelated/home_kuang1.ccz',  'cardRelated/home_kuang4.ccz','cardRelated/home_kuang4.ccz',  'cardRelated/home_kuang3.ccz', 'cardRelated/home_kuang1.ccz',  'cardRelated/home_kuang2.ccz', 'cardRelated/home_kuang3.ccz',  'cardRelated/home_kuang2.ccz'}}; 


  typeTagList = {[1] = {1, 1, 1, 2}, 
  [2] = {1, 1, 1, 2, 2, 3},
  [3] = {1, 1, 1, 2, 2, 3, 3, 4},
  [4] = {1, 1, 1, 2, 2, 3, 3, 4, 2, 5},
  [5] = {1, 1, 1, 2, 2, 3, 3, 4, 2, 5, 4, 5}};
end

function XinghunPanel:DestroyImage( )
  typeTagList = nil;
  iconBottomTable = nil;
  typeList = nil;
end

--刷新界面信息
function XinghunPanel:refresh()
  self:refreshStarList();
  self:refreshImage();
  self:refreshStarNum();
end

function XinghunPanel:refreshStarList()
  local rank = currentRole.rank;
  --	local typeList = resTableManager:GetValue(ResTable.star_map, tostring(rank), 'type');
  self:refreshImageOnce(false);
  for i = 1, #starsList do
    starsList[i] = nil;
  end
  for i = 1, #typeList[rank] do
    for j=1, #currentRole.stars do	
      if currentRole.stars[j].pos == i then
        panelAllLabelList[i].Visibility = Visibility.Visible;  --让点击过的属性显示出来标题
        if(currentRole.stars[j].att == 0) then
          currentRole.stars[j].att = 1;
        end
        panelAllLabelList[i].TextColor = ranLabelColorTabel[self:confirmQualityColor(currentRole.stars[j].lv, currentRole.stars[j].att, currentRole.stars[j].value ) ];
        panelAllLabelList[i].Text = GemWord[currentRole.stars[j].att]..''..tostring(currentRole.stars[j].value);
        starsList[i] = currentRole.stars[j];
        break;
      end
    end
    if not starsList[i] then
      starsList[i] = 
      {
        value = 0,
        lv = typeList[i],
        att = 0,
        pos = i,
      };
    end
  end
end

function XinghunPanel:refreshImageOnce(checkState)
  for i = 1, 12 do
    if(checkState) then
      if(i <= 4) then    
        panelOneOfCircleList[i]:GetLogicChild("taperedImage").Visibility = Visibility.Visible;
        panelOneOfCircleList[i]:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'XinghunPanel:onClickStar');
      elseif (i < 6 and i > 4) then
        for k = 1, 2 do
          panelTwoOfCircleList[k]:GetLogicChild("taperedImage").Visibility = Visibility.Visible;
          panelTwoOfCircleList[k]:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'XinghunPanel:onClickStar');
        end
      elseif (i < 8 and i > 6) then
        for k = 1, 2 do
          panelThreeOfCircleList[k]:GetLogicChild("taperedImage").Visibility = Visibility.Visible;
          panelThreeOfCircleList[k]:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'XinghunPanel:onClickStar');
        end
      elseif (i < 10 and i > 8) then
        for k = 1, 2 do
          panelFourOfCircleList[k]:GetLogicChild("taperedImage").Visibility = Visibility.Visible;
          panelFourOfCircleList[k]:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'XinghunPanel:onClickStar');
        end 
      elseif (i < 12 and i > 10) then
        for k = 1, 2 do
          panelFiveOfCircleList[k]:GetLogicChild("taperedImage").Visibility = Visibility.Visible;
          panelFiveOfCircleList[k]:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'XinghunPanel:onClickStar'); 
        end
      end
    else
      panelAllLabelList[i].Visibility = Visibility.Hidden;
    end
  end
end

--刷新星图以及星位
function XinghunPanel:refreshImage()
  local rank = currentRole.rank;
  --local typeList = resTableManager:GetValue(ResTable.star_map, tostring(rank), 'type'); 
  self:refreshImageOnce(true);
  for i = 1, #typeList[rank] do
    if(i <= 4) then    
      panelOneOfCircleList[i]:GetLogicChild("taperedImage").Visibility = Visibility.Hidden;
      panelOneOfCircleList[i].Image = GetPicture(typeList[1][i]);
      panelOneOfBottomCircleList[i].Image = GetPicture(iconBottomTable[1][i]);
      panelOneOfCircleList[i].TagExt = typeTagList[1][i];
      panelOneOfCircleList[i].Tag = i;
      panelOneOfCircleList[i]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'XinghunPanel:onClickStar');
    elseif (i < 6 and i > 4) then
      for k = 1, 2 do
        panelTwoOfCircleList[k]:GetLogicChild("taperedImage").Visibility = Visibility.Hidden;
        panelTwoOfCircleList[k].TagExt =  typeTagList[2][i + k - 1];
        panelTwoOfCircleList[k].Image = GetPicture(typeList[2][i + k - 1]);
        panelTwoOfBottomCircleList[k].Image = GetPicture(iconBottomTable[2][i + k - 1]);
        panelTwoOfCircleList[k].Tag =  i + k - 1;
        panelTwoOfCircleList[k]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'XinghunPanel:onClickStar');
      end
    elseif (i < 8 and i > 6) then
      for k = 1, 2 do
        panelThreeOfCircleList[k]:GetLogicChild("taperedImage").Visibility = Visibility.Hidden;
        panelThreeOfCircleList[k].Image = GetPicture(typeList[3][i + k - 1]);
        panelThreeOfBottomCircleList[k].Image = GetPicture(iconBottomTable[3][i + k - 1]);
        panelThreeOfCircleList[k].TagExt =  typeTagList[3][i + k - 1];
        panelThreeOfCircleList[k].Tag =  i + k - 1;
        panelThreeOfCircleList[k]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'XinghunPanel:onClickStar');
      end
    elseif (i < 10 and i > 8) then
      for k = 1, 2 do
        panelFourOfCircleList[k]:GetLogicChild("taperedImage").Visibility = Visibility.Hidden;
        panelFourOfCircleList[k].Image = GetPicture(typeList[4][i + k - 1]);
        panelFourOfBottomCircleList[k].Image = GetPicture(iconBottomTable[4][i + k - 1]);
        panelFourOfCircleList[k].TagExt =  typeTagList[4][i + k - 1];
        panelFourOfCircleList[k].Tag =  i + k - 1;
        panelFourOfCircleList[k]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'XinghunPanel:onClickStar');
      end 
    elseif (i < 12 and i > 10) then
      for k = 1, 2 do
        panelFiveOfCircleList[k]:GetLogicChild("taperedImage").Visibility = Visibility.Hidden;
        panelFiveOfCircleList[k].Image = GetPicture(typeList[5][i + k - 1]);
        panelFiveOfBottomCircleList[k].Image = GetPicture(iconBottomTable[5][i + k - 1]);
        panelFiveOfCircleList[k].TagExt =  typeTagList[5][i + k - 1];
        panelFiveOfCircleList[k].Tag = i + k - 1;
        panelFiveOfCircleList[k]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'XinghunPanel:onClickStar'); 
      end
    end
  end
end

--刷新X等星数量
function XinghunPanel:refreshStarNum()
  local m_item;
  for i = 1, 5 do
    m_item = Package:GetMaterial(materialIds[i]);	
    topBallNum[i].Text = m_item and tostring(m_item.num)  or '0';
  end
end

--隐藏
function XinghunPanel:Hide()
  panel.Visibility = Visibility.Hidden;
  CardDetailPanel:refreshFp();
  self.isShow = false; 
  IsVisible = false;
  self.att = nil;
  self.value = nil;
  self:DestroyImage();
  -- uiSystem:UnBind(DDXTYPE.DDX_STRING, ActorManager.user_data, 'rmb', paneltype:GetLogicChild('resumnum'), 'Text');    
end

--判断界面是否显示
function XinghunPanel:IsVisible()
  return IsVisible;
end
--================================================================
--功能函数
function XinghunPanel:conFirmClick()
  PopPanelTabel[1].Visibility = Visibility.Hidden;
  local id = materialIds[self.lv];
  local DiNum = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(id), 'price');
  if currentStarStatus.att == 0 then
    if tonumber(topBallNum[self.lv].Text) == 0 then
      if(tonumber(ActorManager.user_data.rmb) <= DiNum) then
        Toast:MakeToast(Toast.TimeLength_Long, '材料不足');
        return;
      else
        recordPopstate = true;
        PopPanel.setVisible(4, true);
        PopPanel.setPopPanel4(DiNum);
        --return;
      end
    end
  end
  if(tonumber(topBallNum[self.lv].Text) > 0) then
    self:callBackOpenStar();
  end
end


function XinghunPanel:confirmQualityColor(s_lv, s_att, s_value)
  local star_probInfo;
  local s_maxProper, s_minProper;
  local star_info = resTableManager:GetRowValue(ResTable.star, tostring(s_lv));
  if(s_att == 1) then
    s_maxProper = star_info['max_atk'];
    s_minProper = star_info['min_atk'];
  elseif s_att == 2 then
    s_maxProper = star_info['max_mgc'];
    s_minProper = star_info['min_mgc'];
  elseif s_att == 3 then
    s_maxProper = star_info['max_def'];
    s_minProper = star_info['min_def'];
  elseif s_att == 4 then
    s_maxProper = star_info['max_res'];
    s_minProper = star_info['min_res'];
  else
    s_maxProper = star_info['max_hp'];
    s_minProper = star_info['min_hp'];
  end
  local s_lastvalue = math.ceil((s_value - s_minProper)  * 100 / (s_maxProper - s_minProper));
  if s_lastvalue >= 100 then 
    return 6
  end
  for i = 1, 5 do
    star_probInfo = resTableManager:GetRowValue(ResTable.star_prob, tostring(i));
    if(s_lastvalue <= star_probInfo['potential'][2] and s_lastvalue >= star_probInfo['potential'][1]) then
      return star_probInfo['id'];
    end
  end
  return 1;
end

function XinghunPanel:callBackOpenStar()
  --开启
  local msg = {};
  msg.pid = currentRole.pid;
  msg.lv = currentStarStatus.lv;
  msg.pos = currentStarStatus.pos;
  self.refreshCount = 0;
  Network:Send(NetworkCmdType.req_star_open_t, msg);
 -- paneltype.Visibility = Visibility.Hidden;
end

--星位点击函数
function XinghunPanel:onClickStar(Args)
  local refreshState = true;
  local arg = UIControlEventArgs(Args);	
  local tag = arg.m_pControl.Tag;
  local lv =  arg.m_pControl.TagExt;
  --更新当前点击的按钮的状态
  local att = starsList[tag].att or 1;
  local value = starsList[tag].value or 0;
  self.att = att;
  self.value = value;
  self.lv = lv;
  self.tag = tag; 

  local id = materialIds[self.lv];
  local state = getState.none;
  local DiNum = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(id), 'price');
  if(tonumber(ActorManager.user_data.rmb) >= DiNum) then
    self.nosufficient = false;   --当前余额
  end
  if(tonumber(topBallNum[self.lv].Text) > 0) then
    state = getState.item;
  end
  --当前没有属性值
  if att == 0  then
    if tonumber(topBallNum[self.lv].Text) <= 0 then  --没有相应的材料，则直接显示消耗钻石界面
      if tonumber(ActorManager.user_data.rmb) < DiNum then
        isMaterialNotEnough = true;   --钻石和材料都不足
      end
      recordPopstate = true;
      PopPanel.setVisible(4, true);
      PopPanel.setPopPanel4(DiNum);
    else
      PopPanel.setVisible(1, true);
      PopPanel.setPopPanel1(XinghunAtt[att], false);
    end
    self.beforeColor = 0;
  else	
    self.beforeColor = self:confirmQualityColor(self.lv, self.att, self.value );
    -- print("before color KKKK = ", self.beforeColor);
    if tonumber(topBallNum[self.lv].Text) <= 0 then
      PopPanel.setVisible(4, true);
      PopPanel.setPopPanel4(DiNum, XinghunAtt[self.att], self.value);
    else
      if(refreshState) then
        PopPanel.setVisible(2, true);
        PopPanel.setPopPanel2('新属性', true);
        refreshState = false;
      else     
        refreshState = true;
        PopPanel.setVisible(2, true);
        PopPanel.setPopPanel2(XinghunAtt[self.att], true);

        -- self.afterColor = self:confirmQualityColor(self.lv, self.att, self.value );
        -- print("after color TTTT =pppppp ");
      end
    end
  end
  currentStarStatus = 
  {
    pos = tag,
    att = self.att,
    value = self.value,
    lv = lv,
    state = state,
  }
  if UserGuidePanel:IsInGuidence(UserGuideIndex.talent, 1) and panel:GetLogicChild('popPanel1').Visibility == Visibility.Visible then
	UserGuidePanel:ShowGuideShade( panel:GetLogicChild('popPanel1'):GetLogicChild('confirmBtn'),GuideEffectType.hand,GuideTipPos.right,'');
  end

end


function XinghunPanel:IsPopShow()
	return panel:GetLogicChild('popPanel1').Visibility == Visibility.Visible;
end
--弹窗的按钮点击事件
--刷新
function XinghunPanel:refreshBtnClick()
	self.refreshCount = 0;
	self:onRefresh();
end
function XinghunPanel:onRefresh()
  local id = materialIds[self.lv];
  local DiNum = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(id), 'price');
  if(self.nosufficient or tonumber(ActorManager.user_data.rmb) <= DiNum) then

  end
  if (currentStarStatus.state == getState.item) then

  end

  if(tonumber(topBallNum[self.lv].Text) == 0 and ActorManager.user_data.rmb > DiNum and recordPopstate) then   --星魂不足
    recordPopstate = false;
    self:callBackOpenStar();
    return;    
  end
  if(recordPopstate) then
    recordPopstate = false;
    paneltype.Visibility = Visibility.Hidden;
    if isMaterialNotEnough then
      Toast:MakeToast(Toast.TimeLength_Long, '材料不足');
      isMaterialNotEnough = false;
    end
	PopPanel.setPopPanel2Btn(true);
    PopPanel.setPopPanel3Btn(true);
    PopPanel.setPopPanel4Btn(true);
    return ;
  end

  if tonumber(topBallNum[self.lv].Text) == 0 then
    if(tonumber(ActorManager.user_data.rmb) < DiNum) then
      self.nosufficient = true;   --余额不足提示充钱
      if self.isRefreshServeral then
        PopPanel.setPopPanel2Btn(true);
        PopPanel.setPopPanel3Btn(true);
        PopPanel.setPopPanel4Btn(true);
      end
    end
  end

  if self.isRefreshServeral then
    if self.afterColor >= 3 and self.afterColor > self.beforeColor then
      self:onShowSecondSurePanel();
      return;
    end
  else
    if self.afterColor > self.beforeColor then
    self:onShowSecondSurePanel();
    return;
    end
  end 
  --获取
  if(currentStarStatus.att > 0) then
    local msg = {};
    msg.pid = currentRole.pid;
    msg.lv = currentStarStatus.lv;
    msg.pos = currentStarStatus.pos;
    --钻石刷新 2 用star刷新是1+
    msg.flag = (currentStarStatus.state == getState.item) and 1 or 2;
    Network:Send(NetworkCmdType.req_star_get_t, msg);
  end
end

--替换
function XinghunPanel:onReplace()
  local msg = {};
  if self.isRefreshServeral then
      --print('replace-check->'..tostring(paneltype:GetLogicChild('checkBox').Checked));
      paneltype:GetLogicChild('checkBox').Checked = false;
      paneltype:GetLogicChild('checkBox'):GetLogicChild('select').Visibility = Visibility.Hidden;
  end
  paneltype:GetLogicChild('replaceBtn').Visibility = Visibility.Hidden;
  Network:Send(NetworkCmdType.req_star_set_t, msg);
  paneltype.Visibility = Visibility.Hidden;
  self.isRefreshServeral = false;
end

--取消
function XinghunPanel:closePop()
  if self.isRefreshServeral then
      --print('closePop-check->'..tostring(paneltype:GetLogicChild('checkBox').Checked));
      paneltype:GetLogicChild('checkBox').Checked = false;
      paneltype:GetLogicChild('checkBox'):GetLogicChild('select').Visibility = Visibility.Hidden;
  end
  self.isRefreshServeral = false;
  paneltype.Visibility = Visibility.Hidden;
  self.afterColor = 0;
  self.beforeColor = 0;
end

--开启返回
function XinghunPanel:onOpenReturn(msg)
  if msg.code ~= 0 then
    return;
  end
  --更新数据
  local newStarData = {}
  newStarData.lv = msg.lv;
  newStarData.pos = msg.pos;
  newStarData.att = msg.att;
  newStarData.value = msg.value;
  currentRole.stars[#(currentRole.stars)+1] = newStarData;
  starsList[msg.pos] = newStarData;
  --点击开启过的出现属性label
  panelAllLabelList[msg.pos].Visibility = Visibility.Visible;
  panelAllLabelList[msg.pos].TextColor = ranLabelColorTabel[self:confirmQualityColor(msg.lv, msg.att, msg.value)];
  panelAllLabelList[msg.pos].Text = GemWord[msg.att]..''..tostring(msg.value);
  self.att = msg.att;
  self.value = msg.value

  self.beforeColor = self:confirmQualityColor(msg.lv, msg.att, msg.value);
  -- print("before color SSSS = ", self.beforeColor);

  --更新当前选中的star状态
  currentStarStatus.att = newStarData.att;
  currentStarStatus.value = newStarData.value;
  local state = getState.none;
  if tonumber(topBallNum[msg.lv].Text) > 0 then
    state = getState.item;
  else
    --PopPanel.setVisible(3, true);
  end
  currentStarStatus.state = state;		
  self:refreshImage(); --刷新界面

  --  更新战斗力
  uiSystem:UpdateDataBind()
  if UserGuidePanel:IsInGuidence(UserGuideIndex.talent, 1) then
	  UserGuidePanel:ReqWriteGuidence(UserGuideIndex.talent)
  end

  self.lv =  msg.lv;
  self.tag = msg.pos;
  refreshState = true;
  if tonumber(topBallNum[msg.lv].Text) > 0 then
    state = getState.item;
    PopPanel.setVisible(2, false);
    PopPanel.setPopPanel2(XinghunAtt[msg.att], true);
  else
    local id = materialIds[msg.lv];
    local DiNum = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(id), 'price');
    PopPanel.setVisible(3, true);
    PopPanel.setPopPanel3(DiNum);
  end
  paneltype:GetLogicChild('replaceBtn').Visibility = Visibility.Hidden;

  --更新角色天赋提示信息
  XinghunPanel:IsRoleStarTipShow(currentRole);

  if self.isRefreshServeral and self.beforeColor < 3 then
	self.refreshCount = self.refreshCount + 1;
	--print('onOpenReturn-refrshCount->'..tostring(self.refreshCount));
	if self.refreshCount >= 10 then
		PopPanel.setPopPanel2Btn(true);
		PopPanel.setPopPanel3Btn(true);
		PopPanel.setPopPanel4Btn(true);
		--self.isRefreshServeral = false;
	else
		PopPanel.setPopPanel2Btn(false);
		PopPanel.setPopPanel3Btn(false);
		PopPanel.setPopPanel4Btn(false);
		self:onRefresh();
	end
  else
    PopPanel.setPopPanel2Btn(true);
    PopPanel.setPopPanel3Btn(true);
    PopPanel.setPopPanel4Btn(true);
    --self.isRefreshServeral = false;
  end
end

--刷新返回
function XinghunPanel:onGetReturn(msg)
  --验证 是否用完了消耗品
  local state = getState.none;
  self.att = msg.att;
  self.value = msg.value;
  self.lv = msg.lv;

  self.afterColor = self:confirmQualityColor(msg.lv, msg.att, msg.value);
  -- print("afterColor PPPPPP= ", self.afterColor);

  if tonumber(topBallNum[msg.lv].Text) > 0 then
    state = getState.item;
    PopPanel.setVisible(2, false);
    PopPanel.setPopPanel2(XinghunAtt[msg.att], false);
  else
    local id = materialIds[msg.lv];
    local DiNum = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(id), 'price');
    PopPanel.setVisible(3, true);
    PopPanel.setPopPanel3(DiNum);
  end
  currentStarStatus.state = state;
  if self.isRefreshServeral and self.afterColor < 3 then
	self.refreshCount = self.refreshCount + 1;
	--print('onGetReturn-refrshCount->'..tostring(self.refreshCount));
	if self.refreshCount >= 10 then
		PopPanel.setPopPanel2Btn(true);
		PopPanel.setPopPanel3Btn(true);
		PopPanel.setPopPanel4Btn(true);
		--self.isRefreshServeral = false;
	else
		PopPanel.setPopPanel2Btn(false);
		PopPanel.setPopPanel3Btn(false);
		PopPanel.setPopPanel4Btn(false);
		self:onRefresh();
	end
  else
    PopPanel.setPopPanel2Btn(true);
    PopPanel.setPopPanel3Btn(true);
    PopPanel.setPopPanel4Btn(true);
    --self.isRefreshServeral = false;
  end
  -- self:refreshStarList();
end

--替换返回
function XinghunPanel:onSetReturn(msg)
  PopPanel.setRplacePanel2(true);    --进入到替换Panel
  --更新数据
  currentStarStatus.att = self.att;
  currentStarStatus.value = self.value;
  local newStarData = {}
  newStarData.lv = currentStarStatus.lv;
  newStarData.pos = currentStarStatus.pos;
  newStarData.att = currentStarStatus.att;
  newStarData.value = currentStarStatus.value;
  for i=1, #(currentRole.stars) do
    if currentRole.stars[i].pos == self.tag then   --原来是 msg.pos  现在是 self.tag
      currentRole.stars[i] = newStarData;
      starsList[self.tag] = newStarData;
      break;
    end
  end
  self:refreshStarList();
  --  更新战斗力
  uiSystem:UpdateDataBind()

  self.afterColor = 0;
  self.beforeColor = 0;
end

--二次确认
function XinghunPanel:onChangeProperty()
  self.secondSurePanel.Visibility = Visibility.Hidden;
  self:closePop();
  local msg = {}; 
  Network:Send(NetworkCmdType.req_star_set_t, msg);
end

--二次刷新
function XinghunPanel:onSecondRefresh()
  self.secondSurePanel.Visibility = Visibility.Hidden;
  self.afterColor = 0;
  self:onRefresh();
end

function XinghunPanel:onShowSecondSurePanel()
    --self.secondSurePanel:GetLogicChild('newProperLabel').Text = XinghunAtt[self.att]; 

   self.secondSurePanel:GetLogicChild('newProperNum').TextColor = ranLabelColorTabel[self:confirmQualityColor(self.lv, self.att, self.value )];
    self.secondSurePanel:GetLogicChild('beforeProperNum').TextColor = ranLabelColorTabel[self:confirmQualityColor(currentStarStatus.lv, currentStarStatus.att, currentStarStatus.value)];

    self.secondSurePanel:GetLogicChild('newProperNum').Text = XinghunAtt[self.att]..tostring(self.value);
    --self.secondSurePanel:GetLogicChild('beforeNormalLabel').Text = XinghunAtt[currentStarStatus.att];
    self.secondSurePanel:GetLogicChild('beforeProperNum').Text =  XinghunAtt[currentStarStatus.att]..tostring(currentStarStatus.value);
    self.secondSurePanel.Visibility = Visibility.Visible;
end

--角色天赋提示
function XinghunPanel:IsRoleStarTipShow(roleinfo)
  if ActorManager.user_data.role.lvl.level < SystemTaskId[UserGuideIndex.propertyTask] then
    return
  end
	local rank = roleinfo.rank;

	--品质对应天赋数量
	local starsnum = {4,6,8,10,12};

	if #roleinfo.stars < starsnum[tonumber(rank)] then
		CardListPanel:SetTalentState(true);
		return true;
	else
		CardListPanel:SetTalentState(false);
		return false;
	end
end
