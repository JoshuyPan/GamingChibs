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
    
    public entry fun register(
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

    public entry fun register_guild(
        admin: &mut GameAdmin,
        name: std::ascii::String,
        ctx: &mut TxContext
    )
    {
        //Check if the user is registred
        let sender = tx_context::sender(ctx);
        let isRegistred = admin.chibs.contains(&sender);
        assert!(isRegistred == true, SHOULD_BE_REGISTRED_FIRST);

        //Check if the user if the user already have a guild
        let chib = admin.chibs.get_mut(&sender);
        assert!(!chib.get_guild_is_member(), ALREADY_HAVE_A_GUILD);

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
        let (guild, guildAdmin, guildMember) = chibs::guild::create_guild(admin.guildsCreated, name, ctx);

        chib.set_guild_name(name);

        admin.guilds.insert(admin.guildsCreated, guild);
        chib.add_guild_emblem(guildMember);
        chib.add_guild_admin_emblem(guildAdmin);
    }

    public entry fun transfer_guild_ownership(
        admin: &mut GameAdmin,
        newGuildAdmin: address,
        ctx: &mut TxContext
    ){
        //check if the sender is the admin of the guild
        let sender = tx_context::sender(ctx);
        let chibAdmin = admin.chibs.get_mut(&sender);
        let chibNewAdmin = admin.chibs.get_mut(&newGuildAdmin);
        let isAdmin = chibAdmin.get_guild_is_admin();
        assert!(isAdmin, YOU_ARE_NOT_GUILD_ADMIN);

        let emblem = chibAdmin.remove_guild_admin_emblem();
        
        //check if the new admin is a member of the guild
        let guild = admin.guilds.get_mut(&emblem.get_guild_id());
        let isMember = guild.get_address_is_member(&newGuildAdmin);
        assert!(isMember, USER_IS_NOT_GUILD_MEMBER);

        guild.set_new_owner(newGuildAdmin);
        chibNewAdmin.add_guild_admin_emblem(emblem);
    }

}