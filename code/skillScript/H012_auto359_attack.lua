H012_auto359_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H012_auto359_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H012_auto359_attack.info_pool[effectScript.ID].Attacker)
        
		H012_auto359_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgvfdh" )
	end,

	dgvfdh = function( effectScript )
		SetAnimation(H012_auto359_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
