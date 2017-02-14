M014_auto603_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M014_auto603_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M014_auto603_attack.info_pool[effectScript.ID].Attacker)
        
		M014_auto603_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "jhkjhlkjl" )
		effectScript:RegisterEvent( 8, "gjhkj" )
	end,

	jhkjhlkjl = function( effectScript )
		SetAnimation(M014_auto603_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	gjhkj = function( effectScript )
			DamageEffect(M014_auto603_attack.info_pool[effectScript.ID].Attacker, M014_auto603_attack.info_pool[effectScript.ID].Targeter, M014_auto603_attack.info_pool[effectScript.ID].AttackType, M014_auto603_attack.info_pool[effectScript.ID].AttackDataList, M014_auto603_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
