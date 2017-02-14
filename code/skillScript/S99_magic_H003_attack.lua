S99_magic_H003_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S99_magic_H003_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S99_magic_H003_attack.info_pool[effectScript.ID].Attacker)
        
		S99_magic_H003_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfd" )
	end,

	sfd = function( effectScript )
		SetAnimation(S99_magic_H003_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_run)
	end,

}
