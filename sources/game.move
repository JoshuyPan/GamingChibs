module chibs::game{

    /* HERE IS THE MAIN MODULE */
    //Errors
    #[error]
    const ALREADY_REGISTRED: u64 = 1;
    #[error]
    const SHOULD_BE_REGISTRED_FIRST: u64 = 2;
    #[error]
    const GUILD_NAME_ALREADY_EXIST: u64 = 3;
    #[error]
    const ALREADY_HAVE_A_GUILD: u64 = 4;
    #[error]
    const YOU_ARE_NOT_GUILD_ADMIN: u64 = 5;
    #[error]
    const USER_IS_NOT_GUILD_MEMBER: u64 = 6;
    #[error]
    const YOU_HAVE_NO_GUILD: u64 = 7;
    #[error]
    const EURASIA_IS_CLOSED: u64 = 8;


    public struct GameAdmin has key {
        id: UID,
        founder: address,
        chibs: sui::vec_map::VecMap<address, chibs::chib::Chib>,
        guildsCreated: u64,
        guilds: sui::vec_map::VecMap<u64, chibs::guild::Guild>,
        balance: sui::balance::Balance<sui::sui::SUI>,
        eurasia: chibs::map::Map,
        fee: u64
    }

    fun init(ctx: &mut TxContext) 
    {
        let eurasia = chibs::map::instantiate_map(ctx);

        let admin = GameAdmin{
            id: object::new(ctx),
            founder: tx_context::sender(ctx),
            chibs: sui::vec_map::empty<address, chibs::chib::Chib>(),
            guildsCreated: 0,
            guilds: sui::vec_map::empty<u64, chibs::guild::Guild>(),
            balance: sui::balance::zero<sui::sui::SUI>(),
            eurasia: eurasia,
            fee: 2
        };

        transfer::share_object(admin);
    }
    
    public entry fun register
    (
        admin: &mut GameAdmin,
        name: std::ascii::String,
        ctx: &mut TxContext
    ){
        let sender = tx_context::sender(ctx);
        let isRegistred = admin.chibs.contains(&sender);
        assert!(isRegistred == false, ALREADY_REGISTRED);

        let newChib = chibs::chib::create_chib(name, ctx);

        admin.chibs.insert(sender, newChib);

        //TODO: Add the creation event
    }

    public entry fun register_guild
    (
        admin: &mut GameAdmin,
        name: std::ascii::String,
        ctx: &mut TxContext
    )
    {
        let sender = tx_context::sender(ctx);
        //Check if the sender is registred
        is_registred(admin, ctx);

        //Check if the user already have a guild
        let chib = admin.chibs.get_mut(&sender);
        assert!(!chib.get_have_guild(), ALREADY_HAVE_A_GUILD);

        //Check if the guild name is already taken
        let mut iterator = 1;
        while(iterator <= admin.guildsCreated){
            let guilds = admin.guilds.get(&iterator);
            if(guilds.get_guild_name() == name){
                abort(GUILD_NAME_ALREADY_EXIST)
            }else{
                iterator = iterator + 1;
            }
        };

        // Update guild created, creates the new guild, push the guild to the vecmap, sends the adminCap and membership to the sender
        admin.guildsCreated = admin.guildsCreated + 1;
        let guild = chibs::guild::create_guild(admin.guildsCreated, name, ctx);

        chib.set_guild_name(name);
        chib.set_guild_id(admin.guildsCreated);

        admin.guilds.insert(admin.guildsCreated, guild);
    }

    public entry fun transfer_guild_ownership
    (
        admin: &mut GameAdmin,
        newGuildAdmin: address,
        ctx: &mut TxContext
    ){
        //check if the sender is the admin of the guild
        let sender = tx_context::sender(ctx);
        let chibAdmin = admin.chibs.get(&sender);
        let guild = admin.guilds.get_mut(&chibAdmin.get_guild_id());
        let guildAdmin = guild.get_guild_admin();
        assert!(sender == guildAdmin, YOU_ARE_NOT_GUILD_ADMIN);

        //check address given is member of the guild
        let isMember = guild.get_address_is_member(newGuildAdmin);
        assert!(isMember, USER_IS_NOT_GUILD_MEMBER);

        guild.set_new_owner(newGuildAdmin, ctx);
    }

    public entry fun add_guild_member
    (
        admin: &mut GameAdmin,
        guy: address,
        ctx: &mut TxContext
    ){
        let sender = tx_context::sender(ctx);
        let senderChib = admin.chibs.get_mut(&sender);
        assert!(senderChib.get_have_guild(), USER_IS_NOT_GUILD_MEMBER);
        let guild = admin.guilds.get_mut(&senderChib.get_guild_id());
        let newMember = admin.chibs.get_mut(&guy);
        assert!(!newMember.get_have_guild(), ALREADY_HAVE_A_GUILD);

        guild.add_new_member(guy, ctx);
        newMember.set_guild_id(guild.get_guild_id());
        newMember.set_guild_name(guild.get_guild_name());
    }

    public entry fun figth_eurasia
    (
        admin: &mut GameAdmin,
        chib: &mut chibs::chib::Chib,
        ctx: &mut TxContext
    ){
        let isGuilded = chib.get_have_guild();
        assert!(isGuilded, YOU_HAVE_NO_GUILD);
        let mut iterator = 0;

        while(iterator < 2){
            let dude = admin.eurasia.get_dude(iterator);
            let success = figth(chib, dude);
            if(success){
                iterator = iterator + 1
            }else{
                chib.check_state();
                return
            }
        }
    }

    //Getters
    public fun get_founder(admin: &GameAdmin): address{
        admin.founder
    }

    public fun get_chib(admin: &mut GameAdmin, key: &address): &mut chibs::chib::Chib {
        admin.chibs.get_mut(key)
    }

    public fun get_guilds_created(admin: &GameAdmin): u64{
        admin.guildsCreated
    }

    public fun get_fee(admin: &GameAdmin): u64 {
        admin.fee
    }

    //Private
    fun is_registred(admin: &GameAdmin, ctx: &mut TxContext){
        let sender = tx_context::sender(ctx);
        let isRegistred = admin.chibs.contains(&sender);
        assert!(isRegistred == true, SHOULD_BE_REGISTRED_FIRST);
    }

    fun remove_and_destroy_dude(admin: &mut GameAdmin, dudeIndex: u64){
        admin.eurasia.destroy_bad_dude(dudeIndex);
    }

    //Fighting
    ///@dev -> this function returns true if chib won. Otherwise returns false
    fun figth(chib: &mut chibs::chib::Chib, dude: &mut chibs::bad_dudes::BadDude): bool{
        let chibHp = chib.get_hp();
        let chibAtk = chib.get_attack();
        let dudeHp = dude.get_hp();
        let dudeAtk = dude.get_atk();

        while(dude.get_hp() > 0){
            dude.lose_hp(chibAtk);
            chib.lose_hp(dudeAtk);
            if(chib.get_hp() <= 0){
                chib.check_state();
                return false
            }
        };
        chib.give_exp(chibHp + dudeAtk);
        chib.add_victory();
        chib.check_state();
        chib.check_level();
        return true    
    }

}