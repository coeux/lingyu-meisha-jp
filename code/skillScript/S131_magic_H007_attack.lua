S131_magic_H007_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S131_magic_H007_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S131_magic_H007_attack.info_pool[effectScript.ID].Attacker)
        
		S131_magic_H007_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_0701")
		PreLoadAvatar("S130_2")
		PreLoadAvatar("S130_1")
		PreLoadAvatar("S130_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 7, "adffd" )
		effectScript:RegisterEvent( 8, "fgdh" )
		effectScript:RegisterEvent( 15, "adsaf" )
		effectScript:RegisterEvent( 32, "tfdgfg" )
		effectScript:RegisterEvent( 39, "b" )
		effectScript:RegisterEvent( 40, "frgf" )
		effectScript:RegisterEvent( 42, "fddg" )
		effectScript:RegisterEvent( 45, "fdagf" )
	end,

	a = function( effectScript )
		SetAnimation(S131_magic_H007_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("atalk_0701")
	end,

	adffd = function( effectScript )
		AttachAvatarPosEffect(false, S131_magic_H007_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S130_2")
	end,

	fgdh = function( effectScript )
	end,

	adsaf = function( effectScript )
		AttachAvatarPosEffect(false, S131_magic_H007_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 120), 1.8, 100, "S130_1")
	end,

	tfdgfg = function( effectScript )
		AttachAvatarPosEffect(false, S131_magic_H007_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 0), 2, 100, "S130_3")
	end,

	b = function( effectScript )
			DamageEffect(S131_magic_H007_attack.info_pool[effectScript.ID].Attacker, S131_magic_H007_attack.info_pool[effectScript.ID].Targeter, S131_magic_H007_attack.info_pool[effectScript.ID].AttackType, S131_magic_H007_attack.info_pool[effectScript.ID].AttackDataList, S131_magic_H007_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	frgf = function( effectScript )
	end,

	fddg = function( effectScript )
			DamageEffect(S131_magic_H007_attack.info_pool[effectScript.ID].Attacker, S131_magic_H007_attack.info_pool[effectScript.ID].Targeter, S131_magic_H007_attack.info_pool[effectScript.ID].AttackType, S131_magic_H007_attack.info_pool[effectScript.ID].AttackDataList, S131_magic_H007_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fdagf = function( effectScript )
			DamageEffect(S131_magic_H007_attack.info_pool[effectScript.ID].Attacker, S131_magic_H007_attack.info_pool[effectScript.ID].Targeter, S131_magic_H007_attack.info_pool[effectScript.ID].AttackType, S131_magic_H007_attack.info_pool[effectScript.ID].AttackDataList, S131_magic_H007_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
