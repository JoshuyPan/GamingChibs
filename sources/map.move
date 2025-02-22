module chibs::map{

    /* HERE IS THE MAP STUFFS */

    public struct Map has key, store{
        id: UID,
        name: std::ascii::String,
        owner: std::ascii::String,
        b_dudes: vector<chibs::bad_dudes::BadDude>,
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
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2],
            isOpen: true,
            balance: sui::balance::zero()
        }
    }

    //getters
    public fun get_name(map: &Map): std::ascii::String{
        map.name
    }

    public fun have_owner(map: &Map): bool{
        map.owner != b"None".to_ascii_string()
    }

    public fun get_owner(map: &Map): std::ascii::String{
        map.owner
    }

    public fun get_dudes_count(map: &Map): u64{
        map.b_dudes.length()
    }

    public fun get_dude(map: &mut Map, index: u64): chibs::bad_dudes::BadDude{
        map.b_dudes.remove(index)
    }

    public fun get_map_is_open(map: &Map): bool{
        map.isOpen
    }

    //Setters
    public fun set_owner(map: &mut Map, guildName: std::ascii::String){
        map.owner = guildName
    }

    public fun destroy_bad_dude(map: &mut Map, dudeIndex: u64){
        let dude = map.b_dudes.remove(dudeIndex);
        dude.destroy_bad_dude()
    }

}