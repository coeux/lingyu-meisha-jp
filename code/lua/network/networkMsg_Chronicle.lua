--networkMsg_Chronicle.lua

--======================================================================
--编年史
NetworkMsg_Chronicle =
{
};

--请求编年史信息
function NetworkMsg_Chronicle:reqChronicle(year_month)
  local t = {};
  t.chronicle_id = year_month;
  Network:Send(NetworkCmdType.req_chronicle, t, true);
end

--返回编年史信息
function NetworkMsg_Chronicle:retChronicle(msg)
  ChroniclePanel:factory(msg);
end

--请求编年史签到
function NetworkMsg_Chronicle:reqChronicleSign(year_month_day)
  local t = {};
  t.year_month_day = year_month_day;
  Network:Send(NetworkCmdType.req_chronicle_sign, t, true);
end

--返回编年史签到结果
function NetworkMsg_Chronicle:retChronicleSign(msg)
  ChroniclePanel:signResult(msg);
end

--请求记录找回
function NetworkMsg_Chronicle:reqChronicleSignRetrieve()
  Network:Send(NetworkCmdType.req_chronicle_sign_retrieve, {});
end

--返回记录
function NetworkMsg_Chronicle:retChronicleSignRetrieve(msg)
  ChroniclePanel:updateProgress(msg);
end

--请求所有编年史记录
function NetworkMsg_Chronicle:reqChronicleSignAll()
  Network:Send(NetworkCmdType.req_chronicle_sign_all, {});
end

--返回所有编年史记录
function NetworkMsg_Chronicle:retChronicleSignAll(msg)
  ChroniclePanel:allSignResult(msg);
end
