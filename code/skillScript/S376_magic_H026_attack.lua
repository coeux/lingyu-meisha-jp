S376_magic_H026_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S376_magic_H026_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S376_magic_H026_attack.info_pool[effectScript.ID].Attacker)
        
		S376_magic_H026_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fgtjhgk" )
		effectScript:RegisterEvent( 24, "gfjk" )
	end,

	fgtjhgk = function( effectScript )
		SetAnimation(S376_magic_H026_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	gfjk = function( effectScript )
			DamageEffect(S376_magic_H026_attack.info_pool[effectScript.ID].Attacker, S376_magic_H026_attack.info_pool[effectScript.ID].Targeter, S376_magic_H026_attack.info_pool[effectScript.ID].AttackType, S376_magic_H026_attack.info_pool[effectScript.ID].AttackDataList, S376_magic_H026_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
