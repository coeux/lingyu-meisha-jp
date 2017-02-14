S551_magic_H015_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S551_magic_H015_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S551_magic_H015_attack.info_pool[effectScript.ID].Attacker)
        
		S551_magic_H015_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
	end,

	a = function( effectScript )
		SetAnimation(S551_magic_H015_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
