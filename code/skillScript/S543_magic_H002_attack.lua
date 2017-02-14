S543_magic_H002_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S543_magic_H002_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S543_magic_H002_attack.info_pool[effectScript.ID].Attacker)
        
		S543_magic_H002_attack.info_pool[effectScript.ID] = nil
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
		effectScript:RegisterEvent( 24, "fgg" )
		effectScript:RegisterEvent( 26, "rrr" )
		effectScript:RegisterEvent( 32, "ffd" )
		effectScript:RegisterEvent( 36, "fefsg" )
		effectScript:RegisterEvent( 40, "vdvs" )
		effectScript:RegisterEvent( 45, "cxxvxcv" )
		effectScript:RegisterEvent( 50, "erere" )
	end,

	f = function( effectScript )
		SetAnimation(S543_magic_H002_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_0201")
	end,

	fgg = function( effectScript )
		AttachAvatarPosEffect(false, S543_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(70, 50), 1.2, 100, "S122_daoguang")
		PlaySound("skill_0202")
	end,

	rrr = function( effectScript )
		AttachAvatarPosEffect(false, S543_magic_H002_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.5, 100, "S122_shouji")
	end,

	ffd = function( effectScript )
			DamageEffect(S543_magic_H002_attack.info_pool[effectScript.ID].Attacker, S543_magic_H002_attack.info_pool[effectScript.ID].Targeter, S543_magic_H002_attack.info_pool[effectScript.ID].AttackType, S543_magic_H002_attack.info_pool[effectScript.ID].AttackDataList, S543_magic_H002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fefsg = function( effectScript )
		AttachAvatarPosEffect(false, S543_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 50), 1.5, 100, "S122_shifa")
	end,

	vdvs = function( effectScript )
			DamageEffect(S543_magic_H002_attack.info_pool[effectScript.ID].Attacker, S543_magic_H002_attack.info_pool[effectScript.ID].Targeter, S543_magic_H002_attack.info_pool[effectScript.ID].AttackType, S543_magic_H002_attack.info_pool[effectScript.ID].AttackDataList, S543_magic_H002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	cxxvxcv = function( effectScript )
			DamageEffect(S543_magic_H002_attack.info_pool[effectScript.ID].Attacker, S543_magic_H002_attack.info_pool[effectScript.ID].Targeter, S543_magic_H002_attack.info_pool[effectScript.ID].AttackType, S543_magic_H002_attack.info_pool[effectScript.ID].AttackDataList, S543_magic_H002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	erere = function( effectScript )
			DamageEffect(S543_magic_H002_attack.info_pool[effectScript.ID].Attacker, S543_magic_H002_attack.info_pool[effectScript.ID].Targeter, S543_magic_H002_attack.info_pool[effectScript.ID].AttackType, S543_magic_H002_attack.info_pool[effectScript.ID].AttackDataList, S543_magic_H002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
