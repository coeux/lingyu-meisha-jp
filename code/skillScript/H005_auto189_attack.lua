H005_auto189_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H005_auto189_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H005_auto189_attack.info_pool[effectScript.ID].Attacker)
        
		H005_auto189_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0501")
		PreLoadSound("skill_0502")
		PreLoadSound("skill_0502")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 3, "ghjhk" )
		effectScript:RegisterEvent( 17, "dffgh" )
		effectScript:RegisterEvent( 20, "jhgjhk" )
	end,

	a = function( effectScript )
		SetAnimation(H005_auto189_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("stalk_0501")
	end,

	ghjhk = function( effectScript )
			PlaySound("skill_0502")
	end,

	dffgh = function( effectScript )
			PlaySound("skill_0502")
	end,

	jhgjhk = function( effectScript )
			DamageEffect(H005_auto189_attack.info_pool[effectScript.ID].Attacker, H005_auto189_attack.info_pool[effectScript.ID].Targeter, H005_auto189_attack.info_pool[effectScript.ID].AttackType, H005_auto189_attack.info_pool[effectScript.ID].AttackDataList, H005_auto189_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
