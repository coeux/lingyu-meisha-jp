--modelChangePanel.lua
--=====================================================================================
--更换形象

ModelChangePanel =
	{
	};
	
--变量

--控件
local panel;
local mainDesktop;
local bgList = {};
local headPanel;
local modelPanel;
local role_arm;

--初始化
function ModelChangePanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('modelChangePanel'));
	panel:IncRefCount();
	
	panel.Visibility = Visibility.Hidden;
	for i=1, 4 do
		bgList[i] = panel:GetLogicChild('bg'..i);
	end
	headPanel = panel:GetLogicChild('bg2'):GetLogicChild('touchPanel'):GetLogicChild('panel');
	modelPanel = panel:GetLogicChild('bg3'):GetLogicChild('touchPanel'):GetLogicChild('panel');
	role_arm = panel:GetLogicChild('bg1'):GetLogicChild('role_arm');
	panel:GetLogicChild('close'):SubscribeScriptedEvent('Button::ClickEvent', 'ModelChangePanel:onClose');
	panel:GetLogicChild('change'):SubscribeScriptedEvent('Button::ClickEvent', 'ModelChangePanel:changeModel');
end

--销毁
function ModelChangePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function ModelChangePanel:Show()
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);

	for i=1, 4 do
		bgList[i].Background = CreateTextureBrush('personInfo/model_change_bg'..i..'.ccz', 'personInfo');
	end
	self:initRole();
	local aim_resid;
	if ActorManager.main_model < 5000000 then
		aim_resid = 5000000 + ActorManager.user_data.role.resid*100;
	else
		aim_resid = ActorManager.main_model;
	end
	local role_id = math.floor((aim_resid % 1000000) / 100)
	self:selectRole({}, role_id);
end

--隐藏
function ModelChangePanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	for i=1, 4 do
		bgList[i].Background = nil;
		DestroyBrushAndImage('personInfo/model_change_bg'..i..'.ccz', 'personInfo');
	end
end

function ModelChangePanel:initRole()
	local rowNum = 1;
	headPanel:RemoveAllChildren();
	local role_head = customUserControl.new(headPanel, 'cardHeadTemplate');
	role_head.initModleChangeHeadInfo(ActorManager.user_data.role.resid, 130, true);
	role_head.clickEvent('ModelChangePanel:selectRole', -1, ActorManager.user_data.role.resid);

	for i=4, 1000000 do
		local data = resTableManager:GetValue(ResTable.model_change_nokey, i-1, {'role_id', 'skin_id'});
		if data then
			local role_head = customUserControl.new(headPanel, 'cardHeadTemplate');
			local is_qua = ActorManager:GetRoleFromResid(data['role_id']) and true or false;
			role_head.initModleChangeHeadInfo(data['role_id'], 130, is_qua);
			role_head.clickEvent('ModelChangePanel:selectRole', -1, data['role_id']);
			rowNum = rowNum + 1;
		else
			break;
		end
	end	
	headPanel.Size = Size((rowNum-1)*50+rowNum*130,130);
end

function ModelChangePanel:selectRole(Args, go_role)
	local role_id;
	if go_role then
		role_id = go_role;
	else
		local args = UIControlEventArgs(Args);
		role_id = args.m_pControl.TagExt;
		if not role_id or role_id == 0 then
			return;
		end
	end
	local is_main = false;
	if role_id == 101 or role_id == 102 or role_id == 103 then
		is_main = true;
	end
	if not is_main then
		if not ActorManager:GetRoleFromResid(role_id) then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3651);
			return;
		end
	end

	local rowData = resTableManager:GetRowValue(ResTable.model_change, tostring(role_id));
	local rowNum = #rowData['skin_id'];
	modelPanel.Size = Size((rowNum-1)*15+rowNum*100, 100);
	modelPanel:RemoveAllChildren();
	local have_cur_model = false;
	for i=1, rowNum do
		local id = rowData['skin_id'][i];
		local data = resTableManager:GetRowValue(ResTable.skin, tostring(id));
		local skin_item = customUserControl.new(modelPanel, 'itemTemplate');
		local have = true;
		if data['type'] == 3 then
			have = false;
			local aim_id;
			if math.floor((id % 5000000)/100) >= 101 and math.floor((id % 5000000)/100) <= 103 then
				aim_id = 5999900 + id % 100;
			else
				aim_id = id;
			end
			
			if Package.goodsList[aim_id] and Package.goodsList[aim_id].num >= 1 then
				have = true;
			end
		end
		skin_item.initWithInfo(id, -1, 100, false, (not have));
		skin_item.addExtraClickEvent(id, 'ModelChangePanel:setArm');
		if id == ActorManager.main_model then
			have_cur_model = true;
		end
	end
	if have_cur_model then
		self:setArm({}, ActorManager.main_model);
	else
		self:setArm({}, rowData['skin_id'][1]);
	end
end

function ModelChangePanel:setArm(Args, resid)
	local aim_resid;
	if resid then
		aim_resid = resid;
	else
		local args = UIControlEventArgs(Args);
		aim_resid = args.m_pControl.Tag;
	end
	local data = resTableManager:GetRowValue(ResTable.skin, tostring(aim_resid));
	local have = true;
	if data['type'] == 3 then
		have = false;
		local aim_id;
		if math.floor((aim_resid % 5000000)/100) >= 101 and math.floor((aim_resid % 5000000)/100) <= 103 then
			aim_id = 5999900 + aim_resid % 100;
		else
			aim_id = aim_resid;
		end
			
		if Package.goodsList[aim_id] and Package.goodsList[aim_id].num >= 1 then
			have = true;
		end
	end
	if not have then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3652);
		return;
	end
	self.cur_model = aim_resid;

	if self.cur_model == ActorManager.main_model then
		panel:GetLogicChild('change').Visibility = Visibility.Hidden;
	else
		panel:GetLogicChild('change').Visibility = Visibility.Visible;
	end

	role_arm:Destroy();
	local path = GlobalData.AnimationPath .. data['model'] .. '/';
	AvatarManager:LoadFile(path);
	role_arm:LoadArmature(string.sub(data['model'], 1, -8));
	role_arm:SetAnimation(AnimationType.idle);
	role_arm:SetScale(1.3, 1.3);
	role_arm.Horizontal = ControlLayout.H_CENTER;
	role_arm.Vertical = ControlLayout.V_CENTER
end

function ModelChangePanel:changeModel()
	if self.cur_model == ActorManager.main_model then
		return;
	end
	local msg = {};
	msg.new_model = self.cur_model;
    Network:Send(NetworkCmdType.req_change_model_t, msg);
end

function ModelChangePanel:setModel()
	local aim_resid;
	if ActorManager.main_model < 5000000 then
		aim_resid = 5000000 + ActorManager.user_data.role.resid*100;
	else
		aim_resid = ActorManager.main_model;
	end
	local role_id = math.floor((aim_resid % 1000000) / 100)
	self:selectRole({}, role_id);
end

--====================================================================================
--事件
--显示换肤界面
function ModelChangePanel:onShow()
	MainUI:Push(self);
end

--关闭
function ModelChangePanel:onClose()
	MainUI:Pop();
end
