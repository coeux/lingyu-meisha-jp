--fightBigPicPanel.lua
--==============================================================================================
--立绘动画

FightBigPicPanel =
{
  card = nil;
};

--控件
local mainDesktop;
local panel;

local light1;
local light2;
local start1;
local start2;
local start3;
local skillPanel;
local skillName;
local navi;
local text;

local effect_back = nil;
local effect_front = nil;

local final_count = 60;

local x, y = 0, 0;

local controlInfo = {
  ctl_navi = {
    moves = {
      {
        pos = { origin = { x = -1300, y = 100 }, final = { x = 0, y = 20 } },
        start_time = 0,
      end_time = 10,
      motion = MotionType.linear
    },
    {
      pos = { origin = { x = 0, y = 10 }; final = { x = 50, y = 0 }; };
      start_time = 10;
    end_time = 90;
    motion = MotionType.linear;
  },
};
  };
  ctl_light1 = {
    moves = {
      {
        pos = { origin = { x = -570, y = 233 }; final = { x = 0, y = 0 }; };
      end_time = 20;
      motion = MotionType.linear;
    }
  }
};
ctl_light2 = {
  moves = {
    {
      pos = { origin = { x = 570, y = -233 }; final = { x = 0, y = 0 }; };
    end_time = 20;
    motion = MotionType.linear;
  }
}
  };
  ctl_star1 = {
    moves = {
      {
        opacity = { origin = 0; final = 0; } ;
      end_time = 100;
      motion = MotionType.inExpo;
    },
      {
        --scale = { origin = { x = 0, y = 0 }; final = { x = 1, y = 1 }; };
        opacity = { origin = 0; final = 1; } ;
        start_time = 100;
      end_time = 150;
      motion = MotionType.inExpo;
    }
  }
};
ctl_star2 = {
  moves = {
      {
        opacity = { origin = 0; final = 0; } ;
      end_time = 100;
      motion = MotionType.inExpo;
    },
    {
      --scale = { origin = { x = 0, y = 0 }; final = { x = 1, y = 1 }; };
      opacity = { origin = 0; final = 1; } ;
      start_time = 100;
    end_time = 150;
    motion = MotionType.inExpo;
  }
}
  };
  ctl_star3 = {
    moves = {
      {
        opacity = { origin = 0; final = 0; } ;
      end_time = 100;
      motion = MotionType.inExpo;
    },
      {
        --scale = { origin = { x = 0, y = 0 }; final = { x = 1, y = 1 }; };
        opacity = { origin = 0; final = 1; } ;
        start_time = 100;
      end_time = 150;
      motion = MotionType.inExpo;
    }
  }
};
ctl_text = {
  moves = {
    {
      size = { origin = {x = 0, y = 100 }; final = {x = 0, y = 100}; } ;
    end_time = 60;
  },
    {
      size = { origin = {x = 0, y = 100 }; final = {x = 900, y = 100}; } ;
      start_time = 60;
    end_time = 120;
    motion = MotionType.inExpo;
  }
}
  };
  ctl_skillPanel = {
    moves = {
      {
        size = { origin = {x = 0, y = 0 }; final = {x =0, y = 0}; } ;
        start_time = 0;
      end_time = 20;
      motion = MotionType.inExpo;
    },
      {
        size = { origin = {x = 0, y = 100 }; final = {x = 700, y = 100}; } ;
        start_time = 20;
      end_time = 80;
      motion = MotionType.inExpo;
    }
  }
};
};
--============================================================================================
--初始化
function FightBigPicPanel:InitPanel(desktop)
  self.count = 0;

  --界面初始化
  mainDesktop = desktop;
  panel = mainDesktop:GetLogicChild('bigPicPanel');
  panel.Visibility = Visibility.Hidden;
  panel.ZOrder = PanelZOrder.BigPic;

  --controls
  local bg = panel:GetLogicChild('bg');
  --bg.Background = CreateTextureBrush('fight/fight_Big_bg.ccz', 'fight');

  light1 = panel:GetLogicChild('light1');
  light2 = panel:GetLogicChild('light2');

  --light1.Background = CreateTextureBrush('fight/fight_line.ccz', 'fight')
  --light2.Background = CreateTextureBrush('fight/fight_line.ccz', 'fight')

  star1 = panel:GetLogicChild('star1');
  star2 = panel:GetLogicChild('star2');
  star3 = panel:GetLogicChild('star3');

  --star1.Image = GetPicture('fight/fight_guang1.ccz');
  --star2.Image = GetPicture('fight/fight_guang1.ccz');
  --star3.Image = GetPicture('fight/fight_guang1.ccz');
  star1.Size = Size(300, 300);
  star2.Size = Size(300, 300);
  star3.Size = Size(300, 300);

  skillPanel = panel:GetLogicChild('layer'):GetLogicChild('skillPanel');
  skillName = skillPanel:GetLogicChild('name');
  navi = panel:GetLogicChild('navi');

  navi.TransformPoint = Vector2(0, 0.5);
  navi.Scale = Vector2(1.2, 1.2);
  text = panel:GetLogicChild('fg'):GetLogicChild('text');


  controlInfo.ctl_navi.obj = navi;
  controlInfo.ctl_light1.obj = light1;
  controlInfo.ctl_light2.obj = light2;

  controlInfo.ctl_star1.obj = star1;
  controlInfo.ctl_star2.obj = star2;
  controlInfo.ctl_star3.obj = star3;

  controlInfo.ctl_text.obj = text;
  controlInfo.ctl_skillPanel.obj = skillPanel;


  mainDesktop:AddChild(panel);
  --]]
end

--更新
function FightBigPicPanel:Update(elapse)
  if not panel then
    return;
  end

  if panel.Visibility == Visibility.Hidden then
    return;
  end

  self.count = self.count + 1;

  if self.count > final_count then 
    self:onClose();
  end


  for _, control in pairs(controlInfo) do 
    local obj = control.obj;
    for _, move in ipairs(control.moves) do 
      local pos         = move.pos;
      local scale       = move.scale;
      local size        = move.size;
      local start_time  = move.start_time;
      local end_time    = move.end_time;
      local motion_func = move.motion;

      --填充默认值
      if start_time == nil or start_time < 0 then start_time = 0 end;
      if motion_func == nil then motion_func = MotionType.linear end;

      local remain_time = end_time - start_time
      local delta = (self.count - start_time) / remain_time

      if delta >= 0 and delta <= 1 then
        if opacity then
          obj.Opacity = 0.9 * (opacity.origin + ( scale.final - scale.origin ) * motion_func(delta));
        end
        if scale then
          obj.Scale = Vector2( 
          scale.origin.x + ( scale.final.x - scale.origin.x ) * motion_func(delta),
          scale.origin.x + ( scale.final.x - scale.origin.x ) * motion_func(delta)
          );
        end
        if pos then
          obj.Translate = Vector2(
          pos.origin.x + ( pos.final.x - pos.origin.x ) * motion_func(delta),
          pos.origin.y + ( pos.final.y - pos.origin.y ) * motion_func(delta)
          );
        end
        if size then
          obj.Size = Size(
          size.origin.x + ( size.final.x - size.origin.x ) * motion_func(delta),
          size.origin.y + ( size.final.y - size.origin.y ) * motion_func(delta) 
          )
        end
      end
    end
  end
  --[[
  navi.Translate = Vector2(naviOrigin.x + self.count * 8, naviOrigin.y - self.count * 4);
  bg.Translate = Vector2(bgOrigin.x - self.count * 8, bgOrigin.y + self.count * 4);
  --]]
end

--销毁
function FightBigPicPanel:Destroy()
  --DestroyBrushAndImage('fight/fight_Big_bg.ccz', 'fight');
  --DestroyBrushAndImage('fight/fight_line.ccz', 'fight');
end

--显示
function FightBigPicPanel:Show(card)
  FightManager:Pause(false);
  FightSkillCardManager:Hide();
  panel.Visibility = Visibility.Visible;
  self.count = 0;
  self.card = card;

  local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(card.info.actor.resID));
  local naviImage = naviInfo['role_path'];
  local skill_word = naviInfo['skill_word'];

  --设置技能文本
  text.Text = skill_word;

  Debug.print("skill = " .. skill_word);
  navi.Image = GetPicture('navi/' .. naviImage .. '.ccz');


  local skill_name = resTableManager:GetValue(ResTable.skill, tostring(card.info.skill.m_resid), 'name');
  skillName.Text = skill_name;


  --立绘特效
	effect_back = uiSystem:CreateControl('ArmatureUI');
	effect_back:LoadArmature('back_lihui');
	effect_back.Pick = false;
  effect_back.Translate = Vector2(mainDesktop.Width / 2, mainDesktop.Height / 2);
  --effect_back:SetScale(0.67, 0.67)
	--
	effect_front = uiSystem:CreateControl('ArmatureUI');
	effect_front:LoadArmature('front_lihui');
	effect_front.Pick = false;
  effect_front.Translate = Vector2(mainDesktop.Width / 2, mainDesktop.Height / 2);

  --effect_front:SetScriptAnimationCallback(
	
	panel:AddChild(effect_front);
	panel:AddChild(effect_back);

  -- navi.Zorder = 3, 所以前排用4， 后排用2
  effect_front.ZOrder = 4;
  effect_back.ZOrder = 2;

	effect_front:SetAnimation('play');
	effect_back:SetAnimation('play');

end

--隐藏
function FightBigPicPanel:Hide()
  panel.Visibility = Visibility.Hidden;
end

--退出游戏
function FightBigPicPanel:onClose()
  self:Hide();
  FightSkillCardManager:Show();
  self.card.info.actor:SetShowSkillFlag(true);
  self.card.info.skill:SetReleaseFlag(true);
  if FightManager.mFightType == FightType.noviceBattle and PlotsArg.isSecondAngerMax then
    PlotsArg.isSecondAngerMax = false
  else
    FightManager:Continue();
  end
  
  star1 = nil
  star2 = nil
  star3 = nil
end



