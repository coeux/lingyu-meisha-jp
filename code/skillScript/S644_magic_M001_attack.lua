S644_magic_M001_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S644_magic_M001_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S644_magic_M001_attack.info_pool[effectScript.ID].Attacker)
        
		S644_magic_M001_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfd" )
	end,

	sfd = function( effectScript )
		SetAnimation(S644_magic_M001_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

}
