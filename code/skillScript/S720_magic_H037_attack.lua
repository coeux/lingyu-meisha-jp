S720_magic_H037_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S720_magic_H037_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S720_magic_H037_attack.info_pool[effectScript.ID].Attacker)
        
		S720_magic_H037_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S720_2")
		PreLoadSound("skill_03701")
		PreLoadSound("stalk_03701")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdgh" )
		effectScript:RegisterEvent( 19, "dsfdgh" )
		effectScript:RegisterEvent( 28, "fdghgfj" )
	end,

	fdgh = function( effectScript )
		SetAnimation(S720_magic_H037_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdgh = function( effectScript )
		AttachAvatarPosEffect(false, S720_magic_H037_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(63, 38), 1, 100, "S720_2")
		PlaySound("skill_03701")
		PlaySound("stalk_03701")
	end,

	fdghgfj = function( effectScript )
			DamageEffect(S720_magic_H037_attack.info_pool[effectScript.ID].Attacker, S720_magic_H037_attack.info_pool[effectScript.ID].Targeter, S720_magic_H037_attack.info_pool[effectScript.ID].AttackType, S720_magic_H037_attack.info_pool[effectScript.ID].AttackDataList, S720_magic_H037_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
