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
    #[error]
    const NOT_SAME_GUILD: u64 = 9;

    /// This struct is responsable of all the functionality of the game,
    public struct GameAdmin has key {
        id: UID,
        founder: address,
        guildsCreated: u64,
        chibsCreated: u64,
        bannedAddresses: vector<address>,
        guilds: sui::table::Table<u64, chibs::guild::Guild>,
        chibs: sui::table::Table<address, chibs::chib::Chib>,
        eurasia: chibs::map::Map,
        balance: sui::balance::Balance<sui::sui::SUI>,
        fee: u64
    }

    // Events
    public struct ChibCreated has copy, drop{
        registred_address: address,
        chib_name: std::ascii::String,
    }

    fun init(ctx: &mut TxContext) 
    {
        let sender = tx_context::sender(ctx);
        let map = chibs::map::instantiate_map(ctx);

        let admin = GameAdmin{
            id: object::new(ctx),
            founder: sender,
            guildsCreated: 0,
            chibsCreated: 0,
            bannedAddresses: vector[],
            guilds: sui::table::new(ctx),
            chibs: sui::table::new(ctx),
            eurasia: map,
            balance: sui::balance::zero<sui::sui::SUI>(),
            fee: 2
        };

        transfer::share_object(admin);
    }

    //Entry

    /// This function is used to register a new Chib and store his mut reference inside the 
    /// GameAdmin shared obj
    public entry fun register(admin: &mut GameAdmin, name: std::ascii::String, ctx: &mut TxContext){
        // the caller of the function, should not be registered yet
        let sender = tx_context::sender(ctx);
        check_is_not_registred(admin, sender);
        let chib = chibs::chib::create_chib(name, ctx);
        admin.chibs.add(sender, chib);
        admin.chibsCreated = admin.chibsCreated + 1;

        let chibEvent = ChibCreated{
            registred_address: sender,
            chib_name: name
        };
        sui::event::emit(chibEvent);
    }

    //This function is used to register a new Guild
    public entry fun register_guild(admin: &mut GameAdmin, name: std::ascii::String, ctx: &mut TxContext){
        //check if: sender is registred, have no guild and the guildname is not taken
        let sender = tx_context::sender(ctx);
        check_is_registred(admin, sender);
        check_guild_name_is_not_taken(admin, name);
        check_address_have_not_guild(admin, sender);

        admin.guildsCreated = admin.guildsCreated + 1;
        let chib = admin.chibs.borrow_mut(sender);
        let guild = chibs::guild::create_guild(admin.guildsCreated, name, ctx);
        admin.guilds.add(admin.guildsCreated, guild);
        chib.set_guild_id(admin.guildsCreated);
        chib.set_guild_name(name);
    }

    //This function is used to add a member to the guild
    public entry fun add_member(admin: &mut GameAdmin, newMember: address, ctx: &mut TxContext){
        let sender = tx_context::sender(ctx);
        check_address_have_guild(admin, sender);
        check_address_have_not_guild(admin, newMember);
        //this is because we can't assign multiple borrow_mut
        let (guildId, guildName) = {
            let senderChib = admin.chibs.borrow_mut(sender);
            (senderChib.get_guild_id(), senderChib.get_guild_name()) 
        };
        admin.chibs.borrow_mut(newMember).set_guild_id(guildId);
        admin.chibs.borrow_mut(newMember).set_guild_name(guildName);
        admin.guilds.borrow_mut(guildId).add_new_member(newMember, ctx);
    }

    //This function is used to transfer the ownership between the guild members
    public entry fun transfer_guild_ownership(admin: &mut GameAdmin, newOwner: address, ctx: &mut TxContext){
        let sender = tx_context::sender(ctx);
        check_address_have_guild(admin, sender);
        let chib = admin.chibs.borrow(sender);
        let guildId = chib.get_guild_id();
        let guild = admin.guilds.borrow_mut(guildId);
        assert!(guildId == admin.chibs.borrow(newOwner).get_guild_id(), NOT_SAME_GUILD);
        assert!(guild.get_guild_admin() == sender, YOU_ARE_NOT_GUILD_ADMIN);
        guild.set_new_owner(newOwner, ctx);
    }
    // To-do
    /// remove member function
    /// combat system
    
    //Private utility
    fun check_is_not_registred(admin: &GameAdmin, sender: address){
        let isRegistred = admin.chibs.contains(sender);
        assert!(!isRegistred, ALREADY_REGISTRED);
    }

    fun check_is_registred(admin: &GameAdmin, sender: address){
        let isRegistred = admin.chibs.contains(sender);
        assert!(isRegistred, SHOULD_BE_REGISTRED_FIRST);
    }

    fun check_guild_name_is_not_taken(admin: &GameAdmin, name: std::ascii::String){
        let mut i = 1;
        while(i <= admin.guildsCreated){
            assert!(name != admin.guilds.borrow(i).get_guild_name(), GUILD_NAME_ALREADY_EXIST);
            i = i + 1;        
        }
    }
    
    fun check_address_have_guild(admin: &GameAdmin, sender: address){
        let chib = admin.chibs.borrow(sender);
        let haveGuild = chib.get_have_guild();
        assert!(haveGuild, USER_IS_NOT_GUILD_MEMBER);
    }

    fun check_address_have_not_guild(admin: &GameAdmin, sender: address){
        let chib = admin.chibs.borrow(sender);
        let haveGuild = chib.get_have_guild();
        assert!(!haveGuild, ALREADY_HAVE_A_GUILD);
    }
}