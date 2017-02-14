H012_auto356_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H012_auto356_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H012_auto356_attack.info_pool[effectScript.ID].Attacker)
        
		H012_auto356_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01201")
		PreLoadSound("stalk_01201")
		PreLoadSound("skill_01204")
		PreLoadSound("skill_01205")
		PreLoadSound("skill_01204")
		PreLoadAvatar("S350_1")
		PreLoadSound("skill_01205")
		PreLoadAvatar("S350_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdgfhj" )
		effectScript:RegisterEvent( 4, "dfgfjh" )
		effectScript:RegisterEvent( 23, "fdgjhj" )
		effectScript:RegisterEvent( 26, "sfdhfgh" )
		effectScript:RegisterEvent( 28, "dgdh" )
		effectScript:RegisterEvent( 30, "sfdh" )
		effectScript:RegisterEvent( 32, "sfdhfgj" )
		effectScript:RegisterEvent( 35, "sdgdfh" )
		effectScript:RegisterEvent( 36, "sdgdfhghk" )
		effectScript:RegisterEvent( 37, "fdgfhj" )
	end,

	sfdgfhj = function( effectScript )
		SetAnimation(H012_auto356_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dfgfjh = function( effectScript )
			PlaySound("skill_01201")
		PlaySound("stalk_01201")
	end,

	fdgjhj = function( effectScript )
			PlaySound("skill_01204")
	end,

	sfdhfgh = function( effectScript )
			PlaySound("skill_01205")
	end,

	dgdh = function( effectScript )
			PlaySound("skill_01204")
	end,

	sfdh = function( effectScript )
		AttachAvatarPosEffect(false, H012_auto356_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S350_1")
	end,

	sfdhfgj = function( effectScript )
			PlaySound("skill_01205")
	end,

	sdgdfh = function( effectScript )
		AttachAvatarPosEffect(false, H012_auto356_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S350_2")
	end,

	sdgdfhghk = function( effectScript )
		end,

	fdgfhj = function( effectScript )
			DamageEffect(H012_auto356_attack.info_pool[effectScript.ID].Attacker, H012_auto356_attack.info_pool[effectScript.ID].Targeter, H012_auto356_attack.info_pool[effectScript.ID].AttackType, H012_auto356_attack.info_pool[effectScript.ID].AttackDataList, H012_auto356_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
