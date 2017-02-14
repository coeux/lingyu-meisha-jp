H007_auto617_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H007_auto617_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H007_auto617_attack.info_pool[effectScript.ID].Attacker)
        
		H007_auto617_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ass" )
		effectScript:RegisterEvent( 8, "hggjj" )
	end,

	ass = function( effectScript )
		SetAnimation(H007_auto617_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	hggjj = function( effectScript )
			DamageEffect(H007_auto617_attack.info_pool[effectScript.ID].Attacker, H007_auto617_attack.info_pool[effectScript.ID].Targeter, H007_auto617_attack.info_pool[effectScript.ID].AttackType, H007_auto617_attack.info_pool[effectScript.ID].AttackDataList, H007_auto617_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
