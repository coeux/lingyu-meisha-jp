H090_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H090_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H090_normal_attack.info_pool[effectScript.ID].Attacker)
		H090_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("arrow11")
		PreLoadSound("iceball")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "w" )
		effectScript:RegisterEvent( 18, "d" )
		effectScript:RegisterEvent( 20, "v" )
	end,

	a = function( effectScript )
		SetAnimation(H090_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("odin")
	end,

	w = function( effectScript )
		H090_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H090_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(30, 120), 2, 800, 300, 0.75, H090_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "arrow11", effectScript)
		PlaySound("iceball")
	end,

	d = function( effectScript )
		DetachEffect(H090_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

	v = function( effectScript )
			DamageEffect(H090_normal_attack.info_pool[effectScript.ID].Attacker, H090_normal_attack.info_pool[effectScript.ID].Targeter, H090_normal_attack.info_pool[effectScript.ID].AttackType, H090_normal_attack.info_pool[effectScript.ID].AttackDataList, H090_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
