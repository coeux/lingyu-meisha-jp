S232_magic_H008_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S232_magic_H008_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S232_magic_H008_attack.info_pool[effectScript.ID].Attacker)
        
		S232_magic_H008_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0801")
		PreLoadAvatar("S234_3")
		PreLoadAvatar("S234_2")
		PreLoadAvatar("S234_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asdaf" )
		effectScript:RegisterEvent( 7, "dgdfh" )
		effectScript:RegisterEvent( 19, "adffsf" )
		effectScript:RegisterEvent( 21, "dsfdsh" )
		effectScript:RegisterEvent( 22, "dgrgd" )
		effectScript:RegisterEvent( 25, "asfsd" )
		effectScript:RegisterEvent( 26, "adfsfdsg" )
	end,

	asdaf = function( effectScript )
		SetAnimation(S232_magic_H008_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_0801")
	end,

	dgdfh = function( effectScript )
	end,

	adffsf = function( effectScript )
		AttachAvatarPosEffect(false, S232_magic_H008_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S234_3")
	end,

	dsfdsh = function( effectScript )
	end,

	dgrgd = function( effectScript )
		AttachAvatarPosEffect(false, S232_magic_H008_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 70), 1.2, 100, "S234_2")
	end,

	asfsd = function( effectScript )
		AttachAvatarPosEffect(false, S232_magic_H008_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -2.5, 100, "S234_1")
	end,

	adfsfdsg = function( effectScript )
			DamageEffect(S232_magic_H008_attack.info_pool[effectScript.ID].Attacker, S232_magic_H008_attack.info_pool[effectScript.ID].Targeter, S232_magic_H008_attack.info_pool[effectScript.ID].AttackType, S232_magic_H008_attack.info_pool[effectScript.ID].AttackDataList, S232_magic_H008_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
