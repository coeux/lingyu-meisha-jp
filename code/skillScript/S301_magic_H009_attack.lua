S301_magic_H009_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_H009_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_H009_attack.info_pool[effectScript.ID].Attacker)
        
		S301_magic_H009_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0901")
		PreLoadAvatar("S300_3")
		PreLoadAvatar("S300_2")
		PreLoadAvatar("S300_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdff" )
		effectScript:RegisterEvent( 7, "dgfdhj" )
		effectScript:RegisterEvent( 17, "sfdsh" )
		effectScript:RegisterEvent( 23, "b" )
		effectScript:RegisterEvent( 29, "asfdsgfdgh" )
		effectScript:RegisterEvent( 39, "dsfgdh" )
		effectScript:RegisterEvent( 41, "dfhgj" )
		effectScript:RegisterEvent( 45, "sdggfh" )
		effectScript:RegisterEvent( 48, "sdfdhg" )
		effectScript:RegisterEvent( 50, "dfshg" )
		effectScript:RegisterEvent( 52, "fghgfdh" )
	end,

	sdff = function( effectScript )
		SetAnimation(S301_magic_H009_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_0901")
	end,

	dgfdhj = function( effectScript )
	end,

	sfdsh = function( effectScript )
	end,

	b = function( effectScript )
		SetAnimation(S301_magic_H009_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	asfdsgfdgh = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H009_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 10), 1.2, -100, "S300_3")
	end,

	dsfgdh = function( effectScript )
	end,

	dfhgj = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H009_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(220, 90), 2.5, 100, "S300_2")
	end,

	sdggfh = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H009_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 50), 2.5, 100, "S300_1")
	end,

	sdfdhg = function( effectScript )
			DamageEffect(S301_magic_H009_attack.info_pool[effectScript.ID].Attacker, S301_magic_H009_attack.info_pool[effectScript.ID].Targeter, S301_magic_H009_attack.info_pool[effectScript.ID].AttackType, S301_magic_H009_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H009_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dfshg = function( effectScript )
			DamageEffect(S301_magic_H009_attack.info_pool[effectScript.ID].Attacker, S301_magic_H009_attack.info_pool[effectScript.ID].Targeter, S301_magic_H009_attack.info_pool[effectScript.ID].AttackType, S301_magic_H009_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H009_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fghgfdh = function( effectScript )
			DamageEffect(S301_magic_H009_attack.info_pool[effectScript.ID].Attacker, S301_magic_H009_attack.info_pool[effectScript.ID].Targeter, S301_magic_H009_attack.info_pool[effectScript.ID].AttackType, S301_magic_H009_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H009_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
