S933_magic_H058_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S933_magic_H058_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S933_magic_H058_attack.info_pool[effectScript.ID].Attacker)
        
		S933_magic_H058_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_05802")
		PreLoadAvatar("H058_4_1")
		PreLoadSound("stalk_05801")
		PreLoadAvatar("H058_4_2")
		PreLoadAvatar("H058_4_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fgh" )
		effectScript:RegisterEvent( 15, "fhu" )
		effectScript:RegisterEvent( 21, "bc" )
		effectScript:RegisterEvent( 24, "jh" )
		effectScript:RegisterEvent( 26, "ghz" )
	end,

	fgh = function( effectScript )
		SetAnimation(S933_magic_H058_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("skill_05802")
	end,

	fhu = function( effectScript )
		AttachAvatarPosEffect(false, S933_magic_H058_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "H058_4_1")
		PlaySound("stalk_05801")
	end,

	bc = function( effectScript )
		AttachAvatarPosEffect(false, S933_magic_H058_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -14), 1.1, 100, "H058_4_2")
	end,

	jh = function( effectScript )
		AttachAvatarPosEffect(false, S933_magic_H058_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H058_4_3")
	end,

	ghz = function( effectScript )
			DamageEffect(S933_magic_H058_attack.info_pool[effectScript.ID].Attacker, S933_magic_H058_attack.info_pool[effectScript.ID].Targeter, S933_magic_H058_attack.info_pool[effectScript.ID].AttackType, S933_magic_H058_attack.info_pool[effectScript.ID].AttackDataList, S933_magic_H058_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
