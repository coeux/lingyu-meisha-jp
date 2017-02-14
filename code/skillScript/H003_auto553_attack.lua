H003_auto553_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H003_auto553_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H003_auto553_attack.info_pool[effectScript.ID].Attacker)
        
		H003_auto553_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0301")
		PreLoadSound("skill_0301")
		PreLoadAvatar("S150_shifang")
		PreLoadSound("skill_0301")
		PreLoadAvatar("S150_shifa")
		PreLoadSound("skill_0302")
		PreLoadAvatar("S150_daoguang")
		PreLoadAvatar("S150_shouj")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdgfdh" )
		effectScript:RegisterEvent( 4, "jghk" )
		effectScript:RegisterEvent( 14, "gffh" )
		effectScript:RegisterEvent( 16, "fdghjh" )
		effectScript:RegisterEvent( 23, "sdfsfds" )
		effectScript:RegisterEvent( 51, "hfggk" )
		effectScript:RegisterEvent( 53, "dsfdg" )
		effectScript:RegisterEvent( 59, "rgdfgfh" )
		effectScript:RegisterEvent( 64, "gffhhkj" )
		effectScript:RegisterEvent( 69, "yjuk" )
	end,

	sdgfdh = function( effectScript )
		SetAnimation(H003_auto553_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_0301")
	end,

	jghk = function( effectScript )
			PlaySound("skill_0301")
	end,

	gffh = function( effectScript )
		AttachAvatarPosEffect(false, H003_auto553_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 120), 1, 100, "S150_shifang")
	end,

	fdghjh = function( effectScript )
			PlaySound("skill_0301")
	end,

	sdfsfds = function( effectScript )
		AttachAvatarPosEffect(false, H003_auto553_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 140), 1, 100, "S150_shifa")
	end,

	hfggk = function( effectScript )
			PlaySound("skill_0302")
	end,

	dsfdg = function( effectScript )
		AttachAvatarPosEffect(false, H003_auto553_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 100), 1, 100, "S150_daoguang")
	end,

	rgdfgfh = function( effectScript )
		AttachAvatarPosEffect(false, H003_auto553_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S150_shouj")
	end,

	gffhhkj = function( effectScript )
			DamageEffect(H003_auto553_attack.info_pool[effectScript.ID].Attacker, H003_auto553_attack.info_pool[effectScript.ID].Targeter, H003_auto553_attack.info_pool[effectScript.ID].AttackType, H003_auto553_attack.info_pool[effectScript.ID].AttackDataList, H003_auto553_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	yjuk = function( effectScript )
			DamageEffect(H003_auto553_attack.info_pool[effectScript.ID].Attacker, H003_auto553_attack.info_pool[effectScript.ID].Targeter, H003_auto553_attack.info_pool[effectScript.ID].AttackType, H003_auto553_attack.info_pool[effectScript.ID].AttackDataList, H003_auto553_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
