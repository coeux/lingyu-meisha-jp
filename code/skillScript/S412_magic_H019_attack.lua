S412_magic_H019_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S412_magic_H019_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S412_magic_H019_attack.info_pool[effectScript.ID].Attacker)
        
		S412_magic_H019_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01902")
		PreLoadSound("stalk_01901")
		PreLoadAvatar("H019_xuli")
		PreLoadSound("skill_01901")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgfhgfh" )
		effectScript:RegisterEvent( 9, "fdsgh" )
		effectScript:RegisterEvent( 14, "dsgfhjj" )
		effectScript:RegisterEvent( 24, "fdsghfdh" )
		effectScript:RegisterEvent( 40, "fdgh" )
	end,

	dfgfhgfh = function( effectScript )
		SetAnimation(S412_magic_H019_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	fdsgh = function( effectScript )
			PlaySound("skill_01902")
		PlaySound("stalk_01901")
	end,

	dsgfhjj = function( effectScript )
		AttachAvatarPosEffect(false, S412_magic_H019_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 50), 0.8, 100, "H019_xuli")
	end,

	fdsghfdh = function( effectScript )
			PlaySound("skill_01901")
	end,

	fdgh = function( effectScript )
			DamageEffect(S412_magic_H019_attack.info_pool[effectScript.ID].Attacker, S412_magic_H019_attack.info_pool[effectScript.ID].Targeter, S412_magic_H019_attack.info_pool[effectScript.ID].AttackType, S412_magic_H019_attack.info_pool[effectScript.ID].AttackDataList, S412_magic_H019_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
