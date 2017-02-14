H042_auto778_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H042_auto778_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H042_auto778_attack.info_pool[effectScript.ID].Attacker)
        
		H042_auto778_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sefdgfhgjkj" )
		effectScript:RegisterEvent( 9, "fgfhfhgj" )
	end,

	sefdgfhgjkj = function( effectScript )
		SetAnimation(H042_auto778_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fgfhfhgj = function( effectScript )
			DamageEffect(H042_auto778_attack.info_pool[effectScript.ID].Attacker, H042_auto778_attack.info_pool[effectScript.ID].Targeter, H042_auto778_attack.info_pool[effectScript.ID].AttackType, H042_auto778_attack.info_pool[effectScript.ID].AttackDataList, H042_auto778_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
