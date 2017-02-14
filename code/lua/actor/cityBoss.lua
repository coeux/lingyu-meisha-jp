--cityBoss.lua
--========================================================================
--依赖

LoadLuaFile("lua/actor/npc.lua");

CityBoss = class(NPC)

function CityBoss:constructor( id, resID, orderId )
	
	--========================================================================
	--属性相关

	self.hp				= 100;				--hp
	self.awaitTimer		= 0;				--待机小动作计时器
	self.npcType 		= 2;				--默认为主城Boss
	self.level			= 1;				--默认level 1
	self.isFighting 	= 0;
	self.orderId		= orderId;
	--========================================================================

end

--初始化头顶
function CityBoss:InitHead()
	self.uiHead = uiSystem:CreateControl('StackPanel');	
	self.uiHead.Pick = false;
	self.uiHead.Alignment = Alignment.Center;
	self.uiHead.AutoSize = true;
	self.uiHead:SetScale(0.8, 0.8);
	
	--称号
	--[[
	self.uiHead.uiTitle = uiSystem:CreateControl('Label');
	self.uiHead.uiTitle.Pick = false;
	self.uiHead.uiTitle.Size = Size(200, 30);
	self.uiHead.uiTitle.Margin = Rect(-100, -15, 0, 0);
	self.uiHead.uiTitle.TextAlignStyle = TextFormat.MiddleCenter;
	self.uiHead.uiTitle:SetFont('huakang_20');
	self.uiHead.uiTitle.TextColor = QualityColor[1];
	self.uiHead.uiTitle.Text = self.title;
	]]--
	
	local prefixIndex = math.random(8);
	local namePrefix = resTableManager:GetValue(ResTable.invasion_prefix, tostring(prefixIndex), "prefix");
	
	--名字
	self.uiHead.uiName = uiSystem:CreateControl('Label');
	self.uiHead.uiName.Pick = false;
	self.uiHead.uiName.Size = Size(250, 30);
	self.uiHead.uiName.Margin = Rect(-100, -15-self.bodyHeight, 0, 0);
	self.uiHead.uiName.TextAlignStyle = TextFormat.MiddleCenter;
	self.uiHead.uiName:SetFont('huakang_20');
	self.uiHead.uiName.TextColor = QualityColor[1];
	self.uiHead.uiName.Text = namePrefix..self.name;
	
--[[	if tonumber(self.resID) < 900 then
		self.uiHead.taskInfo = ImageElement(uiSystem:CreateControl('ImageElement'));
		self.uiHead.taskInfo.Pick = false;
		
		--设置图片	
		self.uiHead.taskInfo.Image = GetPicture('dynamicPic/task_3.ccz');
		self.uiHead.taskInfo.Visibility = Visibility.Visible;
		self.uiHead.taskInfo.AutoSize = true;
		self.uiHead:AddChild(self.uiHead.taskInfo);
		--self.uiHead.taskInfo.Size = Size(65, 70);	
		--self.uiHead.taskInfo.Margin = Rect(, -15, 0, 0);
	end--]]

	self.uiHead:AddChild(self.uiHead.uiName);
	--self.uiHead:AddChild(self.uiHead.uiTitle);	
	bottomDesktop:AddChild(self.uiHead);
end

function CityBoss:SetBossLevel(level)
	self.level = level;
	self.uiHead.uiName.Text = "LV"..tostring(level).." "..self.uiHead.uiName.Text;
	
	self.bossRate = Configuration:getRare(level);
	self.uiHead.uiName.TextColor = QualityColor[self.bossRate];
end

function CityBoss:SetBossFighting(isFighting)
	if self.isFighting == 1 then
		return;
	end
	
	if isFighting ~= 0 then	
		self.isFighting = 1;
		PlayEffect("zhandouzhong_output/", Rect(0,20,0,0), "zhandouzhong", self.uiHead.uiName);
	end
end

function CityBoss:RefreshStatus(status)
	if status == 0 then -- normal
		self.isFighting = 0;
		if self.uiHead and self.uiHead.uiName then
			self.uiHead.uiName:RemoveAllChildren();
		end
	else
		self:SetBossFighting(1);
	end
end

function CityBoss:HideSelf()
	local bossArmar = self:GetCppObject();
	bossArmar.Visibility = Visibility.Hidden;
	self.Visibility = Visibility.Hidden;
	self.uiHead.Visibility = Visibility.Hidden;
	self:SetPosition(Vector3(100000, -100000, 0));
	--table.remove(self.bossList, bossID);	
end

--加载npc形象
function CityBoss:loadNpc()
	
	local cityBossData = resTableManager:GetRowValue(ResTable.invasion, self.resID);
	
	if cityBossData == nil then
		print ("No cityboss data for "..self.resID);
		return;
	end
	
	--名字
	self.name = cityBossData['name'];
	
	--形象
	local path = GlobalData.AnimationPath .. cityBossData['path'] .. '/';
	AvatarManager:LoadFile(path);
	local avatarName = cityBossData['img'];
	self:LoadArmature(avatarName);
	self:SetAnimation(AnimationType.idle);
	
	--体积
	self.bodyWidth = cityBossData['width'];
	self.bodyHeight = cityBossData['height'];

	--位置
	local x;
	local y;

	x = self.posx;
	y = self.posy;
	
	self:SetPosition(Vector3(x, y, 0));
	
	--设置影子
	-- self:SetShadow( cityBossData['shadow'] );
	
	if tostring(Configuration.StatueNPCID) == self.resID then
		--self:SetScale(1, 1);
	else
		--人物按照场景比例进行一定的缩放
		self:SetScale(GlobalData.ActorNPCScale, GlobalData.ActorNPCScale);
	end	
	
	--朝向
	--self:SetDirection( cityBossData[LANG_cityBoss_1] );
	
end
