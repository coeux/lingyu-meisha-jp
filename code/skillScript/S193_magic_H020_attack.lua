S193_magic_H020_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S193_magic_H020_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S193_magic_H020_attack.info_pool[effectScript.ID].Attacker)
        
		S193_magic_H020_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_02005")
		PreLoadSound("stalk_02001")
		PreLoadAvatar("S192_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 45, "aaa" )
		effectScript:RegisterEvent( 53, "asdas" )
		effectScript:RegisterEvent( 90, "gfh" )
	end,

	aa = function( effectScript )
		SetAnimation(S193_magic_H020_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_02005")
	end,

	aaa = function( effectScript )
		SetAnimation(S193_magic_H020_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_02001")
	end,

	asdas = function( effectScript )
		AttachAvatarPosEffect(false, S193_magic_H020_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -30), 2, -100, "S192_1")
	end,

	gfh = function( effectScript )
			DamageEffect(S193_magic_H020_attack.info_pool[effectScript.ID].Attacker, S193_magic_H020_attack.info_pool[effectScript.ID].Targeter, S193_magic_H020_attack.info_pool[effectScript.ID].AttackType, S193_magic_H020_attack.info_pool[effectScript.ID].AttackDataList, S193_magic_H020_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
