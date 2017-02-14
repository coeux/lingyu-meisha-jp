--runeEatPromptPanel.lua

--========================================================================
--符文吞噬提示界面

RuneEatPromptPanel =
	{
	};

--控件
local mainDesktop;
local runeEatPromptPanel;
local cmbPrompt1;
local cmbPrompt2;

--变量
local runeSrcPos = -1;
local runeDesPos = -1;
local srcRune = 0;
local desRune = 0;

--初始化面板
function RuneEatPromptPanel:InitPanel(desktop)
	--变量初始化
	runeSrcPos = -1;
	runeDesPos = -1;
	runeSrcId = 0;
	runeDesId = 0;
	
	--界面初始化
	mainDesktop = desktop;
	runeEatPromptPanel = Panel(mainDesktop:GetLogicChild('runeEatPromptPanel'));
	runeEatPromptPanel:IncRefCount();
	runeEatPromptPanel.Visibility = Visibility.Hidden;
	
	cmbPrompt1 = CombinedElement(runeEatPromptPanel:GetLogicChild('prompt1'));
	cmbPrompt2 = CombinedElement(runeEatPromptPanel:GetLogicChild('prompt2'));
end	

--销毁
function RuneEatPromptPanel:Destroy()
	runeEatPromptPanel:DecRefCount();
	runeEatPromptPanel = nil;
end	

--显示
function RuneEatPromptPanel:Show()
	--增加吞噬提示
	local srcData = resTableManager:GetRowValue(ResTable.rune, tostring(srcRune.resid));
	local desData = resTableManager:GetRowValue(ResTable.rune, tostring(desRune.resid));
	
	local font = uiSystem:FindFont('huakang_20');
	cmbPrompt1:RemoveAllChildren();
	cmbPrompt1:AddText('Lv' .. desData['level'] , Configuration.WhiteColor, font);
	cmbPrompt1:AddText(desData['name'], QualityColor[desData['quality']], font);
	cmbPrompt1:AddText(LANG_runeEatPromptPanel_1 .. srcData['level'] , Configuration.WhiteColor, font);
	cmbPrompt1:AddText(srcData['name'], QualityColor[srcData['quality']], font);
	cmbPrompt2:RemoveAllChildren();
	cmbPrompt2:AddText(LANG_runeEatPromptPanel_2 .. (srcRune.exp + srcData['baseexp']) .. LANG_runeEatPromptPanel_3, Configuration.WhiteColor, font);
	
	--设置模式对话框
	mainDesktop:DoModal(runeEatPromptPanel);	
end

--隐藏
function RuneEatPromptPanel:Hide()
	--取消模式对话框
	mainDesktop:UndoModal();	
end

--========================================================================
--点击事件

--显示
function RuneEatPromptPanel:onShow(srcPos, desPos, sRune, dRune)
	runeSrcPos = srcPos;
	runeDesPos = desPos;
	srcRune = sRune;
	desRune = dRune;
	MainUI:Push(self);
end

--显示
function RuneEatPromptPanel:onEat()
	self:onClose();
	RunePanel:switchPos(runeSrcPos, runeDesPos)
end

--关闭
function RuneEatPromptPanel:onClose()
	MainUI:Pop();
end
