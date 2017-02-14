
--========================================================================
--资源表格

ResTable =
{
    scene				= 1;			--场景表
    actor				= 2;			--角色表
    actorOrder			= 11;			--角色入场顺序
    monster				= 3;			--怪物表
    talk				= 4;			--对话表	
    skill				= 5;			--技能表	
    barriers			= 6;			--关卡表
    npc					= 7;			--npc表
    monster_property 	= 8;			--怪物属性
    boss_property		= 9;			--boss表
    skill_damage		= 10;			--技能伤害系数
};

function ResTable:Init(repo_path_)

	resTableManager:LoadTable(ResTable.scene, repo_path_..'scene.txt', '场景ID');							--场景表
	resTableManager:LoadTable(ResTable.actor, repo_path_..'role.txt', '角色ID');							--职业表
	resTableManager:LoadTable(ResTable.monster, repo_path_..'monster.txt', '怪物ID');						--怪物表
	resTableManager:LoadTable(ResTable.skill, repo_path_..'skill.txt', '技能ID');							--技能表
	resTableManager:LoadTable(ResTable.barriers, repo_path_..'round.txt', '关卡编号');					--关卡表
	resTableManager:LoadTable(ResTable.npc, repo_path_..'npc.txt', 'NPCID');								--npc表
	resTableManager:LoadTable(ResTable.monster_property, repo_path_..'monster_property.txt', '怪物等级');--怪物属性表
	resTableManager:LoadTable(ResTable.boss_property, repo_path_..'boss_property.txt', '怪物ID等级');						--boss属性表
	resTableManager:LoadTable(ResTable.skill_damage, repo_path_..'skill_effect.txt', '技能ID_等级');		--技能伤害系数表
end

