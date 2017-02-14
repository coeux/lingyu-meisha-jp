H014_auto149_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H014_auto149_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H014_auto149_attack.info_pool[effectScript.ID].Attacker)
        
		H014_auto149_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 8, "kjhkll" )
	end,

	a = function( effectScript )
		SetAnimation(H014_auto149_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	kjhkll = function( effectScript )
			DamageEffect(H014_auto149_attack.info_pool[effectScript.ID].Attacker, H014_auto149_attack.info_pool[effectScript.ID].Targeter, H014_auto149_attack.info_pool[effectScript.ID].AttackType, H014_auto149_attack.info_pool[effectScript.ID].AttackDataList, H014_auto149_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
