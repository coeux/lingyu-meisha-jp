H003_auto159_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H003_auto159_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H003_auto159_attack.info_pool[effectScript.ID].Attacker)
        
		H003_auto159_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ilklk" )
		effectScript:RegisterEvent( 8, "hjkljl" )
	end,

	ilklk = function( effectScript )
		SetAnimation(H003_auto159_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	hjkljl = function( effectScript )
			DamageEffect(H003_auto159_attack.info_pool[effectScript.ID].Attacker, H003_auto159_attack.info_pool[effectScript.ID].Targeter, H003_auto159_attack.info_pool[effectScript.ID].AttackType, H003_auto159_attack.info_pool[effectScript.ID].AttackDataList, H003_auto159_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
