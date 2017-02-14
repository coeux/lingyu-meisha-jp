H078_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H078_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H078_normal_attack.info_pool[effectScript.ID].Attacker)
		H078_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("arrow12")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 4, "df" )
		effectScript:RegisterEvent( 17, "ddd" )
		effectScript:RegisterEvent( 18, "add" )
	end,

	a = function( effectScript )
		SetAnimation(H078_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("odin")
	end,

	ddd = function( effectScript )
		H078_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H078_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(70, 102), 3, 800, 300, 1, H078_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow12", effectScript)
	end,

	add = function( effectScript )
		DetachEffect(H078_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H078_normal_attack.info_pool[effectScript.ID].Attacker, H078_normal_attack.info_pool[effectScript.ID].Targeter, H078_normal_attack.info_pool[effectScript.ID].AttackType, H078_normal_attack.info_pool[effectScript.ID].AttackDataList, H078_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
