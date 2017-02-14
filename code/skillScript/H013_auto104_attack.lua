H013_auto104_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H013_auto104_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H013_auto104_attack.info_pool[effectScript.ID].Attacker)
        
		H013_auto104_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01301")
		PreLoadSound("skill_01301")
		PreLoadAvatar("S102_1")
		PreLoadAvatar("S102_2")
		PreLoadAvatar("S102_3")
		PreLoadSound("skill_01302")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 26, "fdg" )
		effectScript:RegisterEvent( 28, "d" )
		effectScript:RegisterEvent( 29, "ads" )
		effectScript:RegisterEvent( 31, "saf" )
		effectScript:RegisterEvent( 33, "dsgfdsh" )
		effectScript:RegisterEvent( 34, "e" )
		effectScript:RegisterEvent( 39, "dsf" )
		effectScript:RegisterEvent( 43, "dgh" )
	end,

	aa = function( effectScript )
		SetAnimation(H013_auto104_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_01301")
	end,

	fdg = function( effectScript )
			PlaySound("skill_01301")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, H013_auto104_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(180, 0), 1.8, 100, "S102_1")
	end,

	ads = function( effectScript )
		AttachAvatarPosEffect(false, H013_auto104_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(180, 0), 1.5, -100, "S102_2")
	end,

	saf = function( effectScript )
		AttachAvatarPosEffect(false, H013_auto104_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-20, 0), 2, 100, "S102_3")
	end,

	dsgfdsh = function( effectScript )
			PlaySound("skill_01302")
	end,

	e = function( effectScript )
			DamageEffect(H013_auto104_attack.info_pool[effectScript.ID].Attacker, H013_auto104_attack.info_pool[effectScript.ID].Targeter, H013_auto104_attack.info_pool[effectScript.ID].AttackType, H013_auto104_attack.info_pool[effectScript.ID].AttackDataList, H013_auto104_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsf = function( effectScript )
			DamageEffect(H013_auto104_attack.info_pool[effectScript.ID].Attacker, H013_auto104_attack.info_pool[effectScript.ID].Targeter, H013_auto104_attack.info_pool[effectScript.ID].AttackType, H013_auto104_attack.info_pool[effectScript.ID].AttackDataList, H013_auto104_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dgh = function( effectScript )
			DamageEffect(H013_auto104_attack.info_pool[effectScript.ID].Attacker, H013_auto104_attack.info_pool[effectScript.ID].Targeter, H013_auto104_attack.info_pool[effectScript.ID].AttackType, H013_auto104_attack.info_pool[effectScript.ID].AttackDataList, H013_auto104_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
