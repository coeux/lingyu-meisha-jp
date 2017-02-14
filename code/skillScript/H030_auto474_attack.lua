H030_auto474_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H030_auto474_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H030_auto474_attack.info_pool[effectScript.ID].Attacker)
        
		H030_auto474_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_03001")
		PreLoadSound("s0312")
		PreLoadAvatar("S472_1")
		PreLoadSound("s0302")
		PreLoadAvatar("S620_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgh" )
		effectScript:RegisterEvent( 19, "fdgdh" )
		effectScript:RegisterEvent( 24, "dghg" )
		effectScript:RegisterEvent( 28, "ddsg" )
	end,

	dfgh = function( effectScript )
		SetAnimation(H030_auto474_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("atalk_03001")
		PlaySound("s0312")
	end,

	fdgdh = function( effectScript )
		AttachAvatarPosEffect(false, H030_auto474_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 60), 1.2, 100, "S472_1")
		PlaySound("s0302")
	end,

	dghg = function( effectScript )
		AttachAvatarPosEffect(false, H030_auto474_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S620_3")
	end,

	ddsg = function( effectScript )
			DamageEffect(H030_auto474_attack.info_pool[effectScript.ID].Attacker, H030_auto474_attack.info_pool[effectScript.ID].Targeter, H030_auto474_attack.info_pool[effectScript.ID].AttackType, H030_auto474_attack.info_pool[effectScript.ID].AttackDataList, H030_auto474_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
