S449_magic_P103_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S449_magic_P103_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S449_magic_P103_attack.info_pool[effectScript.ID].Attacker)
        
		S449_magic_P103_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adsf" )
	end,

	adsf = function( effectScript )
		SetAnimation(S449_magic_P103_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

}
