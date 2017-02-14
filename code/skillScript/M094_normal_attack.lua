M094_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M094_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M094_normal_attack.info_pool[effectScript.ID].Attacker)
		M094_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("girlskill")
		PreLoadSound("iceball")
		PreLoadAvatar("arrow08")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 7, "dff" )
		effectScript:RegisterEvent( 25, "df" )
		effectScript:RegisterEvent( 30, "d" )
		effectScript:RegisterEvent( 31, "e" )
		effectScript:RegisterEvent( 32, "f" )
	end,

	a = function( effectScript )
		SetAnimation(M094_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dff = function( effectScript )
			PlaySound("girlskill")
	end,

	df = function( effectScript )
			PlaySound("iceball")
	end,

	d = function( effectScript )
		M094_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M094_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 70), 3, 800, 300, 1, M094_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "arrow08", effectScript)
	end,

	e = function( effectScript )
		DetachEffect(M094_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

	f = function( effectScript )
			DamageEffect(M094_normal_attack.info_pool[effectScript.ID].Attacker, M094_normal_attack.info_pool[effectScript.ID].Targeter, M094_normal_attack.info_pool[effectScript.ID].AttackType, M094_normal_attack.info_pool[effectScript.ID].AttackDataList, M094_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
