--redEnvelopes.lua
--========================================================================
--依赖

LoadLuaFile("lua/actor/player.lua");


--红包类
RedEnvelopes = class(Player)

function RedEnvelopes:constructor( id, resID )
	
	--========================================================================
	--属性相关

	self.hp				= 100;				--hp
	self.awaitTimer		= 0;				--待机小动作计时器
	self.npcType 		= NpcTypeDefault;	--默认为主城NPC
	
	--========================================================================

end

--初始化数据
function RedEnvelopes:InitData( data )
	self.name = resTableManager:GetValue(ResTable.npc, self.resID, 'name');
	self.title = resTableManager:GetValue(ResTable.npc, self.resID, 'title');
end


--初始化人物形象
function RedEnvelopes:InitAvatar()
	
	local npcData = resTableManager:GetRowValue(ResTable.npc, self.resID);
	
	--形象
	local path = GlobalData.AnimationPath .. npcData['path'] .. '/';
	AvatarManager:LoadFile(path);
	local avatarName = npcData['img'];
	self:LoadArmature(avatarName);
	self:SetAnimation(AnimationType.idle);
	
	--体积
	self.bodyWidth = npcData['width'];
	self.bodyHeight = npcData['height'];

	self:SetPosition(Vector3.ZERO);
	
--[[	--设置影子
	self:SetShadow( npcData['shadow'] );--]]
	
	if tostring(Configuration.StatueNPCID) == self.resID then
		--self:SetScale(1, 1);
	else
		--人物按照场景比例进行一定的缩放
		local scale = npcData['bodytype'];
		if scale == nil then
			scale = 1;
		end
		self:SetScale(GlobalData.ActorScale * scale , GlobalData.ActorScale * scale);
	end	
	
	--朝向
	self:SetDirection( npcData['headto'] );

end

--初始化头顶
function RedEnvelopes:InitHead()
	if self.uiHead == nil then
		self.uiHead = uiSystem:CreateControl('StackPanel');	
		self.uiHead.Pick = false;
		self.uiHead.Alignment = Alignment.Center;
		self.uiHead.AutoSize = true;
	
		--名字
		self.uiHead.nameline = uiSystem:CreateControl('CombinedElement');
		self.uiHead.nameline.Pick = false;
		self.uiHead.nameline.Alignment = Alignment.Center;
		
		self.uiHead.nameline.uiName = uiSystem:CreateControl('TextElement');
		self.uiHead.nameline.uiName.Pick = false;
		self.uiHead.nameline.uiName:SetFont('huakang_20');
		self.uiHead.nameline.uiName.TextColor = QualityColor[1];
		self.uiHead.nameline.uiName.Text = self.name;
		
		self.uiHead.nameline:AddChild(self.uiHead.nameline.uiName);
		
		self.uiHead:AddChild(self.uiHead.nameline);
		bottomDesktop:AddChild(self.uiHead);
	end
end

--加载Armature
function RedEnvelopes:LoadArmature( fileName )
	self.armature:LoadArmature(fileName);
end

--点击测试
function RedEnvelopes:Hit( PT )
	return self:GetBoundBox():Contain(PT);
end
