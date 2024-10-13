from supabase_cams import SupaBaseCams


class Container:
    def __init__(self, name, parent_name):
        self.supabase_instance = SupaBaseCams.get_instance()
        self.name = name

        if parent_name is None:
            params = {
                'p_name': self.name
            }
        else:
            params = {
                'p_name': self.name
                , 'p_parent_name': parent_name
            }

        self.id = self.supabase_instance.get_by_function(
            'get_or_create_container'
            , params
        ).data

    def get_id(self):
        return self.id