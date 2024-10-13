from supabase_cams import SupaBaseCams


class Container:
    def __init__(self, name, parent_name):
        self.supabase_instance = SupaBaseCams.get_instance()
        self.name = name

        if parent_name is None:
            json_row = {
                'name': self.name
                , 'type_id': self.get_type_id(self.name)
            }
        else:
            json_row = {
                'name': self.name
                , 'type_id': self.get_type_id(self.name)
                , 'parent_id': self.get_parent_id(parent_name)
            }
        # print(json_row)
        data = self.supabase_instance.get_match_dataset('container', 'id', json_row)
        if 'id' not in data.json():
            data = self.supabase_instance.insert_row('container', json_row)
        self.id = data.data.__getitem__(0)['id']

    def get_type_id(self, name):
        if 'snapshots' in name:
            container_type = 'zip'
        else:
            container_type = 'directory'
        data = self.supabase_instance.get_eq_dataset('container_type', 'id', 'name', container_type)
        # print(data.data.__getitem__(0)['id'])
        return data.data.__getitem__(0)['id']

    def get_parent_id(self, parent_name):
        data = self.supabase_instance.get_eq_dataset('container', 'id', 'name', parent_name)
        # print(data.data.__getitem__(0)['id'])
        return data.data.__getitem__(0)['id']

    def get_id(self):
        return self.id