S648_magic_M008_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S648_magic_M008_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S648_magic_M008_attack.info_pool[effectScript.ID].Attacker)
        
		S648_magic_M008_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("gs0081")
		PreLoadAvatar("M008_daoguang")
		PreLoadAvatar("M008_shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ads" )
		effectScript:RegisterEvent( 22, "sdfgdgh" )
		effectScript:RegisterEvent( 24, "asfdg" )
		effectScript:RegisterEvent( 28, "dsfdg" )
	end,

	ads = function( effectScript )
		SetAnimation(S648_magic_M008_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("gs0081")
	end,

	sdfgdgh = function( effectScript )
		AttachAvatarPosEffect(false, S648_magic_M008_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, -10), 1.5, 100, "M008_daoguang")
	end,

	asfdg = function( effectScript )
		AttachAvatarPosEffect(false, S648_magic_M008_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(80, 0), 1.8, 100, "M008_shouji")
	end,

	dsfdg = function( effectScript )
			DamageEffect(S648_magic_M008_attack.info_pool[effectScript.ID].Attacker, S648_magic_M008_attack.info_pool[effectScript.ID].Targeter, S648_magic_M008_attack.info_pool[effectScript.ID].AttackType, S648_magic_M008_attack.info_pool[effectScript.ID].AttackDataList, S648_magic_M008_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
