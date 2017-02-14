S732_magic_H038_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S732_magic_H038_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S732_magic_H038_attack.info_pool[effectScript.ID].Attacker)
        
		S732_magic_H038_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S732_1")
		PreLoadSound("skill_03804")
		PreLoadAvatar("S732_2")
		PreLoadSound("atalk_03802")
		PreLoadAvatar("S732_3")
		PreLoadSound("skill_03803")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgfhjj" )
		effectScript:RegisterEvent( 9, "fdgfh" )
		effectScript:RegisterEvent( 24, "fdgfhjjj" )
		effectScript:RegisterEvent( 30, "vfgfhhgjk" )
		effectScript:RegisterEvent( 31, "fdgfjhj" )
	end,

	dfgfhjj = function( effectScript )
		SetAnimation(S732_magic_H038_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S732_magic_H038_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(70, 175), 1, 100, "S732_1")
		PlaySound("skill_03804")
	end,

	fdgfhjjj = function( effectScript )
		AttachAvatarPosEffect(false, S732_magic_H038_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(75, 100), 1, 100, "S732_2")
		PlaySound("atalk_03802")
	end,

	vfgfhhgjk = function( effectScript )
		AttachAvatarPosEffect(false, S732_magic_H038_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S732_3")
		PlaySound("skill_03803")
	end,

	fdgfjhj = function( effectScript )
			DamageEffect(S732_magic_H038_attack.info_pool[effectScript.ID].Attacker, S732_magic_H038_attack.info_pool[effectScript.ID].Targeter, S732_magic_H038_attack.info_pool[effectScript.ID].AttackType, S732_magic_H038_attack.info_pool[effectScript.ID].AttackDataList, S732_magic_H038_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
