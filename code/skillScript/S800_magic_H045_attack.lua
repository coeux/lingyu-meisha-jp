S800_magic_H045_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S800_magic_H045_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S800_magic_H045_attack.info_pool[effectScript.ID].Attacker)
        
		S800_magic_H045_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_04503")
		PreLoadAvatar("S800_1")
		PreLoadAvatar("H045_pugong_1")
		PreLoadAvatar("H036_pugong_1")
		PreLoadSound("skill_04502")
		PreLoadAvatar("S800_2")
		PreLoadSound("skill_04501")
		PreLoadAvatar("S800_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfggghgjh" )
		effectScript:RegisterEvent( 11, "dgfhgfgh" )
		effectScript:RegisterEvent( 23, "hgjhk" )
		effectScript:RegisterEvent( 24, "asfdsfgdg" )
		effectScript:RegisterEvent( 29, "fdgfdhhj" )
		effectScript:RegisterEvent( 30, "dfdgfdhgh" )
		effectScript:RegisterEvent( 32, "fdsfgh" )
	end,

	dsfggghgjh = function( effectScript )
		SetAnimation(S800_magic_H045_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_04503")
	end,

	dgfhgfgh = function( effectScript )
		AttachAvatarPosEffect(false, S800_magic_H045_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 150), 1.5, 100, "S800_1")
	end,

	hgjhk = function( effectScript )
		AttachAvatarPosEffect(false, S800_magic_H045_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 40), 1.4, 100, "H045_pugong_1")
	end,

	asfdsfgdg = function( effectScript )
		AttachAvatarPosEffect(false, S800_magic_H045_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H036_pugong_1")
		PlaySound("skill_04502")
	end,

	fdgfdhhj = function( effectScript )
		AttachAvatarPosEffect(false, S800_magic_H045_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 50), 1.8, 100, "S800_2")
		PlaySound("skill_04501")
	end,

	dfdgfdhgh = function( effectScript )
		AttachAvatarPosEffect(false, S800_magic_H045_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S800_3")
	end,

	fdsfgh = function( effectScript )
			DamageEffect(S800_magic_H045_attack.info_pool[effectScript.ID].Attacker, S800_magic_H045_attack.info_pool[effectScript.ID].Targeter, S800_magic_H045_attack.info_pool[effectScript.ID].AttackType, S800_magic_H045_attack.info_pool[effectScript.ID].AttackDataList, S800_magic_H045_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
