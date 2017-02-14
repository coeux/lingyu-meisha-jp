CardEventPosterPanel =
{
  poster = {
    ['pic'] = 'background/card_event_poster.png',
    ['dir'] = 'background'
  }
}

local panel
local pp_poster

function CardEventPosterPanel:InitPanel(desktop)
  panel = desktop:GetLogicChild('CardEventPosterPanel')
  panel.Visibility = Visibility.Hidden
  panel:IncRefCount()
  pp_poster = panel:GetLogicChild('poster')
  pp_poster:SubscribeScriptedEvent('UIControl::MouseDownEvent',
                                   'CardEventPosterPanel:onOpen');
end

function CardEventPosterPanel:Show()
  panel.Visibility = Visibility.Visible
  pp_poster.Background = CreateTextureBrush(self.poster.pic, self.poster.dir)
  StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, '')
end

function CardEventPosterPanel:Hide()
  panel.Visibility = Visibility.Hidden
  StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 
                              'CardEventPosterPanel:onDestroy')
end

function CardEventPosterPanel:onClose()
  self:Hide()
end

function CardEventPosterPanel:Destroy()
  panel:DecRefCount()
  panel = nil
end

function CardEventPosterPanel:onDestroy()
  pp_poster.Background = nil
  DestroyBrushAndImage(self.poster.pic, self.poster.dir)
  StoryBoard:OnPopUI()
end

function CardEventPosterPanel:onOpen()
  --CardEventPanel:onShow()
  CardEventPanel:enterCardEvent();
  self:onClose()
end
