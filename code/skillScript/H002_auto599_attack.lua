H002_auto599_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H002_auto599_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H002_auto599_attack.info_pool[effectScript.ID].Attacker)
        
		H002_auto599_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_0201")
		PreLoadAvatar("S120_shifa")
		PreLoadSound("stalk_0201")
		PreLoadAvatar("S120_shifang")
		PreLoadAvatar("S120_shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfsf" )
		effectScript:RegisterEvent( 11, "ad" )
		effectScript:RegisterEvent( 18, "adffd" )
		effectScript:RegisterEvent( 21, "adf" )
		effectScript:RegisterEvent( 22, "safsfd" )
	end,

	sfsf = function( effectScript )
		SetAnimation(H002_auto599_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_0201")
	end,

	ad = function( effectScript )
		AttachAvatarPosEffect(false, H002_auto599_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 90), 1.2, -100, "S120_shifa")
		PlaySound("stalk_0201")
	end,

	adffd = function( effectScript )
		AttachAvatarPosEffect(false, H002_auto599_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(110, 0), 1.2, -100, "S120_shifang")
	end,

	adf = function( effectScript )
		AttachAvatarPosEffect(false, H002_auto599_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 2.5, 100, "S120_shouji")
	end,

	safsfd = function( effectScript )
			DamageEffect(H002_auto599_attack.info_pool[effectScript.ID].Attacker, H002_auto599_attack.info_pool[effectScript.ID].Targeter, H002_auto599_attack.info_pool[effectScript.ID].AttackType, H002_auto599_attack.info_pool[effectScript.ID].AttackDataList, H002_auto599_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
