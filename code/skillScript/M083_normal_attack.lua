M083_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M083_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M083_normal_attack.info_pool[effectScript.ID].Attacker)
		M083_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("beam")
		PreLoadAvatar("hit_41")
		PreLoadSound("thunder")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 7, "df" )
		effectScript:RegisterEvent( 19, "s" )
		effectScript:RegisterEvent( 20, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M083_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("beam")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, M083_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "hit_41")
		PlaySound("thunder")
	end,

	d = function( effectScript )
			DamageEffect(M083_normal_attack.info_pool[effectScript.ID].Attacker, M083_normal_attack.info_pool[effectScript.ID].Targeter, M083_normal_attack.info_pool[effectScript.ID].AttackType, M083_normal_attack.info_pool[effectScript.ID].AttackDataList, M083_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
