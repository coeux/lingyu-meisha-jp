M095_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M095_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M095_normal_attack.info_pool[effectScript.ID].Attacker)
		M095_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("girlskill")
		PreLoadAvatar("hit_41")
		PreLoadSound("thunder")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "df" )
		effectScript:RegisterEvent( 33, "s" )
		effectScript:RegisterEvent( 34, "f" )
	end,

	a = function( effectScript )
		SetAnimation(M095_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("girlskill")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, M095_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "hit_41")
		PlaySound("thunder")
	end,

	f = function( effectScript )
			DamageEffect(M095_normal_attack.info_pool[effectScript.ID].Attacker, M095_normal_attack.info_pool[effectScript.ID].Targeter, M095_normal_attack.info_pool[effectScript.ID].AttackType, M095_normal_attack.info_pool[effectScript.ID].AttackDataList, M095_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
