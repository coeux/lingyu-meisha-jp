S472_magic_H030_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S472_magic_H030_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S472_magic_H030_attack.info_pool[effectScript.ID].Attacker)
        
		S472_magic_H030_attack.info_pool[effectScript.ID] = nil
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
		SetAnimation(S472_magic_H030_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("atalk_03001")
		PlaySound("s0312")
	end,

	fdgdh = function( effectScript )
		AttachAvatarPosEffect(false, S472_magic_H030_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 60), 1.2, 100, "S472_1")
		PlaySound("s0302")
	end,

	dghg = function( effectScript )
		AttachAvatarPosEffect(false, S472_magic_H030_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S620_3")
	end,

	ddsg = function( effectScript )
			DamageEffect(S472_magic_H030_attack.info_pool[effectScript.ID].Attacker, S472_magic_H030_attack.info_pool[effectScript.ID].Targeter, S472_magic_H030_attack.info_pool[effectScript.ID].AttackType, S472_magic_H030_attack.info_pool[effectScript.ID].AttackDataList, S472_magic_H030_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
