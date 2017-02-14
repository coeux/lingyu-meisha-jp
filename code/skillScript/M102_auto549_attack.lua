M102_auto549_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M102_auto549_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M102_auto549_attack.info_pool[effectScript.ID].Attacker)
        
		M102_auto549_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aad" )
		effectScript:RegisterEvent( 9, "dfgdh" )
	end,

	aad = function( effectScript )
		SetAnimation(M102_auto549_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dfgdh = function( effectScript )
			DamageEffect(M102_auto549_attack.info_pool[effectScript.ID].Attacker, M102_auto549_attack.info_pool[effectScript.ID].Targeter, M102_auto549_attack.info_pool[effectScript.ID].AttackType, M102_auto549_attack.info_pool[effectScript.ID].AttackDataList, M102_auto549_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
