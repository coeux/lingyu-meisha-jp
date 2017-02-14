--taskGuidePanel.lua

--========================================================================
--自动任务界面

TaskGuidePanel =
	{
	};

--控件
local mainDesktop;
local taskGuidePanel;
local guideImage;
local btnGuide;
local labelGuideName;



--初始化面板
function TaskGuidePanel:InitPanel(desktop)
	--界面初始化
	mainDesktop = desktop;
	taskGuidePanel = Panel(desktop:GetLogicChild('taskGuidePanel'));
	taskGuidePanel:IncRefCount();
	
	guideImage = ImageElement(taskGuidePanel:GetLogicChild('guideImage'));
	labelGuideName = Label(taskGuidePanel:GetLogicChild('guideName'));
	btnGuide = Button(taskGuidePanel:GetLogicChild('taskGuide'));
	--临时 去掉任务引导（下面还有一处）
	--taskGuidePanel.Visibility = Visibility.Visible;
	taskGuidePanel.Visibility = Visibility.Hidden;
end	

--销毁
function TaskGuidePanel:Destroy()
	taskGuidePanel:DecRefCount();
	taskGuidePanel = nil;
end

--更新界面内容
function TaskGuidePanel:Change(image, guideName)
	if nil == image or nil == guideName then
		return;
	end
	guideImage.Image = image;
	--btnGuideImage.AutoSize = true;
	labelGuideName.Text = guideName;
end

function TaskGuidePanel:onDown()
	guideImage.Scale = Vector2(1.1, 1.1);
end

function TaskGuidePanel:onUp()
	guideImage.Scale = Vector2(1.0, 1.0);
end

--显示
function TaskGuidePanel:Show()
	--临时 
	--taskGuidePanel.Visibility = Visibility.Visible;
	taskGuidePanel.Visibility = Visibility.Hidden;
end

--隐藏
function TaskGuidePanel:Hide()
	taskGuidePanel.Visibility = Visibility.Hidden;
end

--返回自动任务按钮
function TaskGuidePanel:GetGuideButton()
	return btnGuide;
end

--返回自动任务面板
function TaskGuidePanel:GetGuidePanel()
	return taskGuidePanel;
end
