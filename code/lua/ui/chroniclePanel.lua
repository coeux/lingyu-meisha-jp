--chroniclePanel.lua
--=============================================================================================
ChroniclePanel =
{
  story = {};
  dayRecord = {};
  today = nil; -- 20150101
  days = 0;   --开服至今日共多少日子
  year = nil;
  month = nil;
  day = nil;
  finished = false;
  CAN_READ = 2;  --任务完成情况，可读
  Done = 1;     --任务完成情况，完成
  Undone = 0;   --任务完成情况，未完成
  first = true;
};

local SINGLE_TIMES_CONSUME_YB = 20;

local mainDesktop;
local panel;
-- dayPanel
local dayPanel;
local YM;
local WN;
local D;
local fit;
local unfit;
local btnDetail;
local basePanel;
local textPanel;
local describe;
-- monthPanel
local monthPanel;
local btnPreYear;
local btnPreMonth;
local btnNextYear;
local btnNextMonth;
local YearMonth;
local stackPanel;
local btnRetrieve;
local bg;

local viewYear = 0;
local viewMonth = 0;
local callback;
local h = 0;

--=============================================================================================
function ChroniclePanel:InitPanel(desktop)
  h = 0;
  mainDesktop = desktop;
  panel = desktop:GetLogicChild('chroniclePanel');
  panel:IncRefCount();
  self:InitData();
  self:InitBorder();
  self:InitDayPanel();
  self:InitMonthPanel();

  bg = panel:GetLogicChild('diban');
end

function ChroniclePanel:InitData()
  callback = nil;
  self.first = true;

  local tc = os.date("*t", ActorManager.user_data.reward.cur_sec);
  self.today = tc.year * 10000 + tc.month * 100 + tc.day;
  self.year, self.month, self.day = tc.year, tc.month, tc.day;
  viewYear, viewMonth = self.year, self.month;
  local serverTime = ActorManager.user_data.reward.server_ctime;
  local currentTime = ActorManager.user_data.reward.cur_sec;
  self.days = math.ceil((currentTime - serverTime) / 3600 / 24);
end

function ChroniclePanel:InitBorder()
  local border = panel:GetLogicChild('diban');
  local btnClose = border:GetLogicChild('close');
  btnClose:SubscribeScriptedEvent('Button::ClickEvent', 'ChroniclePanel:onClose');
end

function ChroniclePanel:InitDayPanel()
  dayPanel = panel:GetLogicChild('todayPanel');
  YM = dayPanel:GetLogicChild('year');
  WN = dayPanel:GetLogicChild('week');
  D = dayPanel:GetLogicChild('day');
  fit = dayPanel:GetLogicChild('fit');
  unfit = dayPanel:GetLogicChild('taboo');
  basePanel = panel:GetLogicChild('todayPanel'):GetLogicChild('p');
  textPanel = basePanel:GetLogicChild('p');
  describe = textPanel:GetLogicChild('desc');
  textPanel:SubscribeScriptedEvent('UIControl::MouseMoveEvent', 'ChroniclePanel:onMove');
  btnDetail = dayPanel:GetLogicChild('detailsButton');
  local btnHistory = dayPanel:GetLogicChild('histroy');
  btnHistory:SubscribeScriptedEvent('Button::ClickEvent', 'ChroniclePanel:onHistory');
  btnDetail:SubscribeScriptedEvent('Button::ClickEvent', 'ChroniclePanel:onDetail');
end

function ChroniclePanel:InitMonthPanel()
  monthPanel = panel:GetLogicChild('calendarPanel');
  btnPreYear = monthPanel:GetLogicChild('top'):GetLogicChild('left1');
  btnPreMonth = monthPanel:GetLogicChild('top'):GetLogicChild('left2');
  btnNextMonth = monthPanel:GetLogicChild('top'):GetLogicChild('right2');
  btnNextYear = monthPanel:GetLogicChild('top'):GetLogicChild('right1');
  YearMonth = monthPanel:GetLogicChild('top'):GetLogicChild('year');
  stackPanel = monthPanel:GetLogicChild('stackPanel');
  btnRetrieve = monthPanel:GetLogicChild('detailsButton');
  local btnToday = monthPanel:GetLogicChild('today');
  btnPreYear.Tag, btnPreMonth.Tag, btnNextMonth.Tag, btnNextYear.Tag = 1, 2, 3, 4;
  btnPreYear:SubscribeScriptedEvent('Button::ClickEvent', 'ChroniclePanel:onChange');
  btnPreMonth:SubscribeScriptedEvent('Button::ClickEvent', 'ChroniclePanel:onChange');
  btnNextMonth:SubscribeScriptedEvent('Button::ClickEvent', 'ChroniclePanel:onChange');
  btnNextYear:SubscribeScriptedEvent('Button::ClickEvent', 'ChroniclePanel:onChange');
  btnToday:SubscribeScriptedEvent('Button::ClickEvent', 'ChroniclePanel:onToday');
  btnRetrieve:SubscribeScriptedEvent('Button::ClickEvent', 'ChroniclePanel:onRetrieve');
end
--=============================================================================================
function ChroniclePanel:Show()
  bg.Background = CreateTextureBrush('background/calendar_book.ccz', 'background');
  self:moveIn();
end

function ChroniclePanel:isShow()
  -- return panel.Visibility == Visibility.Visible;
end

function ChroniclePanel:reqData()
  if self.first then
    NetworkMsg_Chronicle:reqChronicle(self.year * 100 + self.month); --请求本月
    NetworkMsg_Chronicle:reqChronicleSignAll(); --请求所有记录
    self.first = false;
  else
    HomePanel:onChronicle()
  end
end

function ChroniclePanel:onShow(todo, cb)
  if not self:isCanBeShow() then return end;
  if todo then todo() end;
  callback = cb;
  self:onShowDay();
  self:refreshMonthPanel(self.year, self.month)
  MainUI:Push(self);
end

function ChroniclePanel:Hide()
  bg.Background = nil;
  DestroyBrushAndImage('background/calendar_book.ccz', 'background');
  self:moveOut();
end

function ChroniclePanel:onClose()
  MainUI:Pop();
  self:moveOut();
  if callback then callback() end;
  callback = nil;
end

function ChroniclePanel:Destroy()
  panel:DecRefCount();
  panel = nil;
end

function ChroniclePanel:moveIn()
  panel.Visibility = Visibility.Visible;
  panel.Storyboard = 'storyboard.moveIn_1';
end

function ChroniclePanel:moveOut()
  panel.Storyboard = 'storyboard.moveOut_1';
  panel.Visibility = Visibility.Hidden;
end
--=============================================================================================
function ChroniclePanel:onHistory()
  dayPanel.Visibility = Visibility.Hidden;
  monthPanel.Visibility = Visibility.Visible;
  viewYear, viewMonth = self.year, self.month;
  self:refreshMonthPanel(self.year, self.month);
end

function ChroniclePanel:onDetail()
  ChroniclePanel:showRewardPanel();
end

function ChroniclePanel:onToday()
  self:onShowDay()
end

--显示某日详情
function ChroniclePanel:onShowDay(year, month, day)
  if not year then
    year, month, day = self.year, self.month, self.day
  end
  local td = self.story[year][month][day];
  if td and td.progress and td.progress.state == self.Done then
    btnDetail.Visibility = Visibility.Hidden;
    describe.Text = td.finish_story;
    describe:SetSize(basePanel.Size.Width, self:TextHeight(td.finish_story));
  else
    btnDetail.Visibility = Visibility.Visible;
    describe.Text = td.pre_story;
    describe:SetSize(basePanel.Size.Width, self:TextHeight(td.pre_story));
  end
  YM.Text = year .. " - " .. (month < 10 and "0" or "") .. month;
  D.Text = tostring(day);
  WN.Text = LANG_chroniclePanel_0[td.week];

  dayPanel.Visibility = Visibility.Visible;
  monthPanel.Visibility = Visibility.Hidden;
end

function ChroniclePanel:isCanBeShow()
  local td = self.story[self.year][self.month][self.day];
  if not td then
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_chroniclePanel_10);
    return nil;
  end
  return true;
end

function ChroniclePanel:onChange(Args)
  local args = UIControlEventArgs(Args);
  local t = args.m_pControl.Tag;

  local tY, tM = 0, 0;
  if t == 1 then
  tY, tM = viewYear - 1, viewMonth;
  elseif t == 2 then
  tY, tM = viewYear, viewMonth - 1;
  elseif t == 3 then
  tY, tM = viewYear, viewMonth + 1;
  elseif t == 4 then
  tY, tM = viewYear + 1, viewMonth;
  end
  local ym = tY * 100 + tM;
  if type(self.dayRecord[tostring(ym)]) == 'table' then
    viewYear, viewMonth = tY, tM;
    if self.story[tY][tM] then
    self:refreshMonthPanel(tY, tM);
    else
    NetworkMsg_Chronicle:reqChronicle(ym);
    end
  else
    print("no record, ym = " .. ym);
  end
end

function ChroniclePanel:onShowStory(Args)
  local args = UIControlEventArgs(Args);
  local ymd = args.m_pControl.Tag;

  local y, m, d = self:YMD(ymd)
  local mr = self.story[y][m];
  local isRead = mr[d] and mr[d].progress and mr[d].progress.state == self.CAN_READ
  if isRead then
    TaskDialogPanel:ChronicleDialog(y, m, d)
  else
    self:onShowDay(y, m, d)
  end
end

function ChroniclePanel:onRetrieve()
  local count = 0;
  local curDay = self.day;
  local unsign = "";
  for i = 7, 1, -1 do
    local td = self.story[self.year][self.month][curDay - i];
    if td and (not td.progress or td.progress.state == self.Undone) then
      count = count + 1;
      unsign = unsign .. " " .. tostring(curDay - i);
    end
  end
  if count ~= 0 then
    local okDelegate = Delegate.new(ChroniclePanel, ChroniclePanel.onReqRetrieve, 0);
    MessageBox:ShowDialog(MessageBoxType.OkCancel, string.format(LANG_chroniclePanel_11, count * SINGLE_TIMES_CONSUME_YB, unsign), okDelegate, nil);
  else
    Toast:MakeToast(Toast.TimeLength_Long, LANG_chroniclePanel_12);
  end
end

function ChroniclePanel:onReqRetrieve()
  NetworkMsg_Chronicle:reqChronicleSignRetrieve();
end

function ChroniclePanel:TextHeight(str)
  local l = 0;
  -- 13 文本框宽度（汉字个数）, 30 文本框对应字体高度
  string.gsub(str,"([^%c]+)", function(s) l = l + math.ceil(utf8.len(s) / 13) end);
  h = l * 30;
  h = h > basePanel.Size.Height and h or basePanel.Size.Height;
  return h;
end

function ChroniclePanel:onMove(Args)
  local args = UIControlEventArgs(Args);
  local translate = args.m_pControl.Translate;
  if translate.y <= basePanel.Size.Height - h then
    args.m_pControl.Translate = Vector2(0, basePanel.Size.Height - h);
  elseif translate.y >= 0 then
    args.m_pControl.Translate = Vector2(0, 0);
  else
    args.m_pControl.Translate = Vector2(0, translate.y);
  end
end

function ChroniclePanel:refreshMonthPanel(year, month)
  YearMonth.Text = year .. " - " .. (month < 10 and "0" or "") .. month;
  if self.story[year] and self.story[year][month] then
    stackPanel:RemoveAllChildren();
    local o = customUserControl.new(stackPanel, 'NewWeekTemplate');
    o.initHead();
    local d = 1;
    for i = 1, 6 do
      o = customUserControl.new(stackPanel, 'NewWeekTemplate');
      d = o.initWithMonth(year, month, d);
    end
  end
  btnRetrieve.Visibility = Visibility.Visible;
  btnRetrieve.Enable = false;
  if self.year == year and self.month == month then
    local ym = self.year * 100 + self.month;
    for i = 1, 7 do
      if not next(self.dayRecord) then
        btnRetrieve.Enable = true;
        break;
      end
      if self.dayRecord[tostring(ym)] and next(self.dayRecord[tostring(ym)]) and not self.dayRecord[tostring(ym)][self.day - i] then
        btnRetrieve.Enable = true;
        break;
      end
    end
  end
end
--=============================================================================================
function ChroniclePanel:isFinished(year, month, day)
  local ym = tostring(year*100 + month);
    if self.dayRecord[ym] and self.dayRecord[ym][day] then
      return true;
    end
  return false;
end

function ChroniclePanel:factory(msg)
  local year, month = self:YM(msg.chronicle_month.id);
  local progress = {};
  for _, p in pairs(msg.chronicle_progress) do
    progress[(p.chronicle_story_id) % 100] = p;
  end
  if not self.story[year] then
    self.story[year] = {};
  end
  local s_year = self.story[year];
  self.story[year][month] = msg.chronicle_month;
  local s_month = s_year[month];
  local base = KimLarssonYearMonth(year, month);
  for _, v in pairs(msg.chronicle_day) do
    v.week = (base + v.day) % 7;
    s_month[v.day] = v;
    if month == self.month then
      s_month[v.day].progress = progress[v.day];
    end
  end
  if msg.chronicle_month.id == self.year * 100 + self.month then
    if s_month[self.day].progress and s_month[self.day].progress.state == self.Done then
      self.finished = true;
    end
  end
  self:refreshMonthPanel(year, month);
end

function ChroniclePanel:allSignResult(msg)
  for k, v in pairs(msg.record) do
    self.dayRecord[k] = {};
    local exists = false;
    for i = 0, 31 do
      if bit.band(v, bit.lshift(1, i)) ~= 0 then
        exists = true;
        self.dayRecord[k][i+1] = true;
      end
    end
    if not exists then
      self.dayRecord[k] = nil;
    end
  end
  HomePanel:onChronicle();
end

function ChroniclePanel:signResult(msg)
  local setFinish = function(signProgress, ymd)
    signProgress.progress = {};
    signProgress.progress.state = self.Done;
    signProgress.progress.step = 0;
    signProgress.progress.chronicle_story_id = ymd
    describe.Text = signProgress.finish_story;
    describe:SetSize(basePanel.Size.Width, self:TextHeight(signProgress.finish_story));
    btnDetail.Visibility = Visibility.Hidden;
  end
  if msg.chronicle_story_id == self.today and msg.state == self.Done then
    self.finished = true;
    local signProgress = self.story[self.year][self.month][self.day];
    setFinish(signProgress, self.today);
    ActorManager.user_data.chronicle.is_sign = true;
  elseif msg.state == self.Done then
    local y, m, d = self:YMD(msg.chronicle_story_id)
    local signProgress = self.story[y][m][d];
    setFinish(signProgress, msg.chronicle_story_id);
    self:onShowDay(y, m, d)
  end
end

function ChroniclePanel:showRewardPanel()
  local chronicleRewardPanel = mainDesktop:GetLogicChild('ChronicleRewardPanel');
  chronicleRewardPanel.Visibility = Visibility.Visible;
  local item = chronicleRewardPanel:GetLogicChild('Panel'):GetLogicChild('item');
  local itembg = item:GetLogicChild('itembg');
  local getBtn = chronicleRewardPanel:GetLogicChild('Panel'):GetLogicChild('getBtn');
  item.Image = GetPicture('icon/10005.ccz');
  itembg.Image = GetPicture('home/head_frame_1.ccz');
  getBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ChroniclePanel:CloseRewardPanel');
end

function ChroniclePanel:CloseRewardPanel()
  local chronicleRewardPanel = mainDesktop:GetLogicChild('ChronicleRewardPanel');
  chronicleRewardPanel.Visibility = Visibility.Hidden;
  TaskDialogPanel:ChronicleDialog();
end

function ChroniclePanel:updateProgress(msg)
  if msg.state == -1 then
    --余额不足
    print("yu e bu zu");
    return ;
  end
  local month = self.story[self.year][self.month];
  for _, v in pairs(msg.chronicle_progress) do
    month[v.chronicle_story_id % 100].progress = {};
    month[v.chronicle_story_id % 100].progress = v;
  end
  self:refreshMonthPanel(self.year, self.month);
  btnRetrieve.Enable = false;
end

function ChroniclePanel:YMD(ymd)
  local y = math.floor(ymd / 10000);
  local m = math.floor((ymd % 10000) / 100)
  local d = ymd % 100;
  return y, m, d;
end

function ChroniclePanel:YM(ym)
  local y = math.floor(ym / 100);
  local m = ym % 100;
  return y, m;
end
--=============================================================================================
