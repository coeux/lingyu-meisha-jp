P06_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P06_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P06_normal_attack.info_pool[effectScript.ID].Attacker)
		P06_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("minifire")
		PreLoadAvatar("arrow05")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 16, "df" )
		effectScript:RegisterEvent( 17, "bb" )
		effectScript:RegisterEvent( 18, "cc" )
	end,

	aa = function( effectScript )
		SetAnimation(P06_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("minifire")
	end,

	bb = function( effectScript )
		P06_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( P06_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(90, 70), 3, 800, 300, 0.75, P06_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow05", effectScript)
	end,

	cc = function( effectScript )
		DetachEffect(P06_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(P06_normal_attack.info_pool[effectScript.ID].Attacker, P06_normal_attack.info_pool[effectScript.ID].Targeter, P06_normal_attack.info_pool[effectScript.ID].AttackType, P06_normal_attack.info_pool[effectScript.ID].AttackDataList, P06_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
