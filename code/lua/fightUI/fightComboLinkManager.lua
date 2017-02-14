--fightComboLinkManager.lua

--========================================================================
--Combo链管理器


FightComboLinkManager = {
   desktop = nil;          -- 当前桌面
   cl_panel = nil;         -- 主Panel
   cl_stack = nil;         -- 控件栈
   enable = true;	   -- 是否开启本功能
   skillResult = nil;      -- 当前技能造成的结果
}

-- 初始化
function FightComboLinkManager:Initialize(desktop)
  if not self.enable then return end;
   self.desktop = desktop;
   self.cl_panel = desktop:GetLogicChild('ComboLinkPanel');
   self.cl_panel.Margin = Rect(150, 0, 0, 0);
   self.cl_panel.Size = Size(430, 85);
   self.cl_panel.Pick = false;
   self.cl_panel.Visibility = Visibility.Visible;
   self.cl_panel.Opacity = 0;

   self.cl_stack = self.cl_panel:GetLogicChild('ComboLinkStack');
   self.cl_stack.Margin = Rect(0, 0, 0, 0);
   self.cl_stack.Size = Size(420, 85);
   self.cl_stack.Border = Rect(10, 0, 0, 0);
   self.cl_stack.Pick = false;

   self.cl_panel.Storyboard = "";
   self.skillResult = nil;
   self:Clear();
end

-- 清理
function FightComboLinkManager:Clear()
  if not self.enable then return end;
  self.cl_stack:RemoveAllChildren();
  self.skillResult = nil;
end

-- 销毁
function FightComboLinkManager:Destroy()
  if not self.enable then return end;
end

-- 更新
function FightComboLinkManager:Update(Elapse)
  if not self.enable then return end;
end

-- 生成Combo Item样式
function FightComboLinkManager:GenerateComboItem(skill)

  local skill_data = resTableManager:GetValue(ResTable.skill, tostring(skill.m_resid), {'name',  'skill_class', 'icon', 'count'});
  local name = skill_data['name']
  local icon = GetPicture('icon/' .. skill_data['icon'] .. '.ccz');
  local skill_type_image = FightSkillCardManager:GetSkillClassImage(skill_data['skill_class'], skill_data['count']);

  local panel = uiSystem:CreateControl('Panel');
  panel.Size = Size(48, 48);
  panel.TransformPoint = Vector2(0, 0.5);
  panel.Background = CreateTextureBrush('fight/combo_item_bg.ccz', 'fight');

  local comboItem = uiSystem:CreateControl('ImageElement');
  comboItem.Size = Size(40, 40);
  comboItem.AutoSize = false;
  comboItem.Image = icon;
  comboItem.Margin = Rect(4, 4, 4, 4);
  panel:AddChild(comboItem);

  local skillClassImage = uiSystem:CreateControl('ImageElement');
  skillClassImage.Image = skill_type_image;
  skillClassImage.Horizontal = ControlLayout.H_LEFT;
  skillClassImage.Vertical = ControlLayout.V_TOP;
  skillClassImage.Scale = Vector2(0.7, 0.7);
  skillClassImage.TransformPoint = Vector2(0,0);
  panel:AddChild(skillClassImage);
--[[
  local skillNameLabel = uiSystem:CreateControl('Label');
  skillNameLabel.Text = name;
  skillNameLabel:SetFont('FZ_17_miaobian_COMBO');
  skillNameLabel.TextAlignStyle = TextFormat.MiddleCenter;
  skillNameLabel.Size = Size(78, 21);
  skillNameLabel.Margin = Rect(0, 0, 0, -20);
  skillNameLabel.Horizontal = ControlLayout.H_CENTER;
  skillNameLabel.Vertical = ControlLayout.V_BOTTOM;
  comboItem:AddChild(skillNameLabel);
]]
  panel.Storyboard = 'storyboard.ComboLinkItemShow';

  --预先获取技能结果，在下一个技能出现的时候使用
  self.skillResult = FightComboQueue:GetSkillResultType(skill.m_resid);
  return panel;

end

-- 生成箭头
function FightComboLinkManager:GenerateArrow()
   local arrowItem = uiSystem:CreateControl('ImageElement');
   arrowItem.Size = Size(25, 25);
   arrowItem.Image = GetPicture('fight/arrow.ccz');
   arrowItem.Storyboard = 'storyboard.ComboLinkArrowShow';

   local resultText = uiSystem:CreateControl('Label');
   resultText.Text = self.skillResult;
   resultText:SetFont('FZ_16_noborder');
   resultText.TextAlignStyle = TextFormat.MiddleCenter;
   resultText.Size = Size(40, 20);
   resultText.Translate = Vector2(-9, -20);

   arrowItem:AddChild(resultText);

   return arrowItem;
end

function FightComboLinkManager:RemoveLeftMostItems()
  if not self.enable then return end;
   local item = self.cl_stack:GetLogicChild(0);
   local arrow = self.cl_stack:GetLogicChild(1);
   local sb1 = item:SetUIStoryBoard("storyboard.ComboLinkItemHide");
   local sb2 = arrow:SetUIStoryBoard("storyboard.ComboLinkArrowHide");
   -- 当comboItem消失之后，统一删除前两个元素
   sb1:SubscribeScriptedEvent('StoryboardInstance::FinishedEvent', 'FightComboLinkManager:onHide');
end


-- 添加Combo Item到Combo Link
function FightComboLinkManager:AppendItem(comboInfo)
  if not self.enable then return end;
   self.cl_panel.Storyboard = 'storyboard.FadeOut';
   local item_count = self.cl_stack:GetLogicChildrenCount();

   if item_count == 9 then
      self:RemoveLeftMostItems()
   end

   if item_count > 0 then       -- 当没有元素的时候，不需要创建箭头
      local arrowItem = self:GenerateArrow();
      self.cl_stack:AddChild(arrowItem);
   end


   local comboItem = self:GenerateComboItem(comboInfo);
   self.cl_stack:AddChild(comboItem);
end

function FightComboLinkManager:onHide()
  if not self.enable then return end;
   self.cl_stack:RemoveChild(self.cl_stack:GetLogicChild(0)); -- ok, first item destroyed
   self.cl_stack:RemoveChild(self.cl_stack:GetLogicChild(0)); -- ok, first arrow destroyed
end
