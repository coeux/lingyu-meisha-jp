S962_magic_H061_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S962_magic_H061_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S962_magic_H061_attack.info_pool[effectScript.ID].Attacker)
        
		S962_magic_H061_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_06103")
		PreLoadAvatar("H061_1_2")
		PreLoadAvatar("H061_1_1")
		PreLoadAvatar("H061_4_1")
		PreLoadSound("stalk_06101")
		PreLoadAvatar("H061_4_3")
		PreLoadAvatar("H061_4_2")
		PreLoadAvatar("H061_4_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "gvt" )
		effectScript:RegisterEvent( 1, "sd" )
		effectScript:RegisterEvent( 3, "bfzv" )
		effectScript:RegisterEvent( 6, "ddfva" )
		effectScript:RegisterEvent( 28, "dffg" )
		effectScript:RegisterEvent( 36, "sd1" )
		effectScript:RegisterEvent( 41, "divs" )
		effectScript:RegisterEvent( 44, "fvb" )
		effectScript:RegisterEvent( 46, "rgs" )
	end,

	gvt = function( effectScript )
		SetAnimation(S962_magic_H061_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sd = function( effectScript )
			PlaySound("skill_06103")
	end,

	bfzv = function( effectScript )
		AttachAvatarPosEffect(false, S962_magic_H061_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "H061_1_2")
	end,

	ddfva = function( effectScript )
		AttachAvatarPosEffect(false, S962_magic_H061_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-10, -40), 1.3, 100, "H061_1_1")
	end,

	dffg = function( effectScript )
		SetAnimation(S962_magic_H061_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	AttachAvatarPosEffect(false, S962_magic_H061_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "H061_4_1")
	end,

	sd1 = function( effectScript )
			PlaySound("stalk_06101")
	end,

	divs = function( effectScript )
		AttachAvatarPosEffect(false, S962_magic_H061_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -30), 1.25, 100, "H061_4_3")
	AttachAvatarPosEffect(false, S962_magic_H061_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-230, -60), 1, -100, "H061_4_2")
	end,

	fvb = function( effectScript )
		AttachAvatarPosEffect(false, S962_magic_H061_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(30, -30), 1.4, 100, "H061_4_4")
	end,

	rgs = function( effectScript )
			DamageEffect(S962_magic_H061_attack.info_pool[effectScript.ID].Attacker, S962_magic_H061_attack.info_pool[effectScript.ID].Targeter, S962_magic_H061_attack.info_pool[effectScript.ID].AttackType, S962_magic_H061_attack.info_pool[effectScript.ID].AttackDataList, S962_magic_H061_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
