--convertPackagePanel.lua
--===========================================================================
--礼包兑换
ConvertPackagePanel =
	{
	};

--变量

--控件
local panel;
local mainDesktop;
local input;

--初始化
function ConvertPackagePanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('convertPackagePanel');
	panel:IncRefCount();
	input = panel:GetLogicChild('input');

	panel.Visibility = Visibility.Hidden;
end

--销毁
function ConvertPackagePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示

function ConvertPackagePanel:Show()
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function ConvertPackagePanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--===========================================================================
--事件
--关闭
function ConvertPackagePanel:onClose()
	MainUI:Pop();
end

--显示
function ConvertPackagePanel:onShow()
	input.Text = '';
	MainUI:Push(self);
end

--兑换
function ConvertPackagePanel:onConvert()
	
	if 0 == string.len(input.Text) then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_convertPackagePanel_1);
	else
		if 8 == string.len(input.Text) then
			local msg = {};
			msg.cdkey = input.Text;
			Network:Send(NetworkCmdType.req_cdkey_reward, msg);
			input.Text = '';
		else
			Toast:MakeToast(Toast.TimeLength_Long, LANG_convertPackagePanel_2);
		end		
	end	
end

--显示礼包奖励
function ConvertPackagePanel:onShowPackage(msg)
	ToastMove:AddGoodsGetTip(msg.resid, 1);
	MainUI:Pop();
end