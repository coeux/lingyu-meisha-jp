S771_magic_H042_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S771_magic_H042_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S771_magic_H042_attack.info_pool[effectScript.ID].Attacker)
        
		S771_magic_H042_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_04204")
		PreLoadAvatar("S770_1")
		PreLoadSound("skill_04205")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgdfhj" )
		effectScript:RegisterEvent( 32, "dgfdhghj" )
		effectScript:RegisterEvent( 36, "fdghfj" )
	end,

	dgdfhj = function( effectScript )
		SetAnimation(S771_magic_H042_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_04204")
	end,

	dgfdhghj = function( effectScript )
		AttachAvatarPosEffect(false, S771_magic_H042_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 120), 1.8, 100, "S770_1")
		PlaySound("skill_04205")
	end,

	fdghfj = function( effectScript )
			DamageEffect(S771_magic_H042_attack.info_pool[effectScript.ID].Attacker, S771_magic_H042_attack.info_pool[effectScript.ID].Targeter, S771_magic_H042_attack.info_pool[effectScript.ID].AttackType, S771_magic_H042_attack.info_pool[effectScript.ID].AttackDataList, S771_magic_H042_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
