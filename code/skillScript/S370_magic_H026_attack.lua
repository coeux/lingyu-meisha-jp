S370_magic_H026_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S370_magic_H026_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S370_magic_H026_attack.info_pool[effectScript.ID].Attacker)
        
		S370_magic_H026_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfdhgh" )
		effectScript:RegisterEvent( 45, "sdfdhh" )
		effectScript:RegisterEvent( 70, "dsfdh" )
	end,

	dfdhgh = function( effectScript )
		SetAnimation(S370_magic_H026_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sdfdhh = function( effectScript )
		SetAnimation(S370_magic_H026_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdh = function( effectScript )
			DamageEffect(S370_magic_H026_attack.info_pool[effectScript.ID].Attacker, S370_magic_H026_attack.info_pool[effectScript.ID].Targeter, S370_magic_H026_attack.info_pool[effectScript.ID].AttackType, S370_magic_H026_attack.info_pool[effectScript.ID].AttackDataList, S370_magic_H026_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
