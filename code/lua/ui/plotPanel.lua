--plotPanel.lua

--========================================================================
--剧情界面

PlotPanel =
{
	isPopPlotPanel = false;
};

--控件
local mainDesktop;
local plotPanel;						--剧情面板
local plotShade;						--黑幕面板
local plotContent;						--字幕面板
local plotImage;						--剧情图片

local dialogPortraitPanelLeft;			--对话左边半身像面板
local dialogPortraitPanelRight;			--对话右边半身像面板
local imagePortraitLeft;				--对话左边半身像
local imagePortraitRight;				--对话右边半身像
local dialogPanel;						--对话面板
local talkPanelLeft;					--左对话面板
local talkPanelRight;					--右对话面板
local talkNameLeft;						--左对话人物名称
local talkNameRight;					--右对话人物名称
local talkContentLeft;					--左对话内容
local talkContentRight;					--右对话内容
local brushDialogShade;					--对话遮罩

local dialogTwPanel;						--对话面板
local dialogTwTalk;						--对话内容
local dialogTwName;						--对话npc名字
local dialogTwPortrait;					--对话npc头像
local dialogTwArrow;						--动态箭头

--变量
local timeOut			= 3.3;			--剧情步骤超时时间
local ShadeMaxOpacity	= 1.0;			--黑幕最大透明度

local curType			= PlotStepType.none;		--当前剧情类型
local totalTime		= 0;			--总时间
local elapseTime		= 0;			--累计消耗时间
local finishNotice		= false;		--结束后通知

local talkTextLen		= 0;			--对话文字长度
local talkText			= nil;			--对话内容
local arrowTime		= 0;			--箭头等待时间
local arrowTranslate	= nil;			--箭头默认坐标
local arrowFlag		= false;		--箭头上下标示位

local PortraitOffset	= 500;		--左右半身像的偏离值
local SideLeft	= 0;				--左边
local SideRight	= 1;				--右边
local PortraitInOutTime	= 0.1;		--左右半身像移动时间
local portraitSide = -1;			--头像左边还是右边

local talkSide = -1;				--对话内容左边还是右边

local talkTwTextLen		= 0;			--对话文字长度
local talkTwText			= nil;			--对话内容
local arrowTwTime		= 0;			--箭头等待时间
local arrowTwTranslate	= nil;			--箭头默认坐标
local arrowTwFlag		= false;		--箭头上下标示位

local content 

--初始化面板
function PlotPanel:InitPanel(desktop)
	--初始化变量
	timeOut				= 3.3;			--剧情步骤超时时间
	ShadeMaxOpacity		= 1.0;			--黑幕最大透明度
	
	curType				= PlotStepType.none;		--当前剧情类型
	totalTime			= 0;			--总时间
	elapseTime			= 0;			--累计消耗时间
	finishNotice		= false;		--结束后通知
	
	talkTextLen			= 0;			--对话文字长度
	talkText			= nil;			--对话内容
	arrowTime			= 0;			--箭头等待时间
	arrowTranslate		= nil;			--箭头默认坐标
	arrowFlag			= false;		--箭头上下标示位


	--初始化界面
	mainDesktop = desktop;
	plotPanel = Panel(desktop:GetLogicChild('plotPanel'));
	plotPanel:IncRefCount();
	plotShade = Panel(plotPanel:GetLogicChild('plotShade'));
	plotContent = Label(plotPanel:GetLogicChild('plotContent'));
	plotContent.Text = '';	
	plotImage = Label(plotPanel:GetLogicChild('plotImage'));
	
	dialogPortraitPanelLeft = Panel(plotPanel:GetLogicChild('dialogPortraitPanel1'));
	dialogPortraitPanelRight = Panel(plotPanel:GetLogicChild('dialogPortraitPanel2'));
	imagePortraitLeft = ImageElement(dialogPortraitPanelLeft:GetLogicChild('portrait'));
	imagePortraitRight = ImageElement(dialogPortraitPanelRight:GetLogicChild('portrait'));
	dialogPanel = Panel(plotPanel:GetLogicChild('dialogPanel'));
	talkPanelLeft = Panel(dialogPanel:GetLogicChild('talkPanel1'));
	talkPanelRight = Panel(dialogPanel:GetLogicChild('talkPanel2'));
	talkNameLeft = Label(talkPanelLeft:GetLogicChild('name'));
	talkNameRight = Label(talkPanelRight:GetLogicChild('name'));
	talkContentLeft = Label(talkPanelLeft:GetLogicChild('talk'));
	talkContentRight = Label(talkPanelRight:GetLogicChild('talk'));
	brushDialogShade = Label(plotPanel:GetLogicChild('dialogShade'));
	
	plotPanel.Visibility = Visibility.Hidden;	
	plotShade.Visibility = Visibility.Hidden;
	plotContent.Visibility = Visibility.Hidden;
	plotImage.Visibility = Visibility.Hidden;
	
	dialogPortraitPanelLeft.Visibility = Visibility.Visible;
	dialogPortraitPanelLeft.Translate = Vector2(-PortraitOffset,0);
	dialogPortraitPanelRight.Visibility = Visibility.Visible;
	dialogPortraitPanelRight.Translate = Vector2(PortraitOffset,0);
	dialogPanel.Visibility = Visibility.Hidden;	
	
	dialogTwPanel = Panel(plotPanel:GetLogicChild('dialogPanelTw'));
	dialogTwTalk = Label(dialogTwPanel:GetLogicChild('talk'));
	dialogTwName = Label(dialogTwPanel:GetLogicChild('name'));
	dialogTwPortrait = ImageElement(dialogTwPanel:GetLogicChild('portrait'));
	dialogTwArrow = BrushElement(dialogTwPanel:GetLogicChild('arrow'));
	dialogTwPanel.Visibility = Visibility.Hidden;	
	plotImage:SubscribeScriptedEvent('UIControl::MouseClickEvent', "PlotPanel:onNext");
	
	content = plotPanel:GetLogicChild('content')
	content.Visibility = Visibility.Hidden

	plotPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PlotPanel:guideEquipHide');
end

function PlotPanel:showContent(  )
	if self.isPopPlotPanel then
		plotPanel.Visibility = Visibility.Hidden;
	else
		plotPanel.Visibility = Visibility.Visible;
	end
	plotPanel.Pick = false
	content.Visibility = Visibility.Visible
end

function PlotPanel:hideContent(  )
	plotPanel.Visibility = Visibility.Hidden
	plotPanel.Pick = true
	content.Visibility = Visibility.Hidden
end

function PlotPanel:changeContentPos( x,y )
	content.Translate = Vector2(x,y)
end

function PlotPanel:changeContentText( tip )
	content:GetLogicChild('msg').Text = tip
end
function PlotPanel:setContentClickEvent()
	plotPanel.Pick = true;
	plotPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','PlotPanel:contentClickEvnet');
end
function PlotPanel:unSetContentClickEvent( )
	plotPanel:UnSubscribeScriptedEvent('UIControl::MouseClickEvent','PlotPanel:contentClickEvnet');
end
function PlotPanel:contentClickEvnet()
	FightSkillCardManager:guideCradClick(1, LANG_GUIDE_CONTENT_9);
    FightSkillCardManager.guideCardClick = true;
end
function PlotPanel:guideEquipShow()
	plotPanel.Visibility = Visibility.Visible;
	content.Visibility = Visibility.Visible;
	self.isPopPlotPanel = true;
	mainDesktop:DoModal(plotPanel);
	StoryBoard:ShowUIStoryBoard(plotPanel, StoryBoardType.ShowUI1);
end

function PlotPanel:guideEquipHide()
	if PveLosePanel.isGuideEquipStrength or PveLosePanel.isGuideEquipLevelUp then
		PveLosePanel.isGuideEquipStrength = false;
		PveLosePanel.isGuideEquipLevelUp = false;
		StoryBoard:HideUIStoryBoard(plotPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	end

	if PveLosePanel.isGuideGem then
		PveLosePanel.isGuideGem = false;
		StoryBoard:HideUIStoryBoard(plotPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	end
end

--删除资源
function PlotPanel:Destroy()
	plotPanel:DecRefCount();
	plotPanel = nil;
end

--剧情面板更新
function PlotPanel:Update( Elapse )
	if curType == PlotStepType.blackIn then
		self:updateBlackInShade(Elapse);
	elseif curType == PlotStepType.blackOut then
		self:updateBlackOutShade(Elapse);
	elseif curType == PlotStepType.blackInText then
		self:updateBlackInText(Elapse);
	elseif curType == PlotStepType.blackOutText then
		self:updateBlackOutText(Elapse);
	elseif curType == PlotStepType.blackInImage then
		self:updateBlackInImage(Elapse);
	elseif curType == PlotStepType.blackOutImage then
		self:updateBlackOutImage(Elapse);
	elseif curType == PlotStepType.npcTalk then
		self:updateTalkDialog(Elapse);
	elseif curType == PlotStepType.npcTalkTw then
		self:updateTalkDialogTw(Elapse);
	elseif curType == PlotStepType.portraitIn then
		self:updatePortraitIn(Elapse);
	elseif curType == PlotStepType.portraitOut then
		self:updatePortraitOut(Elapse);
	end
end

--创建剧情遮罩背景图片
function PlotPanel:CreateShadeBg()
	plotShade.Background = CreateTextureBrush('background/juqing-beijing.ccz', 'godsSenki');
end

--销毁剧情遮罩背景图片
function PlotPanel:DestroyShadeBg()
	plotShade.Background = nil;
	DestroyBrushAndImage('background/juqing-beijing.ccz', 'godsSenki');
end

--黑幕淡入更新
function PlotPanel:updateBlackInShade( Elapse )
	elapseTime = elapseTime + Elapse;
	if elapseTime <= totalTime then
		plotShade.Opacity = elapseTime / totalTime * ShadeMaxOpacity;
	else
		plotShade.Opacity = 1;
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;
		
		if finishNotice then
			PlotManager:FinishPlotStep(PlotStepType.blackIn);
		end
	end
end

--黑幕淡出更新
function PlotPanel:updateBlackOutShade( Elapse )
	elapseTime = elapseTime + Elapse;
	if elapseTime <= totalTime then
		plotShade.Opacity = (1 - elapseTime / totalTime) * ShadeMaxOpacity;
	else
		plotShade.Opacity = 0;
		plotShade.Visibility = Visibility.Hidden;
		plotContent.Visibility = Visibility.Hidden;
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;
		
		if finishNotice then
			PlotManager:FinishPlotStep(PlotStepType.blackOut);
		end
	end
end

--字幕淡入更新
function PlotPanel:updateBlackInText( Elapse )
	elapseTime = elapseTime + Elapse;
	if elapseTime <= totalTime then
		plotContent.Opacity = elapseTime / totalTime;
	else
		plotContent.Opacity = 1;
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;
		
		if finishNotice then
			PlotManager:FinishPlotStep(PlotStepType.blackInText);
		end
	end
end

--字幕淡出更新
function PlotPanel:updateBlackOutText( Elapse )
	elapseTime = elapseTime + Elapse;
	if elapseTime <= totalTime then
		plotContent.Opacity = 1 - elapseTime / totalTime;
	else
		plotContent.Opacity = 0;
		plotContent.Visibility = Visibility.Hidden;
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;
		
		if finishNotice then
			PlotManager:FinishPlotStep(PlotStepType.blackOutText);
		end
	end
end

--图片淡入更新
function PlotPanel:updateBlackInImage( Elapse )
	elapseTime = elapseTime + Elapse;
	if elapseTime <= totalTime then
		plotImage.Opacity = elapseTime / totalTime;
	else
		plotImage.Opacity = 1;
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;
		
		if finishNotice then
			PlotManager:FinishPlotStep(PlotStepType.blackInImage);
		end
	end
end

--图片淡出更新
function PlotPanel:updateBlackOutImage(Elapse)
	elapseTime = elapseTime + Elapse;
	if elapseTime <= totalTime then
		plotImage.Opacity = 1 - elapseTime / totalTime;
	else
		plotImage.Opacity = 0;
		plotImage.Visibility = Visibility.Hidden;
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;
		
		if finishNotice then
			PlotManager:FinishPlotStep(PlotStepType.blackOutImage);
		end
	end
end

--对话更新
function PlotPanel:updateTalkDialog( Elapse )
	elapseTime = elapseTime + Elapse;
	
	if elapseTime >= totalTime then
		dialogPanel.Visibility = Visibility.Hidden;	
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;

		if finishNotice then
			PlotManager:FinishPlotStep(PlotStepType.npcTalk);
		end
	end
end

--对话更新
function PlotPanel:updateTalkDialogTw( Elapse )
	elapseTime = elapseTime + Elapse;
	
	arrowTwTime = arrowTwTime + Elapse;
	if arrowTwTime > 0.3 then
		arrowTwTime = 0;
		if arrowTwFlag then
			dialogTwArrow.Translate = Vector2(0, -1);
			arrowTwFlag = false;
		else
			dialogTwArrow.Translate = Vector2(0, 1);
			arrowTwFlag = true;
		end
	end
	
	if elapseTime >= totalTime then
		dialogTwPanel.Visibility = Visibility.Hidden;
		talkTwTextLen = 0;
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;

		if finishNotice then
			PlotManager:FinishPlotStep(PlotStepType.npcTalkTw);
		end
	end
end

--半身像飞入
function PlotPanel:updatePortraitIn( Elapse )
	elapseTime = elapseTime + Elapse;
	if elapseTime <= totalTime then
		if portraitSide == SideLeft then
			dialogPortraitPanelLeft.Translate = Vector2((1-elapseTime / totalTime) * (-PortraitOffset),0);
		elseif portraitSide == SideRight then
			dialogPortraitPanelRight.Translate = Vector2((1-elapseTime / totalTime) * PortraitOffset,0);
		end
	else
		if portraitSide == SideLeft then
			dialogPortraitPanelLeft.Translate = Vector2(0,0);
		elseif portraitSide == SideRight then
			dialogPortraitPanelRight.Translate = Vector2(0,0);
		end
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;
		
		if finishNotice then
			PlotManager:FinishPlotStep(PlotStepType.portraitIn);
		end
	end
end

--半身像移出
function PlotPanel:updatePortraitOut( Elapse )
	elapseTime = elapseTime + Elapse;
	if elapseTime <= totalTime then
		if portraitSide == SideLeft then
			dialogPortraitPanelLeft.Translate = Vector2(elapseTime / totalTime * (-PortraitOffset),0);
		elseif portraitSide == SideRight then
			dialogPortraitPanelRight.Translate = Vector2(elapseTime / totalTime * PortraitOffset,0);
		end
	else
		if portraitSide == SideLeft then
			dialogPortraitPanelLeft.Translate = Vector2(-PortraitOffset,0);
		elseif portraitSide == SideRight then
			dialogPortraitPanelRight.Translate = Vector2(PortraitOffset,0);
		end
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;
		
		if finishNotice then
			PlotManager:FinishPlotStep(PlotStepType.portraitOut);
		end
	end
end

--显示对话
function PlotPanel:Talk(res, side, text, notice)
	if curType ~= PlotStepType.none then
		PrintLog("-----------plot is playing, don't start new one!!!-----------");
	end

	plotPanel.Visibility = Visibility.Visible;
	plotContent.Visibility = Visibility.Hidden;
	plotImage.Visibility = Visibility.Hidden;
	plotShade.Visibility = Visibility.Hidden;	
	
	dialogPanel.Visibility = Visibility.Visible;
	dialogTwPanel.Visibility = Visibility.Hidden;
	
	
	
	
	
	local isHero = false;
	if 0 == res then
		res = ActorManager.hero.resID;
		isHero = true;
	end

	local data = resTableManager:GetRowValue(ResTable.npc, tostring(res));
	local taskid = Task:getMainTaskId();
	local name;
	--起名字后用正式名字
	if isHero and taskid > SystemTaskId.changeName then
		name = ActorManager.user_data.name;
	else
		name = data['name'];
	end	
	
	talkSide = side;
	if side == SideLeft then
		talkPanelLeft.Visibility = Visibility.Visible;
		talkPanelRight.Visibility = Visibility.Hidden;
		talkNameLeft.Text = name;
		talkContentLeft.Text = text;
	elseif side == SideRight then
		talkPanelLeft.Visibility = Visibility.Hidden;
		talkPanelRight.Visibility = Visibility.Visible;
		talkNameRight.Text = name;
		talkContentRight.Text = text;
	end
	
	curType = PlotStepType.npcTalk;
	elapseTime = 0;
	totalTime = timeOut;
	finishNotice = notice;
end

--显示对话
function PlotPanel:TalkTw(res, text, notice)
	if curType ~= PlotStepType.none then
		PrintLog("-----------plot is playing, don't start new one!!!-----------");
	end
	
	plotPanel.Visibility = Visibility.Visible;
	plotContent.Visibility = Visibility.Hidden;
	plotImage.Visibility = Visibility.Hidden;
	plotShade.Visibility = Visibility.Hidden;
	dialogTwPanel.Visibility = Visibility.Visible;
	dialogPanel.Visibility = Visibility.Hidden;
	
	local isHero = false;
	if 0 == res then
		res = ActorManager.hero.resID;
		isHero = true;
	end

	local data = resTableManager:GetRowValue(ResTable.npc, tostring(res));
	dialogTwPortrait.Image = GetPicture('portrait/' .. data['portrait'] .. '/portrait.ccz');
	local taskid = Task:getMainTaskId();
	--起名字后用正式名字
	if isHero and taskid > SystemTaskId.changeName then
		dialogTwName.Text = ActorManager.user_data.name;
	else
		dialogTwName.Text = data['name'];
	end
	
	arrowTwTranslate = dialogTwArrow.Translate;
	talkTwText = text;
	talkTwTextLen = string.len(text);
	dialogTwTalk.Text = text;
	
	curType = PlotStepType.npcTalkTw;
	elapseTime = 0;
	totalTime = timeOut;
	finishNotice = notice;
end

--黑幕淡入
function PlotPanel:BlackInShade(time, notice)
	if curType ~= PlotStepType.none then
		PrintLog("-----------plot is playing, don't start new one!!!-----------");
	end
	
	plotPanel.Visibility = Visibility.Visible;
	plotShade.Visibility = Visibility.Visible;

	--值可能小于一帧时，立即淡入
	if time < PlotManager.MinChangeTime then
		plotShade.Opacity = ShadeMaxOpacity;
		totalTime = 0;
	else
		plotShade.Opacity = 0;
		totalTime = time;
	end
	
	curType = PlotStepType.blackIn;
	elapseTime = 0;
	finishNotice = notice;
end

--黑幕淡出
function PlotPanel:BlackOutShade(time, notice)
	if curType ~= PlotStepType.none then
		PrintLog("-----------plot is playing, don't start new one!!!-----------");
	end
	
	plotPanel.Visibility = Visibility.Visible;

	--值可能小于一帧时，立即淡出
	if time < PlotManager.MinChangeTime then
		plotShade.Opacity = 0;
		totalTime = 0;
	else
		plotShade.Opacity = 1;
		totalTime = time;
	end	
	
	curType = PlotStepType.blackOut;
	elapseTime = 0;
	finishNotice = notice;
end

--字幕淡入
function PlotPanel:BlackInText(text, time, notice)
	if curType ~= PlotStepType.none then
		PrintLog("-----------plot is playing, don't start new one!!!-----------");
	end
	
	plotPanel.Visibility = Visibility.Visible;
	plotContent.Visibility = Visibility.Visible;
	plotContent.Text = text;
	
	--值可能小于一帧时，立即淡入
	if time < PlotManager.MinChangeTime then
		plotContent.Opacity = 1;
		totalTime = 0;
	else
		plotContent.Opacity = 0;
		totalTime = time;
	end
	
	curType = PlotStepType.blackInText;
	elapseTime = 0;
	finishNotice = notice;
end

--字幕淡出
function PlotPanel:BlackOutText(time, notice)
	if curType ~= PlotStepType.none then
		PrintLog("-----------plot is playing, don't start new one!!!-----------");
	end
	
	plotPanel.Visibility = Visibility.Visible;
	
	--值可能小于一帧时，立即淡出
	if time < PlotManager.MinChangeTime then
		plotContent.Opacity = 0;
		plotContent.Visibility = Visibility.Hidden;	
		totalTime = 0;
	else
		plotContent.Opacity = 1;
		totalTime = time;
	end
	
	curType = PlotStepType.blackOutText;
	elapseTime = 0;
	finishNotice = notice;
end

--图片淡入
function PlotPanel:BlackInImage(path, time, scale, x, y, notice)
	if curType ~= PlotStepType.none then
		PrintLog("-----------plot is playing, don't start new one!!!-----------");
	end
	
	plotPanel.Visibility = Visibility.Visible;
		plotImage.Visibility = Visibility.Visible;

	plotImage.Image = GetPicture(path);
	if nil ~= scale then
		plotImage.Scale = Vector2(scale, scale);
	else
		plotImage.Scale = Vector2(1, 1);
	end
	if nil ~= x and nil ~= y then
		plotImage.Translate = Vector2(x, y);
	else
		plotImage.Translate = Vector2(0, 0);
	end
	
	--值可能小于一帧时，立即淡入
	if time < PlotManager.MinChangeTime then
		totalTime = 0;
		plotImage.Opacity = 1;
	else
		totalTime = time;
		plotImage.Opacity = 0;
	end
	
	curType = PlotStepType.blackInImage;
	elapseTime = 0;
	finishNotice = notice;
end

--图片淡出
function PlotPanel:BlackOutImage(time, notice)
	if curType ~= PlotStepType.none then
		PrintLog("-----------plot is playing, don't start new one!!!-----------");
	end
	
	plotPanel.Visibility = Visibility.Visible;
		
	--值可能小于一帧时，立即淡入
	if time < PlotManager.MinChangeTime then
		plotImage.Visibility = Visibility.Hidden;
		plotImage.Opacity = 0;
		totalTime = 0;
	else
		plotImage.Opacity = 1;
		totalTime = time;
	end

	curType = PlotStepType.blackOutImage;
	elapseTime = 0;
	finishNotice = notice;
end

-- 下一张图片
function PlotPanel:onNext(Args)
	if curType == PlotStepType.blackOutImage or curType == PlotStepType.blackInImage then
		elapseTime = 100000;
	elseif curType == PlotStepType.none then
		PlotManager:Continue();
	end
end

-- side：0表示左边，1表示右边
function PlotPanel:PortraitIn(res, side, notice)
	if curType ~= PlotStepType.none then
		PrintLog("-----------plot is playing, don't start new one!!!-----------");
	end
	plotPanel.Visibility = Visibility.Visible;
	
	if 0 == res then
		res = ActorManager.hero.resID;
	end
	local data = resTableManager:GetRowValue(ResTable.npc, tostring(res));

	totalTime = PortraitInOutTime;
	portraitSide = side;
	if side == SideLeft then
		dialogPortraitPanelLeft.Translate = Vector2(-PortraitOffset,0);
		imagePortraitLeft.Image = GetPicture('portrait/' .. data['portrait'] .. '/portrait.ccz');
		imagePortraitLeft.Scale = Vector2(-0.73, 0.73);
	elseif side == SideRight then
		dialogPortraitPanelRight.Translate = Vector2(PortraitOffset,0);
		imagePortraitRight.Image = GetPicture('portrait/' .. data['portrait'] .. '/portrait.ccz');
		imagePortraitRight.Scale = Vector2(0.73, 0.73);
	end
	
	curType = PlotStepType.portraitIn;
	elapseTime = 0;
	finishNotice = notice;
end

function PlotPanel:PortraitOut(res, side, notice)
	if curType ~= PlotStepType.none then
		PrintLog("-----------plot is playing, don't start new one!!!-----------");
	end
	plotPanel.Visibility = Visibility.Visible;
	
	totalTime = PortraitInOutTime;
	portraitSide = side;
	if side == SideLeft then
		dialogPortraitPanelLeft.Translate = Vector2(0,0);
	elseif side == SideRight then
		dialogPortraitPanelRight.Translate = Vector2(0,0);
	end
	curType = PlotStepType.portraitOut;
	elapseTime = 0;
	finishNotice = notice;
end

function PlotPanel:ShadeIn()
	brushDialogShade.Visibility = Visibility.Visible;
end

function PlotPanel:ShadeOut()
	brushDialogShade.Visibility = Visibility.Hidden;
end




--隐藏
function PlotPanel:Hide()
	plotPanel.Visibility = Visibility.Hidden;
end

--对话点击后消失
function PlotPanel:onClickDialog()
	if curType ~= PlotStepType.none then
		dialogPanel.Visibility = Visibility.Hidden;
		local tmpType = curType;	--这里复制一份，然后修改本类，再将复制的传入到PlotManager，防止启动协程直接进行下次剧情时发现curType不为none
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;		
		if finishNotice then
			PlotManager:FinishPlotStep(tmpType);
		end
	end
end

--对话点击后消失
function PlotPanel:onClickDialogTw()
	if curType ~= PlotStepType.none then
		dialogTwPanel.Visibility = Visibility.Hidden;
		local tmpType = curType;	--这里复制一份，然后修改本类，再将复制的传入到PlotManager，防止启动协程直接进行下次剧情时发现curType不为none
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;
		
		if finishNotice then
			PlotManager:FinishPlotStep(tmpType);
		end
	end
end

--黑幕点击后消失
function PlotPanel:onClickShade()
	if curType ~= PlotStepType.none then
		local tmpType = curType;	--这里复制一份，然后修改本类，再将复制的传入到PlotManager，防止启动协程直接进行下次剧情时发现curType不为none
		curType = PlotStepType.none;
		elapseTime = 0;
		totalTime = 0;
		
		if finishNotice then
			PlotManager:FinishPlotStep(tmpType);
		end
	end
end

--获取剧情面板
function PlotPanel:getPlotPanel()
	return plotPanel;
end

--设置最长等待时间
function PlotPanel:SetTimeout(t)
	if t == 0 then
		timeOut = 10;
	else
		timeOut = t;
	end
end
