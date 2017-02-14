S803_magic_H045_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S803_magic_H045_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S803_magic_H045_attack.info_pool[effectScript.ID].Attacker)
        
		S803_magic_H045_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_04501")
		PreLoadAvatar("H045_xuli_1")
		PreLoadSound("attack_04501")
		PreLoadAvatar("S802_1")
		PreLoadAvatar("H045_pugong_1")
		PreLoadSound("attack_04502")
		PreLoadAvatar("S802_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgfhj" )
		effectScript:RegisterEvent( 9, "fdfdgfh" )
		effectScript:RegisterEvent( 25, "fdgfdgf" )
		effectScript:RegisterEvent( 33, "sdfdgfh" )
		effectScript:RegisterEvent( 35, "saffdgh" )
		effectScript:RegisterEvent( 36, "fdgfghh" )
	end,

	dfgfhj = function( effectScript )
		SetAnimation(S803_magic_H045_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("atalk_04501")
	end,

	fdfdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S803_magic_H045_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 0), 1, 100, "H045_xuli_1")
		PlaySound("attack_04501")
	end,

	fdgfdgf = function( effectScript )
		AttachAvatarPosEffect(false, S803_magic_H045_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-40, 200), 1.2, 100, "S802_1")
	end,

	sdfdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S803_magic_H045_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 40), 1.5, 100, "H045_pugong_1")
		PlaySound("attack_04502")
	end,

	saffdgh = function( effectScript )
		AttachAvatarPosEffect(false, S803_magic_H045_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S802_2")
	end,

	fdgfghh = function( effectScript )
			DamageEffect(S803_magic_H045_attack.info_pool[effectScript.ID].Attacker, S803_magic_H045_attack.info_pool[effectScript.ID].Targeter, S803_magic_H045_attack.info_pool[effectScript.ID].AttackType, S803_magic_H045_attack.info_pool[effectScript.ID].AttackDataList, S803_magic_H045_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
