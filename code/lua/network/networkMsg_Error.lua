--networkMsg_Error.lua
--======================================================================
-- 网络消息错误码处理
-- @auther : fanbin
-- @date   : 2015/07/25
-- 说明！！: 此处仅处理通用错误消息处理，若处理完默认消息后仍然有其他内容
-- 需要处理，则使用原有方案处理 例:WOUBossPanel:EnterBossBattleFailed(msg)
-- NetworkMsg_KillBoss:onInvasionFightError(msg)
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
NetworkMsg_Error = 
{
  errorCodeFunc = {};
};

function NetworkMsg_Error:HandleErrorCode(msg)
  if errorCodeFunc[msg.code] then
    errorCodeFunc[msg.code](msg);
  else
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_UNKNOW .. msg.code);
  end
end

errorCodeFunc = {
  [0] = function()
    -- TODO
  end,

  [406] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0406);
  end,
  [501] = function()
    print('--->501')
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0501);
  end,
  [506] = function()
    ToastMove:CreateToast(LANG_ERROR_CODE_0506, Configuration.RedColor);
  end,

  [508] = function()
    ToastMove:CreateToast(LANG_ERROR_CODE_0508, Configuration.RedColor);
  end,

  [509] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0509);
  end,

  [516] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0516);
  end,

  [520] = function()
    ToastMove:CreateToast(LANG_ERROR_CODE_0520);
  end,

  [521] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0521);
  end,

  [523] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0523);
  end,

  [524] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0524);
  end,

  [611] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0611);
  end,

  [620] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0620);
  end,

  [630] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0630);
  end,

  [640] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0640);
  end,

  [641] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0641);
  end,

  [650] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0650);
  end,

  [651] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0651);
  end,

  [652] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0652);
  end,

  [653] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0653);
  end,

  [660] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0660);
  end,

  [661] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0661);
  end,

  [662] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_0662);
  end,

  [900] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_900);
  end,

  [1005] = function()
    CoinNotEnoughPanel:ShowCoinNotEnoughPanel(LANG_ERROR_CODE_1005);
  end,
  [1006] = function()
    print('1006--->');
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_1006);
  end,
  [1007] = function()
    Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_1007);
  end,

  [1605] = function()
    Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_1605);
  end,
  [1650] = function()
    Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_1650);
  end,
  [1703] = function()
  print('1703--->');
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_1703);
  end,
  [1751] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_1751);
  end,

  [1752] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_1752);
  end,

  [1753] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_1753);
  end,

  [1754] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_1754);
  end,

   [1821] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_1821);
  end,

  [1900] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_1900);
  end,

  [2100] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2100);
    TreasurePanel:Nobody();
  end,

  [2101] = function()
    Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_2101);
  end,

  [2102] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2102);
  end,

  [2103] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2103);
  end,
  
  [2104] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2104);
    TreasurePanel:refreshRound();
  end,

  [2105] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2105);
  end,

  [2106] = function()
    Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_2106);
    TreasurePanel:Nobody();
  end,

  [2107] = function()
    Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_2107);
  end,

  [2108] = function(msg)
    --客户端占领总时间达到最大值，但是服务器还没有到，返回准确时间
    if msg.m_or_t < 0 or msg.m_or_t > Configuration.TreasureCaptureMaxTime then
      ActorManager.user_data.round.stamp = 0;
    else
      ActorManager.user_data.round.stamp = msg.m_or_t;
    end
  end,

  [2110] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2110);
  end,

  [2111] = function()
    Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_2111);
  end,

  [2112] = function()
    Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_2112);
  end,

  [2114] = function()
    Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_2114);
  end,
  [2140] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2140);
  end,
  [2141] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2141);
  end,
  [2142] = function()
   MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2142);
  end,
  [2143] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2143);
  end,
  [2144] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2144);
  end,
  [2145] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2145);
  end,
  [2146] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2146);
  end,
  [2147] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2147);
  end,
  [2148] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2148);
  end,
  [2149] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2149);
  end,
  [2150] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2150);
  end,
  [2151] = function()
    Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_2151);
  end,
  [2152] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2152);
  end,
  [2153] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2153);
  end,
  [2154] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2154);
  end,
  [2155] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2155);
  end,
  [2156] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2156);
  end,
  [2400] = function()
    ToastMove:CreateToast(LANG_ERROR_CODE_2400, Configuration.RedColor);
  end,

  [2401] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2401);
  end,

  [2500] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2500);
  end,

  [2501] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2501);
  end,

  [2600] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2600);
  end,

  [2601] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2601);
  end,

  [2602] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2602);
  end,

  [2603] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2603);
  end,

  [2606] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2606);
  end,

  [2700] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2700);
  end,

  [2701] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2701);
  end,

  [2702] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2702);
  end,

  [2703] = function()
		local nameId = resTableManager:GetValue(ResTable.event, tostring(ActorManager.user_data.functions.card_event.event_id), 'item_id');
		local name = resTableManager:GetValue(ResTable.item, tostring(nameId), 'name');
		local error_str = LANG_CardEvent_10;
		error_str[1] = string.format(error_str[1], name);
		local okDelegate = Delegate.new(CardEventPanel, CardEventPanel.gotoFight);
		MessageBox:ShowDialog(MessageBoxType.OkCancel, error_str, okDelegate, nil, LANG_MESSAGEBOX_OK2, nil, nil, nil, nil, Size(135, 48), Size(135,48));
  end,

  [2704] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2704);
  end,

  [2705] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2705);
  end,

  [2706] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2706);
  end,

  [2800] = function()
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2800);
  end,
  [3150] = function()
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3150);
  end,
  [3151] = function()
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3151);
  end,
	[3200] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3200);
	end,
	[3201] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3201);
	end,
	[3202] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3202);
	end,
	[3203] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3203);
	end,
	[3204] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3204);
	end,
	[3205] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3205);
	end,
	[3250] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3250);
	end,
	[3251] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3251);
	end,
	[3252] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3252);
	end,
	[3253] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3253);
	end,
	[3254] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3254);
	end,
	[3255] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3255);
	end,
	[3256] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3256);
	end,
	[3257] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3257);
	end,
	[3258] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3258);
	end,
	[3259] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3259);
	end,
	[3260] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3260);
	end,
	[3261] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3261);
	end,
	[3262] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3262);
	end,
	[3263] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3263);
	end,
	[3264] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3264);
	end,
	[3265] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3265);
	end,
	[3266] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3266);
	end,
	[3267] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3267);
	end,
	[3268] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3268);
	end,
	[3269] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3269);
	end,
	[3270] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3270);
	end,
	[3271] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3271);
	end,
	[3272] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3272);
	end,
	[3273] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3273);
	end,
	[3274] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3274);
	end,
	[3275] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3275);
	end,
	[3276] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3276);
	end,
	[3277] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3277);
	end,
	[3278] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3278);
	end,
	[3279] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3279);
	end,
	[3300] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3300);
	end,
	[3301] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3301);
	end,
	[3302] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3302);
	end,
	[3303] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3303);
	end,
	[3350] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3350);
	end,
	[3351] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3351);
	end,
	[3352] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3352);
	end,
	[3400] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3400);
	end,
	[3401] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3401);
	end,
  [3402] = function()
    ZhaomuPanel:goToRechargeShow();
  end,
	[3600] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3600);
	end,
	[3601] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3601);
	end,
	[3602] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3602);
	end,
	[3603] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3603);
	end,
	[3604] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3604);
	end,
	[3605] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3605);
	end,
	[3606] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3606);
	end,
	[3607] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3607);
	end,
	[3608] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3608);
	end,
	[3609] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3609);
	end,
	[3610] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3610);
	end,
	[3611] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3611);
	end,
	[3612] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3612);
	end,
	[3613] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3613);
	end,
  	[3651] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3651);
	end,
  	[3652] = function()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_3652);
  	end,
	[3700] = function()
   		FeedbackPanel:onFeedback();
	end
};
