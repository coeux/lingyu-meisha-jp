S463_magic_H029_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S463_magic_H029_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S463_magic_H029_attack.info_pool[effectScript.ID].Attacker)
        
		S463_magic_H029_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0293")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "vuug" )
		effectScript:RegisterEvent( 32, "fdsh" )
	end,

	vuug = function( effectScript )
		SetAnimation(S463_magic_H029_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s0293")
	end,

	fdsh = function( effectScript )
			DamageEffect(S463_magic_H029_attack.info_pool[effectScript.ID].Attacker, S463_magic_H029_attack.info_pool[effectScript.ID].Targeter, S463_magic_H029_attack.info_pool[effectScript.ID].AttackType, S463_magic_H029_attack.info_pool[effectScript.ID].AttackDataList, S463_magic_H029_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
