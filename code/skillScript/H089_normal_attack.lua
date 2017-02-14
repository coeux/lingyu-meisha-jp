H089_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H089_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H089_normal_attack.info_pool[effectScript.ID].Attacker)
		H089_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("iceball")
		PreLoadAvatar("arrow08")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 20, "df" )
		effectScript:RegisterEvent( 29, "qq" )
		effectScript:RegisterEvent( 30, "qqq" )
	end,

	a = function( effectScript )
		SetAnimation(H089_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("iceball")
	end,

	qq = function( effectScript )
		H089_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H089_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(25, 135), 3, 800, 300, 0.8, H089_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "arrow08", effectScript)
	end,

	qqq = function( effectScript )
		DetachEffect(H089_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H089_normal_attack.info_pool[effectScript.ID].Attacker, H089_normal_attack.info_pool[effectScript.ID].Targeter, H089_normal_attack.info_pool[effectScript.ID].AttackType, H089_normal_attack.info_pool[effectScript.ID].AttackDataList, H089_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
