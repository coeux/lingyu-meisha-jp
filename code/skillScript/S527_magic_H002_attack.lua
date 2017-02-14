S527_magic_H002_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S527_magic_H002_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S527_magic_H002_attack.info_pool[effectScript.ID].Attacker)
        
		S527_magic_H002_attack.info_pool[effectScript.ID] = nil
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
		effectScript:RegisterEvent( 23, "fgg" )
		effectScript:RegisterEvent( 27, "rrr" )
		effectScript:RegisterEvent( 28, "ffd" )
		effectScript:RegisterEvent( 35, "vdvs" )
		effectScript:RegisterEvent( 38, "fefsg" )
		effectScript:RegisterEvent( 41, "cxxvxcv" )
		effectScript:RegisterEvent( 45, "erere" )
	end,

	f = function( effectScript )
		SetAnimation(S527_magic_H002_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_0201")
	end,

	fgg = function( effectScript )
		AttachAvatarPosEffect(false, S527_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(110, 80), 1.5, 100, "S122_daoguang")
		PlaySound("skill_0202")
	end,

	rrr = function( effectScript )
		AttachAvatarPosEffect(false, S527_magic_H002_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.5, 100, "S122_shouji")
	end,

	ffd = function( effectScript )
			DamageEffect(S527_magic_H002_attack.info_pool[effectScript.ID].Attacker, S527_magic_H002_attack.info_pool[effectScript.ID].Targeter, S527_magic_H002_attack.info_pool[effectScript.ID].AttackType, S527_magic_H002_attack.info_pool[effectScript.ID].AttackDataList, S527_magic_H002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	vdvs = function( effectScript )
			DamageEffect(S527_magic_H002_attack.info_pool[effectScript.ID].Attacker, S527_magic_H002_attack.info_pool[effectScript.ID].Targeter, S527_magic_H002_attack.info_pool[effectScript.ID].AttackType, S527_magic_H002_attack.info_pool[effectScript.ID].AttackDataList, S527_magic_H002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fefsg = function( effectScript )
		AttachAvatarPosEffect(false, S527_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 50), 1.5, 100, "S122_shifa")
	end,

	cxxvxcv = function( effectScript )
			DamageEffect(S527_magic_H002_attack.info_pool[effectScript.ID].Attacker, S527_magic_H002_attack.info_pool[effectScript.ID].Targeter, S527_magic_H002_attack.info_pool[effectScript.ID].AttackType, S527_magic_H002_attack.info_pool[effectScript.ID].AttackDataList, S527_magic_H002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	erere = function( effectScript )
			DamageEffect(S527_magic_H002_attack.info_pool[effectScript.ID].Attacker, S527_magic_H002_attack.info_pool[effectScript.ID].Targeter, S527_magic_H002_attack.info_pool[effectScript.ID].AttackType, S527_magic_H002_attack.info_pool[effectScript.ID].AttackDataList, S527_magic_H002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
