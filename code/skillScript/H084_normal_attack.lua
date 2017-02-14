H084_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H084_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H084_normal_attack.info_pool[effectScript.ID].Attacker)
		H084_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("music")
		PreLoadAvatar("arrow01")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 25, "vb" )
		effectScript:RegisterEvent( 26, "ad" )
	end,

	a = function( effectScript )
		SetAnimation(H084_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("music")
	end,

	vb = function( effectScript )
		H084_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H084_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 70), 3, 800, 300, 1, H084_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow01", effectScript)
	end,

	ad = function( effectScript )
		DetachEffect(H084_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H084_normal_attack.info_pool[effectScript.ID].Attacker, H084_normal_attack.info_pool[effectScript.ID].Targeter, H084_normal_attack.info_pool[effectScript.ID].AttackType, H084_normal_attack.info_pool[effectScript.ID].AttackDataList, H084_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
