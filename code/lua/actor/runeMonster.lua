--runeMonster.lua
--========================================================================
--符文怪物类

RuneMonster = class()

local DropMoveSpeed	= 900;				--掉落移动速度

function RuneMonster:constructor(id, monsterTypeId, coordsId, line, drop, resID)

	--========================================================================
	--属性相关	

	self.id				= id;						--ID
	self.monsterTypeId 	= monsterTypeId;			--怪物类型ID
	self.resID 			= tostring(resID);			--怪物ID
	self.coordsId		= coordsId;					--坐标ID
	
	self.animationID	= AnimationType.none;		--动作ID	
	self.faceDir		= DirectionType.faceright;	--朝向
	
	self.state			= RuneMonsterState.idle;	--状态

	self.targetPos		= Vector2.ZERO;				--目标位置

	self.moveSpeed		= 240;						--移动速度
	
	self.line = line;      --怪物线，一共10条，五条普通怪物，五条魔王，值为0~9	
	self.drop = drop;
	self.dropMoving = false;						--掉落移动中
	
	self.preDirection = SlideDirection.none;		--上次划中方向
 	self.prePoint = nil;							--上次划动的点	
	
	
	self:initDataFromTable();						--根据表格初始化怪物数据
	
	self:initMonsterUI();							--初始化怪物相关的UI
	
	--========================================================================

end

function RuneMonster:Destroy( )
	self.monsterPanel = nil;
	uiSystem:DestroyControl(self.monsterTemplate);
	self.monsterTemplate = nil;
end


--记录划动开始节点
function RuneMonster:SetTouchBeganPoint( point )
	self.prePoint = point;
	self.preDirection = SlideDirection.none;
end

--划动过程处理
function RuneMonster:TouchMove( curPoint )
	if self.curLife == 0 then
		return;
	end
	
	local curDirection = SlideDirection.none;
	
	if RectContainLine(self.prePoint, curPoint, self:GetRect()) then	
		if curPoint.x >= self.prePoint.x then
			curDirection = SlideDirection.right;			
		else
			curDirection = SlideDirection.left;
		end
		if curDirection ~= self.preDirection then
			
			self:UpdateLifeDrop(self.prePoint, curPoint, false);
		end
		self.preDirection = curDirection;
	else		
		self.preDirection = SlideDirection.none;
	end
	
	self.prePoint = curPoint;
end

--自动猎魔处理
function RuneMonster:AutoHunt( )
	local point2 = Vector2(self.monsterPanel.Translate.x + 10, self.monsterPanel.Translate.y + 10);
	self:UpdateLifeDrop(self.monsterPanel.Translate, point2, true);	
end

--获取怪物区域
function RuneMonster:GetRect( )
	local pos = self:GetPosition();	
	return Rect(pos.x - self.width/2, pos.y - self.height, pos.x + self.width/2, pos.y);
end

--初始化数据
function RuneMonster:initDataFromTable()
	
	local data = {};

	--猎魔数据
	data = resTableManager:GetRowValue(ResTable.rune_prob, tostring(self.monsterTypeId));
	self.height	= data['height'];				--角色高度
	self.width = data['width'];				--角色宽度	
	self.moveSpeed = data['speed'];			--角色移动速度
	self.totalLife = data['hit'];		--总血量	
	self.curLife = self.totalLife;				--当前血量

	--怪物表数据
	data = resTableManager:GetRowValue(ResTable.monster, self.resID);
	self.actorForm	= data['img'];			--角色形象
	self.name = data['name'];				--角色名字	
	self.path = data['path'];					--目录

end



--初始化人物形象
function RuneMonster:initMonsterUI()
	self.monsterTemplate = uiSystem:CreateControl('runeMonsterTemplate');
	
	self.monsterPanel = Panel(self.monsterTemplate:GetLogicChild(0));
	
	local data = resTableManager:GetRowValue(ResTable.rune_coordinate, tostring(self.coordsId));
	self.initialTranslate = Vector2(data['x'], data['y']);
	self.monsterPanel.ZOrder = data['z'];
	
	self.labelMonsterName = Label(self.monsterPanel:GetLogicChild('name'));
	self.labelMonsterName.Text = self.name;
	--根据怪物类型ID判断怪物名字颜色
	self.labelMonsterName.TextColor = QualityColor[self.monsterTypeId];
	self.labelMonsterName.Translate = Vector2(self.labelMonsterName.Translate.x, -self.height);
	self.armature = ArmatureUI(self.monsterPanel:GetLogicChild('monster'));
	
	
	self.stackLife = StackPanel(self.monsterPanel:GetLogicChild('life'));
	self.stackLife1 = self.stackLife:GetLogicChild('1');
	self.stackLife2 = self.stackLife:GetLogicChild('2');
	self.stackLife3 = self.stackLife:GetLogicChild('3');
	
	local totalPath = GlobalData.AnimationPath .. self.path .. '/';
	AvatarManager:LoadFile(totalPath);
	
	self.armature:LoadArmature(self.actorForm);
	self.armature:SetScriptAnimationCallback('RuneMonsterAnimationEnd', self.id );
	self:SetAnimation(AnimationType.f_idle);
	
	--随机生成并并移动到一个指定坐标
	self.monsterPanel.Translate = self:GetRandomPosition();	
	self:MoveTo(self:GetRandomPosition());
	
	--初始化血条UI
	self:UpdateLife();
end

--动作结束
function RuneMonsterAnimationEnd( armature, id )
	if armature:IsCurAnimationLoop() then
		--循环动作
		armature:Replay();		
		return;
	end		
	
	local monster = RuneManager:GetMonster(id);
	if monster == nil then	
		return;
	end

	if monster.state == RuneMonsterState.death then
		RuneManager:DestroyMonster( id , true);
	else
		fighter:SetAnimation(AnimationType.f_idle);			
	end

end

--设置朝向
function RuneMonster:SetDirection( dir )

	if self.faceDir == dir then
		return;
	end
	
	self.faceDir = dir;	
	local scale = self.armature.Scale;
	
	if dir == DirectionType.faceleft then
		self.armature.Scale = Vector2( -Math.Abs(scale.x), scale.y);
	else
		self.armature.Scale = Vector2( Math.Abs(scale.x), scale.y);
	end

end

--设置动作
function RuneMonster:SetAnimation( id, timeScale )

	--动作相同
	if self.animationID == id then
		return;
	end
	
	--死亡动作不能被别的动作替换
	if (self.animationID == AnimationType.death) then
		return;
	end

	self.animationID = id;
	
	if timeScale == nil then
		timeScale = -1;		--默认使用配置文件缩放
	end
	
	if self.armature:IsHaveAnimation(id) then
		self.armature:SetAnimation(id, timeScale);
		return;
	end
	
	--不包含动作则按规则匹配
	if id == AnimationType.idle then
		self.armature:SetAnimation(AnimationType.f_idle, timeScale);
	elseif id == AnimationType.run then
		self.armature:SetAnimation(AnimationType.f_run, timeScale);
	elseif id == AnimationType.skill then
		self.armature:SetAnimation(AnimationType.attack, timeScale);
	elseif id == AnimationType.win then
		self.armature:SetAnimation(AnimationType.f_idle, timeScale);
	else
		print(LANG_runeMonster_1 .. id);
	end

end


--更新
function RuneMonster:Update( Elapse )

	--更新怪物移动
	self:updateMonsterMove(Elapse);	
end

function RuneMonster:GetAvatarName()
	return self.avatarName;
end

--========================================================================
--行走控制

--移动
function RuneMonster:MoveTo( Pos )

	if self.targetPos == Pos then
		self:MoveTo(self:GetRandomPosition());
		return;
	end

	self.targetPos = Pos;
	self.state = RuneMonsterState.moving;

	--设置朝向
	local curPos = self:GetPosition();
	if curPos.x < Pos.x then
		--朝右
		self:SetDirection(DirectionType.faceright);
	else
		--朝左
		self:SetDirection(DirectionType.faceleft);
	end

	self:SetAnimation(AnimationType.run);
end

--更新怪物移动
function RuneMonster:updateMonsterMove( Elapse )

	if self.state ~= RuneMonsterState.moving then
		return;
	end
	
	local curPos3 = self:GetPosition();
	local curPos2 = Vector2(curPos3.x, curPos3.y);
	local dir = self.targetPos - curPos2;
	local length = dir:Normalise();
	local dis = self.moveSpeed * Elapse;
	
	if dis >= length then
		--到达目标
		self:SetPosition( self.targetPos );
		self:SetAnimation(AnimationType.idle);
		self.state = RuneMonsterState.idle;
		self:MoveTo(self:GetRandomPosition());	
		
	else

		--没有到达，就移动
		dis = dir * dis;
		curPos2 = curPos2 + dis;
		self:SetPosition( curPos2 );
	end
	
end

function RuneMonster:addDrop( )
	local position = Vector2(self.monsterPanel.Translate.x, self.monsterPanel.Translate.y);
	RuneFalldownManager:addDrop(position, self.id, self.drop, self.line);
end

--获取下一个随机点
function RuneMonster:GetRandomPosition()
	local offset = RuneManager:GetRandomOffset();
	return Vector2(self.initialTranslate.x + offset.x, self.initialTranslate.y + offset.y);
end

--获取位置
function RuneMonster:GetPosition()
	return self.monsterPanel.Translate;
end

--设置位置
function RuneMonster:SetPosition( pos )
	self.monsterPanel.Translate = pos;
end

--到达目标
function RuneMonster:MoveToTarget()
end

--id
function RuneMonster:GetID()
	return self.id;
end

--resID
function RuneMonster:GetResID()
	return self.resID;
end

--坐标ID
function RuneMonster:GetCoordId()
	return self.coordsId;
end

--名字
function RuneMonster:GetName()
	return self.name;
end

--怪物线
function RuneMonster:GetLine()
	return self.line;
end

function RuneMonster:GetCurLife()
	return self.curLife;
end

function RuneMonster:SetName( name )
	self.Name = name;
end

--掉血一滴
function RuneMonster:UpdateLifeDrop( point1, point2, isAutoHunt)
	if RuneHuntPanel.errorFlag ~= 0 then
		RuneHuntPanel:UpdateAlert();
		return;
	end
	self.curLife = self.curLife - 1;

	if self.curLife == 0 then
		--死亡
		self:SetAnimation(AnimationType.death);
		self.state = RuneMonsterState.death;
		
		--非自动猎魔时发请求，自动猎魔请求一起处理
		if not isAutoHunt then
			RuneManager:onRequestHuntOne(self.line);
		end

		--增加掉落
		self:addDrop();
		
		--显示金币浮动效果
		RuneHuntPanel:ShowFloatMoneyEffect('-' .. self.totalLife * RuneManager.RuneHuntMoney .. LANG_runeMonster_2, self.monsterPanel.Translate.x - 250, self.monsterPanel.Translate.y);
		
	end
	self:UpdateLife();
	RuneManager:PlayScratchTraceEffect(point1, point2);
end

--设置当前血量
function RuneMonster:SetCurrentLife( life )
	self.curLife = life;
	self:UpdateLife();
end

--怪物
function RuneMonster:GetArmature()
	return self.armature;
end

--怪物面板，包含名字和血条
function RuneMonster:GetRootPanel()
	return self.monsterPanel;
end

--跟新怪物生命
function RuneMonster:UpdateLife()
	if self.curLife < 0 then
		return;
	end
	if self.totalLife == 3 then
		self.stackLife1.Visibility = Visibility.Visible;
		self.stackLife2.Visibility = Visibility.Visible;
		self.stackLife3.Visibility = Visibility.Visible;
		if self.curLife >= 1 then
			self.stackLife1.Background = Converter.String2Brush(RuneMonsterLife.YES);
		else
			self.stackLife1.Background = Converter.String2Brush(RuneMonsterLife.NO);
		end
		if self.curLife >= 2 then
			self.stackLife2.Background = Converter.String2Brush(RuneMonsterLife.YES);
		else
			self.stackLife2.Background = Converter.String2Brush(RuneMonsterLife.NO);
		end
		if self.curLife >= 3 then
			self.stackLife3.Background = Converter.String2Brush(RuneMonsterLife.YES);
		else
			self.stackLife3.Background = Converter.String2Brush(RuneMonsterLife.NO);
		end
		self.stackLife.Translate = Vector2(-14*3, self.stackLife.Translate.y);
	elseif self.totalLife == 2 then
		self.stackLife1.Visibility = Visibility.Visible;
		self.stackLife2.Visibility = Visibility.Visible;
		self.stackLife3.Visibility = Visibility.Hidden;
		if self.curLife >= 1 then
			self.stackLife1.Background = Converter.String2Brush(RuneMonsterLife.YES);
		else
			self.stackLife1.Background = Converter.String2Brush(RuneMonsterLife.NO);
		end
		if self.curLife >= 2 then
			self.stackLife2.Background = Converter.String2Brush(RuneMonsterLife.YES);
		else
			self.stackLife2.Background = Converter.String2Brush(RuneMonsterLife.NO);
		end
		self.stackLife.Translate = Vector2(-14*2, self.stackLife.Translate.y);
	elseif self.totalLife == 1 then
		self.stackLife1.Visibility = Visibility.Visible;
		self.stackLife2.Visibility = Visibility.Hidden;
		self.stackLife3.Visibility = Visibility.Hidden;
		if self.curLife >= 1 then
			self.stackLife1.Background = Converter.String2Brush(RuneMonsterLife.YES);
		else
			self.stackLife1.Background = Converter.String2Brush(RuneMonsterLife.NO);
		end
		self.stackLife.Translate = Vector2(-14, self.stackLife.Translate.y);
	end
end	