H029_auto468_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H029_auto468_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H029_auto468_attack.info_pool[effectScript.ID].Attacker)
        
		H029_auto468_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0293")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfdh" )
		effectScript:RegisterEvent( 28, "dsgfdh" )
	end,

	sdfdh = function( effectScript )
		SetAnimation(H029_auto468_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s0293")
	end,

	dsgfdh = function( effectScript )
			DamageEffect(H029_auto468_attack.info_pool[effectScript.ID].Attacker, H029_auto468_attack.info_pool[effectScript.ID].Targeter, H029_auto468_attack.info_pool[effectScript.ID].AttackType, H029_auto468_attack.info_pool[effectScript.ID].AttackDataList, H029_auto468_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
