S371_magic_H026_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S371_magic_H026_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S371_magic_H026_attack.info_pool[effectScript.ID].Attacker)
        
		S371_magic_H026_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfdhgh" )
		effectScript:RegisterEvent( 30, "sdfdhh" )
		effectScript:RegisterEvent( 54, "dsfdh" )
	end,

	dfdhgh = function( effectScript )
		SetAnimation(S371_magic_H026_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sdfdhh = function( effectScript )
		SetAnimation(S371_magic_H026_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdh = function( effectScript )
			DamageEffect(S371_magic_H026_attack.info_pool[effectScript.ID].Attacker, S371_magic_H026_attack.info_pool[effectScript.ID].Targeter, S371_magic_H026_attack.info_pool[effectScript.ID].AttackType, S371_magic_H026_attack.info_pool[effectScript.ID].AttackDataList, S371_magic_H026_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
