--BIDataStatistics.lua
--=================================================================
--BI数据统计

BIDataStatistics =
	{
	};
	
	
--BI调试功能开关
function BIDataStatistics:SetIsLogEnabled(flag)
  if true then return end;
	if VersionUpdate.curLanguage == LanguageType.cn then
		platformSDK:SetIsLogEnabled(flag);
	end
end

--账号登陆
function BIDataStatistics:UserLogin()
  if true then return end;
	if VersionUpdate.curLanguage == LanguageType.cn then
		platformSDK:BIUserLogin(platformSDK.m_UserName, platformSDK.m_UserName);
	elseif VersionUpdate.curLanguage == LanguageType.tw then

	end
end

--创建角色
function BIDataStatistics:CreateRole(roleID, roleName, job)
  if true then return end;
	if VersionUpdate.curLanguage == LanguageType.cn then
		platformSDK:BICreateRole(platformSDK.m_UserName, tostring(roleID), roleName, tostring(job));
	elseif VersionUpdate.curLanguage == LanguageType.tw then		
		for index, server in pairs(Login.serverList) do
			if server.serid == Login.hostnum then
				local hostName = server.name .. "|" .. tostring(Login.hostnum);
				platformSDK:TPCreateRole(platformSDK.m_UserName, tostring(roleID), roleName, tostring(job), hostName);
				return;
			end
		end				
	end
end

--角色登陆
function BIDataStatistics:RoleLogin(roleID, roleName, level)
  if true then return end;
	if VersionUpdate.curLanguage == LanguageType.cn then
		platformSDK:BIReInitWithServer( tostring(Login.hostnum) );
		platformSDK:BIRoleLogin(platformSDK.m_UserName, tostring(roleID), roleName, tonumber(level));
	elseif VersionUpdate.curLanguage == LanguageType.tw then
--[[		for index, server in pairs(Login.serverList) do
			if server.serid == Login.hostnum then
				--platformSDK:TPRoleLogin(platformSDK.m_UserName, tostring(roleID), roleName, tonumber(level), hostName);
				local hostName = server.name .. "|" .. tostring(Login.hostnum);
				--print('The hostName:' .. hostName);
				platformSDK:TPRoleLogin(platformSDK.m_UserName, tostring(roleID), roleName, tonumber(level), hostName);
				return;
			end
		end		--]]	
	end
end

--充值
function BIDataStatistics:AddCash(payType, cashAfter, cashAdded)
  if true then return end;
	if VersionUpdate.curLanguage == LanguageType.cn then
		platformSDK:BIAddCash(platformSDK.m_UserName, payType, cashAfter, cashAdded);
	end
end

--消费
function BIDataStatistics:ShopTrade(itemID, itemNum, buyType, cashLeft, cashUsed)
  if true then return end;
	if VersionUpdate.curLanguage == LanguageType.cn then
		platformSDK:BIShopTrade(platformSDK.m_UserName, '', tostring(itemID), tonumber(itemNum), tonumber(buyType), tonumber(cashLeft), tonumber(cashUsed));
	end
end
