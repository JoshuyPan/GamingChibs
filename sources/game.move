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
        guildsCreated: u64,
        chibsCreated: u64,
        bannedAddresses: vector<address>,
        guilds: sui::table::Table<address, chibs::guild::Guild>,
        chibs: sui::table::Table<address, chibs::chib::Chib>,
        eurasia: chibs::map::Map,
        balance: sui::balance::Balance<sui::sui::SUI>,
        fee: u64
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
    public entry fun register(admin: &mut GameAdmin, ctx: &mut TxContext){
        check_is_not_registred(admin, ctx);
    }
    
    //Private
    fun check_is_not_registred(admin: &mut GameAdmin, ctx: &mut TxContext){
        let sender = tx_context::sender(ctx);
        let isRegistred = admin.chibs.contains(sender);
        assert!(!isRegistred, ALREADY_REGISTRED);
    }
}