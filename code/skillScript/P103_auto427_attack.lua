P103_auto427_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P103_auto427_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P103_auto427_attack.info_pool[effectScript.ID].Attacker)
        
		P103_auto427_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s010133")
		PreLoadSound("atalk_010301")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adsf" )
		effectScript:RegisterEvent( 35, "rtytuyi" )
	end,

	adsf = function( effectScript )
		SetAnimation(P103_auto427_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s010133")
		PlaySound("atalk_010301")
	end,

	rtytuyi = function( effectScript )
			DamageEffect(P103_auto427_attack.info_pool[effectScript.ID].Attacker, P103_auto427_attack.info_pool[effectScript.ID].Targeter, P103_auto427_attack.info_pool[effectScript.ID].AttackType, P103_auto427_attack.info_pool[effectScript.ID].AttackDataList, P103_auto427_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
