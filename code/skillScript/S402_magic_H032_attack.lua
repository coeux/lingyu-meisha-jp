S402_magic_H032_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S402_magic_H032_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S402_magic_H032_attack.info_pool[effectScript.ID].Attacker)
        
		S402_magic_H032_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_03201")
		PreLoadSound("stalk_03201")
		PreLoadAvatar("S442_1")
		PreLoadSound("skill_03204")
		PreLoadAvatar("S442_9")
		PreLoadAvatar("H032_jineng")
		PreLoadSound("skill_03203")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdg" )
		effectScript:RegisterEvent( 45, "dsgdh" )
		effectScript:RegisterEvent( 50, "fdgfh" )
		effectScript:RegisterEvent( 66, "dgh" )
		effectScript:RegisterEvent( 69, "fghj" )
		effectScript:RegisterEvent( 71, "dgfh" )
	end,

	fdg = function( effectScript )
		SetAnimation(S402_magic_H032_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_03201")
		PlaySound("stalk_03201")
	end,

	dsgdh = function( effectScript )
		SetAnimation(S402_magic_H032_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_H032_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 165), 0.7, -100, "S442_1")
		PlaySound("skill_03204")
	end,

	dgh = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_H032_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 100), 1.8, 100, "S442_9")
	end,

	fghj = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_H032_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "H032_jineng")
		PlaySound("skill_03203")
	end,

	dgfh = function( effectScript )
			DamageEffect(S402_magic_H032_attack.info_pool[effectScript.ID].Attacker, S402_magic_H032_attack.info_pool[effectScript.ID].Targeter, S402_magic_H032_attack.info_pool[effectScript.ID].AttackType, S402_magic_H032_attack.info_pool[effectScript.ID].AttackDataList, S402_magic_H032_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
