--unionInputPanel.lua
--==============================================================================================
--公会输入

UnionInputPanel =
	{
	};
	
--变量
local inputFlag;			--记录输入公告（1）还是输入留言（2）
local notice;
local message;

--控件
local panel;
local mainDesktop;
local labelTitle;
local tbInput;
local btnOk;

--初始化
function UnionInputPanel:InitPanel(desktop)
	--变量初始化
	inputFlag = 1;			--记录输入公告（1）还是输入留言（2）
	notice = '';
	message = '';

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionInputPanel'));
	panel:IncRefCount();
	
	labelTitle = panel:GetLogicChild('title');
	tbInput = panel:GetLogicChild('input');
	btnOk = panel:GetLogicChild('ok');
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function UnionInputPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionInputPanel:Show()
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function UnionInputPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--==============================================================================================
--功能函数
--获取公告
function UnionInputPanel:GetNotice()
	return notice;
end	

--==============================================================================================
--事件
function UnionInputPanel:onShowInputPanel(flag, note)
	inputFlag = flag;
	if 1 == inputFlag then
		labelTitle.Text = LANG_unionInputPanel_1;		
		tbInput.Text = note;
	elseif 2 == inputFlag then
		labelTitle.Text = LANG_unionInputPanel_2;
		tbInput.Text = '';
	end
	
	MainUI:Push(self);
end

--关闭
function UnionInputPanel:onClose()
	MainUI:Pop();
end

--确定
function UnionInputPanel:onOk()
	if 1 == inputFlag then		--公告
		if 0 == string.len(notice) then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionInputPanel_3);
		elseif LimitedWord:isLimited(notice) then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionInputPanel_4);
		else
			local msg = {};
			msg.notice = notice;
			Network:Send(NetworkCmdType.req_set_notice, msg, true);
			MainUI:Pop();
		end
	else						--留言
		if 0 == string.len(message) then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionInputPanel_5);
		elseif LimitedWord:isLimited(message) then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionInputPanel_6);
		else
			local msg = {};
			msg.msg = message;
			msg.type = UnionInputType.input;	--公会留言
			Network:Send(NetworkCmdType.nt_gang_msg, msg, true);
			MainUI:Pop();
		end
	end	
end

--字符内容改变事件
function UnionInputPanel:onTextChange()
	if 1 == inputFlag then		--公告
		if appFramework:GetStringLengthOfUtf8(tbInput.Text, Configuration.CharToChineseRatio) > Configuration.NoticeStrCount then
			--超过最大字符限制
			tbInput.Text = notice;
		else
			--没有超过最大字符限制
			notice = tbInput.Text;
		end
	else						--留言
		if appFramework:GetStringLengthOfUtf8(tbInput.Text, Configuration.CharToChineseRatio) > Configuration.ChatStrCount then
			--超过最大字符限制
			tbInput.Text = message;
		else
			--没有超过最大字符限制
			message = tbInput.Text;
		end
	end
end