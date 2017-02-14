--partnerFirePanel.lua

--========================================================================
--伙伴解雇确认界面

PartnerFirePanel =
	{
	};	

--控件
local mainDesktop;
local partnerFirePanel;
local textName;
local itemCells = {};
local fengexian;

--变量初始化
local role;
local fightPower;		--战力
local soul;				--灵能
local money;			--金币
local chip;				--碎片
local itemList = {};



--初始化面板
function PartnerFirePanel:InitPanel(desktop)
	--变量初始化
	role = nil;

	--界面初始化
	mainDesktop = desktop;
	partnerFirePanel = Panel(desktop:GetLogicChild('partnerFirePanel'));
	partnerFirePanel:IncRefCount();
	fengexian = partnerFirePanel:GetLogicChild('fengexian');
	
	partnerFirePanel.Visibility = Visibility.Hidden;
	
	textName = TextElement( partnerFirePanel:GetLogicChild('title'):GetLogicChild('2') );
	
	local stackPanel = StackPanel(partnerFirePanel:GetLogicChild('itemList'));
	for index = 1, 4 do
		local itemCell = ItemCell( stackPanel:GetLogicChild(tostring(index)));
		local name = Label( itemCell:GetLogicChild('name'));
		local obj = {};
		obj.itemCell = itemCell;
		obj.name = name;
		table.insert(itemCells , obj);
	end
	
end

--销毁
function PartnerFirePanel:Destroy()
	partnerFirePanel:IncRefCount();
	partnerFirePanel = nil;
end

--显示
function PartnerFirePanel:Show()
	self:Refresh();
	--设置模式对话框
	mainDesktop:DoModal(partnerFirePanel);
	
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(partnerFirePanel, StoryBoardType.ShowUI1);
end

--隐藏
function PartnerFirePanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();	
	
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(partnerFirePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

function PartnerFirePanel:Refresh()
	local count = 0;
	for index = 1, 4 do	
		if nil ~= itemList[index] and itemList[index].num ~= 0 then
			itemCells[index].Visibility = Visibility.Visible;
			local data = resTableManager:GetRowValue(ResTable.item, tostring(itemList[index].resid));
			local icon = GetIcon(data['icon']);
			itemCells[index].itemCell.Image = icon;	
			itemCells[index].itemCell.Background = Converter.String2Brush( QualityType[data['quality']]);
			itemCells[index].itemCell.ItemNum = itemList[index].num;
			itemCells[index].name.Text = data['name'];
			itemCells[index].name.TextColor = QualityColor[data['quality']];
			itemCells[index].itemCell.Visibility = Visibility.Visible;
			count = count + 1;
		else
			itemCells[index].itemCell.Visibility = Visibility.Hidden;
		end
	end
	if count == 4 then
		partnerFirePanel.Width = 680;
		fengexian.Width = 450;
	elseif count == 3 then
		partnerFirePanel.Width = 540;
		fengexian.Width = 350;
	else
		partnerFirePanel.Width = 400;
		fengexian.Width = 300;
	end	
	
end

function PartnerFirePanel:onShow( mRole )
	fightPower = 0;
	soul = 0;
	money = 0;
	chip = 0;
	
	role = mRole;

	textName.Text = role.name;
	textName.TextColor = QualityColor[role.rare];
	for index = 1,role.quality do
		local stuffData = resTableManager:GetRowValue(ResTable.qualityup_stuff, '' .. role.resid .. index);
		soul = soul + stuffData['var2'];
		chip = chip + stuffData['var1'];
		money = money + stuffData['var3'];
	end
	local mergeCount = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'hero_piece');
	chip = math.floor( (chip + mergeCount) * 0.9 );
	for _,skill in ipairs(role.skls) do	
		local skillData = resTableManager:GetRowValue(ResTable.skill, tostring(skill.resid));
		if skillData ~= nil then
			local skillType = skillData['skill_type'];
			if skillType == 0 then
				--一阶技能
				if math.mod(skill.resid, 2) == 1 then
					for index = 101, 100 + skill.level do
						fightPower = fightPower + resTableManager:GetValue(ResTable.skill_upgrade, tostring(index), 'btp')
					end
				--二阶技能
				else
					for index = 201, 200 + skill.level do
						fightPower = fightPower + resTableManager:GetValue(ResTable.skill_upgrade, tostring(index), 'btp')
					end
				end
			elseif skillType == 1 then
				--自动技能非0级表示开启
				if skill.level ~= 0 then
					fightPower = fightPower + skillData['open_btp'];
				end
			end
		else			
			for index = 1, skill.level do
				fightPower = fightPower + resTableManager:GetValue(ResTable.passiveSkillupgrade, tostring(index), 'btp')
			end
		end
	end
	itemList = {};	
	table.insert(itemList, {resid=10002, num=math.floor(fightPower * 0.7)});
	table.insert(itemList, {resid=10001, num=math.floor(money * 0.7)});
	table.insert(itemList, {resid=10009, num=math.floor(soul * 0.7)});
	table.insert(itemList, {resid=role.resid + 30000, num=chip});
	MainUI:Push(self);
end

--请求分解
function PartnerFirePanel:onRequestFire( )
	local msg = {}
	msg.pid = role.pid;
	Network:Send(NetworkCmdType.req_fire_partner, msg);
end

--关闭
function PartnerFirePanel:onClose()
	MainUI:Pop();
end
