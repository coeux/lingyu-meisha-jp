S462_magic_H029_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S462_magic_H029_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S462_magic_H029_attack.info_pool[effectScript.ID].Attacker)
        
		S462_magic_H029_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0293")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "vuug" )
		effectScript:RegisterEvent( 32, "fdsh" )
	end,

	vuug = function( effectScript )
		SetAnimation(S462_magic_H029_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s0293")
	end,

	fdsh = function( effectScript )
			DamageEffect(S462_magic_H029_attack.info_pool[effectScript.ID].Attacker, S462_magic_H029_attack.info_pool[effectScript.ID].Targeter, S462_magic_H029_attack.info_pool[effectScript.ID].AttackType, S462_magic_H029_attack.info_pool[effectScript.ID].AttackDataList, S462_magic_H029_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
