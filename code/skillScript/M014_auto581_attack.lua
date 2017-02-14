M014_auto581_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M014_auto581_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M014_auto581_attack.info_pool[effectScript.ID].Attacker)
        
		M014_auto581_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S581_1")
		PreLoadAvatar("S581_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "yjhkkjl" )
		effectScript:RegisterEvent( 23, "jhkjl" )
		effectScript:RegisterEvent( 26, "dsdgfjhjm" )
		effectScript:RegisterEvent( 28, "dfgfdh" )
	end,

	yjhkkjl = function( effectScript )
		SetAnimation(M014_auto581_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	jhkjl = function( effectScript )
		AttachAvatarPosEffect(false, M014_auto581_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 80), 1.5, 100, "S581_1")
	end,

	dsdgfjhjm = function( effectScript )
		AttachAvatarPosEffect(false, M014_auto581_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.8, 100, "S581_2")
	end,

	dfgfdh = function( effectScript )
			DamageEffect(M014_auto581_attack.info_pool[effectScript.ID].Attacker, M014_auto581_attack.info_pool[effectScript.ID].Targeter, M014_auto581_attack.info_pool[effectScript.ID].AttackType, M014_auto581_attack.info_pool[effectScript.ID].AttackDataList, M014_auto581_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
