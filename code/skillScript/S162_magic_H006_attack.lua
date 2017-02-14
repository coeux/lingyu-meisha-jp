S162_magic_H006_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S162_magic_H006_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S162_magic_H006_attack.info_pool[effectScript.ID].Attacker)
        
		S162_magic_H006_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0601")
		PreLoadAvatar("S160_2")
		PreLoadSound("skill_0601")
		PreLoadSound("skill_0602")
		PreLoadAvatar("S160_1")
		PreLoadAvatar("S160_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adsss" )
		effectScript:RegisterEvent( 4, "ads" )
		effectScript:RegisterEvent( 6, "sfdh" )
		effectScript:RegisterEvent( 20, "fdsg" )
		effectScript:RegisterEvent( 23, "sf" )
		effectScript:RegisterEvent( 25, "dsaf" )
		effectScript:RegisterEvent( 27, "af" )
	end,

	adsss = function( effectScript )
		SetAnimation(S162_magic_H006_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_0601")
	end,

	ads = function( effectScript )
		AttachAvatarPosEffect(false, S162_magic_H006_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 35), 1.5, 100, "S160_2")
	end,

	sfdh = function( effectScript )
			PlaySound("skill_0601")
	end,

	fdsg = function( effectScript )
			PlaySound("skill_0602")
	end,

	sf = function( effectScript )
		AttachAvatarPosEffect(false, S162_magic_H006_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 2, 100, "S160_1")
	end,

	dsaf = function( effectScript )
		AttachAvatarPosEffect(false, S162_magic_H006_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2.5, 100, "S160_3")
	end,

	af = function( effectScript )
			DamageEffect(S162_magic_H006_attack.info_pool[effectScript.ID].Attacker, S162_magic_H006_attack.info_pool[effectScript.ID].Targeter, S162_magic_H006_attack.info_pool[effectScript.ID].AttackType, S162_magic_H006_attack.info_pool[effectScript.ID].AttackDataList, S162_magic_H006_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
