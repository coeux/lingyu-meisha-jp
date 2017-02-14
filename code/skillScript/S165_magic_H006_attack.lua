S165_magic_H006_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S165_magic_H006_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S165_magic_H006_attack.info_pool[effectScript.ID].Attacker)
        
		S165_magic_H006_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0601")
		PreLoadAvatar("S162_3")
		PreLoadSound("skill_0601")
		PreLoadSound("skill_0602")
		PreLoadAvatar("S162_2")
		PreLoadAvatar("S162_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ad" )
		effectScript:RegisterEvent( 4, "adf" )
		effectScript:RegisterEvent( 6, "sdfdh" )
		effectScript:RegisterEvent( 22, "sfdh" )
		effectScript:RegisterEvent( 25, "sf" )
		effectScript:RegisterEvent( 28, "dsaf" )
		effectScript:RegisterEvent( 30, "asdf" )
	end,

	ad = function( effectScript )
		SetAnimation(S165_magic_H006_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_0601")
	end,

	adf = function( effectScript )
		AttachAvatarPosEffect(false, S165_magic_H006_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-10, 60), 2, 100, "S162_3")
	end,

	sdfdh = function( effectScript )
			PlaySound("skill_0601")
	end,

	sfdh = function( effectScript )
			PlaySound("skill_0602")
	end,

	sf = function( effectScript )
		AttachAvatarPosEffect(false, S165_magic_H006_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 60), 2.5, 100, "S162_2")
	end,

	dsaf = function( effectScript )
		AttachAvatarPosEffect(false, S165_magic_H006_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S162_1")
	end,

	asdf = function( effectScript )
			DamageEffect(S165_magic_H006_attack.info_pool[effectScript.ID].Attacker, S165_magic_H006_attack.info_pool[effectScript.ID].Targeter, S165_magic_H006_attack.info_pool[effectScript.ID].AttackType, S165_magic_H006_attack.info_pool[effectScript.ID].AttackDataList, S165_magic_H006_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
