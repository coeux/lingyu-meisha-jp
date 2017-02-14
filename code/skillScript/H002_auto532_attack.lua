H002_auto532_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H002_auto532_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H002_auto532_attack.info_pool[effectScript.ID].Attacker)
        
		H002_auto532_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0201")
		PreLoadAvatar("S122_daoguang")
		PreLoadSound("skill_0202")
		PreLoadAvatar("S122_shouji")
		PreLoadAvatar("S122_shifa")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "f" )
		effectScript:RegisterEvent( 20, "fgg" )
		effectScript:RegisterEvent( 22, "rrr" )
		effectScript:RegisterEvent( 26, "ffd" )
		effectScript:RegisterEvent( 29, "vdvs" )
		effectScript:RegisterEvent( 34, "fefsg" )
		effectScript:RegisterEvent( 38, "cxxvxcv" )
		effectScript:RegisterEvent( 40, "erere" )
	end,

	f = function( effectScript )
		SetAnimation(H002_auto532_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_0201")
	end,

	fgg = function( effectScript )
		AttachAvatarPosEffect(false, H002_auto532_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(110, 80), 1.5, 100, "S122_daoguang")
		PlaySound("skill_0202")
	end,

	rrr = function( effectScript )
		AttachAvatarPosEffect(false, H002_auto532_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.5, 100, "S122_shouji")
	end,

	ffd = function( effectScript )
			DamageEffect(H002_auto532_attack.info_pool[effectScript.ID].Attacker, H002_auto532_attack.info_pool[effectScript.ID].Targeter, H002_auto532_attack.info_pool[effectScript.ID].AttackType, H002_auto532_attack.info_pool[effectScript.ID].AttackDataList, H002_auto532_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	vdvs = function( effectScript )
			DamageEffect(H002_auto532_attack.info_pool[effectScript.ID].Attacker, H002_auto532_attack.info_pool[effectScript.ID].Targeter, H002_auto532_attack.info_pool[effectScript.ID].AttackType, H002_auto532_attack.info_pool[effectScript.ID].AttackDataList, H002_auto532_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fefsg = function( effectScript )
		AttachAvatarPosEffect(false, H002_auto532_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 50), 1.5, 100, "S122_shifa")
	end,

	cxxvxcv = function( effectScript )
			DamageEffect(H002_auto532_attack.info_pool[effectScript.ID].Attacker, H002_auto532_attack.info_pool[effectScript.ID].Targeter, H002_auto532_attack.info_pool[effectScript.ID].AttackType, H002_auto532_attack.info_pool[effectScript.ID].AttackDataList, H002_auto532_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	erere = function( effectScript )
			DamageEffect(H002_auto532_attack.info_pool[effectScript.ID].Attacker, H002_auto532_attack.info_pool[effectScript.ID].Targeter, H002_auto532_attack.info_pool[effectScript.ID].AttackType, H002_auto532_attack.info_pool[effectScript.ID].AttackDataList, H002_auto532_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
