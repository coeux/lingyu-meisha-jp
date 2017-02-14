--drawingSynthesisPanel.lua
--=================================================================================
--图纸合成
DrawingSynthesisPanel =
	{
	};
	
--变量
local selectPaper = {0, 0, 0};

--控件
local mainDesktop;
local panel;
local paperList;

local centerPaper;
local cneterNameLabel;
local sidePaper = {};
local sidePaper2;
local sidePaper3;
local aimPaperId;
local materialPaper = {}

--初始化
function DrawingSynthesisPanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('DrawingSynthesisPanel');
	panel:IncRefCount();
	local drawClipList = panel:GetLogicChild('drawClipList');
	paperList = drawClipList:GetLogicChild('drawingList');
	panel.Margin = Rect(0, -14, 0, 0);
	
	centerPaper = panel:GetLogicChild('drawing');
	cneterNameLabel = panel:GetLogicChild('name');
	sidePaper[1] = panel:GetLogicChild('ic1');
	sidePaper[2] = panel:GetLogicChild('ic2');
	sidePaper[3] = panel:GetLogicChild('ic3');
	generateBtn = panel:GetLogicChild('synthesis');
	

	sidePaper[1]:SubscribeScriptedEvent('UIControl::MouseDownEvent', 'DrawingSynthesisPanel:OnUnSelectPaper');
	sidePaper[2]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'DrawingSynthesisPanel:OnUnSelectPaper');
	sidePaper[3]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'DrawingSynthesisPanel:OnUnSelectPaper');	
	
	generateBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', '');
	generateBtn:SubscribeScriptedEvent('UIControl::MouseDownEvent', 'DrawingSynthesisPanel:DoGeneratePaper');	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function DrawingSynthesisPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function DrawingSynthesisPanel:Show()
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function DrawingSynthesisPanel:Hide()
	--mainDesktop:UndoModal();
	self:RemovePaperItem();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

function DrawingSynthesisPanel:RemovePaperItem()
	paperList:RemoveAllChildren();	
end
--============================================================================
--关闭按钮响应事件
function DrawingSynthesisPanel:OnClose()
	MainUI:Pop();
end		

function DrawingSynthesisPanel:OnGotGeneratePaperRes(msg)
	--print("OnGotGeneratePaperRes:"..tostring(msg));
	DrawingSynthesisPanel:OnRefreshPanelItemNum();
	
	if msg.code == 0 then
		--PlayEffect("tuzhihecheng_output/", Rect.ZERO, "tuzhihecheng", centerPaper);
		
		local data = resTableManager:GetValue(ResTable.item, tostring(aimPaperId), {'name', 'quality'});
		Toast:MakeToast(Toast.TimeLength_Long, LANG_drawingSynthesisPanel_4, nil, data['name'], QualityColor[data['quality']], '】' );

		selectPaper = {0, 0, 0}
		self:OnRefreshSidePaper();
		self:RefreshMaterailPanel();
	end
end

function DrawingSynthesisPanel:DoGeneratePaper()
	--print("DrawingSynthesisPanel:DoGeneratePaper");
	-- check select paper first
	
	for i = 1, #selectPaper do
		if selectPaper[i] == 0 then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_drawingSynthesisPanel_2);
			return
		end
	end
	local msg = {};
	msg.resid = aimPaperId;
	msg.source = selectPaper;
	--print("DoGeneratePaper, aimPaperId:"..aimPaperId..", source:"..tostring(selectPaper));
	Network:Send(NetworkCmdType.req_compose_drawing_t, msg);		
end

function DrawingSynthesisPanel:OnSelectPaper(Args)
	local args = UIControlEventArgs(Args);
	local selItemId = args.m_pControl.Tag;
	
	local selPaperItem = Package:GetEquip(selItemId);
	if selPaperItem == nil then
		return
	end
	
	local selItemNum = selPaperItem.num;
	
	local alreadyNum = 0;
	
	for i=1, #selectPaper do
		if selectPaper[i] == selItemId then
			alreadyNum = alreadyNum + 1;
		end	
	end
	
	if alreadyNum >= selItemNum then
		--物品不足，但不用提示
		--MessageBox:ShowDialog(MessageBoxType.Ok, LANG_drawingSynthesisPanel_3);
		return;
	end
	
	local findItem = false;
	for i=1, #selectPaper do
		if selectPaper[i] == 0 then
			selectPaper[i] = selItemId;
			findItem = true;
			break;
		end
	end
	
	if findItem == true then
		self:OnRefreshSidePaper()
	else
		print("Full");
	end
	
	self:OnRefreshPanelItemNum();
end

function DrawingSynthesisPanel:OnUnSelectPaper(Args)
	--print("OnUnSelectPaper");
	local args = UIControlEventArgs(Args);
	local itemIndex = args.m_pControl.Tag;
	selectPaper[itemIndex] = 0;	
	self:OnRefreshSidePaper();
	self:OnRefreshPanelItemNum();
end

-- 三个合成材料的刷新
function DrawingSynthesisPanel:OnRefreshSidePaper()
	for i=1, #selectPaper do
		paperId = selectPaper[i];
		if paperId ~= 0 then
			local mainItemName = resTableManager:GetValue(ResTable.item, tostring(paperId), "name");
			local iconId = resTableManager:GetValue(ResTable.item, tostring(paperId), "icon");				
			sidePaper[i].Image = GetIcon(iconId);
			local itemColor = resTableManager:GetValue(ResTable.item, tostring(paperId), "quality");				
			sidePaper[i].Background = Converter.String2Brush( QualityType[itemColor] );			
		else
			sidePaper[i].Image = nil;
			sidePaper[i].Background = Converter.String2Brush( QualityType[1] );	
		end

	end
end

function DrawingSynthesisPanel:OnRefreshPanelItemNum()
	for k,resId in ipairs(materialPaper) do
		local paperItem = Package:GetEquip(resId);
		local curCell = paperList:GetLogicChild(tostring(resId)):GetLogicChild("drawingSynthesisTemplate"):GetLogicChild("itemcell");
		local paperNum = 0;
		if paperItem ~= nil then
			paperNum = paperItem.num;
		else
			paperNum = 0;
		end
		for i=1, #selectPaper do
			paperId = selectPaper[i];	
			if paperId == resId then
				paperNum = paperNum -1;
			end	
		end
		if paperNum < 0 then
			paperNum = 0;
		end
		curCell.ItemNum = paperNum;

	end

	local aimPaperItem = Package:GetEquip(aimPaperId);
	if aimPaperItem == nil then
		centerPaper.ItemNum = 0;	
	else
		centerPaper.ItemNum = aimPaperItem.num;	
	end
	
end

function DrawingSynthesisPanel:RefreshMaterailPanel()
	-- 初始化合成材料图纸
	local resIndex = aimPaperId%10;
	self:RemovePaperItem();
	materialPaper = {}
	
	for i=1, 9 do
		if i ~= resIndex then
			local otherResIndex = aimPaperId - resIndex + i;
			local paperItem = Package:GetEquip(otherResIndex);
			
			if paperItem ~= nil then
				--print(paperItem.num);
				local t = uiSystem:CreateControl('drawingSynthesisTemplate');
				t.Name = tostring(otherResIndex);
				t:SubscribeScriptedEvent('UIControl::MouseUpEvent', 'DrawingSynthesisPanel:OnSelectPaper');
				t.Tag = otherResIndex;
				local namectrl = t:GetLogicChild('drawingSynthesisTemplate'):GetLogicChild('name');
				local cell = t:GetLogicChild('drawingSynthesisTemplate'):GetLogicChild('itemcell');		
				--namectrl:SubscribeScriptedEvent('UIControl::MouseDownEvent', 'DrawingSynthesisPanel:OnSelectPaper');	
				namectrl.Tag = 	otherResIndex;
				--cell:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'DrawingSynthesisPanel:OnSelectPaper');	
				cell.Tag = 	otherResIndex;
				table.insert(materialPaper, otherResIndex);

				local itemColor = resTableManager:GetValue(ResTable.item, tostring(paperItem.resid), "quality");				
				cell.Background = Converter.String2Brush( QualityType[itemColor] );

				cell.Image = paperItem.icon;
				cell.ItemNum = paperItem.num;
				local itemName = resTableManager:GetValue(ResTable.item, tostring(paperItem.resid), "name");
				namectrl.Text = itemName;

				namectrl.TextColor = QualityColor[itemColor];
				paperList:AddChild(t);
			end
		end
	end
end

function DrawingSynthesisPanel:OnOpenPanel(paperResId)
	local aimPaperItem = Package:GetEquip(paperResId);
	local resIndex = paperResId%10;
	selectPaper = {0, 0, 0}
	self:OnRefreshSidePaper();
	aimPaperId = paperResId
	
	--mainPaperItem = Package:GetEquip(paperResId);
	--centerPaper.Image = mainPaperItem.icon;
	local mainItemName = resTableManager:GetValue(ResTable.item, tostring(paperResId), "name");
	local iconId = resTableManager:GetValue(ResTable.item, tostring(paperResId), "icon");
	centerPaper.Image = GetIcon(iconId);
	local itemColor = resTableManager:GetValue(ResTable.item, tostring(paperResId), "quality");
	centerPaper.Background = Converter.String2Brush( QualityType[itemColor] );
	if aimPaperItem == nil then
		centerPaper.ItemNum = 0;
	else
		centerPaper.ItemNum = aimPaperItem.num;
	end
	cneterNameLabel.Text = mainItemName;
	cneterNameLabel.TextColor = QualityColor[itemColor];
	
	self:RefreshMaterailPanel(paperResId);	
end
