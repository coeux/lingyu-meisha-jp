--networkMsg_login.lua

--========================================================================
--网络消息_登陆类

local Chars = {}
for Loop = 0, 255 do
	Chars[Loop+1] = string.char(Loop)
end
local String = table.concat(Chars)

local Built = {['.'] = Chars}

local AddLookup = function(CharSet)
	local Substitute = string.gsub(String, '[^'..CharSet..']', '')
	local Lookup = {}
	for Loop = 1, string.len(Substitute) do
		Lookup[Loop] = string.sub(Substitute, Loop, Loop)
	end
	Built[CharSet] = Lookup

	return Lookup
end

function string.random(Length, CharSet)
	-- Length (number)
	-- CharSet (string, optional); e.g. %l%d for lower case letters and digits

	local CharSet = CharSet or '.'

	if CharSet == '' then
		return ''
	else
		local Result = {}
		local Lookup = Built[CharSet] or AddLookup(CharSet)
		local Range = table.getn(Lookup)

		for Loop = 1,Length do
			Result[Loop] = Lookup[math.random(1, Range)]
		end

		return table.concat(Result)
	end
end

function _file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end

function _readContent(path)
	local file = io.open(path, "r");
	if not file then return false end;
	local content = file:read("*a");
	return content;
end

function create_userdata_file()
	local cache_path = appFramework:GetCachePath() .. "userdata.dat";
	local userdata_path = appFramework:GetDocumentPath() .. "userdata.dat";

	if not _file_exists(userdata_path) then
		local user_name = string.random(10, "abcdefghijklmnopqrstuvwxyz0123456789");

		if _file_exists(cache_path) then  --之前把用户名存储在了错误的路径，如果存在这个文件，则使用这个文件的内容作为用户名
			user_name = _readContent(cache_path);
		end

		local file = io.open(userdata_path, "w");
		file:write(user_name);
		file:close();
	end
end

NetworkMsg_Login =
{
};

--路由登陆成功
function NetworkMsg_Login:onLoginRoute( msg )

	--断开路由连接
	networkManager:Disconnet();

	--连接Server
	Network.serverData = msg;
	Network:Connect();
	Login.loginState = LoginState.connectGateWay;

	--生成加密密钥
	networkManager:GenerateDeckey(msg.seskey);

end

--网关登陆成功
function NetworkMsg_Login:onLoginGateWay( msg )

	Login.loginState = Login.idle;

	--使用mac地址登陆
	local msg = {};

	if platformSDK.m_System == "Win32" then
		msg.name = account_config.user_name
		--msg.name = platformSDK:GetMacAddress();
	else
		--msg.name = platformSDK.m_PlatformUserID;
		if platformSDK.m_UserName ~= nil and platformSDK.m_UserName ~= '' then
			msg.name = platformSDK.m_UserName;
		else
			msg.name = platformSDK:GetMacAddress();
		end
		PrintLog('lua:'..msg.name);
	end	

	create_userdata_file();
	--msg.name = "c0eefb06aa1a_864587025395311_50c9669ab136fe3_898600810115F007278"
	--android名字太长，截取imei
	-- if false then 
	if platformSDK.m_System == "Android" and (platformSDK.m_UserName == nil or platformSDK.m_UserName == '') then
		local info = string.split("hello" .. msg.name, "_");
		if #info > 1 then
			msg.name = info[2];
		end
		PrintLog("lua:android master");
	elseif platformSDK.m_System == "iOS" and (platformSDK.m_UserName == nil or platformSDK.m_UserName == '' or platformSDK.m_UserName == 'appstore') then
		local userdata_path = appFramework:GetDocumentPath() .. "userdata.dat";
		local file = io.open(userdata_path, "r");
		local content = file:read("*a");
		msg.name = content;
	end

	PrintLog("my name is " .. msg.name);

	msg.mac = platformSDK:GetMacAddress();
	msg.sys = platformSDK.m_System;
	msg.domain = platformSDK.m_Platform;--'master'--
	if platformSDK.m_System == "Win32" then
		msg.domain = pcdomain or platformSDK.m_Platform;
	end
	msg.jinfo = GlobalData.jinfo;

	Login.name = msg.name;
	--开启消息加密
	Network:Send(NetworkCmdType.req_mac_login, msg);

end

--mac地址登陆成功
function NetworkMsg_Login:onMacLoginSuccess( msg )

	--设置账户信息
	Login:SetAccountInfo(msg);

	--请求服务器列表
	Login:RequestServerList();


end

--服务器列表返回成功
function NetworkMsg_Login:onServerListSuccess( msg )
	Login:RefreshServerListWin(msg);
end

--角色列表返回成功
function NetworkMsg_Login:onRoleListSuccess( msg )
	Login:RefreshRoleList(msg, true);
	if msg.rolelist[1] then    --  如果是第一次进入，就不会获取roleList
		GlobalData.RoleName = tostring(msg.rolelist[1].nickname)
	end
end

--创建角色返回成功
function NetworkMsg_Login:onCreateRoleSuccess( msg )
	--创建完角色直接进游戏
	Login:onEnterGameAfterCreateRole(msg);	
	GlobalData.RoleName = msg.role.nickname     --  只有第一次创建时才会调用此方法
	--BI数据统计，创建角色
	BIDataStatistics:CreateRole(msg.uid, msg.role.nickname, msg.role.resid);	
end

--删除角色返回成功
function NetworkMsg_Login:onDeleteRoleSuccess( msg )
	Login:DeleteRole(msg.uid);
end

--请求进入游戏成功
function NetworkMsg_Login:onEnterGame( msg )

end

