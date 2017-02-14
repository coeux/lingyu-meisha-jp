H034_auto708_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H034_auto708_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H034_auto708_attack.info_pool[effectScript.ID].Attacker)
        
		H034_auto708_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdgfh" )
		effectScript:RegisterEvent( 8, "fgh" )
	end,

	fdgfh = function( effectScript )
		SetAnimation(H034_auto708_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fgh = function( effectScript )
			DamageEffect(H034_auto708_attack.info_pool[effectScript.ID].Attacker, H034_auto708_attack.info_pool[effectScript.ID].Targeter, H034_auto708_attack.info_pool[effectScript.ID].AttackType, H034_auto708_attack.info_pool[effectScript.ID].AttackDataList, H034_auto708_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
