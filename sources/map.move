module chibs::map{

    /* HERE IS THE MAP STUFFS */

    public struct Map has key, store{
        id: UID,
        name: std::ascii::String,
        owner: std::ascii::String,
        b_dudes: vector<chibs::bad_dudes::BadDude>,
        isOpen: bool,
    }

    public fun instantiate_map(
        level: u64,
        ctx: &mut TxContext
    ): Map
    {
        map_based_on_level(level, ctx)
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

    public fun get_dude(map: &mut Map, index: u64): &mut chibs::bad_dudes::BadDude{
        map.b_dudes.borrow_mut(index)
    }

    public fun remove_dude(map: &mut Map, index: u64): chibs::bad_dudes::BadDude{
        map.b_dudes.remove(index)
    }

    public fun get_map_is_open(map: &mut Map): bool{
        map.isOpen
    }

    //Setters
    public fun set_owner(map: &mut Map, guildName: std::ascii::String){
        map.owner = guildName
    }

    public fun insert_dude(map: &mut Map, dude: chibs::bad_dudes::BadDude){
        map.b_dudes.push_back(dude);
    }

    public fun destroy_bad_dude(map: &mut Map, dudeIndex: u64){
        let dude = map.b_dudes.remove(dudeIndex);
        dude.destroy_bad_dude()
    }

    public fun set_map_is_open(map: &mut Map, state: bool){
        map.isOpen = state;
    }

    //private
    fun map_based_on_level(level: u64, ctx: &mut TxContext): Map{
        if(level == 1){

            let dude1 = chibs::bad_dudes::create_bad_dude(b"DireWolf".to_ascii_string(), 100, 10, 2, ctx);
            let dude2 = chibs::bad_dudes::create_bad_dude(b"DireWolf".to_ascii_string(), 200, 20, 2, ctx);

            Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2],
            isOpen: true,
            }
        }else if(level == 2){

            let dude1 = chibs::bad_dudes::create_bad_dude(b"DireWolf".to_ascii_string(), 100, 10, 2, ctx);
            let dude2 = chibs::bad_dudes::create_bad_dude(b"DireWolf".to_ascii_string(), 200, 20, 2, ctx);
            let dude3 = chibs::bad_dudes::create_bad_dude(b"Orc".to_ascii_string(), 500, 50, 5, ctx);
            
            Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2, dude3],
            isOpen: true,
            }        
        }else{
            
            let dude1 = chibs::bad_dudes::create_bad_dude(b"DireWolf".to_ascii_string(), 100, 10, 2, ctx);
            let dude2 = chibs::bad_dudes::create_bad_dude(b"DireWolf".to_ascii_string(), 200, 20, 2, ctx);
            let dude3 = chibs::bad_dudes::create_bad_dude(b"Orc".to_ascii_string(), 500, 50, 5, ctx);
            let dude4 = chibs::bad_dudes::create_bad_dude(b"Orc".to_ascii_string(), 600, 60, 5, ctx);

            Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2, dude3, dude4],
            isOpen: true,
            }
        }/* else if(level == 4){

            Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2],
            isOpen: true,
            }
        }else if(level == 5){

            Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2],
            isOpen: true,
            }
        }else if(level == 6){

            Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2],
            isOpen: true,
            }
        }else if(level == 7){

            Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2],
            isOpen: true,
            }
        }else if(level == 8){

            Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2],
            isOpen: true,
            }
        }else if(level == 9){

            Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2],
            isOpen: true,
            }
        }else{

            Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: b"None".to_ascii_string(),
            b_dudes: vector[dude1, dude2],
            isOpen: true,
            }
        } */
    }

}