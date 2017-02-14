--petModule.lua
--========================================================================
--宠物模块

PetModule =
	{
		have_pet = false,
		petid = 0,
		resid = 27001,
		atk = 0,
		mgc = 0,
		def = 0,
		res = 0,
		hp = 0,
	};

function PetModule:Init(data, have_pet)
	self.have_pet = have_pet;
	if self.have_pet then
		self.petid = data.petid;
		self.resid = data.resid;
		self.atk = data.atk;
		self.mgc = data.mgc;
		self.def = data.def;
		self.res = data.res;
		self.hp = data.hp;
	end
end

function PetModule:HavePet()
	return self.have_pet;
end

function PetModule:getAttribute()
	return self.atk, self.mgc, self.def, self.res, self.hp;
end

function PetModule:getPetFp()
	return math.floor(self.atk * 1.1 + self.mgc * 1 + self.def * 1.2 + self.res * 1 + self.hp * 0.3);
end

function PetModule:onComposeCallback(msg)
	self.resid = msg.resid;
	self.atk = msg.atk;
	self.mgc = msg.mgc;
	self.def = msg.def;
	self.res = msg.res;
	self.hp = msg.hp;
	
	ActorManager.hero.petid = self.resid;
	ActorManager.hero:AttachPet(self.resid);
	PetPanel:composeCallback();
end
	
function PetModule:AddPet(pet_data)
	if self.have_pet then
		return;
	end
	self.have_pet = true;
	self.resid = pet_data.resid;
	self.petid = pet_data.petid;
	self.atk = pet_data.atk;
	self.mgc = pet_data.mgc;
	self.def = pet_data.def;
	self.res = pet_data.res;
	self.hp = pet_data.hp;
	ActorManager.hero.have_pet = true;
	ActorManager.hero.petid = self.resid;
	ActorManager.hero:AttachPet(self.resid);
end
