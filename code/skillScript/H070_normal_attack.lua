H070_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H070_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H070_normal_attack.info_pool[effectScript.ID].Attacker)
		H070_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("burn")
		PreLoadAvatar("arrow05")
		PreLoadSound("minifire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 5, "df" )
		effectScript:RegisterEvent( 24, "b" )
		effectScript:RegisterEvent( 25, "bb" )
	end,

	a = function( effectScript )
		SetAnimation(H070_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("burn")
	end,

	b = function( effectScript )
		H070_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H070_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 50), 3, 800, 300, 0.75, H070_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "arrow05", effectScript)
		PlaySound("minifire")
	end,

	bb = function( effectScript )
		DetachEffect(H070_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H070_normal_attack.info_pool[effectScript.ID].Attacker, H070_normal_attack.info_pool[effectScript.ID].Targeter, H070_normal_attack.info_pool[effectScript.ID].AttackType, H070_normal_attack.info_pool[effectScript.ID].AttackDataList, H070_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
