S410_magic_H019_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S410_magic_H019_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S410_magic_H019_attack.info_pool[effectScript.ID].Attacker)
        
		S410_magic_H019_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01902")
		PreLoadSound("stalk_01901")
		PreLoadSound("skill_01903")
		PreLoadAvatar("S412_1")
		PreLoadSound("skill_01903")
		PreLoadSound("skill_01904")
		PreLoadAvatar("S412_2")
		PreLoadSound("skill_01903")
		PreLoadSound("skill_01904")
		PreLoadSound("skill_01904")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdgh" )
		effectScript:RegisterEvent( 5, "sdfdh" )
		effectScript:RegisterEvent( 16, "sdg" )
		effectScript:RegisterEvent( 17, "gfdhsgfjh" )
		effectScript:RegisterEvent( 20, "sdgdh" )
		effectScript:RegisterEvent( 21, "dsgfdh" )
		effectScript:RegisterEvent( 24, "sfdggfh" )
		effectScript:RegisterEvent( 25, "dsfdsh" )
		effectScript:RegisterEvent( 26, "dsgdh" )
		effectScript:RegisterEvent( 28, "fdgfh" )
		effectScript:RegisterEvent( 30, "fdgfjh" )
		effectScript:RegisterEvent( 32, "sdgfdh" )
	end,

	dsfdgh = function( effectScript )
		SetAnimation(S410_magic_H019_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	sdfdh = function( effectScript )
			PlaySound("skill_01902")
		PlaySound("stalk_01901")
	end,

	sdg = function( effectScript )
			PlaySound("skill_01903")
	end,

	gfdhsgfjh = function( effectScript )
		AttachAvatarPosEffect(false, S410_magic_H019_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 0), 1, 100, "S412_1")
	end,

	sdgdh = function( effectScript )
			PlaySound("skill_01903")
	end,

	dsgfdh = function( effectScript )
			PlaySound("skill_01904")
	end,

	sfdggfh = function( effectScript )
		AttachAvatarPosEffect(false, S410_magic_H019_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S412_2")
	end,

	dsfdsh = function( effectScript )
			PlaySound("skill_01903")
	end,

	dsgdh = function( effectScript )
			PlaySound("skill_01904")
	end,

	fdgfh = function( effectScript )
			DamageEffect(S410_magic_H019_attack.info_pool[effectScript.ID].Attacker, S410_magic_H019_attack.info_pool[effectScript.ID].Targeter, S410_magic_H019_attack.info_pool[effectScript.ID].AttackType, S410_magic_H019_attack.info_pool[effectScript.ID].AttackDataList, S410_magic_H019_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fdgfjh = function( effectScript )
			PlaySound("skill_01904")
	end,

	sdgfdh = function( effectScript )
			DamageEffect(S410_magic_H019_attack.info_pool[effectScript.ID].Attacker, S410_magic_H019_attack.info_pool[effectScript.ID].Targeter, S410_magic_H019_attack.info_pool[effectScript.ID].AttackType, S410_magic_H019_attack.info_pool[effectScript.ID].AttackDataList, S410_magic_H019_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
