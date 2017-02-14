--unionAdjustPosition.lua
--==============================================================================================
--职位调整

UnionAdjustPosition =
	{
	};
	
--变量
local positionTitle = {LANG_unionAdjustPosition_1, LANG_unionAdjustPosition_2, LANG_unionAdjustPosition_3};
local role;

--控件
local panel;
local mainDesktop;
local btnOpt;
local label;

--初始化
function UnionAdjustPosition:InitPanel(desktop)
	--变量初始化
	positionTitle = {LANG_unionAdjustPosition_4, LANG_unionAdjustPosition_5, LANG_unionAdjustPosition_6};
	role = nil;

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionMemberPanel'):GetLogicChild('unionPosAdjustment'));
	
	btnOpt = panel:GetLogicChild('optPosition');
	label = panel:GetLogicChild('nandp');

	panel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'UnionAdjustPosition:onLostFocus');
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function UnionAdjustPosition:Destroy()
	--panel:DecRefCount();
	panel = nil;
end

--显示
function UnionAdjustPosition:Show()
	label.Text = role.name .. ': ' .. positionTitle[role.flag + 1];
	if 0 == role.flag then   		--会员
		btnOpt.Text = LANG_unionAdjustPosition_7;
	elseif 1 == role.flag then   	--官员
		btnOpt.Text = LANG_unionAdjustPosition_8;
	end
	panel.Visibility = Visibility.Visible;
	mainDesktop.FocusControl = panel;
	
	--增加UI弹出时候的效果
	--StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function UnionAdjustPosition:Hide()
	panel.Visibility = Visibility.Hidden;

	--增加UI消失时的效果
	--StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--==============================================================================================
--功能函数
--获得新会长名字
function UnionAdjustPosition:GetNewMasterName()
	return role.name;
end

--==============================================================================================
--事件
--关闭
function UnionAdjustPosition:onClose()
	self:Hide();
end

function UnionAdjustPosition:onLostFocus()
	self:Hide();
end

--显示职位调整界面
function UnionAdjustPosition:onShowAdjustPanel(pos, player)
	panel.Translate = pos;
	role = player;	
	self:Show();
	--MainUI:Push(self);
end

--职位操作
function UnionAdjustPosition:onOptPosition()
	local msg = {};
	msg.uid = role.uid;	
	
	if 0 == role.flag then   		--任命官员
		if UnionMemberPanel:GetOfficerCount() >= UnionMemberPanel:GetMaxOfficerCount() then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionAdjustPosition_9);
			return;
		else
			msg.isadm = true;
		end		
	elseif 1 == role.flag then   	--解除职位
		msg.isadm = false;
	end
	
	Network:Send(NetworkCmdType.req_set_adm, msg);
end

--转让会长
function UnionAdjustPosition:onTransfer()
	local okDelegate = Delegate.new(UnionAdjustPosition, UnionAdjustPosition.ConfirmToChangeMaster);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_unionAdjustPosition_10 .. role.name .. '？', okDelegate);
end

--确认转让会长
function UnionAdjustPosition:ConfirmToChangeMaster()
	local msg = {};
	msg.uid = role.uid;
	
	Network:Send(NetworkCmdType.req_change_charman, msg);
end	
