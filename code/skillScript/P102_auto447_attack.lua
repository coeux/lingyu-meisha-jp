P102_auto447_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P102_auto447_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P102_auto447_attack.info_pool[effectScript.ID].Attacker)
        
		P102_auto447_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s01022")
		PreLoadSound("stalk_010201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdf" )
		effectScript:RegisterEvent( 40, "uiolipo" )
	end,

	sfdf = function( effectScript )
		SetAnimation(P102_auto447_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s01022")
		PlaySound("stalk_010201")
	end,

	uiolipo = function( effectScript )
			DamageEffect(P102_auto447_attack.info_pool[effectScript.ID].Attacker, P102_auto447_attack.info_pool[effectScript.ID].Targeter, P102_auto447_attack.info_pool[effectScript.ID].AttackType, P102_auto447_attack.info_pool[effectScript.ID].AttackDataList, P102_auto447_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
