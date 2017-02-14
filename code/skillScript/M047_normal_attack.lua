M047_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M047_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M047_normal_attack.info_pool[effectScript.ID].Attacker)
		M047_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("heart")
		PreLoadAvatar("hit_41")
		PreLoadSound("thunder")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 27, "ff" )
		effectScript:RegisterEvent( 29, "ffg" )
	end,

	d = function( effectScript )
		SetAnimation(M047_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("heart")
	end,

	ff = function( effectScript )
		AttachAvatarPosEffect(false, M047_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "hit_41")
		PlaySound("thunder")
	end,

	ffg = function( effectScript )
			DamageEffect(M047_normal_attack.info_pool[effectScript.ID].Attacker, M047_normal_attack.info_pool[effectScript.ID].Targeter, M047_normal_attack.info_pool[effectScript.ID].AttackType, M047_normal_attack.info_pool[effectScript.ID].AttackDataList, M047_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
