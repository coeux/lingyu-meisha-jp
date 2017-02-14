S292_magic_H001_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S292_magic_H001_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S292_magic_H001_attack.info_pool[effectScript.ID].Attacker)
        
		S292_magic_H001_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_0101")
		PreLoadSound("skill_0101")
		PreLoadAvatar("S292_1")
		PreLoadSound("skill_0102")
		PreLoadAvatar("S292_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdg" )
		effectScript:RegisterEvent( 9, "gfdhjk" )
		effectScript:RegisterEvent( 10, "fghgjhk" )
		effectScript:RegisterEvent( 24, "dsfdh" )
		effectScript:RegisterEvent( 27, "sfdgh" )
		effectScript:RegisterEvent( 29, "fdghfjh" )
	end,

	dsfdg = function( effectScript )
		SetAnimation(S292_magic_H001_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("atalk_0101")
	end,

	gfdhjk = function( effectScript )
			PlaySound("skill_0101")
	end,

	fghgjhk = function( effectScript )
		AttachAvatarPosEffect(false, S292_magic_H001_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-50, 0), 1, 100, "S292_1")
	end,

	dsfdh = function( effectScript )
			PlaySound("skill_0102")
	end,

	sfdgh = function( effectScript )
		AttachAvatarPosEffect(false, S292_magic_H001_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S292_2")
	end,

	fdghfjh = function( effectScript )
			DamageEffect(S292_magic_H001_attack.info_pool[effectScript.ID].Attacker, S292_magic_H001_attack.info_pool[effectScript.ID].Targeter, S292_magic_H001_attack.info_pool[effectScript.ID].AttackType, S292_magic_H001_attack.info_pool[effectScript.ID].AttackDataList, S292_magic_H001_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
