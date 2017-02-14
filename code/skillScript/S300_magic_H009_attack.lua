S300_magic_H009_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S300_magic_H009_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S300_magic_H009_attack.info_pool[effectScript.ID].Attacker)
        
		S300_magic_H009_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0901")
		PreLoadAvatar("S300_3")
		PreLoadAvatar("S300_2")
		PreLoadAvatar("S300_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdff" )
		effectScript:RegisterEvent( 10, "dsafag" )
		effectScript:RegisterEvent( 23, "fdshj" )
		effectScript:RegisterEvent( 36, "gdfh" )
		effectScript:RegisterEvent( 45, "b" )
		effectScript:RegisterEvent( 46, "asfdsgfdgh" )
		effectScript:RegisterEvent( 60, "dgdh" )
		effectScript:RegisterEvent( 62, "dfhgj" )
		effectScript:RegisterEvent( 67, "sdggfh" )
		effectScript:RegisterEvent( 68, "sdfdhg" )
		effectScript:RegisterEvent( 71, "dfshg" )
		effectScript:RegisterEvent( 72, "fghgfdh" )
	end,

	sdff = function( effectScript )
		SetAnimation(S300_magic_H009_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_0901")
	end,

	dsafag = function( effectScript )
	end,

	fdshj = function( effectScript )
	end,

	gdfh = function( effectScript )
	end,

	b = function( effectScript )
		SetAnimation(S300_magic_H009_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	asfdsgfdgh = function( effectScript )
		AttachAvatarPosEffect(false, S300_magic_H009_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 10), 1.2, -100, "S300_3")
	end,

	dgdh = function( effectScript )
	end,

	dfhgj = function( effectScript )
		AttachAvatarPosEffect(false, S300_magic_H009_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(220, 90), 2.5, 100, "S300_2")
	end,

	sdggfh = function( effectScript )
		AttachAvatarPosEffect(false, S300_magic_H009_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 50), 2.5, 100, "S300_1")
	end,

	sdfdhg = function( effectScript )
			DamageEffect(S300_magic_H009_attack.info_pool[effectScript.ID].Attacker, S300_magic_H009_attack.info_pool[effectScript.ID].Targeter, S300_magic_H009_attack.info_pool[effectScript.ID].AttackType, S300_magic_H009_attack.info_pool[effectScript.ID].AttackDataList, S300_magic_H009_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dfshg = function( effectScript )
			DamageEffect(S300_magic_H009_attack.info_pool[effectScript.ID].Attacker, S300_magic_H009_attack.info_pool[effectScript.ID].Targeter, S300_magic_H009_attack.info_pool[effectScript.ID].AttackType, S300_magic_H009_attack.info_pool[effectScript.ID].AttackDataList, S300_magic_H009_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fghgfdh = function( effectScript )
			DamageEffect(S300_magic_H009_attack.info_pool[effectScript.ID].Attacker, S300_magic_H009_attack.info_pool[effectScript.ID].Targeter, S300_magic_H009_attack.info_pool[effectScript.ID].AttackType, S300_magic_H009_attack.info_pool[effectScript.ID].AttackDataList, S300_magic_H009_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
