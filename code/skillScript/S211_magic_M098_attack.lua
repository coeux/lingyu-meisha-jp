S211_magic_M098_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S211_magic_M098_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S211_magic_M098_attack.info_pool[effectScript.ID].Attacker)
		S211_magic_M098_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("caijuezhiren")
		PreLoadAvatar("S211")
		PreLoadAvatar("M098_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 12, "df" )
		effectScript:RegisterEvent( 15, "f" )
		effectScript:RegisterEvent( 26, "g" )
		effectScript:RegisterEvent( 29, "c" )
		effectScript:RegisterEvent( 33, "ad" )
	end,

	a = function( effectScript )
		SetAnimation(S211_magic_M098_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("caijuezhiren")
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, S211_magic_M098_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1, 100, "S211")
	end,

	g = function( effectScript )
			DamageEffect(S211_magic_M098_attack.info_pool[effectScript.ID].Attacker, S211_magic_M098_attack.info_pool[effectScript.ID].Targeter, S211_magic_M098_attack.info_pool[effectScript.ID].AttackType, S211_magic_M098_attack.info_pool[effectScript.ID].AttackDataList, S211_magic_M098_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S211_magic_M098_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "M098_1")
	end,

	ad = function( effectScript )
		CameraShake()
	end,

}
