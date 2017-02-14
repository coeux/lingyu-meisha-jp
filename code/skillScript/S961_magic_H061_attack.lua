S961_magic_H061_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S961_magic_H061_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S961_magic_H061_attack.info_pool[effectScript.ID].Attacker)
        
		S961_magic_H061_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_06102")
		PreLoadAvatar("H061_1_2")
		PreLoadAvatar("H061_1_1")
		PreLoadSound("atalk_06101")
		PreLoadAvatar("H061_3_1")
		PreLoadAvatar("H061_3_2")
		PreLoadAvatar("H061_3_3")
		PreLoadAvatar("H061_3_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "gvt" )
		effectScript:RegisterEvent( 1, "sd" )
		effectScript:RegisterEvent( 3, "bfzv" )
		effectScript:RegisterEvent( 6, "ddfva" )
		effectScript:RegisterEvent( 21, "sd1" )
		effectScript:RegisterEvent( 27, "dffg" )
		effectScript:RegisterEvent( 28, "divs" )
		effectScript:RegisterEvent( 29, "fvb" )
		effectScript:RegisterEvent( 31, "rgs" )
	end,

	gvt = function( effectScript )
		SetAnimation(S961_magic_H061_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sd = function( effectScript )
			PlaySound("skill_06102")
	end,

	bfzv = function( effectScript )
		AttachAvatarPosEffect(false, S961_magic_H061_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "H061_1_2")
	end,

	ddfva = function( effectScript )
		AttachAvatarPosEffect(false, S961_magic_H061_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-10, -40), 1.3, 100, "H061_1_1")
	end,

	sd1 = function( effectScript )
			PlaySound("atalk_06101")
	end,

	dffg = function( effectScript )
		SetAnimation(S961_magic_H061_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	AttachAvatarPosEffect(false, S961_magic_H061_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "H061_3_1")
	end,

	divs = function( effectScript )
		AttachAvatarPosEffect(false, S961_magic_H061_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H061_3_2")
	AttachAvatarPosEffect(false, S961_magic_H061_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 150), 1.3, 100, "H061_3_3")
	end,

	fvb = function( effectScript )
		AttachAvatarPosEffect(false, S961_magic_H061_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.35, 100, "H061_3_4")
	end,

	rgs = function( effectScript )
			DamageEffect(S961_magic_H061_attack.info_pool[effectScript.ID].Attacker, S961_magic_H061_attack.info_pool[effectScript.ID].Targeter, S961_magic_H061_attack.info_pool[effectScript.ID].AttackType, S961_magic_H061_attack.info_pool[effectScript.ID].AttackDataList, S961_magic_H061_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
