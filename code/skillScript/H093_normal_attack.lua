H093_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H093_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H093_normal_attack.info_pool[effectScript.ID].Attacker)
		H093_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow05")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "aa" )
		effectScript:RegisterEvent( 16, "c" )
	end,

	a = function( effectScript )
		SetAnimation(H093_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	aa = function( effectScript )
		H093_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H093_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 110), 3, 800, 300, 1, H093_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), "arrow05", effectScript)
	end,

	c = function( effectScript )
			DamageEffect(H093_normal_attack.info_pool[effectScript.ID].Attacker, H093_normal_attack.info_pool[effectScript.ID].Targeter, H093_normal_attack.info_pool[effectScript.ID].AttackType, H093_normal_attack.info_pool[effectScript.ID].AttackDataList, H093_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	DetachEffect(H093_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

}
