H032_auto407_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H032_auto407_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H032_auto407_attack.info_pool[effectScript.ID].Attacker)
        
		H032_auto407_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_03201")
		PreLoadSound("atalk_03201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfg" )
		effectScript:RegisterEvent( 33, "dfgh" )
	end,

	sfg = function( effectScript )
		SetAnimation(H032_auto407_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_03201")
		PlaySound("atalk_03201")
	end,

	dfgh = function( effectScript )
			DamageEffect(H032_auto407_attack.info_pool[effectScript.ID].Attacker, H032_auto407_attack.info_pool[effectScript.ID].Targeter, H032_auto407_attack.info_pool[effectScript.ID].AttackType, H032_auto407_attack.info_pool[effectScript.ID].AttackDataList, H032_auto407_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
