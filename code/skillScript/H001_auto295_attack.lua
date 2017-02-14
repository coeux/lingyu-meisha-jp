H001_auto295_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H001_auto295_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H001_auto295_attack.info_pool[effectScript.ID].Attacker)
        
		H001_auto295_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0101")
		PreLoadSound("skill_0101")
		PreLoadAvatar("S290_1")
		PreLoadAvatar("S290_2")
		PreLoadSound("skill_0101")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ddgfh" )
		effectScript:RegisterEvent( 3, "sdgdh" )
		effectScript:RegisterEvent( 7, "dsfdghh" )
		effectScript:RegisterEvent( 22, "sdgdhfdg" )
		effectScript:RegisterEvent( 32, "dgfjh" )
	end,

	ddgfh = function( effectScript )
		SetAnimation(H001_auto295_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_0101")
	end,

	sdgdh = function( effectScript )
			PlaySound("skill_0101")
	end,

	dsfdghh = function( effectScript )
		AttachAvatarPosEffect(false, H001_auto295_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S290_1")
	AttachAvatarPosEffect(false, H001_auto295_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, -100, "S290_2")
	end,

	sdgdhfdg = function( effectScript )
			PlaySound("skill_0101")
	end,

	dgfjh = function( effectScript )
			DamageEffect(H001_auto295_attack.info_pool[effectScript.ID].Attacker, H001_auto295_attack.info_pool[effectScript.ID].Targeter, H001_auto295_attack.info_pool[effectScript.ID].AttackType, H001_auto295_attack.info_pool[effectScript.ID].AttackDataList, H001_auto295_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
