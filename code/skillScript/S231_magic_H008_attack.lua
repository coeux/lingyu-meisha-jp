S231_magic_H008_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S231_magic_H008_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S231_magic_H008_attack.info_pool[effectScript.ID].Attacker)
        
		S231_magic_H008_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_0801")
		PreLoadAvatar("S230_2")
		PreLoadAvatar("S230_3")
		PreLoadAvatar("S230_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "saff" )
		effectScript:RegisterEvent( 5, "sgdfh" )
		effectScript:RegisterEvent( 23, "asdaf" )
		effectScript:RegisterEvent( 43, "fdgdfjh" )
		effectScript:RegisterEvent( 48, "dgrgd" )
		effectScript:RegisterEvent( 49, "adffsf" )
		effectScript:RegisterEvent( 50, "asfsd" )
		effectScript:RegisterEvent( 51, "adfsfdsg" )
	end,

	saff = function( effectScript )
		SetAnimation(S231_magic_H008_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sgdfh = function( effectScript )
	end,

	asdaf = function( effectScript )
		SetAnimation(S231_magic_H008_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fdgdfjh = function( effectScript )
		PlaySound("atalk_0801")
	end,

	dgrgd = function( effectScript )
		AttachAvatarPosEffect(false, S231_magic_H008_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(130, 70), 2, 100, "S230_2")
	end,

	adffsf = function( effectScript )
		AttachAvatarPosEffect(false, S231_magic_H008_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 80), 1, 100, "S230_3")
	end,

	asfsd = function( effectScript )
		AttachAvatarPosEffect(false, S231_magic_H008_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 70), 1, 100, "S230_1")
	end,

	adfsfdsg = function( effectScript )
			DamageEffect(S231_magic_H008_attack.info_pool[effectScript.ID].Attacker, S231_magic_H008_attack.info_pool[effectScript.ID].Targeter, S231_magic_H008_attack.info_pool[effectScript.ID].AttackType, S231_magic_H008_attack.info_pool[effectScript.ID].AttackDataList, S231_magic_H008_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
