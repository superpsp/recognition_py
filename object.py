from supabase_cams import SupaBaseCams


class RecObject:
    def __init__(self, name, channel_id, container_id, probability):
        self.supabase_instance = SupaBaseCams.get_instance()
        self.name = name
        self.class_id = self.get_class_id(self.name)
#TODO: move all DDL to DB side
        json_row = {
            'class_id': self.class_id
            , 'channel_id': channel_id
            , 'container_id': container_id
        }

        data = self.supabase_instance.get_match_dataset(
            'object'
            , 'id'
            , json_row
        )
        if 'id' not in data.json():
            json_row = {
                'channel_id': channel_id
                , 'container_id': container_id
                , 'class_id': self.get_class_id(self.name)
                , 'probability': probability
            }
            data = self.supabase_instance.insert_row('object', json_row)
        self.id = data.data.__getitem__(0)['id']

    def get_class_id(self, name):
        data = self.supabase_instance.get_eq_dataset('class', 'id', 'name', name)
        # print(data.data.__getitem__(0)['id'])
        return data.data.__getitem__(0)['id']
