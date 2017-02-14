S403_magic_H032_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S403_magic_H032_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S403_magic_H032_attack.info_pool[effectScript.ID].Attacker)
        
		S403_magic_H032_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_03202")
		PreLoadSound("atalk_03201")
		PreLoadAvatar("S442_1")
		PreLoadSound("skill_03204")
		PreLoadAvatar("S442_9")
		PreLoadAvatar("H032_jineng")
		PreLoadSound("skill_03203")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdg" )
		effectScript:RegisterEvent( 25, "dsgdh" )
		effectScript:RegisterEvent( 30, "fdgfh" )
		effectScript:RegisterEvent( 46, "dgh" )
		effectScript:RegisterEvent( 49, "fghj" )
		effectScript:RegisterEvent( 51, "dsg" )
	end,

	fdg = function( effectScript )
		SetAnimation(S403_magic_H032_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_03202")
		PlaySound("atalk_03201")
	end,

	dsgdh = function( effectScript )
		SetAnimation(S403_magic_H032_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S403_magic_H032_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 165), 0.7, -100, "S442_1")
		PlaySound("skill_03204")
	end,

	dgh = function( effectScript )
		AttachAvatarPosEffect(false, S403_magic_H032_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 100), 1.8, 100, "S442_9")
	end,

	fghj = function( effectScript )
		AttachAvatarPosEffect(false, S403_magic_H032_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "H032_jineng")
		PlaySound("skill_03203")
	end,

	dsg = function( effectScript )
			DamageEffect(S403_magic_H032_attack.info_pool[effectScript.ID].Attacker, S403_magic_H032_attack.info_pool[effectScript.ID].Targeter, S403_magic_H032_attack.info_pool[effectScript.ID].AttackType, S403_magic_H032_attack.info_pool[effectScript.ID].AttackDataList, S403_magic_H032_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
