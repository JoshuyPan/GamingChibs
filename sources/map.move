module chibs::map{

    /* HERE IS THE MAP STUFFS */

    public struct Map has key, store{
        id: UID,
        name: std::ascii::String,
        owner: option::Option<chibs::guild::Guild>,
        tiles: vector<chibs::bad_dudes::BadDude>,
        isOpen: bool,
        balance: sui::balance::Balance<sui::sui::SUI>
    }

    public fun instantiate_map(
        ctx: &mut TxContext
    ): Map
    {
        let dude1 = chibs::bad_dudes::create_bad_dude(b"Ciccio1".to_ascii_string(), 100, 10, ctx);
        let dude2 = chibs::bad_dudes::create_bad_dude(b"Ciccio2".to_ascii_string(), 200, 20, ctx);

        Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: option::none<chibs::guild::Guild>(),
            tiles: vector[dude1, dude2],
            isOpen: true,
            balance: sui::balance::zero()
        }
    }

    
}